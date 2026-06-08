# pge-plan 最终一致性方案

## 文档定位

这份文档是 `pge-plan` 改造的**最终一致性设计方案**，用于结束方案阶段并作为后续实现/评审的单一设计依据。

它不是实现说明，也不是补丁清单。它的目标是把已经收敛的设计决议整理成一个**闭合的 contract 方案**。

配套输入文档：

- `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md`
- `docs/exec-plans/pge-plan-change-allowlist-denylist.md`
- `docs/exec-plans/pge-plan-safe-refactor-backlog.md`
- `docs/exec-plans/pge-plan-responsibility-realignment-plan.md`

---

## 1. 设计目标

在**不改变现有 canonical producer / consumer / validator 契约**的前提下，把 `pge-plan` 重组为一个更清楚的 **single compound planning surface**，明确分层：

1. inherited problem contract
2. executable solution design
3. plan hardening
4. issue packaging
5. final execution authorization

这次改造的目标不是把 `pge-plan` 变轻，而是把它在**不损伤质量护栏、可审计性、下游消费稳定性**的前提下，变得更清楚、更一致、更可维护。

---

## 2. 不变的外部契约

### 2.1 已证实的当前现实

- `pge-plan` 当前是 canonical producer，直接产出 `.pge/tasks-<slug>/plan.md` 与 `issues/Ixxx.md`。见 `skills/pge-plan/SKILL.md`。
- `pge-exec` 当前消费 `plan_gate PASS + Exec Allowed: yes` 与 `issue_file_plan` shape。见 `skills/pge-exec/SKILL.md`。
- `pge-review` 当前以 `plan.md` 为 alignment source，读取 plan contract-bearing fields、issue files、Plan Engineering Review 等。见 `skills/pge-review/SKILL.md`。
- `templates/plan.md` 当前已经是“必填 contract 面 + optional when useful 的质量面”的最近似 canonical scaffold。见 `skills/pge-plan/templates/plan.md`。

### 2.2 本方案的强约束

本次改造**不改变**：

1. `schema_version: plan.v2`
2. `plan_gate` 命名
3. `issue_file_plan` canonical shape
4. `pge-plan` 作为 canonical producer 的地位
5. `pge-exec` 作为 canonical consumer 的入口
6. `pge-review` 以 canonical plan 为主要对齐源的方式

### 2.3 这次改造不是什么

本方案不是：

- 新增独立 `/spec` stage
- 新增独立 `/tasks` stage
- 新增 persisted `reality-extraction.md` / `analysis.md`
- producer / consumer / schema migration

本方案是：

> 在既有 canonical contract 不动的前提下，重组 `pge-plan` 的内部职责、显式面、升级路径与 hardening 机制。

---

## 3. Stage authority 最终定义

### 3.1 `pge-research`

`pge-research` 负责 **problem contract discovery / intent alignment**，产出 `research.v3`。

它负责：

- `goal`
- `success_shape`
- `scope`
- `non_goals`
- `constraints`
- blocker / friction / feasibility boundary
- open questions
- route to plan or clarification

它不负责：

- final implementation approach
- final issue slicing
- final verification path
- execution contract packaging

### 3.2 `pge-plan`

`pge-plan` 负责 **executable solution design**。

它负责：

- selected approach
- rejected approaches
- issue slicing
- execution ordering
- verification topology
- migration / rollout sequencing
- risk exposure
- execution ergonomics
- canonical plan packaging
- final execution authorization via `plan_gate`

它不负责：

- renewed problem discovery
- silent rewrite Research problem contract
- code implementation
- line-level implementation pseudocode（除非 public/protocol contract 强制要求）

### 3.3 `pge-exec`

`pge-exec` 只消费 passed canonical plan，并在 run context 下做 bounded implementation。

它不是：

- problem discovery stage
- plan repair author
- schema normalization stage

### 3.4 `pge-review` / `pge-challenge`

它们负责：

- semantic alignment review
- correctness / drift / robustness / proof pressure

它们不是：

- planning producer
- execution producer

### 3.5 核心边界

Plan 可以重做“怎么实现”，但不能 silent 改写“到底在解决什么问题”。

---

## 4. `pge-plan` 的最终内部结构

`pge-plan` 保持**单一 compound surface**，但内部明确分为 5 层：

1. **Input adaptation**
2. **Solution design**
3. **Plan hardening**
4. **Execution packaging**
5. **Final authorization**

注意：

- 这是**内部分层**，不是新增 5 个 protocol stages。
- 这些层不会产生新的 canonical artifact。

### 4.1 Layer 1: Input adaptation

负责把不同来源的输入收成一个当前可规划的 planning context。

支持 4 类入口：

1. direct prompt
2. `research.v3`
3. explicit external plan / fast-adopt
4. bare invocation

### 4.2 Layer 2: Solution design

负责从 inherited problem contract 出发，形成 executable approach。

输出至少明确：

- `selected_approach`
- `rejected_approaches`
- `target_areas`
- `forbidden_areas`
- `issues`
- `acceptance`
- `verification`
- `evidence_required`
- `terminal_conditions`

### 4.3 Layer 3: Plan hardening

保留一个统一的 **`Plan Engineering Review`** surface。

它负责：

- 检查 selected approach 是否真的可执行
- 找出 scope drift、隐性 assumption、弱 verification、rollout / coupling / validator 风险
- 改善 slicing、verification、evidence、boundary clarity
- 降低 Exec friction

它不是：

- route authority
- final execution gate
- 独立 planning stage

### 4.4 Layer 4: Execution packaging

`pge-plan` 继续直接产出：

- `.pge/tasks-<slug>/plan.md`
- `issues/Ixxx.md`
- optional `workflow-handoff.md`

不新增 `/spec` stage。

### 4.5 Layer 5: Final authorization

正式 route authority 只保留两处：

1. `source_contract_check`
2. `plan_gate`

其中：

- `source_contract_check` 决定输入能否进入 planning
- `plan_gate` 决定能否进入 execution

---

## 5. Formal route / clarification contract

### 5.1 Canonical route authority

`pge-plan` 中只有两处拥有 **formal route authority**：

1. `source_contract_check`
2. `plan_gate`

任何最终 route 必须落盘到这两者之一。

允许的最终 route 仍为：

- `READY_FOR_EXECUTE`
- `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`
- `RETURN_TO_RESEARCH`
- `NEEDS_INFO`
- `NEEDS_HUMAN`
- `BLOCKED`

### 5.2 中途发现 blocker 时如何处理

中间 surface——包括：

- `Plan Engineering Review`
- `Self-Evaluation`
- final sanity
- other hardening checks

可以：

- 发现 blocker
- 发起局部 clarification
- 要求局部 repair
- 标记必须升级的问题

但它们**不能直接成为最终 route authority**。

正确机制是：

- 中途 ask / clarify / recheck 是 **local repair loop**
- 最终 route 仍必须回写到：
  - `source_contract_check`
  - 或 `plan_gate`

### 5.3 Clarification 不是第三个 authority

`ASK_USER` / clarification 是一种**运行中的 repair action**，不是独立 canonical route surface。

只有在该 clarification 改变 planning outcome 时，最终结果才回写为：

- `NEEDS_INFO`
- `NEEDS_HUMAN`
- `RETURN_TO_RESEARCH`

之一。

---

## 6. Research / Plan override 最终规则

### 6.1 Problem contract inheritance

当 `research.v3` 为 `READY_FOR_PLAN` 时，Plan 继承 Research problem contract。

Plan 可以重做：

- selected implementation approach
- issue slicing
- migration shape
- rollout safety
- verification strategy
- execution topology

Plan 不能 silent 改写：

- `goal`
- `success_shape`
- `scope`
- `non_goals`
- `constraints`
- `Implementation Friction.required_plan_adjustment`
- `Progressive Feasibility.first_plannable_objective`

### 6.2 Override handling

若 Plan 发现 repo reality 与 Research contract 有张力，必须区分：

#### A. implementation-level redesign
Plan 内部解决，不改变 problem contract。

#### B. operationalization difference
可以进入：

- `Plan Grill Log`
- `Decision Overrides`

但仍不改变 problem contract 语义。

#### C. problem-contract change
必须最终 route 到：

- `RETURN_TO_RESEARCH`
- `NEEDS_INFO`
- `NEEDS_HUMAN`

之一。

---

## 7. Input conflict taxonomy

### 7.1 Type A: narrowing constraint

例子：

- “按这个 research，但这轮只改 `SKILL.md`，不要动 template”

处理：

- 保留 artifact 主语义
- 当前 prompt 作为 narrowing constraint 进入 plan
- 必要时进 `Decision Overrides`
- 不触发 Research 回退

### 7.2 Type B: implementation-level preference

例子：

- “保留 issue-file shape，但收轻 PER 呈现”
- “不要新增 stage，只重组现有 skill”

处理：

- Plan 内部吸收
- 不改变 problem contract
- 不需要回到 Research

### 7.3 Type C: contradiction without problem-contract change

例子：

- artifact 暗示某个范围，但当前 prompt 又加了更窄的现实限制
- repo coherence 迫使少量 scope exception，但总体目标不变

处理：

- contradiction 进 `Plan Grill Log`
- justified deviation 进 `Decision Overrides`
- 仍可继续 planning

### 7.4 Type D: problem-contract change

例子：

- Research 指向 `first_plannable_objective`，但当前 prompt 要直接做最终目标
- 当前 prompt 实际改变了 success shape / goal / acceptance 权限边界

处理：

- 最终 route 到 `RETURN_TO_RESEARCH / NEEDS_INFO / NEEDS_HUMAN`
- 不允许在 Plan 内 silent 吞并

### 7.5 Type E: stale / broken source

例子：

- selector 指到的 artifact 不存在
- artifact 与当前 repo 或上下文严重失配
- source 无法支持 fair planning

处理：

- 由 `source_contract_check` 拦截
- 不进入后续 planning

---

## 8. bounded rediscovery 最终规则

### 8.1 允许 rediscovery，但只在 planning 粒度

Plan 可以重新看 repo / runtime reality，但仅限于支持：

- runtime paths
- producer / consumer / validator surfaces
- coupling hotspots
- verification constraints
- migration blockers
- rollout / rollback constraints
- ownership boundaries

### 8.2 不新增 persisted reality artifact

不创建：

- `reality-extraction.md`
- `analysis.md`
- 第二份 canonical truth artifact

### 8.3 rediscovery 的沉淀位置

rediscovery 的结果只能落到现有 contract surfaces：

- `necessary_context`
- `selected_approach`
- `rejected_approaches`
- `Plan Engineering Review`
- `risks`
- `plan_gate_inputs`
- issue-level context（当直接影响 issue contract 时）

---

## 9. Canonical output shape 最终规则

### 9.1 `issue_file_plan` 固定

所有 `READY_FOR_EXECUTE` 计划统一遵守：

- `plan.md` 中 `## issues` 只做 compact index
- full issue contract 一律在 `issues/Ixxx.md`

### 9.2 LIGHT 也不例外

LIGHT / 单 issue 也不允许 inline full issue body 回 `plan.md`。

LIGHT 可以更短，但不能变成另一套 shape。

---

## 10. Conditional visible policy 最终规则

### 10.1 总原则

质量 surface 的策略是：

- **语义保留**
- **按 risk/depth 条件显式**
- **不可退回隐式推理**
- **可折叠 surface 必须规定折叠去向**

### 10.2 Trigger matrix

| Surface | 必显式触发 | 可省略条件 | 默认折叠去向 |
|---|---|---|---|
| `Plan Engineering Review` | MEDIUM/DEEP；architecture/protocol/schema/route/migration/validator-sensitive task；multi-issue slicing | trivial LIGHT 且无明显风险 | 不折叠；可极短 |
| `Plan Grill Log` | contradiction；source conflict；scope exception pressure；artifact-vs-prompt tension | trivial LIGHT 且无冲突 | 不折叠 |
| `Decision Overrides` | justified scope exception；inherited decision deviation；confirmation-needed boundary；`observed_behavior` 不能直接继承 | 无 override | 不折叠 |
| `risks` | rollout/migration risk；verification fragility；coupling/parallel safety；protocol/schema/route change；forbidden-zone risk；research non-blocking question carry-forward | trivial LIGHT 且无风险 | 不折叠 |
| `Self-Evaluation` | authority-heavy；assumption-heavy；headless；`/ needs_confirmation`；`observed_behavior` handling | trivial LIGHT 且无 authority risk | 不折叠 |
| `plan_gate_inputs` | MEDIUM/DEEP ADC；workflow-contract；artifact-schema；validation-contract；gate/tooling；material forbidden-zone risk | ordinary LIGHT/MEDIUM | 不折叠 |
| `Experience Context` | human-facing / artifact-facing acceptance；UX-sensitive success shape | internal/protocol-only task | `acceptance` / `verification` / relevant PER lens |
| `Quality Check Results` | compact quality summary genuinely helps final readability | already fully visible in `plan_gate` / PER / sanity | `plan_gate` checklist summary / final sanity |

---

## 11. `risks` / `Grill` / `Overrides` / `Self-Evaluation` 的最终分工

### 11.1 `risks`

记录未来执行或验证中的风险面：

- rollout / migration
- coupling / parallel safety
- protocol / route / schema fragility
- verification fragility
- unresolved-but-non-blocking planning risk

### 11.2 `Plan Grill Log`

记录 planning 过程中发现的压力与矛盾：

- contradiction
- source conflict
- scope pressure
- inherited-vs-current mismatch

### 11.3 `Decision Overrides`

记录最终如何 justified 地偏离继承面：

- override 的对象
- 来源
- 为什么需要 override / confirmation
- 是否需要用户确认

### 11.4 `Self-Evaluation`

只做 authority / escalation / assumption discipline 自检：

- `/ needs_confirmation`
- `observed_behavior`
- user-authority boundary
- false escalation / swallowed escalation
- headless overreach

这 4 个 surface 不能互相吞并。

---

## 12. Folded surface destination rules

### 12.1 `Experience Context`

若不独立成 section，默认折叠到以下位置之一：

1. `Success Shape → Acceptance + Verification Trace`
2. `acceptance`
3. relevant `Plan Engineering Review` lens（scope / design / verification）

禁止只“理论保留语义”而没有稳定落位。

### 12.2 `Quality Check Results`

若不独立成 section，默认折叠到：

1. `plan_gate` checklist summary
2. final sanity summary
3. PER 剩余 findings / closure summary

禁止出现“原本有 summary surface，但折叠后读者找不到替代位置”。

---

## 13. PER 的 multi-lens final model

### 13.1 单一 PER surface

PGE 只保留一个 `Plan Engineering Review` surface。

不新增：

- `plan-ceo-review`
- `plan-design-review`
- `plan-devex-review`

之类 protocol rails。

### 13.2 Lens activation matrix

| Change type | Required PER lens |
|---|---|
| trivial internal bounded fix | compact engineering lens only |
| architecture / refactor / multi-module change | scope + engineering + verification |
| protocol / schema / route / validator change | engineering + validator/coherence + rollout |
| migration / rollout / compatibility work | engineering + rollout + verification |
| human-facing UX / artifact-facing output | scope + design/experience + verification |
| tooling / workflow / devex change | engineering + devex + regression |
| parallel execution / shared verification | engineering + verification-coupling + rollout safety |

### 13.3 Lens 的角色

各 lens 不是新 stage，只是 PER 在不同任务上必须问的不同问题。

---

## 14. Depth scaling 最终模型

### 14.1 原则

不仅 `read-path` 按 depth 升级，**visible-surface 也按 depth/risk 升级**。

### 14.2 推荐读取矩阵

| Depth | 默认读取 |
|---|---|
| LIGHT | 主 `SKILL.md` 热路径 + `templates/plan.md` + 必要时 compact sanity |
| MEDIUM | 上述 + `engineering-review-gate.md` + `engineering-review.md` + `plan-gate.md` |
| DEEP / protocol / schema / workflow / migration | 上述 + high-risk gate inputs / coherence-oriented references |

### 14.3 输出矩阵

| Depth | 默认输出策略 |
|---|---|
| LIGHT | 最小完整 contract；PER 可省或极短；无触发则不显式展示可选 surface |
| MEDIUM | 显式 PER；必要时 `risks` / `Grill` / `Overrides` / `Self-Evaluation` |
| DEEP / high-risk | 显式 boundary/evidence/coherence；必要时 `plan_gate_inputs` 与完整 hardening surfaces |

---

## 15. Fast Adopt 最终规则

### 15.1 保真原则

Fast Adopt 的目标是：

> **canonicalization with fidelity**

不是 silent replanning。

### 15.2 Adopt 行为

允许：

- 保留外部 plan 的核心 goal / scope / approach semantics
- 补 canonical execution-required fields
- 将 embedded issue structure 升级成 canonical issue-file shape
- MEDIUM/DEEP 时触发 PER

不允许：

- 借 adopt 之名重写 selected approach
- 用 assumptions 偷补缺失关键语义
- 在 source fidelity 不成立时继续 pretend-ready

---

## 16. Bare invocation / direct prompt 最终规则

### 16.1 direct prompt planning 保留

如果当前 prompt 已足够清楚，Plan 可以直接规划，不强制前置 `pge-research`。

### 16.2 bare invocation 不 silent auto-select

当用户 bare invoke 且 repo 中发现 artifact 时：

- 可以提示
- 可以给选择
- 可以建议默认
- **不能 silent auto-select**

因为 artifact discovery 不是 current intent authority。

---

## 17. Reference responsibility 最终分工

### 17.1 主 `SKILL.md`

负责：

- stage authority
- owner boundary
- input priority
- route contract
- depth scaling
- trigger overview
- upgrade path

### 17.2 `engineering-review-gate.md`

负责：

- compact PER hot path
- lens activation
- LIGHT/MEDIUM/DEEP hardening 入口

### 17.3 `engineering-review.md`

负责：

- detailed semantics
- rationale
- failure-mode guidance
- slicing / complexity / verification pressure
- multi-lens interpretation

### 17.4 `plan-gate.md`

负责：

- final authorization validator
- contract completeness
- source fidelity
- PER findings consumed
- repo reality
- execution readiness
- protocol coherence

### 17.5 `self-review.md`

负责：

- final sanity pass
- 不是 route authority

### 17.6 `input-adaptation.md`

建议作为正式 reference 增加。

原因是当前方案已经固定支持：

- current prompt priority
- selector + trailing constraints
- `research.v3`
- external plan / fast-adopt
- bare invocation
- source conflict taxonomy

这些规则如果继续堆在主 `SKILL.md`，热路径仍会过载。

---

## 18. 文件级一致性范围

### 18.1 必须同 slice 同步的文件

- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/references/engineering-review-gate.md`
- `skills/pge-plan/references/engineering-review.md`
- `skills/pge-plan/references/plan-gate.md`
- `skills/pge-plan/references/self-review.md`
- `skills/pge-plan/templates/plan.md`
- `skills/pge-plan/evals/evals.json`
- `skills/pge-plan/evals/joint-evals.json`
- `skills/pge-review/SKILL.md`
- `README.md`
- `README-CN.md`
- `CLAUDE.md`

### 18.2 尽量不改的文件

- `skills/pge-exec/SKILL.md`
- 历史 `.pge/tasks-*/plan.md`
- `schema_version: plan.v2`
- `plan_gate` 命名

除非 protocol consistency review 证明 consumer 真依赖旧 heading / 旧 semantics。

---

## 19. Single protocol-consistency slice 最终规则

### 19.1 实施策略

本方案只能作为一个 **single protocol-consistency slice** 落地。

也就是：

- producer
- template
- reviewer
- eval
- docs

必须同一轮闭合。

### 19.2 禁止的实施方式

禁止：

- 先只改 `pge-plan`
- 后续再慢慢补 `pge-review` / eval / docs

因为那会造成短期 semantic drift，而这类 drift 正是本方案要消除的对象。

---

## 20. 最终验收标准

本方案若被认定为“设计完成”，必须满足以下 8 条：

1. **Stage authority 清楚**
   - 读者能分清 Research / Plan / Exec / Review 谁负责什么。

2. **PER 定位清楚**
   - 不再被理解成独立 route authority，也不被误当成整个 `pge-plan` 本体。

3. **Canonical output 不漂移**
   - `plan.v2`、`plan_gate`、`issue_file_plan` 全部保持稳定。

4. **Rediscovery 有边界**
   - Plan 可重新看 reality，但不新增 persisted reality artifact。

5. **Input conflict 有分类法**
   - 当前 prompt 与 artifact 冲突时，处理方式稳定，不靠临场判断。

6. **Conditional surfaces 有 trigger matrix**
   - reviewer / eval / human audit 能稳定判断“该出现而没出现”与“按规则可省略”。

7. **Folded surfaces 有稳定落位**
   - `Experience Context` / `Quality Check Results` 不再因“可折叠”而语义漂移。

8. **Single slice 可闭合**
   - producer / consumer / validator / reviewer / docs / evals 可以同一轮对齐。

---

## 21. 最终一句话定义

> `pge-plan` 的最终一致性方案，是在不改变 `plan.v2`、`plan_gate`、`issue_file_plan` 与既有 producer/consumer/validator 关系的前提下，把它重组为一个 single compound planning surface：Research 负责问题契约，Plan 负责可执行方案设计与 hardening，Exec 继续只消费 passed canonical plan，Review 继续围绕 canonical plan 审查，同时所有质量面改为 risk-scaled、conditional visible，并通过明确的 route contract、conflict taxonomy、trigger matrix、lens activation matrix 与 fold destination rules 形成闭环。
