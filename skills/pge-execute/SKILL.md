---
name: pge-execute
description: Run one minimal PGE execution using a real Claude Code Agent Team (planner, generator, evaluator) with file-backed artifacts.
version: 0.3.0
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

Run one bounded PGE execution with a real Agent Team.

This skill is the orchestration shell only.
It is not a fourth agent.

Current goal: make `/pge-execute test` run end-to-end with the smallest real closed loop.
Do not broaden into workflow/framework design.

## Hard requirements

- Use Claude Code native Agent Teams.
- Create exactly one team for the run.
- Spawn exactly three teammates:
  - `planner` using `pge-planner`
  - `generator` using `pge-generator`
  - `evaluator` using `pge-evaluator`
- Dispatch work through `SendMessage`.
- Use file-backed handoff.
- Do not simulate Planner / Generator / Evaluator in `main`.
- Do not fall back to direct non-team Agent dispatch.
- Do not require the user to pass a plan path.
- First version is single-round only.

If TeamCreate / Agent with `team_name` / SendMessage / TeamDelete cannot be used, stop immediately and report one concrete blocker.

## Accepted inputs

Read the final `ARGUMENTS:` block for this skill invocation.

Supported inputs in this version:
1. `test`
2. any other inline task prompt

If the argument is `test`, use this fixed smoke task:

```text
Create .pge-artifacts/pge-smoke.txt with content exactly: pge smoke
```

If the argument is not `test`:
- use the prompt as the task input
- Planner may inspect repo plans/docs if helpful
- if no plan exists, Planner should produce a minimal execution brief directly from the prompt
- do not ask the user for a plan path

## Runtime files

Use `repo_root` as the current working directory.
Create `.pge-artifacts/` if needed.

Use these exact per-run artifacts:

```text
run_id = "run-" + current UTC timestamp in YYYYMMDDTHHMMSSZ
artifact_dir = .pge-artifacts
input_artifact = .pge-artifacts/<run_id>-input.md
planner_artifact = .pge-artifacts/<run_id>-planner.md
generator_artifact = .pge-artifacts/<run_id>-generator.md
evaluator_artifact = .pge-artifacts/<run_id>-evaluator.md
state_artifact = .pge-artifacts/<run_id>-state.json
summary_artifact = .pge-artifacts/<run_id>-summary.md
smoke_deliverable = .pge-artifacts/pge-smoke.txt
team_name = pge-runtime-<run_id>
```

## Minimal runtime state

`state_artifact` must always be valid JSON with these fields:

```json
{
  "run_id": "<run_id>",
  "state": "initialized",
  "team_created": false,
  "planner_called": false,
  "generator_called": false,
  "evaluator_called": false,
  "verdict": null,
  "route": null,
  "artifact_refs": {},
  "error_or_blocker": null
}
```

Allowed `state` values only:
- `initialized`
- `team_created`
- `planning`
- `generating`
- `evaluating`
- `converged`
- `stopped`
- `failed`

## Step 0 — Initialize

1. Resolve the effective task input.
   - `test` => fixed smoke task
   - otherwise => raw prompt text
2. Write `input_artifact`.
   - include `run_id`
   - include original argument
   - include resolved task input
   - for `test`, explicitly record the exact smoke contract
3. Write initial `state_artifact` with state `initialized`.
4. Check that these files exist under the active plugin root or current repo plugin source:
   - `agents/pge-planner.md`
   - `agents/pge-generator.md`
   - `agents/pge-evaluator.md`
5. If any is missing, set `state` to `failed`, set `error_or_blocker`, write `state_artifact`, and stop.

## Step 1 — Create Team

1. Create the team:

```python
TeamCreate(team_name=team_name, description="PGE runtime smoke team")
```

2. Spawn exactly three teammates:

```python
Agent(subagent_type="pge-planner", team_name=team_name, name="planner", prompt="You are the PGE planner teammate. Stay idle until main sends the run task. Do not write code.")
Agent(subagent_type="pge-generator", team_name=team_name, name="generator", mode="acceptEdits", prompt="You are the PGE generator teammate. Stay idle until main sends the run task. You may write files when asked.")
Agent(subagent_type="pge-evaluator", team_name=team_name, name="evaluator", prompt="You are the PGE evaluator teammate. Stay idle until main sends the run task. Do not modify files.")
```

3. Update `state_artifact`:
   - `state = "team_created"`
   - `team_created = true`
   - fill `artifact_refs` for all known artifact paths

If team creation or teammate spawn fails, set `state = "failed"`, record one concrete blocker, write `state_artifact`, and stop.

## Step 2 — Planner

1. Update `state = "planning"`.
2. Send work to `planner`.
3. Planner must write `planner_artifact`.
4. Wait for `planner_artifact` to exist before continuing.
   - Prefer waiting on the file-backed handoff directly.
   - Use a bounded shell wait if needed.
   - Do not stop early just because the teammate has not replied yet.
5. After the file exists, read it and gate it.

Planner message:

```text
You are @planner in the PGE runtime team.

run_id: <run_id>
input_artifact: <input_artifact>
output_artifact: <planner_artifact>

Task:
Produce the smallest executable plan for this run.

If the task is `test`, you must preserve this exact smoke deliverable:
- file: .pge-artifacts/pge-smoke.txt
- content: pge smoke

For non-test input:
- inspect repo plans/docs only if useful
- if a relevant plan exists, normalize it into one minimal execution brief
- otherwise create the execution brief directly from the prompt

Write markdown to <planner_artifact> with exactly these top-level sections:
- ## goal
- ## in_scope
- ## out_of_scope
- ## actual_deliverable
- ## acceptance_criteria
- ## verification_path
- ## stop_condition
- ## handoff_seam
- ## open_questions

Rules:
- do not implement
- do not evaluate
- keep one bounded round only
- for test, acceptance must require the smoke file content to equal exactly `pge smoke`
- for test, do not broaden scope beyond the smoke file plus the normal PGE control-plane artifacts written by main/generator/evaluator
```

Planner gate:
- artifact exists
- all required sections exist
- `## actual_deliverable` exists
- `## acceptance_criteria` exists
- `## verification_path` exists
- `## stop_condition` exists

If the gate fails:
- set `state = "failed"`
- set `planner_called = true`
- record blocker
- write `state_artifact`
- stop

If the gate passes:
- set `planner_called = true`
- persist `planner_artifact` path in `artifact_refs`
- write `state_artifact`

## Step 3 — Generator

1. Update `state = "generating"`.
2. Send work to `generator`.
3. Generator must write `generator_artifact` and perform the real repo work.
4. Wait for `generator_artifact` to exist before continuing.
   - Prefer waiting on the file-backed handoff directly.
   - Do not stop early just because the teammate has not replied yet.
5. After the file exists, read it and gate it.

Generator message:

```text
You are @generator in the PGE runtime team.

run_id: <run_id>
planner_artifact: <planner_artifact>
output_artifact: <generator_artifact>

Execute the planner contract.

For `test`, you must perform a real write in this run:
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
- ## known_limits
- ## non_done_items
- ## deviations_from_spec
- ## handoff_status

Rules:
- perform the real file work
- run local verification
- do not self-approve
- do not issue final PASS
- for test, `changed_files` must include `.pge-artifacts/pge-smoke.txt`
- for test, evidence must include proof of exact content equality
```

Generator gate:
- artifact exists
- `## deliverable_path` exists
- `## changed_files` exists
- `## local_verification` exists
- `## evidence` exists
- for `test`, `.pge-artifacts/pge-smoke.txt` exists
- for `test`, reading `.pge-artifacts/pge-smoke.txt` returns exactly `pge smoke`

If the gate fails:
- set `state = "failed"`
- set `planner_called = true`
- set `generator_called = true`
- record blocker
- write `state_artifact`
- stop

If the gate passes:
- set `generator_called = true`
- persist `generator_artifact` and smoke deliverable path in `artifact_refs`
- write `state_artifact`

## Step 4 — Evaluator

1. Update `state = "evaluating"`.
2. Send work to `evaluator`.
3. Evaluator must independently read the smoke file and write `evaluator_artifact`.
4. Wait for `evaluator_artifact` to exist before continuing.
   - Prefer waiting on the file-backed handoff directly.
   - Do not stop early just because the teammate has not replied yet.
5. After the file exists, read it and gate it.

Evaluator message:

```text
You are @evaluator in the PGE runtime team.

run_id: <run_id>
planner_artifact: <planner_artifact>
generator_artifact: <generator_artifact>
output_artifact: <evaluator_artifact>

Evaluate independently.
You must read the actual deliverable yourself.
Do not trust generator claims without checking the file.
Do not modify repo files.

For `test`, independently read `.pge-artifacts/pge-smoke.txt`.
Only output PASS if the file exists and its full content equals exactly `pge smoke`.
If PASS, route must be `converged`.

Write markdown to <evaluator_artifact> with exactly these top-level sections:
- ## verdict
- ## route
- ## route_reason
- ## evidence
- ## required_followup

Allowed verdicts:
- PASS
- RETRY
- BLOCK
- ESCALATE

Allowed routes:
- converged
- retry
- return_to_planner
- stopped
```

Evaluator gate:
- artifact exists
- `## verdict` exists
- `## route` exists
- `## route_reason` exists
- `## evidence` exists
- for `test`, PASS is valid only when route is `converged`

If the gate fails:
- set `state = "failed"`
- set `planner_called = true`
- set `generator_called = true`
- set `evaluator_called = true`
- record blocker
- write `state_artifact`
- stop

If the gate passes:
- set `evaluator_called = true`
- persist `evaluator_artifact` path in `artifact_refs`
- write `state_artifact`

## Step 5 — Route

Read the evaluator artifact.

If:
- verdict = `PASS`
- route = `converged`

then:
- set `state = "converged"`
- set `verdict = "PASS"`
- set `route = "converged"`
- set `error_or_blocker = null`

Otherwise:
- set `state = "stopped"`
- set `verdict` and `route` from evaluator when present
- set `error_or_blocker` to the evaluator reason
- do not retry automatically in this version

Write `state_artifact` after route selection.

## Step 6 — Summary

Write `summary_artifact` with:
- run_id
- task input summary
- team name
- planner/generator/evaluator called flags
- verdict
- route
- artifact paths
- for `test`, smoke result and exact smoke file path
- blocker if any

## Step 7 — Teardown

After the summary is written:

```python
SendMessage(to="planner", message={"type": "shutdown_request"})
SendMessage(to="generator", message={"type": "shutdown_request"})
SendMessage(to="evaluator", message={"type": "shutdown_request"})
TeamDelete()
```

If teardown fails after route selection and artifacts are already written:
- keep the execution result
- mention teardown failure in the final text
- do not rewrite PASS to failure solely because shutdown was noisy

## Final response

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
  - <generator_artifact>
  - <evaluator_artifact>
  - <state_artifact>
  - <summary_artifact>
  - .pge-artifacts/pge-smoke.txt
- blocker: <single concrete blocker or null>
```

## Forbidden behavior

Do not:
- require `--plan`
- require a plan path from the user
- simulate agents in `main`
- replace Team flow with direct role-play
- auto-retry multiple rounds
- expand into broader contract or state-machine design
- stop before waiting for the dispatched teammate artifact handoff
- accept `test` without the evaluator independently reading `.pge-artifacts/pge-smoke.txt`
