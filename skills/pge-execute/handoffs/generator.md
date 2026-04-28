# Generator Handoff

## Dispatch

Send this task to `generator` only after preflight has passed.

```text
You are @generator in the PGE runtime team.

run_id: <run_id>
planner_artifact: <planner_artifact>
contract_proposal_artifact: <contract_proposal_artifact>
preflight_artifact: <preflight_artifact>
output_artifact: <generator_artifact>

Execute the planner contract.
Use the accepted preflight proposal as execution guidance, but do not expand scope beyond the Planner contract.

For `test`, perform a real write in this run:
- write `.pge-artifacts/pge-smoke.txt`
- set its full content to exactly `pge smoke`
- do this even if the file already exists
- verify the file exists and its full content equals exactly `pge smoke`

Write markdown to <generator_artifact> with exactly these top-level sections:
- ## current_task
- ## boundary
- ## actual_deliverable
- ## deliverable_path
- ## changed_files
- ## local_verification
- ## evidence
- ## self_review
- ## known_limits
- ## non_done_items
- ## deviations_from_spec
- ## handoff_status

Rules:
- perform the real file work
- run local verification
- perform local self-review, but do not self-approve
- do not issue final PASS
- for test, `changed_files` must include `.pge-artifacts/pge-smoke.txt`
- for test, evidence must include proof of exact content equality
```

## Gate

- artifact exists
- `## deliverable_path` exists
- `## changed_files` exists
- `## local_verification` exists
- `## evidence` exists
- `## self_review` exists
- for `test`, `.pge-artifacts/pge-smoke.txt` exists
- for `test`, reading `.pge-artifacts/pge-smoke.txt` returns exactly `pge smoke`

On failure: set `state = "failed"`, mark planner/preflight/generator called, record blocker, write state, update progress, stop.

On pass: set `generator_called = true`, persist generator and deliverable refs, write state, update progress.
