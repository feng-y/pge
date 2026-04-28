# PGE_EXECUTE_ORCHESTRATION

## Purpose

This file records the minimal orchestration behavior for `/pge-execute` in the current stage.

Current priority is only this:
- make `/pge-execute test` run through a real Agent Team
- prove planner -> generator -> evaluator handoff
- write the required artifacts
- stop after one bounded round

Do not broaden this seam into a larger workflow framework.

## Runtime roles

- `main` = orchestration shell only
- `planner` = produce minimal execution brief
- `generator` = do the real repo work and self-check
- `evaluator` = independently validate and issue verdict/route

`main` is not a fourth agent.

## Required lifecycle

Single round only:
1. initialize run
2. create team
3. planner handoff
4. contract preflight handoff
5. generator handoff
6. evaluator handoff
7. route
8. summary
9. teardown

## Core rule

Each handoff is file-backed.
`main` continues only after the required artifact file exists and passes its minimal structural gate.

For the current stage, this is more important than richer state-machine detail.

## Smoke task

For `/pge-execute test`:
- generator must write `.pge-artifacts/pge-smoke.txt`
- file content must be exactly `pge smoke`
- evaluator must independently read that file
- PASS requires `verdict = PASS` and `next_route = converged`

## Required run artifacts

Each run must write at least:
- `.pge-artifacts/<run_id>-input.md`
- `.pge-artifacts/<run_id>-planner.md`
- `.pge-artifacts/<run_id>-contract-proposal.md`
- `.pge-artifacts/<run_id>-preflight.md`
- `.pge-artifacts/<run_id>-generator.md`
- `.pge-artifacts/<run_id>-evaluator.md`
- `.pge-artifacts/<run_id>-state.json`
- `.pge-artifacts/<run_id>-summary.md`
- `.pge-artifacts/<run_id>-progress.md`
- `.pge-artifacts/pge-smoke.txt`

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
- each run must maintain `.pge-artifacts/<run_id>-progress.md`
- progress must show current phase, phase status, open issues, and latest evaluator gate status
- progress is an observer artifact written by `main`, not a fourth agent output

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
- repairable proposal issues may loop through bounded preflight repair attempts while state remains `preflight_pending`
- `BLOCK` or `ESCALATE` records the contract issue and stops at `unsupported_route` once repair must return to Planner
- preflight never performs repo edits

## Guardrails

- Use real Agent Teams or stop with a blocker.
- Do not simulate planner/generator/evaluator inside `main`.
- Do not stop early after dispatch while the required artifact handoff is still pending.
- Keep the run bounded to one round.
- Do not let Generator perform repo edits before preflight accepts the round contract.
- Keep changes minimal and execution-first.
