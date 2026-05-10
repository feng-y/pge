# OpenSpec 调研报告

来源: [Fission-AI/OpenSpec](https://github.com/Fission-AI/OpenSpec) — "Spec-driven development (SDD) for AI coding assistants"

## 概述

OpenSpec 是一个轻量级的 spec 框架，在 AI coding assistant 和人之间加一层 spec 层，让双方在写代码前先对齐要构建什么。核心哲学：fluid not rigid, iterative not waterfall, brownfield-first。

## Artifact 类型和结构

### 两大顶层区域

```
openspec/
├── specs/          # 源头真相 — 系统当前行为的规范
│   ├── auth/
│   │   └── spec.md
│   └── payments/
│       └── spec.md
├── changes/        # 提议的修改 — 每个 change 一个文件夹
│   ├── add-dark-mode/
│   │   ├── proposal.md
│   │   ├── design.md
│   │   ├── tasks.md
│   │   ├── .openspec.yaml
│   │   └── specs/        # delta specs
│   │       └── ui/
│   │           └── spec.md
│   └── archive/          # 已完成的 changes
│       └── 2025-01-24-add-auth/
├── schemas/        # 工作流定义（可自定义）
│   └── spec-driven/
│       ├── schema.yaml
│       └── templates/
├── config.yaml     # 项目配置
└── explorations/   # 探索性思考（无结构要求）
```

### 四种核心 Artifact

在默认的 `spec-driven` schema 下，每个 change 包含四种 artifact：

| Artifact | 文件 | 回答什么 | 依赖 |
|----------|------|----------|------|
| proposal | `proposal.md` | WHY — 为什么要做这个改动 | 无（根节点） |
| specs | `specs/**/*.md` | WHAT — 系统应该做什么（delta 格式） | proposal |
| design | `design.md` | HOW — 技术方案和架构决策 | proposal |
| tasks | `tasks.md` | STEPS — 实现步骤清单（checkbox） | specs + design |

依赖关系形成 DAG：

```
            proposal
           /        \
        specs      design
           \        /
            tasks
```

### Spec 的内部结构

Spec 是行为契约（behavior contract），不是实现计划：

```markdown
# Auth Specification

## Purpose
Authentication and session management.

## Requirements

### Requirement: User Authentication
The system SHALL issue a JWT token upon successful login.

#### Scenario: Valid credentials
- GIVEN a user with valid credentials
- WHEN the user submits login form
- THEN a JWT token is returned

### Requirement: Session Expiration
The system MUST expire sessions after 30 minutes of inactivity.
```

关键设计点：
- 用 RFC 2119 关键词（SHALL/MUST/SHOULD/MAY）表达要求强度
- 每个 Requirement 必须有至少一个 Scenario
- Scenario 用 GIVEN/WHEN/THEN 格式，可直接映射为测试用例
- Spec 只描述可观察行为，不包含实现细节

### Delta Spec 机制

这是 OpenSpec 最核心的设计 — change 中的 spec 不是完整重写，而是增量描述：

```markdown
# Delta for Auth

## ADDED Requirements
### Requirement: Two-Factor Authentication
...

## MODIFIED Requirements
### Requirement: Session Expiration
The system MUST expire sessions after 15 minutes of inactivity.
(Previously: 30 minutes)

## REMOVED Requirements
### Requirement: Remember Me
**Reason**: Deprecated in favor of 2FA
**Migration**: Use new auth endpoint
```

三种 delta 操作：
- ADDED — 新行为，archive 时追加到主 spec
- MODIFIED — 变更行为，archive 时替换对应 requirement
- REMOVED — 废弃行为，archive 时从主 spec 删除

### Schema 定义

Schema 用 YAML 定义 artifact 类型、依赖关系和生成指令：

```yaml
name: spec-driven
artifacts:
  - id: proposal
    generates: proposal.md
    requires: []
    instruction: |
      Create the proposal document...
  - id: specs
    generates: "specs/**/*.md"
    requires: [proposal]
  - id: design
    generates: design.md
    requires: [proposal]
  - id: tasks
    generates: tasks.md
    requires: [specs, design]

apply:
  requires: [tasks]
  tracks: tasks.md
```

Schema 可以自定义（fork 或从头创建），支持不同团队的工作流。

## Artifact 生命周期

### Change 的生命周期

```
创建 → 规划（生成 artifacts）→ 实现（执行 tasks）→ 验证 → 归档
```

核心原则：**Actions, not phases** — 没有阶段门禁，可以随时回去修改任何 artifact。

### Artifact 状态模型

```
BLOCKED → READY → DONE
  │         │       │
缺少依赖  依赖完成  文件存在于文件系统
```

状态检测基于文件系统存在性（不是数据库或状态文件）。

### Archive 流程

归档时发生三件事：
1. Delta specs 合并到主 specs（ADDED 追加，MODIFIED 替换，REMOVED 删除）
2. Change 文件夹移到 `changes/archive/YYYY-MM-DD-name/`
3. 所有 artifact 原样保留在 archive 中（完整审计轨迹）

归档后，specs/ 成为更新后的源头真相，下一个 change 基于更新后的 specs 构建。

## 对 PGE 有价值的设计点

### 1. Specs 与 Changes 的分离

OpenSpec 将"当前真相"（specs/）和"提议修改"（changes/）物理分离。这让多个 change 可以并行存在而不冲突。

PGE 启发：contract 的"当前基线"和"正在进行的修改"可以类似分离。

### 2. Delta 机制

不重写整个 spec，只描述增量变化（ADDED/MODIFIED/REMOVED）。这对 brownfield 开发特别友好。

PGE 启发：contract 的演进可以用 delta 方式描述，而不是每次全量重写。

### 3. Schema-driven 的 artifact DAG

Artifact 之间的依赖关系用 YAML schema 声明式定义，形成 DAG。状态检测基于文件系统。

PGE 启发：proving run 的 artifact 依赖关系可以声明式定义，而不是硬编码在流程中。

### 4. 文件夹即 change 的组织方式

每个 change 是一个自包含的文件夹，包含所有相关 artifact。完成后整体归档。

PGE 启发：每个 proving round 或 execution 可以是一个自包含文件夹。

### 5. 行为契约而非实现计划

Spec 只描述可观察行为（WHEN/THEN），不包含实现细节。实现细节在 design.md 和 tasks.md 中。

PGE 启发：contract 应该描述"什么算通过"（verdict 条件），而不是"怎么实现"。

### 6. 渐进式严格度（Progressive Rigor）

大多数 change 用 Lite spec（简短行为要求 + 验收检查），只有高风险 change 才用 Full spec。

PGE 启发：不是所有 proving run 都需要同等严格度的 contract。

## 不适用于 PGE 的部分

### 1. 面向人类的交互模型

OpenSpec 的核心场景是人类开发者通过 slash command 与 AI 协作。PGE 的场景是 agent 自主执行 proving run，交互模型不同。

### 2. 线性的 propose → apply → archive 流程

OpenSpec 假设一个 change 从提议到实现到归档是一个相对线性的过程（虽然允许回退）。PGE 的 proving run 可能有更复杂的状态转换（retry、partial success、escalation）。

### 3. 文本 diff 式的 delta merge

OpenSpec 的 delta merge 基于 requirement 名称匹配和文本替换。PGE 的 contract 演进可能需要更结构化的 merge 语义。

### 4. 单一 schema 假设

OpenSpec 假设一个项目用一个 schema（虽然支持自定义）。PGE 可能需要不同类型的 proving run 使用不同的 artifact 结构。

### 5. 无运行时状态

OpenSpec 的状态完全基于文件系统存在性检测。PGE 需要运行时状态（agent 执行状态、verdict 结果、round 进度）。

## 关键术语映射

| OpenSpec | PGE 可能对应 |
|----------|-------------|
| spec | contract baseline |
| change | proving round / execution |
| proposal | round intent / goal |
| delta spec | contract amendment |
| design | execution strategy |
| tasks | execution steps |
| archive | round record |
| schema | run type definition |
| verify | verdict evaluation |
