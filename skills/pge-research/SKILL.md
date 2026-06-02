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

**[P0] Observed behavior vs confirmed contract:** When the task is reliability/recovery/fallback/safety-related, and Research observes or depends on an existing reliability mechanism (ack/redelivery semantics, idempotency boundary, retry contract, recovery driver, state persistence order), classify it as `observed_behavior` rather than `confirmed_contract` unless user/upstream evidence explicitly confirms it as intentional design. Do not let `repo_evidence` auto-upgrade to a preservation constraint in Plan. Tag such claims in Authority Notes as `repo_evidence / needs_confirmation` or `inferred_by_research / needs_confirmation`.

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

- <claim> — authority: user_confirmed | source_of_truth | repo_evidence | inferred_by_research | observed_behavior | repo_evidence / needs_confirmation | inferred_by_research / needs_confirmation — source: <evidence>
```

**[P0] Authority classification:**
- `observed_behavior` — current repo behavior that may be incidental rather than intentional design; must not become a preservation constraint without confirmation.
- `repo_evidence / needs_confirmation` — repo fact that looks like a contract but user/upstream has not confirmed it as intentional.
- `inferred_by_research / needs_confirmation` — Research inference that affects safety/correctness/scope and requires user authority before Plan treats it as constraint.

Authority Notes help Plan avoid upgrading inferred claims to user-confirmed constraints, treating repo evidence as user intent, or treating observed reliability mechanisms as preservation requirements without confirmation.

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

**[latency] Efficiency rule:** Explore just enough repo, docs, config, prior artifacts, or architecture structure to determine whether the goal and scope are plan-ready. Stop exploring when another file would not change goal, scope, constraints, route, or Plan's first move.

**[latency] Direct reading first:** For 1-5 files or narrow cross-file questions, use direct Read/Grep/Bash. Prefer direct tools over Agent delegation when the overhead of spawning, summarizing, and consuming an Agent result exceeds reading the raw evidence yourself.

**[latency] Agent delegation triggers:** Use an Agent only when ALL of these are true:
- exploration is genuinely broad (6+ candidate files, unknown naming conventions, or multi-module sweep)
- AND the raw exploration output would be large enough (200+ lines of grep results, multi-file dumps) that Plan will not need the full detail
- AND you only need the Agent's compact conclusion (yes/no/where/confidence/discarded dead ends), not the verbatim evidence

Agent delegation does not save context when the alternative is 3 Read calls. It saves context when the alternative is 15 Read calls whose raw content you'd have to filter and summarize anyway.

### 4. Check for implementation friction

Compare expected understanding against observed implementation reality. Trigger the gate only when the mismatch changes Plan.

Examples:

- user or upstream source says a field is unused, but Plan still consumes it
- a proposed deletion has downstream consumers
- route vocabulary differs from what downstream skills validate

### 5. Check progressive feasibility

Ask whether the direct goal can be planned as a safe, bounded, incrementally verifiable change. If not, trigger the gate and name the first plannable objective.

Research does not write the staged plan. It only tells Plan which first objective is safe and which parts are deferred.

**[P1] Coverage boundary for recovery/compensation features:** When the task is recovery/compensation/fallback/best-effort output, identify the **structural precondition** the mechanism depends on (e.g., Redis anchor must exist, event must be normalized, identity must be stable). Mark failure classes that fall outside that precondition as out-of-coverage, and name who handles them (ops offset replay, upstream normalization, etc.). This is distinct from non-goals — it documents what the mechanism **physically cannot see** versus what it **chooses not to do**.

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
- **[P0] core friction is confirmed or recorded with explicit needs_confirmation tag** (see Core Friction Confirmation below)

### 7. Core Friction Confirmation

**[P0] Trigger:** Before routing `READY_FOR_PLAN`, classify material frictions/assumptions/mechanisms into **core** vs **self-decidable**.

**Core friction** = affects safety, correctness, or scope boundary. Examples:
- ACK/commit/redelivery semantics for reliability features
- reclaim/lease thresholds for stateful recovery
- trigger predicates for conditional features (what makes input valid/invalid)
- admission predicates for conditional outputs (minimum publishable contract)
- coverage boundary preconditions (what the mechanism physically depends on)
- observed reliability mechanisms that look like contracts

**Self-decidable** = reversible impl/design choices, cosmetic conventions, file/module layout, default config values with no correctness risk.

**Handling:**
- Core friction with reasonable evidence-based default → record in `non_blocking_questions` with confidence level **AND** add an Authority Notes entry tagged `needs_confirmation` for that claim. **[P0] The `needs_confirmation` Authority Notes tag is mandatory for every core friction that is not user-confirmed — parking it in `non_blocking_questions` alone is insufficient, because Plan consumes Authority Notes, not the question prose.** Route `NEEDS_USER` if the friction genuinely blocks a fair contract.
- Core friction with no safe default → ask one focused question (requirement gap).
- Self-decidable → record assumption with basis and continue.

This gate preserves the "do not grill" discipline while catching the narrow slice of frictions that define contracts rather than preferences.

### 8. Self-review before routing

Before writing or finalizing the artifact, check:

- Does the brief preserve original goal A separately from B?
- Would the user recognize the goal and success shape?
- Are repo facts supported by repo evidence or clearly marked as assumptions?
- Are user-intent claims supported by user/upstream evidence?
- Did Research accidentally select the final approach, issue slices, acceptance, or verification?
- If Implementation Friction exists, is `required_plan_adjustment` present?
- If Progressive Feasibility exists, is `first_plannable_objective` present?
- Is the route vocabulary one of the v3 routes?
- **[P0] Are core frictions either confirmed or tagged `needs_confirmation`?**
- **[P0] Are observed reliability behaviors classified as `observed_behavior` or `repo_evidence / needs_confirmation` rather than auto-upgraded to preservation constraints?**
- **[P1] For recovery/compensation features, is the coverage boundary precondition explicit?**

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
