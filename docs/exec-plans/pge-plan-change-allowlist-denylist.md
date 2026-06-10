# pge-plan 变更 Allowlist / Denylist

## 用途

这份清单用于约束后续对 `pge-plan` 的调整，确保改动属于：

- contract closure
- 结构整理
- 导航优化
- 权威归并

而不属于：

- 功能删减
- 质量护栏弱化
- 把显式约束收回到隐式推理
- 以“更快”为名降低 planning runtime 质量

这份清单默认和下面文档一起使用：

- `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md`

---

## 核心原则

### 原则 1：质量等价优先于简化

成功标准不是：
- 文件更短
- section 更少
- 阅读路径更轻

成功标准是：
- 现有功能覆盖仍完整
- 现有质量机制仍成立
- contradiction / authority / assumption / fidelity / coupling 仍然可见、可审、可回归

---

### 原则 2：不能因为缺少 parser consumer 就删除显式质量机制

以下内容即使不是 `pge-exec` 的硬 parser 字段，也可能是：
- eval 依赖
- tuning 后留下的失败模式修复面
- human audit surface
- planning 质量护栏

所以：

> 没有 machine consumer ≠ 没有 protocol value

---

### 原则 3：优先做保真重组，不做删减式轻量化

允许做：
- 重组
- 合并重复表达
- 改善导航
- 明确何时读哪个 reference
- 修补 contract gap

不允许直接做：
- 默认删除现有质量 section
- 降低高风险场景的显式约束强度
- 把原来可审计的判断变成模型内部隐式行为

---

## 一、Allowlist：允许做的改动

这些改动在当前证据下是安全方向，但仍应做回归验证。

### A1. contract closure

允许：

- 明确 `risks` 的 canonical conditional 地位
- 统一 route / verdict / state vocabulary 的权威来源
- 补齐 template / SKILL / review / exec 之间的字段不一致
- 明确哪些 section 是 conditional required，哪些是 optional when useful

**适用对象：**
- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/templates/plan.md`
- `skills/pge-review/SKILL.md`
- 相关 reference / eval / docs

---

### A2. 导航与读取路径优化

允许：

- 在主 `SKILL.md` 顶部加入 depth-based reading matrix
- 明确 LIGHT / MEDIUM / DEEP / protocol-change 场景分别需要读哪些 references
- 把“何时读哪个 reference”前置到 skill 热路径

**允许的目标：**
- 让 LIGHT task 少受 DEEP 噪音影响
- 让高风险 task 更稳定命中必要 reference

**不改变的内容：**
- 规则本身的约束强度

---

### A3. 重复表达归并

允许：

- 将主 `SKILL.md` 中对 gate/review 的重复摘要收缩为 pointer
- 让 reference 成为单一 detailed authority
- 将高度重复的规则搬迁到单一 reference 文件

**前提：**
- skill 入口仍能知道何时必须读这些 reference
- 不会让关键规则“存在于仓库里，但触发时看不到”

---

### A4. reference 责任重划

允许：

- 重新划分 `engineering-review.md` 与 `engineering-review-gate.md` 的职责
- 重新划分 input adaptation / authority / clarification / flow 等 reference 的职责
- 把主 `SKILL.md` 中过长的输入适配细则迁出到 reference

**前提：**
- 新职责边界更清晰，而不是更模糊
- 迁出后仍有明确升级路径

---

### A5. 条件化显式 section，而不是直接删除

允许：

- 把某些质量 section 从“总是显式”改成“在满足风险条件时显式”
- 把 trivial LIGHT case 的输出面适度收轻

**但必须满足：**
- MEDIUM/DEEP / authority-heavy / contradiction-present / docs/exec-plans sourced / protocol-change 场景仍显式输出
- eval、review、human audit 仍有替代可见面

**潜在适用对象：**
- `Plan Grill Log`
- `Self-Evaluation`
- `Experience Context Check`
- `Quality Check Results`

注意：这类变更必须先证明不会削弱质量。

---

### A6. 文档化“为什么存在”

允许：

- 为现有 section 增加 failure-mode rationale
- 在 reference 中解释某个 check / section 是为了防哪类真实错误
- 把 tuning / eval 的来历折叠成更稳定的指导语

这类改动能帮助后续维护者不再把质量机制误判成冗余。

---

## 二、Denylist：禁止做的改动

以下动作当前应视为禁止，除非先证明功能与质量都等价覆盖。

### D1. 直接删除质量显式化 section

禁止直接删除：

- `Plan Grill Log`
- `Decision Overrides`
- `Self-Evaluation`
- `Experience Context Check`
- `Assumptions`
- success-shape → acceptance → verification trace

**禁止原因：**
这些 section 当前与：
- 主 skill 语义
- reference 规则
- template
- eval
- tuning 历史
- 历史 plan 工件

存在真实耦合。

---

### D2. 因为“下游不解析”就取消显式记录面

禁止将下面这类判断收回模型内部：

- contradiction 是否存在
- scope exception 是否 justified
- authority escalation 为什么发生
- assumption 是否只是低风险默认
- experience context 是否被 preserved

**禁止原因：**
这会把“可审计质量约束”退化成“希望模型自己记得”。

---

### D3. 为了主文件变短，弱化高风险规则

禁止：

- 删除 authority classification 的核心约束
- 删除 `/ needs_confirmation` 的显式闭环
- 删除 Core Friction / Safety Amplifier 相关规则
- 删除 fast-adopt fidelity 的显式保真约束
- 删除 verification coupling / parallel safety 的明确要求

**禁止原因：**
这些都不是文风冗余，而是失败模式防线。

---

### D4. 以“收轻 LIGHT”之名误伤 MEDIUM/DEEP

禁止：

- 把高风险场景需要的显式 section 一并从模板中拿掉
- 用 LIGHT 场景的优化逻辑重写整个 plan contract
- 让 MEDIUM/DEEP 失去 contradiction / override / authority / fidelity 的可见面

---

### D5. 在没有替代机制前合并或删除 reference

禁止：

- 仅因为内容相似，就删除 `engineering-review-gate.md` 或 `engineering-review.md`
- 在没有新 read-path 的前提下，把大量规则迁出主 skill
- 让“必须读的规则”只存在于仓库，但没有触发时的升级指示

---

### D6. 将“更快”视为独立目标

禁止以下 reasoning：

- “这个 section 不影响 parser，所以删掉更快”
- “这个记录面只是给人看，所以删掉更干净”
- “模型理论上会自己做，所以不必显式写”

**禁止原因：**
对 `pge-plan` 来说，planning runtime 的质量高于速度。

---

## 三、Conditional zone：可以讨论，但必须先举证

下面这些改动不是绝对禁止，但必须先完成举证，再能进入实施。

### C1. `Plan Grill Log` 改成 conditional required

可以讨论，但必须先证明：
- 哪些场景省略后不会损失 contradiction visibility
- eval 如何更新
- review / human audit 是否仍能追到 scope exception / override path

**最低建议：**
- trivial LIGHT 可省略
- MEDIUM/DEEP、docs/exec-plans sourced、contradiction/override present 必须保留

---

### C2. `Self-Evaluation` 改成 conditional visible

可以讨论，但必须先证明：
- Core Friction / User Challenge / headless assumption handling 仍被显式约束
- 不会回归 tuning log 里已经修过的问题

**最低建议：**
- trivial LIGHT 可省略
- authority-heavy / `/ needs_confirmation` / assumption-heavy / headless case 保留

---

### C3. `Experience Context Check` 改成折叠呈现

可以讨论，但必须先证明：
- human-facing / artifact-facing success shape 仍不被 silently dropped
- eval 仍能验证它
- review 仍能看见它被消费了

**允许的方向：**
- 折叠进 PER / acceptance / verification record

**不允许的方向：**
- 直接取消体验质量的显式规划义务

---

### C4. `Quality Check Results` 真正改成 when useful

可以讨论，而且是最有希望安全收轻的一项。

但仍应先证明：
- 哪些 case 依赖它做 compact review summary
- 历史使用面是否只是 convenience，不是实际质量闭环

---

## 四、必须保留的能力面

以下能力面是 refactor 的保底约束，任何实现方案都必须完整覆盖。

### 必须保留

- issue-file canonical output
- `plan_gate PASS` 才允许 ready route
- direct prompt planning
- `research.v3` adapter
- fast-adopt semantic fidelity
- verification coupling / parallel safety
- workflow handoff adapter boundary
- PER vs Final Gate 分层
- assumptions support
- high-risk `plan_gate_inputs`
- contradiction / override / authority / fidelity 的显式质量闭环

---

## 五、每次改动前必须回答的问题

在动 `pge-plan` 前，至少回答下面这些问题：

1. 这项改动影响的是功能契约，还是表达组织？
2. 它当前在防什么失败模式？
3. 如果删/折叠它，替代机制是什么？
4. 替代机制是否仍然**显式可审计**？
5. `pge-exec` / `pge-review` / eval / 历史 plan 工件 / human audit 中，谁会受影响？
6. 这项改动是让 runtime 更清楚，还是只是更短？

如果回答不清楚，就不应该先动。

---

## 六、推荐的实施优先级

### Priority 1：安全且必要

1. `risks` contract closure
2. 统一澄清规则措辞
3. 加入 read matrix
4. 补文档说明现有质量机制的 failure-mode value

### Priority 2：结构整理

1. 主 `SKILL.md` 压缩重复摘要
2. 明确 references 的单一权威边界
3. 重组 input adaptation / authority / clarification 细则位置

### Priority 3：条件化优化（需举证）

1. `Plan Grill Log` 是否可 conditional required
2. `Self-Evaluation` 是否可按场景显式
3. `Experience Context Check` 是否可折叠展示
4. `Quality Check Results` 是否可进一步弱化默认存在

---

## 七、回归要求

任何进入实施的改动，至少要通过四类回归。

### R1. 功能覆盖回归

证明仍完整覆盖：
- research.v3
- direct prompt
- fast-adopt
- issue files
- final gate
- assumptions route
- workflow handoff
- verification coupling

### R2. 质量机制回归

证明仍显式处理：
- contradiction
- override
- authority escalation
- `/ needs_confirmation`
- Core Friction
- experience preservation
- source fidelity
- protocol coherence

### R3. eval 回归

至少检查：
- `skills/pge-plan/evals/evals.json`
- `skills/pge-plan/evals/joint-evals.json`

### R4. 对抗回归

确认优化后不会出现：
- faster but vaguer planning
- fewer visible contradictions
- more silent assumptions
- adoption drift
- authority downgrade hidden in prose

---

## 最终一句话规则

> 对 `pge-plan` 的任何优化，只有在**不减少功能覆盖、不削弱显式质量护栏、不降低可审计性**的情况下，才算允许改动。
