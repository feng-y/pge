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
- relevant_repo_or_architecture_context:
- assumptions:

## 3. Direction

- simplest_direction:
- rejected_directions:
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

## Metadata

- research_id: <YYYYMMDD-HHMM-slug>
- date: <ISO date>
- task_dir: .pge/tasks-<slug>/
