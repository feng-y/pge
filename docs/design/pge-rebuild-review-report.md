# PGE 改建方案 Review Report

## Review 概况

- Round 1: Repo-grounded review — 3 P0 + 6 P1 + 3 P2 findings
- Round 2: Critical Gates review — 5 gates 评估
- Round 3: Codex independent review — 4 P0 + 8 P1 + 7 P2 findings
- Round 4: Post-review revision — 本轮（实际修订文档）

---

## Round 1 Findings 处理

| # | Finding | Severity | Status | Action |
|---|---------|----------|--------|--------|
| P0-1 | 历史 artifact 命名与方案/合约定义不一致 | P0 | **accepted** | `pge-rebuild-plan.md` §1 Confirmed 表已修改，明确标注历史 run 使用 pre-ORCHESTRATION 命名约定（`-planner-output.md` 等），不是当前 ORCHESTRATION.md 定义的完整 9-artifact 格式 |
| P0-2 | multiround-runtime-design 将未实现状态描述为"从当前 repo 提升" | P0 | **accepted** | `pge-multiround-runtime-design.md` §8.4 表头改为"当前可执行状态 (ORCHESTRATION.md)"，新增状态标注为"将规范性定义转为可执行实现"，附录 B 决策记录同步更新 |
| P0-3 | `pge-rebuild-plan.md` 中 `contracts/` 路径引用不一致 | P0 | **accepted** | 全局替换 `contracts/` → `skills/pge-execute/contracts/`，同时修复 `handoffs/` → `skills/pge-execute/handoffs/` 和 `runtime/` → `skills/pge-execute/runtime/` |
| P1-1 | "3 个完整 run" 不够准确 | P1 | **accepted** | 已合并到 P0-1 修复中，Confirmed 表明确标注为"3 个早期 run" |
| P1-2 | contract-negotiation 和 multiround-runtime 对 runtime state 的扩展互相独立 | P1 | **accepted** | contract-negotiation 的 6 个字段已合并到 `pge-multiround-runtime-design.md` §2.1 统一 schema 中。`pge-contract-negotiation-design.md` §10.3 标注 canonical schema 在 multiround design 中 |
| P1-3 | `planning_round` 状态与 `planning` 不一致 | P1 | **accepted** | 统一使用 `planning_round`（对齐 `runtime-state-contract.md`）。`pge-multiround-runtime-design.md` §8.1 添加状态名对齐说明，§8.2 状态转换表全部更新。`pge-contract-negotiation-design.md` §10.4 添加对齐说明 |
| P1-4 | evaluator verdict bundle schema 与当前输出格式差距大 | P1 | **accepted** | 已合并到 Codex P1-2 修复中 |
| P1-5 | sprint 概念与"不学 Sprint"结论矛盾 | P1 | **accepted** | 已合并到 Codex P0-1 修复中（sprint→slice 重命名） |
| P1-6 | Phase 依赖链与实际可行性 | P1 | **accepted** | 已合并到 Codex P1-3 修复中 |
| P2-1 | README.md 中路径错误 | P2 | **rejected** | 这是 repo 本身的问题，不是方案文档的问题。不在本轮修订范围内 |
| P2-2 | learning-notes 中目标路径不精确 | P2 | **accepted** | 检查确认 learning-notes 中的路径已使用完整 `skills/pge-execute/` 前缀 |
| P2-3 | anti-slop 检测规则可能过于严格 | P2 | **accepted** | 已合并到 Codex P1-7 修复中 |

<!-- PLACEHOLDER_ROUND2 -->

## Round 2 Critical Gates 评估

| Gate | 评估结果 | 最终状态 |
|------|---------|---------|
| Gate 1: Planner raw-prompt ownership | 缺口已识别（无 intake negotiation、无 scope 前置检测）。改建动作方向正确，已在 Phase 4 中规划。 | 设计充分，待实施 |
| Gate 2: Preflight multi-turn negotiation | 缺口已识别（修复循环太短、无收敛检测）。`pge-contract-negotiation-design.md` 提供了完整的多轮 negotiation 设计。 | 设计充分，待实施 |
| Gate 3: Generator slice/feature granularity | 最大功能缺口（无 multi-round 执行）。`pge-multiround-runtime-design.md` 提供了完整的 run/slice/round 三层设计。术语已从 sprint 统一为 slice。 | 设计充分，待实施 |
| Gate 4: Evaluator hard-threshold grading | 设计最完整的 Gate。`pge-evaluator-threshold-design.md` 提供了 6 维度评分、blocking flags、fixtures、anti-slop 检测。已修正为"格式重构"而非"扩展"。 | 设计充分，待实施 |
| Gate 5: Runtime long-running execution and recovery | 设计充分但实现依赖 Phase 2。Context budget 机制已标注为需要平台支持，增加了启发式替代方案。 | 设计充分，待实施（依赖 Phase 2） |

## Round 3 Codex Findings 处理

| # | Finding | Severity | Status | Action |
|---|---------|----------|--------|--------|
| P0-1 | Sprint 层与"不学 Sprint"结论矛盾 | P0 | **accepted** | 全局重命名 sprint→slice。`pge-multiround-runtime-design.md` §1 添加术语说明，解释 slice 与 Anthropic sprint 的区别。`pge-reference-learning-notes.md` §1 "不学什么"扩展说明 PGE slice 的独立语义。`pge-contract-negotiation-design.md` §2 标题从"Sprint Contract Proposal"改为"Round Contract Proposal" |
| P0-2 | Artifact 命名不一致 | P0 | **accepted** | 与 R1 P0-1 合并处理。`pge-rebuild-plan.md` §1 Confirmed 表已修改 |
| P0-3 | 两份文档 runtime-state schema 独立扩展 | P0 | **accepted** | contract-negotiation 的 6 个字段合并到 `pge-multiround-runtime-design.md` §2.1 统一 schema。`pge-contract-negotiation-design.md` §10.3 标注 canonical schema 位置 |
| P0-4 | `planning_round` 与 `planning` 状态名不一致 | P0 | **accepted** | 统一使用 `planning_round`。`pge-multiround-runtime-design.md` §8.1-8.4 全部更新。`pge-contract-negotiation-design.md` §10.4 添加对齐说明 |
| P1-1 | "从当前 repo 提升"低估实现难度 | P1 | **accepted** | `pge-multiround-runtime-design.md` §8.4 重写为"将规范性定义转为可执行实现"，附录 B 决策记录同步更新 |
| P1-2 | Evaluator threshold 是格式重写非扩展 | P1 | **accepted** | `pge-evaluator-threshold-design.md` §10.1 重写为"重大重构"，增加过渡策略列和 Phase 1 中间输出格式定义 |
| P1-3 | Phase 依赖链可能不必要 | P1 | **accepted** | `pge-rebuild-plan.md` Phase 2 依赖从"Phase 1"改为"无硬依赖"，说明当前 Evaluator 已有 required_fixes 足以支撑基本 retry |
| P1-4 | contract-negotiation 缺少实施路径 | P1 | **accepted** | `pge-contract-negotiation-design.md` 新增 §12 实施路径，列出需变更的文件、无需新增文件、分阶段实施计划 |
| P1-5 | Context budget 机制假设不可用 API | P1 | **accepted** | `pge-multiround-runtime-design.md` §9.2 添加实现约束说明，列出 3 种启发式替代方案，标注精确检测需要平台支持 |
| P1-6 | rebuild-plan 使用缩短 contract 路径 | P1 | **accepted** | 与 R1 P0-3 合并处理。全局替换完成 |
| P1-7 | Anti-slop issue_minimization 规则过于严格 | P1 | **accepted** | `pge-evaluator-threshold-design.md` §9.2 机制 5 修改：issue_minimization 仅在 severity ≥ major 时触发。添加例外说明，与 evaluation-contract.md 的 "narrowest verdict" 原则对齐 |
| P1-8 | 无设计文档自身的验收检查 | P1 | **accepted** | `pge-rebuild-plan.md` §6 新增 Phase 0: 设计文档对齐，定义 5 项验收标准，标注已在 Round 4 完成 |
| P2-1 | learning-notes 路径使用简写 | P2 | **accepted** | 检查确认已使用完整路径 |
| P2-2 | Checkpoint JSON schemas 过于复杂 | P2 | **rejected** | 当前 schema 设计合理。复杂度来自恢复所需的最小信息集。可在实施时根据实际经验简化 |
| P2-3 | Fixture W4 BF_NO_EVIDENCE 命名不准确 | P2 | **accepted** | 重命名为 `BF_NO_INDEPENDENT_EVIDENCE`，描述更新为"无高独立性证据" |
| P2-4 | §9.4 scope control 是 prompt-compliance 依赖 | P2 | **rejected** | 正确识别了限制，但这是 prompt-driven harness 的固有特征。当前阶段无结构化替代方案 |
| P2-5 | 无设计文档版本策略 | P2 | **partially accepted** | `pge-multiround-runtime-design.md` 版本从 0.1.0 更新为 0.2.0。完整的版本策略留待实施阶段定义 |
| P2-6 | N2 非目标可能过于限制 | P2 | **rejected** | 当前阶段保持三角色约束合理。如果 evaluator prompt 超出 instruction budget，可在实施时重新评估 |
| P2-7 | Recovery 设计假设 artifact 足以重建上下文 | P2 | **partially accepted** | 这是正确的风险识别。已在 multiround design §9.2 中标注 context budget 的实现约束。专门的 recovery proving run 测试留待 Phase 5 实施 |

## 修订摘要

| 文件 | 修改内容 |
|------|---------|
| `pge-multiround-runtime-design.md` | sprint→slice 全局重命名；§1 添加术语说明；§2.1 合并 contract-negotiation 字段为统一 schema；§2.2 active_phase 使用 planning_round；§8.1 添加状态名对齐说明；§8.1-8.2 planning→planning_round；§8.4 重写为"将规范性定义转为可执行实现"；§9.2 添加 context budget 实现约束；附录 B 更新决策记录；版本 0.1.0→0.2.0 |
| `pge-contract-negotiation-design.md` | §2 标题 Sprint→Round；§10.3 标注 canonical schema 在 multiround design；§10.4 添加状态名对齐说明；新增 §12 实施路径；D2 和引用表中 Sprint→Contract |
| `pge-rebuild-plan.md` | §1 Confirmed 表修正历史 run 描述；§6 新增 Phase 0 设计文档对齐；Phase 2 依赖改为无硬依赖；全局修复 contracts/handoffs/runtime 路径前缀 |
| `pge-evaluator-threshold-design.md` | §10.1 重写为"重大重构"并添加过渡策略；Phase 1 添加中间输出格式；§9.2 issue_minimization 限定 severity ≥ major；BF_NO_EVIDENCE→BF_NO_INDEPENDENT_EVIDENCE |
| `pge-reference-learning-notes.md` | §1 "不学什么"扩展 slice 与 sprint 的区别说明；Sprint Contract→Contract 术语统一 |

## 仍然未解决的问题

1. **ORCHESTRATION.md 使用 `planning` 而非 `planning_round`** — 设计文档已统一为 `planning_round`，但实际可执行文件 `ORCHESTRATION.md` 仍使用 `planning`。需在实施时更新。
2. **Context budget 精确检测** — 需要 Claude Code 平台支持。当前设计提供了启发式替代方案，但精确检测仍是开放问题。
3. **Recovery round-trip 测试** — 从 artifact 重建 team 并继续执行的可行性尚未验证。需在 Phase 5 中设计专门的 proving run 测试。
4. **Evaluator instruction budget** — 完整的 6 维度评分 + 7 blocking flags + anti-slop 检测可能超出 ~150-200 条指令限制。需在 Phase 1 实施时评估。
5. **max_negotiation_rounds = 3 的经验依据** — 参数选择基于推测，无实际运行数据支撑。需在实施后根据实际运行调优。

## 后续代码改造建议

推荐实施顺序：

1. **Phase 0 (已完成)**: 设计文档对齐 — 本轮已完成
2. **Phase 1 + Phase 2 (并行)**: Evaluator 硬阈值 + Multi-round 路由 — 无硬依赖，可并行推进。Phase 1 从中间输出格式开始（保留现有 5 section + 追加 scores table）。Phase 2 从 retry 路由开始（最小可行的 multi-round）
3. **Phase 3**: Preflight 协商增强 — 依赖 Phase 1 的 structured feedback 格式
4. **Phase 4**: Planner intake negotiation — 独立，但建议在 Phase 1-2 之后
5. **Phase 5**: Checkpoint 和恢复 — 依赖 Phase 2 的 multi-round 实现

每个 Phase 的前置条件：
- Phase 1: 无。可立即开始
- Phase 2: 无硬依赖。当前 Evaluator 的 required_fixes + next_route 足以支撑基本 retry
- Phase 3: Phase 1 的 structured feedback 格式
- Phase 4: 无硬依赖
- Phase 5: Phase 2 的 multi-round 路由实现

