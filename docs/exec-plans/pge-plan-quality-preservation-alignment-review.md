# pge-plan 质量保真对齐评估

## 目标

这份文档不再以“简化 / 删除”为默认方向，而是回答更严格的问题：

1. `pge-plan` 当前有哪些**真实质量机制**
2. 这些机制分别在防什么失败模式
3. 哪些机制**不能轻动**
4. 哪些优化只允许做**结构整理 / 权威归并 / 导航改进**
5. 哪些“看起来可以简化”的动作实际上会降低 runtime 质量

核心前提：

> **一个更快但质量更低的 planning runtime 是退化，不是优化。**

因此，本文的判断标准不是“更短更轻”，而是：

- 功能覆盖是否完整
- 质量保护是否等价或更强
- 显式约束是否仍足以防止 silent drift / silent assumption / silent replanning

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
- `skills/pge-plan/TUNING_LOG.md`
- `skills/pge-exec/SKILL.md:245-266`
- `skills/pge-review/SKILL.md:185-198`
- `docs/adr/0001-pge-contract-authority-and-planning.md`
- `docs/exec-plans/pge-plan-responsibility-realignment-plan.md`

---

## 一、结论摘要

`pge-plan` 当前的“厚”不是单纯坏味道。它的很多显式 section、检查面、记录面、条件化规则，很可能是在修补真实失败模式后留下的**质量护栏**。因此，对 `pge-plan` 的优化不能先问“哪些能删”，而必须先问：

- 这个 section / rule 在防什么失败？
- 如果不显式写出来，谁来补这个洞？
- 现有 eval / tuning / human review / downstream consumer 是否已经依赖它？

基于当前证据，`pge-plan` 的优化应遵循：

1. **先保质量机制，再谈结构整理**
2. **优先修 contract closure，不优先删 section**
3. **允许 reorganize，不允许为了收轻而把显式质量约束隐回模型内部**

换句话说：

> `pge-plan` 需要的是“保真重组”，不是“删减式轻量化”。

---

## 二、现有实现的长处

这些长处不是泛泛优点，而是与 planning 质量直接相关的机制。

### 1. 它把高风险判断显式化，而不是留在内部推理里

**证据：**

- `Plan Grill Log`：`skills/pge-plan/SKILL.md:480, 515`; `skills/pge-plan/templates/plan.md:216-223`; `skills/pge-plan/references/engineering-review.md:131`
- `Decision Overrides`：`skills/pge-plan/SKILL.md:334, 481, 514`; `skills/pge-plan/templates/plan.md:208-214`
- `Self-Evaluation`：`skills/pge-plan/SKILL.md:575-595`; `skills/pge-plan/templates/plan.md:288-292`

**它防的失败模式：**

- contradiction 被 silently ignored
- override 被 silently broadened
- question / assumption / user-authority boundary 被 silently decided

**为什么这很重要：**
Planning 的高风险失败，往往不是“完全不工作”，而是“看起来很顺，但在错误边界上推进”。显式记录面是为了让这种错误可见。

---

### 2. 它把 authority / confirmation / safety friction 明确定义为 planning 内部机制

**证据：**

- `skills/pge-plan/SKILL.md:102-126`
- `skills/pge-plan/SKILL.md:575-595`
- `skills/pge-plan/TUNING_LOG.md:453-469`

**它防的失败模式：**

- 把 `observed_behavior` 错当 preservation constraint
- 吞掉 `/ needs_confirmation`
- 把 Core Friction 误当 taste/self-answer

**为什么这很重要：**
如果 authority closure 不显式，模型很容易用“合理默认”跨过真实的 user-authority boundary。

---

### 3. 它不是只产出 plan，而是在约束 planning 质量

**证据：**

- `Plan Engineering Review`：`skills/pge-plan/SKILL.md:468-483`; `references/engineering-review.md`; `references/engineering-review-gate.md`
- `Final Plan Gate`：`skills/pge-plan/SKILL.md:485-515`; `references/plan-gate.md`
- `Final Sanity Pass`：`references/self-review.md`

**它防的失败模式：**

- 方案不完整但看起来合理
- issue slicing 可执行性差
- acceptance / verification 不闭环
- source fidelity 被 silently weakened

**为什么这很重要：**
`pge-plan` 的职责不是“写一个像 plan 的文本”，而是“输出可执行且可验证的 execution contract”。

---

### 4. 它对 fast-adopt fidelity 的 paranoia 是有价值的

**证据：**

- `skills/pge-plan/SKILL.md:264-300`
- `skills/pge-plan/references/plan-gate.md:74-90`
- `skills/pge-plan/evals/evals.json:41-45, 89-92`

**它防的失败模式：**

- 把 adoption 变成 silent replanning
- external plan 语义被“优化”掉
- missing semantics 被 assumptions 偷补

**为什么这很重要：**
外部 plan 采纳最大的风险不是格式不兼容，而是语义保真失败。

---

### 5. 它把 verification coupling / parallel safety 当成一等 planning 输出

**证据：**

- `skills/pge-plan/SKILL.md:560-565, 679, 703-727`
- `skills/pge-exec/SKILL.md:251, 256, 260, 266, 415-419`
- `skills/pge-plan/templates/plan.md:163-173`

**它防的失败模式：**

- issue 看似独立，实则共享 verification surface
- exec 因 target areas 不重叠而错误并行
- verification point 不清晰导致假通过

**为什么这很重要：**
这是 planning 对 execution safety 的直接贡献，不是文档装饰。

---

### 6. 它保留了人类可审计面，而不是把关键判断全变成内部隐式行为

**证据：**

- `skills/pge-review/SKILL.md:187-190`
- `skills/pge-plan/templates/plan.md` 中大量显式 section
- 历史计划产物含：`Plan Grill Log` / `Self-Evaluation` / `Quality Check Results` / `Assumptions`

**它防的失败模式：**

- 人类 review 无法判断计划为什么这样切
- 矛盾 / assumptions / overrides 没有可见证据
- tuning 之后机制退化但不易发现

---

## 三、当前质量机制清单

这里列的不是“所有 section”，而是当前证据表明具有真实质量作用的机制。

### A. 不能轻动的 contract-bearing 机制

这些是下游有明确消费者、或者是 active protocol 的关键面。

- canonical issue-file output
  - `## issues` index + `issues/Ixxx.md`
- `plan_gate PASS + Exec Allowed: yes` 才允许 ready route
- `research.v3` adapter
- direct prompt planning
- fast-adopt semantic fidelity
- verification coupling / parallel safety
- `workflow-handoff.md` 只做 adapter
- assumptions support（尤其 `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`）
- high-risk `plan_gate_inputs`

**证据：**

- `skills/pge-exec/SKILL.md:245-266`
- `skills/pge-plan/templates/workflow-handoff.md`
- `skills/pge-plan/references/final-plan-gate.md`

---

### B. 高概率是“质量显式化机制”的 section

这些不一定是 machine parser 的硬字段，但当前证据表明它们不是可随便删除的装饰。

- `Plan Grill Log`
- `Decision Overrides`
- `Self-Evaluation`
- `Experience Context Check`
- `Quality Check Results`
- `Assumptions`
- acceptance trace / success-shape trace

**证据链：**

#### `Plan Grill Log`
- 主 skill 要求：`skills/pge-plan/SKILL.md:480, 515`
- reference 要求：`skills/pge-plan/references/engineering-review.md:131`
- template 支持：`skills/pge-plan/templates/plan.md:216-223`
- eval 依赖：`skills/pge-plan/evals/joint-evals.json:88-92`; `skills/pge-plan/evals/evals.json:187`
- 历史计划存在：`.pge/tasks-goal-reality-alignment-p0/plan.md:244`; `.pge/tasks-exec-executable-contract-inputs/plan.md:195`

#### `Decision Overrides`
- 主 skill 要求：`skills/pge-plan/SKILL.md:334, 481, 514`
- template 支持：`skills/pge-plan/templates/plan.md:208-214`
- eval 依赖：`skills/pge-plan/evals/joint-evals.json:88-92`

#### `Self-Evaluation`
- 主 skill：`skills/pge-plan/SKILL.md:575-595`
- template：`skills/pge-plan/templates/plan.md:288-292`
- tuning 历史：`skills/pge-plan/TUNING_LOG.md:37, 44, 159, 204, 456, 460, 469`
- 历史计划存在：`.pge/tasks-goal-reality-alignment-p0/plan.md:263`; `.pge/tasks-20260529-1526-exec-light-coordinator/plan.md:462`

#### `Experience Context Check`
- reference 正式定义：`skills/pge-plan/references/engineering-review.md:100-109`
- 主 skill 显式引用：`skills/pge-plan/SKILL.md:513`
- template summary slot：`skills/pge-plan/templates/plan.md:280-286`
- eval 依赖：`skills/pge-plan/evals/evals.json:89-98`
- 历史计划存在：`.pge/tasks-20260529-1526-exec-light-coordinator/plan.md:459`

#### `Quality Check Results`
- 主 skill：`skills/pge-plan/SKILL.md:512`
- template：`skills/pge-plan/templates/plan.md:266-286`
- 历史计划存在：`.pge/tasks-20260529-1526-exec-light-coordinator/plan.md:453`

**结论：**
这些 section 当前至少已被：

- skill 规则
- template
- eval
- tuning 历史
- 历史 plan 工件

共同塑造成现役质量机制。不能仅因“下游 parser 不读取”就当成冗余。

---

## 四、哪些东西不能为了“优化”而直接删

### 1. 不能直接删 `Plan Grill Log`

**原因：**
它当前不仅是记录面，还是 contradiction / scope exception / source conflict 的显式承载面。

**风险：**
删除后最可能退化成：
- contradiction 仍然存在，但只留在模型内部推理
- override 仍然发生，但 review 只看到结果，看不到理由

**更安全的做法：**
只允许把它做成**条件显式要求**：
- MEDIUM/DEEP
- docs/exec-plans sourced
- contradiction / override / source conflict present

trivial LIGHT case 才可省略。

---

### 2. 不能直接删 `Self-Evaluation`

**原因：**
从 tuning log 看，它不是可有可无的“思维脚手架”，而是修过真实 authority / escalation / core friction 失败模式的机制。

**风险：**
删除后最可能回归：
- User Challenge / Core Friction 误分类
- ASK_USER boundary 漂移
- headless mode 默认值错误升级

**更安全的做法：**
- trivial LIGHT 可省略
- authority-sensitive / `/ needs_confirmation` / assumption-heavy / headless 情况保留

---

### 3. 不能直接删 `Experience Context Check`

**原因：**
它在 eval 中被明确测试，用于防止 human-facing 成功标准被 silently dropped。

**风险：**
删除命名检查后，能力仍可能“理论上存在”，但更容易在实际产物中消失。

**更安全的做法：**
先允许**表现形式松动**，再决定是否移除命名检查：
- 可以折叠进 PER / acceptance / verification record
- 但不能先删掉这层显式质量义务

---

### 4. 不能先删 authority / confirmation 显式规则，再指望“模型会懂”

**原因：**
`observed_behavior`、`/ needs_confirmation`、Core Friction、Safety Amplifier 这些都对应具体历史失败模式。

**证据：**
- `skills/pge-plan/TUNING_LOG.md:453-469`
- `skills/pge-plan/SKILL.md:102-126, 575-595`

**风险：**
删掉显式规则后，质量退化会表现为：
- 计划仍然可写
- gate 仍然可跑
- 但 authority boundary 更容易被 silent default 吞掉

---

## 五、允许做的优化：只限结构整理，不减质量

下面这些优化方向是安全的，前提是**不降低显式约束强度**。

### 1. 主 `SKILL.md` 做导航化重组

允许：
- 把“什么时候读哪个 reference”前置
- 用 depth-based reading matrix 改善入口导航
- 把重复摘要压缩成 pointer

不允许：
- 因为导航优化而删除高风险规则本身

---

### 2. 明确单一权威来源，减少重复表述

允许：
- 主 `SKILL.md` 只保留高层稳定语义
- 详细 gate/review semantics 下沉到 references

前提：
- 仍能在 skill 入口清楚知道何时必须读哪些 reference
- 不出现“主 skill 太短，导致模型没读到关键高风险规则”

---

### 3. 对质量显式化机制做“条件化”，而不是“删除”

允许：
- 根据 depth / risk / source type 调整是否显式输出某些 section

不允许：
- 把它们从协议层完全降成纯内部隐式行为

更具体地说：

| 机制 | 可做的优化 | 不可做的优化 |
|---|---|---|
| Plan Grill Log | 变成条件必填 | 直接取消显式记录面 |
| Self-Evaluation | trivial LIGHT 省略 | authority-heavy case 也删除 |
| Experience Context Check | 允许折叠进 PER/acceptance | 直接取消体验质量显式义务 |
| Quality Check Results | 可改为 truly-when-useful | 误删后导致 eval/审计无替代面 |

---

### 4. 合并或重划 references，但前提是职责更清楚而不是更模糊

例如：
- `engineering-review.md` 与 `engineering-review-gate.md` 可以考虑重划边界
- 但在证明职责不会更模糊前，不应仅因为“看起来重复”就删掉一个

更安全的策略：
1. 先定义一个是 detailed semantics，一个是 compact hot-path reference
2. 如果仍高度重叠，再合并

---

## 六、当前最值得优先修的是真正的 contract closure

### P0. `risks` 的 canonical 地位需要对齐

**现象：**
- `pge-review` 读取 `risks`：`skills/pge-review/SKILL.md:187-190`
- 主 skill 把 `Risks` 当 issue/plan 风险承载面之一：`skills/pge-plan/SKILL.md:565, 679`
- 历史 plans 广泛有 `## risks`
- 但 `templates/plan.md` 未把它提升为稳定 canonical conditional section

**判断：**
这是活跃 contract gap，不是小修辞问题。

**建议：**
把 `## risks` 正式定义为 **canonical conditional section**：
- 存在 cross-issue coupling
- migration / rollout risk
- protocol change
- verification fragility
- forbidden-zone risk

时必须写；trivial LIGHT 可省略。

---

### P1. 澄清规则要统一，但不能过度收紧

当前问题不是“问太多”，而是：
- 主 skill 多处呈现出强单问倾向
- 某些高风险 case 实际需要最小但完整的一轮澄清

**建议：**
统一成：
- 默认单轮澄清
- 当多个耦合事实共同决定 goal/scope/acceptance/safety 时，可同轮合并提问

这样既保守，也不牺牲质量。

---

### P1. LIGHT / MEDIUM / DEEP 的 read-path 要更清晰

这属于**结构优化**，不是功能削减。

**建议：**
在主 `SKILL.md` 顶部增加 reading matrix，例如：

| Depth | 默认读取 |
|---|---|
| LIGHT | 主流程 + `templates/plan.md` + 必要时 `self-review.md` |
| MEDIUM | 上述 + `engineering-review*.md` + `plan-gate.md` |
| DEEP / protocol / schema / workflow | 上述 + `final-plan-gate.md` |

注意：这不是让 DEEP 少读，而是让 LIGHT 少被 DEEP 噪音淹没。

---

## 七、禁止性优化清单

以下动作当前证据下应视为**禁止性优化**，除非先证明功能和质量都等价覆盖。

### 禁止 1：以“下游没 parser 消费”为理由删除显式质量机制

这会忽略：
- eval
- tuning history
- human audit surfaces
- skill 自身语义

---

### 禁止 2：把 authority / contradiction / experience / self-evaluation 全收进内部推理

这会把质量机制从“可检查”退化成“希望模型记得”。

---

### 禁止 3：为了减少主 skill 行数，移除高风险规则而不提供更清晰的升级式读取路径

这会让 skill 变短，但不一定更可靠。

---

### 禁止 4：把当前多个显式 section 直接视为“历史冗余”，而不经过 failure-mode 对照

正确问题应是：

> 这个 section 解决了哪个历史失败？
> 如果不用它，替代机制是什么？

---

## 八、如果要改，正确的实施顺序

### Phase 1：先做 contract closure

1. 明确 `risks` 的 canonical conditional 地位
2. 统一澄清规则表述
3. 确认哪些质量 section 是 conditional required，而不是 purely optional

### Phase 2：再做结构重组

1. 给主 `SKILL.md` 增加 read matrix
2. 压缩重复摘要，保留 pointer
3. 重新划分 detailed vs compact reference 责任

### Phase 3：最后才考虑哪些 section 可以条件省略

前提：
- eval 要更新
- 历史 tuning 相关 failure mode 要确认仍被覆盖
- review / exec / human audit 还有替代可见面

---

## 九、回归标准

任何针对 `pge-plan` 的优化，如果声称“没有减少功能约束”，至少要满足下面四类回归标准。

### 1. 功能覆盖回归

必须证明仍完整覆盖：
- research.v3 adapter
- direct prompt planning
- fast-adopt fidelity
- issue-file canonical output
- final gate authorization
- assumptions route
- workflow handoff boundary
- verification coupling / parallel safety

### 2. 质量机制回归

必须证明仍能显式处理：
- contradiction
- override
- authority escalation
- `/ needs_confirmation`
- Core Friction
- experience-context preservation
- high-risk protocol coherence

### 3. eval 回归

至少重跑并关注：
- `skills/pge-plan/evals/evals.json`
- `skills/pge-plan/evals/joint-evals.json`

尤其要盯住：
- `Plan Grill Log`
- `Decision Overrides`
- `Experience Context Check`
- fast-adopt semantic fidelity

### 4. 对抗样例回归

要验证优化后不会出现：
- faster but vaguer planning
- fewer visible contradictions
- more silent assumptions
- external-plan adoption drift
- authority downgrade hidden in prose

---

## 十、最终立场

`pge-plan` 的问题不能被概括为“太长，所以该删”。更准确的说法是：

> 它当前把很多质量机制、协议细则、失败模式修复痕迹和下游对齐说明，过度堆叠在主 `SKILL.md` 中，导致结构负担很重；但这些内容里相当一部分并不是冗余，而是现役质量护栏。

因此，正确的优化方向是：

1. **保留现有质量上限**
2. **优先做 contract closure**
3. **只做不降质的结构重组**
4. **把“可见质量约束”留在可审计表面上，而不是退回内部推理**

一句话总结：

> `pge-plan` 需要的不是“更轻”，而是“在不损伤质量机制的前提下，更清楚地组织这些机制”。
