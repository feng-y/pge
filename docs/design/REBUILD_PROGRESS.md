# PGE 改建进度追踪

Updated: 2026-04-30

---

## 总览

| Phase | 名称 | 状态 | 依赖 | 优先级 |
|-------|------|------|------|--------|
| 0 | 设计文档对齐 | DONE | 无 | - |
| 0.5A | Adaptive Execution | IN_PROGRESS | Phase 0 | P0 |
| 0.5B | Agent Teams Communication | IN_PROGRESS | Phase 0 | P0 |
| 0.5C | Planner Stabilization | IN_PROGRESS | Phase 0.5A/B | P0 |
| 1 | Evaluator 验收面 | IN_PROGRESS | Phase 0.5A | P0 |
| 2 | Multi-round 路由 | IN_PROGRESS | 无（可与 P1 并行） | P0 |
| 3 | Preflight 协商增强 | TODO | Phase 1 | P1 |
| 4 | Planner intake negotiation | IN_PROGRESS | 建议 Phase 1-2 后 | P1 |
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
- [x] runtime handoffs 与 artifact budget 已落地为 FAST_PATH 最小 artifact 面
- [ ] proving run 验证 smoke test 管理 artifact 数量 ≤ 3

---

## Phase 0.5B: Agent Teams Communication — IN_PROGRESS

**目标**: 常规协商默认走 Agent Teams messaging；文件只承担 durable 输出和状态职责。

**当前对齐结论**:

- [x] negotiation/challenge/clarification/feedback/status 默认走 `SendMessage`
- [x] 文件不再被定义为 turn-by-turn 消息总线
- [x] durable artifact 边界已重新定义为“阶段结果”和“恢复状态”
- [x] preflight 已退出当前 executable lane；evaluation 继续保留 durable verdict
- [x] `main` 的推进依据已收敛为 runtime events；artifact gate 退为事件引用的 durable side effect 校验
- [ ] proving run 验证当前 smoke lane 不再落 proposal/preflight artifact

---

## Phase 0.5C: Planner Stabilization — IN_PROGRESS

**目标**: 先把 Planner 的 evidence steward / scope challenger / contract author / risk registrar / contract self-checker 职责落成可执行行为，否则后续 Generator / Evaluator 会继续填补 Planner 未冻结的语义空白。

**当前对齐结论**:

- [x] Planner 不是 Anthropic product-spec Planner 的直接复制；PGE Planner 是 evidence-backed bounded-round planner
- [x] Planner 内部明确为 research pass → thin counter-research / brainstorming pass → architecture pass → contract freeze
- [x] `evidence_basis` 要求 source / fact / confidence / verification_path
- [x] Planner 明确拥有 current-round task split + DoD，不拥有 full-project backlog scheduling
- [x] 保持 Planner 外部 section 接口不变；context loading、rejected cuts、failure modes、contract self-check 先写入现有 section
- [x] code/runtime contract 与 prose doc 冲突时，code/runtime contract 是 truth
- [x] 可选方案对比保持薄：推荐 cut + 最多两个 rejected cuts + tradeoff
- [x] 需要用户澄清时，只在 `planner_escalation` 放一个 focused question
- [ ] proving run 验证 Planner 产出是否真正减少 Generator / Evaluator 猜测

**下一步**: Planner proving 后再进入 Generator 职责收敛。

**延后 TODO**: 新增 Planner top-level section 需要与 Generator、Evaluator、orchestration gate、validator 联合调整，不能单独在 Planner 里先加。

---

## Phase 1: Evaluator 验收面 — IN_PROGRESS

**目标**: Evaluator 从松散叙述性判断升级为紧凑、稳定、可路由的验收面。

**为什么优先**: Evaluator 质量是整个 harness 的瓶颈。multi-round 执行只会放大不可靠的 Evaluator 的错误。

**职责边界**:

- 应承担：独立验收、路由裁决、成本门控
- 不应承担：长篇审计写作、默认大评分矩阵、替 Planner/Generator 做工作

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `skills/pge-execute/contracts/evaluation-contract.md` | 定义 compact acceptance surface、mode-aware 评估深度、AI slop 检测规则 | DONE |
| `agents/pge-evaluator.md` | 明确职责边界和 mode-aware 输出要求 | DONE |
| `skills/pge-execute/handoffs/evaluator.md` | 定义 lightweight / compact / deeper-audit 输出格式 | IN_PROGRESS |

**验收标准**:

- [x] evaluation-contract.md 明确定义三类职责：独立验收、路由裁决、成本门控
- [x] pge-evaluator.md 明确限制默认输出重度审计内容
- [x] evaluator handoff 支持 `FAST_PATH` 的 lightweight verdict
- [ ] evaluator handoff 支持 `LITE_PGE` / `FULL_PGE` 的 compact acceptance surface
- [x] evaluation-contract.md 包含至少 3 条 AI slop 检测规则
- [x] `bin/pge-validate-contracts.sh` 通过
- [ ] proving run 中 Evaluator 产出足以驱动路由的紧凑 verdict（不是冗长评审稿）

**当前差距**: compact acceptance surface 已在 contract 层定义，但 `LITE_PGE` / `FULL_PGE` 的 mode-specific 输出还没在 handoff / gate / proving 上完全贯通。

**设计参考**: `docs/design/pge-evaluator-threshold-design.md`, `docs/design/pge-adaptive-execution-design.md`

---

## Phase 2: Multi-round 路由 — IN_PROGRESS

**目标**: retry/continue/return_to_planner 三条路由自动重新调度，不再停在 `unsupported_route`。

**为什么重要**: 从"单轮执行"到"可迭代执行"的核心跳跃。

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `skills/pge-execute/contracts/routing-contract.md` | 定义三条路由的 canonical 语义、verdict-to-route mapping、stop condition 决策 | IN_PROGRESS |
| `skills/pge-execute/ORCHESTRATION.md` | 当前明确 single-run lifecycle 和 unsupported_route 停机语义；尚无 multi-round loop | IN_PROGRESS |
| `skills/pge-execute/runtime/artifacts-and-state.md` | `progress_artifact` 已冻结；`round_number` / `max_rounds` 尚未进入 executable lane | IN_PROGRESS |
| `skills/pge-execute/handoffs/route-summary-teardown.md` | 已定义 route_selected / unsupported_route closeout；尚无 redispatch 文本 | IN_PROGRESS |
| `skills/pge-execute/handoffs/retry.md` | 新增：retry 路由的具体调度（带 Evaluator 反馈） | TODO |

**验收标准**:

- [x] routing-contract.md 定义三条路由的 canonical 语义（当前仍停在 `unsupported_route`）
- [ ] ORCHESTRATION.md 包含 round loop 入口、round_number 递增、termination 条件
- [ ] artifacts-and-state.md 包含 `round_number`、`max_rounds`、`progress_artifact`
- [ ] routing-contract.md 定义 `max_rounds` 默认值和 stop condition
- [ ] proving run: Evaluator verdict=RETRY 时自动开始 retry round
- [ ] proving run: 达到 max_rounds 时停止并产出 summary

**当前差距**: route 语义和 `continue` vs `converged` 判定已经冻结，但 runtime 仍诚实地在 `unsupported_route` 停机，没有自动 redispatch。

**设计参考**: `docs/design/pge-multiround-runtime-design.md`

---

## Phase 3: Preflight 协商增强 — TODO

**目标**: Preflight 协商结构化、能收敛或明确失败。

**依赖**: Phase 1（紧凑、可路由的 verdict surface 是 preflight feedback 结构化的基础）

**当前 repo 状态**: `skills/pge-execute/handoffs/preflight.md` 已明确标注“不在 current executable lane”，当前 runtime 先收敛到 `planner -> generator -> evaluator` 单骨架。这个 phase 现阶段不是增量打磨，而是 future re-entry 设计。

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `skills/pge-execute/contracts/evaluation-contract.md` | 若 preflight 回归 executable lane，再补 structured feedback 格式 | TODO |
| `skills/pge-execute/handoffs/preflight.md` | 当前为 archived seam；重启时补收敛检测逻辑、max_preflight_attempts=3 | ARCHIVED |
| `skills/pge-execute/runtime/artifacts-and-state.md` | 当前 executable lane 不含 max_preflight_attempts；重启 preflight 时再引入 | N/A |

**验收标准**:

- [ ] preflight BLOCK 包含 `specific_issue`、`suggested_fix`、`acceptance_condition`
- [ ] 收敛检测：第 N 次未解决第 N-1 次问题时升级 return_to_planner
- [ ] max_preflight_attempts = 3
- [ ] proving run: preflight BLOCK 产出结构化反馈
- [ ] proving run: 3 次未收敛时升级为 return_to_planner

**设计参考**: `docs/design/pge-contract-negotiation-design.md`

---

## Phase 4: Planner intake negotiation — IN_PROGRESS

**目标**: Planner 能处理模糊 raw prompt，通过结构化澄清产出高质量 round contract。

**依赖**: 建议 Phase 1-2 后（先确保下游可靠）

**改动文件**:

| 文件 | 改动 | 状态 |
|------|------|------|
| `agents/pge-planner.md` | 已加入 Questions gate、raw prompt shaping、focused clarification seam | IN_PROGRESS |
| `skills/pge-execute/contracts/entry-contract.md` | 当前明确“不做 entry-time field contract”；触发条件和 clarification artifact 仍未冻结 | IN_PROGRESS |
| `skills/pge-execute/handoffs/planner.md` | 已加入 raw prompt shaping 和 `planner_escalation` focused question 约束 | IN_PROGRESS |
| `skills/pge-execute/ORCHESTRATION.md` | planner 阶段前增加可选 intake negotiation 步骤 | TODO |

**验收标准**:

- [x] pge-planner.md 包含 intake-like Questions gate / raw prompt shaping / focused clarification seam
- [ ] entry-contract.md 定义触发条件（不是所有输入都触发）
- [ ] 明确 prompt（"add a README.md"）→ 直接产出 round contract
- [ ] 模糊 prompt（"improve the project"）→ 产出 clarification artifact

**当前差距**: Planner 已经能“吃 raw prompt 并在 artifact 内升级为 focused question”，但 `entry-contract` 还没有冻结 intake trigger，也还没有独立 clarification artifact。

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
| 1. Planner raw-prompt ownership | Planner 已能 shape raw prompt，并通过 `planner_escalation` 提一个 focused question；但 intake trigger / clarification artifact 未冻结 | Phase 4 | 模糊 prompt → intake negotiation → clarification → contract |
| 2. Preflight multi-turn negotiation | 当前已退出 executable lane，保留为 archived seam | Phase 3 | structured feedback + 收敛检测 + max 3 attempts |
| 3. Generator sprint/feature granularity | 单轮执行，retry/continue 停在 unsupported_route | Phase 2 | multi-round loop + 自动路由调度 |
| 4. Evaluator acceptance surface | compact verdict bundle、AI slop、static gate 已落地；`LITE_PGE` / `FULL_PGE` 贯通和 runtime proving 未完成 | Phase 1 | 紧凑验收面 + mode-aware 输出 + AI slop 检测 + 示例 |
| 5. Runtime long-running execution | 无 checkpoint/resume，无 context budget | Phase 2 + 5 | round loop (P2) + checkpoint/resume (P5) |

---

## 变更日志

| 日期 | 变更 |
|------|------|
| 2026-04-29 | 初始版本。Phase 0 已完成。Phase 1-5 待实施。 |
| 2026-04-30 | 根据当前 repo 实际状态回填：Phase 1 / 2 / 4 改为 IN_PROGRESS；标注 preflight 已退出当前 executable lane；记录 `bin/pge-validate-contracts.sh` 已通过。 |
