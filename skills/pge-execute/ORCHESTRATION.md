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
4. generator handoff
5. evaluator handoff
6. route
7. summary
8. teardown

## Core rule

Each handoff is file-backed.
`main` continues only after the required artifact file exists and passes its minimal structural gate.

For the current stage, this is more important than richer state-machine detail.

## Smoke task

For `/pge-execute test`:
- generator must write `.pge-artifacts/pge-smoke.txt`
- file content must be exactly `pge smoke`
- evaluator must independently read that file
- PASS requires `verdict = PASS` and `route = converged`

## Required run artifacts

Each run must write at least:
- `.pge-artifacts/<run_id>-input.md`
- `.pge-artifacts/<run_id>-planner.md`
- `.pge-artifacts/<run_id>-generator.md`
- `.pge-artifacts/<run_id>-evaluator.md`
- `.pge-artifacts/<run_id>-state.json`
- `.pge-artifacts/<run_id>-summary.md`
- `.pge-artifacts/pge-smoke.txt`

## Minimal runtime state

Allowed states only:
- `initialized`
- `team_created`
- `planning`
- `generating`
- `evaluating`
- `converged`
- `stopped`
- `failed`

Required fields only:
- `run_id`
- `state`
- `team_created`
- `planner_called`
- `generator_called`
- `evaluator_called`
- `verdict`
- `route`
- `artifact_refs`
- `error_or_blocker`

## Route behavior

Current version supports only one successful terminal route:
- `converged`

If evaluator returns anything else:
- record it
- write state + summary
- stop
- do not auto-retry

## Guardrails

- Use real Agent Teams or stop with a blocker.
- Do not simulate planner/generator/evaluator inside `main`.
- Do not stop early after dispatch while the required artifact handoff is still pending.
- Keep the run bounded to one round.
- Keep changes minimal and execution-first.
