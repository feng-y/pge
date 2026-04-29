# PGE Evaluator Acceptance Surface Design

> 版本: 0.2.0
> 日期: 2026-04-29
> 状态: 设计草案
> 说明: 文件名保留 `threshold-design` 仅为历史连续性；当前设计目标已收敛为“紧凑验收面”，不是“默认重型阈值矩阵”

---

## 1. 设计结论

Evaluator 的职责应该收敛为三件事：

- **独立验收**：直接检查真实 deliverable 和关键证据
- **路由裁决**：给出 `PASS / RETRY / BLOCK / ESCALATE` 与 `next_route`
- **成本门控**：在 preflight / triage 阶段决定 `FAST_PATH / LITE_PGE / FULL_PGE / LONG_RUNNING_PGE`

Evaluator 不应默认承担：

- 长篇审计写作
- 6 维评分矩阵
- weighted score
- blocking-flag 大表
- confidence matrix

原因很直接：这些重型输出会让 Evaluator 自己变成收敛瓶颈，尤其会直接破坏 `FAST_PATH`。

---

## 2. 为什么放弃“默认重评分”

### 2.1 smoke test 已经证明它太重

简单确定性任务如果还要求：

- 多维度评分
- 加权总分
- blocking flags
- 长篇 rationale

那么运行成本会被评估面本身吞掉，而不是花在交付物验证上。

### 2.2 Anthropic 的对齐方式

Anthropic 的经验支持：

- 要有独立 Evaluator gate
- 要有清晰的 acceptance frame
- 要惩罚虚假收敛和自我说服

但这不等于“每个任务都默认写大评分表”。对 PGE 当前阶段，更合理的映射是：

- `FAST_PATH`: lightweight verdict
- `LITE_PGE`: compact core scoring
- `FULL_PGE`: compact core scoring + 简短风险说明
- deeper audit: 仅在显式要求时启用

---

## 3. mode-aware 验收面

### 3.1 `FAST_PATH`

目标：最快完成诚实闭环。

必须判断：

- deliverable 是否存在
- deterministic / exact-match check 是否通过
- 是否有明显 scope violation
- verdict 与 route

不做：

- weighted score
- 大评分矩阵
- confidence matrix
- 默认长篇说明

### 3.2 `LITE_PGE`

目标：保留独立验收，但避免 full artifact + heavy review。

使用 3 个 compact dimensions：

- `correctness`
- `contract_compliance`
- `evidence_sufficiency`

每个维度 1-5 分。
PASS 条件：所有 core dimensions `>= 3`。
不计算 weighted total。

### 3.3 `FULL_PGE`

目标：保持完整闭环，但仍然以“能否收敛”为中心。

使用 3 个 compact dimensions：

- `deliverable_alignment`
- `contract_compliance`
- `evidence_sufficiency`

允许补充简短风险说明，但默认不引入：

- 6 维矩阵
- blocking flag 总表
- confidence matrix

### 3.4 `LONG_RUNNING_PGE`

目标：保持 verdict 可路由、可恢复、可压缩。

即使任务更长，也不应该自动回退到“越长越要写重型评审稿”。

---

## 4. 核心判定规则

### 4.1 verdict 选择

- `PASS`: 当前 contract 满足，证据充分，允许收敛或继续
- `RETRY`: contract 仍然有效，问题可在当前轮本地修复
- `BLOCK`: 缺少必要验收条件，当前结果不能接受
- `ESCALATE`: 当前 contract 已经不是正确的修复框架

原则：

**选择能正确解释失败的最窄 verdict。**

### 4.2 compact score 规则

仅适用于 `LITE_PGE` / `FULL_PGE`。

1-5 分含义：

| 分数 | 含义 |
|------|------|
| 1 | 缺失或明显不可接受 |
| 2 | 存在但仍低于验收线 |
| 3 | 最低可接受 |
| 4 | 良好且有独立证据支持 |
| 5 | 明显高于 contract 最低要求 |

规则：

- 任一 core dimension `< 3` → 不能 PASS
- 不计算 weighted score
- 不用总分掩盖局部失败

---

## 5. anti-slop 规则

以下模式直接说明 Evaluator 还没有真正完成独立验收：

| 规则 | 触发条件 | 效果 |
|------|----------|------|
| `praise_without_substance` | 只有积极形容词，没有具体证据 | 不能 PASS |
| `existence_as_quality` | 只证明文件/section 存在，没有证明内容满足 contract | 不能 PASS |
| `self_report_as_primary_evidence` | 主要依赖 Generator 自述 | 不能 PASS |
| `issue_minimization` | 明知存在 material issue，仍无反证地给 PASS | verdict 必须降级 |

---

## 6. 输出格式

所有模式都必须保留：

```markdown
## verdict

## evidence

## violated_invariants_or_risks

## required_fixes

## next_route

## route_reason

## independent_verification
```

只有 `LITE_PGE` / `FULL_PGE` 默认增加：

```markdown
## compact_scores
```

`FAST_PATH` 默认不要求 `compact_scores`。

---

## 7. 示例粒度

### 7.1 FAST_PATH PASS

适合：

- smoke file exact match
- 单文件 deterministic write
- 单命令 deterministic output

期望产出：

- 1-3 条 concrete evidence
- 1 条 independent verification
- 简短 route reason

### 7.2 LITE_PGE RETRY

适合：

- deliverable 已存在
- contract 方向正确
- 但证据不足或有局部缺口

期望产出：

- `compact_scores`
- 简短 `required_fixes`
- `next_route = retry`

### 7.3 FULL_PGE ESCALATE

适合：

- contract 和实现语义已经明显错位
- retry 只会重复同样的错误

期望产出：

- `compact_scores`
- 清晰指出为什么当前 contract 不再是公平验收框架
- `next_route = return_to_planner`

---

## 8. 与 runtime 的接口要求

需要和以下文件保持一致：

- `skills/pge-execute/contracts/evaluation-contract.md`
- `skills/pge-execute/handoffs/evaluator.md`
- `agents/pge-evaluator.md`
- `docs/design/pge-adaptive-execution-design.md`
- `docs/design/pge-rebuild-plan.md`

一致性要求：

- `FAST_PATH` 不默认要求评分
- `LITE_PGE` / `FULL_PGE` 只默认要求 compact scores
- verdict 必须服务 routing，不服务长篇评审写作
- anti-slop 规则必须能阻止“看起来像通过、实际上没验证”的假收敛

---

## 9. Phase 1 验收目标

Phase 1 完成时，应满足：

1. Evaluator 契约明确只有三类核心职责：独立验收、路由裁决、成本门控
2. `FAST_PATH` 的 verdict 可以在轻量验证后快速收敛
3. `LITE_PGE` / `FULL_PGE` 有统一的 compact acceptance surface
4. repo 中不再把 weighted score / 6 维矩阵 / blocking flag matrix 作为默认目标格式
5. 至少有 3 条 AI slop 规则进入 runtime authority 文档
