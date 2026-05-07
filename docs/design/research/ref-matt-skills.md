# Matt Skills Study for PGE

> 来源: github.com/mattpocock/skills (45K+ stars)
> 调研日期: 2026-05-07
> 调研目的: 理解 Matt Pocock 的 skill 设计哲学、grilling pattern、CONTEXT.md 机制、以及 "小而可组合" 的 skill 架构

---

## Study Goal

理解 Matt skills 作为最成功的 Claude Code skill 集合，如何通过编码软件工程纪律（对齐访谈、共享词汇、反馈循环、架构思维）来解决 AI coding agent 的四大失败模式。重点关注其 progressive disclosure、domain-language-first、和 composability 设计。

## Original Context

- 作者: Matt Pocock — TypeScript 教育者，前 Vercel/Stately 工程师，Total TypeScript 创建者，AI Hero 平台
- 规模: 45K+ GitHub stars, ~1000 forks
- 定位: "Skills for Real Engineers. Straight from my .claude directory."
- 分发: 通过 skills.sh 包管理器 (`npx skills@latest add mattpocock/skills`)
- 哲学: "not vibe coding" — 面向生产工程的软件基本功编码

## What Problem It Solves

Matt 围绕 AI coding agent 的四大失败模式设计:

1. **"Agent 没做我想要的"**: 开发者意图和 agent 输出之间的错位
   - 解法: `/grill-me` 和 `/grill-with-docs` 在写代码前强制结构化访谈

2. **"Agent 太啰嗦"**: Agent 用 20 个词表达 1 个词能说清的事，因为缺乏领域词汇
   - 解法: `CONTEXT.md`（共享术语表），由 `/grill-with-docs` 构建和维护

3. **"代码不工作"**: 没有反馈循环
   - 解法: `/tdd`（红-绿-重构）、`/diagnose`（结构化调试纪律）

4. **"我们造了一坨泥"**: Agent 加速软件熵增
   - 解法: `/improve-codebase-architecture`（找 "deepening opportunities"）、`/to-prd`

## Core Mechanisms

### Skill 文件结构

```
skill-name/
  SKILL.md           # 主指令 (必需, <100 行理想)
  REFERENCE.md       # 详细文档 (按需加载)
  EXAMPLES.md        # 使用示例
  scripts/           # 工具脚本
```

### SKILL.md 格式

```markdown
---
name: skill-name
description: Brief description. Use when [triggers].
---

[Agent 遵循的指令]
```

`description` 字段是 agent 在 system prompt 中看到的唯一内容（用于决定是否加载）。完整 SKILL.md 内容仅在 skill 被调用时注入。

### 核心 Skills

**工程类 (日常代码工作):**
- `/grill-with-docs` — 对计划进行 grilling，挑战领域模型，内联更新 CONTEXT.md 和 ADR
- `/tdd` — 严格红-绿-重构的垂直切片 TDD
- `/diagnose` — 6 阶段调试纪律（建立反馈循环 → 复现 → 假设 → 插桩 → 修复 → 清理）
- `/to-prd` — 将对话综合为 PRD，发布到 issue tracker
- `/to-issues` — 将计划拆分为垂直切片 issue（tracer bullets）
- `/improve-codebase-architecture` — 找 "deepening opportunities"（浅模块 → 深模块）

**生产力类:**
- `/grill-me` — 对任何计划/设计的无情访谈
- `/caveman` — 超压缩通信模式（~75% token 减少）
- `/write-a-skill` — 创建新 skill 的元 skill

### Grilling Pattern

`/grill-me` 和 `/grill-with-docs` 的核心机制:
1. 在任何代码编写前进行结构化访谈
2. 挑战假设、暴露模糊性、确认范围
3. 产出: 明确的计划 + 更新的 CONTEXT.md + ADR（如果有不可逆决策）

### CONTEXT.md Pattern

受 Eric Evans DDD "ubiquitous language" 启发:
- 项目级共享术语表
- 由 `/grill-with-docs` 自动构建和维护
- 所有 skill 引用和维护它
- 效果: 显著提升 agent 输出质量，减少 token 使用

### ADR 触发条件

只在三个条件同时满足时创建 ADR:
1. 难以逆转
2. 没有上下文会令人惊讶
3. 是真正权衡的结果

### Progressive Disclosure

- SKILL.md 保持 <100 行
- 支撑细节在单独文件中，仅按需加载
- 尊重上下文窗口限制
- 约 263 字符的 description 是唯一常驻 system prompt 的部分

## Design Principles

1. **小而可组合**: 每个 skill 做一件事。它们组合而非拥有整个流程。对比 "GSD, BMAD, Spec-Kit 试图通过拥有流程来帮助" 但 "夺走了你的控制权"
2. **Progressive disclosure**: SKILL.md <100 行。支撑细节按需加载
3. **Domain-language-first**: 重度强调 CONTEXT.md 作为共享术语表
4. **垂直切片优于水平**: 工作被拆分为薄的端到端切片（tracer bullets），不是逐层块
5. **反馈循环是首要的**: `/diagnose` 字面说 "This is the skill" 关于建立反馈循环
6. **模型无关**: "They work with any model." 纯 markdown，无运行时依赖
7. **Human-in-the-loop 检查点**: `/grill-me`、`/to-issues`、`/tdd` 有明确的用户批准门
8. **ADR 用于不可逆决策**: 只在三个条件同时满足时
9. **深模块优于浅模块**: 架构 skill 使用 John Ousterhout 的 "A Philosophy of Software Design" 词汇

## Strengths

1. **极高采纳率**: 45K+ stars，证明了 "编码工程纪律为 skill" 的价值
2. **扎根真实工程**: 引用 Pragmatic Programmer、DDD、XP、Philosophy of Software Design
3. **低门槛**: 只是 markdown 文件。无运行时、无依赖、无锁定
4. **Grilling pattern 被广泛验证**: 被引用为最有影响力的 skill，解决了代码编写前的对齐问题
5. **CONTEXT.md pattern**: 共享术语表被独立验证为显著提升 agent 输出质量
6. **可组合性**: 可以只用一个 skill 而不用其他的。无整体框架
7. **"不是 vibe coding"**: 明确定位为生产工程，不是快速原型

## Failure Modes / Costs

1. **上下文窗口压力**: 每个安装的 skill 的 description 消耗 system prompt token。Claude Code 有 ~16K 字符预算。约 263 字符/skill 意味着只能装 ~42 个 skill。装太多导致 "context rot"
2. **不是运行时**: Skill 是指令，不是强制执行。Agent 可以偏离 skill 的流程，尤其在长会话中。没有程序化保证 agent 遵循步骤
3. **设置开销**: 需要每 repo 运行 `/setup-matt-pocock-skills`，维护 CONTEXT.md，ADR 纪律。不维护这些 artifact 的团队收益递减
4. **有主见的工作流**: issue tracker 集成、triage 标签、PRD 格式假设特定工作流
5. **小任务的规划开销**: "先 grill，再 plan，再 code" 的方法增加延迟。对琐碎修改是过度的
6. **无执行保证**: 不像 hooks 或 CI，skill 是建议性的。配置错误或过载的 agent 可能跳过步骤或幻觉合规
7. **生态碎片化**: 成功催生了许多 fork 和市场（mdskills.ai, skillsmp.com, mdskill.dev），难以知道哪个版本是规范的
8. **Grilling 过度提问 (实测)**: `/grill-with-docs` 存在两个实际问题:
   - 一些模型可以自我评估的明显问题仍然反复问用户，缺乏 "自答能力" — 不区分 "需要用户输入的真正模糊点" 和 "可以通过读代码/文档自行判断的问题"
   - 围绕已经回答过的问题反复追问，缺乏 "已回答" 状态追踪 — 没有收敛机制
   - 根本原因: grilling 是无状态的 prompt 指令，没有问题状态机（open → answered → closed）

## What PGE Might Borrow

1. **Grilling pattern 作为 Planner 的输入澄清机制**: 在 plan 前进行结构化访谈，但必须解决过度提问问题 — 需要区分 "真正需要用户输入的模糊点" 和 "可以自行判断的问题"，并追踪已回答状态
2. **CONTEXT.md 概念**: PGE run 可以维护一个 run-level 术语表，确保 P/G/E 三个 agent 使用一致的词汇
3. **Progressive disclosure 的 skill 设计**: PGE 的 agent prompt 应该分层 — 核心指令 <100 行，详细参考按需加载
4. **"小而可组合" 原则**: PGE 的每个 phase 应该做一件事做好，而非试图拥有整个流程
5. **垂直切片思维**: Planner 的 plan 应该是垂直切片（端到端可验证），不是水平层
6. **`/to-issues` 的垂直切片拆分 (实测有效)**: 任务拆分为可独立验证的切片，收益明确。Planner 的 plan 输出可以借鉴这个结构
7. **ADR 触发条件的严格性**: PGE 的 decision logging 应该只记录真正不可逆的权衡

## What PGE Should Not Borrow

1. **"Skill 是建议性的" 这个特性**: PGE 的 contract 是强制性的，不是建议。Agent 必须遵循 phase contract
2. **Human-in-the-loop 在每个步骤**: PGE 的目标是 bounded autonomous execution，不是每步都问用户
3. **CONTEXT.md 的手动维护负担**: PGE 的术语一致性应该通过 contract 设计自动保证，不是靠维护文件
4. **"不是 vibe coding" 的定位**: PGE 不需要定位声明，它是执行引擎
5. **Skill marketplace 生态**: PGE 是单一插件，不是 skill 集合
6. **每 repo 的 setup 流程**: PGE 应该零配置启动，不需要 per-repo setup skill
7. **Architecture improvement skill**: PGE 不做架构改进，它执行给定的 plan

## Potential PGE Relevance

- **Planner 的输入质量**: grilling pattern 的核心洞察 — 在执行前对齐意图 — 直接适用于 Planner 如何处理模糊输入
- **跨 agent 词汇一致性**: CONTEXT.md 的思路可以用于确保 P/G/E 三个 agent 对同一概念使用相同术语
- **Progressive disclosure 的 prompt 设计**: PGE agent 的 prompt 应该分层，核心 contract 精简，详细参考按需
- **垂直切片的 plan 结构**: Planner 产出的 plan 应该是可独立验证的垂直切片
- **反馈循环内建于 Generator**: Generator 不应该只写代码，应该写-测试-修复作为原子操作
- **"小而可组合" 对 PGE 架构的启示**: 每个 phase 做一件事，phase 之间通过 artifact 组合

## Open Questions for Step 2

1. PGE 的 Planner 是否需要类似 grilling 的输入澄清步骤？如果需要，如何在 bounded round 内控制摩擦？
2. **问题分流机制**: grilling 中的问题应该分为两类 — (a) 必须问用户的真正模糊点 (b) 可以用独立 agent 自我评估的问题（生成多方案 → 评分 → 选择最优）。PGE 的 Planner 如何实现这个分流？
3. PGE 是否需要 run-level 的 CONTEXT.md（术语表）来确保 P/G/E 词汇一致？
4. PGE 的 agent prompt 是否应该重构为 progressive disclosure 结构（核心 <100 行 + 按需参考）？
5. Planner 的 plan 输出是否应该强制为垂直切片格式（类似 `/to-issues`）？
6. Generator 的 "写-测试-修复" 原子操作如何与 Evaluator 的验证职责划分？

---

## PGE Context Lens

| PGE 已知问题 | Matt Skills 相关性 |
|---|---|
| Planner plan 可能不完整/不确定/模糊 | grilling pattern 在 plan 前澄清意图，但需要降低摩擦 |
| grill-with-docs 高摩擦 | 实测确认: 过度提问 + 重复已答问题 + 不区分可自答 vs 需用户输入。PGE 需要有状态的问题收敛机制 |
| 未细化实现细节不应都被当作 blocking question | 垂直切片思维: 只问阻塞当前切片的问题 |
| P/G/E 可能需要被理解为 workflow nodes | "小而可组合" 原则: 每个 node 做一件事，通过 artifact 组合 |
| Planner 缺少 issue/slice 划分逻辑 | `/to-issues` 的垂直切片拆分是直接参考 |
