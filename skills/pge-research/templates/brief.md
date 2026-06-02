# Research: <title>

schema_version: research.v3
route: READY_FOR_PLAN | NEEDS_USER | NEEDS_REPO_EVIDENCE | BLOCKED

This is a minimum contract scaffold, not a fixed prose template. Scale depth to task complexity. Add optional sections only when they reduce uncertainty or preserve material decisions for planning.

## 1. Spec Discovery

- user_request:
- goal:
- success_shape:
- scope:
- non_goals:
- constraints:

## 2. Context

- relevant_user_context:
- relevant_repo_or_architecture_context: **[P1] For reliability/recovery features, surface candidate behavioral invariants (ack ordering, idempotency boundary, redelivery contract, etc.) when relevant — but tag each with authority. A behavior observed in code is `observed_behavior` or `repo_evidence / needs_confirmation`, NOT a confirmed preservation constraint, until the user confirms intent (see Core Friction Confirmation). For recovery/compensation features, state the structural precondition the mechanism depends on (e.g., Redis anchor exists, event normalized) and which failure classes fall outside coverage.**
- assumptions:

## 3. Direction

- candidate_direction:
- rejected_framings:
- why_this_is_enough_for_plan:

## 4. Open Questions

- blocking_questions:
- non_blocking_questions:

## 5. Route

- route: <must match the top-level route exactly>
- route_reason:

## Optional snippets — omit unless triggered

### Conditional: Implementation Friction

Use only when expected understanding conflicts with actual implementation reality in a plan-affecting way.

- expected_understanding:
- actual_implementation_reality:
- conflict:
- why_it_matters_for_plan:
- required_plan_adjustment:

### Conditional: Progressive Feasibility

Use only when the goal is valid but cannot be safely planned as a direct incremental change because the repo is not structurally ready.

- direct_goal:
- direct_planning_risk:
- structural_blocker:
- first_plannable_objective:
- deferred_goal_parts:
- plan_instruction:

### Optional: Four-Way Gap

Use only as a diagnostic lens when Implementation Friction is hard to express directly.

- user_intent:
- ai_understanding:
- code_reality:
- architecture_intent:
- gap_that_matters_for_plan:

### Optional: Design / Experience Note

Use only when a human-visible surface would change planning.

- surface:
- audience:
- experience_success_shape:
- constraints_or_risks_for_plan:

### Optional: Evidence Notes

Use only when citations or checked facts materially affect planning.

- <finding> — basis: user | upstream | repo | architecture | inferred — source: <file:line | command | conversation>

### Optional: Authority Notes

Use only when user intent, repo reality, architecture intent, and inference are mixed in a way that would cause Plan to misattribute authority.

- <claim> — authority: user_confirmed | source_of_truth | repo_evidence | inferred_by_research | observed_behavior | repo_evidence / needs_confirmation | inferred_by_research / needs_confirmation — source: <evidence>

**[P0] Authority classification:**
- `observed_behavior` — current repo behavior that may be incidental rather than intentional design.
- `repo_evidence / needs_confirmation` — repo fact that looks like a contract but user/upstream has not confirmed it as intentional.
- `inferred_by_research / needs_confirmation` — Research inference affecting safety/correctness/scope that requires user authority.

## Metadata

- research_id: <YYYYMMDD-HHMM-slug>
- date: <ISO date>
- task_dir: .pge/tasks-<slug>/
