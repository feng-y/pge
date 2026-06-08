# pge-plan 对齐优化与可简化项分析

## 目标

在**不减少 `pge-plan` 当前核心功能与执行约束**的前提下，评估：

1. 哪些能力/契约必须保留
2. 哪些地方应做对齐优化
3. 哪些内容可以删除、降级或简化
4. 如何把 `pge-plan` 从“单文件协议总汇”收回为“可执行 skill + 分层 references”

本文只基于当前仓库证据，不把推测写成事实。

---

## 证据范围

已读取并作为主要证据来源：

- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/references/engineering-review.md`
- `skills/pge-plan/references/engineering-review-gate.md`
- `skills/pge-plan/references/plan-gate.md`
- `skills/pge-plan/references/final-plan-gate.md`
- `skills/pge-plan/references/self-review.md`
- `skills/pge-plan/templates/plan.md`
- `skills/pge-plan/templates/issue.md`
- `skills/pge-plan/templates/workflow-handoff.md`
- `skills/pge-plan/evals/evals.json`
- `skills/pge-plan/evals/joint-evals.json`
- `skills/pge-exec/SKILL.md:245-266`
- `skills/pge-review/SKILL.md:185-198`
- `docs/adr/0001-pge-contract-authority-and-planning.md`
- `docs/exec-plans/pge-plan-responsibility-realignment-plan.md`

附注：`skills/pge-plan/agents/openai.yaml` 不存在；在 Claude Code 执行环境下这**不是缺陷**，因为当前 subagent 边界主要由 `SKILL.md` 文本契约约束。

---

## 一、结论摘要

`pge-plan` 当前最大的问题不是功能不足，而是**协议内容过度堆叠在主 `SKILL.md`**，导致 skill 本体同时承担了：

- 触发说明
- 输入适配器
- authority 规则表
- 计划流程
- review/gate 细则
- 输出模板约束
- 下游兼容说明
- 高风险专题规则

这让它在语义上仍然强，但在执行上更像“协议百科”，而不是“高可用 skill”。

**结论：**

- 核心能力应保留，不能删。
- 可以显著瘦身主 `SKILL.md`，把大量规则下沉到 references，而不减少功能。
- 有少量内容可以删除为“默认要求”，改成“按需记录”或“仅在 reference 中存在”。
- 当前存在至少一个值得优先修复的契约不一致：`risks` 在下游被消费，但并未在 `pge-plan` 的主契约/模板中保持一致地定义。

---

## 二、哪些能力/约束必须保留

以下能力有明确下游消费者或明确协议价值，**不建议删除**。

### 1. canonical issue-file plan 输出

**必须保留：**

- `plan.md` 的 `## issues` 作为 compact execution index
- `issues/Ixxx.md` 作为 issue-local contract
- 禁止把完整 issue body 留在 `plan.md ## issues`

**证据：**

- `skills/pge-plan/SKILL.md:64-66, 816-840`
- `skills/pge-plan/templates/plan.md:48-59`
- `skills/pge-plan/templates/issue.md:1-39`
- `skills/pge-exec/SKILL.md:248-266`

**原因：**
这是 `pge-exec` 的直接输入，不是文档偏好。

---

### 2. `plan_gate PASS + Exec Allowed: yes` 才允许 ready route

**必须保留：**

- `Final Plan Gate` 作为唯一 execution authorization gate
- `READY_FOR_EXECUTE` / `READY_FOR_EXECUTE_WITH_ASSUMPTIONS` 必须受其约束

**证据：**

- `skills/pge-plan/SKILL.md:527-549, 898-905`
- `skills/pge-plan/references/plan-gate.md:27-37, 203-209`
- `skills/pge-exec/SKILL.md:248-250`

**原因：**
这是 `pge-exec` 的硬入口条件。

---

### 3. `research.v3` 消费与 direct prompt planning 双路径

**必须保留：**

- `research.v3` 作为主上游契约
- direct prompt planning 作为 first-class path
- bare invocation 时要求确认 artifact 选择

**证据：**

- `skills/pge-plan/SKILL.md:220-223, 336-345, 398-414`
- `docs/adr/0001-pge-contract-authority-and-planning.md:43-53`

**原因：**
这决定了 `pge-plan` 既能承接正式 research，又能在用户直接下 planning 指令时工作。

---

### 4. Fast Adopt 的语义保真约束

**必须保留：**

- external plan / Claude plan-mode output 语义采纳
- 禁止 silent replanning
- 缺语义时应 `NEEDS_INFO` 或走 normal planning

**证据：**

- `skills/pge-plan/SKILL.md:264-300`
- `skills/pge-plan/references/plan-gate.md:74-90`
- `skills/pge-plan/evals/evals.json:41-45, 89-92`

**原因：**
这是 `pge-plan` 的一个高价值能力，不应因瘦身而失去。

---

### 5. Verification Coupling / Parallel Safety

**必须保留：**

- `Verification Coupling` 分类
- coupled / integration-only / serial verification 等策略
- 不允许仅凭 target areas 非重叠就推断并行安全

**证据：**

- `skills/pge-plan/SKILL.md:703-727, 816-840`
- `skills/pge-exec/SKILL.md:251, 256, 260, 266, 415-419`

**原因：**
这是 execution safety 的直接输入。

---

### 6. `workflow-handoff.md` 仅作为 launch adapter

**必须保留：**

- executable route 时生成 adapter
- adapter 不得变成第二份 plan / DAG / graph
- `workflow-result.md` 仅为 evidence backflow

**证据：**

- `skills/pge-plan/SKILL.md:855-875`
- `skills/pge-plan/templates/workflow-handoff.md:3-41, 122-181`
- `docs/adr/0001-pge-contract-authority-and-planning.md:58-60, 84`

**原因：**
这关系到 PGE 的单一 canonical plan 原则。

---

### 7. Plan Engineering Review 与 Final Plan Gate 的分层

**必须保留：**

- Review 负责 hardening
- Gate 负责 authorization
- 两者不能混为一体

**证据：**

- `skills/pge-plan/SKILL.md:470, 508, 523, 527`
- `skills/pge-plan/references/plan-gate.md:3-7`

**原因：**
这是整个 planning/execution 责任分层的稳定基础。

---

## 三、优先要修的对齐问题

### P0. `risks` 契约不一致

**现象：**

- `pge-review` 把 `risks` 当成 plan contract-bearing field 来读。
- 现有计划样例中也大量存在 `## risks`。
- 但 `pge-plan` 主技能 mandatory field 列表不含 `risks`，模板中也没有稳定地把 `## risks` 作为 canonical section 固化。

**证据：**

- `skills/pge-review/SKILL.md:187-190`
- `skills/pge-plan/SKILL.md:40-60`
- `skills/pge-plan/templates/plan.md`（无 canonical `## risks` 必需段）
- 示例计划存在 `## risks`：
  - `.pge/tasks-20260529-1526-exec-light-coordinator/plan.md:321`
  - `.pge/tasks-goal-reality-alignment-p0/plan.md:136`
  - `.pge/tasks-plan-gate-v3-workflow/plan.md:294`

**影响：**

- review 认为它是稳定字段，但 plan 生产侧没有等价强度保证。
- 会出现“review 期待读取，但 plan 未必总产出”的不稳定面。

**建议：二选一，尽快统一**

1. **推荐做法：**把 `## risks` 定义为 canonical conditional section
   - 规则：当存在跨 issue coupling、migration risk、protocol change、verification fragility、forbidden-zone risk 时必须写
   - LIGHT trivial plan 可省略
2. 或者把 `pge-review` 降级为“当 present 时读取”，不再视作稳定字段

如果目标是不减少功能，**更推荐方案 1**。

---

### P1. 主 `SKILL.md` 与 references 重复定义同一协议

**现象：**

- `Plan Engineering Review`
- `Final Plan Gate`
- `Final Sanity Pass`
- `plan_gate_inputs`

都在主 skill 与 reference 中重复出现。

**证据：**

- `skills/pge-plan/SKILL.md:468-583, 876-885`
- `skills/pge-plan/references/engineering-review.md`
- `skills/pge-plan/references/engineering-review-gate.md`
- `skills/pge-plan/references/plan-gate.md`
- `skills/pge-plan/references/final-plan-gate.md`
- `skills/pge-plan/references/self-review.md`

**影响：**

- 维护时易漂移
- 模型执行时易重复阅读和重复输出

**建议：**

- 主 `SKILL.md` 只保留“何时读哪个 reference”与少量硬规则
- 详细 gate/review/check 规则只保留在 reference 中

---

### P1. 澄清规则存在局部冲突

**现象：**

主 skill 多处传达“最多问一个问题”，但 gate reference 明确允许多个耦合事实在必要时一起澄清。

**证据：**

- `skills/pge-plan/SKILL.md:178, 236, 656, 741, 756`
- `skills/pge-plan/references/plan-gate.md:149-153`

**影响：**

- 容易导致模型压缩过度，问不够
- 或反过来担心违规，不敢澄清真正阻塞 planning 的点

**建议：**

把规则统一为：

- 默认：**单轮澄清**
- 例外：**若多个事实共同决定 goal/scope/acceptance/safety，可在同一轮合并提问**

不要再用容易被读成硬上限的 `ASK_USER (max 1)` 表述。

---

### P1. LIGHT 任务“可简化”被写出来了，但没有形成清晰的 read-path

**现象：**

文件多次强调 LIGHT 不该付出 DEEP ceremony，但没有首屏的 depth-based reading matrix。

**证据：**

- `skills/pge-plan/SKILL.md:240-262, 635-645`
- `skills/pge-plan/references/engineering-review-gate.md:13, 41`
- `skills/pge-plan/references/final-plan-gate.md:17`

**影响：**

- 模型可能仍保守地吃下完整 skill 内容
- 导致 trivial task 也执行成大工程

**建议：**

在 `SKILL.md` 顶部加入：

| Depth | 默认读取 |
|---|---|
| LIGHT | SKILL 主流程 + `templates/plan.md` + 必要时 `self-review.md` |
| MEDIUM | 上述 + `engineering-review.md` + `plan-gate.md` |
| DEEP / protocol / schema / workflow | 上述 + `final-plan-gate.md` |

---

## 四、哪些内容可以删除、降级或简化

这里分三类：

- **A. 可以从主 `SKILL.md` 删除，但功能保留在 reference 或行为中**
- **B. 可以从默认输出要求中删除，改为按需记录**
- **C. 可以合并/重命名/压缩**

---

## A. 可以从主 `SKILL.md` 删除的内容（不减功能）

### A1. Graphviz 全流程图

**证据：**

- `skills/pge-plan/SKILL.md:132-202`

**判断：**

- 有说明价值
- 但不是执行 contract
- 占据主技能大量篇幅

**建议：**

- 从主 `SKILL.md` 删除
- 移到 `references/flow.md` 或 docs
- 在主 skill 仅保留 8-12 行编号式流程

**可删强度：高**

---

### A2. authority classification 大表与完整说明

**证据：**

- `skills/pge-plan/SKILL.md:102-126`

**判断：**

- 规则重要
- 但表格细节更适合 reference

**建议：**

- 主 skill 只保留 3 条硬规则：
  - 不升级 `observed_behavior`
  - 不吞掉 `/ needs_confirmation`
  - research blocking questions 不能变成 assumptions
- 完整 authority 表移到 `references/authority-and-clarification.md`

**可删强度：中高（从主 skill 删除，不是从协议删除）**

---

### A3. `research.v3` 详细 field mapping 全量说明

**证据：**

- `skills/pge-plan/SKILL.md:398-430`

**判断：**

- 有必要存在
- 但不必占据主 skill 热路径

**建议：**

- 抽到 `references/input-adaptation.md`
- 主 skill 只保留 adapter 的高层规则

**可删强度：高**

---

### A4. `Final Plan Gate` 六层细则在主 skill 中的完整重复版本

**证据：**

- `skills/pge-plan/SKILL.md:521-583`
- `skills/pge-plan/references/plan-gate.md`

**判断：**

- 主 skill 里的这段与 reference 明显重复

**建议：**

- 主 skill 仅保留：
  - gate 是唯一授权点
  - 何时必须读 `plan-gate.md`
  - ready route 的硬条件
- 详细六层规则保留在 reference

**可删强度：高**

---

## B. 可以从“默认输出要求”中删除或降级的内容

### B1. `Plan Grill Log` 不应作为默认命名产物要求

**证据：**

- `skills/pge-plan/SKILL.md:661-681`
- 下游 active skills 未见对 `Plan Grill Log` 的直接消费

**判断：**

- “grill the plan” 作为行为有价值
- 但固定要求一个命名 log，会增加 ceremony
- 没有明确下游消费者

**建议：**

保留行为，删除默认输出要求：

- 仍要求解决 contradiction
- 仅在高风险/非显然 case 下，把结论折叠进 `### Plan Engineering Review` 或 `## risks`
- 不再要求独立 `Plan Grill Log`

**可删强度：高**

---

### B2. `Quality Check Result Shape` 不应作为默认 plan 输出面

**证据：**

- `skills/pge-plan/SKILL.md:585-603`
- `skills/pge-plan/templates/plan.md:242-262`
- 下游 active skills 未见消费该 shape

**判断：**

- 这是 authoring/debug aid，不是 execution contract
- 对主 hot path 噪音大

**建议：**

- 从模板默认输出中删除
- 如需调试或临时审计，只保留在 reference 中

**可删强度：高**

---

### B3. `Experience Context Check` 不必作为独立命名 check 暴露

**证据：**

- `skills/pge-plan/SKILL.md:605-633`
- `skills/pge-plan/evals/evals.json:53-62`
- 下游未见对该命名 check 的直接消费

**判断：**

- 能力本身值得保留：human-facing task 要把体验上下文写进 acceptance/verification/evidence
- 但“独立 check 名称”未见下游契约依赖

**建议：**

把它从独立 check 降级为一条规则：

- 若 task 是 human-facing / artifact-facing 且 research 提供 experience context，plan 必须在 acceptance / verification / evidence 中体现
- 不必强制输出 `Experience Context Check: PASS/SKIP...`

**可删强度：中高（删命名 check，不删能力）**

---

### B4. `Self-Evaluation` 决策表不应成为默认 plan artifact 内容

**证据：**

- `skills/pge-plan/SKILL.md:736-756`
- `skills/pge-plan/templates/plan.md:264-268`
- 下游未见消费 `Self-Evaluation` 表

**判断：**

- 这是 internal reasoning scaffold
- 作为默认 artifact 内容价值有限

**建议：**

- 保留成内部执行规则
- 从默认模板中去掉 `### Self-Evaluation` section
- 仅在出现复杂 authority/safety clarification 时，以简短说明落到 `Assumptions` 或 `plan_gate` rationale

**可删强度：高**

---

## C. 可以合并、压缩或重命名的内容

### C1. 合并 `engineering-review.md` 与 `engineering-review-gate.md`

**证据：**

- 两者都在定义 Plan Engineering Review 维度与结果

**建议：**

保留一个 authoritative reference，例如：

- `references/engineering-review.md` 作为唯一 PER reference
- 里面区分：purpose / dimensions / record shape / depth scaling

另一个文件删除。

**可简化强度：高**

---

### C2. 把 Input Adaptation 从主 skill 拆成独立 reference

**证据：**

- `skills/pge-plan/SKILL.md:216-430` 占比极大

**建议：**

拆为：

- `references/input-adaptation.md`
- `references/source-priority.md`（或合并进一个文件）

主 skill 只保留四种输入模式：

1. direct prompt
2. `research.v3`
3. explicit external plan / fast-adopt
4. bare invocation

**可简化强度：高**

---

### C3. 把 Architecture Delta Contract 压缩成一组 mandatory dimensions + reference

**证据：**

- `skills/pge-plan/SKILL.md:70-100`

**判断：**

- 核心思想有价值
- 但主 skill 中展开过多

**建议：**

主 skill 仅保留：

- current reality
- bounded delta
- target direction
- allowed/forbidden changes
- claim/evidence expectations

详细适用条件放入 reference/gate docs。

**可简化强度：中**

---

### C4. 用“默认单轮澄清”替代“max 1 question”措辞

**建议：**

- 把 `ASK_USER (max 1)` 改为：`single clarification round by default`
- 允许同一轮合并多个耦合事实

**可简化强度：中**

---

## 五、建议保留为 optional，而不是删除的内容

### 1. `plan_gate_inputs`

**不建议删除。**

**证据：**

- `skills/pge-plan/references/final-plan-gate.md`
- `docs/pge/plan-gate-v3.md`
- `skills/pge-plan/SKILL.md:99, 525`

**原因：**

这对 workflow/schema/route/validator 类高风险改动是有价值的结构化输入。问题不在它存在，而在它不该污染 LIGHT 热路径。

**建议：**

- 保留
- 明确高风险触发条件
- 从主 skill 主流程中后移到升级路径

---

### 2. `Source Semantics Ledger`

**不建议删除。**

**原因：**

在 Fast Adopt 场景下，它是 useful optional traceability tool。

**建议：**

- 仅 Fast Adopt / source fidelity 非显然时使用
- 不要当默认 section

---

### 3. `Assumptions`

**不建议删除。**

**证据：**

- `skills/pge-exec/SKILL.md:250, 264`

**原因：**

`READY_FOR_EXECUTE_WITH_ASSUMPTIONS` 直接消费 assumptions。

**建议：**

- 保留 conditional canonical role
- 但不要要求每个 trivial plan 都写冗长 assumptions 表

---

## 六、建议的新结构（不减功能）

### 主 `SKILL.md` 保留

1. metadata / trigger
2. what this skill does / does not do
3. four input modes
4. depth routing + read matrix
5. canonical outputs
6. hard rules
7. final response

目标：约 250-400 行。

---

### references 重组建议

- `references/input-adaptation.md`
- `references/authority-and-clarification.md`
- `references/engineering-review.md`（合并 gate 版）
- `references/plan-gate.md`
- `references/final-plan-gate.md`
- `references/self-review.md`
- 可选：`references/flow.md`

---

### templates 调整建议

#### `templates/plan.md`

**建议保留为 canonical / conditional：**

- `schema_version`
- `source_contract_check`
- `selected_approach`
- `rejected_approaches`
- `goal`
- `non_goals`
- `necessary_context`
- `target_areas`
- `forbidden_areas`
- `issues`
- `acceptance`
- `verification`
- `evidence_required`
- `terminal_conditions`
- `plan_gate`
- `stop_conditions`
- `route`
- `Metadata`
- `Handoff To Execute`
- `Assumptions`（conditional）
- `plan_gate_inputs`（conditional）
- `risks`（建议补齐为 canonical conditional）
- `Plan Engineering Review`（MEDIUM/DEEP mandatory, LIGHT optional）

**建议从默认模板删除：**

- `Quality Check Results`
- `Self-Evaluation`
- 独立 `Experience Context Check` 行
- 默认 `Plan Grill Log`

---

## 七、推荐的落地顺序

### Phase 1：先做 contract 对齐，不做大重写

1. 统一 `risks` 的 canonical 地位
2. 统一澄清规则措辞
3. 明确 LIGHT / MEDIUM / DEEP read matrix
4. 明确 `Plan Engineering Review` 与 `Final Plan Gate` 的单一 reference authority

### Phase 2：再做主 skill 瘦身

1. 从 `SKILL.md` 拆出 input adaptation
2. 拆出 authority/clarification 细则
3. 删除 graphviz 主体
4. 删除主 skill 内重复 gate 细节

### Phase 3：最后清理模板/输出噪音

1. 模板去掉 `Quality Check Results`
2. 模板去掉默认 `Self-Evaluation`
3. 把 `Experience Context Check` 降级为规则，不再要求命名输出
4. 删除默认 `Plan Grill Log` 要求

---

## 八、最终判断：哪些可以删，哪些只能简化

### 可以直接删掉“默认要求/默认输出”的

- 主 `SKILL.md` 中的 Graphviz 全流程图
- `Quality Check Result Shape`
- `templates/plan.md` 中默认 `Quality Check Results`
- `templates/plan.md` 中默认 `Self-Evaluation`
- 默认 `Plan Grill Log` 命名输出要求
- 独立命名的 `Experience Context Check` 输出要求

### 不能删，但应挪位置/降热度的

- authority classification 细则
- research.v3 详细 field mapping
- Fast Adopt 详细判定
- Final Plan Gate 六层细则
- Architecture Delta Contract 详细展开

### 不能删的核心能力

- issue-file canonical output
- `plan_gate PASS` 才允许 ready route
- direct prompt planning
- `research.v3` adapter
- Fast Adopt semantic fidelity
- verification coupling / parallel safety
- workflow handoff adapter boundary
- PER vs Final Gate 分层
- assumptions support
- high-risk `plan_gate_inputs`

---

## 建议的最终立场

如果目标是：

> **在不减少 `pge-plan` 功能约束下做对齐优化**

那么最优策略不是“删能力”，而是：

1. **保留 contract-bearing capability**
2. **删除无下游消费者的默认输出 ceremony**
3. **把重复协议从主 `SKILL.md` 下沉到 reference**
4. **优先修复 `risks`、澄清规则、LIGHT read-path 这三个对齐问题**

如果目标进一步放宽到：

> **评估哪些功能可删除或简化**

那我的判断是：

- **可删的是默认仪式化输出，不是核心 planning 能力**
- `pge-plan` 现在更需要“收口与分层”，而不是“功能阉割”

---

## 可直接执行的下一步

如果后续要进入修改阶段，建议按下面顺序实施：

1. 修 `risks` 契约对齐
2. 合并 `engineering-review*.md`
3. 给 `SKILL.md` 增加 depth-based reading matrix
4. 把 input adaptation/authority 细则拆出到 references
5. 清理模板中的默认噪音 sections

这样能最大程度降低改动风险，同时保留当前 `pge-plan` 的能力上限。
