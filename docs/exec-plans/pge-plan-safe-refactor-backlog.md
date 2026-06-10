# pge-plan 安全改造 Backlog

## 目的

这份 backlog 只包含**在不降低 `pge-plan` 功能覆盖、质量机制、显式可审计性**前提下可推进的改造项。

它不是“轻量化计划”，而是“保质量前提下的结构对齐与 contract closure 工作清单”。

配套文档：

- `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md`
- `docs/exec-plans/pge-plan-change-allowlist-denylist.md`

---

## 使用原则

每个 backlog 项在实施前都要满足：

1. 不削弱现有功能面
2. 不削弱现有质量护栏
3. 不把显式约束收回模型内部隐式推理
4. 有明确的回归面：skill / template / eval / downstream / history

---

## Backlog 概览

### B1. 统一 `risks` 的 canonical conditional 地位
### B2. 统一澄清规则表述与 authority 升级边界
### B3. 给主 `SKILL.md` 增加 depth-based reading matrix
### B4. 压缩主 `SKILL.md` 中重复的 gate/review 摘要，但不降规则强度
### B5. 重划 `engineering-review*.md` 的职责边界
### B6. 将 input adaptation 细则迁出主 `SKILL.md` 到专用 reference
### B7. 为现有质量机制补 failure-mode rationale
### B8. 评估哪些 section 可以“条件显式化”，而不是默认删掉

---

## B1. 统一 `risks` 的 canonical conditional 地位

### 目标

补上 `risks` 在 `pge-plan` / template / review / historical plans 之间的契约缺口。

### 为什么现在就该做

当前证据显示：

- `pge-review` 会读取 `risks`
- `pge-plan` 主 skill 已把 `Risks` 当风险承载面之一
- 历史 plan 广泛包含 `## risks`
- 但 template / canonical contract 还没有正式把它定级为稳定 conditional section

这属于 **contract closure**，不是风格优化。

### 影响文件

- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/templates/plan.md`
- `skills/pge-review/SKILL.md`
- 必要时相关 eval / docs

### 建议改法

把 `## risks` 明确为 **canonical conditional section**：

在以下情况要求显式产出：
- cross-issue verification coupling / parallel safety risk
- migration / rollout risk
- protocol / schema / route change risk
- verification fragility
- forbidden-zone risk

trivial LIGHT case 可省略。

### 为什么安全

- 不新增能力
- 不改变 route 语义
- 只是在现有活跃语义上补齐 contract

### 必要回归

- `pge-review` 读取 `risks` 的预期仍成立
- historical plan shape 不被削弱
- `pge-exec` 的 issue brief / risk-triggered hints 不被弱化

---

## B2. 统一澄清规则表述与 authority 升级边界

### 目标

让“何时问 / 问几轮 / 什么时候必须不自作主张”在主 skill 与 gate reference 里一致。

### 当前问题

现有表述同时存在：
- 强单问倾向
- `ASK_USER (max 1)` 风格表达
- gate reference 中允许必要时最小完整澄清

这容易让模型在高风险场景过度压缩澄清。

### 影响文件

- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/references/plan-gate.md`
- 必要时 `templates/plan.md` / docs

### 建议改法

统一成：

- 默认：**单轮澄清**
- 例外：**若多个耦合事实共同决定 goal / scope / acceptance / safety，可同轮合并提问**
- Core Friction / `/ needs_confirmation` 仍不得 silent assume

### 为什么安全

- 不放松 authority 约束
- 只是减少表述歧义
- 有利于保持质量而不是逼迫模型少问

### 必要回归

- research blocker 不会被 plan 吞掉
- User Challenge / Core Friction 边界不后退
- headless 行为仍然受限

---

## B3. 给主 `SKILL.md` 增加 depth-based reading matrix

### 目标

改善 skill 热路径导航，让 LIGHT 不被 DEEP 噪音淹没，同时确保高风险场景仍能稳定命中必要 reference。

### 影响文件

- `skills/pge-plan/SKILL.md`

### 建议改法

在前部加入简洁 read matrix，例如：

| Depth / Surface | 默认读取 |
|---|---|
| LIGHT | 主流程 + `templates/plan.md` + 必要时 `self-review.md` |
| MEDIUM | 上述 + `engineering-review*.md` + `plan-gate.md` |
| DEEP / protocol / schema / workflow | 上述 + `final-plan-gate.md` |

### 为什么安全

- 不减少规则
- 只是把升级路径前置
- 可以减少错误读取，而不是减少能力

### 必要回归

- LIGHT 仍能命中必要 sanity
- MEDIUM/DEEP 不会漏读关键 gate/reference
- fast-adopt / protocol-change case 仍会进入高风险路径

---

## B4. 压缩主 `SKILL.md` 中重复的 gate/review 摘要，但不降规则强度

### 目标

减少主 `SKILL.md` 中与 references 高度重复的描述，让主文件更偏：
- 入口导航
- 核心硬规则
- 何时升级读取

而 detailed semantics 归 reference 持有。

### 影响文件

- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/references/engineering-review.md`
- `skills/pge-plan/references/engineering-review-gate.md`
- `skills/pge-plan/references/plan-gate.md`
- `skills/pge-plan/references/self-review.md`

### 建议改法

保留在主 skill 中：
- PER 是 hardening，不是 authorization
- Final Plan Gate 是唯一 execution authorization gate
- ready route 的硬条件
- 何时必须读哪个 reference

把重复的详细 layer / checklist / dimension 说明收缩为 pointer。

### 为什么安全

- 这是结构重组，不是能力裁剪
- 前提是 pointer 明确、升级路径不丢

### 风险

- 如果压太过，可能造成“规则还在 reference，但 skill 热路径看不到”

### 必要回归

- plan gate 六层语义仍可稳定命中
- PER findings consumption 规则不丢
- self-review 仍能进入正确时机

---

## B5. 重划 `engineering-review*.md` 的职责边界

### 目标

解决两个 engineering review reference 职责模糊、内容重叠的问题。

### 注意

这项 backlog **不是先验要求合并**，而是先要求把职责讲清楚。

### 影响文件

- `skills/pge-plan/references/engineering-review.md`
- `skills/pge-plan/references/engineering-review-gate.md`
- `skills/pge-plan/SKILL.md`

### 两种安全路径

#### 路径 A：保留双文件，但清晰分工
- `engineering-review.md`：detailed semantics / rationale / failure-mode guidance
- `engineering-review-gate.md`：compact hot-path / checklist summary

#### 路径 B：证明双文件确实重复后再合并
- 合并为一个 authoritative file
- 主 skill 中仅保留 pointer

### 为什么安全

- 先整理责任，不先删内容
- 能避免“以简化为名删除 hot-path guidance”

### 必要回归

- PER 触发条件保持一致
- Inconsistency Grill / Experience Context / Failure Mode / Closed-loop slicing 不丢
- main skill 对 PER 的调用时机仍清楚

---

## B6. 将 input adaptation 细则迁出主 `SKILL.md` 到专用 reference

### 目标

降低主 `SKILL.md` 的认知拥挤度，但不减少 input adaptation 规则本身。

### 影响文件

- `skills/pge-plan/SKILL.md`
- 新增如：`skills/pge-plan/references/input-adaptation.md`
- 可能还涉及 authority / source-priority 相关 reference

### 建议改法

主 skill 只保留四类入口：
1. direct prompt
2. `research.v3`
3. explicit external plan / fast-adopt
4. bare invocation

详细规则迁出：
- source priority
- selector + trailing constraints
- research.v3 field mapping
- obsolete source handling
- non-canonical selected source rules

### 为什么安全

- 只是迁位置
- 规则仍保留
- 通过 read matrix 和明确 pointer 保证高风险 case 不漏读

### 风险

- 迁出后如果 pointer 不清楚，会让 skill 入口更弱

### 必要回归

- research.v3 route gate 不退化
- fast-adopt fidelity 不退化
- obsolete source rejection 不退化
- bare invocation confirmation 不退化

---

## B7. 为现有质量机制补 failure-mode rationale

### 目标

减少未来维护者把质量 section 误判成冗余装饰的风险。

### 影响文件

- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/references/*.md`
- 必要时 `docs/exec-plans/*`

### 建议改法

对下面这些机制补一句“它在防什么”：
- `Plan Grill Log`
- `Decision Overrides`
- `Self-Evaluation`
- `Experience Context Check`
- `Assumptions`
- `Quality Check Results`（若保留）

### 为什么安全

- 纯文档化增益
- 不改变 contract 语义
- 有助于防止错误轻量化

### 必要回归

- 无功能回归风险，但要避免新增与现有权威规则冲突的解释文本

---

## B8. 评估哪些 section 可以“条件显式化”，而不是默认删掉

### 目标

把真正可能收轻的 section 变成**经过举证后的 conditional visible**，而不是“看起来不重要就删”。

### 范围

只讨论：
- `Plan Grill Log`
- `Self-Evaluation`
- `Experience Context Check`
- `Quality Check Results`

### 这项 backlog 不是直接改文件

它的目标是先给出判定规则：
- 哪些场景必须显式
- 哪些场景可以省略
- 哪些场景可以折叠呈现

### 为什么安全

- 先建 guardrail，再谈收轻
- 避免一步到位误删质量面

### 必要举证

- eval 覆盖这些 section 的哪些期望
- tuning 历史里哪些修复依赖它们
- history plans 中哪些场景真的在用
- 下游 review / exec / human audit 是否还有替代面

### 这项 backlog 的完成标准

不是“已经删掉了”，而是：

> 得到一张经过证据支撑的 conditional visibility policy。

---

## 不在当前 backlog 内的事项

这些工作当前不应优先推进，或必须等上面 backlog 完成后再看。

### 暂不推进 1：默认删除显式质量 section

包括但不限于：
- 删除 `Plan Grill Log`
- 删除 `Self-Evaluation`
- 删除 `Experience Context Check`
- 删除 `Decision Overrides`

### 暂不推进 2：为了短而短的主 `SKILL.md` 瘦身

如果缩短主 skill 的方式是：
- 删除关键高风险规则
- 让 pointer 不清楚
- 把 DEEP/authority/fidelity case 的规则藏太深

则不应推进。

### 暂不推进 3：改弱 fast-adopt / authority / coupling 规则

这类规则当前都应视为高价值质量机制，而非负担。

---

## 推荐执行顺序

### 第一组：先做 contract closure + clarity
1. B1 `risks` canonical conditional
2. B2 澄清规则统一
3. B3 read matrix

### 第二组：再做结构重组
4. B4 主 `SKILL.md` 去重归并
5. B5 engineering-review references 责任重划
6. B6 input adaptation 细则迁出

### 第三组：最后做质量显式面条件化评估
7. B7 failure-mode rationale 补全
8. B8 conditional visibility policy

---

## 每项 backlog 的统一回归要求

每个 backlog 项实施后，都至少检查：

1. **功能覆盖**
   - research.v3
   - direct prompt
   - fast-adopt
   - issue-file plan
   - final gate
   - assumptions route
   - workflow handoff
   - verification coupling

2. **质量机制覆盖**
   - contradiction
   - override
   - authority escalation
   - `/ needs_confirmation`
   - Core Friction
   - experience preservation
   - source fidelity
   - protocol coherence

3. **eval 回归**
   - `skills/pge-plan/evals/evals.json`
   - `skills/pge-plan/evals/joint-evals.json`

4. **对抗回归**
   - 不出现 faster but vaguer planning
   - 不出现 fewer visible contradictions
   - 不出现 more silent assumptions
   - 不出现 adoption drift

---

## 最终一句话

> 这个 backlog 的目标不是把 `pge-plan` 变轻，而是把它在**不失去现有质量护栏**的前提下，变得更清楚、更一致、更可维护。