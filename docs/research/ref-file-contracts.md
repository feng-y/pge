# 参考调研：文件系统上的 Contract / Spec / Plan 组织模式

调研目标：学习其他项目如何把 contract、spec、plan 等协议文档落到文件系统上，为 PGE contract 文件设计提供参考。

---

## 1. GSD (get-shit-done)

来源：`github.com/gsd-build/get-shit-done`

### 目录结构

```
.planning/
├── PROJECT.md          # 项目上下文（核心价值、需求、约束、决策）
├── REQUIREMENTS.md     # 可检查的需求列表（带 traceability）
├── ROADMAP.md          # 分阶段路线图（phase → plan 映射）
├── STATE.md            # 项目短期记忆（当前位置、进度、session 连续性）
├── config.json         # 工作流配置
├── research/           # 调研产出
├── todos/              # 待办事项
│   └── pending/
└── phases/
    └── XX-name/
        ├── XX-SPEC.md          # 阶段规格（锁定需求）
        ├── XX-YY-PLAN.md       # 执行计划（具体步骤）
        ├── CONTEXT.md          # 实现决策（discuss-phase 产出）
        ├── SUMMARY.md          # 执行总结
        ├── .continue-here.md   # 会话恢复 handoff
        └── VALIDATION.md       # 验证记录
```

### 关键文件字段结构

**PROJECT.md** — 项目活文档：
- `What This Is`: 2-3 句产品描述
- `Core Value`: 最重要的一件事
- `Requirements`: Validated / Active / Out of Scope 三区
- `Context`: 技术环境、先前工作
- `Constraints`: 硬限制（类型 + 原因）
- `Key Decisions`: 决策表（Decision / Rationale / Outcome）

**ROADMAP.md** — 路线图：
- Phase 列表（整数 = 计划，小数 = 紧急插入）
- 每个 Phase: Goal / Depends on / Requirements / Success Criteria / Plans
- Progress 表（Phase / Plans Complete / Status / Completed）
- 状态值：Not started / In progress / Complete / Deferred

**STATE.md** — 短期记忆（<100 行）：
- Current Position: Phase X of Y, Plan A of B, Status
- Performance Metrics: 速度、趋势
- Accumulated Context: 决策摘要、待办、阻塞
- Session Continuity: 上次会话时间、恢复文件路径

**SPEC.md** — 阶段规格（锁定需求的单向门）：
- Goal: 一句精确可测量的目标
- Background: 当前代码现状
- Requirements: 每条含 Current / Target / Acceptance 三字段
- Boundaries: In scope / Out of scope（含原因）
- Constraints: 性能、兼容性等硬限制
- Acceptance Criteria: 可勾选的 pass/fail 检查项
- Ambiguity Report: 各维度评分表（gate: ≤ 0.20）
- Interview Log: 需求发现过程记录

**continue-here.md** — 会话恢复 handoff：
- YAML frontmatter: phase / task / total_tasks / status / last_updated
- Sections: current_state / completed_work / remaining_work / decisions_made / blockers / context / next_action
- 恢复后删除（非永久存储）

### 文件间引用和状态管理

- ROADMAP 引用 REQUIREMENTS（REQ-ID → Phase 映射）
- STATE 引用 PROJECT（Core Value 摘要）
- SPEC 锁定后，discuss-phase 读取 SPEC 生成 CONTEXT
- 每个 phase transition 触发 PROJECT/STATE 更新
- 状态流：PROJECT → REQUIREMENTS → ROADMAP → STATE → SPEC → PLAN → EXECUTE → SUMMARY

---

## 2. Superpowers (obra/superpowers)

来源：`github.com/obra/superpowers`

### 目录结构

```
docs/superpowers/
├── specs/
│   └── YYYY-MM-DD-<topic>-design.md    # 设计规格文档
└── plans/
    └── YYYY-MM-DD-<feature-name>.md    # 实现计划文档

skills/
├── brainstorming/
│   ├── SKILL.md                        # 生成 spec 的技能定义
│   └── spec-document-reviewer-prompt.md
├── writing-plans/
│   ├── SKILL.md                        # 生成 plan 的技能定义
│   └── plan-document-reviewer-prompt.md
├── executing-plans/
│   └── SKILL.md                        # 执行 plan 的技能定义
└── subagent-driven-development/
    ├── SKILL.md
    └── spec-reviewer-prompt.md         # spec 合规审查模板
```

### Spec 文件格式

保存位置：`docs/superpowers/specs/YYYY-MM-DD-<topic>-design.md`

Spec 是 brainstorming 技能的产出，内容结构：
- Motivation: 为什么做
- Empirical Findings: 实际测试发现（如有）
- Design: 技术方案（含决策矩阵）
- Changes: 具体变更列表（每个变更含文件路径和行数估算）

Spec 没有固定模板/schema，而是由 brainstorming 流程动态生成。
自审检查项：placeholder scan / internal consistency / scope creep / ambiguity。

### Plan 文件格式

保存位置：`docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`

固定 header：
```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: ...

**Goal:** [一句话]
**Architecture:** [2-3 句]
**Tech Stack:** [关键技术]
**Spec:** [指向 spec 文件的路径]
```

Task 结构：
```markdown
### Task N: [Component Name]
**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test** [含完整代码]
- [ ] **Step 2: Run test to verify it fails** [含命令和预期输出]
- [ ] **Step 3: Write minimal implementation** [含完整代码]
- [ ] **Step 4: Run test to verify it passes**
- [ ] **Step 5: Commit** [含完整 git 命令]
```

关键原则：
- 每步 2-5 分钟
- 零 placeholder（TBD/TODO 是 plan failure）
- 完整代码在每一步
- 精确文件路径
- DRY / YAGNI / TDD / 频繁提交

### Spec 与 Plan 的关系

```
brainstorming → spec (design doc) → writing-plans → plan (implementation doc)
                                                          ↓
                                              executing-plans / subagent-driven-development
```

- Spec 是 "what + why + design decisions"
- Plan 是 "how + exact steps + exact code"
- Plan header 中 `**Spec:**` 字段指向对应 spec 文件
- Plan 写完后有 self-review 对照 spec 检查覆盖度
- 执行时有 spec-compliance-reviewer 独立审查实现是否匹配 spec

### 审查机制

两层审查 prompt 模板：
1. **plan-document-reviewer**: 检查 plan 完整性、spec 对齐、task 分解质量
2. **spec-compliance-reviewer**: 检查实现是否匹配 spec（"Do Not Trust the Report" — 独立读代码验证）

---

## 3. OpenSpec (Fission-AI/OpenSpec)

来源：`github.com/Fission-AI/OpenSpec`（43K+ stars）

### 目录结构

```
openspec/
├── specs/                              # 源真相（当前系统行为）
│   ├── auth/
│   │   └── spec.md
│   ├── payments/
│   │   └── spec.md
│   └── <domain>/
│       └── spec.md
├── changes/                            # 提议的变更（每个变更一个文件夹）
│   ├── IMPLEMENTATION_ORDER.md         # 实施顺序（叙述性）
│   ├── <change-name>/
│   │   ├── proposal.md                 # 意图 + 范围 + 方法
│   │   ├── design.md                   # 技术方案 + 架构决策
│   │   ├── tasks.md                    # 实施清单
│   │   ├── .openspec.yaml              # 变更元数据
│   │   └── specs/                      # Delta specs
│   │       └── <domain>/
│   │           └── spec.md             # ADDED / MODIFIED / REMOVED
│   └── archive/                        # 已完成的变更（带日期前缀）
│       └── YYYY-MM-DD-<change-name>/
│           ├── proposal.md
│           ├── design.md
│           ├── tasks.md
│           └── specs/
└── schemas/                            # Artifact 类型和依赖定义
    └── spec-driven/
        └── schema.yaml
```

### 核心概念：Specs vs Changes

**Specs**（源真相）：
- 按领域组织：`openspec/specs/<domain>/spec.md`
- 描述系统当前行为（行为契约，非实现计划）
- 格式：Purpose → Requirements → Scenarios
- 使用 RFC 2119 关键词（MUST/SHALL/SHOULD/MAY）
- Given/When/Then 场景格式

**Changes**（提议变更）：
- 每个变更是一个自包含文件夹
- 包含完整上下文：proposal + design + tasks + delta specs
- 可并行工作，互不冲突
- 完成后 archive（delta merge 进 specs）

### Artifact 流水线

```
proposal → specs → design → tasks → implement
  why       what     how     steps
+ scope   changes  approach  to take
```

由 schema.yaml 定义依赖图：
```yaml
artifacts:
  - id: proposal
    generates: proposal.md
    requires: []
  - id: specs
    generates: specs/**/*.md
    requires: [proposal]
  - id: design
    generates: design.md
    requires: [proposal]
  - id: tasks
    generates: tasks.md
    requires: [specs, design]
```

### 关键文件字段结构

**proposal.md**：
- Why: 为什么做这个变更
- What Changes: 具体变更列表（编号）
- Capabilities: New / Modified
- Impact: 受影响的文件列表

**spec.md**（源真相）：
```markdown
# <domain> Specification
## Purpose
## Requirements
### Requirement: <Name>
<RFC 2119 statement>
#### Scenario: <Name>
- GIVEN ...
- WHEN ...
- THEN ...
- AND ...
```

**Delta spec**（变更中的 spec）：
```markdown
## ADDED Requirements
### Requirement: <Name> ...
## MODIFIED Requirements
### Requirement: <Name> (Previously: ...)
## REMOVED Requirements
### Requirement: <Name> (Deprecated reason)
```

**tasks.md**：
```markdown
## 1. <Category>
- [ ] 1.1 <Task description>
- [ ] 1.2 <Task description>
## 2. <Category>
- [ ] 2.1 ...
```

**.openspec.yaml**：
```yaml
schema: spec-driven
created: 2026-02-21
# 可选扩展字段：
dependsOn: [<change-id>]
provides: [<capability>]
requires: [<capability>]
parent: <change-id>
```

### Archive 机制

归档时：
1. Delta specs 的 ADDED/MODIFIED/REMOVED 合并进主 specs
2. 变更文件夹移到 `changes/archive/YYYY-MM-DD-<name>/`
3. 所有 artifact 保留完整上下文（审计追踪）

### 文件间引用

- proposal 引用 capabilities（New / Modified）
- delta specs 镜像 specs 的领域目录结构
- tasks 引用 proposal 和 specs 中的需求
- .openspec.yaml 的 dependsOn 建立变更间依赖
- IMPLEMENTATION_ORDER.md 提供叙述性排序

---

## 4. Claude Code Plan 模式

来源：Claude Code 内置功能 + `ccplan` / `claude-plan-reviewer` 等社区工具

### Plan 文件位置

- 默认：`~/.claude/plans/<random-name>.md`（全局）
- 可配置：`.claude/settings.json` 中 `planDirectory` 设置（如 `"./plans"`）
- 文件名：随机生成的三词组合（如 `woolly-kindling-lecun.md`）

### Plan 文件格式

纯 Markdown，无固定 schema。典型结构：

```markdown
# Context / ## Context
[当前状态描述、已确认的现状、工作目标]

# Recommended approach / ## 1. [Section]
[分步骤的推荐方案]

## 2. [Section]
[具体变更描述]
...
```

特点：
- 无 frontmatter / 无元数据
- 无状态字段（draft/active/done 由外部工具管理）
- 内容完全自由格式
- Plan 是 Claude 在 plan mode 下的思考产出
- 执行时 Claude Code 提供 fresh context 选项

### 社区工具补充的管理层

**ccplan** 在文件外部管理状态：
- 状态：draft / active / done
- 清理：按状态 + 天数过滤删除
- 理念："plan 文档本质上是临时的"

**claude-plan-reviewer** 在执行前插入审查：
- 拦截 ExitPlanMode 事件
- 发送 plan 给外部 AI（Codex/Gemini）审查
- 审查通过才允许退出 plan mode

### 与其他系统的对比

Claude Code plan 是最轻量的方案：
- 无目录约定
- 无文件间引用
- 无状态管理
- 无 artifact 流水线
- 优势：零摩擦、即写即用
- 劣势：无法支持多轮、跨会话、多 agent 协作

---

## 5. 跨项目共通 Patterns

### Pattern 1: Artifact 分层（What → How → Steps）

所有项目都有某种形式的三层分离：

| 层次 | GSD | Superpowers | OpenSpec | Claude Code |
|------|-----|-------------|----------|-------------|
| What（需求/意图） | SPEC.md | spec (design doc) | proposal.md + delta specs | — |
| How（方案/设计） | CONTEXT.md | spec 中的 Design 部分 | design.md | plan 中混合 |
| Steps（执行步骤） | PLAN.md | plan.md | tasks.md | plan 中混合 |

### Pattern 2: 文件夹即工作单元

- GSD: `.planning/phases/XX-name/` — 一个 phase 的所有 artifact
- OpenSpec: `openspec/changes/<name>/` — 一个变更的所有 artifact
- Superpowers: 按日期命名的 spec/plan 文件对

### Pattern 3: 源真相 vs 变更提议 分离

- OpenSpec 最显式：`specs/`（源真相）vs `changes/`（提议）+ archive 合并
- GSD 隐式：PROJECT.md + REQUIREMENTS.md（源真相）vs phases/（变更）
- Superpowers 无此分离（spec 即一次性设计文档）

### Pattern 4: 状态在文件中表达

| 机制 | GSD | OpenSpec | Superpowers |
|------|-----|----------|-------------|
| 全局状态 | STATE.md（<100行） | — | — |
| 任务状态 | checkbox `- [ ]` / `- [x]` | checkbox in tasks.md | checkbox in plan |
| Phase 状态 | ROADMAP 进度表 | archive/ 目录 | — |
| 元数据 | YAML frontmatter | .openspec.yaml | — |
| 会话恢复 | .continue-here.md | — | — |

### Pattern 5: 文件间引用方式

- GSD: 文件路径引用（`See: .planning/PROJECT.md`）+ REQ-ID 交叉引用
- OpenSpec: 目录结构镜像（delta specs 镜像 specs 的领域结构）+ dependsOn 依赖
- Superpowers: Plan header 中 `**Spec:**` 字段指向 spec 文件

### Pattern 6: 审查/验证机制

- GSD: Ambiguity Report（评分表）+ plan-checker agent + verifier agent
- Superpowers: spec-document-reviewer + plan-document-reviewer + spec-compliance-reviewer
- OpenSpec: schema 验证 + archive 前 verify

---

## 6. 对 PGE Contract 文件设计最有价值的 Patterns

### 6.1 GSD 的 SPEC.md 三字段需求格式

```
Current: [当前状态]
Target: [目标状态]
Acceptance: [验收标准]
```

这个格式直接适用于 PGE 的 round-contract：每个 round 的 deliverable 可以用 Current/Target/Acceptance 精确定义，Evaluator 可以直接用 Acceptance 字段做独立裁决。

### 6.2 OpenSpec 的 Delta Spec 模式

ADDED / MODIFIED / REMOVED 的显式变更标记，适用于 PGE 多轮执行中 contract 的演化：
- Round N 的 contract 是 Round N-1 的 delta
- Router 可以基于 MODIFIED/ADDED 决定下一轮范围

### 6.3 GSD 的 continue-here.md Handoff 模式

YAML frontmatter + 结构化 sections 的 handoff 文件，直接适用于 PGE 的跨轮上下文传递：
- current_state / completed_work / remaining_work / decisions_made / next_action
- 恢复后删除（非永久存储）

### 6.4 OpenSpec 的 Schema 定义 Artifact 依赖

```yaml
artifacts:
  - id: proposal
    requires: []
  - id: specs
    requires: [proposal]
  - id: tasks
    requires: [specs, design]
```

这个模式可以用于 PGE 定义 contract 之间的依赖关系和生成顺序。

### 6.5 GSD 的 STATE.md 短期记忆

<100 行的全局状态摘要，适用于 PGE 的 round 间状态传递：
- 当前位置（哪一轮、什么状态）
- 累积上下文（决策、阻塞）
- 会话连续性

### 6.6 Superpowers 的 "零 Placeholder" 原则

Plan 中不允许 TBD/TODO/placeholder，每步必须包含完整可执行内容。这个原则适用于 PGE 的 Generator 输入：round-contract 必须足够具体，Generator 不需要猜测。

---

## 引用来源

- GSD: https://github.com/gsd-build/get-shit-done — templates/roadmap.md, templates/project.md, templates/state.md, templates/spec.md, templates/requirements.md, templates/continue-here.md, docs/ARCHITECTURE.md
- Superpowers: https://github.com/obra/superpowers — skills/brainstorming/SKILL.md, skills/writing-plans/SKILL.md, skills/writing-plans/plan-document-reviewer-prompt.md, skills/subagent-driven-development/spec-reviewer-prompt.md, docs/superpowers/specs/, docs/superpowers/plans/
- OpenSpec: https://github.com/Fission-AI/OpenSpec — docs/concepts.md, openspec/specs/, openspec/changes/, openspec/changes/add-change-stacking-awareness/ (proposal.md, tasks.md, .openspec.yaml, specs/)
- Claude Code: ~/.claude/plans/, planDirectory setting, ccplan (github.com/sorafujitani/ccplan), claude-plan-reviewer (github.com/yuuichieguchi/claude-plan-reviewer)
