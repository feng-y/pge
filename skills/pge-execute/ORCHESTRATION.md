# PGE_EXECUTE_ORCHESTRATION

## Purpose

This file records the minimal orchestration behavior for `/pge-execute` in the current stage.

Current priority is this:
- keep one real Agent Team for the run
- shift normal coordination to Agent Teams messaging
- preserve durable artifacts only for phase results and state
- allow lighter closure for simple deterministic tasks
- keep the current executable lane bounded to one run

Do not broaden this seam into a larger workflow framework.

## Runtime roles

- `main` = orchestration shell only
- `planner` = produce minimal execution brief
- `generator` = do the real repo work and self-check
- `evaluator` = independently validate and issue verdict/route

`main` is not a fourth agent.

## Required lifecycle

Single-run lifecycle:
1. initialize run
2. create team
3. planner handoff
4. Evaluator cost-gate triage and mode decision
5. execute chosen path (`FAST_PATH`, `LITE_PGE`, or `FULL_PGE`)
6. evaluator handoff / final verdict
7. route
8. summary when mode requires it
9. teardown

## Core rule

Normal coordination is message-first.
`main` advances only from runtime events defined in `skills/pge-execute/contracts/runtime-event-contract.md`.

Durable artifacts are side effects validated after the matching event is received.

For the current stage:
- Planner writes the locked task-shape artifact
- Generator and Evaluator negotiate preflight primarily through `SendMessage`
- only durable phase outputs are written to disk

## Smoke task

For `/pge-execute test`:
- generator must write `.pge-artifacts/pge-smoke.txt`
- file content must be exactly `pge smoke`
- evaluator must independently read that file
- PASS requires `verdict = PASS` and `next_route = converged`
- expected mode is `FAST_PATH` when Evaluator approves the deterministic contract
- management artifacts, excluding `input_artifact` and the smoke deliverable, must be at most 3: `planner_artifact`, `evaluator_artifact`, and `state_artifact`

## Required run artifacts

Required artifacts are mode-aware:
- all modes: `.pge-artifacts/<run_id>-planner.md`, `.pge-artifacts/<run_id>-evaluator.md`, `.pge-artifacts/<run_id>-state.json`
- `LITE_PGE` and `FULL_PGE`: `.pge-artifacts/<run_id>-generator.md`
- `FULL_PGE`: `.pge-artifacts/<run_id>-contract-proposal.md`, `.pge-artifacts/<run_id>-preflight.md`
- mode-required only: `.pge-artifacts/<run_id>-summary.md`, `.pge-artifacts/<run_id>-progress.md`
- deliverable when applicable: `.pge-artifacts/pge-smoke.txt`

`FAST_PATH` must not require or write `.pge-artifacts/<run_id>-contract-proposal.md`, `.pge-artifacts/<run_id>-preflight.md`, `.pge-artifacts/<run_id>-generator.md`, `.pge-artifacts/<run_id>-summary.md`, or `.pge-artifacts/<run_id>-progress.md`.

## Minimal runtime state

Allowed states only:
- `initialized`
- `team_created`
- `planning`
- `preflight_pending`
- `ready_to_generate`
- `generating`
- `evaluating`
- `unsupported_route`
- `converged`
- `stopped`
- `failed`

Required fields only:
- `run_id`
- `state`
- `mode`
- `mode_decision_owner`
- `fast_finish_approved`
- `artifact_budget`
- `team_created`
- `planner_called`
- `preflight_called`
- `preflight_attempt_id`
- `max_preflight_attempts`
- `generator_called`
- `evaluator_called`
- `verdict`
- `route`
- `artifact_refs`
- `error_or_blocker`

Progress tracking:
- `FULL_PGE` runs must maintain `.pge-artifacts/<run_id>-progress.md`
- lighter modes may omit `progress.md`
- when present, progress must show current phase, phase status, open issues, and latest evaluator gate status
- progress is an observer artifact written by `main`, not a fourth agent output
- initial `mode` is null until Evaluator makes the mode decision; do not initialize as `FULL_PGE`

## Route behavior

Current version supports only one successful terminal route:
- `converged`

If evaluator returns anything else:
- record it
- write state + summary
- transition to `unsupported_route` for canonical `continue`, `retry`, or `return_to_planner`
- stop without redispatch
- do not auto-retry in the current smoke stage

Preflight returns before generation:
- `PASS` + `ready_to_generate` advances to Generator work
- Evaluator owns preflight mode decision and fast-finish approval
- For deterministic `FAST_PATH`, Evaluator may approve mode and fast finish from the Planner contract through `SendMessage`; do not write proposal/preflight artifacts.
- repairable proposal issues may loop through bounded preflight repair attempts while state remains `preflight_pending`
- `BLOCK` or `ESCALATE` records the contract issue and stops at `unsupported_route` once repair must return to Planner
- preflight never performs repo edits

## Guardrails

- Use real Agent Teams or stop with a blocker.
- Do not simulate planner/generator/evaluator inside `main`.
- Do not give Planner authority to decide `FAST_PATH` or fast finish.
- Do not advance from artifact existence alone; require the matching runtime event first.
- Keep the current lane bounded to one run.
- Do not let Generator perform repo edits before preflight accepts the round contract.
- Do not create FULL_PGE-only artifacts after Evaluator approves `FAST_PATH`.
- Keep changes minimal and execution-first.
