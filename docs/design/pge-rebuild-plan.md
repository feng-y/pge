# PGE 改建方案

Updated: 2026-04-29

---

## 1. 当前 PGE 的真实状态

### Confirmed（从代码/文件直接验证）

| 能力 | 证据 |
|------|------|
| Claude Code 插件打包 | `.claude-plugin/plugin.json` + `marketplace.json`，version 0.1.3 |
| 本地安装脚本 | `bin/pge-local-install.sh` — 完整 Python 脚本 |
| 静态合约验证 | `bin/pge-validate-contracts.sh` — 243 行 bash |
| 三个 agent 定义 | `agents/pge-planner.md`, `agents/pge-generator.md`, `agents/pge-evaluator.md` |
| SKILL.md orchestration shell | `skills/pge-execute/SKILL.md` — v0.4.0, <220 行 |
| 最小编排行为定义 | `skills/pge-execute/ORCHESTRATION.md` — 单轮生命周期 |
| 五个运行时合约 | `skills/pge-execute/contracts/` — entry, round, evaluation, routing, runtime-state |
| 五个 handoff 模板 | `skills/pge-execute/handoffs/` — planner, preflight, generator, evaluator, route-summary-teardown |
| 运行时 artifact 路径定义 | `skills/pge-execute/runtime/artifacts-and-state.md` |
| 历史运行产物 | `.pge-artifacts/` 下 3 个早期 run（使用 pre-ORCHESTRATION 命名约定：`-planner-output.md`, `-generator-output.md`, `-evaluator-verdict.md`, `-round-summary.md`，每个 run 4 个文件，不是当前 ORCHESTRATION.md 定义的完整 9-artifact 格式） |
| 证明运行记录 | `docs/proving/runs/run-001..005/` |
| 单轮执行模型 | `ORCHESTRATION.md`: "stop after one bounded round" |
| 只支持 `converged` 终端路由 | `routing-contract.md`: continue/retry/return_to_planner 停在 `unsupported_route` |

### Inferred（从设计文档推断，未在运行时验证）

| 项目 | 推断依据 |
|------|---------|
| Marketplace 安装可用 | `marketplace.json` 存在，但端到端安装未验证 |
| Preflight 修复循环有效 | 合约定义 max 2 attempts，但实际修复质量依赖 Claude 行为 |
| Gate 检查有效阻止低质量产物 | Gate 只检查 section 存在，不检查内容质量 |
| 状态机转换正确 | 状态转换规则在 markdown 中定义，由 Claude 解释执行，无确定性保证 |

### 关键架构事实

**PGE 没有运行时代码。** 整个 repo 是 markdown 文档/合约/agent 定义。执行依赖 Claude Code 的 Agent Team 机制解释 SKILL.md 中的指令。这意味着：
- "执行" = Claude Code 读取 SKILL.md 并按指令操作
- "状态机" = Claude Code 按 ORCHESTRATION.md 中的规则写 JSON 文件
- "gate" = Claude Code 检查 artifact 文件是否包含必需 section
- "Agent Team" = Claude Code 原生 TeamCreate/SendMessage/TeamDelete API

这不是缺陷——这是有意的设计选择。PGE 是一个 **prompt-driven harness**，不是一个代码运行时。

---

## 2. 当前已具备的能力

| 能力 | 成熟度 | 说明 |
|------|--------|------|
| P/G/E 三角色分离 | 可用 | 三个 agent 有明确的职责、输入/输出字段、工具权限、行为约束 |
| 单轮 bounded execution | 可用 | 完整的 7 步生命周期：initialize → team → planner → preflight → generator → evaluator → route/summary/teardown |
| Preflight negotiation | 可用（有限） | Generator proposal + Evaluator review，max 2 repair attempts |
| 合约体系 | 可用 | 5 个合约文件定义完整的 verdict/route/state 语义 |
| Handoff 模板 | 可用 | 5 个 handoff 文件定义调度文本/gate/路由行为 |
| Artifact-backed 状态 | 可用 | 每个阶段产出写入 `.pge-artifacts/`，不依赖 chat history |
| 插件打包和安装 | 可用（本地验证） | 本地安装脚本完整，marketplace 路径未验证 |
| 静态合约验证 | 可用 | `bin/pge-validate-contracts.sh` 检查文件/section/pattern |

---
## 3. 与 Anthropic 5 个 Critical Gates 的差距分析

### Gate 1: Planner raw-prompt ownership

**参考标准**: Planner 将 1-4 句用户 prompt 展开为完整产品 spec，关注产品上下文和高层技术设计，不指定细粒度实现细节。

**当前状态**: Planner 是 "round shaper"，不是 "product planner"。接收上游 spec 或 raw user prompt，产出 bounded round contract。有 14 个输出字段（goal, evidence_basis, design_constraints 等）。有 "single bounded round heuristic"（pass-through 或 cut）。

**缺口**:
1. **无结构化澄清流程**: Planner 没有 Superpowers 式的逐步提问机制。当 raw prompt 模糊时，Planner 依赖自身判断而非向用户澄清
2. **无 scope 前置检测**: 没有在深入规划前判断任务是否需要分解的机制
3. **open_questions 是被动的**: Planner 记录 open_questions 但没有主动解决它们的流程
4. **无方案对比**: 不提出 2-3 种方案让用户选择

**改建动作**:
- 在 `agents/pge-planner.md` 中增加 **intake negotiation 协议**: 当 raw prompt 歧义度超过阈值时，Planner 必须先产出 clarification artifact，等待用户回应后再产出 round contract
- 在 `skills/pge-execute/contracts/entry-contract.md` 中定义 intake negotiation 的触发条件和产出格式
- 在 `skills/pge-execute/handoffs/planner.md` 中增加 intake negotiation 阶段的调度文本

### Gate 2: Preflight multi-turn negotiation

**参考标准**: Generator 提出要构建什么以及如何验证成功，Evaluator 审查提案，双方迭代直到达成 sprint contract。通信通过文件。

**当前状态**: Preflight 存在且可用。Generator 产出 contract-proposal，Evaluator review。有 max 2 repair attempts。PASS + ready_to_generate 继续，BLOCK + generator repair 进入修复循环。

**缺口**:
1. **修复循环太短**: max 2 attempts 可能不够复杂任务的协商
2. **无 Evaluator 反提案**: Evaluator 只能 PASS/BLOCK，不能提出替代方案
3. **无协商收敛检测**: 没有检测协商是否在进步（vs 原地打转）的机制
4. **BLOCK 后的修复指导不够结构化**: Evaluator 的 required_fixes 是自由文本

**改建动作**:
- 将 `max_preflight_attempts` 从 2 提升到 3，并在 `skills/pge-execute/runtime/artifacts-and-state.md` 中更新
- 在 `skills/pge-execute/contracts/evaluation-contract.md` 中为 preflight 阶段增加 **structured feedback 格式**: 每个 BLOCK 必须包含 `specific_issue`, `suggested_fix`, `acceptance_condition`
- 在 `skills/pge-execute/handoffs/preflight.md` 中增加收敛检测: 如果第 N 次修复没有解决第 N-1 次的 specific_issue，升级为 return_to_planner

### Gate 3: Generator slice/feature granularity

**参考标准**: Generator 按 sprint 工作，每个 sprint 实现一个 feature。Sprint 结束时 git commit + progress update，留下干净状态。V2 中 sprint 构造被移除（Opus 4.6 原生能力足够）。

**当前状态**: Generator 执行一个 bounded round contract，产出 actual deliverable + 本地验证 + self-review。有完整的输出字段。但只支持单轮——没有 multi-slice 或 multi-round 能力。

**缺口**:
1. **无 multi-round 执行**: 当前只能执行一轮。retry/continue/return_to_planner 被识别但停在 unsupported_route
2. **无增量进度追踪**: 没有跨 round 的 progress file（类似 Anthropic 的 `claude-progress.txt`）
3. **无 "干净状态" 保证**: round 结束时没有明确的 "适合下一轮接手" 的状态定义
4. **无 feature list 作为 ground truth**: 没有跨 round 的任务清单追踪完成状态

**改建动作**:
- 实现 `continue` 路由: Evaluator verdict=PASS + route=continue 时，自动开始下一轮（新 Planner → Generator → Evaluator 循环）
- 实现 `retry` 路由: Evaluator verdict=RETRY 时，Generator 在同一 contract 下重新执行，带上 Evaluator 反馈
- 实现 `return_to_planner` 路由: Evaluator verdict=BLOCK/ESCALATE 时，回到 Planner 重新规划
- 在 `skills/pge-execute/runtime/artifacts-and-state.md` 中增加 `progress_artifact` 格式: 跨 round 的累积进度记录
- 在 `skills/pge-execute/contracts/routing-contract.md` 中定义 multi-round 的 stop condition 和 max_rounds 限制
- 在 `skills/pge-execute/ORCHESTRATION.md` 中增加 multi-round 生命周期定义

### Gate 4: Evaluator hard-threshold grading

**参考标准**: Evaluator 有硬阈值，任一标准低于阈值则 sprint 失败。使用 few-shot examples 校准。明确惩罚 AI slop 模式。

**当前状态**: Evaluator 使用叙述性判断（PASS/RETRY/BLOCK/ESCALATE），有 verdict 选择规则（"choose the narrowest verdict"）。但没有量化阈值、没有评分维度、没有校准 fixtures。

**缺口**:
1. **无量化评分维度**: 没有类似 Anthropic 的 Design Quality / Originality / Craft / Functionality 维度
2. **无硬阈值**: verdict 完全依赖 Evaluator agent 的主观判断
3. **无校准 fixtures**: 没有 few-shot examples 来校准 Evaluator 的判断标准
4. **无 AI slop 检测**: 没有明确惩罚模板化/低质量输出的机制
5. **无置信度标注**: 不像 gstack 那样要求每个发现附带置信度分数

**改建动作**:
- 在 `skills/pge-execute/contracts/evaluation-contract.md` 中增加 **评分维度定义**: 根据任务类型定义 2-4 个评分维度，每个维度有 1-10 分和硬阈值
- 在 `agents/pge-evaluator.md` 中增加 **校准 fixtures**: 提供 2-3 个 few-shot examples（一个 PASS、一个 RETRY、一个 BLOCK），展示期望的评估深度和判断标准
- 在 `skills/pge-execute/contracts/evaluation-contract.md` 中增加 **AI slop 检测规则**: 定义具体的 slop 模式（模板化输出、模糊表述、未验证的声明）及其对 verdict 的影响
- 在 Evaluator 输出字段中增加 `confidence_score` (1-10) 和 `evidence_type` (code-verified / pattern-matched / inferred)

### Gate 5: Runtime long-running execution and recovery

**参考标准**: Agent 在离散 session 中工作，每个新 session 开始时没有之前的记忆。需要 durable state（progress file + feature list + git）来跨 session 恢复。

**当前状态**: `skills/pge-execute/runtime/persistent-runner.md` 定义了恢复协议但未实现。当前如果 team 丢失或 session 中断，没有自动恢复机制。Artifact 写入 `.pge-artifacts/` 但没有恢复读取流程。

**缺口**:
1. **无 session 恢复**: team 丢失后无法从 artifact 恢复执行
2. **无 checkpoint 机制**: 没有在关键节点保存可恢复状态的流程
3. **无 context rot 防治**: 没有 context window 监控或主动 compaction 策略
4. **无 "干净 handoff" 格式**: 没有类似 GSD 的 HANDOFF.json + .continue-here.md 双格式

**改建动作**:
- 在 `skills/pge-execute/ORCHESTRATION.md` 中增加 **checkpoint 协议**: 每个阶段完成后写 checkpoint 到 state artifact，包含足够信息重启该阶段
- 在 `skills/pge-execute/runtime/persistent-runner.md` 中将恢复协议从设计转为可执行指令: 定义 resume 入口、state 读取、阶段重入逻辑
- 在 `skills/pge-execute/handoffs/` 中增加 `resume.md`: 定义从 checkpoint 恢复的调度文本
- 在 `skills/pge-execute/runtime/artifacts-and-state.md` 中增加 context budget 规则: 当 context 使用率超过阈值时，主动写 checkpoint 并建议 /clear

---
## 4. 改建目标

每个目标必须可验收，不是愿景描述。

| # | 目标 | 验收标准 |
|---|------|---------|
| G1 | Planner 能处理模糊 raw prompt | 给定一个 2 句话的模糊 prompt，Planner 产出 clarification artifact 或 bounded round contract（不是两者都不产出） |
| G2 | Preflight 协商能收敛或明确失败 | 3 次 preflight attempt 内达成 contract，或升级为 return_to_planner，不会原地打转 |
| G3 | 支持 multi-round 执行 | retry/continue/return_to_planner 三条路由可自动重新调度，有 max_rounds 限制 |
| G4 | Evaluator 有量化评分和硬阈值 | 每个 verdict 附带维度评分和置信度，硬阈值低于 X 则自动 RETRY/BLOCK |
| G5 | 支持从 checkpoint 恢复执行 | session 中断后，从 state artifact 恢复到最近完成的阶段，继续执行 |
| G6 | 跨 round 进度追踪 | progress artifact 累积记录每轮结果，新 round 的 Planner 能读取历史进度 |

---

## 5. 改建非目标

明确不做的事情：

| # | 非目标 | 原因 |
|---|--------|------|
| N1 | 不做战略设计文档 | PGE 已有明确的 P/G/E 三角色架构，不需要重新设计 |
| N2 | 不新增 agent | 保持 Planner/Generator/Evaluator 三个稳定角色，不膨胀为 4+ agent |
| N3 | 不复制其他项目的完整体系 | 不复制 GSD 的 86 skills、Superpowers 的 worktree 工作流、gstack 的交互式 review |
| N4 | 不写运行时代码 | 保持 prompt-driven harness 架构，不引入 JS/Python 运行时 |
| N5 | 不做并行执行 | 保持串行的 P→G→E 流程，不引入 wave/parallel 执行 |
| N6 | 不做 cross-model verification | 保持单模型执行，不引入 Codex/GPT 交叉验证 |
| N7 | 不做 plugin marketplace 体系 | PGE 是单项目插件，不需要 skill 分发体系 |
| N8 | 不做 UI/UX 相关功能 | PGE 是 proving/execution 框架 |

---

## 6. 分阶段改建路线

### Phase 0: 设计文档对齐（前置条件）

**范围**: 确保所有设计文档内部一致，作为实施的前提。

**验收标准**:
1. 所有设计文档中的 artifact 路径使用 `skills/pge-execute/` 前缀
2. runtime-state schema 在 `pge-multiround-runtime-design.md` §2.1 中统一（包含 contract-negotiation 字段）
3. 状态名统一使用 `planning_round`（对齐 `runtime-state-contract.md`）
4. "slice" 术语替代 "sprint"（对齐 `runtime-state-contract.md` 的 `active_slice_ref`）
5. 历史 artifact 命名差异已在文档中标注

**状态**: 已在 Round 4 post-review revision 中完成。

### Phase 1: Evaluator 硬阈值（最高优先级）

**范围**: 让 Evaluator 从叙述性判断升级为量化评分 + 硬阈值。

**理由**: Anthropic 明确指出 "开箱即用的 Claude 是糟糕的 QA agent"。Evaluator 质量是整个 harness 的瓶颈——如果 Evaluator 不可靠，multi-round 执行只会放大错误。

**产出**:
- 更新 `skills/pge-execute/contracts/evaluation-contract.md`: 增加评分维度定义、硬阈值规则、AI slop 检测规则
- 更新 `agents/pge-evaluator.md`: 增加校准 fixtures（2-3 个 few-shot examples）、置信度标注要求
- 更新 `skills/pge-execute/handoffs/evaluator.md`: 增加结构化评分输出格式

**依赖**: 无。可独立进行。

**验收标准**: 见 Phase 1 验收标准（§7）。

### Phase 2: Multi-round 路由

**范围**: 实现 retry/continue/return_to_planner 三条路由的自动重新调度。

**理由**: 这是从 "单轮执行" 到 "可迭代执行" 的核心跳跃。没有 multi-round，Generator 的错误无法被修复，Evaluator 的反馈无法被消费。

**产出**:
- 更新 `skills/pge-execute/contracts/routing-contract.md`: 定义三条路由的重新调度语义、max_rounds 限制、stop condition
- 更新 `skills/pge-execute/ORCHESTRATION.md`: 增加 multi-round 生命周期（round loop + termination）
- 更新 `skills/pge-execute/runtime/artifacts-and-state.md`: 增加 round_number、progress_artifact 格式
- 更新 `skills/pge-execute/handoffs/route-summary-teardown.md`: 增加 retry/continue/return_to_planner 的调度文本
- 新增 `skills/pge-execute/handoffs/retry.md`: retry 路由的具体调度（带 Evaluator 反馈）

**依赖**: 无硬依赖。当前 Evaluator 已产出 `required_fixes`（叙述性）和 `next_route`，足以支撑基本的 retry 路由。Phase 1 的结构化评分会增强 retry 质量，但不是 retry 的前提条件。Phase 1 和 Phase 2 可并行推进。

**验收标准**: 见 Phase 2 验收标准（§7）。
### Phase 3: Preflight 协商增强

**范围**: 让 preflight 协商更结构化、能收敛或明确失败。

**理由**: 当前 preflight 的 max 2 attempts 和自由文本反馈不够。结构化反馈 + 收敛检测让协商更可靠。

**产出**:
- 更新 `skills/pge-execute/contracts/evaluation-contract.md`: 为 preflight 阶段增加 structured feedback 格式（specific_issue / suggested_fix / acceptance_condition）
- 更新 `skills/pge-execute/handoffs/preflight.md`: 增加收敛检测逻辑、max_preflight_attempts 提升到 3
- 更新 `skills/pge-execute/runtime/artifacts-and-state.md`: max_preflight_attempts 从 2 改为 3

**依赖**: Phase 1（结构化评分格式是 preflight feedback 的基础）。

**验收标准**: 见 Phase 3 验收标准（§7）。

### Phase 4: Planner intake negotiation

**范围**: 让 Planner 能处理模糊 raw prompt，通过结构化澄清流程产出高质量 round contract。

**理由**: 当前 Planner 对模糊输入的处理依赖自身判断。增加 intake negotiation 让 Planner 能主动澄清，减少下游错误。

**产出**:
- 更新 `agents/pge-planner.md`: 增加 intake negotiation 协议（歧义检测 → clarification artifact → 用户回应 → round contract）
- 更新 `skills/pge-execute/contracts/entry-contract.md`: 定义 intake negotiation 的触发条件、clarification artifact 格式
- 更新 `skills/pge-execute/handoffs/planner.md`: 增加 intake negotiation 阶段的调度文本
- 更新 `skills/pge-execute/ORCHESTRATION.md`: 在 planner 阶段前增加可选的 intake negotiation 步骤

**依赖**: 无直接依赖，但建议在 Phase 1-2 之后进行（先确保下游可靠）。

**验收标准**: 见 Phase 4 验收标准（§7）。

### Phase 5: Checkpoint 和恢复

**范围**: 实现 checkpoint 写入和 session 恢复。

**理由**: Multi-round 执行（Phase 2）增加了 session 中断的风险。没有恢复机制，中断意味着从头开始。

**产出**:
- 更新 `skills/pge-execute/ORCHESTRATION.md`: 增加 checkpoint 协议（每阶段完成后写 checkpoint）
- 更新 `skills/pge-execute/runtime/persistent-runner.md`: 将恢复协议从设计转为可执行指令
- 新增 `skills/pge-execute/handoffs/resume.md`: 从 checkpoint 恢复的调度文本
- 更新 `skills/pge-execute/runtime/artifacts-and-state.md`: 增加 checkpoint 格式和 context budget 规则

**依赖**: Phase 2（multi-round 是恢复的前提——单轮执行不需要恢复）。

**验收标准**: 见 Phase 5 验收标准（§7）。

---

## 7. 每阶段验收标准

### Phase 1 验收标准: Evaluator 硬阈值

1. `skills/pge-execute/contracts/evaluation-contract.md` 包含至少 2 个评分维度，每个维度有 1-10 分范围和硬阈值定义
2. `agents/pge-evaluator.md` 包含至少 2 个 few-shot examples（一个 PASS case、一个 RETRY/BLOCK case），每个 example 展示完整的评分过程
3. Evaluator 输出字段包含 `dimension_scores` (dict)、`confidence_score` (1-10)、`evidence_type` (enum)
4. `skills/pge-execute/contracts/evaluation-contract.md` 包含至少 3 条 AI slop 检测规则，每条规则有具体的模式描述和 verdict 影响
5. 运行 `bin/pge-validate-contracts.sh` 通过（新增的 section 被检测到）
6. 执行一次 proving run，Evaluator 产出包含维度评分和置信度的 verdict（不是纯叙述性判断）

### Phase 2 验收标准: Multi-round 路由

1. `skills/pge-execute/contracts/routing-contract.md` 定义 retry/continue/return_to_planner 三条路由的重新调度语义，每条路由有明确的触发条件和目标状态
2. `ORCHESTRATION.md` 包含 multi-round 生命周期定义，包括 round loop 入口、round_number 递增、termination 条件
3. `skills/pge-execute/runtime/artifacts-and-state.md` 包含 `round_number`、`max_rounds`、`progress_artifact` 字段定义
4. `routing-contract.md` 定义 `max_rounds` 默认值和 stop condition（不是无限循环）
5. 执行一次 proving run，当 Evaluator verdict=RETRY 时，系统自动开始 retry round（不是停在 unsupported_route）
6. 执行一次 proving run，当达到 max_rounds 时，系统停止并产出 summary（不是无限循环）

### Phase 3 验收标准: Preflight 协商增强

1. `skills/pge-execute/contracts/evaluation-contract.md` 的 preflight 部分包含 structured feedback 格式: 每个 BLOCK 必须有 `specific_issue`、`suggested_fix`、`acceptance_condition` 三个字段
2. `skills/pge-execute/handoffs/preflight.md` 包含收敛检测规则: 如果第 N 次修复没有解决第 N-1 次的 specific_issue，升级为 return_to_planner
3. `skills/pge-execute/runtime/artifacts-and-state.md` 中 `max_preflight_attempts` 为 3
4. 执行一次 proving run，preflight BLOCK 时 Evaluator 产出结构化反馈（不是自由文本）
5. 执行一次 proving run，preflight 3 次未收敛时升级为 return_to_planner（不是停止）

### Phase 4 验收标准: Planner intake negotiation

1. `agents/pge-planner.md` 包含 intake negotiation 协议，定义歧义检测标准和 clarification artifact 格式
2. `skills/pge-execute/contracts/entry-contract.md` 定义 intake negotiation 的触发条件（不是所有输入都触发）
3. `skills/pge-execute/handoffs/planner.md` 包含 intake negotiation 阶段的调度文本
4. 给定一个明确的 prompt（如 "add a README.md"），Planner 直接产出 round contract（不触发 intake negotiation）
5. 给定一个模糊的 prompt（如 "improve the project"），Planner 产出 clarification artifact（不是直接产出 round contract）

### Phase 5 验收标准: Checkpoint 和恢复

1. `ORCHESTRATION.md` 定义 checkpoint 协议: 每个阶段完成后写 checkpoint 到 state artifact
2. `skills/pge-execute/runtime/artifacts-and-state.md` 定义 checkpoint 格式，包含足够信息重启该阶段
3. `skills/pge-execute/handoffs/resume.md` 存在，定义从 checkpoint 恢复的调度文本
4. `skills/pge-execute/runtime/artifacts-and-state.md` 包含 context budget 规则（阈值和行为）
5. 执行一次 proving run 到 generator 阶段，手动中断，然后从 checkpoint 恢复，系统从 evaluator 阶段继续（不是从头开始）
