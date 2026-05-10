---
name: pge-execute
description: Run one bounded PGE execution using the PGE Agent Team surfaces pge-planner, pge-generator, and pge-evaluator with messaging-first coordination and durable phase artifacts.
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

> **DEPRECATED**: This is the legacy Anthropic PGE mode (3 resident agents: planner/generator/evaluator). For the current pipeline (`pge-research → pge-plan → pge-exec`), use `pge-exec` instead. This skill is preserved for cases where no pge-plan output exists and you need raw prompt → P/G/E execution.

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
- one bounded run where Planner freezes the contract, Generator implements, and Evaluator validates
- a bounded same-contract `generator <-> evaluator` repair loop for retryable failures
- task size changes role depth, not stage count
- durable phase outputs plus one shared progress log
- independent final evaluation
- progress log is weak dependency only

Not supported yet:
- automatic multi-round redispatch
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
     -> if Evaluator returns retryable required fixes under the same fair contract,
        main dispatches bounded Generator repair and bounded Evaluator re-check
     -> route/summary/teardown phase records outcome and deletes the team
```

The orchestrator advances from runtime events and then validates any referenced durable side effects.

## Hard Requirements
- Use Claude Code native Agent Teams.
- Do not add a separate capability-check phase before execution. Attempt the required Team control-plane action directly and treat a real call failure as the signal.
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
- Do not replace agent dispatch with main-session roleplay.
- Only `main` may talk directly to the user; teammates may surface clarification needs, but `main` owns the actual user-facing question.
- Do not require the user to pass a plan path.
- Do not insert a separate preflight or mode-decision phase into the current executable lane.
- Do not give Planner authority to decide final verdict.
- Do not claim redispatch for `continue` or `return_to_planner`; `retry` supports a bounded Generator repair loop in the same resident team when Evaluator says the current contract remains fair.

If TeamCreate / Agent with `team_name` / SendMessage / TeamDelete fails, stop immediately and report that concrete blocker. Do not fail from tool-list inspection or other speculative pre-checks.

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
- keep the initial Planner / Generator / Evaluator progression thin
- do not read additional handoff/runtime docs during execution
- do not redispatch teammates
- do not treat teammate `idle_notification` as completion
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
- send planner one compact smoke-task dispatch; wait for the canonical teammate-to-main message whose first non-empty line is `type: planner_contract_ready`
- gate `planner_artifact` by required top-level sections
- send generator one compact smoke-task dispatch; wait for the canonical teammate-to-main message whose first non-empty line is `type: generator_completion`
- gate the smoke deliverable by existence, exact bytes, and exact content
- send evaluator one compact smoke-task dispatch; wait for the canonical teammate-to-main message whose first non-empty line is `type: final_verdict`
- gate `evaluator_artifact` by required sections plus `PASS / converged`
- route immediately, request shutdown once, delete team once, and return the final result
- use non-canonical teammate hints, including recovery/resume recap or task-state replay, only to trigger a clarification / resend request to the same teammate; do not advance from them unless the canonical notification text is present
- ignore or log support messages such as `planner_support_request` / `planner_support_response` while waiting for phase completion; they are not completion hints
- keep wait/recovery observation quiet; do not expose foreground polling scripts or verbose verification transcripts as the progress model
- treat `TaskUpdate(status: completed)` as bookkeeping only; it is not a PGE phase-completion event
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
   - otherwise read `handoffs/planner.md`, send work, wait for the canonical teammate-to-main `type: planner_contract_ready` message, and if needed send exactly one protocol repair message asking planner to resend only that event
   - while waiting, support messages may be logged but must not trigger phase advancement or the one-shot completion repair
   - if `planner_contract_ready` has `ready_for_generation: false`, record Planner blocker/escalation, do not dispatch Generator, route/status as blocked, then teardown
   - if no planner message arrives after repair but `planner_artifact` exists and passes the full gate for this run, record degraded progression with `protocol_recovery: missing_team_message_event_artifact_gate`
   - if no planner message arrives and degraded recovery cannot be proven, stop with `protocol_violation: missing_team_message_event`, record blocker/friction, then teardown when a team exists
   - after receiving the planner message or recording degraded progression, gate `planner_artifact`
   - append a best-effort planner gate log entry; this is the first hard review point

4. Generator
   - for non-test runs, read `handoffs/generator.md`
   - for `test`, send implementation task to generator with `output_artifact = None` and the resolved `smoke_deliverable`
   - otherwise send implementation task to generator with the configured durable `generator_artifact`; non-test runs must not omit it
   - wait for the canonical teammate-to-main `type: generator_completion` message, and if needed send exactly one protocol repair message asking generator to write any missing required durable `generator_artifact` and send that event with `handoff_status: READY_FOR_EVALUATOR` or `handoff_status: BLOCKED`
   - while waiting, `planner_support_request` / `planner_support_response` traffic between Generator and Planner may be logged but must not trigger completion repair or phase advancement
   - if the real deliverable appears but `generator_artifact` or `generator_completion` is missing, treat it as a recoverable Generator handoff gap first; do not route blocked until the repair request fails or returns canonical BLOCKED
   - after receiving the generator message or recording degraded progression, gate deliverable and any required durable generator output
   - when a durable generator artifact exists, inspect `self_review.generator_plan_review`
   - if `generator_completion` has `handoff_status: BLOCKED` and the artifact shows a still-local same-contract issue with a narrow `repair_direction`, send `generator_repair_request` to the resident `generator` instead of tearing down immediately
   - if `generator_completion` has `handoff_status: BLOCKED` and the artifact does not show a still-local same-contract repair path, record the Generator blocker, do not dispatch Evaluator, route/status as blocked or unsupported, then teardown
   - if no generator message arrives after repair but the deliverable and required generator artifact exist and pass the full gate for this run, record degraded progression with `protocol_recovery: missing_team_message_event_artifact_gate`
   - if no generator message arrives and degraded recovery cannot be proven, stop with `protocol_violation: missing_team_message_event`, record blocker/friction, then teardown when a team exists
   - append a best-effort generator gate log entry; this is the second hard review point

5. Evaluator
   - for non-test runs, read `handoffs/evaluator.md`
   - send evaluation task to evaluator, wait for the canonical teammate-to-main `type: final_verdict` message, and if needed send exactly one protocol repair message asking evaluator to resend only that event
   - while waiting, support messages may be logged but must not trigger phase advancement or the one-shot completion repair
   - treat failed acceptance verification, including command crash/signal/non-zero results such as exit code `139`, as task non-acceptance even if the team later has teardown friction
   - if no evaluator message arrives after repair but `evaluator_artifact` exists and passes the full gate for this run, record degraded progression with `protocol_recovery: missing_team_message_event_artifact_gate`
   - if no evaluator message arrives and degraded recovery cannot be proven, stop with `protocol_violation: missing_team_message_event`, record blocker/friction, then teardown when a team exists
   - after receiving the evaluator message or recording degraded progression, gate `evaluator_artifact` and final verdict
   - if verdict is `RETRY`, or `BLOCK` with current contract still fair and required fixes are local to Generator, send `generator_repair_request` to resident Generator, gate the fresh `generator_completion`, then send `evaluator_recheck_request` to Evaluator and gate the fresh `final_verdict`
   - repeat the Generator repair -> Evaluator re-check loop until PASS, return_to_planner/ESCALATE, repeated same-failure threshold, or max generator attempts per round is reached
   - max generator attempts per round is 10 total attempts, including the initial generation; same `failure_signature` repeated on 3 consecutive evaluations requires a saved repair snapshot and explicit main decision before continuing
   - **no-change guard**: if Generator's repair attempt produces no file changes (same `changed_files` as prior attempt), treat it as a same-failure and count toward the 3-consecutive threshold immediately; do not dispatch Evaluator for unchanged code
   - when a loop threshold is hit, save the current repair snapshot, then main chooses continue one more attempt, return to Planner, or stop failed; ask the user only when main cannot justify that decision from artifacts
   - append a best-effort evaluator gate log entry; this is the third hard review point

6. Route, summary, teardown
   - for non-test runs, read `handoffs/route-summary-teardown.md`
   - route from Evaluator verdict and next_route
   - write summary only when the run actually needs a human-readable closeout
   - request teammate shutdown, wait boundedly for teammate `shutdown_response` messages to `team-lead`, delete team, append best-effort route / teardown log entries

## Final Response

Return only:

```md
## PGE Execute Result
- status: <SUCCESS | BLOCKED>
- run_id: <run_id>
- verdict: <verdict>
- route: <route>
- task_status: <passed | failed | blocked | unsupported>
- teardown_status: <ok | friction | failed | not_attempted>
- artifacts:
    - <input_artifact>
    - <planner_artifact>
    - <generator_artifact if written>
    - <evaluator_artifact>
    - <manifest_artifact>
    - <progress_artifact if written>
    - <repair_snapshot_artifact if written>
    - <summary_artifact if written>
    - <deliverable if produced>
- blocker: <single concrete blocker or null>
```

Final response path rule:
- artifact and deliverable entries must be complete absolute paths copied from manifest/progress values
- each path must be one list item; do not concatenate adjacent artifact paths or stream partial path fragments
- include a path only when it exists/readable, or mark it explicitly as missing

Final result mapping:
- `status = SUCCESS` only when `verdict = PASS` and `route = converged`
- `route = continue | retry | return_to_planner | unsupported_route | blocked` must not be reported as `SUCCESS`
- `task_status` is derived from Planner/Generator/Evaluator deliverable evidence and verification, not from teardown
- `teardown_status` records shutdown/delete friction separately and must not rewrite a failed task as infrastructure-only failure

## Forbidden Behavior

Do not:

- require `--plan`
- require a plan path from the user
- simulate agents in `main`
- replace agent dispatch with direct role-play
- insert a separate preflight or mode-decision gate into the current executable lane
- advance from shell polling or mailbox file existence without either canonical teammate-to-main notification plus gate or explicit degraded artifact-gated recovery
- react to teammate `idle_notification` as if it were canonical completion
- emit user-facing "waiting for ..." chatter for `test`
- redispatch a `test` teammate because of silence or idle notification alone
- auto-retry multiple rounds beyond the bounded same-contract generator repair loop
- treat the progress log as a state machine or execution gate
- treat `TaskUpdate(status: completed)` as phase completion
- stop before waiting for the dispatched teammate artifact handoff
- accept `test` without the evaluator independently reading the run-scoped smoke deliverable
- report `status: SUCCESS` together with any non-terminal route
- let teammates write authoritative progress directly
- redispatch Generator with no code changes (same input → same output = infinite loop)
- allow Generator to run destructive git commands (reset --hard, clean -f, push --force, checkout -- .)
- auto-retry failed package installs with guessed package names (typosquatting risk)
