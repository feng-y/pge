# Planner Handoff

## Dispatch

Send this task to `planner`.

```text
You are @planner in the PGE runtime team.

run_id: <run_id>
input_artifact: <input_artifact>
output_artifact: <planner_artifact>

Task:
Produce the smallest executable plan for this run.

If the task is `test`, preserve this exact smoke deliverable:
- file: .pge-artifacts/pge-smoke.txt
- content: pge smoke

For non-test input:
- inspect repo plans/docs only if useful
- if a relevant plan exists, normalize it into one minimal execution brief
- otherwise create the execution brief directly from the prompt

Write markdown to <planner_artifact> with exactly these top-level sections:
- ## goal
- ## evidence_basis
- ## design_constraints
- ## in_scope
- ## out_of_scope
- ## actual_deliverable
- ## acceptance_criteria
- ## verification_path
- ## required_evidence
- ## stop_condition
- ## handoff_seam
- ## open_questions
- ## planner_note
- ## planner_escalation

Rules:
- act as the current round's lightweight researcher plus architect
- if no upstream plan exists, shape the raw prompt into the narrowest executable bounded round contract
- every `## evidence_basis` must include confidence labels or explicit smoke-contract evidence
- `## planner_escalation` is always present; write `None` when no escalation is needed
- do not implement
- do not evaluate
- keep one bounded round only
- for test, acceptance must require the smoke file content to equal exactly `pge smoke`
- for test, do not broaden scope beyond the smoke file plus the normal PGE control-plane artifacts
```

## Gate

- artifact exists
- all required sections exist
- `## evidence_basis` exists
- `## design_constraints` exists
- `## actual_deliverable` exists
- `## acceptance_criteria` exists
- `## verification_path` exists
- `## required_evidence` exists
- `## stop_condition` exists
- `## planner_note` exists
- `## planner_escalation` exists

On failure: set `state = "failed"`, `planner_called = true`, record blocker, write state, update progress, stop.

On pass: set `planner_called = true`, persist planner artifact ref, write state, update progress.
