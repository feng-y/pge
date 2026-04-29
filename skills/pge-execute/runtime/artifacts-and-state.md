# PGE Execute Runtime Artifacts And State

## Artifact Paths

Use `repo_root` as the current working directory. Create `.pge-artifacts/` if needed.

```text
run_id = "run-" + current UTC timestamp in YYYYMMDDTHHMMSSZ
artifact_dir = .pge-artifacts
input_artifact = .pge-artifacts/<run_id>-input.md
planner_artifact = .pge-artifacts/<run_id>-planner.md
contract_proposal_artifact = .pge-artifacts/<run_id>-contract-proposal.md
preflight_artifact = .pge-artifacts/<run_id>-preflight.md
generator_artifact = .pge-artifacts/<run_id>-generator.md
evaluator_artifact = .pge-artifacts/<run_id>-evaluator.md
state_artifact = .pge-artifacts/<run_id>-state.json
summary_artifact = .pge-artifacts/<run_id>-summary.md
progress_artifact = .pge-artifacts/<run_id>-progress.md
smoke_deliverable = .pge-artifacts/pge-smoke.txt
team_name = pge-runtime-<run_id>
```

Artifacts are mode-aware:

- `FAST_PATH`: `planner_artifact`, `evaluator_artifact`, `state_artifact`, plus deliverable
- `LITE_PGE`: `planner_artifact`, `generator_artifact`, `evaluator_artifact`, `state_artifact`, plus deliverable
- `FULL_PGE`: all listed artifacts except optional checkpoint/resume files
- `LONG_RUNNING_PGE`: future lane; current stage may classify it but must not silently claim full execution support

`input_artifact` is intake capture. It is durable when written, but it is not counted against the mode's management-artifact budget.

## Runtime State

This file defines the current executable subset of runtime state for `pge-execute`.

It is intentionally smaller than `skills/pge-execute/contracts/runtime-state-contract.md`, which is the normative semantic superset for richer and future runtime states.

`state_artifact` must always be valid JSON with at least these fields:

```json
{
  "run_id": "<run_id>",
  "state": "initialized",
  "mode": "FULL_PGE",
  "mode_decision_owner": null,
  "fast_finish_approved": false,
  "artifact_budget": null,
  "team_created": false,
  "planner_called": false,
  "preflight_called": false,
  "preflight_attempt_id": 1,
  "max_preflight_attempts": 2,
  "generator_called": false,
  "evaluator_called": false,
  "verdict": null,
  "route": null,
  "check": null,
  "artifact_refs": {},
  "error_or_blocker": null
}
```

Allowed `state` values only:

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

Allowed `mode` values only:

- `FAST_PATH`
- `LITE_PGE`
- `FULL_PGE`
- `LONG_RUNNING_PGE`

## Progress Artifact

Maintain `progress_artifact` throughout the run only when the chosen mode requires it. It is an observer artifact written by main, not a fourth agent output.

When written, it must record:

- run_id
- current phase
- phase status table
- preflight attempt counters
- open issues / blockers
- latest evaluator gate status
- whether Generator has been allowed to edit

Update `progress_artifact` after every phase transition when mode is `FULL_PGE` or `LONG_RUNNING_PGE`:

- initialization
- team creation
- planner handoff
- preflight proposal
- preflight evaluation
- generation
- evaluation
- route
- summary
- teardown attempt
