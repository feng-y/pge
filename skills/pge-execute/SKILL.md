---
name: pge-execute
description: Run one bounded PGE execution using a real Claude Code Agent Team (planner, generator, evaluator) with messaging-first coordination and durable phase artifacts.
version: 0.4.0
argument-hint: "test | <task prompt>"
allowed-tools:
  - TeamCreate
  - TeamDelete
  - Agent
  - SendMessage
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# PGE Execute

This skill is the orchestration shell only. It is not a fourth agent.

`main` is the only control-plane owner for the active lane: initialize run, create exactly one team, dispatch planner / generator / evaluator, gate artifacts and runtime events, reduce route deterministically, record authoritative progress / friction, classify failures, and perform teardown. `main` must not replace Planner / Generator / Evaluator specialist judgment.

## Progressive Disclosure
Keep this entrypoint small. Load detail files only when the phase needs them:

- Runtime artifacts/progress: `runtime/artifacts-and-state.md`
- Planner handoff: `handoffs/planner.md`
- Generator handoff: `handoffs/generator.md`
- Evaluator handoff: `handoffs/evaluator.md`
- Route, summary, teardown: `handoffs/route-summary-teardown.md`
- Runtime events: `contracts/runtime-event-contract.md`
- Contracts: `contracts/*.md` relative to this skill (authoritative for this skill)
- Minimal lifecycle reference: `ORCHESTRATION.md`
Design references live outside the skill at `docs/design/pge-execute/`; consult them when changing the skill, not during every normal run. The archived preflight and runtime-state materials remain on disk for future design work, not for the current executable lane.

## Current Executable Claim
Supported in the current implementation lane:
- one Team
- exactly three teammates: planner, generator, evaluator
- one bounded run with `planner -> generator -> evaluator` for normal tasks
- task size changes role depth, not stage count
- durable phase outputs plus one shared progress log
- independent final evaluation
- progress log is weak dependency only

Not supported yet:
- automatic multi-round redispatch
- bounded retry loop
- return-to-planner loop
- checkpoint/resume execution

## Execution Flow
```text
User invokes /pge-execute
  -> pge-execute orchestrator skill
     -> initialize input/progress artifacts
     -> create one per-run resident team
        - teammate `planner` runs agent surface `pge-planner`
        - teammate `generator` runs agent surface `pge-generator`
        - teammate `evaluator` runs agent surface `pge-evaluator`
     -> planner writes locked task-shape contract
     -> generator reviews then executes the task
     -> evaluator independently checks the deliverable
     -> route/summary/teardown phase records outcome and deletes the team
```

The orchestrator advances from runtime events and then validates any referenced durable side effects.

## Hard Requirements
- Use Claude Code native Agent Teams.
- Create exactly one team for the run.
- Spawn exactly three teammates:
  - `planner` using `pge-planner`
  - `generator` using `pge-generator`
  - `evaluator` using `pge-evaluator`
- Dispatch work through `SendMessage`.
- Use files only for durable phase outputs and one shared append-only progress log.
- Maintain `progress_artifact` as best-effort execution logging only; it must not gate execution.
- `main` is the only authoritative writer of progress / friction / repeated-failure logs.
- Do not simulate Planner / Generator / Evaluator in `main`.
- Do not fall back to direct non-team Agent dispatch.
- Only `main` may talk directly to the user; teammates may surface clarification needs, but `main` owns the actual user-facing question.
- Do not require the user to pass a plan path.
- Do not insert a separate preflight or mode-decision phase into the current executable lane.
- Do not give Planner authority to decide final verdict.
- Do not claim redispatch for `continue`, `retry`, or `return_to_planner`.

If TeamCreate / Agent with `team_name` / SendMessage / TeamDelete cannot be used, stop immediately and report one concrete blocker.

## Accepted Inputs
Read the final `ARGUMENTS:` block for this skill invocation.
Supported inputs:
1. `test`
2. any other inline task prompt

If the argument is `test`, use this fixed smoke task:

```text
Create the run-scoped smoke file .pge-artifacts/<run_id>/deliverables/smoke.txt with content exactly: pge smoke
```

For `test`, use the smallest possible Agent Teams path:
- keep the skeleton `planner -> generator -> evaluator`
- do not read additional handoff/runtime docs during execution
- do not redispatch teammates
- ignore teammate `idle_notification` messages completely
- do not emit user-facing "waiting for ..." chatter between dispatch and the required runtime event

If the argument is not `test`:
- use the prompt as the task input
- Planner may inspect repo plans/docs if helpful
- if no plan exists, Planner should produce a minimal execution brief directly from the prompt
- do not ask the user for a plan path

## Execution Protocol
For normal non-test runs, read `runtime/artifacts-and-state.md`, `ORCHESTRATION.md`, and `contracts/runtime-event-contract.md`.

For `test`, use this inline minimal protocol instead of reading extra runtime/handoff docs:
- initialize `run_id`, `input_artifact`, `progress_artifact`, and `smoke_deliverable`
- create one team with `planner`, `generator`, and `evaluator`
- send planner one compact smoke-task dispatch; wait only for `type: planner_contract_ready`
- gate `planner_artifact` by required top-level sections
- send generator one compact smoke-task dispatch; wait only for `type: generator_completion`
- gate the smoke deliverable by existence, exact bytes, and exact content
- send evaluator one compact smoke-task dispatch; wait only for `type: final_verdict`
- gate `evaluator_artifact` by required sections plus `PASS / converged`
- route immediately, request shutdown once, delete team once, and return the final result
- ignore teammate `idle_notification` and keep waiting for the required runtime event
- for `test`, never redispatch planner, generator, or evaluator after an idle notification

For all runs:

1. Initialize
   - resolve task input and `smoke_deliverable = .pge-artifacts/<run_id>/deliverables/smoke.txt` for `test`
   - write `input_artifact`
   - initialize `progress_artifact` as one shared append-only execution log
   - initialize `manifest_artifact` as the run-directory index
   - verify the runtime can resolve the `pge-planner`, `pge-generator`, and `pge-evaluator` agent surfaces

2. Create team
   - `TeamCreate(team_name=team_name, description="PGE runtime team")`
   - spawn teammate `planner` using `pge-planner`
   - spawn teammate `generator` using `pge-generator`
   - spawn teammate `evaluator` using `pge-evaluator`
   - append a best-effort `run_started` / `team_created` log entry

3. Planner
   - for `test`, use one compact dispatch and a minimal section gate
   - otherwise read `handoffs/planner.md`, send work, wait for `type: planner_contract_ready`, gate `planner_artifact`
   - append a best-effort planner gate log entry; this is the first hard review point

4. Generator
   - for non-test runs, read `handoffs/generator.md`
   - for `test`, send implementation task to generator with `output_artifact = None` and the resolved `smoke_deliverable`
   - otherwise send implementation task to generator with the configured durable `generator_artifact`
   - wait for `type: generator_completion`, gate deliverable and any required durable generator output
   - when a durable generator artifact exists, inspect `self_review.generator_plan_review`
   - append a best-effort generator gate log entry; this is the second hard review point

5. Evaluator
   - for non-test runs, read `handoffs/evaluator.md`
   - send evaluation task to evaluator, wait for `type: final_verdict`, gate `evaluator_artifact` and final verdict
   - append a best-effort evaluator gate log entry; this is the third hard review point

6. Route, summary, teardown
   - for non-test runs, read `handoffs/route-summary-teardown.md`
   - route from Evaluator verdict and next_route
   - write summary only when the run actually needs a human-readable closeout
   - request teammate shutdown, delete team, append best-effort route / teardown log entries

## Final Response

Return only:

```md
## PGE Execute Result
- status: <SUCCESS | BLOCKED>
- run_id: <run_id>
- verdict: <verdict>
- route: <route>
- artifacts:
    - <input_artifact>
    - <planner_artifact>
    - <generator_artifact if written>
    - <evaluator_artifact>
    - <manifest_artifact>
    - <progress_artifact if written>
    - <summary_artifact if written>
    - <deliverable if produced>
- blocker: <single concrete blocker or null>
```

Final result mapping:
- `status = SUCCESS` only when `verdict = PASS` and `route = converged`
- `route = continue | retry | return_to_planner | unsupported_route | blocked` must not be reported as `SUCCESS`

## Forbidden Behavior

Do not:

- require `--plan`
- require a plan path from the user
- simulate agents in `main`
- replace Team flow with direct role-play
- insert a separate preflight or mode-decision gate into the current executable lane
- advance from shell polling or mailbox file existence instead of a valid runtime event
- react to teammate `idle_notification` as if it were a runtime event
- emit user-facing "waiting for ..." chatter for `test`
- redispatch a `test` teammate because of silence or idle notification alone
- auto-retry multiple rounds
- treat the progress log as a state machine or execution gate
- stop before waiting for the dispatched teammate artifact handoff
- accept `test` without the evaluator independently reading the run-scoped smoke deliverable
- report `status: SUCCESS` together with any non-terminal route
- let teammates write authoritative progress directly
