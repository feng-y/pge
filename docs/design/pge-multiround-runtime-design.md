# PGE Multi-Round Runtime Design

> Version: 0.3.0
> Date: 2026-04-29
> Status: Draft (hybrid communication integration)
> Scope: run / slice / round 层次、runtime-state、progress、evidence、verdict、route 结构定义，checkpoint/handoff/resume 机制，状态流转，多 slice 稳定执行，混合通信（message + file）上下文恢复

---

## 1. Run / Slice / Round 层次关系

> **术语说明**: 本设计使用 "slice" 而非 "sprint"。Anthropic 在 Opus 4.6 上移除了 sprint 构造（见 `pge-reference-learning-notes.md` §1 "不学什么"）。PGE 的 slice 是不同的概念：它是 run 内的一个有界工作阶段，对应 `runtime-state-contract.md` 中已有的 `active_slice_ref`，提供 Planner 重新规划的自然边界。这不是 Anthropic 的 sprint contract 模式的复制，而是 PGE bounded proving 的固有需求。

### 1.1 定义

```
run
├── slice 1
│   ├── round 1  (plan → generate → evaluate → route)
│   ├── round 2  (retry / continue within same slice goal)
│   └── round N
├── slice 2
│   ├── round 1
│   └── round N
└── slice M
    └── ...
```

| 层级 | 定义 | 生命周期 | 身份标识 |
|------|------|----------|----------|
| **run** | 一次完整的 PGE 执行，从用户调用到最终收敛或停止。对应一个上游目标或 proving packet。 | 用户调用 `/pge-execute` 到 terminal state | `run_id` |
| **slice** | run 内的一个有界工作阶段，对应一个 bounded slice（可验证的子目标）。slice 切换意味着 Planner 重新规划。 | Planner 冻结 slice 到 slice 完成或放弃 | `slice_id` (= `run_id` + `-s` + sequence) |
| **round** | slice 内的一次 plan→generate→evaluate→route 循环。retry 产生新 round，continue 到下一 slice。 | Planner 冻结 round contract 到 Evaluator verdict + route | `round_id` (= `slice_id` + `-r` + sequence) |

### 1.2 层次规则

- 一个 run 包含 1..M 个 slice（M ≤ `max_slices`，默认 5）
- 一个 slice 包含 1..N 个 round（N ≤ `max_rounds_per_slice`，默认 3）
- round 是最小执行单元，不可再分
- slice 边界 = Planner 重新规划（新 slice 或 return_to_planner）
- round 边界 = 同一 slice 内的 retry 或 attempt

### 1.3 与当前 repo 的对齐

当前 repo 状态：只支持单 round 执行（`run_stop_condition = single_round`）。

对齐方式：
- 当前的 `run_id` 保持不变
- 当前缺少 `slice_id` 和 `round_id` → 新增
- 当前 `runtime-state-contract.md` 中的 `active_slice_ref` 直接对应 slice
- 当前 `active_round_contract_ref` 对应 round
- 当前 `persistent-runner.md` 中的 `round_id` 和 `attempt_id` 合并为本设计的 `round_id`

---

## 2. Runtime-State 结构

### 2.1 完整 schema

```jsonc
{
  // === 身份 ===
  "run_id": "run-20260429T120000Z",
  "slice_id": "run-20260429T120000Z-s1",
  "round_id": "run-20260429T120000Z-s1-r1",

  // === 上游引用 ===
  "upstream_plan_ref": ".pge-artifacts/test-upstream-plan.md",
  "run_stop_condition": "single_round",
  // === Slice 状态 ===
  "slice_sequence": 1,
  "max_slices": 5,
  "slice_goal": "implement smoke test deliverable",
  "slice_status": "active",

  // === Round 状态 ===
  "round_sequence": 1,
  "max_rounds_per_slice": 3,
  "preflight_attempt": 1,
  "max_preflight_attempts": 2,

  // === 阶段状态 ===
  "state": "initialized",
  "active_phase": null,

  // === Team ===
  "team_name": "pge-runtime-run-20260429T120000Z",
  "team_status": "not_created",

  // === 阶段追踪 ===
  "planner_called": false,
  "preflight_called": false,
  "generator_called": false,
  "evaluator_called": false,

  // === 结果 ===
  "verdict": null,
  "route": null,
  "route_reason": null,
  "convergence_reason": null,

  // === 引用 ===
  "active_round_contract_ref": null,
  "latest_generator_ref": null,
  "latest_evaluator_ref": null,
  "latest_evidence_ref": null,
  "latest_preflight_result": null,

  // === 偏差与风险 ===
  "unverified_areas": [],
  "accepted_deviations": [],

  // === Artifact 索引 ===
  "artifact_refs": {},

  // === Contract Negotiation (统一 schema，来自 pge-contract-negotiation-design.md) ===
  "negotiation_round": 1,
  "max_negotiation_rounds": 3,
  "total_preflight_cycles": 0,
  "max_total_preflight_cycles": 6,
  "contract_locked": false,
  "contract_locked_at_preflight": null,

  // === 错误 ===
  "error_or_blocker": null
}
```

### 2.2 字段语义

| 字段 | 类型 | 语义 |
|------|------|------|
| `run_id` | string | 全局唯一 run 标识，格式 `run-<UTC timestamp>` |
| `slice_id` | string | `run_id` + `-s` + slice 序号 |
| `round_id` | string | `slice_id` + `-r` + round 序号 |
| `upstream_plan_ref` | string\|null | 上游计划文件路径 |
| `run_stop_condition` | enum | `single_round` \| `slice_complete` \| `goal_satisfied` \| `deliverable_count:N` |
| `slice_sequence` | int | 当前 slice 在 run 内的序号（1-based） |
| `max_slices` | int | run 内最大 slice 数 |
| `slice_goal` | string | 当前 slice 的目标描述 |
| `slice_status` | enum | `active` \| `completed` \| `failed` \| `skipped` |
| `round_sequence` | int | 当前 round 在 slice 内的序号（1-based） |
| `max_rounds_per_slice` | int | slice 内最大 round 数 |
| `preflight_attempt` | int | 当前 preflight 尝试次数（1-based） |
| `max_preflight_attempts` | int | 单 round 内最大 preflight 尝试数 |
| `state` | enum | 见 §8 状态机 |
| `active_phase` | enum\|null | `planning_round` \| `preflight` \| `generating` \| `evaluating` \| `routing` \| null |
| `team_name` | string | Agent Team 名称 |
| `team_status` | enum | `not_created` \| `active` \| `shutdown` \| `lost` |
| `verdict` | enum\|null | `PASS` \| `RETRY` \| `BLOCK` \| `ESCALATE` \| null |
| `route` | enum\|null | `continue` \| `converged` \| `retry` \| `return_to_planner` \| null |
| `route_reason` | string\|null | 路由决策的具体原因 |
| `convergence_reason` | string\|null | 收敛时的具体原因 |
| `active_round_contract_ref` | string\|null | 当前 round contract artifact 路径 |
| `latest_generator_ref` | string\|null | 最新 generator artifact 路径 |
| `latest_evaluator_ref` | string\|null | 最新 evaluator artifact 路径 |
| `latest_evidence_ref` | string\|null | 最新 evidence bundle 路径（generator artifact 内的 fragment） |
| `latest_preflight_result` | enum\|null | `pass` \| `fail` \| null |
| `unverified_areas` | string[] | 未验证区域列表 |
| `accepted_deviations` | string[] | 已接受的偏差列表 |
| `artifact_refs` | object | artifact 名称到路径的映射 |
| `error_or_blocker` | string\|null | 当前错误或阻塞描述 |

### 2.3 与当前 repo 的变更

| 当前字段 | 变更 | 原因 |
|----------|------|------|
| `run_id` | 保持 | 无变化 |
| `state` | 扩展枚举值 | 新增 `routing`, `slice_complete` 等 |
| — | 新增 `slice_id`, `round_id` | 支持多层标识 |
| — | 新增 `slice_*` 字段组 | 支持 slice 追踪 |
| — | 新增 `round_sequence` | 替代 `attempt_id` |
| `preflight_attempt_id` | 重命名为 `preflight_attempt` | 一致性 |
| — | 新增 `route_reason`, `convergence_reason` | 从 runtime-state-contract.md 提升 |
| — | 新增 `team_status` | 支持 team 生命周期追踪 |

---

## 3. Progress 结构

### 3.1 Schema

progress artifact 是 Markdown 文件，由 `main` 维护（不是 agent 输出）。

```markdown
# PGE Run Progress

## Identity
- run_id: run-20260429T120000Z
- upstream_plan_ref: .pge-artifacts/test-upstream-plan.md
- run_stop_condition: single_round
- started_at: 2026-04-29T12:00:00Z

## Current Position
- slice: 1 / 5 (max)
- round: 1 / 3 (max)
- state: generating
- active_phase: generating

## Slice History

| slice | goal | rounds | status | verdict |
|--------|------|--------|--------|---------|
| s1 | implement smoke test | 1 (active) | active | — |

## Round History (current slice)

| round | planner | preflight | generator | evaluator | verdict | route |
|-------|---------|-----------|-----------|-----------|---------|-------|
| r1 | done | pass | active | — | — | — |

## Phase Status (current round)

| phase | status | artifact | gate |
|-------|--------|----------|------|
| initialize | done | run-...-input.md | pass |
| team_create | done | — | pass |
| planner | done | run-...-planner.md | pass |
| preflight | done (attempt 1/2) | run-...-preflight.md | pass |
| generator | active | — | — |
| evaluator | pending | — | — |
| route | pending | — | — |
| summary | pending | — | — |
| teardown | pending | — | — |

## Open Issues
- (none)

## Latest Evaluator Gate
- verdict: —
- route: —
- evidence_sufficient: —

## Generator Edit Permission
- allowed: true (preflight passed)
```

### 3.2 更新时机

progress artifact 在每次阶段转换时更新：

| 事件 | 更新内容 |
|------|----------|
| run 初始化 | 创建 progress，写 identity + initial state |
| team 创建 | 更新 team status |
| planner 完成 | 更新 planner phase status + slice history |
| preflight 完成 | 更新 preflight status + attempt counter |
| generator 完成 | 更新 generator phase status |
| evaluator 完成 | 更新 evaluator phase status + verdict + route |
| route 决策 | 更新 route + round history |
| slice 切换 | 新增 slice history 行，重置 round history |
| summary 写入 | 更新 summary phase status |
| teardown | 更新 teardown status + final state |

---

## 4. Evidence 结构

### 4.1 Schema

evidence 是 Generator artifact 内的结构化 section，不是独立文件。

```markdown
## evidence

### evidence_items

- id: e1
  claim: "smoke file exists at .pge-artifacts/pge-smoke.txt"
  type: file_existence
  method: "Read .pge-artifacts/pge-smoke.txt"
  observed: "file exists, content = 'pge smoke'"
  acceptance_criterion_ref: "ac-1"
  confidence: high

- id: e2
  claim: "file content matches expected value"
  type: content_match
  method: "Read file and compare to expected 'pge smoke'"
  observed: "exact match"
  acceptance_criterion_ref: "ac-2"
  confidence: high

### evidence_summary
- total_items: 2
- high_confidence: 2
- medium_confidence: 0
- low_confidence: 0
- acceptance_criteria_covered: [ac-1, ac-2]
- acceptance_criteria_uncovered: []
```

### 4.2 字段定义

| 字段 | 类型 | 语义 |
|------|------|------|
| `id` | string | evidence item 唯一标识 |
| `claim` | string | 该 evidence 声称证明了什么 |
| `type` | enum | `file_existence` \| `content_match` \| `test_pass` \| `behavior_observed` \| `invariant_held` \| `manual_verification` |
| `method` | string | 获取该 evidence 的具体方法 |
| `observed` | string | 实际观察到的结果 |
| `acceptance_criterion_ref` | string | 对应的 acceptance criterion ID |
| `confidence` | enum | `high` \| `medium` \| `low` |

### 4.3 Evidence 充分性规则

Evaluator 判断 evidence 充分性时：
- 每个 `acceptance_criteria` 必须至少有一个 `high` confidence evidence item 覆盖
- `medium` confidence 的 evidence 需要额外的独立验证
- `low` confidence 的 evidence 不能单独支撑 PASS
- Evaluator 必须独立验证 evidence（不信任 Generator 叙述）

### 4.4 与当前 repo 的对齐

当前 `pge-generator.md` 已定义 `evidence` 输出字段，但没有结构化 schema。本设计将其具体化为上述结构。当前 `evaluation-contract.md` 要求 "evidence sufficiency" 检查，本设计提供了具体的充分性规则。

---

## 5. Verdict 结构

### 5.1 Schema

verdict 是 Evaluator artifact 内的结构化 section。

```markdown
## verdict_record

- verdict: PASS
- round_id: run-20260429T120000Z-s1-r1
- timestamp: 2026-04-29T12:05:00Z

### contract_compliance
- status: satisfied
- checked_criteria:
  - ac-1: satisfied (evidence: e1)
  - ac-2: satisfied (evidence: e2)
- unchecked_criteria: []

### evidence_assessment
- sufficient: true
- independent_verification: true
- items_verified: [e1, e2]
- items_disputed: []

### deviation_assessment
- material_deviations: []
- accepted_deviations: []
- unresolved_deviations: []

### invariant_check
- violated: []
- at_risk: []

### verdict_rationale
The deliverable satisfies all acceptance criteria with high-confidence
independently verified evidence. No deviations or invariant violations.

### required_fixes
(none)

### next_route
- route: converged
- reason: "single_round stop condition satisfied, all criteria met"
```

### 5.2 Verdict 枚举（与当前 evaluation-contract.md 对齐）

| Verdict | 语义 | 本地/升级 | 典型 route |
|---------|------|-----------|------------|
| `PASS` | deliverable 满足 round contract，evidence 充分 | 本地 | `continue` 或 `converged` |
| `RETRY` | 方向有效，结果不可接受，可本地修复 | 本地 | `retry` |
| `BLOCK` | 必需条件缺失或违反 | 本地（可能升级） | `retry`（默认）或 `return_to_planner` |
| `ESCALATE` | 当前 contract 不再是公平的评估框架 | 升级 | `return_to_planner` |

### 5.3 Verdict 选择规则（保持当前 evaluation-contract.md 不变）

> Choose the narrowest verdict that explains the failure correctly.

---

## 6. Route 结构

### 6.1 Schema

route 是 `main` 在 Evaluator verdict 后计算的路由决策。

```jsonc
{
  "route_decision": {
    "round_id": "run-20260429T120000Z-s1-r1",
    "verdict": "PASS",
    "route": "converged",
    "reason": "single_round stop condition satisfied",
    "effect": "teardown",

    // === 路由参数（按 route 类型填充） ===
    "retry_params": null,
    "continue_params": null,
    "return_to_planner_params": null,
    "converged_params": {
      "convergence_reason": "all acceptance criteria met, single_round complete"
    }
  }
}
```

### 6.2 Route 枚举与效果

| Route | 触发条件 | 效果 | 状态转换 |
|-------|----------|------|----------|
| `converged` | PASS + `run_stop_condition` 满足 | teardown | `routing → converged` |
| `continue` | PASS + `run_stop_condition` 未满足 | 新 slice（Planner 重新规划） | `routing → planning_round` (slice_sequence++) |
| `retry` | RETRY 或 BLOCK（本地可修复） | 同 slice 新 round（Generator 重试） | `routing → generating` (round_sequence++) |
| `return_to_planner` | BLOCK（需重规划）或 ESCALATE | 同 slice 新 round（Planner 重新规划） | `routing → planning_round` (round_sequence++) |

### 6.3 Route 参数结构

```jsonc
// retry_params
{
  "required_fixes": ["fix file content to match expected value"],
  "max_remaining_attempts": 2,
  "carry_forward": ["evidence e1 still valid"]
}

// continue_params
{
  "next_slice_goal": "implement next feature",
  "carry_forward_evidence": ["e1", "e2"],
  "completed_slice_summary": "smoke test slice completed successfully"
}

// return_to_planner_params
{
  "escalation_reason": "contract mismatch: deliverable type changed",
  "suggested_replan_scope": "narrow deliverable to single file",
  "preserve_from_current": ["evidence e1"]
}

// converged_params
{
  "convergence_reason": "all acceptance criteria met, single_round complete"
}
```

### 6.4 与当前 routing-contract.md 的对齐

当前 `routing-contract.md` 定义的 verdict→route 映射完全保留。新增的是：
- route 参数结构（当前只有 route 枚举，没有参数）
- `continue` 的 slice 切换语义（当前 `continue` 停在 `unsupported_route`）
- `retry` 的 carry-forward 语义（当前 `retry` 停在 `unsupported_route`）

---

## 7. Checkpoint / Handoff / Resume 机制

### 7.1 Checkpoint 类型

| Checkpoint 类型 | 触发时机 | 内容 | 文件 |
|----------------|----------|------|------|
| **round_checkpoint** | 每个 round 结束（无论 verdict） | 完整 round 状态 + verdict + route | `<run_id>-checkpoint-s<N>-r<N>.json` |
| **slice_checkpoint** | slice 结束（完成或放弃） | slice 汇总 + 所有 round 结果 | `<run_id>-checkpoint-s<N>.json` |
| **pause_checkpoint** | 用户暂停或 context 告急 | 当前精确位置 + 恢复指令 | `<run_id>-pause.json` + `<run_id>-continue-here.md` |

### 7.2 round_checkpoint 格式

```jsonc
{
  "checkpoint_type": "round",
  "run_id": "run-20260429T120000Z",
  "slice_id": "run-20260429T120000Z-s1",
  "round_id": "run-20260429T120000Z-s1-r1",
  "timestamp": "2026-04-29T12:05:00Z",

  "state_snapshot": {
    "state": "routing",
    "verdict": "PASS",
    "route": "converged",
    "route_reason": "single_round stop condition satisfied"
  },

  "artifact_refs": {
    "planner": ".pge-artifacts/run-20260429T120000Z-planner.md",
    "preflight": ".pge-artifacts/run-20260429T120000Z-preflight.md",
    "generator": ".pge-artifacts/run-20260429T120000Z-generator.md",
    "evaluator": ".pge-artifacts/run-20260429T120000Z-evaluator.md"
  },

  "carry_forward": {
    "valid_evidence": ["e1", "e2"],
    "accepted_deviations": [],
    "blocking_constraints": []
  },

  "next_action": {
    "type": "teardown",
    "description": "write summary and delete team"
  }
}
```

### 7.3 pause_checkpoint 格式（双格式：JSON + Markdown）

**JSON 格式**（机器可读）：`<run_id>-pause.json`

```jsonc
{
  "checkpoint_type": "pause",
  "run_id": "run-20260429T120000Z",
  "slice_id": "run-20260429T120000Z-s1",
  "round_id": "run-20260429T120000Z-s1-r1",
  "timestamp": "2026-04-29T12:03:00Z",
  "pause_reason": "context_budget_warning",

  "precise_position": {
    "slice_sequence": 1,
    "round_sequence": 1,
    "active_phase": "generating",
    "phase_progress": "generator dispatched, artifact not yet received"
  },

  "completed_phases": ["initialize", "team_create", "planner", "preflight"],
  "pending_phases": ["generator", "evaluator", "route", "summary", "teardown"],

  "team_state": {
    "team_name": "pge-runtime-run-20260429T120000Z",
    "team_status": "active",
    "can_resume_team": true
  },

  "artifact_refs": {
    "input": ".pge-artifacts/run-20260429T120000Z-input.md",
    "planner": ".pge-artifacts/run-20260429T120000Z-planner.md",
    "preflight": ".pge-artifacts/run-20260429T120000Z-preflight.md",
    "state": ".pge-artifacts/run-20260429T120000Z-state.json",
    "progress": ".pge-artifacts/run-20260429T120000Z-progress.md"
  },

  "blocking_constraints": [],
  "decisions_made": [
    "planner chose single-file deliverable",
    "preflight approved round contract on attempt 1"
  ],

  "resume_action": "redispatch generator with same round contract"
}
```

**Markdown 格式**（人类可读）：`<run_id>-continue-here.md`

```markdown
# Continue Here — run-20260429T120000Z

## Position
- Slice 1, Round 1
- Phase: generating (in progress)
- Generator dispatched, artifact not yet received

## What's Done
1. Planner produced round contract (smoke test)
2. Preflight approved on attempt 1
3. Generator dispatched with approved contract

## What's Left
1. Wait for generator artifact
2. Evaluator independent verification
3. Route → summary → teardown

## Decisions Made
- Planner chose single-file deliverable
- Preflight approved round contract on attempt 1

## Blocking Constraints
(none discovered)

## Required Reading (in order)
1. .pge-artifacts/run-20260429T120000Z-state.json
2. .pge-artifacts/run-20260429T120000Z-progress.md
3. .pge-artifacts/run-20260429T120000Z-planner.md
4. .pge-artifacts/run-20260429T120000Z-preflight.md

## Resume Action
Redispatch generator with the same round contract.
Do not re-run planner or preflight.
```

### 7.4 Handoff 机制

> Handoff 使用混合通信：file artifacts 承载 durable state，SendMessage 承载 live interaction（handoff brief、retry brief、rebriefing）。详见 `pge-agent-teams-communication-design.md`。

Handoff 发生在两个边界：

**Phase 间 handoff**（round 内）：
- Planner → Generator：`main` 通过 SendMessage 发送 handoff brief（含 `planner_artifact` 路径引用），Generator 读取 artifact 文件获取 round contract
- Generator → Evaluator：`main` 通过 SendMessage 发送 evaluation brief（含 `generator_artifact` 路径引用），Evaluator 读取 artifact 文件获取 deliverable + evidence
- Evaluator → Router：Evaluator 通过 SendMessage 发送 verdict summary 给 `main`（快速路由决策），完整 verdict 写入 `evaluator_artifact`（审计/持久化）

**Round 间 handoff**（slice 内）：
- 通过 `round_checkpoint` 传递 `carry_forward` 信息（durable state）
- retry 时：`main` 通过 SendMessage 发送 `retry_brief`（含 evaluator feedback 摘要 + 原 contract 路径引用），Generator 读取原 contract 文件获取完整内容
- return_to_planner 时：`main` 通过 SendMessage 发送 rebriefing（含 `escalation_reason` + `preserve_from_current`），Planner 读取相关 artifact 文件

**Slice 间 handoff**：
- 通过 `slice_checkpoint` 传递 slice 汇总（durable state）
- 新 slice 开始时，`main` 通过 SendMessage 发送 rebriefing 给 Planner（含 carry_forward 摘要 + 上游计划路径引用），Planner 读取 artifact 文件获取完整内容

### 7.5 Resume 流程

```text
Resume entry
  │
  ├─ 读取 state_artifact
  │    └─ 确认 run_id, state, artifact_refs
  │
  ├─ 读取 progress_artifact
  │    └─ 确认当前位置 (slice/round/phase)
  │
  ├─ 检查 pause_checkpoint（如果存在）
  │    └─ 读取 precise_position + resume_action
  │
  ├─ 验证 artifact_refs 指向的文件都存在
  │    └─ 如果缺失：标记需要重新执行的阶段
  │
  ├─ 检查 team 状态
  │    ├─ team 仍存在 → 继续使用
  │    └─ team 丢失 → 从 artifacts 重建 team
  │
  ├─ 重新执行最后完成阶段的 gate
  │    └─ gate 通过 → 从下一阶段继续
  │    └─ gate 失败 → 从该阶段重新执行
  │
  └─ 继续执行
```

### 7.6 Team 重建规则

当 team 丢失时（session 中断、context reset）：

1. 创建新 team，使用相同角色名（planner, generator, evaluator）
2. 不依赖旧 team 的 chat history
3. 通过 SendMessage rebriefing 传递 checkpoint 摘要 context，agent 根据 rebriefing 中的路径引用读取 artifact 文件获取完整 durable state
4. 新 agent 启动时的 mandatory read list（通过 rebriefing 消息指定）：
   - `state_artifact`（当前状态）
   - `progress_artifact`（进度）
   - 当前 round 的 `planner_artifact`（round contract）
   - 如果是 generator resume：上一次的 `generator_artifact`（如果存在）
   - 如果是 evaluator resume：`generator_artifact`（deliverable + evidence）

---

## 8. 状态流转（状态机定义）

### 8.1 完整状态枚举

> **状态名对齐**: 本设计使用 `planning_round` 而非 `planning`，与 `runtime-state-contract.md` 的规范性状态名一致。当前 `ORCHESTRATION.md` 使用 `planning`，实施时需更新。

```
initialized
team_created
planning_round
preflight_pending
preflight_failed
ready_to_generate
generating
awaiting_evaluation
evaluating
routing
slice_complete
converged
unsupported_route
stopped
failed
```

### 8.2 状态转换表

```text
initialized ──────────────────────► team_created
team_created ─────────────────────► planning_round
planning_round ───────────────────► preflight_pending
planning_round ───────────────────► failed                [planner 无法产出 contract]
preflight_pending ────────────────► ready_to_generate     [preflight PASS]
preflight_pending ────────────────► preflight_failed      [preflight FAIL, attempt < max]
preflight_pending ────────────────► failed                [preflight FAIL, attempt = max]
preflight_failed ─────────────────► planning_round        [return to planner for replan]
preflight_failed ─────────────────► preflight_pending     [generator repairs proposal, retry preflight]
ready_to_generate ────────────────► generating
generating ───────────────────────► awaiting_evaluation   [generator artifact produced]
generating ───────────────────────► failed                [generator 无法产出 artifact]
awaiting_evaluation ──────────────► evaluating
evaluating ───────────────────────► routing               [evaluator verdict produced]
evaluating ───────────────────────► failed                [evaluator 无法产出 verdict]
routing + converged ──────────────► converged             [PASS + stop_condition met]
routing + continue ───────────────► planning_round        [PASS + stop_condition not met → new slice]
routing + retry ──────────────────► generating            [RETRY/BLOCK local → same slice, new round]
routing + return_to_planner ──────► planning_round        [ESCALATE/BLOCK needs replan → same slice, new round]
routing ──────────────────────────► unsupported_route     [route 未实现时的 fallback]
slice_complete ──────────────────► planning_round        [continue to next slice]
slice_complete ──────────────────► converged             [all slices done]

# 任何状态均可转换到:
* ────────────────────────────────► stopped               [用户暂停 / context 告急 / timeout]
* ────────────────────────────────► failed                [不可恢复错误]
```

### 8.3 状态转换规则

1. **每次转换必须有显式 reason**（写入 `route_reason` 或 `error_or_blocker`）
2. **不允许跳过状态**（必须经过中间状态）
3. **terminal 状态不可逆**：`converged`, `failed` 是 terminal
4. **`stopped` 可恢复**：通过 resume 流程重新进入
5. **`unsupported_route` 可恢复**：当对应的 route loop 实现后

### 8.4 与当前 repo 的对齐

| 当前可执行状态 (ORCHESTRATION.md) | 本设计状态 | 变更 |
|----------------------------------|-----------|------|
| `initialized` | `initialized` | 保持 |
| `team_created` | `team_created` | 保持 |
| `planning` | `planning_round` | 重命名（对齐 runtime-state-contract.md 规范名） |
| `preflight_pending` | `preflight_pending` | 保持 |
| — | `preflight_failed` | 新增：将 runtime-state-contract.md 的规范性定义转为可执行实现 |
| `ready_to_generate` | `ready_to_generate` | 保持 |
| `generating` | `generating` | 保持 |
| — | `awaiting_evaluation` | 新增：将 runtime-state-contract.md 的规范性定义转为可执行实现 |
| `evaluating` | `evaluating` | 保持 |
| — | `routing` | 新增：将 runtime-state-contract.md 的规范性定义转为可执行实现 |
| — | `slice_complete` | 新增（本设计引入） |
| `converged` | `converged` | 保持 |
| `unsupported_route` | `unsupported_route` | 保持 |
| `stopped` | `stopped` | 保持 |
| `failed` | `failed` | 保持 |

> **实现说明**: 标记为"新增"的状态来自 `runtime-state-contract.md` 的规范性语义超集。它们在规范文档中已有定义，但在当前可执行子集（`ORCHESTRATION.md` + `artifacts-and-state.md`）中尚未实现。将这些状态从规范性定义转为可执行实现是本设计的核心工作之一，不应被视为简单的"提升"。

---

## 9. 多 Slice 稳定执行机制

### 9.1 核心问题

多 slice 执行面临三个稳定性挑战：

1. **Context rot** — 随着 slice 增加，context window 填满，agent 质量退化
2. **State drift** — 跨 slice 的状态可能不一致或丢失
3. **Scope creep** — 后续 slice 可能偏离原始目标

### 9.2 Context Rot 防治

**策略：Fresh context per slice**

每个 slice 开始时，`main` 执行 context reset：

```text
Slice N 结束
  │
  ├─ 写 slice_checkpoint
  ├─ 写 progress_artifact（更新 slice history）
  │
  ├─ [Context Reset Point]
  │   ├─ 如果 team context 退化 → 重建 team（新 agent 获得 fresh context）
  │   └─ 如果 team context 健康 → 继续使用
  │
  └─ Slice N+1 开始
      ├─ main 通过 SendMessage rebriefing 传递: carry_forward 摘要 + upstream_plan 路径引用
      ├─ Planner 读取 artifact 文件: upstream_plan + slice_history + carry_forward
      └─ 不读取/不重放：前 slice 的完整 chat history 或 negotiation 消息
```

**Context budget 分级**（借鉴 GSD）：

| 级别 | Context 使用率 | 行为 |
|------|---------------|------|
| NORMAL | 0-40% | 正常执行 |
| WARNING | 40-60% | 完成当前 round，不开始新 round |
| CRITICAL | 60%+ | 立即 checkpoint，暂停 run |

> **实现约束**: Claude Code 当前不暴露 context usage percentage API。实现时需要使用启发式替代方案：(1) 基于 artifact 数量和文件大小的 token 估算，(2) 基于 round 计数的固定上限（如 max_rounds_per_slice），(3) Claude Code 内置的 compaction 信号作为 CRITICAL 触发器。精确的 context budget 检测需要平台支持，在此之前使用 round 计数作为 proxy。

**实现方式**：`main` 在每次 phase 转换时检查 context budget（或其 proxy）。如果进入 WARNING，在当前 round 结束后写 pause_checkpoint。如果进入 CRITICAL，立即写 pause_checkpoint 并停止。

### 9.3 State 一致性保证

**Artifact 文件是 durable state 的唯一真相源**：

- 所有跨 slice 的 durable state 通过 artifact 文件传递
- 跨 slice 的 context transfer 使用 checkpoint 文件（durable）+ agent rebriefing 消息（runtime）
- Chat history 和 negotiation 消息不是 durable state — 它们是瞬态的 runtime communication
- 每个 slice 开始时，agent 从 rebriefing 消息获得 context 摘要，从 artifact 文件获得完整 durable state

**Slice 间状态传递的最小集**：

```jsonc
{
  "carry_forward": {
    // 从已完成 slice 传递到下一 slice
    "completed_slices": [
      {
        "slice_id": "run-...-s1",
        "goal": "implement smoke test",
        "verdict": "PASS",
        "key_evidence": ["e1", "e2"],
        "accepted_deviations": [],
        "blocking_constraints_discovered": []
      }
    ],
    "remaining_goal": "implement feature X",
    "cumulative_unverified_areas": [],
    "cumulative_accepted_deviations": []
  }
}
```

### 9.4 Scope 控制

**Slice goal 必须从 upstream plan 派生**：

- Planner 在每个 slice 开始时，对照 `upstream_plan_ref` 确定 slice goal
- Slice goal 不能超出 upstream plan 的范围
- 如果 Planner 认为 upstream plan 需要修改，必须 ESCALATE，不能静默扩展

**Slice 间的 goal 递进**：

```text
upstream_plan: "implement features A, B, C"

slice 1 goal: "implement feature A"  → PASS → continue
slice 2 goal: "implement feature B"  → PASS → continue
slice 3 goal: "implement feature C"  → PASS → converged (goal_satisfied)
```

### 9.5 Loop Limits（硬上限）

| 限制 | 默认值 | 超限行为 |
|------|--------|----------|
| max_slices | 5 | 写 blocker，停止 |
| max_rounds_per_slice | 3 | 写 blocker，ESCALATE 到下一 slice 或停止 |
| max_preflight_attempts | 2 | 写 blocker，return_to_planner 或停止 |

超限时的处理：
1. 写最新 blocker 到 `error_or_blocker`
2. 保留所有 artifacts
3. 设置 `state = stopped` 或 `failed`
4. 写 summary_artifact 记录为什么停止

### 9.6 Slice 生命周期

```text
Slice Start
  │
  ├─ Planner: 读取 upstream_plan + carry_forward → 冻结 slice goal + round contract
  │
  ├─ Round Loop (1..max_rounds_per_slice):
  │   ├─ Preflight
  │   ├─ Generator
  │   ├─ Evaluator
  │   └─ Route:
  │       ├─ PASS → slice_complete
  │       ├─ RETRY → next round (same slice)
  │       ├─ BLOCK (local) → next round (same slice)
  │       ├─ BLOCK (needs replan) → Planner replan (same slice)
  │       └─ ESCALATE → return_to_planner (same slice, new round contract)
  │
  ├─ Slice Complete:
  │   ├─ 写 slice_checkpoint
  │   ├─ 检查 run_stop_condition
  │   │   ├─ 满足 → converged
  │   │   └─ 未满足 → continue to next slice
  │   └─ Context reset point
  │
  └─ Slice Failed:
      ├─ max_rounds exceeded
      └─ 写 blocker → stopped
```

---

## 10. 从文件恢复上下文

### 10.1 恢复入口

恢复可以从两个入口触发：

1. **显式恢复**：用户调用 `/pge-execute --resume <run_id>`
2. **自动恢复**：`main` 检测到 `state_artifact` 存在且 state 不是 terminal

### 10.2 恢复流程（具体步骤）

```text
Step 1: 定位 state artifact
  ├─ 读取 .pge-artifacts/<run_id>-state.json
  ├─ 如果不存在 → 报错，无法恢复
  └─ 解析 state, slice_id, round_id, artifact_refs

Step 2: 读取 progress artifact
  ├─ 读取 .pge-artifacts/<run_id>-progress.md
  ├─ 确认当前位置 (slice/round/phase)
  └─ 确认已完成和待完成的阶段

Step 3: 读取 pause checkpoint（如果存在）
  ├─ 读取 .pge-artifacts/<run_id>-pause.json
  ├─ 获取 precise_position + resume_action
  └─ 获取 blocking_constraints + decisions_made

Step 4: 验证 artifact 完整性
  ├─ 遍历 artifact_refs
  ├─ 检查每个引用的文件是否存在
  ├─ 如果缺失：标记需要重新执行的阶段
  └─ 如果全部存在：确认可以从下一阶段继续

Step 5: 确定恢复点
  ├─ 找到最后一个 gate 通过的阶段
  ├─ 重新执行该阶段的 gate（验证 artifact 仍然有效）
  │   ├─ gate 通过 → 从下一阶段继续
  │   └─ gate 失败 → 从该阶段重新执行
  └─ 设置 state 为恢复点对应的状态

Step 6: 重建 team（如果需要）
  ├─ 检查 team_status
  │   ├─ active → 继续使用
  │   └─ lost/shutdown → 创建新 team
  ├─ 新 team 使用相同角色名
  └─ 通过 SendMessage rebriefing 传递 checkpoint 摘要 context
      （agent 根据 rebriefing 中的 artifact 路径引用读取 durable state）

Step 7: Rebriefing（SendMessage）
  ├─ 向每个需要的 agent 发送 rebriefing 消息
  │   消息内容: checkpoint 摘要 + 当前 phase 的 context + artifact 路径引用
  ├─ Agent 根据 rebriefing 读取 mandatory read list 中的 artifact 文件
  └─ 不发送历史讨论内容，不重放旧 negotiation 消息

Step 8: 继续执行
  ├─ 从恢复点的下一阶段开始
  ├─ 更新 state_artifact 和 progress_artifact
  └─ 正常执行后续流程
```

### 10.3 恢复点判定表

| state_artifact.state | 恢复动作 |
|---------------------|----------|
| `initialized` | 从 team_created 开始 |
| `team_created` | 从 planning_round 开始 |
| `planning_round` + planner artifact 缺失 | 重新 dispatch planner |
| `planning_round` + planner artifact 存在 + gate pass | 从 preflight 开始 |
| `preflight_pending` + preflight artifact 缺失 | 重新 dispatch preflight |
| `preflight_pending` + preflight pass | 从 generating 开始 |
| `preflight_failed` | 从 planning 开始（replan） |
| `ready_to_generate` | 从 generating 开始 |
| `generating` + generator artifact 缺失 | 重新 dispatch generator |
| `generating` + generator artifact 存在 + gate pass | 从 evaluating 开始 |
| `awaiting_evaluation` | 从 evaluating 开始 |
| `evaluating` + evaluator artifact 缺失 | 重新 dispatch evaluator |
| `evaluating` + evaluator artifact 存在 + gate pass | 从 routing 开始 |
| `routing` | 重新执行 route 决策 |
| `unsupported_route` | 不自动恢复（等待 route loop 实现） |
| `stopped` | 从 pause_checkpoint 恢复 |
| `converged` | 不恢复（已完成） |
| `failed` | 不恢复（需要人工干预） |

### 10.4 Mandatory Read List（按恢复阶段）

| 恢复到阶段 | Agent | Mandatory Read |
|-----------|-------|----------------|
| planning | planner | state, progress, upstream_plan, carry_forward |
| preflight | generator + evaluator | state, progress, planner_artifact |
| generating | generator | state, progress, planner_artifact, preflight_artifact |
| evaluating | evaluator | state, progress, planner_artifact, generator_artifact |
| routing | main | state, progress, evaluator_artifact |

### 10.5 恢复的不变量

1. **永远不从 chat history 推断完成状态** — 只信任 artifact 文件
2. **恢复后的 agent 必须通过 rebriefing 消息获得 context，并读取 mandatory read list** — 不能假设 agent 记得之前的上下文，不重放旧 negotiation 消息
3. **恢复不改变 run_stop_condition** — 除非用户显式修改
4. **恢复不跳过 gate** — 即使 artifact 存在，也要重新验证 gate
5. **恢复不重置 loop counters** — slice_sequence, round_sequence, preflight_attempt 保持连续

---

## 11. Communication Model

> 权威设计: `pge-agent-teams-communication-design.md`

### 11.1 混合通信原则

Multi-round runtime 使用混合通信模型（message + file），而非纯文件通信：

| 通信平面 | 机制 | 用途 | 生命周期 |
|----------|------|------|----------|
| **Runtime Communication Plane** | Agent Teams SendMessage | 实时协作：handoff brief、negotiation、challenge、feedback、retry brief、rebriefing、status、verdict summary | 瞬态（session 内） |
| **Durable Control Plane** | File artifacts | 持久化：locked contract、evidence、verdict、route、checkpoint、handoff | 持久（跨 session） |

### 11.2 Multi-Round 循环中的通信分工

**Retry 循环**（同 slice 内 round→round）：
- `main` 通过 SendMessage 发送 `retry_brief` 给 Generator（含 evaluator feedback 摘要 + 原 contract 路径引用 + retry 约束）
- Generator 读取原 contract 文件获取完整内容（durable state）
- Evaluator feedback 的完整内容在 `evaluator.md` 中（durable），`retry_brief` 只携带摘要

**Continue 循环**（slice→slice）：
- `main` 写 `slice_checkpoint`（durable state）
- `main` 通过 SendMessage 发送 rebriefing 给 Planner（含 carry_forward 摘要 + upstream_plan 路径引用）
- Planner 读取 artifact 文件获取完整 durable state

**Resume**（session 中断后恢复）：
- 从 `checkpoint.json` + `state.json` 重建最小必要 context（durable state）
- 通过 SendMessage rebriefing 重新 brief agents（runtime communication）
- 不重放旧 negotiation 消息，不从 chat history 恢复

### 11.3 关键规则

1. **Round-to-round context transfer = checkpoint 文件（durable）+ rebriefing 消息（runtime）**，不是重放旧 artifact 文件
2. **Negotiation 在 SendMessage 中完成**，只有最终锁定结果写入文件
3. **文件不是消息总线** — 不为瞬态通信写文件（见 `pge-agent-teams-communication-design.md` §3.1）
4. **Agent 是有 direct communication 能力的 team 角色**，不是只读写文件的独立 LLM 调用

---

## 附录 A: Artifact 路径规范

### 单 round（当前兼容）

```text
.pge-artifacts/<run_id>-input.md
.pge-artifacts/<run_id>-planner.md
.pge-artifacts/<run_id>-contract-proposal.md
.pge-artifacts/<run_id>-preflight.md
.pge-artifacts/<run_id>-generator.md
.pge-artifacts/<run_id>-evaluator.md
.pge-artifacts/<run_id>-state.json
.pge-artifacts/<run_id>-summary.md
.pge-artifacts/<run_id>-progress.md
```

### 多 round / 多 slice

```text
.pge-artifacts/<run_id>-input.md
.pge-artifacts/<run_id>-state.json
.pge-artifacts/<run_id>-progress.md
.pge-artifacts/<run_id>-summary.md

# Per slice
.pge-artifacts/<run_id>-s<N>-planner.md
.pge-artifacts/<run_id>-s<N>-r<M>-contract-proposal.md
.pge-artifacts/<run_id>-s<N>-r<M>-preflight.md
.pge-artifacts/<run_id>-s<N>-r<M>-generator.md
.pge-artifacts/<run_id>-s<N>-r<M>-evaluator.md

# Checkpoints
.pge-artifacts/<run_id>-checkpoint-s<N>-r<M>.json
.pge-artifacts/<run_id>-checkpoint-s<N>.json
.pge-artifacts/<run_id>-pause.json
.pge-artifacts/<run_id>-continue-here.md
```

### 向后兼容

单 round 执行（`run_stop_condition = single_round`）时，artifact 路径保持当前格式不变。只有当 `run_stop_condition` 不是 `single_round` 时，才使用多 round/slice 路径格式。

---

## 附录 B: 设计决策记录

| 决策 | 选择 | 原因 |
|------|------|------|
| slice vs 直接多 round | 引入 slice 层 | `runtime-state-contract.md` 已定义 `active_slice_ref`，slice 是 PGE bounded proving 的固有概念（与 Anthropic 已移除的 sprint 构造不同）。GSD 的 phase 也是类似概念。slice 提供了 Planner 重新规划的自然边界。 |
| evidence 在 generator artifact 内 vs 独立文件 | 在 generator artifact 内 | 当前 `runtime-state-contract.md` 已定义 `latest_evidence_ref` 为 generator artifact 内的 fragment reference。保持一致。 |
| checkpoint 双格式 (JSON + MD) | 采用 | GSD 的 HANDOFF.json + .continue-here.md 模式经过实战验证。机器可读 + 人类可读互补。 |
| context reset per slice | 采用 | GSD 和 Anthropic 都证明 fresh context per agent/slice 是最有效的 context rot 防治。 |
| 状态机扩展来源 | 将规范性定义转为可执行实现 | 新增状态来自 `runtime-state-contract.md` 的规范性超集。这些状态在规范文档中已有定义，但在当前可执行子集中尚未实现。 |
| 状态名统一 | 使用 `planning_round` | 对齐 `runtime-state-contract.md` 的规范名。当前 `ORCHESTRATION.md` 使用 `planning`，实施时需更新。 |
| loop limits 硬上限 | 采用 | Anthropic 的 hard threshold 经验 + persistent-runner.md 已定义的 max_rounds/max_attempts。 |
| 混合通信模型 | 采用 message + file | 文件只承载 durable state，SendMessage 承载 live interaction。消除了 file-as-message-bus 反模式。详见 `pge-agent-teams-communication-design.md`。 |
| round-to-round context transfer | checkpoint 文件 + rebriefing 消息 | 不重放旧 artifact 文件。Checkpoint 提供 durable 恢复点，rebriefing 提供 runtime context brief。 |

---

## 附录 C: 与当前 repo 的完整对齐表

| 当前 repo 文件 | 本设计涉及的部分 | 对齐状态 |
|---------------|-----------------|----------|
| `ORCHESTRATION.md` | §8 状态机、§1 层次 | 扩展（新增 slice 层、新增状态） |
| `runtime/artifacts-and-state.md` | §2 runtime-state | 扩展（新增字段，保持当前字段兼容） |
| `runtime/persistent-runner.md` | §7 checkpoint、§9 多 slice、§10 恢复 | 具体化（将设计意图转为具体 schema） |
| `contracts/round-contract.md` | §1 round 定义 | 保持不变 |
| `contracts/evaluation-contract.md` | §5 verdict | 保持不变，新增结构化 schema |
| `contracts/routing-contract.md` | §6 route | 保持不变，新增 route 参数结构 |
| `contracts/runtime-state-contract.md` | §2 runtime-state、§8 状态机 | 对齐（将规范性超集的状态提升为可执行） |
| `contracts/entry-contract.md` | §10 恢复入口 | 保持不变 |
| `docs/design/pge-agent-teams-communication-design.md` | §11 通信模型、§7.4 handoff、§7.5 resume、§9.2 context reset | 新增引用（混合通信模型的权威设计） |
```

