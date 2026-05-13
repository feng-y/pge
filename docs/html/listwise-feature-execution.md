# Listwise 特征执行语义

> 本文档描述 Listwise 路径下特征执行的完整语义，包括三类特征的执行、存储和消费方式。
> 服务于 projection 统一重构的设计决策。

---

## 概述

Listwise 模型的特征执行产出三类特征，最终在 `ListwiseQSModel::generate_input()` 中组装为 Galaxy input tensors：

| 特征类型 | 语义 | 执行粒度 | Galaxy input 粒度 | 转换方式 |
|---------|------|---------|------------------|---------|
| **User** | 请求级用户特征 | 1 份 | 1 份（broadcast） | 直接传递 |
| **Item** | 候选广告特征 | M 个 raw items | N × list_size | gather |
| **Seq** | 序列上下文特征 | unique_sequences | N × list_size | indices + padding |

---

## 执行链路

```
process_listwise
│
└── schedule_module_listwise
    │
    └── stage_parse_request
        │
        ├── calculate_feasign (CalculateFeasignModule, args="listwise")
        │   ├── prepare_fs_context()        → 构建 FeaContext
        │   ├── calculate_items_feasign()   → item_feasign_list [M]
        │   │   或 run_hermes()             → FeatureResult
        │   └── convert_to_tensor()         → user_feasign_tensor_list
        │                                   → item_feasign_tensor_list
        │
        └── calculate_seq_feasign (CalculateSeqFeasignModule)
            ├── calculate_items_feasign()   → seq_feasign_list [unique_seq_count]
            │   (ParallelSeqFeaRunner)
            └── convert_to_tensor()         → seq_item_total_map
                                              (不构建 tensor，只整理 map)
```

---

## 第一次特征执行：CalculateFeasignModule（User + Item）

### 输入

| 输入 | 来源 | 说明 |
|------|------|------|
| `request.items()` | Listwise 请求体 | M 个候选广告 item（card proto） |
| `FSRuntime` | `DataKeeper::get_data<FsCurator>()` | FS 特征配置 + slot 定义的请求级快照 |
| `FeaContext` | `prepare_fs_context()` 初始化 | 特征执行上下文（含 user profile、dict 引用等） |

### 执行逻辑（FS 路径）

```cpp
// calculate_feasign_module.cpp:168
// 逐 item 串行执行 FS 特征计算（单线程，非并行）
for (size_t idx = 0; idx < item_size; ++idx) {
    p_fea_ctx->_p_card = &request.items(idx);  // 设置当前 item
    p_fea_ctx->reset(0);
    fea_runner.run(*p_fea_ctx);                 // FS 引擎执行所有 slot 的特征计算
    
    // 输出: p_fea_ctx->_feasign_list (SlotStorage: 所有 slot 的 feasign)
    item_feasign_list[idx] = std::move(p_fea_ctx->_feasign_list);
    
    // User dense: 仅从 idx==0 收集
    if (idx == 0) user_dense_fea_map = p_fea_ctx->_user_dense_fea_map;
    // Item dense: 每个 item 收集
    item_dense_fea_map[slot_id][idx] = p_fea_ctx->_item_dense_fea_map[slot_id];
}
```

**关键细节**：
- Listwise 路径的 item 特征执行是**串行**的（不走 `ParallelFeaRunner`），因为 M 通常较小（< 100）
- 每个 item 的 `_feasign_list` 包含该 item 所有 slot 的 feasign（user + item 混在一起）
- User/Item 的分离在 `convert_to_tensor()` 阶段按 `SlotType` 完成

### 执行逻辑（Hermes 路径）

```cpp
// calculate_feasign_module.cpp:308
// Hermes 批量执行所有 items 的特征
hermes_runner->RunMaskV2Pro(specpro, fea_ctx, masks, thread_num);
hermes_runner->ToFeatureResultMaskV2(feature_result);
// feature_result 包含 user_feasign_span + item_feasign_span
```

### convert_to_tensor：分离 User/Item 并构建 tensor

```cpp
// calculate_feasign_module.cpp:258
// 遍历每个 item 的 feasign_list，按 SlotType 分流
for (idx = 0; idx < item_size; ++idx) {
    for (auto sign: item_feasign_list[idx]) {
        int slot_id = sign >> 48;  // feasign 高 16 位是 slot_id
        if (idx == 0 && conf_ptr->slot_type == SlotType::USER) {
            user_map[slot_id].push_back(sign);      // User: 仅从第一个 item 收集
        } else if (conf_ptr->slot_type == SlotType::ITEM) {
            item_map[slot_id].push_back(sign);      // Item: 每个 item 各自收集
        }
    }
    merge_map(item_size, idx, item_map, item_total_map);  // 聚合为 [M][feasigns]
}

// 构建 tensor
builder.build_user_feasign_tensor(user_slot_config_vec, user_map, ...)
    → user_feasign_tensor_list (values + row_splits 成对)
builder.build_item_feasign_tensor(item_slot_config_vec, item_total_map, item_size, ...)
    → item_feasign_tensor_list (values + row_splits 成对)
```

### 输出

| 输出 | 存储位置 | 形状 |
|------|----------|------|
| User tensors | `session_data.user_feasign_tensor_list()` | 每 slot 一对 (values, row_splits)，共 1 份 |
| Item tensors | `session_data.item_feasign_tensor_list()` | 每 slot 一对 (values, row_splits)，共 M 份 |
| User dense | `session_data.user_dense_fea_map()` | slot_id → vector\<float\> |
| Item dense | `session_data.item_dense_fea_map()` | slot_id → vector\<vector\<float\>\>[M] |

---

## 第二次特征执行：CalculateSeqFeasignModule（Seq Context）

### 输入

| 输入 | 来源 | 说明 |
|------|------|------|
| `sequence_score_collection_map` | 上游打分意图 | 所有待打分序列（按业务 key 分组） |
| `FSRuntime` | 同上 | 复用同一份 FS 配置 |
| `FeaContext` | 继承自第一次执行 | 第一次 `prepare_fs_context()` 已初始化 |

### 执行逻辑（FS 路径）

```cpp
// calculate_feasign_module.cpp:793
// Phase 1: 序列去重
for (const auto& [_, score_collection]: score_info_collection_map) {
    feasign_storage.add_sequences(score_collection.score_info_list);
    // 按 vector<int32_t> 内容 hash 去重，N 个序列 → K 个 unique sequences
}

// Phase 2: 并行特征执行
ParallelSeqFeaRunner::parallel_run(fs_runtime, fea_ctx, unique_sequences, ...)
```

**ParallelSeqFeaRunner 内部**：
```cpp
// parallel_fea_runner.cpp:285
// 将 K 个 unique sequences 按 num_threads 分片
// 每个 SubSeqFeaRunner 拥有独立的 FeaRunner + FeaContext 副本

// SubSeqFeaRunner::run() (parallel_fea_runner.cpp:248)
for (i = start; i < end; ++i) {
    p_fea_ctx->_p_sequence = &unique_sequences[i];  // 设置当前序列
    p_fea_ctx->reset(0);
    p_fea_runner->run(*p_fea_ctx);                   // FS 引擎执行序列特征 slot
    
    // 输出: p_fea_ctx->_feasign_list (该序列的所有 feasign)
    temp_ins_batch.push_back(std::move(p_fea_ctx->_feasign_list));
}
```

**并行策略**：
- 第一个 sequence 先单独执行一次（`run_once=true`），用于初始化 FS 静态变量（`set_pre_calc`）
- 然后启动 bthread 并行执行剩余 sequences
- 所有线程完成后，按顺序合并结果到 `seq_feasign_list_`

### convert_to_tensor：整理为 slot→batch map

```cpp
// calculate_feasign_module.cpp:856
// 注意：不构建 tensor，只整理数据结构
for (idx = 0; idx < unique_seq_count; ++idx) {
    for (auto sign: seq_feasign_list[idx]) {
        int slot_id = sign >> 48;
        update_map(slot_id, sign, item_map);
    }
    merge_map(unique_seq_count, idx, item_map, item_total_map);
}
// 输出: seq_item_total_map → slot_id → [K][feasigns]
// K = unique_seq_count，每个 unique sequence 对应一行
```

### 输出

| 输出 | 存储位置 | 形状 |
|------|----------|------|
| Seq feasign list | `session_data.feasign_storage().seq_feasign_list_` | [K] × SlotStorage |
| Seq item total map | `session_data.seq_item_total_map()` | slot_id → [K][feasigns] |
| Sequence mappings | `session_data.feasign_storage().sequence_mappings_` | sequence → unique index |

---

## Galaxy Input 组装：ListwiseQSModel::generate_input()

`generate_input()` 消费两次特征执行的输出，组装为模型可消费的 Galaxy input tensors。

### User Features → 直接传递

```cpp
// listwise_qs_model.cpp:122
// 按 slot_idx_map 过滤，直接加入 inputs
for (i = 0; i < user_tensors.size(); ++i) {
    if (slot_idx_map.contains(user_slot_ids[i])) {
        inputs.emplace_back(user_output_tensor_names[i], user_tensors[i]);
    }
}
```

**Galaxy input 形状**：`[1, ...]`（模型内部 broadcast）

### Item Features → gather 展开

```cpp
// listwise_qs_model.cpp:168
// Item tensors 形状是 [M, ...]，需要按 sequences 展开为 [N × list_size, ...]
// sequences[i] = score_info_list[i]->_sequence (如 [3, 1, 7, 2])
// gather 操作：按 sequence 中的 item indices 从 M 个 item tensors 中取值
afs::gather(item_tensors[i], item_tensors[i+1],  // values + row_splits
            ..., sequences, list_size,
            outputs, output_tensor_names, slot_ids);
```

**转换语义**：
```
item_tensors [M items 的特征]
    + sequences[N] (每个 batch row 引用哪些 items，以什么顺序)
    → gather → [N × list_size] (每个位置对应一个 item 的特征)
    
例: M=10 个 items，N=50 个 sequences，list_size=4
    sequence[0] = [3, 1, 7, 2] → 取 item[3], item[1], item[7], item[2] 的特征
    输出: [50 × 4 = 200] 行的 tensor
```

**Galaxy input 形状**：`[N × list_size, ...]`

### Seq Features → indices 展开 + padding

```cpp
// listwise_qs_model.cpp:190
// Phase 1: 每个 batch row 找到其 unique sequence 的 index
for (seq : sequences) {
    indices.push_back(feasign_storage.get_indice(*seq));
    effective_lens.push_back(seq->size());
}

// Phase 2: 从 [K][feasigns] 展开为 [N × list_size][1]
create_padded_map(seq_slot_config_vec, src_seq_item_total_map,
                  indices, effective_lens, list_size, seq_item_total_map);
// indices[i] 指向 unique sequence 的 index
// effective_lens[i] 标记有效长度，超出部分 padding 为 -1

// Phase 3: rehash（如果配置了 rehash_bucket_map）
for ([slot_id, batch_seq_feasigns] : seq_item_total_map) {
    feasign & bucket_mask;  // 按 slot 粒度 rehash
}

// Phase 4: 构建 tensor
builder.build_item_feasign_tensor(seq_slot_config_vec, seq_item_total_map, batch_size, ...)
```

**转换语义**：
```
seq_item_total_map [K unique sequences 的特征, 每个 sequence 有 list_size 个位置]
    + indices[N] (每个 batch row 对应哪个 unique sequence)
    + effective_lens[N] (每个 sequence 的有效长度)
    → create_padded_map → [N × list_size, 1]
        有效位置: 取对应 unique sequence 的 feasign
        padding 位置: 填充 -1 (uint64_t max)
    → build_tensor → [N × list_size, ...]
```

**Galaxy input 形状**：`[N × list_size, ...]`

### Masks → 标记有效位置

```cpp
// listwise_qs_model.cpp:264
// masks[i * list_size + j] = 1.0 if position j is valid, 0.0 if padding
for (idx = 0; idx < batch_size; ++idx) {
    effective_len = min(sequences[idx]->size(), list_size);
    for (j = 0; j < effective_len; ++j) {
        masks[idx * list_size + j] = 1.0f;
    }
}
```

**Galaxy input 形状**：`[N × list_size]`（float，1.0=有效，0.0=padding）

### batch_size scalar

```cpp
batch_tensor.scalar<int64_t>()() = batch_size * list_size;  // N × list_size
```

**Galaxy input 形状**：`[N × list_size, ...]`

---

## 与精排的对比

| 维度 | 精排（Pointwise） | Listwise |
|------|------------------|----------|
| 特征类型 | user + item | user + item + seq |
| 特征执行粒度 | N items | M items + unique_sequences |
| Galaxy batch_size | N | N × list_size |
| Item 特征转换 | 无（1:1） | gather（M → N×list_size） |
| Seq 特征 | 无 | indices + padding（unique → N×list_size） |
| Masks | 无 | 有（标记 padding 位置） |

---

## Seq convert_to_tensor 的实际语义

`CalculateSeqFeasignModule::convert_to_tensor()` 名称有误导性——它**不构建 tensor**，只是将 `SlotStorage` 整理为 map 结构：

```cpp
// calculate_feasign_module.cpp:856
// 输入: feasign_storage.seq_feasign_list_ [K × SlotStorage]
// 输出: session_data.seq_item_total_map() → slot_id → [K][feasigns]
for (size_t idx = 0; idx < item_size; ++idx) {
    // 将每个 unique sequence 的 SlotStorage 按 slot_id 拆分聚合
    for (auto sign: seq_feasign_list[idx]) {
        int slot_id = sign >> 48;
        afs::update_map(slot_id, sign, item_map);
    }
    afs::merge_map(item_size, idx, item_map, item_total_map);
}
```

真正的 tensor 构建延迟到 `ListwiseQSModel::generate_input()` 阶段，因为那时才知道每个 batch row 对应哪个 unique sequence（需要 indices 展开 + padding）。

---

## 关键参与者

| 组件 | 位置 | 职责 |
|------|------|------|
| `SequenceScoreType` | type_define.h:962 | 打分意图载体，携带 `_sequence`（item indices 排列） |
| `SequenceScoreCollectionMap` | type_define.h:1010 | 按业务 key 分组的序列打分意图集合 |
| `FeasignStorage` | type_define.h:1027 | 序列去重 + 结果索引（避免重复特征计算） |
| `CalculateSeqFeasignModule` | calculate_feasign_module.h:63 | 编排层：去重 → 并行执行 → 整理输出 |
| `ParallelSeqFeaRunner` | parallel_fea_runner.h:173 | 并行调度：按线程数分片 unique sequences |
| `SubSeqFeaRunner` | parallel_fea_runner.h:126 | 执行单元：独立 FeaRunner + FeaContext，逐序列跑 FS |
| `FeaRunner` | fea/fea_runner.h | FS 特征执行引擎（底层 slot 计算） |
| `DataKeeper::get_data<FsCurator>` | data/ | 提供 FSRuntime（FS 配置 + slot 定义的请求级快照） |
| `ListwiseQSModel::generate_input` | predict/listwise_qs_model.cpp:190 | 消费者：indices 展开 + padding → Galaxy tensor |

---

## 代码锚点

- `model_server/model_server/modules/calculate_feasign_module.cpp:168` — `CalculateFeasignModule::calculate_items_feasign()`
- `model_server/model_server/modules/calculate_feasign_module.cpp:793` — `CalculateSeqFeasignModule::calculate_items_feasign()`
- `model_server/model_server/modules/calculate_feasign_module.cpp:856` — `CalculateSeqFeasignModule::convert_to_tensor()`
- `model_server/model_server/fea/parallel_fea_runner.h:173` — `ParallelSeqFeaRunner`
- `model_server/model_server/predict/listwise_qs_model.cpp:83` — `ListwiseQSModel::generate_input()`
- `model_server/model_server/predict/listwise_qs_model.cpp:190` — seq context feature 构建
- `model_server/model_server/afs/tensor_util.cpp:625` — `create_padded_map()`
- `model_server/model_server/type_define.h:962` — `SequenceScoreType`
- `model_server/model_server/type_define.h:1027` — `FeasignStorage`
- `model_server/model_server/service_impl.cpp:682` — `ServiceImpl::process_listwise()`
- `model_server/production/conf/mix_ads/ordinary/module_schedule_listwise.conf` — Listwise 模块调度配置
