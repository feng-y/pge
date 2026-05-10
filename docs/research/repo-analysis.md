# PGE Repo Analysis

Updated: 2026-04-29

---

## 1. 文件清单

### 核心运行时文件

| 文件 | 用途 |
|------|------|
| `.claude-plugin/plugin.json` | Claude Code 插件元数据 (name: pge, version: 0.1.3) |
| `.claude-plugin/marketplace.json` | Marketplace 注册元数据 (owner: feng-y/pge) |
| `agents/pge-planner.md` | Planner agent 定义 — 产出 bounded round contract |
| `agents/pge-generator.md` | Generator agent 定义 — 执行 deliverable + 本地验证 |
| `agents/pge-evaluator.md` | Evaluator agent 定义 — 独立验证 + verdict + routing |
| `skills/pge-execute/SKILL.md` | 技能入口 — orchestration shell (v0.4.0, <220行) |
| `skills/pge-execute/ORCHESTRATION.md` | 最小编排行为定义 — 单轮生命周期 |

### Contracts (运行时权威)

| 文件 | 用途 |
|------|------|
| `skills/pge-execute/contracts/entry-contract.md` | 入口合约 — 当前阶段不强制入口字段 |
| `skills/pge-execute/contracts/round-contract.md` | 轮次合约 — Planner→Generator 的最小 handoff 字段 |
| `skills/pge-execute/contracts/evaluation-contract.md` | 评估合约 — verdict 类型/语义/选择规则 |
| `skills/pge-execute/contracts/routing-contract.md` | 路由合约 — verdict→route 映射 + stop condition |
| `skills/pge-execute/contracts/runtime-state-contract.md` | 运行时状态合约 — 规范性语义超集 |

### Handoffs (阶段调度模板)

| 文件 | 用途 |
|------|------|
| `skills/pge-execute/handoffs/planner.md` | Planner 调度文本 + gate |
| `skills/pge-execute/handoffs/preflight.md` | Preflight 调度 (Generator proposal + Evaluator review) |
| `skills/pge-execute/handoffs/generator.md` | Generator 实现调度 + gate |
| `skills/pge-execute/handoffs/evaluator.md` | Evaluator 最终评估调度 + gate |
| `skills/pge-execute/handoffs/route-summary-teardown.md` | 路由/摘要/拆除流程 |

### Runtime 资源

| 文件 | 用途 |
|------|------|
| `skills/pge-execute/runtime/artifacts-and-state.md` | 当前可执行的 artifact 路径 + state 子集 |
| `skills/pge-execute/runtime/persistent-runner.md` | 未来持久化运行模型 (recovery, loop limits) |

### 设计文档

| 文件 | 用途 |
|------|------|
| `docs/design/pge-execute/layered-skill-model.md` | 分层技能模型 — 组件表/流程图/架构模式 |
| `docs/design/pge-execute/communication-protocol.md` | 通信协议 — main 中介的文件通信 |
| `docs/design/pge-execute/execution-framework-lessons.md` | 外部框架教训 (Anthropic/OpenAI/Superpowers/GSD等) |
| `docs/design/pge-execute/role-mapping.md` | 角色映射 — researcher+archi→planner 等 |

### 执行计划 / 证明文档

| 文件 | 用途 |
|------|------|
| `docs/exec-plans/CURRENT_MAINLINE.md` | 当前主线目标 + P0 blocker |
| `docs/exec-plans/ISSUES_LEDGER.md` | P0/P1/P2 问题台账 |
| `docs/exec-plans/ROUND_TEMPLATE.md` | 轮次记录模板 |
| `docs/proving/README.md` | 证明/开发运行入口 |
| `docs/proving/runs/run-001..005/` | 历史证明运行记录 |

### 脚本

| 文件 | 用途 |
|------|------|
| `bin/pge-local-install.sh` | 本地开发安装 → `~/.claude/dev-plugins/pge` |
| `bin/pge-validate-contracts.sh` | 静态合约/schema 漂移检查 |

### 运行时产物

| 文件 | 用途 |
|------|------|
| `.pge-artifacts/run-*` | 历史运行产物 (planner/generator/evaluator/summary) |
| `.pge-artifacts/test-upstream-plan.md` | 测试用上游计划 |

### 其他

| 文件 | 用途 |
|------|------|
| `commands/start-round.md` | 开始一轮证明/开发的命令 |
| `commands/close-round.md` | 关闭一轮的命令 |
| `progress.md` | 整体 harness 进度跟踪 |
| `todo.md` | 未完成差距清单 |

---

## 2. 当前架构

PGE 是一个 Claude Code 插件，实现 Planner / Generator / Evaluator 三角色有界执行流。

**架构层次** (confirmed from code):

```
用户调用 /pge-execute <task>
  │
  ▼
SKILL.md — orchestration shell (main)
  │  读取 runtime/ 和 handoffs/ 资源
  │  创建一个 Agent Team
  │
  ├── planner (pge-planner agent)
  │     产出 bounded round contract
  │
  ├── preflight (generator proposal + evaluator review)
  │     质量左移，repo 编辑前的合约确认
  │
  ├── generator (pge-generator agent)
  │     执行实际 deliverable + 本地验证
  │
  ├── evaluator (pge-evaluator agent)
  │     独立验证 + verdict + next_route
  │
  └── route / summary / teardown
        路由决策 + 摘要 + 团队拆除
```

**关键架构原则** (confirmed from `SKILL.md`, `ORCHESTRATION.md`, `layered-skill-model.md`):

1. `main` 是 orchestration shell，不是第四个 agent
2. 所有语义 handoff 通过文件进行，不依赖 chat history
3. 每个阶段有结构化 gate — artifact 必须存在且包含必需 section
4. 持久真相是 `state_artifact` + `progress_artifact` + phase artifacts
5. 使用 Claude Code 原生 Agent Teams (TeamCreate/SendMessage/TeamDelete)
6. 渐进式加载 — SKILL.md 保持小型，详细指令在子目录

**插件打包** (confirmed from `.claude-plugin/`):

- 作为 Claude Code plugin 分发: `feng-y/pge`
- marketplace.json + plugin.json 双清单
- 安装路径: `/plugin marketplace add feng-y/pge` → `/plugin install pge@pge`
- 本地开发: `bin/pge-local-install.sh` → `~/.claude/dev-plugins/pge`

---

## 3. P/G/E 三角色

### Planner (pge-planner)

**职责** (confirmed from `agents/pge-planner.md`):
- 接收上游 spec 或 raw user prompt
- 执行轻量级证据收集
- 识别设计约束和 harness 约束
- 应用 "single bounded round heuristic" — 决定 `pass-through` 或 `cut`
- 冻结恰好一个 current-task plan / bounded round contract
- 定义 Generator 必须交付什么、Evaluator 必须验证什么

**输出字段** (confirmed): goal, evidence_basis, design_constraints, in_scope, out_of_scope, actual_deliverable, acceptance_criteria, verification_path, required_evidence, stop_condition, handoff_seam, open_questions, planner_note, planner_escalation

**工具**: Read, Grep, Glob (只读，不能编辑)

**限制** (confirmed):
- 不做实现
- 不做多层/递归分解
- 不做完整产品/spec 编写
- 不能静默解决歧义 — 必须记录在 open_questions

### Generator (pge-generator)

**职责** (confirmed from `agents/pge-generator.md`):
- 执行一个 bounded round contract
- 通过真实 repo 工作产出 actual deliverable
- 运行本地验证 (required, not optional)
- 执行本地 self-review (skeptical, not approval)
- 提供具体证据绑定到 acceptance criteria
- 声明 known limits 和 deviations
- 不自我批准 — 交给 Evaluator

**输出字段** (confirmed): current_task, boundary, actual_deliverable, deliverable_path, changed_files, local_verification, evidence, self_review, known_limits, non_done_items, deviations_from_spec, handoff_status

**工具**: Read, Write, Edit, Bash, Grep, Glob (完整编辑能力)

**限制** (confirmed):
- preflight 通过前不能编辑 repo
- 不能扩展 scope
- 不能重新定义 contract
- 不能自我批准
- 歧义时使用 "narrowest conservative interpretation"

### Evaluator (pge-evaluator)

**职责** (confirmed from `agents/pge-evaluator.md`):
- 独立验证 actual deliverable (不信任 Generator 叙述)
- 对照 approved round contract 验证
- 检查证据充分性和独立性
- 检查 task-applicable invariants
- 发出 verdict: PASS | RETRY | BLOCK | ESCALATE
- 发出 canonical next_route: continue | converged | retry | return_to_planner

**输出字段** (confirmed): verdict, evidence, violated_invariants_or_risks, required_fixes, next_route

**工具**: Read, Bash, Grep, Glob (只读，不能编辑)

**核心评估顺序** (confirmed):
1. 先验证 actual deliverable 本身
2. 对照 approved contract 验证
3. 验证证据充分性和独立性
4. 检查 task-applicable invariants
5. 评估 known_limits, non_done_items, deviations

**限制** (confirmed):
- 不能修改 deliverable
- 不能修复问题
- 不能重新定义 contract
- 不能接受仅基于 artifact 存在的工作
- 不能接受叙述作为证据

---

## 4. 当前执行模型

### 单轮执行 (confirmed)

**当前状态**: 只支持单轮执行。这在多处明确声明:
- `ORCHESTRATION.md` line 5: "stop after one bounded round"
- `SKILL.md` line 57-59: "Not supported yet: automatic multi-round redispatch, bounded retry loop, return-to-planner loop"
- `progress.md`: "The current executable runtime is still a single implementation round"

### Sprint 概念

**不存在** (confirmed)。虽然 `execution-framework-lessons.md` 讨论了 Anthropic 文章中的 sprint 概念，但 PGE 明确声明当前不支持 sprint 粒度:
- "Generator executes one accepted bounded round only" (execution-framework-lessons.md)
- "current runtime still executes one implementation round instead of a multi-sprint build"

### Round 工作方式

一个 round 的完整生命周期 (confirmed from `ORCHESTRATION.md` + `SKILL.md`):

```
1. initialize  → 解析输入, 写 input/state/progress artifacts
2. create team → TeamCreate + 3 teammates (planner/generator/evaluator)
3. planner     → SendMessage → 等待 planner_artifact → gate
4. preflight   → generator proposal (无 repo 编辑) → evaluator review
                  PASS + ready_to_generate → 继续
                  BLOCK + generator repair → 有界修复循环 (max 2 attempts)
                  BLOCK + planner / ESCALATE → unsupported_route, 停止
5. generator   → 实际 repo 工作 → generator_artifact → gate
6. evaluator   → 独立验证 → evaluator_artifact → gate
7. route       → PASS + converged → 成功
                  其他 canonical route → unsupported_route, 停止
8. summary     → 写 summary_artifact
9. teardown    → shutdown requests → TeamDelete
```

### 路由行为 (confirmed from routing-contract.md)

当前版本只支持一个成功终端路由: `converged`

其他 canonical routes (`continue`, `retry`, `return_to_planner`) 被识别但不自动重新调度:
- 记录在 state 中
- 转换到 `unsupported_route`
- 停止，不重新调度

---

## 5. Runtime 状态模型

### 当前可执行状态 (confirmed from `runtime/artifacts-and-state.md`)

```json
{
  "run_id": "<run_id>",
  "state": "initialized",
  "team_created": false,
  "planner_called": false,
  "preflight_called": false,
  "preflight_attempt_id": 1,
  "max_preflight_attempts": 2,
  "generator_called": false,
  "evaluator_called": false,
  "verdict": null,
  "route": null,
  "artifact_refs": {},
  "error_or_blocker": null
}
```

### 允许的状态值 (confirmed)

`initialized` → `team_created` → `planning` → `preflight_pending` → `ready_to_generate` → `generating` → `evaluating` → `converged` | `unsupported_route` | `stopped` | `failed`

### 规范性语义超集 (confirmed from `runtime-state-contract.md`)

比当前可执行子集更丰富，包含:
- `upstream_plan_ref`, `active_slice_ref`, `active_round_contract_ref` (身份三元组)
- `run_stop_condition` (驱动 continue vs converged 决策)
- `latest_preflight_result`, `latest_evidence_ref`, `latest_evaluation_verdict`
- `route_reason`, `convergence_reason`
- 更多状态: `intake_pending`, `planning_round`, `preflight_failed`, `awaiting_evaluation`, `routing`, `artifact_gate_failed`, `failed_upstream`

### Verdict 结构 (confirmed from evaluation-contract.md)

- `PASS`: deliverable 满足 round contract, 证据充分
- `RETRY`: 方向有效但结果不可接受, 可本地修复
- `BLOCK`: 必需条件缺失或违反
- `ESCALATE`: 当前 contract 不再是公平的评估框架

### Artifact 路径 (confirmed)

```
.pge-artifacts/<run_id>-input.md
.pge-artifacts/<run_id>-planner.md
.pge-artifacts/<run_id>-contract-proposal.md
.pge-artifacts/<run_id>-preflight.md
.pge-artifacts/<run_id>-generator.md
.pge-artifacts/<run_id>-evaluator.md
.pge-artifacts/<run_id>-state.json
.pge-artifacts/<run_id>-summary.md
.pge-artifacts/<run_id>-progress.md
```

---

## 6. Contract 体系

### 位置

运行时权威合约在 `skills/pge-execute/contracts/` 下 (confirmed)。顶层 `contracts/` 已被移除。

### 五个合约文件

**entry-contract.md**: 当前阶段不强制入口字段。Planner 负责规范化上游输入。

**round-contract.md**: Planner→Generator 的最小 handoff，包含 11 个字段:
goal, evidence_basis, design_constraints, in_scope, out_of_scope, actual_deliverable, verification_path, acceptance_criteria, required_evidence, stop_condition, handoff_seam

**evaluation-contract.md**: 定义 4 种 verdict (PASS/RETRY/BLOCK/ESCALATE) 的语义、触发条件、本地/升级性质、典型路由效果。包含 verdict 选择规则: "choose the narrowest verdict that explains the failure correctly"。

**routing-contract.md**: 定义 4 种 route (continue/converged/retry/return_to_planner) 的语义。包含 verdict→route 默认映射和 continue vs converged 决策规则 (基于 `run_stop_condition`)。当前阶段 continue/retry/return_to_planner 必须停在 `unsupported_route`。

**runtime-state-contract.md**: 规范性语义超集。定义状态身份三元组、最小状态集、允许的状态转换、转换规则。当前可执行子集在 `runtime/artifacts-and-state.md`。

---

## 7. 已实现 vs 骨架

### 真正实现的 (confirmed from code + artifacts)

| 功能 | 证据 |
|------|------|
| 插件打包 | `.claude-plugin/plugin.json` + `marketplace.json` 存在 |
| 本地安装脚本 | `bin/pge-local-install.sh` — 完整 Python 脚本，处理安装/卸载/legacy 清理 |
| 静态合约验证 | `bin/pge-validate-contracts.sh` — 243行 bash，检查文件存在/section 存在/pattern 匹配 |
| 三个 agent 定义 | `agents/pge-*.md` — 详细的角色定义、输入/输出字段、行为规则 |
| SKILL.md orchestration | 完整的执行协议定义 (7步)，但这是 **指令文档**，不是代码 |
| 合约体系 | 5个合约文件，定义完整的 verdict/route/state 语义 |
| Handoff 模板 | 5个 handoff 文件，定义调度文本/gate/路由行为 |
| 历史运行产物 | `.pge-artifacts/` 下有 3 个 run 的完整产物 (run-1776665033, run-1776666837, run-1776777707) |
| 证明运行记录 | `docs/proving/runs/run-001..005/` 有详细的运行记录 |

### 骨架/文档/未实现 (confirmed)

| 功能 | 状态 | 证据 |
|------|------|------|
| 自动多轮重新调度 | 未实现 | `SKILL.md`: "Not supported yet: automatic multi-round redispatch" |
| 有界 retry 循环 | 未实现 | `SKILL.md`: "Not supported yet: bounded retry loop" |
| return-to-planner 循环 | 未实现 | `SKILL.md`: "Not supported yet: return-to-planner loop" |
| 持久化运行恢复 | 仅设计 | `persistent-runner.md` 定义了恢复协议但未实现 |
| Evaluator 校准 fixtures | 未实现 | `SKILL.md`: "Not supported yet: evaluator calibration fixtures" |
| Product/spec planner 分离 | 未实现 | `SKILL.md`: "Not supported yet: product/spec planner split" |
| Marketplace 安装验证 | 未验证 | `ISSUES_LEDGER.md`: "Marketplace install path still unverified" |
| Checkpoint-driven recovery | 仅设计 | `ISSUES_LEDGER.md`: "defined but not yet enacted end-to-end" |
| 硬阈值 Evaluator 评分 | 未实现 | `execution-framework-lessons.md`: "richer graded criteria, hard thresholds, and calibration fixtures are still absent" |

### 关键观察

**PGE 没有运行时代码**。整个 repo 是 markdown 文档/合约/agent 定义。执行依赖 Claude Code 的 Agent Team 机制来解释 SKILL.md 中的指令并执行。没有 JavaScript/Python/Shell 运行时 (除了安装和验证脚本)。

这意味着:
- "执行" = Claude Code 读取 SKILL.md 并按指令操作
- "状态机" = Claude Code 按 ORCHESTRATION.md 中的规则写 JSON 文件
- "gate" = Claude Code 检查 artifact 文件是否包含必需 section
- "Agent Team" = Claude Code 原生 TeamCreate/SendMessage/TeamDelete API

---

## 8. 安装/运行方式

### `bin/pge-local-install.sh`

**功能** (confirmed from source):
- 读取 `.claude-plugin/plugin.json` 获取插件元数据
- 将 plugin payload 复制到 `~/.claude/dev-plugins/pge`
- 复制内容: `.claude-plugin/plugin.json`, `agents/*.md`, `skills/pge-execute/` 整个目录
- 计算 local build hash (SHA256 of all payload files)
- 在安装的 SKILL.md 中注入 `[local dev vX.Y.Z-<hash>]` 标记
- 清理 legacy 路径 (`~/.claude/skills/pge-execute`, `~/.claude/agents/pge-*.md`)
- 支持 `--uninstall` 模式

### `bin/pge-validate-contracts.sh`

**功能** (confirmed from source):
- 验证所有必需文件存在 (agents, skills, handoffs, contracts, design docs)
- 验证 SKILL.md 行数 ≤ 220
- 验证关键 pattern 存在 (合约权威声明, agent surface 解析, 执行流程等)
- 验证 Planner/Generator/Evaluator 的所有必需 section 存在
- 验证 preflight/evaluator 的 enum 值
- 验证不存在 stale pattern (旧的路由 schema 等)
- 纯静态检查，不执行实际运行

### 运行方式

```bash
# Marketplace 安装
/plugin marketplace add feng-y/pge
/plugin install pge@pge

# 本地开发安装
./bin/pge-local-install.sh

# 执行 smoke test
/pge-execute test

# 执行自定义任务
/pge-execute <task prompt>

# 验证合约
./bin/pge-validate-contracts.sh
```

---

## 9. 当前限制

### 运行时限制 (confirmed)

1. **单轮执行**: 只能执行一个 bounded round。`retry`, `continue`, `return_to_planner` 被识别但停在 `unsupported_route`。

2. **无运行时代码**: 整个执行依赖 Claude Code 解释 markdown 指令。没有确定性的状态机实现。Claude Code 的行为可能因 session 不同而有差异。

3. **无自动恢复**: 如果 team 丢失或 session 中断，没有自动恢复机制。`persistent-runner.md` 定义了恢复协议但未实现。

4. **Preflight 修复有限**: 最多 2 次 preflight 修复尝试 (`max_preflight_attempts: 2`)。超过后停止。

5. **无 Evaluator 校准**: 没有 false-positive/false-negative 校准 fixtures。Evaluator 的判断完全依赖 agent 的 prompt 理解。

6. **Marketplace 未验证**: 实际的 Claude Code marketplace 安装流程尚未端到端验证。

7. **Gate 是 structural 的**: artifact gate 只检查 section 是否存在，不检查内容质量。

### 架构限制 (inferred)

8. **Context window 依赖**: 长任务可能超出 agent 的 context window。虽然设计了 artifact-backed recovery，但当前未实现。

9. **无并行执行**: 所有阶段严格串行。

10. **Planner 不做完整 spec**: 有意比 Anthropic 文章中的 Planner 更窄 — 只做 "round shaper"，不做 "full product planner"。

11. **无 hard-threshold 评分**: Evaluator 使用叙述性判断而非量化阈值。与 Anthropic 文章中的 grading calibration 有差距。

12. **SKILL.md 接近大小限制**: `pge-validate-contracts.sh` 强制 SKILL.md ≤ 220 行。当前已接近上限。
