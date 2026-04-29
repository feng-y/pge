# Generator Handoff

## Dispatch

Send this task to `generator` only after preflight has passed.

```text
You are @generator in the PGE runtime team.

run_id: <run_id>
planner_artifact: <planner_artifact>
contract_proposal_artifact: <contract_proposal_artifact or None for FAST_PATH>
preflight_artifact: <preflight_artifact or None for FAST_PATH>
output_artifact: <generator_artifact or None for FAST_PATH>

Execute the planner contract.
Use the accepted preflight proposal as execution guidance, but do not expand scope beyond the Planner contract.
For `FAST_PATH`, use the Planner contract and Evaluator mode approval as execution guidance; no durable Generator artifact is required.

For `test`, perform a real write in this run:
- write `.pge-artifacts/pge-smoke.txt`
- set its full content to exactly `pge smoke`
- do this even if the file already exists
- verify the file exists and its full content equals exactly `pge smoke`

If mode is `FAST_PATH`, do not write <generator_artifact>. After local verification, report completion through `SendMessage` with deliverable path and exact verification result.

FAST_PATH completion message shape:

```text
type: generator_completion
handoff_status: READY_FOR_EVALUATOR
deliverable_path: .pge-artifacts/pge-smoke.txt
verification_result: exact content equals `pge smoke`
generator_artifact: null
```

If mode requires a durable Generator artifact, write markdown to <generator_artifact> with exactly these top-level sections:
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

- for `test`, `.pge-artifacts/pge-smoke.txt` exists
- for `test`, reading `.pge-artifacts/pge-smoke.txt` returns exactly `pge smoke`
- when mode requires durable Generator output, artifact exists
- when mode requires durable Generator output, `## deliverable_path` exists
- when mode requires durable Generator output, `## changed_files` exists
- when mode requires durable Generator output, `## local_verification` exists
- when mode requires durable Generator output, `## evidence` exists
- when mode requires durable Generator output, `## self_review` exists

On failure: set `state = "failed"`, mark planner/preflight/generator called, record blocker, write state, update progress only when enabled, stop.

On pass: set `generator_called = true`, persist deliverable ref, persist generator ref only when the artifact was written, write state, update progress only when enabled.
