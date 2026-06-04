# PGE

PGE 是一个面向 Claude Code 的 plan-grounded 工程插件。

它把模糊意图或外部计划转成 repo-local canonical contract，然后让执行后端基于这个 contract 实现并回传证据。重点不是让 agent 遵守更多仪式，而是提升执行质量：保留意图、限制范围、暴露验证，让失败也能变成有用的回流。

## 定位

PGE 是 harness，不是 agent OS。

它做三件事：

1. **澄清工作**：捕获目标、成功形态、范围、约束和当前 repo 现实。
2. **冻结可执行合约**：选择方案、切出 issue contracts、定义验收与验证，并保留 forbidden areas。
3. **回流执行证据**：执行产出可验证 evidence，或产出可用于 review、replan、ship、handoff 的 blocker。

PGE 不替代 Claude Code 的原生执行能力。`pge-exec` 仍是默认 PGE 执行界面。Ready plan 也可以暴露 `workflow-handoff.md`，让 Claude Code Dynamic Workflow 自己拥有 task-specific orchestration，同时仍读取同一份 canonical plan。

## 核心模型

持久事实源是任务目录：

```text
.pge/tasks-<slug>/
  research.md                     # 可选的问题发现合约
  plan.md                         # canonical plan contract
  issues/Ixxx.md                  # 完整 issue execution contracts
  workflow-handoff.md             # 可选 Dynamic Workflow 启动适配器
  runs/<run_id>/*                 # pge-exec run artifacts
  workflow-result.md              # 可选 Dynamic Workflow evidence backflow
  review.md / challenge.md        # 被调用时产生的 bounded review/prove-it feedback
```

不变量是语义对齐，不是固定格式。模板只是脚手架；必须保留的是字段语义，而不是 prose 形状。

## 流程

```text
Research -> Plan -> Execute backend -> Evidence backflow -> Review / Challenge / Ship
```

执行后端选项：

| 后端 | 输入 | 输出 | 负责 |
|---|---|---|---|
| `pge-exec` | `plan.md` + selected `issues/Ixxx.md` | `.pge/tasks-<slug>/runs/<run_id>/*` | 默认 PGE 执行 lanes、有界修复、分阶段验证、Exec QA Gate |
| Claude Code Dynamic Workflow | `workflow-handoff.md` -> `plan.md` | `.pge/tasks-<slug>/workflow-result.md` | task-specific orchestration、并行、有界 local repair、验证、结果产出 |

`workflow-result.md` 不是 `pge-exec` repair artifact，也不是 `pge-review` route。它是给后续被选择的 review、replan、ship 或 handoff 步骤使用的 evidence backflow。

## 阶段权限

| 界面 | 负责 | 不负责 |
|---|---|---|
| `pge-research` | 问题合约：目标、成功形态、范围、非目标、约束、相关上下文、路由 | 最终方案、issue 切片、实现 |
| `pge-plan` | 可执行方案合约：selected approach、issue index、issue files、target/forbidden areas、acceptance、verification、evidence、Final Plan Gate | 实现代码、runtime orchestration、交付决策 |
| `pge-exec` | 默认执行后端：在 plan contract 内实现、记录 run evidence、有界修复、Diagnostic Recovery | 修改计划、扩大 scope、豁免验证、交付决策 |
| Dynamic Workflow | 可选执行后端：通过 `workflow-handoff.md` 解读同一份 canonical plan | 把 plan 重写成 reusable graph、创建 PGE routes、替代 canonical plan |
| `pge-review` | 被显式调用时给出 review verdict：对齐性、简洁性、标准、验证故事 | 默认拥有所有 workflow result、实现、修改计划 |
| `pge-challenge` | 被调用时提供 PR/ship 前的手动 prove-it 压力 | 计划或实现权限 |

Subagents 和 workers 是有界 helpers，不是 workflow authorities。

## Plan Contract

`pge-plan` 在 `.pge/tasks-<slug>/` 下产生 canonical contract。

Ready plan 包含：

- `plan.md`：包含 `schema_version`、source contract check、selected/rejected approaches、goal、non-goals、necessary context、issue index、target areas、forbidden areas、acceptance、verification、evidence required、terminal conditions、plan gate、stop conditions 和 route。
- `issues/Ixxx.md`：完整 issue contracts。`plan.md ## issues` 只是紧凑 Execution Index。
- `workflow-handoff.md`：ready route 下生成的可选 Dynamic Workflow 启动适配器。

`workflow-handoff.md` 指回 `plan.md`。它不能复制 acceptance criteria、issue bodies、verification details，也不能派生 reusable workflow graph、task DAG、dependency JSON 或 subagent topology。

## 外部计划

PGE 可以采纳 PGE 外部产生的计划：Claude plan mode 输出、`docs/exec-plans/` 文档、review comments、issue lists 或其他结构化笔记。

只有当 source semantics 足以让 `pge-plan` 确认以下内容时，才允许 fast-adopt：

- 目标和可观察成功/停止条件
- 有界范围与非目标
- 已固定的决策和 ownership boundaries
- allowed / forbidden areas
- verification 与 evidence expectations
- 足够的有序工作结构，可以切出 executable issues，而不发明 scope 或重做架构决策

采纳后，`.pge/tasks-<slug>/plan.md` 是权威事实源。外部计划只是 source evidence，不是并行 runtime contract。

## 技能

### 主界面

- **[`/pge-research`](./skills/pge-research/SKILL.md)** — 当 goal、success shape、scope、constraints 或 repo reality 不足以公平计划时，产生有界 `research.v3` 问题发现 brief。

- **[`/pge-plan`](./skills/pge-plan/SKILL.md)** — 产生 canonical executable solution contract：`plan.md`、`issues/Ixxx.md`、Final Plan Gate，以及 ready plan 的可选 `workflow-handoff.md`。

- **[`/pge-exec`](./skills/pge-exec/SKILL.md)** — 通过默认 PGE 后端执行 plan issues，记录 bounded lanes、verification evidence、implementation notes，并在不清楚或重复开发失败时进入 Diagnostic Recovery。

- **[`/pge-review`](./skills/pge-review/SKILL.md)** — 被调用时审查固定点以来的变化。检查与 plan/original intent 的对齐、标准、简洁性和验证故事，然后返回有界 review verdict。

- **[`/pge-challenge`](./skills/pge-challenge/SKILL.md)** — 被调用时提供手动 prove-it gate，用证据挑战每个有意义的变更。

### 支持界面

- **[`/pge-ai-native-refactor`](./skills/pge-ai-native-refactor/SKILL.md)** — 在 PGE 执行前塑造一个人工选择的 repo 演进方向。
- **[`/pge-spark`](./skills/pge-spark/SKILL.md)** — 面向 fuzzy 或 solution-first 输入的 Superpowers-style brainstorming shim。
- **[`/pge-handoff`](./skills/pge-handoff/SKILL.md)** — 为另一个 agent 或未来 session 创建临时聚焦 handoff。
- **[`/pge-learn`](./skills/pge-learn/SKILL.md)** — 从 context friction、agent memory、code summaries 和 run artifacts 中捕获高质量 learning candidates。
- **[`/pge-html`](./skills/pge-html/SKILL.md)** — 将 PGE artifacts 或当前线程 source packets 渲染为保真的 HTML 页面和 decision boards。
- **[`/pge-complexity`](./skills/pge-complexity/SKILL.md)** — 默认只报告的复杂度与性能热点分析。
- **[`/pge-diagnose`](./skills/pge-diagnose/SKILL.md)** — 结构化 bug 诊断。
- **[`/pge-grill-me`](./skills/pge-grill-me/SKILL.md)** — 压力测试计划或设计。
- **[`/pge-redo`](./skills/pge-redo/SKILL.md)** — 基于已有失败上下文重做平庸修复。
- **[`/pge-zoom-out`](./skills/pge-zoom-out/SKILL.md)** — 在更高抽象层映射模块、调用者和数据流。

## 安装

市场安装：

```text
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
