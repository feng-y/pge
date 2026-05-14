# PGE

一个将多步骤工程工作转化为有界、可验证执行的 Claude Code 插件。

## 为什么需要 PGE

AI 编码代理擅长单次任务。让它们修复拼写错误或添加函数——完成。但真正的工程工作是多步骤的：研究问题、规划方案、逐个执行议题、验证每个部分。这正是代理失效的地方。

**失效模式：**

1. **漂移（Drift）** — 代理开始执行，失去对计划的追踪，构建了你没有要求的东西
2. **跳过验证（Skipped verification）** — 代码被编写但从未针对验收标准进行测试
3. **上下文崩溃（Context collapse）** — 在较大任务中，代理忘记了对话早期的约束，与自己的计划相矛盾

**解决方案：** PGE 将工作结构化为常见的代理工程弧线：研究（Research）→ 计划（Plan）→ 执行（Execute）→ 审查（Review）→ 交付（Ship）。每个边界都有明确的产物或门控，但不变量是语义对齐，而非固定格式。研究证明它理解用户意图。计划将该意图转化为可执行合约。执行证明代码变更满足该合约。审查在交付前检查差异是否仍与原始意图对齐。每个阶段都是单独的技能调用——你始终控制何时推进。

## 核心合约

PGE 使用固定接口与灵活表达。

- 研究必须暴露 `intent_spec`、`clarify_status`、`plan_delta`、`blockers` 和 `evidence`。
- 计划必须暴露 `goal`、`non_goals`、`issues`、`target_areas`、`acceptance`、`verification`、`evidence_required` 和 `risks`。
- 执行必须暴露每个变更实现了哪个议题、验收是否通过、运行了什么验证，以及任何计划偏差。
- 审查必须根据计划和原始用户意图检查差异，包括范围漂移和证据缺口。
- 每个阶段必须消费其明确输入加上相关的当前上下文。当上下文改变意图、范围或修复目标时，该阶段必须在产生下一个合约前进行澄清。
- 研究和计划拥有发现和澄清的职责。执行不应该是解决主要意图或验收歧义的地方；那意味着上游合约还没准备好。

模板是保持一致性的脚手架。它们不是填充简单任务或掩盖真实决策的理由。

## 快速开始

```
/pge-research   → 理解问题空间
/pge-plan       → 产生带有议题和验收标准的有界计划
/pge-exec       → 逐个议题执行计划并验证
/pge-review     → 根据标准、对齐性、简洁性审查组合的差异
/pge-challenge  → 证明有意义的变更经得起对抗性检查
```

## 流水线

```
pge-research → pge-plan → pge-exec → pge-review → pge-challenge → ship
```

每个技能产生一个产物或门控结果供下一步消费。你可以从任何点进入——如果你已经了解全局就跳过研究，如果你已经有计划文件就跳过计划，或者在 PGE 流水线之外对普通差异运行审查/挑战。

PGE 也可以采纳其他工作流产生的计划。如果 Claude 计划模式输出、`docs/exec-plans/` 文档或外部工作流计划清晰完整——目标、范围、语义所有权、非目标、目标区域或所有权边界、实现方向和验证/证据检查点都存在——`pge-exec` 可以将其规范化为 `.pge/tasks-<slug>/plan.md` 并从规范产物执行。规范化后，计划由 PGE 进行仓库管理：运行产物、证据、审查和学习必须存放在 `.pge/tasks-<slug>/runs/<run_id>/` 下。

### 工作流映射

| 阶段 | PGE 界面 | 产物 / 门控 |
|---|---|---|
| 研究 | `pge-research` | `.pge/tasks-<slug>/research.md` 带有意图/证据合约 |
| 计划 | `pge-plan` | `.pge/tasks-<slug>/plan.md` 带有可执行议题合约 |
| 执行 | `pge-exec` | `.pge/tasks-<slug>/runs/<run_id>/*` |
| 审查 | `pge-review` + 可选 `pge-challenge` | 审查门控：`BLOCK_SHIP`、`NEEDS_FIX`、`READY_FOR_CHALLENGE` 或 `READY_TO_SHIP`；需要时提供证明证据 |
| 交付 | 外部 git/PR/部署工作流 | commit、PR、merge、deploy 或交接 |

`pge-ai-native-refactor`、`pge-handoff`、`pge-knowledge`、`pge-html`、`pge-diagnose`、`pge-grill-me`、`pge-redo` 和 `pge-zoom-out` 是支持界面。它们在弧线周围很有用，但不替代主阶段合约。

## 技能

### 流水线

按顺序使用的技能，从模糊意图到验证代码。

- **[`/pge-research`](./skills/pge-research/SKILL.md)** — 在计划前将研究理解与用户真实意图对齐。当意图仍然模糊、多个方案似乎可行或任务涉及不熟悉的代码时使用。读取仓库，从代码和文档解决歧义，编写为计划提供的最小意图/证据合约。

- **[`/pge-plan`](./skills/pge-plan/SKILL.md)** — 在 `.pge/tasks-<slug>/plan.md` 下产生经过工程审查的有界计划。将意图转化为带有验收标准、验证提示和证据要求的编号可执行议题合约。

- **[`/pge-exec`](./skills/pge-exec/SKILL.md)** — 使用生成器（Generator）+ 评估器（Evaluator）代理执行计划议题。消费计划文件，分派每个议题的执行，用独立评估器验证，记录证据，报告任何计划偏差。

- **[`/pge-review`](./skills/pge-review/SKILL.md)** — 自固定点以来变更的审查阶段门控。在路由到修复、挑战或交付前，检查标准、与计划/原始意图的语义对齐、简洁性和验证故事。

- **[`/pge-challenge`](./skills/pge-challenge/SKILL.md)** — PR/交付前的手动证明门控。解释差异，在存在当前提示约束时证明，证明执行满足计划/开发要求，用证据挑战每个有意义的变更。

### 实用工具

- **[`/pge-ai-native-refactor`](./skills/pge-ai-native-refactor/SKILL.md)** — 在 PGE 执行前，将一个人工选择的仓库演进方向塑造为有界的 AI 原生重构计划。聚焦一个主导摩擦：入口、包含、验证、结构毒性或缺失的机械不变量。

- **[`/pge-handoff`](./skills/pge-handoff/SKILL.md)** — 为另一个代理或未来会话创建紧凑的一次性交接文档。仅 Matt 风格的观察者摘要：无流水线控制，无知识提取。

- **[`/pge-knowledge`](./skills/pge-knowledge/SKILL.md)** — 在将高质量候选提升为仓库知识前，评估上下文摩擦、代理记忆、代码摘要和运行学习。

- **[`/pge-html`](./skills/pge-html/SKILL.md)** — 为计划、报告、审查、比较、仪表板、模块映射和执行语义生成面向人类的 HTML 认知工具，同时保持 Markdown 作为规范流水线产物。

### 开发者工具

日常开发的独立技能。不是流水线的一部分——随时使用。

- **[`/pge-diagnose`](./skills/pge-diagnose/SKILL.md)** — 结构化的 6 阶段 bug 诊断：构建反馈循环 → 重现 → 假设 → 仪器化 → 修复 → 清理。

- **[`/pge-grill-me`](./skills/pge-grill-me/SKILL.md)** — 通过无情的质询对计划或设计进行压力测试。遍历决策树的每个分支。

- **[`/pge-redo`](./skills/pge-redo/SKILL.md)** — 废弃平庸的修复，使用从失败尝试中积累的上下文优雅地重做。

- **[`/pge-zoom-out`](./skills/pge-zoom-out/SKILL.md)** — 在更高抽象层映射相关模块、调用者和数据流。

## 安装

市场安装：

```
/plugin marketplace add feng-y/pge
/plugin install pge@pge
```

本地开发：

```bash
./bin/pge-local-install.sh
```

## 开发

验证合约并检查进度：

```bash
./bin/pge-validate-contracts.sh
./bin/pge-progress-report.sh
```
