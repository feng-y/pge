# Round 1: Repo-grounded Review

## Findings

### P0 Issues

**P0-1: 历史 artifact 命名与方案/合约定义不一致**

- 文档: `pge-rebuild-plan.md` §1 "Confirmed" 表, `pge-multiround-runtime-design.md` 附录 A, `pge-contract-negotiation-design.md` §9.3
- Section: 所有引用 artifact 路径的地方
- 问题: 方案中声称 artifact 路径为 `<run_id>-planner.md`, `<run_id>-generator.md`, `<run_id>-evaluator.md`, `<run_id>-summary.md`（与 `ORCHESTRATION.md` 和 `artifacts-and-state.md` 一致）。但 `.pge-artifacts/` 中实际存在的文件使用不同命名: `-planner-output.md`, `-generator-output.md`, `-evaluator-verdict.md`, `-round-summary.md`。同时缺少 `-input.md`, `-contract-proposal.md`, `-preflight.md`, `-state.json`, `-progress.md`。
- 影响: 方案中的 "Confirmed" 标签和 "3 个完整 run" 的说法与实际 artifact 结构不一致。实际运行产物使用的是旧命名约定，说明当前 ORCHESTRATION.md 定义的 artifact 路径规范尚未被实际运行完全采纳。方案基于规范路径做设计，但未确认实际运行是否已对齐。

**P0-2: `pge-multiround-runtime-design.md` 将未实现的状态描述为"从当前 repo 提升"**

- 文档: `pge-multiround-runtime-design.md`
- Section: §8.4 "与当前 repo 的对齐", §2.3 "与当前 repo 的变更", 附录 C
- 问题: 方案声称 "新增状态全部来自当前 `runtime-state-contract.md` 的规范性超集，不是凭空引入"。这在字面上正确——`runtime-state-contract.md` 确实定义了 `preflight_failed`, `awaiting_evaluation`, `routing` 等状态。但方案没有明确区分：这些状态在 `runtime-state-contract.md` 中是**规范性定义**（normative semantic superset），而在 `ORCHESTRATION.md` 和 `artifacts-and-state.md` 中是**不存在的**（当前可执行子集不包含它们）。方案的措辞 "从 runtime-state-contract.md 提升" 暗示这是一个小变更，实际上是将规范性定义转为可执行实现——这是本设计的核心工作，不是简单的"提升"。
- 影响: 读者可能低估实现难度。

**P0-3: `pge-rebuild-plan.md` 中 `contracts/` 路径引用不一致**

- 文档: `pge-rebuild-plan.md`
- Section: §3 Gate 1-5 的 "改建动作", §6 分阶段路线的 "产出"
- 问题: 多处引用 `contracts/evaluation-contract.md`, `contracts/routing-contract.md` 等路径，省略了 `skills/pge-execute/` 前缀。例如 §3 Gate 4: "在 `contracts/evaluation-contract.md` 中增加评分维度定义"。而 repo 中顶层 `contracts/` 目录已被移除（README.md 明确声明: "Top-level `contracts/` has been removed so runtime authority is not ambiguous"）。实际路径是 `skills/pge-execute/contracts/evaluation-contract.md`。
- 影响: 路径歧义。虽然可推断意图，但方案文档应使用准确路径，特别是 repo 明确声明了顶层 contracts/ 已移除的情况下。

### P1 Issues

**P1-1: `pge-rebuild-plan.md` §1 "Confirmed" 表中 "历史运行产物 | 3 个完整 run" 不够准确**

- 文档: `pge-rebuild-plan.md`
- Section: §1 Confirmed 表
- 问题: 声称 ".pge-artifacts/ 下 3 个完整 run"。实际每个 run 只有 4 个文件（planner-output, generator-output, evaluator-verdict, round-summary），缺少 ORCHESTRATION.md 定义的 input, contract-proposal, preflight, state.json, progress 等 artifact。这些 run 是早期版本的产物，不是当前 ORCHESTRATION.md 定义的 "完整 run"。
- 影响: 可能误导读者认为当前 ORCHESTRATION.md 定义的完整 9-artifact 流程已被验证。

**P1-2: `pge-contract-negotiation-design.md` 引入 `negotiation_round` 和 `max_negotiation_rounds` 但未与 multiround 设计对齐**

- 文档: `pge-contract-negotiation-design.md`
- Section: §10.3 "新增 Runtime State 字段"
- 问题: 引入了 `negotiation_round`, `max_negotiation_rounds`, `total_preflight_cycles`, `max_total_preflight_cycles`, `contract_locked`, `contract_locked_at_preflight` 等字段。但 `pge-multiround-runtime-design.md` §2.1 的 runtime-state schema 中没有这些字段。两份方案对 runtime state 的扩展互相独立，没有统一的 schema。
- 影响: 如果两份方案同时实施，runtime state 会有两套独立的扩展，需要合并。

**P1-3: `pge-contract-negotiation-design.md` §10.4 引入 `planning_round` 状态但当前 repo 不存在此状态**

- 文档: `pge-contract-negotiation-design.md`
- Section: §10.4 "新增状态转换"
- 问题: 引入了 `routing -> planning_round` 和 `preflight_pending -> planning_round` 转换。`planning_round` 是 `runtime-state-contract.md` 中的规范性状态，但当前可执行子集（`ORCHESTRATION.md`）使用的是 `planning`。方案没有说明 `planning_round` 和 `planning` 的关系。
- 影响: 状态命名不一致，可能导致实现时混淆。

**P1-4: `pge-evaluator-threshold-design.md` 的 verdict bundle schema 与当前 evaluator agent 输出格式有较大差距**

- 文档: `pge-evaluator-threshold-design.md`
- Section: §6.1 "完整 Verdict Bundle Schema"
- 问题: 定义了包含 `run_id`, `round_id`, `evaluator_version`, `timestamp`, 6 维度评分, `weighted_score`, 7 个 blocking flags, 结构化 evidence 列表等的完整 schema。当前 `agents/pge-evaluator.md` 的输出只有 5 个 markdown section: verdict, evidence, violated_invariants_or_risks, required_fixes, next_route。从 5 个 section 到完整 YAML schema 是一个很大的跳跃。
- 影响: 方案 §10.1 声称 "扩展而非替换"，但实际上是对 evaluator 输出格式的重大重构。需要明确过渡策略。

**P1-5: `pge-multiround-runtime-design.md` 的 sprint 概念与 repo-analysis.md 的 "Sprint 概念不存在" 结论矛盾**

- 文档: `pge-multiround-runtime-design.md`
- Section: §1 "Run / Sprint / Round 层次关系"
- 问题: `repo-analysis.md` §4 明确声明 "Sprint 概念: 不存在 (confirmed)"。`pge-reference-learning-notes.md` §1 "不学什么" 第 1 条也说 "V2 移除 Sprint 构造"。但 `pge-multiround-runtime-design.md` 引入了完整的 sprint 层。方案在附录 B 中给出了理由（"Anthropic 的 sprint contract 模式证明了 bounded slice 的价值"），但这与 reference-learning-notes 中 "不学什么" 的结论存在张力。
- 影响: 需要明确解释为什么在 "不学 sprint" 的结论下仍然引入 sprint 层。当前方案的理由在附录 B 中，但不够显著。

**P1-6: `pge-rebuild-plan.md` 的 Phase 依赖链与实际可行性**

- 文档: `pge-rebuild-plan.md`
- Section: §6 "分阶段改建路线"
- 问题: Phase 2 (Multi-round 路由) 依赖 Phase 1 (Evaluator 硬阈值)，理由是 "Evaluator 必须能产出结构化反馈，retry 才有意义"。但当前 Evaluator 已经能产出 `required_fixes` 字段（叙述性的），retry 的核心需求是路由重新调度，不一定需要量化评分。将 Phase 1 作为 Phase 2 的硬依赖可能不必要地延迟了 multi-round 的实现。
- 影响: 可能影响改建优先级决策。

### P2 Issues

**P2-1: README.md 中 "Supporting reference docs" 路径错误**

- 文档: README.md（非方案文档，但方案依赖的 repo 文件）
- Section: "Supporting reference docs"
- 问题: README 引用 `phase-contract.md`, `evaluation-gate.md`, `progress-md.md` 为 repo 根目录文件，但这些文件实际在 `docs/design/archive/` 下。
- 影响: 低。这是 repo 本身的问题，不是方案的问题。但方案应该注意到这个不一致。

**P2-2: `pge-reference-learning-notes.md` 中部分 "学到哪个模块" 的目标路径不精确**

- 文档: `pge-reference-learning-notes.md`
- Section: 各参考项目的 "学到 PGE 哪个模块里" 表
- 问题: 部分目标路径使用简写（如 `contracts/evaluation-contract.md` 而非 `skills/pge-execute/contracts/evaluation-contract.md`），与 P0-3 同类问题。
- 影响: 低。意图可推断，但不够精确。

**P2-3: `pge-evaluator-threshold-design.md` 的 anti-slop 检测规则可能过于严格**

- 文档: `pge-evaluator-threshold-design.md`
- Section: §9.2 机制 5 "Anti-Slop 检测"
- 问题: "任一 slop_flag 触发时，verdict 不可为 PASS" 可能过于严格。例如 `issue_minimization`（"evidence 中识别了问题但 verdict 为 PASS"）在某些情况下是合理的——Evaluator 可能识别了 minor issue 但判断不影响 acceptance。
- 影响: 低。可在实施时调整。


# Round 2: Critical Gates Review

## Gate 1: Planner raw-prompt ownership

- **当前状态 (confirmed)**:
  - Planner 是 "round shaper"，不是 "product planner"（`agents/pge-planner.md` line 6-7: "combine lightweight researcher and architect responsibilities"）
  - 接收 upstream spec 或 raw user prompt，产出 bounded round contract
  - 有 14 个输出字段（goal, evidence_basis, design_constraints, in_scope, out_of_scope, actual_deliverable, acceptance_criteria, verification_path, required_evidence, stop_condition, handoff_seam, open_questions, planner_note, planner_escalation）
  - 有 "single bounded round heuristic"（pass-through 或 cut）
  - `entry-contract.md` 明确声明当前阶段不强制入口字段
  - Planner 工具只有 Read, Grep, Glob（只读）

- **缺口**:
  1. **无 intake negotiation**: 当 raw prompt 模糊时，Planner 没有结构化的澄清流程。`pge-planner.md` 的 "Handle uncertainty explicitly" 只要求记录 `open_questions`，但没有主动向用户澄清的机制。
  2. **无 scope 前置检测**: Planner 的 "single bounded round heuristic" 只有 pass-through/cut 两个选项，没有在深入规划前判断任务是否需要分解的预检步骤。
  3. **open_questions 是被动记录**: Planner 记录 open_questions 但没有解决它们的流程——它们被写入 artifact 后就没有后续处理路径。

- **改建动作充分性**:
  - `pge-rebuild-plan.md` §3 Gate 1 提出了 intake negotiation 协议（歧义检测 → clarification artifact → 用户回应 → round contract），方向正确。
  - `pge-contract-negotiation-design.md` §2 详细定义了 Planner 从 raw intent 到 proposal 的 5 步流程，但这个流程仍然是 Planner 单方面的——没有用户交互环节。
  - **不足**: 两份方案都没有定义 "歧义度阈值" 的具体判断标准。什么样的 prompt 触发 intake negotiation？什么样的直接 pass-through？这个判断标准缺失。

- **需要的 artifact**:
  1. 更新 `agents/pge-planner.md`: 增加 intake negotiation 行为定义
  2. 更新 `skills/pge-execute/contracts/entry-contract.md`: 定义 intake negotiation 触发条件
  3. 更新 `skills/pge-execute/handoffs/planner.md`: 增加 intake negotiation 调度文本
  4. 新增: clarification artifact 格式定义（可以在 entry-contract.md 中定义）

- **验收方式**:
  - 给定明确 prompt（如 "create .pge-artifacts/pge-smoke.txt with content 'pge smoke'"），Planner 直接产出 round contract
  - 给定模糊 prompt（如 "improve the project"），Planner 产出 clarification artifact 而非直接产出 round contract
  - `bin/pge-validate-contracts.sh` 检测到新增的 section

## Gate 2: Preflight multi-turn negotiation

- **当前状态 (confirmed)**:
  - Preflight 机制存在且可用（`skills/pge-execute/handoffs/preflight.md`）
  - Generator 产出 contract-proposal artifact，Evaluator review
  - `max_preflight_attempts: 2`（`artifacts-and-state.md`）
  - PASS + ready_to_generate 继续；BLOCK + generator repair 进入修复循环
  - BLOCK + planner / ESCALATE 停在 unsupported_route
  - Preflight 禁止 repo 编辑（多处确认: ORCHESTRATION.md, handoffs/generator.md, agents/pge-generator.md）
  - Hard gate 已实现: orchestration gate + handoff gate + agent behavior gate + artifact gate（4 层）

- **缺口**:
  1. **修复循环只有 2 次**: `max_preflight_attempts: 2` 对复杂任务可能不够
  2. **无 Evaluator 反提案**: Evaluator 只能 PASS/BLOCK/ESCALATE，不能提出替代方案
  3. **无收敛检测**: 没有检测修复是否在进步的机制（可能原地打转）
  4. **BLOCK 后的 required_contract_fixes 是自由文本**: 没有结构化的 specific_issue / suggested_fix / acceptance_condition 格式
  5. **BLOCK(planner) 和 ESCALATE 停在 unsupported_route**: 无法自动 return_to_planner

- **改建动作充分性**:
  - `pge-rebuild-plan.md` §3 Gate 2 提出了 3 项改建: 提升 max_preflight_attempts 到 3、structured feedback 格式、收敛检测。方向正确。
  - `pge-contract-negotiation-design.md` §5 定义了完整的多轮 negotiation 状态机，包含 `max_preflight_attempts`, `max_negotiation_rounds`, `max_total_preflight_cycles` 三层限制。设计比 rebuild-plan 更完整。
  - **不足**: `pge-contract-negotiation-design.md` 引入了 `max_negotiation_rounds: 3` 和 `max_total_preflight_cycles: 6`，但这些参数的选择缺乏经验依据。方案中 D3 决策记录说 "如果三轮 replanning 仍无法达成共识，问题通常不在 contract 层面"，但这是推测，没有来自实际运行的数据支撑。

- **需要的 artifact**:
  1. 更新 `skills/pge-execute/handoffs/preflight.md`: structured feedback 格式 + 收敛检测
  2. 更新 `skills/pge-execute/runtime/artifacts-and-state.md`: max_preflight_attempts 调整
  3. 更新 `skills/pge-execute/contracts/evaluation-contract.md`: preflight 阶段的 structured feedback 定义
  4. 更新 `skills/pge-execute/ORCHESTRATION.md`: negotiation loop 生命周期（当 multi-round 实现时）

- **验收方式**:
  - Preflight BLOCK 时 Evaluator 产出包含 specific_issue / suggested_fix / acceptance_condition 的结构化反馈
  - 修复循环在 N 次内收敛或明确升级为 return_to_planner
  - 收敛检测: 如果第 N 次修复没有解决第 N-1 次的 specific_issue，自动升级

## Gate 3: Generator sprint/feature granularity

- **当前状态 (confirmed)**:
  - Generator 执行一个 bounded round contract，产出 actual deliverable + 本地验证 + self-review
  - 有完整的输出字段（12 个: current_task, boundary, actual_deliverable, deliverable_path, changed_files, local_verification, evidence, self_review, known_limits, non_done_items, deviations_from_spec, handoff_status）
  - 有详细的 output contract enforcement（5 条规则 + 字段语义定义）
  - 有 question-first protocol（歧义时使用 narrowest conservative interpretation）
  - 只支持单轮——retry/continue/return_to_planner 停在 unsupported_route
  - 无 multi-sprint 或 multi-round 能力

- **缺口**:
  1. **无 multi-round 执行**: 当前只能执行一轮。这是最大的功能缺口。
  2. **无增量进度追踪**: 没有跨 round 的 progress file。当前 progress_artifact 只记录单轮内的阶段状态。
  3. **无 "干净状态" 保证**: round 结束时没有明确的 "适合下一轮接手" 的状态定义。
  4. **retry 行为只有设计**: `agents/pge-generator.md` 定义了 retry behavior（读取 prior verdict + required fixes → 增量修复），但标注为 "Runtime retry is future work until the P2 bounded retry loop is implemented"。

- **改建动作充分性**:
  - `pge-rebuild-plan.md` §3 Gate 3 提出了 4 项改建: 实现 continue/retry/return_to_planner 路由、增量进度追踪、multi-round 生命周期、stop condition 和 max_rounds。方向正确且全面。
  - `pge-multiround-runtime-design.md` 提供了完整的 run/sprint/round 三层设计，包含状态机、checkpoint、resume、context rot 防治。设计非常详细。
  - **不足**: `pge-multiround-runtime-design.md` 引入了 sprint 层，但 `pge-rebuild-plan.md` 的 Phase 2 只提到 "multi-round 路由"，没有提到 sprint。两份方案对 multi-round 的粒度理解不一致: rebuild-plan 说的是 round 级别的 retry/continue，multiround-design 说的是 sprint 级别的工作阶段。需要明确: Phase 2 是否包含 sprint 层的实现？

- **需要的 artifact**:
  1. 更新 `skills/pge-execute/ORCHESTRATION.md`: multi-round 生命周期（round loop + sprint loop）
  2. 更新 `skills/pge-execute/contracts/routing-contract.md`: retry/continue/return_to_planner 的重新调度语义
  3. 更新 `skills/pge-execute/runtime/artifacts-and-state.md`: round_number, sprint_number, progress_artifact 格式
  4. 新增 `skills/pge-execute/handoffs/retry.md`: retry 路由的调度文本
  5. 更新 `skills/pge-execute/runtime/persistent-runner.md`: 从设计转为可执行指令

- **验收方式**:
  - Evaluator verdict=RETRY 时，系统自动开始 retry round（不停在 unsupported_route）
  - Evaluator verdict=PASS + route=continue 时，系统自动开始下一 sprint
  - 达到 max_rounds 时，系统停止并产出 summary
  - progress_artifact 累积记录每轮结果

## Gate 4: Evaluator hard-threshold grading

- **当前状态 (confirmed)**:
  - Evaluator 使用叙述性判断: verdict (PASS/RETRY/BLOCK/ESCALATE) + evidence + violated_invariants_or_risks + required_fixes + next_route
  - 有 verdict 选择规则: "choose the narrowest verdict that explains the failure correctly"
  - 有详细的 core evaluation order（5 步: 验证 deliverable → 对照 contract → 验证证据 → 检查 invariants → 评估 deviations）
  - 有 forbidden behavior 列表（不修改 deliverable、不接受 narrative-without-evidence 等）
  - 无量化评分维度、无硬阈值、无校准 fixtures、无 AI slop 检测
  - `SKILL.md` 明确列出 "evaluator calibration fixtures" 为未实现功能

- **缺口**:
  1. **无量化评分**: 没有数字化的评分维度，verdict 完全依赖 agent 主观判断
  2. **无硬阈值**: 没有 "任一维度低于 X 则不可 PASS" 的机制
  3. **无校准 fixtures**: 没有已知弱/强交付物的标准样例来校准 Evaluator
  4. **无 AI slop 检测**: 没有结构化的 slop 模式检测（空洞赞美、问题最小化、存在即合格、自述循环）
  5. **Gate 只做结构检查**: `bin/pge-validate-contracts.sh` 和 orchestration gate 只检查 section 存在，不检查内容质量

- **改建动作充分性**:
  - `pge-rebuild-plan.md` §3 Gate 4 提出了 4 项改建: 评分维度、校准 fixtures、AI slop 检测、置信度标注。方向正确。
  - `pge-evaluator-threshold-design.md` 提供了非常详细的设计: 6 维度评分（DA/ES/CC/SD/VI/CP）、1-5 分制、硬阈值规则、7 个 blocking flags、6 个 weak deliverable fixtures、6 个防退化机制。设计完整度高。
  - **充分性评估**: 这是 5 个 Gate 中设计最完整的。`pge-evaluator-threshold-design.md` 的设计深度足以指导实现。
  - **风险**: 设计复杂度高。从当前的 5 个 markdown section 输出到完整的 6 维度评分 + 7 blocking flags + 结构化 evidence 是一个很大的跳跃。§10.2 的分阶段实施（Phase 1 评分框架 → Phase 2 证据结构化 → Phase 3 校准与防御）是合理的渐进策略。

- **需要的 artifact**:
  1. 更新 `agents/pge-evaluator.md`: 增加评分维度要求、校准 fixtures（few-shot examples）、anti-slop 规则
  2. 更新 `skills/pge-execute/contracts/evaluation-contract.md`: 增加评分维度定义、硬阈值规则、证据分类
  3. 更新 `skills/pge-execute/handoffs/evaluator.md`: 增加结构化评分输出格式
  4. 可选: 新增 `skills/pge-execute/fixtures/` 目录存放校准 fixtures

- **验收方式**:
  - Evaluator 产出包含 6 维度评分表的 verdict bundle
  - 硬阈值规则生效: 任一核心维度 < 3 时 verdict 不为 PASS
  - 对 W1-W6 fixtures 运行 Evaluator，verdict 匹配预期
  - Anti-slop 检测: verdict_reason 中出现空洞赞美时被标记

## Gate 5: Runtime long-running execution and recovery

- **当前状态 (confirmed)**:
  - `skills/pge-execute/runtime/persistent-runner.md` 定义了恢复协议（7 步 recovery protocol）、loop limits、team lifecycle、completion gate
  - 恢复协议是**设计文档**，不是可执行指令——标注为 "The current executable runtime is still one implementation round"
  - Artifact-backed 状态: state_artifact + progress_artifact + phase artifacts 是持久真相
  - "Chat history is not durable state" 原则已确立
  - Team 重建规则已定义: "recreate exactly one team with the same role names and continue from artifacts"
  - Loop limits 已定义: max preflight repairs 2, max generator attempts 3, max rounds 5
  - 无实际的 checkpoint 写入、无 session 恢复、无 context rot 防治

- **缺口**:
  1. **无 session 恢复实现**: persistent-runner.md 的 recovery protocol 是设计，不是可执行指令
  2. **无 checkpoint 机制**: 没有在关键节点保存可恢复状态的实际流程
  3. **无 context rot 防治**: 没有 context window 监控或主动 compaction 策略
  4. **无 "干净 handoff" 格式**: 没有 GSD 式的 HANDOFF.json + .continue-here.md 双格式
  5. **无 resume 入口**: 没有 `/pge-execute --resume <run_id>` 的实现

- **改建动作充分性**:
  - `pge-rebuild-plan.md` §3 Gate 5 提出了 4 项改建: checkpoint 协议、恢复协议可执行化、resume.md handoff、context budget 规则。方向正确。
  - `pge-multiround-runtime-design.md` §7 提供了详细的 checkpoint/handoff/resume 设计: 3 种 checkpoint 类型（round/sprint/pause）、双格式（JSON + Markdown）、6 步 resume 流程、team 重建规则、mandatory read list。设计完整。
  - **充分性评估**: 设计充分，但实现依赖 Phase 2 (multi-round)。单轮执行不需要恢复——如果只有一轮，重新运行比恢复更简单。因此 `pge-rebuild-plan.md` 将此放在 Phase 5 是合理的。
  - **风险**: `pge-multiround-runtime-design.md` §9.2 的 context budget 分级（NORMAL/WARNING/CRITICAL）依赖 Claude Code 提供 context usage API。当前 Claude Code 是否暴露 context usage 信息需要验证。

- **需要的 artifact**:
  1. 更新 `skills/pge-execute/ORCHESTRATION.md`: checkpoint 协议（每阶段完成后写 checkpoint）
  2. 更新 `skills/pge-execute/runtime/persistent-runner.md`: 从设计转为可执行指令
  3. 新增 `skills/pge-execute/handoffs/resume.md`: 从 checkpoint 恢复的调度文本
  4. 更新 `skills/pge-execute/runtime/artifacts-and-state.md`: checkpoint 格式、context budget 规则
  5. 更新 `skills/pge-execute/SKILL.md`: 增加 `--resume` 参数支持

- **验收方式**:
  - 每个阶段完成后 state_artifact 包含足够信息重启该阶段
  - session 中断后，从 state_artifact 恢复到最近完成的阶段，继续执行
  - context budget 超过阈值时，主动写 checkpoint 并暂停
  - pause_checkpoint 包含 JSON + Markdown 双格式

# Summary

## 总体评估

5 份方案文档整体质量较高，对当前 repo 状态的理解基本准确，设计方向与 Anthropic 5 个 Critical Gates 对齐。最大的优势是 `pge-evaluator-threshold-design.md` 的设计深度——6 维度评分、blocking flags、weak deliverable fixtures、anti-slop 检测形成了完整的评估框架。最大的风险是方案之间的 schema 不统一（contract-negotiation 和 multiround-runtime 对 runtime state 的扩展互相独立）以及 sprint 层引入与 "不学 sprint" 结论的张力。

## 最严重的 3 个问题

1. **P0-1: 历史 artifact 命名与方案/合约定义不一致** — 方案基于规范路径做设计，但实际运行产物使用旧命名约定。这意味着方案中 "3 个完整 run" 的 confirmed 标签不够准确，可能影响对当前状态的判断。

2. **P0-2: multiround-runtime-design 将规范性定义描述为"从当前 repo 提升"** — 措辞暗示这是小变更，实际上是将规范性定义转为可执行实现。读者可能低估实现难度。

3. **P1-2: contract-negotiation 和 multiround-runtime 对 runtime state 的扩展互相独立** — 两份方案各自引入了不同的 runtime state 字段，没有统一的 schema。如果同时实施会产生合并冲突。

## 推荐优先修复顺序

1. **P0-3 → P0-1**: 先统一路径引用（将 `contracts/` 改为 `skills/pge-execute/contracts/`），然后确认历史 artifact 命名是否需要迁移或在方案中标注为 "旧格式"。
2. **P1-2 → P0-2**: 统一 contract-negotiation 和 multiround-runtime 的 runtime state schema，同时修正 "从当前 repo 提升" 的措辞为 "将规范性定义转为可执行实现"。
3. **P1-5**: 在 multiround-runtime-design 中显著位置解释为什么引入 sprint 层（当前理由在附录 B，不够显著），并与 reference-learning-notes 的 "不学 sprint" 结论做明确区分。
