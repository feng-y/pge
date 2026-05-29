这版我把前面多轮讨论收敛成一个 **Codex/Claude Code 可执行任务书**：既说明为什么改，也说明怎么改、改到什么程度、哪些不能改、如何验收。

# PGE Research 重构任务书：从重型 Research Contract 改为轻量 Spec-Discovery Workflow

## 0. 执行对象

本任务用于重构 PGE repo 中的 `pge-research`，使其从当前偏重型、规则密集、合规化的 research contract，改为轻量但结构化的 spec-discovery / brainstorming workflow。

目标读者：

* Codex
* Claude Code
* 任何执行 PGE repo 修改的 coding agent

执行重点：

> 不要继续给 PGE 增加更多约束。
> 本任务的核心是大幅减少默认规则、默认字段、默认 gate，同时保留 Research 作为 Plan 前防错入口的能力。

---

# 1. 优化目标

## 1.1 核心目标

将 `pge-research` 重构为：

> Plan 前的轻量 spec-discovery / ambiguity-handling 阶段。

它应该大幅覆盖 Superpowers brainstorming / GSD discuss-phase 的核心能力：

1. 理解用户请求。
2. 必要时一次只问一个问题。
3. 澄清目标、范围、成功标准、约束。
4. 将粗糙想法收敛成更清晰的方向。
5. 探索更简洁路径和被拒绝路径。
6. 输出 right-sized handoff 给 `pge-plan`。

同时，针对 PGE 的复杂旧项目 / harness / repo-specific execution 场景，Research 额外增强：

1. 区分原始目标 A 和实现假设 B。
2. 在“理解模型 vs 实际实现”发生冲突时触发 Implementation Friction Gate。
3. 在“用户目标合理但当前 repo 无法直接渐进推进”时触发 Progressive Feasibility Gate。
4. 必要时使用 User Intent / AI Understanding / Code Reality / Architecture Intent 作为分析镜头。
5. 证据优先，但不是 repo 优先。
6. 输出新的 `research.v3` 协议，便于 Plan 后续消费。

---

## 1.2 一句话定义

新的 PGE Research：

```text
PGE Research is a lightweight spec-discovery workflow before Plan.

It clarifies the request enough for Plan by understanding goal, scope, success shape, constraints, and simplest direction.

For PGE’s legacy/harness-heavy scenarios, it additionally detects plan-affecting friction between task understanding and actual implementation reality, and detects when a valid user goal must first be staged because the repo is not structurally ready.
```

中文定义：

```text
PGE Research 是 Plan 前的轻量 spec-discovery 阶段。

它负责把用户请求澄清到足以进入 Plan：目标、范围、成功标准、约束、简洁方向。

针对 PGE 的复杂旧项目和 harness 场景，它额外识别两类风险：
1. 理解模型和实际实现存在会影响 Plan 的摩擦；
2. 用户目标本身合理，但当前 repo 结构不支持直接渐进式推进，需要先做结构准备。
```

---

# 2. 优化背景与重构原因

## 2.1 当前阶段基本判断

PGE 的主链路保持不变：

```text
Research → Plan → Exec → Review / Challenge → Ship
```

阶段职责也保持：

```text
Research: spec discovery / ambiguity handling / task-relevant reality discovery
Plan: executable contract
Exec: contract-constrained implementation
Review / Challenge: drift detection and quality gate
```

本次不是推翻 PGE 主流程，而是重构 Research 阶段的默认形态。

---

## 2.2 当前 Research 的问题

当前 `pge-research` 已经过重，混合了承担过多职责：

1. intent alignment
2. brainstorm
3. clarify / grill
4. zoom-out
5. upstream contract preservation
6. design surface capture
7. reality alignment proof
8. experience scope classification
9. interactive alignment proof
10. value proof
11. decision log
12. planning handoff constraints
13. route gate
14. STOP gate
15. full quality gate
16. strict compliance-oriented flow

这些能力单独看可能有价值，但组合后造成问题：

```text
Research 从“帮助 Plan 前澄清问题”
变成了“生产合规 research artifact”。
```

具体负面影响：

1. 字段过多，简单任务也被迫填模板。
2. gate 过密，模型优先满足流程而不是推进真实问题。
3. “ask is expensive” 压制了必要的用户澄清。
4. grill / brainstorming 被弱化成可跳过的说明。
5. repo evidence 被误用成 user intent evidence。
6. Research 容易滑向 Plan，提前决定 implementation approach。
7. 下游 Plan 仍然需要重新解释 Research 产物，因为 Research 输出太重但不够直接。
8. 对齐被拔得过高，像要一次性完成全局对齐，而不是处理会影响 spec 的关键差异。

---

## 2.3 正确问题重述

Research 要解决的不是“全局对齐”。

Research 要解决的是：

```text
在进入 Plan 前，是否存在会让 Plan 走错的目标、范围、成功标准、实现理解或结构可行性问题？
```

换句话说：

```text
Research 不是完成对齐。
Research 是提前发现并处理会让 spec 错掉的关键差异。
```

完整对齐是整个 spec workflow 的责任：

```text
Research: 防止明显错误目标 / 大歧义进入 Plan
Plan: 把目标和方向转成 executable spec
Exec: 保证实现不偏离 spec
Review: 检查实现/spec/原始目标之间的偏差
Challenge: 重新质疑 plan 或实现是否错解目标
```

---

# 3. 设计原则

## 3.1 减规则，不加规则

本次重构不是增加更多 checklist。

目标是：

```text
更少字段
更少 gate
更少默认证明
更强触发条件
更清晰 handoff
```

不要把本任务实现成：

```text
新增一层 research adapter
新增一层 validation gate
新增更多 route
新增更多 reference docs
新增更多 anti-pattern
```

---

## 3.2 保留 workflow graph，但删除重型合规 flow

不要删除 workflow graph。

Superpowers brainstorming 的价值之一就是它有稳定 workflow：理解上下文、一次一个问题、逐步澄清、形成设计/方向、用户确认。

所以 PGE Research 也需要 workflow graph。

但要替换当前重型合规 flow，改成轻量 spec-discovery workflow。

新的 Research workflow：

```text
START
  ↓
Understand request
  ↓
Classify:
  A = original goal / pain / desired outcome
  B = implementation hypothesis / proposed solution
  ↓
Is goal / success / scope clear enough?
  ├─ No → Ask one intent-discovery question
  └─ Yes → continue
  ↓
Collect task-relevant context
  - user context
  - repo/code reality
  - architecture intent if needed
  ↓
Check for Implementation Friction
  - expected understanding vs actual implementation
  - only if plan-affecting
  ↓
Check for Progressive Feasibility
  - can this goal be directly planned incrementally?
  - or must we first prepare repo structure?
  ↓
Explore simplest direction
  - recommended direction
  - rejected directions
  - constraints
  ↓
Can Plan safely proceed?
  ├─ missing user authority → NEEDS_USER
  ├─ missing repo evidence → NEEDS_REPO_EVIDENCE
  ├─ contradiction/blocker → BLOCKED
  └─ enough for Plan → READY_FOR_PLAN
  ↓
Write research.md
```

---

## 3.3 证据优先，但不是 repo 优先

核心规则：

```text
Evidence-first does not mean repo-first.
```

证据来源区分：

```text
User evidence proves user intent.
Repo evidence proves code reality.
Architecture docs / structure may support architecture intent.
Inference must be labeled.
Assumption must be labeled.
```

禁止：

```text
因为代码里有 X，所以用户真正想要的是 Y。
```

允许：

```text
用户目标是 Y；repo 现实显示 X 是当前约束；因此 goal 与 reality 的 gap 是 Z。
```

---

## 3.4 Research 不提前变成 Plan

Research 可以输出：

1. goal
2. success shape
3. constraints
4. relevant context
5. simplest direction
6. rejected directions
7. implementation friction
8. progressive feasibility staging instruction

Research 不应该输出：

1. vertical slices
2. target files as execution plan
3. final acceptance criteria
4. final verification path
5. implementation task list
6. method-level code instructions
7. detailed migration plan

边界：

```text
Research can recommend direction.
Plan selects approach and creates executable contract.
```

---

# 4. 新 Research 能力模型

## 4.1 默认能力：Spec Discovery

默认 Research 只做轻量 spec-discovery：

```text
用户想要什么？
成功是什么样？
范围是什么？
有什么不做？
有什么约束？
有没有更简单方向？
Plan 需要知道什么？
```

输出不应重。

---

## 4.2 条件增强一：Intent Discovery Trigger

触发条件：

1. 用户只给了实现方案 B，没有给真实目标 A。
2. 多个目标解释都合理。
3. 成功标准不可观察。
4. scope 边界会改变 Plan。
5. tradeoff 需要用户权威判断。
6. 用户请求是 workflow / architecture / design direction，但期望结果不清楚。

用户问题格式：

```text
我需要先确认真实目标：你真正要解决的是 A、B、C 里的哪一个？还是另一个目标？
我的默认判断是 X，因为 Y。
```

规则：

1. 一次只问一个问题。
2. 优先 multiple choice。
3. 带默认判断。
4. 最多连续问 2 个 blocking question。
5. 如果无法得到用户回答但能形成安全假设，记录 assumption。
6. 如果不能形成安全假设，route `NEEDS_USER`。

---

## 4.3 条件增强二：Implementation Friction Gate

### 定义

当 Research 形成的理解模型、预期架构或候选方向，与 repo / docs / runtime 的实际实现发生会影响 Plan 的冲突时，触发 Implementation Friction Gate。

核心判断：

```text
我以为系统是 A，
但实际实现是 B，
这个差异会改变 Plan。
```

### 触发信号

当 repo evidence 反驳以下任一 planning assumption，并且会影响 Plan 时触发：

1. expected entry point differs from actual entry point
2. expected owner/stage differs from actual owner/stage
3. expected schema/protocol differs from actual downstream consumption
4. expected architecture boundary differs from actual implementation
5. expected verification path is unavailable
6. expected small change actually touches multiple protocol consumers
7. current implementation contains compatibility or historical constraints that change the safe path
8. name / field meaning differs from actual behavior
9. docs claim one responsibility but skill/code implements another

### 不触发情况

不触发：

1. 命名不好但不影响 Plan。
2. 文档风格差异。
3. 代码组织丑但不影响本任务。
4. 只是可以优化，不是完成目标必须处理。
5. AI 想顺便重构。

判断标准：

```text
这个摩擦是否会改变 Plan？
不会 → 记录为普通 fact。
会 → 触发 Implementation Friction Gate。
```

### 输出格式

```md
## Conditional: Implementation Friction

- expected_understanding:
- actual_implementation_reality:
- conflict:
- why_it_matters_for_plan:
- required_plan_adjustment:
```

---

## 4.4 条件增强三：Progressive Feasibility Gate

### 定义

当用户目标合理，但当前 repo 的结构、接口协议、模块边界、验证能力不支持直接渐进式推进时，触发 Progressive Feasibility Gate。

它解决的问题：

```text
目标没错，但 repo 现在扛不住直接做。
必须先做结构准备，再推进最终目标。
```

### 触发信号

任一条件成立时触发：

1. 目标需要跨阶段或多模块接口协议调整。
2. 目标无法端到端验证。
3. 直接实现会造成结构性破坏。
4. 当前 repo 不具备承载目标的抽象边界。
5. 目标需要大规模同步修改多个 producer / consumer。
6. 目标混合多个不同性质的 change type。
7. 用户目标是最终态，但当前 repo 只能先做准备态。
8. 如果直接 Plan 最终目标，会导致大 scope、大风险、不可验证。

### 不触发情况

不触发：

1. 跨多个文件但协议不变。
2. 有清晰验证路径。
3. 可以通过一个 vertical slice 端到端完成。
4. 大批量机械改动且可 grep 验证。
5. 只是代码丑，但不影响目标推进。

判断标准：

```text
能否形成一个小的、可验证的、不会破坏结构的第一轮 Plan？
不能 → 触发。
```

### 输出格式

```md
## Conditional: Progressive Feasibility

- direct_goal:
- direct_planning_risk:
- structural_blocker:
- first_plannable_objective:
- deferred_goal_parts:
- plan_instruction:
```

### 关键规则

Research 不要写完整分期计划。

Research 只告诉 Plan：

```text
不要直接 plan 最终目标。
先 plan 第一个可安全执行的结构准备目标。
```

---

# 5. 新协议：research.v3

## 5.1 协议目标

`research.v3` 应该比旧协议更轻：

```text
少字段
强语义
条件增强
方便 Plan 消费
不鼓励模板填充
不鼓励 Research 越权到 Plan
```

---

## 5.2 Base Schema

新 Research artifact 默认使用：

```md
# Research

schema_version: research.v3
route: READY_FOR_PLAN | NEEDS_USER | NEEDS_REPO_EVIDENCE | BLOCKED

## 1. Spec Discovery
- user_request:
- goal:
- success_shape:
- scope:
- non_goals:
- constraints:

## 2. Context
- relevant_user_context:
- relevant_repo_or_architecture_context:
- assumptions:

## 3. Direction
- simplest_direction:
- rejected_directions:
- why_this_is_enough_for_plan:

## 4. Open Questions
- blocking_questions:
- non_blocking_questions:

## 5. Route
- route:
- route_reason:
```

---

## 5.3 Conditional Sections

只有触发时才添加。

### Implementation Friction

```md
## Conditional: Implementation Friction

- expected_understanding:
- actual_implementation_reality:
- conflict:
- why_it_matters_for_plan:
- required_plan_adjustment:
```

### Progressive Feasibility

```md
## Conditional: Progressive Feasibility

- direct_goal:
- direct_planning_risk:
- structural_blocker:
- first_plannable_objective:
- deferred_goal_parts:
- plan_instruction:
```

### Optional Four-Way Gap

只有当 Implementation Friction 难以表达清楚时使用，不是默认字段。

```md
## Optional: Four-Way Gap

- user_intent:
- ai_understanding:
- code_reality:
- architecture_intent:
- planning_risk_if_ignored:
```

重要：

```text
Four-way gap 是分析镜头，不是默认模板。
Implementation Friction 是触发器。
Progressive Feasibility 是分批推进触发器。
```

---

## 5.4 Route 语义

### READY_FOR_PLAN

条件：

1. goal 足够清楚；
2. success_shape 足够可观察；
3. scope / non_goals 足够明确；
4. Plan 所需 context 足够；
5. open questions 不阻塞 Plan；
6. 如果存在 implementation friction，已经记录 required_plan_adjustment；
7. 如果存在 progressive feasibility，已经给出 first_plannable_objective。

### NEEDS_USER

用于：

1. 目标需要用户确认；
2. scope 需要用户选择；
3. success shape 需要用户定义；
4. tradeoff 必须由用户决定；
5. 没有用户回答无法安全进入 Plan。

### NEEDS_REPO_EVIDENCE

用于：

1. 用户目标清楚；
2. 但 repo/code/docs/runtime reality 不足；
3. Plan 无法安全选择方向。

### BLOCKED

用于：

1. 必需来源不可用；
2. 上下文矛盾无法解决；
3. 目标、现实、约束之间存在无法安全推进的冲突。

---

# 6. Research 与 Plan 的协议变更

## 6.1 Plan 后续需要适配 research.v3

`pge-plan` 不需要大重构，但必须能消费 research.v3。

Plan 应支持：

```text
research.v2 legacy artifacts
research.v3 new artifacts
```

## 6.2 字段映射

| Plan 需要                     | research.v3 来源                                      |
| --------------------------- | --------------------------------------------------- |
| goal                        | `Spec Discovery.goal`                               |
| success shape               | `Spec Discovery.success_shape`                      |
| scope                       | `Spec Discovery.scope`                              |
| non-goals                   | `Spec Discovery.non_goals`                          |
| constraints                 | `Spec Discovery.constraints`                        |
| assumptions                 | `Context.assumptions`                               |
| repo / architecture context | `Context.relevant_repo_or_architecture_context`     |
| candidate direction         | `Direction.simplest_direction`                      |
| rejected approaches         | `Direction.rejected_directions`                     |
| planning readiness          | `Route.route` + `Route.route_reason`                |
| blocking uncertainty        | `Open Questions.blocking_questions`                 |
| non-blocking uncertainty    | `Open Questions.non_blocking_questions`             |
| required Plan adjustment    | `Implementation Friction.required_plan_adjustment`  |
| first plannable objective   | `Progressive Feasibility.first_plannable_objective` |
| deferred work               | `Progressive Feasibility.deferred_goal_parts`       |

---

## 6.3 Plan 必须遵守的适配规则

### Rule 1: Do not treat simplest_direction as final approach

Research 的 `simplest_direction` 是候选方向，不是 Plan 的最终 selected approach。

Plan 仍然要做 engineering review。

### Rule 2: Progressive Feasibility overrides direct goal planning

如果 Research 输出 Progressive Feasibility，Plan 不应该直接 plan 最终目标。

Plan 应该计划：

```text
first_plannable_objective
```

不是：

```text
direct_goal
```

### Rule 3: Implementation Friction must affect Plan

如果 Research 输出 Implementation Friction，Plan 必须处理：

```text
required_plan_adjustment
```

不能忽略。

### Rule 4: Missing goal/success/scope returns to Research

如果 research.v3 缺少：

1. goal
2. success_shape
3. scope
4. route READY_FOR_PLAN

Plan 不应自行脑补，应返回 Research 或 route NEEDS_USER。

---

# 7. 当前代码反模式条款

本次重构要删除、压缩或降级以下反模式。

## 7.1 反模式：Research 变成 Plan 前置版

表现：

1. Research 选择 final implementation approach。
2. Research 写 detailed planning handoff。
3. Research 输出 target files / issues / verification。
4. Research 实际上已经完成 Plan。

处理：

```text
Research 只输出 direction，不输出 executable contract。
```

---

## 7.2 反模式：模板字段多于判断

表现：

1. 所有任务都要填大量 mandatory fields。
2. 简单任务也生成长 research.md。
3. 产物像合规材料，不像 Plan handoff。

处理：

```text
改为 research.v3 base schema + conditional sections。
```

---

## 7.3 反模式：Grill 被 ask-is-expensive 压制

表现：

1. 用户目标不清时继续读 repo。
2. 用 repo reality 代替用户目标确认。
3. 写 no-question rationale 逃逸。

处理：

```text
用户目标不清时，优先问一个 intent-discovery question。
读 repo 不能证明用户 intent。
```

---

## 7.4 反模式：证据优先被误读成 repo 优先

表现：

1. 一开始读代码。
2. 以代码结构解释用户目标。
3. 忽略用户的真实动机和成功形态。

处理：

```text
User evidence proves intent.
Repo evidence proves reality.
```

---

## 7.5 反模式：四方 gap 默认化

表现：

1. 所有任务都写 User / AI / Code / Architecture。
2. 轻量任务也被拖进大对齐。
3. Research 产物过重。

处理：

```text
Four-way gap 只作为 optional diagnostic lens。
默认不输出。
```

---

## 7.6 反模式：全仓库地图化

表现：

1. 为了 zoom-out 读太多文件。
2. 输出架构地图但不改变 Plan。
3. Research 像架构文档。

处理：

```text
只读 task-relevant context。
如果多读一个文件不会改变 goal/direction/route，就停止。
```

---

## 7.7 反模式：Design surface 默认化

表现：

1. 所有任务都要 experience_scope。
2. 内部工程任务也被套体验设计字段。
3. Research 需要判断 audience / disappointment / interaction 等。

处理：

```text
删除默认 design surface 字段。
仅在人类可见 artifact / UI / HTML / 文档 / report / prompt 输出任务中用 optional design note。
```

---

## 7.8 反模式：Reality alignment proof 过重

表现：

1. 所有任务都要 proof row/status。
2. Research 为了证明“我没猜”生成合规材料。
3. Plan 反而难消费。

处理：

```text
删除默认 reality_alignment_proof。
用 Context / assumptions / open_questions / conditional friction 代替。
```

---

## 7.9 反模式：目标不适合直接做，但仍硬 Plan

表现：

1. 用户目标合理，但会影响多阶段协议。
2. 无法端到端验证。
3. 直接改会破坏结构。
4. 仍然一次性生成完整计划。

处理：

```text
触发 Progressive Feasibility Gate。
Research 输出 first_plannable_objective。
Plan 只 plan 第一批结构准备目标。
```

---

# 8. 优化前后能力对齐表

| 当前能力 / 字段 / 规则                 | 优化后处理                                 | 原因                           | 是否由 Plan/Exec 补充                  |
| ------------------------------ | ------------------------------------- | ---------------------------- | --------------------------------- |
| research.v2                    | 改为 research.v3                        | 协议过重，需要轻量化                   | Plan 兼容 v2/v3                     |
| intent_framings                | 删除默认，必要时进入 Open Questions / Direction | 不应每次多 framing                | 不补                                |
| confirmed_intent               | 改为 `goal`                             | 更直接                          | Plan 消费                           |
| scope_contract                 | 改为 `scope / non_goals / constraints`  | contract 语言过重                | Plan 转正式 scope                    |
| success_shape                  | 保留                                    | spec discovery 核心            | Plan 转 acceptance                 |
| experience_scope               | 删除默认                                  | 不适合内部工程任务                    | 体验任务 Plan 可补                      |
| design_surface_context         | 删除默认                                  | 不应污染 Research                | 体验任务可 optional                    |
| upstream_contract              | 降级为 relevant context                  | 不应默认 preservation            | Plan 负责 contract preservation     |
| evidence                       | 保留但简化                                 | 证据优先仍重要                      | Plan 消费 assumptions/context       |
| reality_alignment_proof        | 删除默认                                  | 太重                           | Review/Plan 可处理关键证据               |
| ambiguities                    | 改为 blocking / non-blocking questions  | 更易消费                         | Plan 判断是否返回 Research              |
| interactive_alignment          | 删除默认                                  | 容易成为逃逸说明                     | 只记录真实提问                           |
| planning_handoff               | 删除默认                                  | Research 不做 detailed handoff | Plan 用 research.v3 直接消费           |
| known_invalid_directions       | 改为 rejected_directions                | 保留有价值信息                      | Plan 转 rejected approaches        |
| likely_affected_areas          | 删除默认                                  | 容易滑入 Plan                    | Plan 负责 target areas              |
| verification_risks             | 删除默认                                  | verification 属于 Plan         | Plan 负责                           |
| design_experience_constraints  | 删除默认                                  | 场景化能力                        | 体验任务后续补                           |
| route                          | 保留并简化                                 | 阶段交接需要                       | Plan 消费                           |
| READY_FOR_PLAN                 | 保留                                    | 正常进入 Plan                    | Plan 入口                           |
| NEEDS_INFO                     | 改为 NEEDS_USER / NEEDS_REPO_EVIDENCE   | 更清晰                          | Plan 兼容旧值                         |
| BLOCKED                        | 保留                                    | 无法推进                         | 不补                                |
| early_exit mode                | 删除 route 化                            | 不需要独立模式                      | 不补                                |
| superpowers_brainstorming mode | 不作为 route，作为 workflow 基础              | 避免模式膨胀                       | 不补                                |
| zoom-out                       | 收敛为 task-relevant context             | 避免全仓库地图                      | 不补                                |
| value proof                    | 删除                                    | 自证废话                         | 不补                                |
| decision log                   | 删除默认                                  | Research 不做复杂决策              | Plan 可保留 key decision             |
| full quality gates             | 删除                                    | Research 不应合规化               | Plan/Review 负责 gate               |
| grill brief                    | 改为 intent-discovery question          | 更稳定                          | pge-challenge 可做深度 grill          |
| anti-pattern list              | 大幅压缩                                  | skill 不应堆哲学                  | 设计文档可保留                           |
| references mandatory read      | 删除默认                                  | 主 skill 应自包含                 | 不补                                |
| ask is expensive               | 改写                                    | 不能压制目标澄清                     | 不补                                |
| Research must not plan         | 保留                                    | 阶段边界正确                       | Plan 负责                           |
| Research may recommend framing | 保留为 simplest_direction                | 有助于 Plan 收敛                  | Plan 正式选择 approach                |
| Implementation Friction        | 新增 conditional gate                   | 解决理解与实现冲突                    | Plan 必须处理 adjustment              |
| Progressive Feasibility        | 新增 conditional gate                   | 解决目标无法直接渐进推进                 | Plan 计划 first_plannable_objective |
| Four-way gap                   | 改为 optional diagnostic lens           | 不是默认大对齐                      | 不补                                |

---

# 9. 执行路径

## Slice 1: Rewrite `skills/pge-research/SKILL.md`

### 目标

将当前 `pge-research` 重写为轻量 spec-discovery workflow。

### 修改要求

1. 保留 workflow graph，但改为轻量 graph。
2. 删除重型 mandatory fields。
3. 删除默认 reality proof / design surface / experience scope。
4. 删除强制 reference reads。
5. 增加 A/B 区分：

   ```text
   A = original goal / pain / desired outcome
   B = implementation hypothesis / proposed solution
   ```
6. 增加 Intent Discovery Trigger。
7. 增加 Implementation Friction Gate。
8. 增加 Progressive Feasibility Gate。
9. 增加 research.v3 schema。
10. 明确 Research 不输出 executable contract。

### 验收

1. `pge-research/SKILL.md` 明显变短。
2. 默认输出字段只有 research.v3 base schema。
3. conditional sections 只在触发时出现。
4. workflow graph 覆盖 brainstorming 能力。
5. 没有恢复旧的 heavy proof/gate 结构。

---

## Slice 2: Update `README.md`

### 目标

更新公开主流程说明，使 Research 定义与 research.v3 一致。

### 修改要求

1. 保留 `Research → Plan → Exec` 主链路。
2. 将 Research 描述改为：

   ```text
   lightweight spec-discovery / ambiguity-handling before Plan
   ```
3. 删除旧 research.v2 重字段列表。
4. 说明 Research 输出：

   ```text
   goal, success shape, scope, constraints, context, direction, open questions, route
   ```
5. 说明 conditional gates：

   ```text
   Implementation Friction
   Progressive Feasibility
   ```
6. 不扩展 Plan/Exec 说明。

### 验收

1. README 不再要求旧 research.v2 默认字段。
2. README 不再把 Research 描述成重型对齐合同。
3. README 说明 Plan 消费 research.v3。

---

## Slice 3: Update `CLAUDE.md`

### 目标

更新 repo-level agent guidance，避免与新 Research 定义冲突。

### 修改要求

1. Research ownership 改为：

   ```text
   Research owns lightweight spec discovery: goal, success shape, scope, constraints, task-relevant context, direction, and route.
   ```
2. 增加：

   ```text
   Research may use Implementation Friction / Progressive Feasibility only when triggered.
   ```
3. 删除旧字段强绑定。
4. 保留 stage boundary。
5. 保留不要盲目改动 active workflow contract 的原则。

### 验收

1. CLAUDE.md 不再要求旧 research.v2 默认字段。
2. 不再压制必要的 intent-discovery question。
3. 不引入新的大规则组。

---

## Slice 4: Add minimal research.v3 adapter in `skills/pge-plan/SKILL.md`

### 目标

让 Plan 可以消费 research.v3，但不要大幅重构 Plan。

### 修改要求

1. 新增 short section：Research Input Adapter。
2. 支持 `research.v2` legacy 和 `research.v3`。
3. 映射字段：

   * goal
   * success_shape
   * scope
   * constraints
   * assumptions
   * simplest_direction
   * rejected_directions
   * blocking_questions
   * implementation friction adjustment
   * progressive feasibility first_plannable_objective
4. 如果 research.v3 route 不是 READY_FOR_PLAN，Plan 不应继续。
5. 如果 Progressive Feasibility 存在，Plan 应计划 `first_plannable_objective`，不是直接计划 `direct_goal`。
6. 如果 Implementation Friction 存在，Plan 必须处理 `required_plan_adjustment`。

### 验收

1. Plan 不再要求 `planning_handoff`。
2. Plan 不再要求 `reality_alignment_proof`。
3. Plan 能接受 research.v3。
4. Plan 不把 `simplest_direction` 当最终 selected approach。
5. Plan 不忽略 conditional gates。

---

## Slice 5: Search and repair active protocol drift

### 搜索关键词

```bash
grep -R "research.v2\|intent_framings\|scope_contract\|experience_scope\|design_surface_context\|reality_alignment_proof\|interactive_alignment\|planning_handoff\|ready_for_plan_basis\|plan_blocking_gaps\|NEEDS_INFO" -n .
```

### 处理原则

1. 如果在 active authoritative docs / skills 中要求旧字段为默认行为，更新。
2. 如果在历史文档、旧任务 artifact、example 中出现，不要大规模清理。
3. 如果是 Plan legacy compatibility，可保留但标注 legacy。
4. 不要为了“全仓库干净”扩大 scope。

### 验收

1. active workflow 不再强制旧 research.v2 默认字段。
2. 所有 remaining legacy references 都是兼容或历史用途。
3. 没有引入新大规模文档重写。

---

# 10. 建议的新 `pge-research/SKILL.md` 骨架

可以作为实现参考，不要求逐字照抄。

```md
---
name: pge-research
description: >
  Use before pge-plan when the task's goal, success shape, scope, constraints, or task-relevant repo/architecture context is not clear enough to plan safely.
  PGE Research is a lightweight spec-discovery workflow, not a heavy research contract.
version: 0.3.0
argument-hint: ""
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---

# PGE Research

Prevent unclear or unsafe tasks from entering Plan.

Research performs lightweight spec discovery:
- understand the request
- clarify goal, scope, success shape, and constraints
- ask one question at a time when needed
- gather task-relevant repo/architecture context
- recommend the simplest direction
- route to Plan or stop with a clear reason

Research does not create executable implementation plans.

## Workflow

START
  -> Understand request
  -> Separate original goal A from implementation hypothesis B
  -> If goal/success/scope is unclear, ask one intent-discovery question
  -> Collect task-relevant context
  -> If expected understanding conflicts with actual implementation in a plan-affecting way, record Implementation Friction
  -> If the goal cannot be safely planned as a direct incremental change, record Progressive Feasibility
  -> Explore simplest direction and rejected directions
  -> Route READY_FOR_PLAN / NEEDS_USER / NEEDS_REPO_EVIDENCE / BLOCKED
  -> Write research.md

## A/B distinction

A = original goal, pain, desired outcome, or success shape.
B = implementation hypothesis, proposed solution, technical framing, or preferred path.

Do not let B replace A unless the user explicitly chooses it.

## Intent Discovery Trigger

Ask one question when:
- user gives a solution but not the underlying goal
- multiple goals are plausible
- success shape is not observable
- scope would change the plan
- tradeoff requires user authority
- workflow / architecture / design direction is requested but desired outcome is unclear

Ask one question at a time. Prefer multiple choice. Include a default read.

## Evidence rule

Evidence-first does not mean repo-first.

- User evidence proves user intent.
- Repo evidence proves code reality.
- Architecture docs or structure may support architecture intent.
- Inference must be labeled.
- Assumption must be labeled.

Repo evidence cannot prove user intent.

## Implementation Friction Gate

Trigger when repo/doc/runtime evidence contradicts the current task understanding or expected architecture in a way that may affect Plan.

Examples:
- expected entry point differs from actual entry point
- expected owner/stage differs from actual owner/stage
- expected schema/protocol differs from downstream consumption
- expected verification path is unavailable
- expected small change touches multiple protocol consumers
- actual implementation has compatibility constraints that change the safe path

Output only when triggered:

## Conditional: Implementation Friction
- expected_understanding:
- actual_implementation_reality:
- conflict:
- why_it_matters_for_plan:
- required_plan_adjustment:

## Progressive Feasibility Gate

Trigger when the user goal is valid but cannot be safely planned as a direct incremental change because the repo is not structurally ready.

Examples:
- cross-stage or multi-module protocol change
- no reliable end-to-end verification
- direct implementation would cause structural breakage
- repo lacks the boundary needed to support the target change
- large synchronized producer/consumer edits are required
- the goal mixes multiple change types that should be staged

Output only when triggered:

## Conditional: Progressive Feasibility
- direct_goal:
- direct_planning_risk:
- structural_blocker:
- first_plannable_objective:
- deferred_goal_parts:
- plan_instruction:

## Output: research.v3

Write `.pge/tasks-<slug>/research.md`.

# Research

schema_version: research.v3
route: READY_FOR_PLAN | NEEDS_USER | NEEDS_REPO_EVIDENCE | BLOCKED

## 1. Spec Discovery
- user_request:
- goal:
- success_shape:
- scope:
- non_goals:
- constraints:

## 2. Context
- relevant_user_context:
- relevant_repo_or_architecture_context:
- assumptions:

## 3. Direction
- simplest_direction:
- rejected_directions:
- why_this_is_enough_for_plan:

## 4. Open Questions
- blocking_questions:
- non_blocking_questions:

## 5. Route
- route:
- route_reason:

## Route rules

READY_FOR_PLAN:
- goal, success shape, scope, and constraints are clear enough for Plan
- task-relevant context is sufficient
- blocking questions are empty
- any Implementation Friction has required_plan_adjustment
- any Progressive Feasibility has first_plannable_objective

NEEDS_USER:
- user authority is required for goal, scope, success shape, or tradeoff

NEEDS_REPO_EVIDENCE:
- goal is clear but repo/architecture context is insufficient

BLOCKED:
- required source is unavailable or contradictions prevent safe planning

## Hard boundaries

Research must not:
- select final implementation approach
- create vertical slices
- define final acceptance criteria
- define final verification path
- output code or pseudocode
- silently narrow user scope
- route READY_FOR_PLAN when B replaced A without confirmation
```

---

# 11. 验收测试场景

用这些场景检查新 Research 是否符合目标。

## Case 1: 用户只给实现方案

输入：

```text
帮我做一个 MCP
```

期望：

1. Research 不直接研究 MCP。
2. 先问 intent-discovery question。
3. 问题应该类似：

   ```text
   你真正要解决的是手机远程控制、session 持续、工具接入，还是别的目标？
   ```

---

## Case 2: 简单明确任务

输入：

```text
把 README 里 Research 的字段列表改成 research.v3
```

期望：

1. Research 不生成长文。
2. 不触发四方 gap。
3. 不触发 Progressive Feasibility。
4. 输出短 research.v3 或直接 READY_FOR_PLAN brief。

---

## Case 3: 理解与实现冲突

输入：

```text
删除 planning_handoff，Research 不需要这个字段了
```

repo evidence 发现：

```text
pge-plan 仍消费 planning_handoff
```

期望：

1. 触发 Implementation Friction。
2. 输出：

   * expected_understanding
   * actual_implementation_reality
   * conflict
   * why_it_matters_for_plan
   * required_plan_adjustment
3. 不直接建议硬删字段。
4. Plan 后续应做 compatibility adapter。

---

## Case 4: 目标合理但不能直接渐进推进

输入：

```text
把 research 全面改成轻量协议，删除旧字段，更新 plan/exec/review
```

期望：

1. 触发 Progressive Feasibility。
2. 指出 direct goal 太大。
3. 指出 structural blocker：

   * 多阶段协议消费者
   * 无完整端到端验证
   * 直接删除可能破坏 Plan
4. 给出 first_plannable_objective：

   ```text
   先让 research.v3 在 pge-research 中成为新协议，并让 pge-plan 兼容消费。
   ```
5. defer：

   * 全量旧文档清理
   * exec/review 大重构
   * 完整端到端 workflow redesign

---

## Case 5: 架构边界模糊

输入：

```text
Research 里加入 verification risk，避免后续执行失败
```

期望：

1. Research 判断 verification 属于 Plan 主责。
2. 如果现有 Research 已有 verification_risks 字段，触发 Implementation Friction 或 Direction note。
3. 输出 simplest_direction：

   ```text
   Research 只保留可能影响 Plan 的 context/constraint；Plan 定义 verification。
   ```

---

# 12. 验证方法

## 12.1 静态检查

执行 grep：

```bash
grep -R "research.v2\|intent_framings\|scope_contract\|experience_scope\|design_surface_context\|reality_alignment_proof\|interactive_alignment\|planning_handoff\|ready_for_plan_basis\|plan_blocking_gaps\|NEEDS_INFO" -n .
```

检查：

1. active docs 不再强制旧字段。
2. Plan 只以 legacy compatibility 方式接受旧字段。
3. README / CLAUDE.md / pge-research 不冲突。

---

## 12.2 协议一致性检查

确认：

1. `pge-research/SKILL.md` 定义 research.v3。
2. `README.md` 描述 research.v3。
3. `CLAUDE.md` 不要求 research.v2 字段。
4. `pge-plan/SKILL.md` 能消费 research.v3。
5. route vocabulary 一致：

   ```text
   READY_FOR_PLAN / NEEDS_USER / NEEDS_REPO_EVIDENCE / BLOCKED
   ```

---

## 12.3 行为检查

用第 11 节的五个测试场景手动检查。

重点不是跑测试，而是确认：

1. Research 会问该问的问题。
2. Research 不在不该问时过度问。
3. Research 能识别理解与实现摩擦。
4. Research 能识别目标无法直接渐进推进。
5. Research 输出足够 Plan 消费，但没有提前变成 Plan。

---

# 13. 执行禁令

本任务明确禁止：

1. 不重构 Exec。
2. 不重构 Review / Challenge。
3. 不新增 agent。
4. 不新增大量 references。
5. 不把 research.v3 再扩成重型协议。
6. 不做全仓库历史文档清理。
7. 不把 Four-way Gap 设为默认字段。
8. 不把 Implementation Friction / Progressive Feasibility 变成每次必填。
9. 不让 Research 输出 issue / acceptance / verification。
10. 不用“完整性”作为扩大 scope 的理由。

---

# 14. 最终执行指令

请按以下主线执行：

```text
Refactor PGE Research into a lightweight spec-discovery workflow before Plan.

Preserve a clear brainstorming-style workflow graph.
Remove heavy default contract fields and proof gates.
Add research.v3 base schema.
Add conditional Implementation Friction Gate.
Add conditional Progressive Feasibility Gate.
Update README and CLAUDE.md to match.
Add minimal pge-plan adapter for research.v3.
Do not redesign Plan or Exec.
Do not add new gates beyond the two conditional gates.
Do not make four-way gap mandatory.
```

执行顺序：

```text
1. Rewrite skills/pge-research/SKILL.md.
2. Update README.md Research protocol.
3. Update CLAUDE.md Research ownership.
4. Add minimal research.v3 adapter to skills/pge-plan/SKILL.md.
5. Grep old research.v2 field references.
6. Repair only active authoritative drift.
7. Validate using the five behavior scenarios.
```

Stop condition：

```text
PGE repo clearly defines research.v3 as the new Research protocol;
pge-research is lightweight and workflow-driven;
pge-plan can consume research.v3;
active authoritative docs no longer require old research.v2 heavy fields;
Research still covers brainstorming behavior and can detect implementation friction / progressive feasibility when triggered.
```

---

# 15. 最终判断标准

本次重构成功的标准不是“Research 更完整”。

成功标准是：

```text
Research 更短。
Research 更稳定。
Research 更容易触发必要澄清。
Research 不再过度证明自己。
Research 能把真正影响 Plan 的差异提前暴露。
Research 能在目标过大时把第一批可规划目标交给 Plan。
```

一句话：

```text
PGE Research should help Plan start correctly, not become a second Plan.
```
