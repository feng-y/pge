---
name: pge-research
description: >
  Use before pge-plan when the user's goal, success shape, scope, constraints,
  or repo reality is not clear enough for fair planning. Produces a lightweight
  research.v3 spec-discovery brief that preserves original intent, captures only
  task-relevant context, identifies open questions, and routes to Plan or a
  blocking clarification/evidence state.
version: 0.2.0
argument-hint: "<topic or intent>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---

# PGE Research

Turn unclear or under-evidenced intent into a lightweight spec-discovery brief for `pge-plan`.

Research is responsible for **intent alignment**:

```text
my understanding of the goal = the user's real goal
```

Research produces `schema_version: research.v3`. It clarifies the problem-side contract before planning; it does not design the executable solution.

`pge-spark` may help recover intent before Research runs, but `spark.v1` is not a substitute for `research.v3`. When Research runs, it owns the problem-discovery contract and route semantics.

## Output contract

Write the artifact to:

```text
.pge/tasks-<slug>/research.md
```

The default brief must expose these v3 semantics:

```text
schema_version: research.v3
route: READY_FOR_PLAN | NEEDS_USER | NEEDS_REPO_EVIDENCE | BLOCKED

Spec Discovery:
  user_request
  goal
  success_shape
  scope
  non_goals
  constraints

Context:
  relevant_user_context
  relevant_repo_or_architecture_context
  assumptions

Direction:
  candidate_direction
  rejected_framings
  why_this_is_enough_for_plan

Open Questions:
  blocking_questions
  non_blocking_questions

Route:
  route
  route_reason
```

Optional sections are allowed only when triggered:

```text
Conditional: Implementation Friction
Conditional: Progressive Feasibility
Optional: Four-Way Gap
Optional: Design / Experience Note
Optional: Evidence Notes
Optional: Authority Notes
```

Do not pad the brief to satisfy a template. A short brief is valid when it preserves intent, names scope and non-goals, marks assumptions, exposes plan-changing uncertainty, and gives Plan enough context to proceed without guessing.

## Hard boundary

Research may recommend a **candidate direction** for planning, but Plan selects the implementation approach and writes executable contracts.

Research must not:

- select the final implementation approach
- create numbered issues or vertical slices
- define final acceptance criteria
- define the final verification path
- write implementation code, pseudocode, function bodies, or field rewiring
- invoke `pge-plan`, `pge-exec`, or implementation agents

`Direction.candidate_direction` is a candidate framing for Plan, not selected architecture.

## Core distinction: A vs B

Always protect the original goal from being replaced by the first plausible solution.

- **A: original goal** — the user's pain, desired outcome, or observable success.
- **B: implementation hypothesis** — a possible path, system area, or proposed solution that might satisfy A.

If B is present in the prompt, record it as a hypothesis unless the user explicitly made B the goal. If conversation has already drifted to B and A is unclear, ask one goal-recovery question before researching solution details.

A good question shape:

```text
I can treat <B> as the goal itself, or as one possible way to achieve <A>.
Which is correct?
```

## Evidence rule

Keep evidence authority explicit:

- User evidence proves user intent.
- Repo evidence proves code reality.
- Architecture docs and structure may support architecture intent.
- Inferences and assumptions must be labeled.

Do not use repo evidence to invent user intent. Do not use user belief to prove code reality when the repo can be checked.

## Triggers

Research has three triggered capabilities. Do not add more default gates.

### 1. Intent Discovery Trigger

Trigger when Plan would need to invent user intent.

Signals:

- the prompt gives a solution without the underlying goal
- multiple plausible goals or scopes remain viable
- success shape is not observable enough for Plan
- scope boundary changes what Plan would include
- a tradeoff needs user authority
- workflow, architecture, design, or product direction is requested but the desired outcome is unclear

Behavior:

1. Read only the context that can resolve the ambiguity cheaply.
2. If repo/docs cannot resolve it, ask one focused question.
3. Prefer a small choice set with a recommended default when evidence supports one.
4. Route `NEEDS_USER` when the answer is required and not available.

Do not bundle questionnaires. One question at a time.

### 2. Implementation Friction Gate

Trigger when expected understanding conflicts with actual implementation reality in a way that changes Plan.

Use when:

```text
expected system model != observed repo reality
```

Do not trigger for cosmetic mismatch or details Plan can handle locally.

When triggered, add:

```md
## Conditional: Implementation Friction

- expected_understanding:
- actual_implementation_reality:
- conflict:
- why_it_matters_for_plan:
- required_plan_adjustment:
```

Route impact:

- `READY_FOR_PLAN` is allowed only when `required_plan_adjustment` gives Plan a safe boundary.
- `NEEDS_REPO_EVIDENCE` when the conflict is suspected but not checked enough to plan.
- `BLOCKED` when the conflict makes the requested goal unsafe or impossible in current constraints.

### 3. Progressive Feasibility Gate

Trigger when the user goal is valid, but the repo cannot safely support direct incremental planning for that goal.

Use when:

```text
valid user goal != current repo's safe incremental execution condition
```

Signals:

- the goal requires cross-stage or multi-module protocol/interface changes
- final success needs end-to-end verification that does not currently exist
- direct implementation would structurally break downstream consumers
- repo boundaries are not ready to support the target change safely
- the target needs large synchronized edits across producers and consumers
- the request mixes multiple change types that should be staged

Do not trigger when a normal vertical slice can be planned and verified.

When triggered, add:

```md
## Conditional: Progressive Feasibility

- direct_goal:
- direct_planning_risk:
- structural_blocker:
- first_plannable_objective:
- deferred_goal_parts:
- plan_instruction:
```

The most important field is `first_plannable_objective`. It tells Plan to plan the first safe structural objective, not the entire final goal. When Progressive Feasibility is triggered, `pge-plan` must plan `first_plannable_objective` as the current target; `direct_goal` is deferred context only, not the current plan target.

### Optional: Four-Way Gap

Use only as a diagnostic lens when Implementation Friction is hard to explain directly.

```md
## Optional: Four-Way Gap

- user_intent:
- ai_understanding:
- code_reality:
- architecture_intent:
- gap_that_matters_for_plan:
```

Do not make this a default section.

### Optional: Authority Notes

Use only when user intent, repo reality, architecture intent, and inference are mixed in a way that would cause Plan to misattribute authority. Do not trigger for straightforward tasks where evidence sources are obvious.

```md
## Optional: Authority Notes

- <claim> — authority: user_confirmed | repo_evidence | architecture_intent | inferred — source: <evidence>
```

Authority Notes help Plan avoid upgrading inferred claims to user-confirmed constraints or treating repo evidence as user intent.

## Process

### 1. Intake the request and current context

Consume the explicit prompt plus relevant current conversation, user corrections, selected artifacts, failures, or prior stage outputs. Identify:

- explicit user request
- likely original goal A
- implementation hypothesis B, if any
- observable success shape
- candidate scope and non-goals
- constraints and hard “do not” instructions

If a structured upstream source is supplied, preserve its goal, scope, decisions, constraints, and non-goals at the same level of abstraction before narrowing.

### 2. Check whether intent discovery is needed

Ask:

```text
Can Plan fairly create executable issues without inventing user intent?
```

If no, use the Intent Discovery Trigger. Ask only when user authority is needed; otherwise record the resolved assumption and basis.

### 3. Collect only task-relevant context

Explore just enough repo, docs, config, prior artifacts, or architecture structure to determine whether the goal and scope are plan-ready.

Prefer direct reading for narrow work. Use an Agent only when exploration is broad, cross-cutting, or likely to produce dead-end noise whose raw output Plan will not need.

Stop exploring when another file would not change goal, scope, constraints, route, or Plan's first move.

### 4. Check for implementation friction

Compare expected understanding against observed implementation reality. Trigger the gate only when the mismatch changes Plan.

Examples:

- user or upstream source says a field is unused, but Plan still consumes it
- a proposed deletion has downstream consumers
- route vocabulary differs from what downstream skills validate

### 5. Check progressive feasibility

Ask whether the direct goal can be planned as a safe, bounded, incrementally verifiable change. If not, trigger the gate and name the first plannable objective.

Research does not write the staged plan. It only tells Plan which first objective is safe and which parts are deferred.

### 6. Synthesize the brief

Use `templates/brief.md`. Keep findings, assumptions, and open questions separate.

For `READY_FOR_PLAN`, the brief must make these true:

- goal and success shape are clear enough for Plan
- scope and non-goals are explicit enough to prevent silent expansion
- constraints are visible
- assumptions are labeled
- blocking questions are empty
- any conditional gate includes the field Plan must consume
- route reason explains why Plan can proceed

### 7. Self-review before routing

Before writing or finalizing the artifact, check:

- Does the brief preserve original goal A separately from B?
- Would the user recognize the goal and success shape?
- Are repo facts supported by repo evidence or clearly marked as assumptions?
- Are user-intent claims supported by user/upstream evidence?
- Did Research accidentally select the final approach, issue slices, acceptance, or verification?
- If Implementation Friction exists, is `required_plan_adjustment` present?
- If Progressive Feasibility exists, is `first_plannable_objective` present?
- Is the route vocabulary one of the v3 routes?

Repair the brief before routing `READY_FOR_PLAN`.

## Route semantics

- `READY_FOR_PLAN` — Plan can proceed without inventing goal, scope, or success shape.
- `NEEDS_USER` — a user-authority answer is required before fair planning.
- `NEEDS_REPO_EVIDENCE` — repo reality is too uncertain and more evidence is required before planning.
- `BLOCKED` — current constraints make the requested goal unsafe, impossible, or outside this workflow.

Do not use `NEEDS_INFO` as a Research v3 route.

## References

- Read `references/superpowers-brainstorming.md` when the prompt is fuzzy, broad, value-laden, or dominated by implementation hypothesis B.
- Read `references/design-surface-research.md` only when the task has a human-visible surface and experience context would change planning.

Reference files calibrate behavior. They do not add default required v3 fields unless this skill explicitly says so.

## Final Response

After writing the artifact, output exactly one concise result block:

```md
## PGE Research Result
- task_dir: .pge/tasks-<slug>/
- research_path: .pge/tasks-<slug>/research.md
- schema_version: research.v3
- route: READY_FOR_PLAN | NEEDS_USER | NEEDS_REPO_EVIDENCE | BLOCKED
- questions_asked: <0-3>
- next_action: <READY_FOR_PLAN: pge-plan <task-slug> | NEEDS_USER: answer blocking question then rerun pge-research | NEEDS_REPO_EVIDENCE: gather repo evidence then rerun pge-research | BLOCKED: resolve blocker before continuing>
```
