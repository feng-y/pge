---
name: pge-execute
description: Use this skill when the user asks to run one bounded PGE execution round. It creates a persistent Claude Code Team with pge-planner, pge-generator, and pge-evaluator, then runs Planner → Generator → Evaluator through file-backed handoff.
version: 0.2.0
argument-hint: "test | <upstream-plan-file> | <inline-upstream-plan>"
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

Run one bounded PGE execution round using Claude Code native Team system.

This skill is the `main` orchestration shell.

`main` is not a fourth agent.

`main` owns:
- team lifecycle
- runtime state
- artifact paths
- phase dispatch
- file-backed handoff
- route recording
- teardown

`main` must not:
- simulate Planner / Generator / Evaluator
- read agent markdown and act as those roles
- replace Team execution with direct role-play
- create one-off per-task P/G/E groups
- expand into multi-round orchestration

The runtime team is fixed for this skill invocation.

Resolve `plugin_root` from the current installed skill location.

If the skill base directory is `{plugin_root}/skills/pge-execute`, then use:

```python
plugin_root = dirname(dirname(skill_base_dir))
```

Use these agent definition paths from the active plugin surface:

| Teammate | subagent_type | Agent definition |
|---|---|---|
| planner | pge-planner | `{plugin_root}/agents/pge-planner.md` |
| generator | pge-generator | `{plugin_root}/agents/pge-generator.md` |
| evaluator | pge-evaluator | `{plugin_root}/agents/pge-evaluator.md` |

## Agent Resolution Map

Use these exact mappings:

```python
AGENTS = {
  "planner": {
    "subagent_type": "pge-planner",
    "name": "planner",
    "agent_def_path": f"{plugin_root}/agents/pge-planner.md",
  },
  "generator": {
    "subagent_type": "pge-generator",
    "name": "generator",
    "agent_def_path": f"{plugin_root}/agents/pge-generator.md",
  },
  "evaluator": {
    "subagent_type": "pge-evaluator",
    "name": "evaluator",
    "agent_def_path": f"{plugin_root}/agents/pge-evaluator.md",
  },
}
```

This map is the only role → agent mapping for `pge-execute`.

Do not invent other role names.

Do not spawn extra Planner / Generator / Evaluator agents.

## Accepted Inputs

Use the final `ARGUMENTS:` block attached to this skill invocation.

Accepted forms:

1. `test`
2. a readable file path containing upstream shaping input
3. inline upstream text, notes, or a partially-shaped upstream plan
4. any short execute-first request that Planner can cut into one bounded round

If the argument is `test`, use this fixed upstream plan exactly:

```yaml
goal: Create `.pge-artifacts/pge-smoke.txt` containing exactly `pge smoke`
boundary: Only create `.pge-artifacts/pge-smoke.txt`
deliverable: `.pge-artifacts/pge-smoke.txt` with exact content `pge smoke`
verification_path: Verify the file exists and its full contents equal `pge smoke`
run_stop_condition: single_round
```

If the input is not `test`, do not require upstream fields at entry.

Pass the effective upstream input to Planner exactly as received after file resolution.

Planner owns cutting or normalizing that input into one bounded round contract.

Do not enforce intake validation beyond resolving the provided argument.

Do not guess beyond the provided upstream input.

## Runtime Files

Use the current working directory as `repo_root`.

Resolve the active plugin root from the installed skill location:

```python
plugin_root = dirname(dirname(skill_base_dir))
```

Create and use:

```python
artifact_dir = f"{repo_root}/.pge-artifacts"
run_id = f"run-{timestamp}"
round_id = "round-1"

planner_artifact = f"{artifact_dir}/{run_id}-planner-output.md"
generator_artifact = f"{artifact_dir}/{run_id}-generator-output.md"
evaluator_artifact = f"{artifact_dir}/{run_id}-evaluator-verdict.md"
runtime_state = f"{artifact_dir}/{run_id}-runtime-state.json"
summary_artifact = f"{artifact_dir}/{run_id}-round-summary.md"
checkpoint_artifact = f"{artifact_dir}/{run_id}-checkpoint.json"
team_log = f"{artifact_dir}/{run_id}-team-log.jsonl"
```

All runtime state is per-run.

Do not write repo-global runtime state.

## Team Lifecycle

Use Claude Code native Team system.

```python
# 1. Create persistent team for this run
TeamCreate(team_name=f"pge-runtime-{run_id}")

# 2. Spawn exactly three teammates
Agent(
  subagent_type="pge-planner",
  team_name=f"pge-runtime-{run_id}",
  name="planner",
  prompt=planner_startup_prompt,
)

Agent(
  subagent_type="pge-generator",
  team_name=f"pge-runtime-{run_id}",
  name="generator",
  prompt=generator_startup_prompt,
)

Agent(
  subagent_type="pge-evaluator",
  team_name=f"pge-runtime-{run_id}",
  name="evaluator",
  prompt=evaluator_startup_prompt,
)

# 3. Dispatch by SendMessage
SendMessage(to="planner", message=planner_message)
SendMessage(to="generator", message=generator_message)
SendMessage(to="evaluator", message=evaluator_message)

# 4. Shutdown
SendMessage(to="planner", message={"type": "shutdown_request"})
SendMessage(to="generator", message={"type": "shutdown_request"})
SendMessage(to="evaluator", message={"type": "shutdown_request"})

TeamDelete(team_name=f"pge-runtime-{run_id}")
```

If `TeamCreate`, `Agent(..., team_name=...)`, `SendMessage`, or `TeamDelete` is unavailable, stop immediately.

Do not fall back to direct Agent dispatch.

Do not report success without Team execution.

## Startup Checks

Before running the round:

1. Confirm `CLAUDE_CODE_EXPERIMENTAL_AGENT_TEAMS=1` is set.
2. Confirm these files exist under the active plugin root:

   * `{plugin_root}/agents/pge-planner.md`
   * `{plugin_root}/agents/pge-generator.md`
   * `{plugin_root}/agents/pge-evaluator.md`
3. Record each agent definition evidence:

   * path
   * sha256 if available
   * otherwise mtime and size
4. Create `.pge-artifacts/` if needed.
5. Initialize `runtime_state`.
6. Create `team_log`.

If any agent definition file is missing, stop.

Report:

```text
BLOCKER: missing PGE agent definition under active plugin root: <path>
```

## Observer Log

`main` writes JSONL records to `team_log`.

Use one event per phase transition.

Required phases:

```text
init
agent_def_checked
team_create_start
team_create_done
spawn_planner_done
spawn_generator_done
spawn_evaluator_done
planner_dispatch_start
planner_done
planner_artifact_written
generator_dispatch_start
generator_done
generator_artifact_written
evaluator_dispatch_start
evaluator_done
evaluator_artifact_written
route_selected
summary_written
shutdown_start
shutdown_done
complete
blocker
```

Each log entry should include:

```json
{
  "ts": "<iso8601>",
  "run_id": "<run_id>",
  "round_id": "round-1",
  "phase": "<phase>",
  "team_name": "pge-runtime-<run_id>",
  "details": {}
}
```

The log is evidence.

Do not use transcript-only state.

## Execution Flow

### Step 0 — Initialize

Resolve the effective upstream input.

- If the argument is `test`, use the fixed smoke upstream plan.
- If the argument is a readable file path, read that file and use its contents as the upstream input.
- Otherwise, treat the raw argument text as the upstream input.
- Pass the resolved upstream input forward without entry-time validation.

Write initial `runtime_state`:

```json
{
  "run_id": "<run_id>",
  "round_id": "round-1",
  "state": "initialized",
  "agent_team_mode": true,
  "team_name": "pge-runtime-<run_id>",
  "teammates": {
    "planner": {
      "subagent_type": "pge-planner",
      "agent_def_path": "{plugin_root}/agents/pge-planner.md"
    },
    "generator": {
      "subagent_type": "pge-generator",
      "agent_def_path": "{plugin_root}/agents/pge-generator.md"
    },
    "evaluator": {
      "subagent_type": "pge-evaluator",
      "agent_def_path": "{plugin_root}/agents/pge-evaluator.md"
    }
  },
  "artifacts": {},
  "verdict": null,
  "route": null,
  "route_reason": null
}
```

### Step 1 — Create Team

Create the team:

```python
TeamCreate(team_name=f"pge-runtime-{run_id}")
```

Spawn exactly:

```python
Agent(subagent_type="pge-planner", team_name=f"pge-runtime-{run_id}", name="planner", prompt=...)
Agent(subagent_type="pge-generator", team_name=f"pge-runtime-{run_id}", name="generator", prompt=...)
Agent(subagent_type="pge-evaluator", team_name=f"pge-runtime-{run_id}", name="evaluator", prompt=...)
```

The spawned teammates must appear as:

```text
@planner
@generator
@evaluator
```

If spawn fails, retry once.

If still failing, stop and write blocker.

Do not continue without all three teammates.

### Step 2 — Planner

Send the upstream plan to `@planner`.

Planner message:

```text
You are @planner in the PGE runtime team.

Produce exactly one bounded round contract for this run.

Inputs:
- run_id: {run_id}
- round_id: round-1
- upstream_plan:
{upstream_plan}

Output must be a markdown artifact with these sections:

# PGE Planner Output

## goal
## in_scope
## out_of_scope
## actual_deliverable
## acceptance_criteria
## verification_path
## required_evidence
## stop_condition
## handoff_seam
## open_questions
## planner_note
## planner_escalation

Rules:
- Do not implement.
- Do not evaluate.
- Do not broaden scope.
- If the input is `test`, preserve the smoke deliverable exactly:
  `.pge-artifacts/pge-smoke.txt` containing exactly `pge smoke`.
```

Persist Planner result to:

```text
.pge-artifacts/{run_id}-planner-output.md
```

Gate:

* file exists
* required sections exist
* `actual_deliverable` exists
* `acceptance_criteria` exists
* `verification_path` exists
* `stop_condition` exists

If gate fails, stop with:

```text
BLOCKER: planner artifact failed structural gate.
```

### Step 3 — Generator

Send Planner artifact to `@generator`.

Generator message:

```text
You are @generator in the PGE runtime team.

Execute the bounded round contract from Planner.

Inputs:
- run_id: {run_id}
- round_id: round-1
- planner_artifact_path: {planner_artifact}
- generator_artifact_path: {generator_artifact}

You must produce the real deliverable.

For smoke test:
- create `.pge-artifacts/pge-smoke.txt`
- content must be exactly:
  pge smoke

Output must be a markdown artifact with these sections:

# PGE Generator Output

## current_task
## boundary
## actual_deliverable
## deliverable_path
## changed_files
## local_verification
### checks_run
### results
### overall_status
## evidence
## known_limits
## non_done_items
## deviations_from_spec
## handoff_status

Rules:
- Produce the actual deliverable through repo work.
- Run the verification path.
- Do not self-approve.
- Do not issue final verdict.
- Do not change the Planner contract.
- Stay inside boundary.
```

Persist Generator result to:

```text
.pge-artifacts/{run_id}-generator-output.md
```

Gate:

* generator artifact exists
* deliverable path is named
* changed files are named
* local verification is present
* evidence is present
* for `test`, `.pge-artifacts/pge-smoke.txt` exists
* for `test`, full file content equals exactly `pge smoke`

If gate fails, stop with:

```text
BLOCKER: generator artifact or smoke deliverable failed gate.
```

### Step 4 — Evaluator

Send Planner + Generator artifacts to `@evaluator`.

Evaluator message:

```text
You are @evaluator in the PGE runtime team.

Independently evaluate Generator output against Planner contract.

Inputs:
- run_id: {run_id}
- round_id: round-1
- planner_artifact_path: {planner_artifact}
- generator_artifact_path: {generator_artifact}
- expected_deliverable_path: .pge-artifacts/pge-smoke.txt for smoke test
- expected_smoke_content: pge smoke for smoke test

Output must be a markdown artifact with these sections:

# PGE Evaluator Verdict

## contract_checked
## deliverable_checked
## evidence_checked
## verification_checked
## findings
## verdict
## route
## route_reason
## required_followup

Allowed verdict:
- PASS
- RETRY
- BLOCK
- ESCALATE

Allowed route:
- converged
- retry
- return_to_planner
- escalate

Rules:
- Verify the actual deliverable.
- For smoke test, read `.pge-artifacts/pge-smoke.txt` and confirm full content equals exactly `pge smoke`.
- Do not trust Generator claims without checking the artifact.
- PASS only if acceptance criteria are satisfied.
- If PASS, route should be `converged`.
```

Persist Evaluator result to:

```text
.pge-artifacts/{run_id}-evaluator-verdict.md
```

Gate:

* evaluator artifact exists
* verdict exists
* route exists
* route_reason exists
* findings exist
* for PASS, route is `converged`

If gate fails, stop with:

```text
BLOCKER: evaluator artifact failed route gate.
```

### Step 5 — Route

`main` reads Evaluator artifact and records final route.

Supported terminal route for this stage:

```text
converged
```

If route is:

```text
retry
return_to_planner
escalate
```

write checkpoint and stop.

Do not automatically redispatch in this stage.

### Step 6 — Summary

Write:

```text
.pge-artifacts/{run_id}-round-summary.md
```

Summary must include:

```md
# PGE Round Summary

## run_id
## round_id
## team_name
## teammates
## agent_definitions
## artifacts
## verdict
## route
## route_reason
## smoke_result
```

For `agent_definitions`, include:

```md
| teammate | subagent_type | path | sha256_or_mtime_size |
|---|---|---|---|
| planner | pge-planner | {plugin_root}/agents/pge-planner.md | ... |
| generator | pge-generator | {plugin_root}/agents/pge-generator.md | ... |
| evaluator | pge-evaluator | {plugin_root}/agents/pge-evaluator.md | ... |
```

### Step 7 — Teardown

Send shutdown messages:

```python
SendMessage(to="planner", message={"type": "shutdown_request", "run_id": run_id})
SendMessage(to="generator", message={"type": "shutdown_request", "run_id": run_id})
SendMessage(to="evaluator", message={"type": "shutdown_request", "run_id": run_id})
TeamDelete(team_name=f"pge-runtime-{run_id}")
```

Write final runtime state with:

```json
{
  "state": "complete",
  "verdict": "PASS",
  "route": "converged"
}
```

If shutdown fails after the round completed, report it as teardown warning, not as execution failure.

## Smoke Completion Criteria

For `pge-execute test`, success requires:

1. Team was created.
2. Exactly three teammates were spawned:

   * planner
   * generator
   * evaluator
3. The teammates used these subagent types:

   * pge-planner
   * pge-generator
   * pge-evaluator
4. The agent definition files existed under the active plugin root:

   * `{plugin_root}/agents/pge-planner.md`
   * `{plugin_root}/agents/pge-generator.md`
   * `{plugin_root}/agents/pge-evaluator.md`
5. Planner artifact was written.
6. Generator artifact was written.
7. Evaluator artifact was written.
8. Runtime state was written.
9. Summary was written.
10. `.pge-artifacts/pge-smoke.txt` exists.
11. `.pge-artifacts/pge-smoke.txt` content is exactly:

    ```text
    pge smoke
    ```
12. Evaluator verdict is `PASS`.
13. Route is `converged`.
14. Team was shut down.

## Forbidden Fallbacks

Do not do any of these:

* use direct Agent calls without `team_name`
* read agent definition files and imitate them instead of using Team execution
* spawn temporary task-specific P/G/E groups
* claim Agent Teams were used without TeamCreate
* claim success without SendMessage dispatch
* claim success without teammate artifacts
* claim success without `.pge-artifacts/pge-smoke.txt`
* broaden smoke into architecture/design work
* implement multi-round retry
* edit unrelated docs

## Final Response

When done, report only:

```md
## PGE Execute Result

- status:
- run_id:
- team_name:
- teammates:
  - planner: pge-planner
  - generator: pge-generator
  - evaluator: pge-evaluator
- agent_definitions:
  - {plugin_root}/agents/pge-planner.md: <sha256_or_mtime_size>
  - {plugin_root}/agents/pge-generator.md: <sha256_or_mtime_size>
  - {plugin_root}/agents/pge-evaluator.md: <sha256_or_mtime_size>
- artifacts:
  - planner:
  - generator:
  - evaluator:
  - runtime_state:
  - summary:
  - team_log:
  - deliverable:
- verdict:
- route:
- changed_files:
- blocker:
```

If not complete, `status` must be `BLOCKED`, and `blocker` must be the single concrete blocker.
