# PGE 改建进度追踪

Updated: 2026-04-29

---

## 总览

| Phase | 名称 | 状态 | 依赖 | 优先级 |
|-------|------|------|------|--------|
| 0 | 设计文档对齐 | DONE | 无 | - |
| 1 | Evaluator 硬阈值 | TODO | 无 | P0 |
| 2 | Multi-round 路由 | TODO | 无（可与 P1 并行） | P0 |
| 3 | Preflight 协商增强 | TODO | Phase 1 | P1 |
| 4 | Planner intake negotiation | TODO | 建议 Phase 1-2 后 | P1 |
| 5 | Checkpoint 和恢复 | TODO | Phase 2 | P2 |

---

## Phase 0: 设计文档对齐 — DONE

在 Round 4 post-review revision 中完成。

- [x] 所有设计文档 artifact 路径使用 `skills/pge-execute/` 前缀
- [x] runtime-state schema 统一（含 contract-negotiation 字段）
- [x] 状态名统一使用 `planning_round`
- [x] "slice" 术语替代 "sprint"
- [x] 历史 artifact 命名差异已标注

---

## Phase 1: Evaluator 硬阈值 — TODO

**目标**: Evaluator 从叙述性判断升级为量化评分 + 硬阈值。

**为什么优先**: Evaluator 质量是整个 harness 的瓶颈。multi-round 执行只会放大不可靠的 Evaluator 的错误。

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `skills/pge-execute/contracts/evaluation-contract.md` | 增加评分维度定义、硬阈值规则、AI slop 检测规则 | TODO |
| `agents/pge-evaluator.md` | 增加校准 fixtures（2-3 个 few-shot examples）、置信度标注要求 | TODO |
| `skills/pge-execute/handoffs/evaluator.md` | 增加结构化评分输出格式 | TODO |

**验收标准**:

- [ ] evaluation-contract.md 包含至少 2 个评分维度，每个有 1-10 分范围和硬阈值
- [ ] pge-evaluator.md 包含至少 2 个 few-shot examples（1 PASS + 1 RETRY/BLOCK）
- [ ] Evaluator 输出包含 `dimension_scores`、`confidence_score`、`evidence_type`
- [ ] evaluation-contract.md 包含至少 3 条 AI slop 检测规则
- [ ] `bin/pge-validate-contracts.sh` 通过
- [ ] proving run 中 Evaluator 产出维度评分 + 置信度（非纯叙述）

**设计参考**: `docs/design/pge-evaluator-threshold-design.md`

---

## Phase 2: Multi-round 路由 — TODO

**目标**: retry/continue/return_to_planner 三条路由自动重新调度，不再停在 `unsupported_route`。

**为什么重要**: 从"单轮执行"到"可迭代执行"的核心跳跃。

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `skills/pge-execute/contracts/routing-contract.md` | 定义三条路由的重新调度语义、max_rounds、stop condition | TODO |
| `skills/pge-execute/ORCHESTRATION.md` | 增加 multi-round 生命周期（round loop + termination） | TODO |
| `skills/pge-execute/runtime/artifacts-and-state.md` | 增加 round_number、progress_artifact 格式 | TODO |
| `skills/pge-execute/handoffs/route-summary-teardown.md` | 增加 retry/continue/return_to_planner 调度文本 | TODO |
| `skills/pge-execute/handoffs/retry.md` | 新增：retry 路由的具体调度（带 Evaluator 反馈） | TODO |

**验收标准**:

- [ ] routing-contract.md 定义三条路由的重新调度语义
- [ ] ORCHESTRATION.md 包含 round loop 入口、round_number 递增、termination 条件
- [ ] artifacts-and-state.md 包含 `round_number`、`max_rounds`、`progress_artifact`
- [ ] routing-contract.md 定义 `max_rounds` 默认值和 stop condition
- [ ] proving run: Evaluator verdict=RETRY 时自动开始 retry round
- [ ] proving run: 达到 max_rounds 时停止并产出 summary

**设计参考**: `docs/design/pge-multiround-runtime-design.md`

---

## Phase 3: Preflight 协商增强 — TODO

**目标**: Preflight 协商结构化、能收敛或明确失败。

**依赖**: Phase 1（结构化评分格式是 preflight feedback 的基础）

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `skills/pge-execute/contracts/evaluation-contract.md` | preflight 增加 structured feedback 格式 | TODO |
| `skills/pge-execute/handoffs/preflight.md` | 增加收敛检测逻辑、max_preflight_attempts=3 | TODO |
| `skills/pge-execute/runtime/artifacts-and-state.md` | max_preflight_attempts 从 2 改为 3 | TODO |

**验收标准**:

- [ ] preflight BLOCK 包含 `specific_issue`、`suggested_fix`、`acceptance_condition`
- [ ] 收敛检测：第 N 次未解决第 N-1 次问题时升级 return_to_planner
- [ ] max_preflight_attempts = 3
- [ ] proving run: preflight BLOCK 产出结构化反馈
- [ ] proving run: 3 次未收敛时升级为 return_to_planner

**设计参考**: `docs/design/pge-contract-negotiation-design.md`

---

## Phase 4: Planner intake negotiation — TODO

**目标**: Planner 能处理模糊 raw prompt，通过结构化澄清产出高质量 round contract。

**依赖**: 建议 Phase 1-2 后（先确保下游可靠）

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `agents/pge-planner.md` | 增加 intake negotiation 协议 | TODO |
| `skills/pge-execute/contracts/entry-contract.md` | 定义触发条件和 clarification artifact 格式 | TODO |
| `skills/pge-execute/handoffs/planner.md` | 增加 intake negotiation 调度文本 | TODO |
| `skills/pge-execute/ORCHESTRATION.md` | planner 阶段前增加可选 intake negotiation 步骤 | TODO |

**验收标准**:

- [ ] pge-planner.md 包含 intake negotiation 协议
- [ ] entry-contract.md 定义触发条件（不是所有输入都触发）
- [ ] 明确 prompt（"add a README.md"）→ 直接产出 round contract
- [ ] 模糊 prompt（"improve the project"）→ 产出 clarification artifact

**设计参考**: `docs/design/pge-contract-negotiation-design.md`, `docs/design/pge-rebuild-plan.md` §Gate 1

---

## Phase 5: Checkpoint 和恢复 — TODO

**目标**: 实现 checkpoint 写入和 session 恢复，中断不必从头开始。

**依赖**: Phase 2（multi-round 是恢复的前提）

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `skills/pge-execute/ORCHESTRATION.md` | 增加 checkpoint 协议 | TODO |
| `skills/pge-execute/runtime/persistent-runner.md` | 恢复协议从设计转为可执行指令 | TODO |
| `skills/pge-execute/handoffs/resume.md` | 新增：从 checkpoint 恢复的调度文本 | TODO |
| `skills/pge-execute/runtime/artifacts-and-state.md` | 增加 checkpoint 格式和 context budget 规则 | TODO |

**验收标准**:

- [ ] ORCHESTRATION.md 定义 checkpoint 协议
- [ ] artifacts-and-state.md 定义 checkpoint 格式
- [ ] resume.md 存在，定义恢复调度文本
- [ ] artifacts-and-state.md 包含 context budget 规则

**设计参考**: `docs/design/pge-multiround-runtime-design.md` §7

---

## 设计文档索引

| 文档 | 用途 |
|------|------|
| `docs/design/pge-rebuild-plan.md` | 总体改建方案：状态分析 + 差距 + 路线 |
| `docs/design/pge-multiround-runtime-design.md` | 多轮运行时：状态机 + schema + checkpoint |
| `docs/design/pge-contract-negotiation-design.md` | 合约协商：preflight + negotiation + hard gate |
| `docs/design/pge-evaluator-threshold-design.md` | Evaluator：评分维度 + 阈值 + fixtures + verdict |
| `docs/design/pge-reference-learning-notes.md` | 参考项目：学什么 / 不学什么 / 映射到哪 |
| `docs/design/pge-rebuild-review-report.md` | Review 报告：4 轮 findings + 修订记录 |
| `docs/design/pge-codex-review.md` | Codex 独立 review |
| `docs/design/pge-final-codex-review.md` | 最终 Codex review（CONDITIONAL PASS） |
| `docs/design/research/` | 调研原始资料（8 份） |

---

## 5 Critical Gates 差距表

| Gate | 当前状态 | 改建 Phase | 改建后预期 |
|------|---------|-----------|-----------|
| 1. Planner raw-prompt ownership | Planner 是 round shaper，无结构化澄清 | Phase 4 | 模糊 prompt → intake negotiation → clarification → contract |
| 2. Preflight multi-turn negotiation | 存在但 max 2 attempts，无结构化反馈 | Phase 3 | structured feedback + 收敛检测 + max 3 attempts |
| 3. Generator sprint/feature granularity | 单轮执行，retry/continue 停在 unsupported_route | Phase 2 | multi-round loop + 自动路由调度 |
| 4. Evaluator hard-threshold grading | 叙述性判断，gate 只检查 section 存在 | Phase 1 | 量化评分 + 硬阈值 + AI slop 检测 + fixtures |
| 5. Runtime long-running execution | 无 checkpoint/resume，无 context budget | Phase 2 + 5 | round loop (P2) + checkpoint/resume (P5) |

---

## 变更日志

| 日期 | 变更 |
|------|------|
| 2026-04-29 | 初始版本。Phase 0 已完成。Phase 1-5 待实施。 |
