# PGE Skills Contract-First Implementation Plan

## Purpose

Define the contracts before implementing the PGE skill split.

This document is a plan only. It does not modify `skills/`, agent files, plugin metadata, validators, or runtime contracts. Its job is to define the contract-first target for three skills:

- `pge-setup`
- `pge-plan`
- `pge-execute`

## Global Contract Rules

- `pge-setup` writes setup/config artifacts under `.pge/config/*`.
- `pge-plan` writes plan artifacts under `.pge/plans/<plan_id>.md`.
- `pge-execute` writes run artifacts under `.pge/runs/<run_id>/*`.
- `pge-execute` is a triage/state-machine driven execution controller.
- `pge-execute` is not a TDD skill.
- TDD is only one possible execution mode.
- `pge-execute` must not output `PASS`, `MERGED`, or `SHIPPED` as status, verdict, or route.
- Do not introduce `TeamCreate`.
- Do not restore the Planner / Generator / Evaluator Claude Code Agent Teams orchestrator.
- Do not implement an SDK runner.
- Source `agents/pge-*.md` and installed `.claude/agents/pge-*` may be used only as role spec / prompt material / future SDK runner material, not as active runtime teammates.

## Skill Chain

```text
pge-setup
  -> writes .pge/config/*
  -> pge-plan reads setup config

pge-plan
  -> writes .pge/plans/<plan_id>.md
  -> pge-execute reads plan artifact

pge-execute
  -> writes .pge/runs/<run_id>/*
  -> routes by explicit state-machine result
```

The chain is artifact-first. Each skill may be invoked independently, but each downstream skill must define which upstream artifacts it consumes and what happens when they are missing.

## pge-setup

### 1. Workflow

`pge-setup` prepares the repo-local PGE surface for planning and execution.

Workflow:

1. Locate repo root.
2. Inspect required PGE source files and directories.
3. Inspect plugin metadata when present.
4. Inspect local conventions needed by downstream skills.
5. Write setup/config artifacts under `.pge/config/`.
6. Report setup status as `ready`, `warning`, or `blocked`.

`pge-setup` is allowed to check facts. It is not allowed to execute user tasks or create plans.

### 2. Artifact Contract

`pge-setup` must write:

- `.pge/config/setup.md`
  - Human-readable setup report.
  - Records what was checked, what is ready, warnings, blockers, and next action.
- `.pge/config/capabilities.json`
  - Machine-readable capability/config summary for downstream skills.
  - Records repo root, available skill dirs, available role-spec files, validation commands, artifact roots, and disabled runtime surfaces.
- `.pge/config/guardrails.md`
  - Human-readable guardrails inherited by `pge-plan` and `pge-execute`.
  - Must explicitly state no `TeamCreate`, no Claude Code Agent Teams orchestrator, no SDK runner, and TDD as optional execution mode only.

Optional setup artifacts:

- `.pge/config/install-check.md`
  - Used only when setup performs install-surface inspection.
- `.pge/config/validation.md`
  - Captures static validation command names and results when setup runs checks.

### 3. Handoff Contract

`pge-plan` must read:

- `.pge/config/capabilities.json`
- `.pge/config/guardrails.md`

`pge-plan` may read:

- `.pge/config/setup.md`
- `.pge/config/validation.md`

Consumption rules:

- If `.pge/config/capabilities.json` is missing, `pge-plan` may run with degraded setup only when the user explicitly asks for planning without setup.
- If `.pge/config/guardrails.md` is missing, `pge-plan` must recreate or inline the global guardrails in its own plan artifact.
- `pge-plan` must not treat setup warnings as execution permission. Setup artifacts only describe environment readiness and guardrails.

### 4. State / Route Contract

Allowed setup states:

- `initialized`
- `inspecting`
- `ready`
- `warning`
- `blocked`

Allowed setup routes:

- `ready_for_plan`
- `ready_with_warnings`
- `blocked_needs_setup`

Forbidden setup routes:

- `ready_for_execute`
- `execute`
- `retry_execution`
- `merged`
- `shipped`

### 5. Guardrails

`pge-setup` must not:

- modify `skills/`
- modify user deliverables
- create `.pge/plans/<plan_id>.md`
- create `.pge/runs/<run_id>/*`
- call or document `TeamCreate` as an active runtime step
- spawn Planner / Generator / Evaluator as Claude Code agents
- run an SDK runner
- classify task success
- output `PASS`, `MERGED`, or `SHIPPED`

## pge-plan

### 1. Workflow

`pge-plan` turns user intent into one execution-ready plan artifact.

Workflow:

1. Resolve user input.
2. Read setup guardrails from `.pge/config/*` when available.
3. Inspect only the repo context needed to make a fair plan.
4. Classify ambiguity as requirement gap, design choice, or implementation detail.
5. Select one bounded deliverable slice.
6. Define acceptance criteria, verification path, risks, and blockers.
7. Recommend an execution mode for `pge-execute`.
8. Write `.pge/plans/<plan_id>.md`.
9. Route to `ready_for_execute`, `needs_clarification`, or `blocked`.

`pge-plan` may use role spec material from `agents/pge-*.md` only as non-runtime reference. It must not treat those files as live agent bindings.

### 2. Artifact Contract

`pge-plan` must write:

- `.pge/plans/<plan_id>.md`
  - The authoritative execution plan for one bounded task.
  - The filename must use a stable `plan_id`, such as timestamp plus slug.

Required sections in `.pge/plans/<plan_id>.md`:

- `## plan_id`
- `## source_input`
- `## setup_refs`
- `## goal`
- `## evidence_basis`
- `## in_scope`
- `## out_of_scope`
- `## deliverable`
- `## acceptance_criteria`
- `## verification_path`
- `## execution_mode_recommendation`
- `## state_route_hint`
- `## risks`
- `## blockers`
- `## handoff_to_execute`
- `## guardrails`

Execution mode recommendation values:

- `direct_edit`
- `tdd`
- `investigate_then_edit`
- `docs_only`
- `verification_only`
- `blocked_no_execute`

TDD is allowed only as `execution_mode_recommendation: tdd`. The plan must explain why TDD is appropriate when selected.

### 3. Handoff Contract

`pge-execute` must read:

- `.pge/plans/<plan_id>.md`

`pge-execute` should read when present:

- `.pge/config/capabilities.json`
- `.pge/config/guardrails.md`

`pge-execute` consumes these plan fields:

- `goal` defines the task objective.
- `in_scope` and `out_of_scope` define edit boundaries.
- `deliverable` defines the required output.
- `acceptance_criteria` define evaluation conditions.
- `verification_path` defines required checks.
- `execution_mode_recommendation` is advisory input to triage, not a command.
- `state_route_hint` gives the initial state/route suggestion.
- `blockers` may force `blocked` before editing.
- `guardrails` must be enforced during execution.

Missing plan behavior:

- If no plan artifact is provided, `pge-execute` may enter `triage` and route to `needs_plan`.
- `pge-execute` may execute from raw prompt only for explicitly trivial tasks when the state machine classifies the task as safe direct execution.
- If plan guardrails conflict with setup guardrails, stricter guardrails win.

### 4. State / Route Contract

Allowed plan states:

- `intake`
- `inspecting`
- `planning`
- `ready`
- `needs_clarification`
- `blocked`

Allowed plan routes:

- `ready_for_execute`
- `needs_user_clarification`
- `blocked_no_plan`

Forbidden plan routes:

- `execute`
- `retry`
- `converged`
- `pass`
- `merged`
- `shipped`

### 5. Guardrails

`pge-plan` must not:

- modify implementation files as part of planning
- create `.pge/runs/<run_id>/*`
- call `TeamCreate`
- instruct `pge-execute` to create Planner / Generator / Evaluator Claude Code agents
- define Planner / Generator / Evaluator as an active runtime team
- implement an SDK runner
- require TDD for all tasks
- output `PASS`, `MERGED`, or `SHIPPED`
- hide unresolved requirement gaps as assumptions

## pge-execute

### 1. Workflow

`pge-execute` is the triage/state-machine driven execution controller.

Workflow:

1. Resolve input:
   - preferred: `.pge/plans/<plan_id>.md`
   - allowed fallback: raw prompt for trivial direct execution
2. Initialize `.pge/runs/<run_id>/`.
3. Read setup guardrails when available.
4. Read and validate plan artifact when provided.
5. Enter `triage`.
6. Select execution mode:
   - `direct_edit`
   - `tdd`
   - `investigate_then_edit`
   - `docs_only`
   - `verification_only`
   - `blocked_no_execute`
7. Execute only if state route permits editing.
8. Run verification proportional to risk and plan requirements.
9. Evaluate against acceptance criteria without emitting `PASS`.
10. Route to a terminal or bounded retry state.
11. Write final run summary under `.pge/runs/<run_id>/`.

State-machine sketch:

```text
initialized
  -> triage
  -> needs_plan | blocked | ready_to_execute
  -> executing
  -> verifying
  -> evaluating
  -> completed | needs_retry | blocked | needs_plan
```

TDD behavior:

- TDD may be selected only when the plan or triage identifies a testable behavior change.
- TDD is not the default identity of `pge-execute`.
- Non-code, docs-only, verification-only, and simple direct-edit tasks must not be forced into TDD.

### 2. Artifact Contract

`pge-execute` must write all run artifacts under:

- `.pge/runs/<run_id>/`

Required run artifacts:

- `.pge/runs/<run_id>/input.md`
  - Raw invocation input and resolved plan reference.
- `.pge/runs/<run_id>/state.json`
  - Machine-readable current and final state.
- `.pge/runs/<run_id>/triage.md`
  - Triage decision, execution mode, risk level, and whether a plan is required.
- `.pge/runs/<run_id>/execution.md`
  - What was changed or intentionally not changed.
- `.pge/runs/<run_id>/verification.md`
  - Commands/checks run, results, and unverified areas.
- `.pge/runs/<run_id>/evaluation.md`
  - Acceptance-criteria evaluation using allowed result vocabulary.
- `.pge/runs/<run_id>/summary.md`
  - Human-readable final run summary.

Optional run artifacts:

- `.pge/runs/<run_id>/diff.md`
  - Diff summary when files changed.
- `.pge/runs/<run_id>/retry.md`
  - Bounded retry reason and next action if route is `needs_retry`.
- `.pge/runs/<run_id>/blocker.md`
  - Concrete blocker when route is blocked.

Allowed execution result vocabulary:

- `satisfied`
- `not_satisfied`
- `blocked`
- `needs_plan`
- `needs_retry`
- `not_run`

Forbidden execution result vocabulary:

- `PASS`
- `MERGED`
- `SHIPPED`

### 3. Handoff Contract

`pge-execute` consumes:

- `.pge/plans/<plan_id>.md` from `pge-plan`
- `.pge/config/capabilities.json` from `pge-setup` when present
- `.pge/config/guardrails.md` from `pge-setup` when present

`pge-execute` produces no required downstream handoff in this three-skill chain. Its downstream handoff is the run record:

- `.pge/runs/<run_id>/summary.md`
- `.pge/runs/<run_id>/state.json`
- `.pge/runs/<run_id>/verification.md`
- `.pge/runs/<run_id>/evaluation.md`

A later human or automation may read those artifacts to decide whether to plan another task, retry, or stop. That is outside this plan unless explicitly added in a future slice.

### 4. State / Route Contract

Allowed execution states:

- `initialized`
- `triage`
- `needs_plan`
- `ready_to_execute`
- `executing`
- `verifying`
- `evaluating`
- `completed`
- `needs_retry`
- `blocked`

Allowed execution routes:

- `completed_satisfied`
- `completed_not_satisfied`
- `needs_retry`
- `needs_plan`
- `blocked`

Forbidden execution routes:

- `pass`
- `merged`
- `shipped`
- `converged`
- `team_created`
- `planner_dispatched`
- `generator_dispatched`
- `evaluator_dispatched`

Route rules:

- `completed_satisfied` means acceptance criteria were satisfied by evidence.
- `completed_not_satisfied` means execution finished but acceptance criteria were not satisfied.
- `needs_retry` means the same plan may still be repaired with a bounded retry.
- `needs_plan` means execution should stop until a plan exists or is repaired.
- `blocked` means execution cannot fairly proceed without external action.

### 5. Guardrails

`pge-execute` must not:

- call `TeamCreate`
- call `TeamDelete` for PGE orchestration
- use `SendMessage` as teammate progression
- create Planner / Generator / Evaluator Claude Code agents
- restore a Planner / Generator / Evaluator orchestrator loop
- implement or invoke an SDK runner
- output `PASS`, `MERGED`, or `SHIPPED`
- treat TDD as mandatory
- edit outside plan scope unless triage records a concrete reason and the change is required to satisfy the user request
- claim completion without verification or an explicit unverified/blocked record
- silently continue when the plan has blocking ambiguity

## Cross-Skill Consistency Checks

Future implementation should add validator checks for:

- `skills/pge-setup/SKILL.md` exists.
- `skills/pge-plan/SKILL.md` exists.
- `skills/pge-execute/SKILL.md` uses triage/state-machine language.
- Active skill files do not contain `TeamCreate`.
- Active skill files do not define Planner / Generator / Evaluator as live Claude Code teammates.
- `pge-execute` docs do not use `PASS`, `MERGED`, or `SHIPPED` as output values.
- TDD appears only as one execution mode.
- Artifact roots are exactly:
  - `.pge/config/*`
  - `.pge/plans/<plan_id>.md`
  - `.pge/runs/<run_id>/*`

## Implementation Order

1. Implement `pge-setup` contracts and artifacts first.
2. Implement `pge-plan` contracts and plan artifact second.
3. Refactor `pge-execute` last, because it replaces the current active Agent Teams runtime surface with the triage/state-machine controller.

## Plan Stop Condition

Stop this planning stage after this document exists and only this document has been added for the contract-first plan.
