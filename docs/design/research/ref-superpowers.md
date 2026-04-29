# 参考调研：obra/superpowers — Brainstorming 机制

> 来源：github.com/obra/superpowers (MIT License)
> 调研日期：2026-04-29
> 调研范围：brainstorming skill、writing-plans skill、using-superpowers orchestration

---

## 1. 核心设计：Raw Intent → Clearer Spec 的完整流程

Superpowers 的核心理念是 **"design before code"** — agent 看到用户要构建东西时，不直接写代码，而是先退一步问清楚用户真正想做什么。

### 1.1 完整管线

```
raw intent → brainstorming → spec document → writing-plans → execution
```

每个阶段有 hard gate：前一阶段未完成+用户未批准，不得进入下一阶段。

### 1.2 Brainstorming Skill 的 9 步 Checklist

| 步骤 | 内容 | Gate |
|------|------|------|
| 1 | 探索项目上下文（文件、docs、recent commits） | — |
| 2 | 判断是否需要 visual companion（可选） | — |
| 3 | 逐个提问澄清（one question at a time） | — |
| 4 | 提出 2-3 种方案 + trade-offs + 推荐 | — |
| 5 | 分段呈现设计，每段后等用户确认 | user approval per section |
| 6 | 写 spec 文档到 `docs/superpowers/specs/` | — |
| 7 | Spec 自审（placeholder/矛盾/歧义/scope） | — |
| 8 | 用户审阅 spec 文件 | user approval |
| 9 | 转入 writing-plans skill | — |

**关键约束（HARD-GATE）：**
> "Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity."

### 1.3 Anti-Pattern 防护

Superpowers 明确列出了 agent 常见的跳过设计的借口，并逐一封堵：

| Agent 内心想法 | Superpowers 的回应 |
|---|---|
| "This is too simple to need a design" | 每个项目都走这个流程，简单项目的 spec 可以短，但必须有 |
| "I need more context first" | Skill check 在澄清问题之前 |
| "Let me explore the codebase first" | Skill 告诉你怎么探索 |
| "The skill is overkill" | 简单的事情会变复杂，用它 |
| "I'll just do this one thing first" | 做任何事之前先检查 |

---

## 2. 前置澄清流程的具体做法

### 2.1 提问策略

- **一次只问一个问题** — 不用多问题轰炸用户
- **优先用选择题** — 比开放式问题更容易回答
- **聚焦三个维度**：purpose（目的）、constraints（约束）、success criteria（成功标准）

### 2.2 Scope 前置检测

在深入提问之前，先评估 scope：
- 如果请求描述了多个独立子系统（如"build a platform with chat, file storage, billing, and analytics"），**立即标记**
- 不要花时间细化一个需要先分解的项目
- 帮用户分解为子项目 → 每个子项目走独立的 spec → plan → implementation 循环

### 2.3 方案探索

- 必须提出 **2-3 种方案** + trade-offs
- 以推荐方案开头，解释为什么推荐
- 对话式呈现，不是文档式

### 2.4 分段呈现设计

- 设计按复杂度分段：简单的几句话，复杂的 200-300 词
- 每段后问用户"到目前为止看起来对吗？"
- 覆盖：architecture, components, data flow, error handling, testing
- 随时准备回退澄清

---

## 3. Spec 文档与质量门

### 3.1 Spec 自审 Checklist

写完 spec 后，agent 自己做四项检查：

1. **Placeholder 扫描** — 任何 TBD/TODO/不完整部分？修掉
2. **内部一致性** — 各部分是否矛盾？架构是否匹配功能描述？
3. **Scope 检查** — 是否聚焦到可以用单个 plan 实现？
4. **歧义检查** — 任何需求是否可以有两种解读？选一个，明确化

### 3.2 Spec Reviewer（可选 subagent）

有独立的 `spec-document-reviewer-prompt.md` 模板，可以 dispatch subagent 做 spec review：
- 检查完整性、一致性、清晰度、scope、YAGNI
- 校准标准："Only flag issues that would cause real problems during implementation planning"
- 输出：Status (Approved / Issues Found) + Issues + Recommendations

### 3.3 用户审阅 Gate

Spec 自审通过后，必须等用户审阅：
> "Spec written and committed to `<path>`. Please review it and let me know if you want to make any changes before we start writing out the implementation plan."

---

## 4. 从 Spec 到 Plan 的衔接

### 4.1 Writing-Plans Skill

Spec 批准后，进入 writing-plans：
- 假设执行者是 **"an enthusiastic junior engineer with poor taste, no judgement, no project context, and an aversion to testing"**
- 每个 task 是 2-5 分钟的 bite-sized step
- 必须包含：exact file paths, complete code, verification steps
- 严格禁止 placeholder（TBD/TODO/"similar to Task N"）
- 强制 TDD：RED-GREEN-REFACTOR

### 4.2 Plan 自审

写完 plan 后做三项检查：
1. Spec coverage — 每个 spec 需求都有对应 task？
2. Placeholder scan — 搜索红旗模式
3. Type consistency — 后面 task 的类型/方法名是否与前面定义一致？

---

## 5. 对 PGE Planner Raw-Prompt Ownership 有价值的具体点

### 5.1 直接可借鉴

| Superpowers 做法 | PGE 可借鉴点 |
|---|---|
| HARD-GATE: 设计未批准不得实现 | PGE Planner 的 raw-prompt → spec 阶段可以设类似 gate |
| 一次一个问题 + 优先选择题 | 降低用户认知负担，提高澄清效率 |
| Scope 前置检测 | 在深入澄清前先判断是否需要分解 |
| 2-3 方案 + 推荐 | 让用户做选择而非从零描述 |
| 分段呈现 + 逐段确认 | 增量验证，避免最后才发现方向错误 |
| Spec 自审 4 项 checklist | 可直接复用为 PGE spec quality gate |
| Anti-pattern 表（agent 借口封堵） | 防止 agent 跳过澄清直接执行 |
| "Design for isolation and clarity" 原则 | spec 阶段就考虑可测试性和边界清晰度 |

### 5.2 流程模式可借鉴

- **Brainstorming 是独立 skill，不是 plan 的子步骤** — 它有自己的完整生命周期和 gate
- **Spec 是持久化文档** — 写到文件、commit 到 git，不是对话中的临时产物
- **用户有两次审批点**：设计呈现时（对话中）+ spec 文件审阅时（文件级）
- **Spec → Plan 是单向 handoff** — brainstorming 的唯一出口是 writing-plans

### 5.3 Orchestration 模式

Superpowers 用 `using-superpowers` skill 作为 meta-orchestrator：
- 每条用户消息到达时，先检查是否有 skill 适用
- Brainstorming 优先级最高（process skill > implementation skill）
- 强制 skill 调用：即使只有 1% 可能性也必须检查

---

## 6. 不适用于 PGE 的部分

| Superpowers 做法 | 为什么不适用于 PGE |
|---|---|
| Visual companion（浏览器 mockup） | PGE 是 proving/execution 框架，不涉及 UI mockup |
| Git worktree 隔离 | PGE 当前是 docs/contracts skeleton，不需要 worktree 工作流 |
| Subagent-driven-development | PGE 有自己的 agent 调度模型（pge-execute） |
| TDD RED-GREEN-REFACTOR 强制 | PGE 当前阶段是设计/合约，不是代码实现 |
| Skill 自动发现/安装机制 | PGE 不需要复制 plugin marketplace 体系 |
| "Enthusiastic junior engineer" 假设 | PGE 的执行者模型不同（proving agent with contracts） |
| 完整的 PR/code review 流程 | PGE 有自己的 evaluator/verdict 机制 |

---

## 7. 关键洞察总结

1. **Brainstorming 的本质是 "forced pause"** — 用 hard gate 强制 agent 在动手前停下来思考和澄清。这不是建议，是强制流程。

2. **澄清是结构化的，不是自由对话** — 有明确的 checklist、提问策略（一次一个、优先选择题）、scope 前置检测、方案对比。

3. **Spec 是第一类公民** — 持久化到文件、commit 到 git、有自审和用户审阅两道 gate。不是对话中的临时共识。

4. **Anti-pattern 防护是设计的核心部分** — Superpowers 花了大量篇幅列举和封堵 agent 跳过流程的借口。这说明 agent 的默认行为是跳过澄清直接执行，必须用强约束对抗。

5. **单向 handoff 保证流程完整性** — brainstorming 只能转入 writing-plans，不能跳到任何实现 skill。这防止了"设计到一半就开始写代码"的问题。

---

## 引用来源

- `github.com/obra/superpowers` — README.md
- `skills/brainstorming/SKILL.md` — 完整 brainstorming skill 定义
- `skills/brainstorming/spec-document-reviewer-prompt.md` — spec reviewer 模板
- `skills/writing-plans/SKILL.md` — plan 编写 skill 定义
- `skills/using-superpowers/SKILL.md` — meta-orchestrator skill
- `skills/executing-plans/SKILL.md` — plan 执行 skill
- `skills/subagent-driven-development/SKILL.md` — subagent 执行模式
- `CLAUDE.md` — 贡献者指南（含 PR 质量标准）
