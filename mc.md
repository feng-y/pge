**状态：补充 Research 触发器｜主线：PGE Research 重构｜当前问题：目标本身不适合直接渐进推进｜防漂移：只定义 Research 如何识别并交给 Plan，不展开 Plan 细节**

这个场景很重要，而且和前面的 **Implementation Friction Gate** 不是一类。

前面那个是：

```text
我理解的系统模型 ≠ 代码实际实现
```

你现在说的是：

```text
用户目标本身 ≠ 当前 repo 可安全承载的渐进式执行条件
```

所以需要新增一个 Research 触发器：

# Progressive Feasibility Gate

中文可以叫：

> **渐进可行性检查**

它不是判断“目标对不对”，而是判断：

> **这个目标能不能直接作为本轮 Plan 的执行目标。**

---

# 1. 核心定义

```text
Progressive Feasibility Gate triggers when the user goal is valid,
but cannot be safely planned as a direct incremental change because the repo is not structurally ready.
```

中文：

> 当用户目标本身合理，但当前 repo 的结构、接口协议、模块边界、验证条件不支持直接渐进式推进时，Research 必须触发渐进可行性检查。

它解决的是：

```text
目标合理，但不能直接干。
必须先让 repo 具备承载这个目标的结构条件。
```

---

# 2. 必须触发的信号

出现下面任意一类，就触发。

## P1. 多阶段 / 多模块接口协议同时变化

例如：

```text
要改一个目标，但会同时影响：
- Research output protocol
- Plan input adapter
- Exec consumption
- README / CLAUDE.md authoritative docs
- review/challenge assumptions
```

这说明它不是一个普通功能改动，而是 **跨阶段协议变更**。

---

## P2. 无法做端到端验证

例如：

```text
目标最终效果需要完整 Research → Plan → Exec 跑通才能验证，
但当前阶段没有稳定 harness / test / sample artifact 支持 E2E 检查。
```

这时直接 Plan 目标会很危险，因为：

```text
改完不知道是不是真的成立
只能靠人工感觉
```

---

## P3. 直接实现会造成结构性破坏

例如：

```text
直接删除旧 research.v2 字段，
会让 plan 旧消费逻辑断掉。
```

或者：

```text
直接改 Research 语义，
会导致 README / CLAUDE.md / pge-plan 对阶段职责理解不一致。
```

这类问题不是局部 bug，而是结构性破坏。

---

## P4. 当前 repo 不具备承载目标的抽象边界

例如：

```text
用户想做“轻量 Research 协议”，
但当前 repo 里 research 协议、plan 消费、docs contract 混在一起，
没有清晰 adapter / compatibility / protocol boundary。
```

这时第一步不是做最终目标，而是先建立能安全迁移的结构。

---

## P5. 用户目标需要大规模同步修改才能看起来完成

例如：

```text
要让所有 active docs / skills / references 全部一次性切到 research.v3。
```

这类目标表面上完整，实际风险大：

```text
改动面大
难验证
容易漏
容易让 agent 为了“全改完”扩大 scope
```

---

## P6. 目标包含多个不同性质的变化

例如同一个目标里混了：

```text
- 协议简化
- workflow graph 重写
- plan adapter
- README 更新
- CLAUDE.md 更新
- old docs drift 清理
- validation checklist
```

这些应该分批，不应该一个 Plan 吃掉。

---

# 3. 不触发的情况

不要把这个 gate 泛化。

不触发：

```text
1. 改动跨多个文件，但接口协议不变
2. 有清晰测试或验证路径
3. 可以通过一个 vertical slice 端到端完成
4. 改动面大但机械一致，例如批量重命名且可 grep 验证
5. 只是代码丑，不影响目标推进
```

判断标准很简单：

```text
能否形成一个小的、可验证的、不会破坏结构的第一轮 Plan？
```

不能，就触发。

---

# 4. Gate 输出格式

Research 不要在这里写详细分期计划。
只输出一个小节，告诉 Plan：**不要直接 plan 最终目标，先 plan 结构准备阶段。**

```md
## Progressive Feasibility

- Direct goal:
- Why direct planning is unsafe:
- Blocking structural constraint:
- Required staging:
- First plannable objective:
- What must be deferred:
```

例子：

```md
## Progressive Feasibility

- Direct goal: Refactor pge-research into a lightweight spec-discovery workflow.
- Why direct planning is unsafe: The research protocol is consumed by README, CLAUDE.md, and pge-plan. Direct deletion of old fields may break downstream assumptions.
- Blocking structural constraint: There is no explicit research.v3 → plan input adapter yet.
- Required staging: First introduce the new research protocol boundary and minimal Plan adapter, then migrate active docs and clean old fields.
- First plannable objective: Make research.v3 authoritative in pge-research and add pge-plan compatibility consumption without removing all legacy references.
- What must be deferred: Full cleanup of all historical docs, broad Plan simplification, Exec changes, and end-to-end workflow redesign.
```

---

# 5. 和 Implementation Friction Gate 的区别

| Gate                         | 触发原因           | 解决问题                     |
| ---------------------------- | -------------- | ------------------------ |
| Implementation Friction Gate | 理解模型和代码实现冲突    | 防止 Plan 基于错误系统理解         |
| Progressive Feasibility Gate | 用户目标不能直接安全渐进推进 | 防止 Plan 把过大的结构性目标硬塞进一轮执行 |

一句话区分：

```text
Implementation Friction = 我们理解错了 repo。
Progressive Feasibility = 目标没错，但 repo 现在扛不住直接做。
```

---

# 6. Research 协议应补充这个条件字段

不要把它变成默认大字段。
作为 conditional section：

```md
## Conditional: Progressive Feasibility

Use only when the goal cannot be safely planned as a direct incremental change.

- direct_goal:
- direct_planning_risk:
- structural_blocker:
- first_plannable_objective:
- deferred_goal_parts:
- plan_instruction:
```

其中最重要的是：

```text
first_plannable_objective
```

这会告诉 Plan：

> 你现在不是去 plan 用户最终目标，而是先 plan 第一个结构准备目标。

---

# 7. 对 Plan 的影响

Research 触发这个 gate 后，Plan 不应该问：

```text
如何一次性完成最终目标？
```

而应该问：

```text
第一批次如何让 repo 具备继续推进最终目标的结构条件？
```

Plan 的 selected approach 应该围绕：

```text
最小结构准备
协议边界
兼容 adapter
可验证迁移点
不破坏下游消费
```

而不是一次性完成：

```text
所有 skill 重写
所有 docs 清理
所有 plan/exec 适配
所有旧协议删除
```

---

# 8. 放进 Codex/CC 规划的新增文本

可以直接补进你的重构任务书：

```text
Add a Progressive Feasibility Gate to pge-research.

This gate triggers when the user goal is valid but cannot be safely planned as a direct incremental change because the repo is not structurally ready.

Trigger when evidence shows:
1. the goal requires cross-stage or multi-module interface/protocol changes;
2. no reliable end-to-end verification exists for the final goal;
3. direct implementation would cause structural breakage;
4. current repo boundaries are not ready to support the target change;
5. the target requires large synchronized edits across protocol producers and consumers;
6. the goal mixes multiple change types that should be staged.

When triggered, Research must not produce a full staged plan.
It should identify:
- direct_goal
- direct_planning_risk
- structural_blocker
- first_plannable_objective
- deferred_goal_parts
- plan_instruction

The Plan stage must then plan the first plannable objective, not the entire final goal.
```

---

# 9. Research 最终触发体系

现在 Research 应该有三个核心触发器：

```text
1. Intent Discovery Trigger
   用户目标/成功标准/范围不清楚。

2. Implementation Friction Gate
   理解模型和实际实现冲突，且会影响 Plan。

3. Progressive Feasibility Gate
   目标合理，但当前 repo 结构不支持直接渐进式执行。
```

这三个够了。

不要再扩一堆抽象触发词。

---

# 10. 最终定位

Research 默认还是轻量 spec-discovery / brainstorming。

只有遇到两类工程风险才增强：

```text
理解错了实现
目标暂时不能直接做
```

最终一句话：

> **Research 不只是问清楚目标，还要判断这个目标能不能直接进入 Plan。若目标正确但 repo 结构、协议边界、验证能力不支持直接推进，Research 必须把最终目标降解为“第一批可规划的结构准备目标”，并把剩余目标显式 defer 给后续阶段。**
