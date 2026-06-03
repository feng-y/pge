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

PGE 是 harness，不是重型协议引擎。默认产物应该给模型目标、禁止边界、必要上下文、必要时的推荐方向，以及期望的验证证据。详细审计字段只在风险触发时出现，不是默认执行仪式。

- 研究必须暴露 `schema_version: research.v3`、目标、成功形态、范围、非目标、约束、任务相关上下文、最简单方向、开放问题和路由。Implementation Friction 与 Progressive Feasibility 只在触发时出现。
- 计划必须暴露 `schema_version`、`source_contract_check`、`selected_approach`、`rejected_approaches`、`goal`、`non_goals`、`necessary_context`、`issues`、`target_areas`、`forbidden_areas`、`acceptance`、`verification`、`evidence_required`、`terminal_conditions`、`plan_gate`、`stop_conditions` 和 `route`。推荐方案只在有助于执行且不会限制有用实现选择时出现。新的可执行计划中，`plan.md ## issues` 是紧凑执行索引；完整 issue 合约写入 `.pge/tasks-<slug>/issues/Ixxx.md`。
- 执行必须暴露每个变更实现了哪个议题、验收是否通过、运行了什么验证、任何计划偏差、卡住 lane 的恢复，以及不清楚或重复开发失败的 Diagnostic Recovery 记录。
- 审查必须根据计划和原始用户意图检查差异，包括范围漂移和证据缺口，并在存在 PGE 任务目录时写入面向执行修复的发现。
- 每个阶段必须消费其明确输入加上相关的当前上下文。当上下文改变意图、范围或修复目标时，该阶段必须在产生下一个合约前进行澄清。
- 研究负责问题发现；计划负责可执行方案设计。执行不应该是解决主要意图、范围或验收歧义的地方；那意味着上游合约还没准备好。

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

PGE 也可以采纳其他工作流产生的计划。Claude 计划模式输出、`docs/exec-plans/` 文档或外部工作流计划，只要其语义足以让 `pge-plan` 确认目标、可观察的成功/停止条件、有界范围、已固定的决策与所有权边界、允许/禁止区域、验证/证据期望，以及足够的有序工作结构来切出可执行议题，而不发明 scope 或重做架构决策，就可以 fast-adopt。源内容可以是 prose、表格、issue list、review comments 或其他结构化笔记；不需要 canonical 标题。Fast-adopt 会把这些语义 materialize 成 canonical `.pge/tasks-<slug>/plan.md` 的 `plan.v2` 字段和引用的 `.pge/tasks-<slug>/issues/Ixxx.md` issue 合约，并在允许执行前运行 Final Plan Gate。采纳后，`pge-exec` 在 `plan_gate` 通过时消费 canonical plan index 和选中的 issue files。

### 工作流映射

| 阶段 | PGE 界面 | 产物 / 门控 |
|---|---|---|
| 研究 | `pge-research` | `.pge/tasks-<slug>/research.md` 带有有界 `research.v3` 问题发现合约 |
| 计划 | `pge-plan` | `.pge/tasks-<slug>/plan.md` 带有 issue 执行索引，`.pge/tasks-<slug>/issues/Ixxx.md` 带有完整 issue 合约，并通过 Final Plan Gate |
| 计划（外部） | `pge-plan` fast-adopt | 从语义充分的外部计划 materialize 而来的 canonical `.pge/tasks-<slug>/plan.md`，通过 Final Plan Gate 后可执行 |
| 执行 | `pge-exec` | `.pge/tasks-<slug>/runs/<run_id>/*` |
| 审查 | `pge-review` + 可选 `pge-challenge` | `.pge/tasks-<slug>/review.md` 和 `.pge/tasks-<slug>/challenge.md`；反馈只在 provenance 校验通过后回流 `pge-exec` 做有界修复，`pge-challenge` 通常从 review 阶段的 `READY_FOR_CHALLENGE` 路由进入 |
| 交付 | 外部 git/PR/部署工作流 | commit、PR、merge、deploy 或交接 |

`pge-ai-native-refactor`、`pge-handoff`、`pge-learn`、`pge-html`、`pge-complexity`、`pge-diagnose`、`pge-grill-me`、`pge-redo` 和 `pge-zoom-out` 是支持界面。它们在弧线周围很有用，但不替代主阶段合约。

## 技能

### 流水线

按顺序使用的技能，从模糊意图到验证代码。

- **[`/pge-research`](./skills/pge-research/SKILL.md)** — 在计划前产生有界 `research.v3` 问题发现 brief。当目标、成功形态、范围、约束或仓库现实不足以公平计划时使用。区分原始目标 A 和实现假设 B，记录任务相关上下文，只在需要时触发 Implementation Friction 或 Progressive Feasibility，并以明确路由停止。

- **[`/pge-plan`](./skills/pge-plan/SKILL.md)** — 在 `.pge/tasks-<slug>/` 下产生有界的可执行方案设计合约：稳定 `plan.md` 保存 issue 执行索引，`issues/Ixxx.md` 保存完整 issue 合约、验收标准、本地验证、证据要求、禁止区域、按深度缩放的 Plan Engineering Review、仓库现实检查和 Final Plan Gate；Final Plan Gate 通过前不能进入 `pge-exec`。也支持从语义充分的外部计划 fast-adopt 成 canonical 合约。

- **[`/pge-exec`](./skills/pge-exec/SKILL.md)** — 以轻量协调、紧凑且有界的 Generator lanes、分阶段验证和最终 Evaluator 压力执行计划议题。消费计划文件，允许在计划合约内通过 `implementation-notes.md` 记录实现适配，在有用时使用可选只读 prep hints，并验证 composed run，而不是强制每个议题都经过 Evaluator 批准。记录证据，报告计划偏差，用 Progress Watchdog 恢复停滞 lanes，并把不清晰的开发失败升级为 Diagnostic Recovery，而不是试错式修补。

- **[`/pge-review`](./skills/pge-review/SKILL.md)** — 自固定点以来变更的审查阶段门控。在路由到修复、挑战或交付前，检查标准、与计划/原始意图的语义对齐、简洁性和验证故事。

- **[`/pge-challenge`](./skills/pge-challenge/SKILL.md)** — PR/交付前的手动证明门控。解释差异，在存在当前提示约束时证明，证明执行满足计划/开发要求，用证据挑战每个有意义的变更。

### 实用工具

- **[`/pge-ai-native-refactor`](./skills/pge-ai-native-refactor/SKILL.md)** — 在 PGE 执行前，将一个人工选择的仓库演进方向塑造为有界的 AI 原生重构计划。聚焦一个主导摩擦：入口、包含、验证、结构毒性或缺失的机械不变量。

- **[`/pge-spark`](./skills/pge-spark/SKILL.md)** — 本地化的 Superpowers brainstorming shim，适用于 fuzzy、broad、value-laden 或 solution-first 的输入。先恢复原始目标 A，再处理实现假设 B；一次只问一个问题，比较 2-3 个 framing 或 approach，写入 `.pge/tasks-<slug>/spark.md`，并在用户批准 spec 后停止，供 `pge-plan` 消费。

- **[`/pge-handoff`](./skills/pge-handoff/SKILL.md)** — 为另一个代理或未来会话创建临时、聚焦的 handoff。Matt-style task slice only：无流水线控制，无知识提取。

- **[`/pge-learn`](./skills/pge-learn/SKILL.md)** — 从上下文摩擦、代理记忆、代码摘要和运行 artifacts 中学习。以 `learn` 作为默认捕获命令；必要时记录 workspace-local raw learning candidates，并且只把有证据、质量过关的候选提升为 durable repo knowledge。

- **[`/pge-html`](./skills/pge-html/SKILL.md)** — 将规范 PGE artifacts 渲染为保真的单文件 HTML 页面和派生决策板。保真页面保留源结构；决策板把 artifacts 压缩为 issue、evidence、risk、gate 和 human-attention 视图，同时保持 Markdown/JSON/evidence 作为事实源。也可以直接消费当前对话上下文、生成报告、命令输出、浏览器观察和混合 source packet，不要求先整理成 Markdown 文件；同时支持非 PGE 的认知、design-to-HTML、展示和本地编辑器 HTML artifacts，并要求语义覆盖与 markup-integrity 检查。

- **[`/pge-complexity`](./skills/pge-complexity/SKILL.md)** — 默认只报告的复杂度与性能热点分析。查找潜在算法复杂度、嵌套、长函数和大文件热点；只有用户明确要求时才修改代码。

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

检查进度：

```bash
./bin/pge-progress-report.sh <progress.jsonl-or-task-dir>
```
