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
| 六个运行时合约 | `skills/pge-execute/contracts/` — entry, round, evaluation, routing, runtime-event, runtime-state |
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
| 合约体系 | 可用 | 6 个合约文件定义完整的 verdict/route/state/event 语义 |
| Handoff 模板 | 可用 | 5 个 handoff 文件定义调度文本/gate/路由行为 |
| Artifact-backed 状态 | 可用 | 每个阶段产出写入 `.pge-artifacts/`，不依赖 chat history |
| 插件打包和安装 | 可用（本地验证） | 本地安装脚本完整，marketplace 路径未验证 |
| 静态合约验证 | 可用 | `bin/pge-validate-contracts.sh` 检查文件/section/pattern |

---
## 3. 与 Anthropic 5 个 Critical Gates 的差距分析

### Gate 1: Planner evidence-backed round shaping

**参考标准**: Anthropic Planner 将 1-4 句用户 prompt 展开为完整产品 spec，关注产品上下文和高层技术设计，不指定细粒度实现细节。

**PGE 调整**: PGE 不直接复制 Anthropic product-spec Planner。PGE 是 prompt-driven bounded-round harness，不能假设后续 runtime 会可靠补齐高层 spec 的空白。因此 PGE Planner 的定位是 **evidence-backed bounded-round planner**：先做轻量 research，再做薄 counter-research / brainstorming，再冻结一个可执行、可验证、可路由的 round contract。

**当前状态**: Planner 是 "round shaper"，不是 "product planner"。接收上游 spec 或 raw user prompt，产出 bounded round contract。有 14 个输出字段（goal, evidence_basis, design_constraints 等）。已开始用职责面表达内部能力：evidence steward、scope challenger、contract author、risk registrar、contract self-checker。

**缺口**:
1. **research pass 仍需 proving**: 新规则已写入 Planner prompt，但还未用 proving run 验证它是否真能减少下游猜测
2. **clarification 仍是轻量机制**: 当前只允许 `planner_escalation` 放一个 focused question，尚未实现完整 intake negotiation
3. **risk register 仍压在 design_constraints 中**: 还没有独立 section，保持兼容但表达空间有限
4. **方案对比必须保持薄**: 推荐 cut + 最多两个 rejected cuts，避免退化成大设计流程

**改建动作**:
- 在 `agents/pge-planner.md` 中明确 research pass / thin counter-research pass / architecture pass / contract freeze
- 在 `skills/pge-execute/contracts/round-contract.md` 中定义 `evidence_basis` 的 source / fact / confidence / verification_path 结构
- 在 `skills/pge-execute/handoffs/planner.md` 中要求 thin brainstorming：推荐 cut + 最多两个 rejected cuts + tradeoff
- 将完整 intake negotiation 延后到 Phase 4；当前阶段只允许一个 focused `planner_escalation` question

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

### Gate 4: Evaluator acceptance surface

**参考标准**: Evaluator 必须独立验收真实交付物，并给出足以驱动路由的稳定裁决。Anthropic 的经验支持“强 evaluator gate”，但不要求所有任务都输出重型审计矩阵。对简单任务，重评分会直接变成收敛瓶颈。

**当前状态**: Evaluator 已有独立 verdict（PASS/RETRY/BLOCK/ESCALATE）和基本路由语义，但 repo 里仍残留“6 维评分 + weighted score + blocking flag matrix”的旧设计预期，与 `0.5A` 的轻量闭环目标冲突。

**缺口**:
1. **默认输出面过重**: `FAST_PATH` 和简单 `FULL_PGE` 任务不该默认写大型评分矩阵
2. **mode-aware 深度还未完全统一**: 简单任务、常规任务、复杂任务仍缺少一致的验收面定义
3. **无足够明确的 AI slop 规则**: 需要明确哪些“看起来像评估、实际上没验证”的模式直接禁止 PASS
4. **示例不足**: 缺少 compact PASS / RETRY / BLOCK 的对照样例来帮助稳定收敛

**改建动作**:
- 在 `skills/pge-execute/contracts/evaluation-contract.md` 中定义 **compact acceptance surface**：`FAST_PATH` 用 lightweight verdict，`LITE_PGE` / `FULL_PGE` 用 compact core scores
- 在 `agents/pge-evaluator.md` 中增加 **mode-aware 示例与边界**：突出独立验收、路由裁决、成本门控，而不是长篇审计
- 在 `skills/pge-execute/contracts/evaluation-contract.md` 中增加 **AI slop 检测规则**：明确“praise without substance / existence as quality / self-report as primary evidence / issue minimization” 不能 PASS
- 在 handoff 模板中保持 verdict 可路由、可压缩，而不是引入默认 `confidence matrix` 或 weighted totals

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
| G4 | Evaluator 有紧凑、稳定、可路由的验收面 | `FAST_PATH` 用 lightweight verdict；`LITE_PGE` / `FULL_PGE` 用 compact core scores；AI slop 模式不能 PASS |
| G5 | 支持从 checkpoint 恢复执行 | session 中断后，从 state artifact 恢复到最近完成的阶段，继续执行 |
| G6 | 跨 round 进度追踪 | progress artifact 累积记录每轮结果，新 round 的 Planner 能读取历史进度 |
| **G7** | **执行流程根据任务复杂度自适应** | 简单确定性任务（如 smoke test）通过 Agent Teams quick triage 快速收敛，Evaluator 批准 FAST_PATH 后 deterministic check 即可完成，不创建大量管理 artifacts |
| **G8** | **通信默认走 Agent Teams messaging** | P/G/E 之间的 negotiation、clarification、feedback 走 SendMessage；只有 locked contract、final evidence、final verdict、checkpoint 写文件。文件不是 message bus |

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

### Phase 0.5A: Adaptive Execution — 流程自适应（P0-1）

**范围**: 解决流程过重问题。当前所有任务（包括 9 字节 smoke test）走完整 P/G/E 全流程，产出 9 个管理文件。必须让执行流程根据任务复杂度自适应。

**理由**: 这是后续所有 Phase 的前提。如果不解决，multi-round（Phase 2）、checkpoint（Phase 5）等都建立在过重流程上，成本不可控。Smoke test 已证明问题存在。

**核心设计决策**:
- Planner 只做 task shaping + 验收门控定义，负责识别任务形态与边界，不负责 fast finish 决策
- Generator 基于 Planner contract 提出执行方式、验证方式和风险说明
- **Evaluator 拥有 Execution Cost Gate**：对确定性 FAST_PATH 可只基于 Planner contract 批准轻路径；对 LITE/FULL 则结合 Planner contract + Generator 方案决策执行模式（FAST_PATH / LITE_PGE / FULL_PGE / LONG_RUNNING_PGE），并确认是否允许快速结束
- Orchestrator 只执行 Evaluator 的 mode decision，不自行决定 fast finish
- 简单任务用 Agent Teams quick triage 快速收敛，不是跳过 Agent Teams
- Fast path 跳过 proposal/preflight/generator/summary/progress 等重 artifacts，但**不跳过 Evaluator verdict**

**产出**:
- `docs/design/pge-adaptive-execution-design.md`（已创建）
- 更新 `skills/pge-execute/SKILL.md`: 增加 mode selection 流程
- 更新 `skills/pge-execute/ORCHESTRATION.md`: 增加 triage 阶段和 mode-specific 生命周期
- 更新 `skills/pge-execute/contracts/routing-contract.md`: 明确 execution mode 不是 route，并补充 mode-aware early-converge 规则
- 更新 `skills/pge-execute/runtime/artifacts-and-state.md`: per-mode artifact budget

**依赖**: Phase 0 完成。建议先于 Phase 1 落地。

**验收标准**: 见 §7 Phase 0.5A 验收标准。

### Phase 0.5B: Agent Teams Communication — 通信模型修正（P0-2）

**范围**: 解决通信模型错误。当前 P/G/E 之间所有交互通过文件，本质上是三个独立模型串行读写文件，没有利用 Agent Teams 的 direct communication 能力。

**理由**: Anthropic 用文件通信是 Claude Agent SDK 的环境约束（SDK 没有 SendMessage），不是架构偏好。PGE 运行在 Claude Code Agent Teams 上，有 SendMessage 原语，应该利用它。不解决这个问题，preflight negotiation 的效率和 artifact 膨胀问题无法根治。

**核心设计决策**:
- **默认走 Agent Teams messaging**: negotiation、clarification、challenge、feedback、status 全走 SendMessage
- **例外才写文件**: 只有 durable phase outputs 才写文件，包括 locked contract、最终 contract/proposal 结果、final evidence、final verdict、runtime state、checkpoint/resume，以及 mode 需要时的 summary/progress
- Agent 主动读文件的场景极少：只有 resume 读 checkpoint、Evaluator 独立读 deliverable 验证
- 文件不是 message bus，不模拟聊天记录
- Resume 从 checkpoint 重建上下文，不重播文件历史

**产出**:
- `docs/design/pge-agent-teams-communication-design.md`（已创建）
- 更新 `skills/pge-execute/handoffs/*.md`: 区分 message dispatch 和 file write
- 更新 `skills/pge-execute/ORCHESTRATION.md`: 通信方式从 file-only 改为 hybrid
- 更新 `skills/pge-execute/runtime/artifacts-and-state.md`: 标注哪些 artifacts 是 durable（必须写文件）、哪些是 transient（走消息）

**依赖**: Phase 0 完成。与 Phase 0.5A 强相关，建议并行设计、串行落地（先通信面，再轻量模式）。

**验收标准**: 见 §7 Phase 0.5B 验收标准。

### Phase 1: Evaluator 验收面

**范围**: 让 Evaluator 从松散叙述性判断升级为**紧凑、可复用、可路由**的验收裁决面。

**理由**: Anthropic 明确指出 "开箱即用的 Claude 是糟糕的 QA agent"。Evaluator 质量是整个 harness 的瓶颈——如果 Evaluator 不可靠，multi-round 执行只会放大错误。

**Evaluator 在 PGE 中应承担的职责**:
- 独立验收：直接检查 deliverable 和关键证据
- 路由裁决：输出足以驱动 runtime 的 verdict + next_route
- 成本门控：在 preflight / triage 阶段判定执行模式

**Evaluator 不应默认承担的职责**:
- 不做 Planner 的工作
- 不做 Generator 的工作
- 不默认输出长篇审计报告
- 不因为能评分就默认写大评分矩阵

**设计原则**:
- Evaluator 的输出必须足够让 orchestrator 决策
- 但 Evaluator 不能重到自己变成收敛瓶颈
- `FAST_PATH` 用 lightweight verdict
- `LITE_PGE` / `FULL_PGE` 默认都用 compact acceptance surface
- 更深的评分和审计只能是显式请求的扩展模式，不是默认模式

**依赖**: Phase 0.5A（Evaluator 的 Execution Cost Gate 职责在 Phase 0.5A 中定义）。

**产出**:
- 更新 `skills/pge-execute/contracts/evaluation-contract.md`: 定义 compact acceptance surface、mode-aware 评估深度、AI slop 检测规则
- 更新 `agents/pge-evaluator.md`: 明确职责边界和 mode-aware 输出要求
- 更新 `skills/pge-execute/handoffs/evaluator.md`: 定义 lightweight / compact / deeper-audit 三层输出格式

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

**依赖**: 无硬依赖。当前 Evaluator 已产出 `required_fixes`（叙述性）和 `next_route`，足以支撑基本的 retry 路由。Phase 1 的紧凑验收面会增强 retry 质量，但不是 retry 的前提条件。Phase 1 和 Phase 2 可并行推进。

**验收标准**: 见 Phase 2 验收标准（§7）。
### Phase 3: Preflight 协商增强

**范围**: 让 preflight 协商更结构化、能收敛或明确失败。

**理由**: 当前 preflight 的 max 2 attempts 和自由文本反馈不够。结构化反馈 + 收敛检测让协商更可靠。

**产出**:
- 更新 `skills/pge-execute/contracts/evaluation-contract.md`: 为 preflight 阶段增加 structured feedback 格式（specific_issue / suggested_fix / acceptance_condition）
- 更新 `skills/pge-execute/handoffs/preflight.md`: 增加收敛检测逻辑、max_preflight_attempts 提升到 3
- 更新 `skills/pge-execute/runtime/artifacts-and-state.md`: max_preflight_attempts 从 2 改为 3

**依赖**: Phase 1（紧凑、可路由的 verdict surface 是 preflight feedback 结构化的基础）。

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

### Phase 0.5A 验收标准: Adaptive Execution

1. `docs/design/pge-adaptive-execution-design.md` 定义 4 种执行模式（FAST_PATH / LITE_PGE / FULL_PGE / LONG_RUNNING_PGE），每种模式有明确的 artifact budget
2. Evaluator 拥有 Execution Cost Gate：mode decision 和 fast-finish approval 不来自 Planner 或 Orchestrator
3. Planner 不输出 mode recommendation，不拥有 fast-finish 决策权
4. FAST_PATH 仍保留 Evaluator verdict（deterministic check 或 lightweight），不跳过 Evaluator
5. 简单任务（如 smoke test）通过 Agent Teams quick triage 收敛，管理 artifacts（不含 `input_artifact` 和最终 deliverable）不超过 3 个
6. 执行一次 smoke test proving run，使用 FAST_PATH mode，验证管理 artifact 数量（不含 `input_artifact` 和最终 deliverable）≤ 3

### Phase 0.5B 验收标准: Agent Teams Communication

1. `docs/design/pge-agent-teams-communication-design.md` 定义 Runtime Communication Plane（SendMessage）和 Durable Control Plane（文件），有明确的使用边界
2. Preflight negotiation 使用 Agent Teams direct communication（SendMessage），不使用文件轮转
3. 只有 durable phase outputs 写文件；negotiation 中间态不写文件轮转
4. Handoff 模板区分 message dispatch（runtime）和 file write（durable）
5. Resume 从 checkpoint 重建上下文，不重播文件历史
6. 执行一次 proving run，preflight 阶段的 G↔E 交互走 SendMessage，最终 locked contract 写文件

### Phase 1 验收标准: Evaluator 验收面

1. `skills/pge-execute/contracts/evaluation-contract.md` 明确定义 Evaluator 的三类职责：独立验收、路由裁决、成本门控
2. `agents/pge-evaluator.md` 明确定义 Evaluator 不默认输出长篇审计报告或大评分矩阵
3. `skills/pge-execute/handoffs/evaluator.md` 支持 mode-aware 输出：
   `FAST_PATH` = lightweight verdict
   `LITE_PGE` / `FULL_PGE` = compact acceptance surface
4. `skills/pge-execute/contracts/evaluation-contract.md` 包含至少 3 条 AI slop 检测规则，每条规则有具体模式描述和 verdict 影响
5. 运行 `bin/pge-validate-contracts.sh` 通过
6. 执行一次 proving run，Evaluator 产出足以驱动 routing 的紧凑 verdict，而不是冗长评审稿

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
