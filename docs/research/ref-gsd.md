# GSD (get-shit-done) 调研报告

> 来源: github.com/gsd-build/get-shit-done (v1.37.0)
> 调研日期: 2026-04-29
> 调研目的: 学习 GSD 的 context engineering、roadmap-before-code、phase/handoff、context rot 防治机制

---

## 1. Context Engineering

GSD 的核心主张：Claude Code 本身很强，但大多数人不给它足够的上下文。GSD 是一个 **context engineering layer**。

### 1.1 结构化上下文文件体系

GSD 用文件系统作为上下文的持久化层，每个文件有明确的角色：

| 文件 | 角色 | 加载时机 |
|------|------|----------|
| `PROJECT.md` | 项目愿景、约束、决策 | 所有 agent 始终加载 |
| `REQUIREMENTS.md` | 分级需求 (v1/v2/out-of-scope) | Planner, Verifier, Auditor |
| `ROADMAP.md` | 阶段分解 + 状态追踪 | 所有 orchestrator |
| `STATE.md` | 活状态：位置、决策、阻塞、指标 | 所有 agent |
| `CONTEXT.md` (per phase) | 用户偏好/决策 | Researcher, Planner, Executor |
| `RESEARCH.md` (per phase) | 生态调研结果 | Planner, Plan Checker |
| `PLAN.md` (per plan) | 原子任务 + XML 结构 | Executor, Plan Checker |
| `SUMMARY.md` (per plan) | 执行结果 | Verifier, State tracking |

### 1.2 Context 传播链

```
PROJECT.md ──────────────────────► 所有 agent
REQUIREMENTS.md ─────────────────► Planner, Verifier
ROADMAP.md ──────────────────────► Orchestrators
STATE.md ────────────────────────► 所有 agent
CONTEXT.md (per phase) ──────────► Researcher → Planner → Executor
RESEARCH.md (per phase) ─────────► Planner → Plan Checker
PLAN.md (per plan) ──────────────► Executor → Plan Checker
SUMMARY.md (per plan) ───────────► Verifier → State tracking
```

关键设计：每个阶段产出的 artifact 自动成为下一阶段的输入。上下文是 **链式传递** 的，不是一次性加载的。

### 1.3 Mandatory Initial Read

所有 agent 启动时，如果 prompt 包含 `<required_reading>` 块，必须先用 Read tool 加载列出的所有文件。这是硬性约束，不是建议。

### 1.4 Context Budget 分级

GSD 根据 context window 大小调整读取深度：

| Context Window | 读取策略 |
|---------------|----------|
| < 500K (200K model) | 只读 frontmatter、状态字段、摘要 |
| >= 500K (1M model) | 允许读取完整 body |

Context 使用率分级：

| 层级 | 使用率 | 行为 |
|------|--------|------|
| PEAK | 0-30% | 全功能操作 |
| GOOD | 30-50% | 正常操作，偏好 frontmatter |
| DEGRADING | 50-70% | 节约模式，警告用户 |
| POOR | 70%+ | 紧急模式，立即 checkpoint |

### 1.5 对 PGE 的启发

- **文件即上下文**：用结构化文件体系替代 in-memory 状态传递
- **链式传播**：每个阶段的产出自动成为下一阶段的输入
- **读取深度自适应**：根据 context window 大小调整加载策略
- **Mandatory initial read**：agent 启动时强制加载关键上下文

---

## 2. Roadmap-before-code 流程

GSD 的核心流程是 **先规划再编码**，具体分为：

### 2.1 初始化阶段 (`/gsd-new-project`)

1. **Questions** — 自适应提问，直到完全理解用户想法（目标、约束、技术偏好、边界情况）
2. **Research** — 4 个并行 researcher agent 调研领域（stack, features, architecture, pitfalls）
3. **Requirements** — 提取 v1/v2/out-of-scope 需求
4. **Roadmap** — 创建映射到需求的阶段计划

用户批准 roadmap 后才能开始构建。

### 2.2 每个 Phase 的流程

```
discuss-phase → CONTEXT.md (用户偏好)
    ↓
plan-phase
    ├── Research → RESEARCH.md
    ├── Planner → PLAN.md files (XML 结构)
    └── Plan Checker → 验证循环 (最多 3 次)
    ↓
execute-phase
    ├── Wave 分析 (依赖分组)
    ├── Executor per plan → 代码 + 原子提交
    └── Verifier → VERIFICATION.md
    ↓
verify-work → UAT.md (用户验收)
```

### 2.3 Plan 的 XML 结构

每个 plan 是结构化 XML，包含精确指令：

```xml
<task type="auto">
  <name>Create login endpoint</name>
  <files>src/app/api/auth/login/route.ts</files>
  <action>具体实现指令</action>
  <verify>验证命令</verify>
  <done>完成标准</done>
</task>
```

### 2.4 对 PGE 的启发

- **Discuss → Plan → Execute → Verify** 四步循环是可借鉴的 phase 结构
- **Plan 的 XML 结构** 类似 PGE 的 contract，但更面向执行
- **Plan Checker 验证循环** (最多 3 次) 是质量门控的具体实现
- **Requirements coverage gate** 确保每个需求至少被一个 plan 覆盖

---

## 3. Phase/Handoff 机制

### 3.1 Agent 完成标记

每个 agent 有明确的完成标记（completion markers）：

| Agent | 完成标记 |
|-------|----------|
| gsd-planner | `## PLANNING COMPLETE` |
| gsd-executor | `## PLAN COMPLETE` |
| gsd-phase-researcher | `## RESEARCH COMPLETE` / `## RESEARCH BLOCKED` |
| gsd-plan-checker | `## VERIFICATION PASSED` / `## ISSUES FOUND` |
| gsd-verifier | `## Verification Complete` |

Orchestrator 通过 regex 匹配这些标记来检测 agent 完成状态。

### 3.2 Planner → Executor 交接合约

PLAN.md 的交接合约：

| 字段 | 必需 | 描述 |
|------|------|------|
| Frontmatter | Yes | phase, plan, type, wave, depends_on, files_modified |
| `<objective>` | Yes | plan 要达成什么 |
| `<tasks>` | Yes | 有序任务列表 |
| `<verification>` | Yes | 整体验证步骤 |
| `<success_criteria>` | Yes | 可衡量的完成标准 |

### 3.3 Executor → Verifier 交接合约

SUMMARY.md 的交接合约：

| 字段 | 必需 | 描述 |
|------|------|------|
| Frontmatter | Yes | phase, plan, subsystem, tags, key-files, metrics |
| Commits table | Yes | 每个 task 的 commit hash |
| Deviations section | Yes | 偏差或 "None" |
| Self-Check | Yes | PASSED 或 FAILED |

### 3.4 Session 间交接 (pause/resume)

**Pause** (`/gsd-pause-work`):
- 检测当前工作类型（phase/spike/sketch/deliberation/research）
- 收集完整状态（位置、已完成、剩余、决策、阻塞）
- 写入两个文件：
  - `.planning/HANDOFF.json` — 机器可读的结构化状态
  - `.continue-here.md` — 人类可读的上下文
- Git commit 为 WIP

**Resume** (`/gsd-resume-work`):
- 加载 STATE.md（或重建）
- 检测 checkpoint（.continue-here 文件）
- 检测未完成工作（有 PLAN 但没有 SUMMARY）
- 上下文感知的下一步路由

### 3.5 HANDOFF.json 结构

```json
{
  "version": "1.0",
  "timestamp": "...",
  "phase": "...",
  "plan": 2,
  "task": 3,
  "total_tasks": 7,
  "status": "paused",
  "completed_tasks": [...],
  "remaining_tasks": [...],
  "blockers": [...],
  "human_actions_pending": [...],
  "decisions": [...],
  "uncommitted_files": [],
  "next_action": "具体的第一步",
  "context_notes": "思路和计划"
}
```

### 3.6 .continue-here.md 结构

包含以下关键部分：
- **BLOCKING CONSTRAINTS** — 恢复前必须理解的约束（通过失败发现的）
- **Critical Anti-Patterns** — 严重性分级（blocking/advisory）
- **current_state** — 当前精确位置
- **completed_work / remaining_work** — 进度
- **decisions_made** — 决策及理由
- **Required Reading** — 恢复 agent 必须读的文档（有序）
- **next_action** — 恢复时的第一步

### 3.7 Continuation Format

GSD 有标准化的 "Next Up" 格式，用于 phase 间过渡：

```
## ▶ Next Up — [PROJECT_CODE] PROJECT_TITLE
**Phase 2: Authentication** — JWT login flow
`/clear` then:
`/gsd-plan-phase 2`
```

关键规则：
- 始终显示 `/clear` 在命令之前（清理上下文）
- 始终显示名称 + 描述，不只是命令路径
- 从 ROADMAP.md 或 PLAN.md 拉取上下文

### 3.8 对 PGE 的启发

- **双格式交接**（JSON + Markdown）是好的模式：机器可读 + 人类可读
- **Completion markers** 是 agent 间通信的简单有效机制
- **Blocking constraints** 的概念（通过失败发现的约束）值得借鉴
- **Required Reading 有序列表** 确保恢复 agent 按正确顺序加载上下文
- **`/clear` then command** 模式是 context rot 防治的关键手段

---

## 4. Context Rot 防治

GSD 明确将 context rot 定义为：**随着 AI 填满 context window，质量逐渐退化的现象**。

### 4.1 核心防治策略：Fresh Context Per Agent

每个 subagent 获得干净的 context window（最多 200K tokens）。这是 GSD 最核心的 context rot 防治机制。

```
Orchestrator (thin, routes only)
    ├── Agent 1 (fresh 200K context)
    ├── Agent 2 (fresh 200K context)
    └── Agent 3 (fresh 200K context)
```

Orchestrator 永远不做重活。它只负责：加载上下文、spawn agent、收集结果、路由下一步。

### 4.2 Context Window Monitor (Hook)

运行时监控机制：

1. Statusline hook 将 context 指标写入 `/tmp/claude-ctx-{session_id}.json`
2. PostToolUse hook 读取指标
3. 低于阈值时注入警告到 agent 的 `additionalContext`

| 级别 | 剩余 | Agent 行为 |
|------|------|-----------|
| Normal | > 35% | 无警告 |
| WARNING | <= 35% | 收尾当前任务，不开始新的复杂工作 |
| CRITICAL | <= 25% | 立即停止，保存状态 (`/gsd-pause-work`) |

防抖机制：首次警告立即触发，后续需要间隔 5 次 tool use。严重性升级绕过防抖。

### 4.3 Wave Execution Model

Plans 按依赖关系分组为 waves：
- Wave 内并行执行
- Wave 间顺序执行
- 每个 executor 获得 fresh context

这意味着一个 phase 可以包含大量工作，但主 context window 保持在 30-40%。

### 4.4 Context Degradation 早期信号

GSD 识别的质量退化早期信号：

- **Silent partial completion** — agent 声称完成但实现不完整
- **Increasing vagueness** — agent 开始用 "appropriate handling" 等模糊表述
- **Skipped steps** — agent 省略正常会遵循的协议步骤

### 4.5 Persistent Context Threads

`/gsd-thread` 提供跨 session 的轻量级知识持久化，用于跨多个 session 的工作。

### 4.6 对 PGE 的启发

- **Fresh context per agent** 是最有效的 context rot 防治——PGE 的 multi-round 设计应该确保每轮获得 fresh context
- **Context monitor hook** 是运行时防治的好模式——在 context 耗尽前主动警告
- **质量退化早期信号** 可以作为 PGE evaluator 的检测维度
- **`/clear` then command** 模式——每个 phase 过渡时清理 context

---

## 5. 不适用于 PGE 的部分

| GSD 特性 | 不适用原因 |
|----------|-----------|
| 完整的命令体系 (86 skills) | PGE 不是 workflow 工具，不需要复制命令体系 |
| Git 集成 (atomic commits, branching) | PGE 是 proving/evaluation 系统，不是代码生产系统 |
| Wave execution / parallel agents | PGE 的 multi-round 是顺序的 proving 过程 |
| UI/UX 相关功能 | PGE 不涉及 UI |
| npm 安装/更新机制 | PGE 是 docs/contracts skeleton |
| Model profiles (quality/balanced/budget) | PGE 有自己的 evaluator 模型选择逻辑 |
| Security hardening (prompt injection) | 不是 PGE 当前阶段的关注点 |

---

## 6. 对 PGE Runtime/Handoff 设计有价值的具体点

### 6.1 直接可借鉴

1. **文件即上下文** — 用结构化 Markdown 文件作为 agent 间的上下文传递介质
2. **双格式交接** — JSON (机器可读) + Markdown (人类可读) 的 handoff 模式
3. **Completion markers** — agent 用标准化的文本标记表示完成状态
4. **Mandatory initial read** — agent 启动时强制加载关键上下文
5. **Context budget 分级** — 根据 context window 大小和使用率调整行为
6. **Blocking constraints** — 通过失败发现的约束，恢复时必须理解

### 6.2 需要适配的

1. **Discuss → Plan → Execute → Verify 循环** — PGE 的 proving round 可以参考这个结构，但语义不同（PGE 是 proving，不是 building）
2. **Plan 的 XML 结构** — PGE 的 contract 可以参考结构化格式，但内容是 evaluation criteria 而非 implementation tasks
3. **Context propagation chain** — PGE 的 round 间传递需要类似的链式设计，但传递的是 verdict/evidence 而非 code artifacts

---

## 引用来源

- README.md: github.com/gsd-build/get-shit-done (通过 `gh repo view` 获取)
- docs/ARCHITECTURE.md: 系统架构文档
- docs/context-monitor.md: Context window 监控机制
- docs/FEATURES.md: 完整功能参考
- get-shit-done/references/context-budget.md: Context budget 规则
- get-shit-done/references/agent-contracts.md: Agent 交接合约
- get-shit-done/references/continuation-format.md: 过渡格式标准
- get-shit-done/references/universal-anti-patterns.md: 通用反模式
- get-shit-done/references/checkpoints.md: Checkpoint 类型定义
- commands/gsd/pause-work.md + workflows/pause-work.md: 暂停/恢复机制
- commands/gsd/resume-work.md: 恢复机制
