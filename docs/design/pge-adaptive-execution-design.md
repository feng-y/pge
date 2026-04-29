# PGE 自适应执行设计

> Version: 0.1.0
> Date: 2026-04-29
> Status: Draft
> Scope: execution mode 选择、fast path / lite / full / long-running 四级执行模式、artifact budget、deterministic check、evaluator 降级、state.json 与 progress.md 关系

---

## 1. Execution Mode Selection

### 问题

当前 PGE 对所有任务使用同一条重量级流水线：Planner → Preflight → Generator → Evaluator，每次运行产出 ~9 个管理 artifact。一个写 9 字节文件的 smoke test 也走完整流程，Planner 自己标注了 "pass-through" 但 orchestrator 仍然创建 Agent Team 并执行全部步骤。

### 设计原则

- Mode 选择发生在 Team 创建**之前**，不是之后
- 选择基于任务特征，不基于 Planner 输出（Planner 在 Mode 2+ 才存在）
- 简单确定性任务**禁止**使用 full P/G/E
- Agent Teams **禁止**用于低价值任务

### 决策树

```
orchestrator 收到任务
│
├─ 任务有确定性验收标准？（exact file content / command output / test pass）
│  ├─ YES → 任务是单步操作？（一条命令 / 一次文件写入）
│  │  ├─ YES → Mode 0: Direct Fast Path
│  │  └─ NO  → Mode 1: Lite PGE
│  └─ NO  → 任务需要多 slice / 长期执行？
│     ├─ YES → Mode 3: Long-running Multi-sprint PGE
│     └─ NO  → Mode 2: Full PGE Agent Teams
```

### 信号矩阵

| 信号 | Mode 0 | Mode 1 | Mode 2 | Mode 3 |
|------|--------|--------|--------|--------|
| 确定性验收（exact match / diff / test） | 必须 | 必须 | 可选 | 可选 |
| 单步操作 | 必须 | 否 | 否 | 否 |
| 需要设计决策 | 否 | 否 | 是 | 是 |
| 需要独立评估 | 否 | 否 | 是 | 是 |
| 跨多个 slice | 否 | 否 | 否 | 是 |
| 需要 checkpoint/recovery | 否 | 否 | 否 | 是 |

### Orchestrator 伪代码

```
function select_mode(task):
  if task.has_deterministic_acceptance:
    if task.is_single_step:
      return MODE_0
    else:
      return MODE_1
  else:
    if task.requires_multi_slice:
      return MODE_3
    else:
      return MODE_2
```

---

## 2. Mode 0: Direct Fast Path

### 适用场景

- 完全确定性的单步任务
- smoke test（写文件 + 验证内容）
- 已知结果的文件操作（copy / move / write exact content）
- 单条命令执行 + 输出匹配

### 执行流程

```
orchestrator 直接执行
│
├─ 1. 执行操作（write file / run command）
├─ 2. deterministic check（cat / diff / wc / exit code）
├─ 3. 写 result 到 state.json
└─ 4. 结束
```

### 关键约束

- **不创建 Agent Team**（无 TeamCreate / TeamDelete）
- **不调用 Planner / Generator / Evaluator**
- **不使用 LLM evaluator**——验证完全是 programmatic
- **零管理 artifact**——仅在 state.json 中记录一行 result
- 不写 progress.md

### Smoke Test 具体示例

当前 smoke test（`/pge-execute test`）的行为：

| 步骤 | 当前（Mode 2） | 应该（Mode 0） |
|------|----------------|----------------|
| 创建 Team | TeamCreate 3 agents | 不创建 |
| Planner | 产出 planner.md（标注 pass-through） | 跳过 |
| Preflight | 产出 contract-proposal.md + preflight.md | 跳过 |
| Generator | 产出 generator.md + pge-smoke.txt | 直接写 pge-smoke.txt |
| Evaluator | 产出 evaluator.md（6 维评分） | `cat pge-smoke.txt` == `pge smoke` |
| Summary | 产出 summary.md + progress.md | 不产出 |
| Artifacts | 9 个文件 | 1 个文件（pge-smoke.txt）+ state.json 更新 |

### state.json 记录格式

```jsonc
{
  "run_id": "<run_id>",
  "mode": 0,
  "state": "converged",
  "result": "PASS",
  "check": {
    "method": "exact_match",
    "expected": "pge smoke",
    "actual": "pge smoke",
    "pass": true
  },
  "artifact_refs": {
    "deliverable": ".pge-artifacts/pge-smoke.txt"
  }
}
```

---

## 3. Mode 1: Lite PGE

### 适用场景

- 有界任务，plan 显而易见（Planner 会说 "pass-through"）
- 有确定性或轻量级验收标准
- 不需要独立评估视角
- 例：根据明确 spec 生成单个文件、运行已有测试套件、按模板创建配置

### 执行流程

```
orchestrator
│
├─ 1. orchestrator 内联生成 brief（不创建 Planner agent）
├─ 2. Generator 执行（单 agent，无 Team）
├─ 3. deterministic check 或 lightweight verification
└─ 4. 写 result
```

### 关键约束

- **不创建 Agent Team**——Generator 作为单个 agent 调用
- **不调用 Planner**——orchestrator 自身产出 inline brief
- **不调用 Evaluator**——使用 deterministic check 或 binary pass/fail
- **最多 3 个 artifact**：input、generator output、result

### Artifact 清单

| Artifact | 必须/可选 | 说明 |
|----------|-----------|------|
| `<run_id>-input.md` | 必须 | 任务输入 + inline brief |
| `<run_id>-generator.md` | 必须 | Generator 产出记录 |
| `<run_id>-state.json` | 必须 | 运行状态 + check result |
| `<run_id>-progress.md` | 禁止 | Mode 1 不写 progress |

### state.json 记录格式

```jsonc
{
  "run_id": "<run_id>",
  "mode": 1,
  "state": "converged",
  "result": "PASS",
  "generator_called": true,
  "check": {
    "method": "test_exit_code",
    "command": "npm test -- --filter smoke",
    "exit_code": 0,
    "pass": true
  },
  "artifact_refs": {
    "input": ".pge-artifacts/<run_id>-input.md",
    "generator": ".pge-artifacts/<run_id>-generator.md"
  }
}
```

---

## 4. Mode 2: Full PGE Agent Teams

### 适用场景

- 任务有真正的歧义，需要 Planner 展开
- 复杂验收标准，需要独立评估视角
- 需要 Preflight negotiation 确保 Generator 和 Evaluator 对齐
- 例：实现新功能、修复复杂 bug、架构变更

### 执行流程

当前已有的完整 7 步生命周期（见 `ORCHESTRATION.md`）：

```
1. initialize run
2. create team (TeamCreate: planner, generator, evaluator)
3. planner handoff → planner.md
4. contract preflight → contract-proposal.md + preflight.md
5. generator handoff → generator.md
6. evaluator handoff → evaluator.md
7. route → summary.md + progress.md + state.json
   teardown (TeamDelete)
```

### 关键约束

- **必须创建 Agent Team**（3 agents）
- **必须走完整 P/G/E 流程**
- **Evaluator 使用完整评分**（简单任务可降级，见 §9）
- **最多 10 个 artifact**

### 与当前实现的关系

Mode 2 就是当前 `ORCHESTRATION.md` 定义的流程，无需修改。变化在于：orchestrator 不再对所有任务默认使用 Mode 2，而是通过 §1 的决策树选择合适的 mode。

---

## 5. Mode 3: Long-running Multi-sprint PGE

### 适用场景

- 大型任务，需要多个 slice 分阶段完成
- 需要 checkpoint 和 recovery 机制
- 需要跨 slice 的 progress 追踪
- 例：大规模重构、多文件功能实现、跨模块迁移

### 执行流程

```
orchestrator
│
├─ slice 1
│   ├─ create team
│   ├─ planner → slice goal + round contracts
│   ├─ round 1: preflight → generator → evaluator → route
│   ├─ round N: (retry / continue within slice)
│   ├─ checkpoint
│   └─ teardown team
├─ slice 2
│   ├─ create team (fresh context)
│   ├─ planner reads checkpoint → new slice goal
│   └─ ...
└─ slice M
    └─ final convergence
```

### 关键约束

- **每个 slice 创建/销毁独立 Team**（防止 context 膨胀）
- **每个 slice 边界写 checkpoint**
- **最多 10 个 artifact per round** + 累积 progress
- **Evaluator 使用完整 6 维评分**
- 遵循 `pge-multiround-runtime-design.md` 中的 run/slice/round 层次

### Checkpoint 内容

```jsonc
{
  "run_id": "<run_id>",
  "slice_id": "<slice_id>",
  "slice_sequence": 2,
  "completed_slices": [
    {
      "slice_id": "...-s1",
      "goal": "...",
      "verdict": "PASS",
      "key_outputs": ["file1.ts", "file2.ts"]
    }
  ],
  "remaining_goal": "...",
  "context_for_next_slice": "..."
}
```

### 与 multiround-runtime-design 的关系

Mode 3 是 `pge-multiround-runtime-design.md` 定义的完整 run/slice/round 模型的实现。Mode 0-2 是该模型的退化形式（Mode 0/1 = 单 round 无 slice，Mode 2 = 单 slice 单/多 round）。

---

## 6. PASS_THROUGH Route

### 问题

当前 Planner 可以识别 pass-through 任务（在 planner output 中标注），但 orchestrator 没有对应的短路机制——仍然走完整 Mode 2 流程。这是一个硬性缺陷，不是可选优化。

### 硬性要求

**当 Planner 返回 pass-through 信号时，orchestrator 必须短路。**

### 机制

有两种情况触发 pass-through：

#### 情况 A：Mode 选择阶段（§1 决策树）

Orchestrator 在创建 Team 之前识别出任务是确定性的 → 直接选择 Mode 0 或 Mode 1。Planner 不参与。

这是主要路径。大多数 pass-through 任务应在此阶段被拦截。

#### 情况 B：Planner 运行后发现 pass-through

在 Mode 2 流程中，Planner 已经被调用，但 Planner 在输出中标注了 `pass_through: true`。

短路流程：

```
planner.md 包含 pass_through: true
│
├─ orchestrator 读取 planner output
├─ 检测 pass_through 信号
├─ 跳过 preflight（不产出 contract-proposal.md / preflight.md）
├─ 降级到 Mode 1 执行：
│   ├─ Generator 直接执行（已在 Team 中，复用）
│   ├─ deterministic check（不调用 Evaluator）
│   └─ 写 result
├─ teardown team
└─ 结束
```

### Planner pass_through 信号格式

在 `<run_id>-planner.md` 中：

```yaml
pass_through: true
pass_through_reason: "task is a single deterministic file write with exact expected content"
recommended_mode: 0
```

### Orchestrator 行为规则

| Planner 输出 | Orchestrator 行为 |
|-------------|------------------|
| `pass_through: true`, `recommended_mode: 0` | 跳过 preflight + generator + evaluator，orchestrator 直接执行 + deterministic check |
| `pass_through: true`, `recommended_mode: 1` | 跳过 preflight + evaluator，Generator 直接执行 + deterministic check |
| `pass_through: false` 或无此字段 | 继续正常 Mode 2 流程 |

### 与 §1 的关系

§1 的决策树是第一道防线（Team 创建前）。§6 是第二道防线（Planner 运行后）。两者互补：

- 如果 §1 正确识别 → 任务不进入 Mode 2，Planner 不被调用
- 如果 §1 误判（将简单任务送入 Mode 2）→ Planner 的 pass_through 信号触发短路

---

## 7. Artifact Budget

### 每 Mode Artifact 限制

| Artifact | Mode 0 | Mode 1 | Mode 2 | Mode 3 |
|----------|--------|--------|--------|--------|
| `<run_id>-input.md` | 不产出 | 必须 | 必须 | 必须（每 round） |
| `<run_id>-planner.md` | 不产出 | 不产出 | 必须 | 必须（每 round） |
| `<run_id>-contract-proposal.md` | 不产出 | 不产出 | 必须 | 必须（每 round） |
| `<run_id>-preflight.md` | 不产出 | 不产出 | 必须 | 必须（每 round） |
| `<run_id>-generator.md` | 不产出 | 必须 | 必须 | 必须（每 round） |
| `<run_id>-evaluator.md` | 不产出 | 不产出 | 必须 | 必须（每 round） |
| `<run_id>-state.json` | 必须 | 必须 | 必须 | 必须 |
| `<run_id>-summary.md` | 不产出 | 不产出 | 必须 | 必须（每 slice） |
| `<run_id>-progress.md` | 不产出 | 不产出 | 必须 | 必须（累积） |
| deliverable（如 pge-smoke.txt） | 必须 | 必须 | 必须 | 必须 |

### 数量上限

| Mode | 管理 Artifact 上限 | 说明 |
|------|-------------------|------|
| Mode 0 | 0-1 | 仅 state.json 更新（inline，不单独成文件）+ deliverable |
| Mode 1 | 3 | input + generator + state.json |
| Mode 2 | 10 | 当前完整 artifact 集 |
| Mode 3 | 10 per round | + 跨 slice 的 checkpoint 和累积 progress |

### 强制规则

- Orchestrator 在选择 mode 后，设置 `artifact_budget` 上限
- 任何 agent 产出超过 budget 的 artifact → orchestrator 记录 warning 但不阻塞
- Mode 0 和 Mode 1 **禁止**产出 planner.md / preflight.md / evaluator.md
- Mode 0 **禁止**产出 progress.md 和 summary.md

---

## 8. Deterministic Check

### 问题

对于有确定性验收标准的任务（文件内容匹配、命令输出匹配、测试通过/失败），使用 LLM Evaluator 是浪费。`cat file | diff` 比 6 维 LLM 评分更快、更可靠、更便宜。

### Check 接口

```jsonc
{
  "check_type": "exact_match | contains | regex | exit_code | file_exists | diff",
  "expected": "<expected value or pattern>",
  "actual_source": {
    "type": "file_content | command_output | file_exists",
    "path": "<file path>",          // for file_content / file_exists
    "command": "<shell command>"     // for command_output
  },
  "result": {
    "actual": "<actual value>",
    "pass": true,
    "detail": "exact match confirmed"
  }
}
```

### 支持的 check 类型

| check_type | 语义 | 示例 |
|-----------|------|------|
| `exact_match` | actual == expected（trim whitespace） | 文件内容 = "pge smoke" |
| `contains` | actual 包含 expected | 输出包含 "BUILD SUCCESS" |
| `regex` | actual 匹配 regex pattern | 版本号匹配 `\d+\.\d+\.\d+` |
| `exit_code` | 命令退出码 == expected | `npm test` 退出码 = 0 |
| `file_exists` | 文件存在 | `.pge-artifacts/pge-smoke.txt` 存在 |
| `diff` | 两个文件内容相同 | generated file == golden file |

### 与 Mode 的关系

| Mode | 验证方式 |
|------|---------|
| Mode 0 | 仅 deterministic check，无 LLM |
| Mode 1 | 优先 deterministic check；无确定性标准时用 binary pass/fail |
| Mode 2 | Evaluator 评分（可降级，见 §9）；有确定性标准时 Evaluator 必须引用 check 结果 |
| Mode 3 | 同 Mode 2，每 round 独立 check |

### Orchestrator 职责

Orchestrator（不是 Evaluator）执行 deterministic check。这确保：
- Mode 0/1 不需要 Evaluator agent
- Mode 2 中 Evaluator 可以引用 check 结果但不替代它
- Check 结果写入 state.json 的 `check` 字段

---

## 9. Evaluator Degradation

### 问题

当前 Evaluator 对所有任务使用完整 6 维评分（correctness, completeness, quality, contract_adherence, evidence_basis, risk_flags）。对于简单任务，大部分维度不适用或答案显而易见。

### 降级矩阵

| Mode | 验证方式 | 评分维度 |
|------|---------|---------|
| Mode 0 | deterministic check only | 无 LLM 评分 |
| Mode 1 | deterministic check → binary pass/fail | 无 LLM 评分 |
| Mode 2 简单任务 | Evaluator + reduced scoring | 3 维：correctness, completeness, contract_adherence |
| Mode 2 复杂任务 | Evaluator + full scoring | 6 维全部 |
| Mode 3 | Evaluator + full scoring | 6 维全部 |

### "简单任务" 判定

Mode 2 内部区分简单/复杂：

- **简单**：Planner 标注 `complexity: low`，且验收标准中有确定性成分
- **复杂**：Planner 标注 `complexity: medium/high`，或验收标准完全依赖主观判断

### Reduced Scoring（3 维）

跳过的维度及原因：

| 跳过的维度 | 原因 |
|-----------|------|
| `quality` | 简单任务的 quality 由 correctness 隐含 |
| `evidence_basis` | 简单任务的 evidence 是 deterministic check 结果 |
| `risk_flags` | 简单任务的 risk 在 preflight 阶段已覆盖 |

### Evaluator 行为变化

Evaluator agent 定义（`agents/pge-evaluator.md`）不需要修改。降级由 orchestrator 在 evaluator handoff 中控制：

```
# evaluator handoff（简单任务）
评分维度：仅 correctness, completeness, contract_adherence
跳过维度：quality, evidence_basis, risk_flags（标注 "skipped: simple task"）
deterministic check 结果：[引用 state.json 中的 check 字段]
```

---

## 10. state.json / progress.md Relationship

### 问题

当前 `state.json` 和 `progress.md` 存在信息重复。两者都记录运行状态、当前阶段、verdict 等。维护两份同步的状态源增加了复杂度且没有额外价值。

### 设计决策

**`state.json` 是唯一的 machine-readable source of truth。`progress.md` 是从 `state.json` 派生的 human-readable 视图。**

### 职责划分

| 属性 | state.json | progress.md |
|------|-----------|-------------|
| 角色 | Source of truth | Derived view |
| 格式 | JSON | Markdown |
| 读者 | Orchestrator / agents / 自动化 | 人类 / debug |
| 写入时机 | 每次状态变更 | 仅 Mode 2+ 的关键节点 |
| 写入者 | Orchestrator（main） | Orchestrator（main） |
| 必须存在 | 所有 Mode | 仅 Mode 2+ |

### 每 Mode 行为

| Mode | state.json | progress.md |
|------|-----------|-------------|
| Mode 0 | 写入（minimal：mode, state, result, check） | **不写** |
| Mode 1 | 写入（含 generator_called, check） | **不写** |
| Mode 2 | 写入（完整字段） | 写入（在 planner/generator/evaluator 完成后更新） |
| Mode 3 | 写入（完整字段 + slice/round tracking） | 写入（每 round 更新 + 跨 slice 累积） |

### state.json 新增字段

在现有 schema（见 `runtime/artifacts-and-state.md`）基础上新增：

```jsonc
{
  // === 新增：mode 相关 ===
  "mode": 0,                    // 0 | 1 | 2 | 3
  "artifact_budget": 1,         // 当前 mode 的 artifact 上限
  "pass_through": false,        // planner 是否标注 pass-through

  // === 新增：deterministic check ===
  "check": {
    "check_type": "exact_match",
    "expected": "pge smoke",
    "actual": "pge smoke",
    "pass": true
  },

  // === 现有字段保持不变 ===
  "run_id": "...",
  "state": "converged",
  // ...
}
```

### progress.md 生成规则

当 progress.md 需要写入时（Mode 2+），其内容**必须**从 state.json 派生：

```markdown
# Run Progress: <run_id>

## 状态
- Mode: <state.mode>
- Phase: <state.state>
- Verdict: <state.verdict>
- Route: <state.route>

## Artifact 产出
<从 state.artifact_refs 生成列表>

## Check 结果
<从 state.check 生成，如果存在>
```

Orchestrator 不得在 progress.md 中写入 state.json 中不存在的状态信息。如果 progress.md 和 state.json 不一致，以 state.json 为准。

---

## 附录：Mode 选择与当前 repo 的对齐

### 需要修改的文件

| 文件 | 修改内容 |
|------|---------|
| `skills/pge-execute/SKILL.md` | 在 orchestration 入口增加 mode selection 逻辑 |
| `skills/pge-execute/ORCHESTRATION.md` | 增加 Mode 0/1 的生命周期定义 |
| `skills/pge-execute/runtime/artifacts-and-state.md` | 增加 mode / check / artifact_budget 字段 |
| `skills/pge-execute/contracts/runtime-state-contract.md` | 增加 mode 相关字段的 schema |
| `skills/pge-execute/contracts/routing-contract.md` | 增加 pass_through route 处理 |
| `agents/pge-planner.md` | 增加 pass_through / complexity 输出字段 |
| `skills/pge-execute/handoffs/evaluator.md` | 支持 reduced scoring handoff |

### 不需要修改的文件

| 文件 | 原因 |
|------|------|
| `agents/pge-generator.md` | Generator 行为不因 mode 变化 |
| `agents/pge-evaluator.md` | Evaluator 降级由 handoff 控制，agent 定义不变 |
| `skills/pge-execute/contracts/evaluation-contract.md` | 评分维度定义不变，降级是 handoff 层面的选择 |
