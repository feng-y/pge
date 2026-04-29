# PGE Contract Negotiation Design

> 设计日期: 2026-04-29
> 状态: Draft
> 范围: Planner/Generator/Evaluator 三方 contract negotiation 流程

---

## 1. 概述

PGE 的 contract negotiation 是 Planner、Generator、Evaluator 三角色在 implementation 开始前就 "要做什么、怎么验证、什么算通过" 达成可执行共识的过程。

核心原则：**没有 locked contract，禁止 implementation**。

当前 repo 已有 preflight 机制（Generator proposal + Evaluator review），本设计将其扩展为完整的多轮 negotiation 协议，同时保持与现有 contract 体系的兼容。

---

## 2. Planner 如何生成 Round Contract Proposal

### 2.1 从 Raw Intent 到 Proposal 的流程

```
raw intent (user prompt / upstream spec)
  │
  ▼
[1] Planner 读取上游输入 + 最小 repo context
  │
  ▼
[2] 轻量级证据收集 (Read/Grep/Glob only)
  │  - 验证引用的文件/路径是否存在
  │  - 检测 upstream spec 与 repo 现实的冲突
  │  - 收集 design constraints 和 harness constraints
  │
  ▼
[3] 应用 single bounded round heuristic
  │  - 输入已 bounded → pass-through
  │  - 输入过宽 → cut 一个 bounded task
  │
  ▼
[4] 冻结一个 round contract proposal
  │  - 填充所有必需字段 (见 §8)
  │  - 标记 evidence confidence level
  │  - 记录 open_questions
  │
  ▼
[5] 写入 planner_artifact
```

### 2.2 关键行为约束

- Planner 只做 round shaping，不做 full product/spec authoring
- 不做多层/递归分解 — 一次只冻结一个 bounded round contract
- 不指定 Generator 的实现方式 — 只定义 what，不定义 how
- 歧义不静默解决 — 记录在 `open_questions`
- 冲突不静默适配 — 记录在 `planner_escalation`

### 2.3 Planner 产出

写入 `<run_id>-planner.md`，包含完整的 round contract 字段（见 §8 schema）。

---

## 3. Generator 如何 Review Contract

### 3.1 Review 什么

Generator 在 preflight 阶段以 **执行者视角** review Planner 的 contract：

| 检查维度 | 具体内容 |
|----------|---------|
| 可执行性 | contract 是否足够具体，能不靠猜测执行？ |
| 边界清晰度 | in_scope / out_of_scope 是否无歧义？ |
| 交付物明确性 | actual_deliverable 是否指向具体 repo artifact？ |
| 验证可行性 | verification_path 是否可以在当前环境运行？ |
| 证据可收集性 | required_evidence 是否可以通过工具输出获得？ |
| 约束可遵守性 | design_constraints 是否与 repo 现实兼容？ |
| 前置条件 | 执行所需的依赖/工具/文件是否存在？ |

### 3.2 产出什么

写入 `<run_id>-contract-proposal.md`，包含：

```yaml
sections:
  - current_task          # 对 contract 的理解确认
  - execution_boundary_ack # 边界确认
  - deliverable_ack       # 交付物确认
  - verification_plan     # 验证计划（如何执行 verification_path）
  - evidence_plan         # 证据收集计划（如何满足 required_evidence）
  - addressed_preflight_feedback  # 对前次 preflight 反馈的回应（修复轮）
  - unresolved_blockers   # 无法解决的阻塞
  - preflight_status      # READY_FOR_EVALUATOR | BLOCKED
```

### 3.3 通信方式

Generator review 的讨论过程通过 Agent Teams direct communication（SendMessage）进行，不通过文件轮转。Generator 与 Evaluator 之间的 proposal/challenge/response 交互全部使用 SendMessage。只有最终锁定的 contract-proposal artifact 写入文件作为 durable record。

> 通信模型详见 `pge-agent-teams-communication-design.md`。

### 3.4 关键约束

- **不修改 repo 文件** — preflight 阶段禁止 repo 编辑
- **不静默覆盖 Planner 约束** — Planner 是 evidence/design authority
- **修复轮必须聚焦** — 只回应 preflight feedback，不扩展 scope

---

## 4. Evaluator 如何 Review Contract

### 4.1 Review 什么

Evaluator 在 preflight 阶段以 **独立验证者视角** review Planner contract + Generator proposal 的组合：

| 检查维度 | 具体内容 |
|----------|---------|
| 公平性 | contract 是否构成公平的评估框架？ |
| 可独立评估性 | Evaluator 能否仅凭 contract + deliverable 独立判断？ |
| 可测试性 | acceptance_criteria 是否可观察、可检查？ |
| 无歧义性 | contract 是否有多种合理解读？ |
| 无自相矛盾 | 各字段之间是否一致？ |
| 范围合理性 | scope 是否过宽导致无法在一轮内完成？ |
| 证据充分性 | required_evidence 是否足以支撑独立判断？ |
| Generator 理解正确性 | Generator proposal 是否正确理解了 contract？ |

### 4.2 产出什么

写入 `<run_id>-preflight.md`，包含：

```yaml
sections:
  - preflight_verdict     # PASS | BLOCK | ESCALATE
  - evidence              # 支撑 verdict 的具体证据
  - contract_risks        # 识别到的 contract 风险
  - required_contract_fixes  # 需要修复的具体问题
  - repair_owner          # generator | planner
  - next_route            # ready_to_generate | return_to_planner
```

### 4.3 通信方式

Evaluator review 的讨论过程通过 Agent Teams direct communication（SendMessage）进行。Evaluator 的 challenge、clarification request、inline feedback 全部使用 SendMessage 发送给 Generator。只有最终锁定的 preflight verdict artifact 写入文件作为 durable record。

> 通信模型详见 `pge-agent-teams-communication-design.md`。

### 4.4 Verdict 语义

| Verdict | 含义 | 后续 |
|---------|------|------|
| `PASS` | contract + proposal 构成可执行、可独立评估的 round | → `ready_to_generate` |
| `BLOCK` | 存在必须修复的问题，但 contract 框架本身可能仍然正确 | → `generator` 修复 或 `planner` 修复 |
| `ESCALATE` | contract 本身有问题，需要 replanning | → `return_to_planner` |

### 4.5 repair_owner 决策规则

- `generator`: Planner contract 可以保持冻结，Generator proposal 可以在不猜测的情况下修复
- `planner`: contract 本身歧义、不公平、自相矛盾、过大、或缺少可执行 round 所需的基础

---

## 5. 多轮 Negotiation 如何收敛

> **通信通道**: Negotiation 走 Agent Teams direct communication，结果才落文件。状态机和收敛逻辑不变，但每一轮 negotiation turn（proposal、challenge、response、feedback）通过 SendMessage 进行，不通过文件写入。只有 phase boundary 的最终锁定结果（contract-proposal、preflight verdict）写入文件。详见 `pge-agent-teams-communication-design.md`。

### 5.1 状态机

```
                    ┌─────────────────────────────────────┐
                    │                                     │
                    ▼                                     │
[planning_round] ──→ [preflight_pending] ──→ PASS ──→ [ready_to_generate]
                         │       ▲
                         │       │ (repair attempt, generator owns)
                         │       │
                         ▼       │
                    BLOCK(generator) ──→ Generator 修复 proposal ──┘
                         │                    (attempt_id++)
                         │
                         ▼
                    BLOCK(planner) / ESCALATE / attempts exhausted
                         │
                         ▼
                    [return_to_planner] ──→ Planner 重新冻结 contract ──→ [preflight_pending]
                         │                        (negotiation_round++)
                         │
                         ▼ (max rounds exhausted)
                    [negotiation_failed] ──→ STOP
```

### 5.2 收敛参数

| 参数 | 默认值 | 含义 |
|------|--------|------|
| `max_preflight_attempts` | 2 | 单个 contract 下 Generator proposal 的最大修复次数 |
| `max_negotiation_rounds` | 3 | Planner 重新冻结 contract 的最大轮数 |
| `max_total_preflight_cycles` | 6 | 整个 negotiation 过程的 preflight 总次数上限 |

### 5.3 收敛条件

Negotiation 在以下任一条件满足时收敛：

1. **PASS**: Evaluator preflight verdict = `PASS`，next_route = `ready_to_generate`
2. **Repair 成功**: Generator 修复 proposal 后 Evaluator 给出 `PASS`
3. **Replanning 成功**: Planner 重新冻结 contract 后新一轮 preflight 给出 `PASS`

### 5.4 终止条件（非收敛退出）

| 条件 | 行为 |
|------|------|
| `max_preflight_attempts` 耗尽且 repair_owner = generator | 升级到 return_to_planner |
| `max_negotiation_rounds` 耗尽 | 设置 state = `negotiation_failed`，停止 |
| `max_total_preflight_cycles` 耗尽 | 设置 state = `negotiation_failed`，停止 |
| Evaluator 发出 `ESCALATE` | 直接 return_to_planner（消耗一个 negotiation round） |
| Planner 发出 `planner_escalation != None` | 设置 state = `negotiation_failed`，停止 |

### 5.5 超时处理

当前阶段不实现时间超时。收敛完全由轮次计数控制。未来可增加：
- 单次 preflight 的 token budget 上限
- 整个 negotiation 的 wall-clock timeout

---

## 6. Locked Contract 的条件

### 6.1 什么是 Locked Contract

Locked contract 是经过 negotiation 达成三方共识的、不可再修改的执行合约。它是 Generator implementation 的唯一授权依据。

### 6.2 Lock 条件

Contract 被锁定当且仅当以下全部满足：

1. Planner 已冻结一个完整的 round contract（所有必需字段存在且非空）
2. Generator 已提交 proposal 且 `preflight_status = READY_FOR_EVALUATOR`
3. Evaluator preflight verdict = `PASS` 且 `next_route = ready_to_generate`
4. Runtime state 转换到 `ready_to_generate`

### 6.3 Lock 的效果

一旦 contract 被锁定：

- Generator 必须按 locked contract 执行，不得重新定义
- Evaluator 必须按 locked contract 评估，不得重新定义
- 任何偏离必须在 `deviations_from_spec` 中声明
- Contract 只能通过 `ESCALATE` → `return_to_planner` 解锁并重新协商

### 6.4 Lock 的持久化

Locked contract 通过以下 artifact 组合持久化：

- `<run_id>-planner.md` — Planner 冻结的 contract
- `<run_id>-contract-proposal.md` — Generator 的执行确认
- `<run_id>-preflight.md` — Evaluator 的 PASS verdict
- `<run_id>-state.json` — `state: "ready_to_generate"` 记录 lock 状态

---

## 7. 没有 Locked Contract 时禁止 Implementation

### 7.1 Hard Gate 机制

```
Generator 收到 implementation 任务
  │
  ▼
检查 runtime state
  │
  ├── state == "ready_to_generate" → 允许 repo 编辑
  │
  └── state != "ready_to_generate" → 禁止 repo 编辑，报告 blocker
```

### 7.2 Gate 的实施层次

| 层次 | 机制 | 当前状态 |
|------|------|---------|
| Orchestration gate | `main` 只在 `state = ready_to_generate` 后才 dispatch generator implementation | 已实现 |
| Handoff gate | `handoffs/generator.md` 明确声明 "preflight 通过前不能编辑 repo" | 已实现 |
| Agent behavior gate | `pge-generator.md` 明确禁止 preflight 前的 repo 编辑 | 已实现 |
| Artifact gate | `<run_id>-preflight.md` 必须存在且包含 `PASS` verdict | 已实现 |

### 7.3 违反 Gate 的后果

- 如果 Generator 在 preflight 前编辑了 repo 文件：这是 Generator failure
- Evaluator 在最终评估时应检查 `changed_files` 的时间线是否与 preflight PASS 一致
- 违反 hard gate 的 run 应被标记为 `failed`，不是 `RETRY`

---

## 8. Contract 必须包含的字段

### 8.1 Round Contract Schema

以下是 round contract 的完整字段定义。字段分为三类：执行字段（Generator 消费）、评估字段（Evaluator 消费）、路由字段（main 消费）。

```yaml
round_contract:
  # === 执行字段 (Generator 消费) ===
  goal:
    type: string
    required: true
    description: 本轮必须解决的具体目标。必须是可检查的陈述，不是模糊愿望。
    example: "在 src/auth/login.ts 中实现 email 格式验证函数 validateEmail()"

  evidence_basis:
    type: list[evidence_item]
    required: true
    description: Planner 选择本轮的证据基础。每项包含 source、fact、confidence。
    item_schema:
      source: string    # 证据来源（文件路径、命令输出、upstream spec 引用）
      fact: string      # 具体事实
      confidence: enum  # high | medium | low
    example:
      - source: "skills/pge-execute/contracts/round-contract.md"
        fact: "round contract 要求 11 个必需字段"
        confidence: high

  design_constraints:
    type: list[string]
    required: true
    description: Generator 必须遵守的设计和 harness 约束。
    example:
      - "不修改 contracts/ 下的现有文件"
      - "保持 SKILL.md ≤ 220 行"

  in_scope:
    type: list[string]
    required: true
    description: 本轮允许变更的范围。
    example:
      - "src/auth/login.ts"
      - "tests/auth/login.test.ts"

  out_of_scope:
    type: list[string]
    required: true
    description: 本轮禁止变更的范围。
    example:
      - "src/auth/signup.ts"
      - "数据库 schema 变更"

  actual_deliverable:
    type: string
    required: true
    description: 本轮必须产出的具体 repo artifact。必须指向可定位的文件或文件集。
    example: "文件 src/auth/login.ts 包含 validateEmail() 函数"

  verification_path:
    type: string
    required: true
    description: 本轮的主要验证方式。必须是可执行的命令或可检查的条件。
    example: "npm test -- auth/login.test.ts"

  # === 评估字段 (Evaluator 消费) ===
  acceptance_criteria:
    type: list[criterion]
    required: true
    description: 本轮完成的最低条件。每项必须是可观察、可检查的。
    item_schema:
      id: string        # 标准编号 (AC-1, AC-2, ...)
      description: string  # 可检查的条件描述
      evidence_type: enum  # tool_output | file_content | command_result | path_existence
    example:
      - id: AC-1
        description: "validateEmail('invalid') 返回 false"
        evidence_type: tool_output
      - id: AC-2
        description: "validateEmail('user@example.com') 返回 true"
        evidence_type: tool_output

  required_evidence:
    type: list[string]
    required: true
    description: Evaluator 独立判断所需的最低证据。
    example:
      - "verification_path 的命令输出（含 exit code）"
      - "deliverable 文件的关键内容摘录"

  evaluator_thresholds:
    type: object
    required: false
    description: 可选的量化评估阈值。当存在时，Evaluator 必须按阈值判断。
    schema:
      criteria_pass_rate:
        type: number    # 0.0 - 1.0
        description: acceptance_criteria 中必须通过的最低比例
        default: 1.0    # 默认全部通过
      evidence_coverage:
        type: number    # 0.0 - 1.0
        description: required_evidence 中必须提供的最低比例
        default: 1.0
      hard_fail_criteria:
        type: list[string]  # AC id 列表
        description: 任一失败即 BLOCK 的硬阈值标准
        default: []
    example:
      criteria_pass_rate: 1.0
      evidence_coverage: 1.0
      hard_fail_criteria: ["AC-1"]

  # === 路由字段 (main 消费) ===
  stop_condition:
    type: string
    required: true
    description: 标记本轮完成的条件，用于 continue vs converged 路由决策。
    allowed_values:
      - single_round      # 本轮通过即 converged
      - slice_complete     # 当前 slice 完成即 converged
      - goal_satisfied     # 目标满足即 converged
      - "deliverable_count:N"  # N 个 deliverable 完成即 converged
    example: "single_round"

  handoff_seam:
    type: string
    required: true
    description: 后续工作的接续点。明确本轮不做什么，后续从哪里继续。
    example: "email 验证完成后，signup flow 集成在下一轮处理"

  retry_policy:
    type: object
    required: false
    description: 本轮的重试策略。当存在时覆盖默认值。
    schema:
      max_generator_retries:
        type: integer
        default: 1
        description: Generator 在同一 contract 下的最大重试次数
      retry_scope:
        type: enum  # full | incremental
        default: incremental
        description: 重试时是全量重做还是增量修复
      escalation_after:
        type: integer
        default: 2
        description: 连续失败多少次后升级到 return_to_planner
    example:
      max_generator_retries: 1
      retry_scope: incremental
      escalation_after: 2

  # === Planner 元数据 ===
  open_questions:
    type: list[string]
    required: true
    description: 未解决的歧义。可以为空列表。
    example: []

  planner_note:
    type: enum
    required: true
    allowed_values: [pass-through, cut]
    description: Planner 对上游输入的处理方式。

  planner_escalation:
    type: string
    required: true
    description: "None" 或一个具体的无法冻结原因。
    example: "None"
```

### 8.2 Generator Proposal Schema

```yaml
contract_proposal:
  current_task:
    type: string
    required: true
    description: Generator 对 contract goal 的理解确认。

  execution_boundary_ack:
    type: string
    required: true
    description: 对 in_scope / out_of_scope 边界的确认。

  deliverable_ack:
    type: string
    required: true
    description: 对 actual_deliverable 的确认，包括 Generator 理解的具体产出。

  verification_plan:
    type: string
    required: true
    description: 如何执行 verification_path 的具体计划。

  evidence_plan:
    type: string
    required: true
    description: 如何收集 required_evidence 的具体计划。

  addressed_preflight_feedback:
    type: string
    required: true
    description: 对前次 preflight 反馈的回应。首次为 "N/A"。

  unresolved_blockers:
    type: list[string]
    required: true
    description: 无法解决的阻塞。可以为空列表。

  preflight_status:
    type: enum
    required: true
    allowed_values: [READY_FOR_EVALUATOR, BLOCKED]
```

### 8.3 Preflight Verdict Schema

```yaml
preflight_verdict_bundle:
  preflight_verdict:
    type: enum
    required: true
    allowed_values: [PASS, BLOCK, ESCALATE]

  evidence:
    type: string
    required: true
    description: 支撑 verdict 的具体证据。

  contract_risks:
    type: list[string]
    required: true
    description: 识别到的 contract 风险。可以为空列表。

  required_contract_fixes:
    type: list[string]
    required: true
    description: 需要修复的具体问题。PASS 时为空列表。

  repair_owner:
    type: enum
    required: true
    allowed_values: [generator, planner]

  next_route:
    type: enum
    required: true
    allowed_values: [ready_to_generate, return_to_planner]
```

---

## 9. Contract 文件格式

### 9.1 格式选择：Markdown with Structured Sections

Contract 使用 **Markdown** 格式，每个字段对应一个 `## section`。

选择 Markdown 而非 YAML/JSON 的理由：
- 与当前 repo 中所有 contract 和 agent artifact 的格式一致
- Claude Code agent 原生读写 Markdown，无需额外解析
- 支持富文本内容（列表、代码块、表格）
- 结构化 gate 通过 section 存在性检查实现（已有 `pge-validate-contracts.sh` 先例）

### 9.2 Round Contract 文件示例

```markdown
## goal

在 src/auth/login.ts 中实现 email 格式验证函数 validateEmail()

## evidence_basis

- source: upstream user prompt
  fact: 用户要求添加 email 验证
  confidence: high
- source: src/auth/login.ts
  fact: 当前无 email 验证逻辑
  confidence: high (verified via grep)

## design_constraints

- 不修改现有 auth flow
- 使用 RFC 5322 基础验证，不引入外部库

## in_scope

- src/auth/login.ts
- tests/auth/login.test.ts

## out_of_scope

- src/auth/signup.ts
- 数据库 schema
- UI 组件

## actual_deliverable

文件 src/auth/login.ts 包含导出函数 validateEmail(email: string): boolean

## acceptance_criteria

- AC-1: validateEmail('invalid') 返回 false
- AC-2: validateEmail('user@example.com') 返回 true
- AC-3: validateEmail('') 返回 false
- AC-4: 函数已导出且可被其他模块引用

## verification_path

npm test -- auth/login.test.ts

## required_evidence

- verification_path 命令输出（含 exit code 和 pass/fail 计数）
- validateEmail 函数的实际代码内容

## stop_condition

single_round

## handoff_seam

email 验证完成后，signup flow 集成在下一轮处理

## evaluator_thresholds

- criteria_pass_rate: 1.0
- hard_fail_criteria: [AC-1, AC-2]

## retry_policy

- max_generator_retries: 1
- retry_scope: incremental
- escalation_after: 2

## open_questions

（无）

## planner_note

pass-through

## planner_escalation

None
```

### 9.3 Artifact 路径约定

```
.pge-artifacts/<run_id>-planner.md           # Planner 冻结的 round contract
.pge-artifacts/<run_id>-contract-proposal.md  # Generator 的 preflight proposal
.pge-artifacts/<run_id>-preflight.md          # Evaluator 的 preflight verdict
.pge-artifacts/<run_id>-state.json            # Runtime state (含 lock 状态)
```

与当前 repo 的 artifact 路径完全一致（见 `ORCHESTRATION.md`）。

---

## 10. Contract 与当前 Repo 中已有 Contract 的关系

### 10.1 兼容性策略：扩展，不替换

本设计与现有 `skills/pge-execute/contracts/` 的关系是 **向后兼容的扩展**：

| 现有 Contract | 本设计的关系 |
|--------------|-------------|
| `round-contract.md` | **基础**。本设计的 round contract schema 是对其 11 个字段的超集扩展，增加了 `evaluator_thresholds`、`retry_policy`、`open_questions`、`planner_note`、`planner_escalation` |
| `evaluation-contract.md` | **不变**。verdict 语义 (PASS/RETRY/BLOCK/ESCALATE) 和选择规则完全复用 |
| `routing-contract.md` | **不变**。verdict→route 映射和 continue vs converged 决策规则完全复用 |
| `runtime-state-contract.md` | **扩展**。增加 `negotiation_round`、`max_negotiation_rounds`、`max_total_preflight_cycles` 状态字段 |
| `entry-contract.md` | **不变**。Planner 仍然负责规范化上游输入 |

### 10.2 新增字段的向后兼容

新增的 contract 字段（`evaluator_thresholds`、`retry_policy`）标记为 `required: false`。当这些字段不存在时：

- `evaluator_thresholds` 缺失 → Evaluator 使用默认行为（全部 criteria 必须通过）
- `retry_policy` 缺失 → 使用默认重试参数

这意味着现有的 smoke test (`/pge-execute test`) 无需修改即可继续工作。

### 10.3 新增 Runtime State 字段

> **统一 schema**: 以下字段已合并到 `pge-multiround-runtime-design.md` §2.1 的统一 runtime-state schema 中。本节保留字段定义供参考，但 `pge-multiround-runtime-design.md` §2.1 是 canonical schema。

```yaml
# 在 state_artifact 中新增（已纳入统一 schema）
negotiation_round: 1              # 当前 negotiation 轮次
max_negotiation_rounds: 3         # 最大 negotiation 轮次
total_preflight_cycles: 0         # 已消耗的 preflight 总次数
max_total_preflight_cycles: 6     # preflight 总次数上限
contract_locked: false             # contract 是否已锁定
contract_locked_at_preflight: null # 锁定时的 preflight_attempt_id
```

### 10.4 新增状态转换

在 `runtime-state-contract.md` 的 allowed transitions 基础上增加：

```
routing -> planning_round          # return_to_planner (negotiation 重新开始)
preflight_pending -> planning_round # preflight attempts 耗尽，升级到 replanning
```

> **状态名对齐**: 使用 `planning_round`（与 `runtime-state-contract.md` 和 `pge-multiround-runtime-design.md` §8.1 一致）。

当前阶段这些转换仍然停在 `unsupported_route`，直到多轮 runtime 实现。

---

## 11. 完整 Negotiation 流程图

```
User invokes /pge-execute <task>
  │
  ▼
[main] Initialize run
  │
  ▼
[main] Create team (planner, generator, evaluator)
  │
  ▼
┌─── NEGOTIATION LOOP (max_negotiation_rounds) ──────────────────────┐
│                                                                     │
│  [Planner] 冻结 round contract → planner_artifact                  │
│    │                                                                │
│    ▼                                                                │
│  ┌─── PREFLIGHT LOOP (max_preflight_attempts) ──────────────────┐  │
│  │                                                               │  │
│  │  [Generator] Review contract → contract_proposal_artifact     │  │
│  │    │                                                          │  │
│  │    ▼                                                          │  │
│  │  [Evaluator] Review contract+proposal → preflight_artifact    │  │
│  │    │                                                          │  │
│  │    ├── PASS → CONTRACT LOCKED → exit both loops               │  │
│  │    │                                                          │  │
│  │    ├── BLOCK(generator) + attempts remaining                  │  │
│  │    │     → Generator 修复 proposal → loop back                │  │
│  │    │                                                          │  │
│  │    └── BLOCK(planner) / ESCALATE / attempts exhausted         │  │
│  │          → exit preflight loop                                │  │
│  └───────────────────────────────────────────────────────────────┘  │
│    │                                                                │
│    ├── PASS → already exited above                                  │
│    │                                                                │
│    └── needs replanning + rounds remaining                          │
│          → Planner 重新冻结 contract → loop back                    │
│                                                                     │
└─────────────────────────────────────────────────────────────────────┘
  │
  ├── CONTRACT LOCKED → [Generator] Implementation → [Evaluator] Final evaluation → Route
  │
  └── NEGOTIATION FAILED → state = negotiation_failed, stop
```

---

## 12. 实施路径

### 12.1 需要变更的现有文件

| 文件 | 变更内容 |
|------|---------|
| `skills/pge-execute/handoffs/preflight.md` | 增加 structured feedback 格式、收敛检测逻辑、negotiation loop 调度 |
| `skills/pge-execute/runtime/artifacts-and-state.md` | 增加 negotiation 相关 state 字段（已纳入统一 schema）、调整 max_preflight_attempts |
| `skills/pge-execute/contracts/evaluation-contract.md` | 增加 preflight 阶段的 structured feedback 定义 |
| `skills/pge-execute/ORCHESTRATION.md` | 增加 negotiation loop 生命周期（当 multi-round 实现时） |
| `skills/pge-execute/contracts/runtime-state-contract.md` | 增加 negotiation 相关状态转换 |

### 12.2 无需新增文件

本设计不需要新增文件。所有变更通过扩展现有文件实现。

### 12.3 分阶段实施

- **Phase 3 (Preflight 协商增强)**: structured feedback 格式 + 收敛检测 + max_preflight_attempts 调整
- **Phase 2 (Multi-round 路由) 之后**: negotiation loop 的完整生命周期（return_to_planner 路由可用后）

---

## 13. 设计决策记录

### D1: 为什么用 Markdown 而非 YAML/JSON

Anthropic 的经验表明 JSON 比 Markdown 更不容易被 agent 不当修改（ref-anthropic §4）。但 PGE 的 contract 需要富文本内容（evidence_basis 的叙述、acceptance_criteria 的复杂条件），且当前 repo 全部使用 Markdown。Gate 通过 section 存在性检查实现，不依赖 JSON 解析。因此选择 Markdown，但对关键枚举值（verdict、route、status）使用严格的 allowed_values 约束。

### D2: 为什么 Evaluator 在 preflight 阶段就参与

Anthropic 的 contract 协商模式（ref-anthropic §4）证明：在 implementation 前让 Evaluator 审查 contract 可以避免 "Generator 构建了错误的东西" 的问题。Superpowers 的 hard-gate 模式（ref-superpowers §1.2）进一步证明：强制 pause 比建议 pause 有效得多。

### D3: 为什么 max_negotiation_rounds = 3

经验法则：如果三轮 replanning 仍无法达成共识，问题通常不在 contract 层面，而在 upstream intent 层面。继续 negotiation 只会增加 token 消耗而不会收敛。此时应该停止并向用户报告。

### D4: 为什么新增字段是 optional

保持向后兼容。现有的 smoke test 和单轮执行不需要 `evaluator_thresholds` 或 `retry_policy`。渐进式引入新能力，不破坏已有流程。

### D5: 通信方式选择混合模型

~~Anthropic 明确推荐 "通信通过文件"（ref-anthropic §4）。~~ 初始设计采用纯文件通信，但 Agent Teams 提供了 direct communication（SendMessage）能力。更新后的设计采用混合模型：negotiation 过程（proposal/challenge/response/feedback）使用 SendMessage 进行实时协作，只有最终锁定结果（contract、verdict、evidence、route）写入文件作为 durable record。这减少了中间文件 I/O，允许 G↔E 直接对话，同时保留了文件作为审计轨迹和 resume 依据的优势。

> 权威通信模型: `pge-agent-teams-communication-design.md`

---

## 13. 引用来源

| 来源 | 相关内容 |
|------|---------|
| `docs/design/pge-agent-teams-communication-design.md` | **权威通信模型** — runtime communication plane vs durable control plane 职责划分 |
| `docs/design/research/ref-anthropic.md` §3-4 | Contract 协商、preflight negotiation |
| `docs/design/research/ref-anthropic.md` §5 | Hard evaluator thresholds |
| `docs/design/research/ref-superpowers.md` §1-2 | Hard-gate、前置澄清流程 |
| `docs/design/research/ref-openspec.md` §2-3 | Artifact 组织、行为契约 |
| `docs/design/research/repo-analysis.md` §3-6 | 当前 P/G/E 角色、contract 体系 |
| `skills/pge-execute/contracts/round-contract.md` | 现有 round contract 字段 |
| `skills/pge-execute/contracts/evaluation-contract.md` | 现有 verdict 语义 |
| `skills/pge-execute/contracts/routing-contract.md` | 现有路由规则 |
| `skills/pge-execute/handoffs/preflight.md` | 现有 preflight 机制 |
| `agents/pge-planner.md` | Planner 行为定义 |
| `agents/pge-generator.md` | Generator 行为定义 |
| `agents/pge-evaluator.md` | Evaluator 行为定义 |
