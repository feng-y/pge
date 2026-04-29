# PGE 改建进度追踪

Updated: 2026-04-29

---

## 总览

| Phase | 名称 | 状态 | 依赖 | 优先级 |
|-------|------|------|------|--------|
| 0 | 设计文档对齐 | DONE | 无 | - |
| 0.5A | Adaptive Execution | IN_PROGRESS | Phase 0 | P0 |
| 0.5B | Agent Teams Communication | IN_PROGRESS | Phase 0 | P0 |
| 1 | Evaluator 验收面 | TODO | Phase 0.5A | P0 |
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

## Phase 0.5A: Adaptive Execution — IN_PROGRESS

**目标**: 用 team-backed quick triage 解决简单任务流程过重的问题，同时保留 Evaluator 的最终确认权。

**当前对齐结论**:

- [x] Planner 不拥有 fast-finish 决策权
- [x] Generator 负责提出执行/验证方式
- [x] Evaluator 拥有 Execution Cost Gate
- [x] FAST_PATH 保留 Evaluator verdict
- [ ] runtime handoffs 与 artifact budget 仍需继续落地

---

## Phase 0.5B: Agent Teams Communication — IN_PROGRESS

**目标**: 常规协商默认走 Agent Teams messaging；文件只承担 durable 输出和状态职责。

**当前对齐结论**:

- [x] negotiation/challenge/clarification/feedback/status 默认走 `SendMessage`
- [x] 文件不再被定义为 turn-by-turn 消息总线
- [x] durable artifact 边界已重新定义为“阶段结果”和“恢复状态”
- [ ] preflight/evaluation handoff 的具体执行细节仍需继续落地

---

## Phase 1: Evaluator 验收面 — TODO

**目标**: Evaluator 从松散叙述性判断升级为紧凑、稳定、可路由的验收面。

**为什么优先**: Evaluator 质量是整个 harness 的瓶颈。multi-round 执行只会放大不可靠的 Evaluator 的错误。

**职责边界**:

- 应承担：独立验收、路由裁决、成本门控
- 不应承担：长篇审计写作、默认大评分矩阵、替 Planner/Generator 做工作

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `skills/pge-execute/contracts/evaluation-contract.md` | 定义 compact acceptance surface、mode-aware 评估深度、AI slop 检测规则 | IN_PROGRESS |
| `agents/pge-evaluator.md` | 明确职责边界和 mode-aware 输出要求 | IN_PROGRESS |
| `skills/pge-execute/handoffs/evaluator.md` | 定义 lightweight / compact / deeper-audit 输出格式 | IN_PROGRESS |

**验收标准**:

- [ ] evaluation-contract.md 明确定义三类职责：独立验收、路由裁决、成本门控
- [ ] pge-evaluator.md 明确限制默认输出重度审计内容
- [ ] evaluator handoff 支持 `FAST_PATH` 的 lightweight verdict
- [ ] evaluator handoff 支持 `LITE_PGE` / `FULL_PGE` 的 compact acceptance surface
- [ ] evaluation-contract.md 包含至少 3 条 AI slop 检测规则
- [ ] `bin/pge-validate-contracts.sh` 通过
- [ ] proving run 中 Evaluator 产出足以驱动路由的紧凑 verdict（不是冗长评审稿）

**设计参考**: `docs/design/pge-evaluator-threshold-design.md`, `docs/design/pge-adaptive-execution-design.md`

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

**依赖**: Phase 1（紧凑、可路由的 verdict surface 是 preflight feedback 结构化的基础）

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
| `docs/design/pge-evaluator-threshold-design.md` | Evaluator：紧凑验收面、mode-aware 输出、AI slop 规则、示例 |
| `docs/design/pge-reference-learning-notes.md` | 参考项目：学什么 / 不学什么 / 映射到哪 |
| `docs/design/research/` | 调研原始资料（8 份） |

---

## 5 Critical Gates 差距表

| Gate | 当前状态 | 改建 Phase | 改建后预期 |
|------|---------|-----------|-----------|
| 1. Planner raw-prompt ownership | Planner 是 round shaper，无结构化澄清 | Phase 4 | 模糊 prompt → intake negotiation → clarification → contract |
| 2. Preflight multi-turn negotiation | 存在但 max 2 attempts，无结构化反馈 | Phase 3 | structured feedback + 收敛检测 + max 3 attempts |
| 3. Generator sprint/feature granularity | 单轮执行，retry/continue 停在 unsupported_route | Phase 2 | multi-round loop + 自动路由调度 |
| 4. Evaluator acceptance surface | 叙述性判断，gate 只检查 section 存在 | Phase 1 | 紧凑验收面 + mode-aware 输出 + AI slop 检测 + 示例 |
| 5. Runtime long-running execution | 无 checkpoint/resume，无 context budget | Phase 2 + 5 | round loop (P2) + checkpoint/resume (P5) |

---

## 变更日志

| 日期 | 变更 |
|------|------|
| 2026-04-29 | 初始版本。Phase 0 已完成。Phase 1-5 待实施。 |
