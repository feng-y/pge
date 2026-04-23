---
name: pge-execute
description: Use this skill when bounded repo-internal work needs one explicit Planner → Generator → Evaluator execution round with clear acceptance gates.
version: 0.1.2
argument-hint: "<upstream-plan | path | test>"
allowed-tools:
  - Agent
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

<objective>
Run one real PGE execution round by dispatching the installed `pge-planner`, `pge-generator`, and `pge-evaluator` agents.

`main` lives here as skill-internal orchestration logic only: runtime state, artifact persistence, preflight, routing, recovery records, and bounded run control.

Use `skills/pge-execute/ORCHESTRATION.md` as the operational seam for that orchestration behavior.
</objective>

<scope>
- Single repo-internal round only.
- No external tasks.
- No automatic multi-round redispatch in the current stage.
- Runtime-team architecture remains the target control-plane shape, but this skill only executes the bounded single-round path.
- Use the installed runtime-facing agent names exactly: `pge-planner`, `pge-generator`, `pge-evaluator`.
- Runtime state must be isolated per run and keyed by `run_id`.
- Follow `skills/pge-execute/ORCHESTRATION.md` plus `skills/pge-execute/contracts/*` for execution behavior.
</scope>

<argument_handling>
Use the final `ARGUMENTS:` block attached to this skill invocation.

Accepted forms:
1. `test`
2. a readable file path containing an upstream plan
3. inline upstream plan text that already includes the required entry fields

If the argument is `test`, use this fixed upstream plan exactly:

```yaml
goal: Create `.pge-artifacts/pge-smoke.txt` containing exactly `pge smoke`
boundary: Only create `.pge-artifacts/pge-smoke.txt`
deliverable: `.pge-artifacts/pge-smoke.txt` with exact content `pge smoke`
verification_path: Verify the file exists and its full contents equal `pge smoke`
run_stop_condition: single_round
```

If the input is not `test` and does not provide a concrete goal, boundary, deliverable, verification path, and explicit `run_stop_condition`, stop and ask for an execute-first upstream plan instead of guessing.
</argument_handling>

<runtime_files>
Use the current working directory as `repo_root`.

Create and use:
- `artifact_dir = {repo_root}/.pge-artifacts`
- `run_id = run-<unix-timestamp-ms>`
- `round_id = round-1`
- `planner_artifact = {artifact_dir}/{run_id}-planner-output.md`
- `generator_artifact = {artifact_dir}/{run_id}-generator-output.md`
- `evaluator_artifact = {artifact_dir}/{run_id}-evaluator-verdict.md`
- `summary_artifact = {artifact_dir}/{run_id}-round-summary.md`
- `runtime_state = {artifact_dir}/{run_id}-runtime-state.json`
- `checkpoint_artifact = {artifact_dir}/{run_id}-checkpoint.json`
</runtime_files>

<process>
Execute one bounded round exactly as defined in:
- `skills/pge-execute/ORCHESTRATION.md`
- `skills/pge-execute/contracts/entry-contract.md`
- `skills/pge-execute/contracts/round-contract.md`
- `skills/pge-execute/contracts/evaluation-contract.md`
- `skills/pge-execute/contracts/runtime-state-contract.md`
- `skills/pge-execute/contracts/routing-contract.md`

For the current stage, follow the minimal runtime team lifecycle in `skills/pge-execute/ORCHESTRATION.md`:
- `bootstrap`
- `dispatch`
- `handoff`
- `teardown`

At the end of the round, report the `run_id`, verdict, route, and artifact paths.
</process>

<constraints>
- `main` is skill-internal orchestration logic, not an agent seam.
- Use the installed agents directly through the Agent tool. Do not read `agents/*.md` and simulate them.
- Keep the run bounded to one round.
- Do not broaden scope beyond the accepted upstream plan.
- If a required artifact or tool result is missing or malformed, stop and report the blocker instead of repairing it by guesswork.
- Do not write repo-global runtime state for this flow; each run must persist its own runtime state file under `.pge-artifacts/` keyed by `run_id`.
- Planner and Evaluator are read-only agents in this repo. Persist their returned markdown artifacts from the main session.
</constraints>
