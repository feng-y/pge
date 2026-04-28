---
name: pge-execute
description: Run one bounded PGE execution using a real Claude Code Agent Team (planner, generator, evaluator) with file-backed artifacts.
version: 0.4.0
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

This skill is the orchestration shell only. It is not a fourth agent.

## Progressive Disclosure

Keep this entrypoint small. Load detail files only when the phase needs them:

- Runtime artifacts/state/progress: `runtime/artifacts-and-state.md`
- Persistent runner model: `runtime/persistent-runner.md`
- Planner handoff: `handoffs/planner.md`
- Contract preflight: `handoffs/preflight.md`
- Generator handoff: `handoffs/generator.md`
- Evaluator handoff: `handoffs/evaluator.md`
- Route, summary, teardown: `handoffs/route-summary-teardown.md`
- Contracts: `contracts/*.md` relative to this skill (authoritative for this skill)
- Minimal lifecycle reference: `ORCHESTRATION.md`

Design references live outside the skill at `docs/design/pge-execute/`; consult them when changing the skill, not during every normal run.

## Current Executable Claim

Current goal: make `/pge-execute test` run end-to-end with the smallest honest closed loop.

Supported now:

- one Team
- exactly three teammates: planner, generator, evaluator
- file-backed handoffs
- Planner contract
- Generator/Evaluator preflight gate
- one implementation round
- independent final evaluation
- explicit `unsupported_route` for recognized routes that are not yet redispatched
- per-run progress artifact

Not supported yet:

- automatic multi-round redispatch
- bounded retry loop
- return-to-planner loop
- product/spec planner split
- evaluator calibration fixtures

## Execution Flow

```text
User invokes /pge-execute
  -> pge-execute orchestrator skill
     -> initialize input/state/progress artifacts
     -> create one per-run resident team
        - teammate `planner` runs agent surface `pge-planner`
        - teammate `generator` runs agent surface `pge-generator`
        - teammate `evaluator` runs agent surface `pge-evaluator`
     -> planner phase resource writes bounded round contract
     -> preflight phase resource asks generator for proposal, evaluator for review
     -> generator phase resource allows repo edits only after preflight PASS
     -> evaluator phase resource checks the actual deliverable independently
     -> route/summary/teardown phase records outcome and deletes the team
```

The orchestrator routes from file artifacts. Agents do role work. Phase resources define the dispatch text, schemas, and gates.

## Hard Requirements

- Use Claude Code native Agent Teams.
- Create exactly one team for the run.
- Spawn exactly three teammates:
  - `planner` using `pge-planner`
  - `generator` using `pge-generator`
  - `evaluator` using `pge-evaluator`
- Dispatch work through `SendMessage`.
- Use file-backed handoff.
- Maintain `progress_artifact` for the run.
- Do not simulate Planner / Generator / Evaluator in `main`.
- Do not fall back to direct non-team Agent dispatch.
- Do not require the user to pass a plan path.
- Do not let Generator edit files before preflight passes.
- Do not claim redispatch for `continue`, `retry`, or `return_to_planner`.

If TeamCreate / Agent with `team_name` / SendMessage / TeamDelete cannot be used, stop immediately and report one concrete blocker.

## Accepted Inputs

Read the final `ARGUMENTS:` block for this skill invocation.

Supported inputs:

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

## Execution Protocol

Before executing, read `runtime/artifacts-and-state.md` and `ORCHESTRATION.md`.
For long-running or resumable behavior, also read `runtime/persistent-runner.md`.

1. Initialize
   - resolve task input
   - write `input_artifact`
   - write initial `state_artifact`
   - write initial `progress_artifact`
   - verify the runtime can resolve the `pge-planner`, `pge-generator`, and `pge-evaluator` agent surfaces

2. Create team
   - `TeamCreate(team_name=team_name, description="PGE runtime team")`
   - spawn teammate `planner` using `pge-planner`
   - spawn teammate `generator` using `pge-generator`
   - spawn teammate `evaluator` using `pge-evaluator`
   - set `team_created = true`
   - update state and progress

3. Planner
   - read `handoffs/planner.md`
   - send work to planner
   - wait for `planner_artifact`
   - gate the artifact
   - update state and progress

4. Contract preflight
   - read `handoffs/preflight.md`
   - send proposal task to generator
   - wait for `contract_proposal_artifact`
   - send preflight review to evaluator
   - wait for `preflight_artifact`
   - gate the artifacts
   - allow bounded proposal repair attempts before any repo edits
   - continue only on `PASS + ready_to_generate`

5. Generator
   - read `handoffs/generator.md`
   - send implementation task to generator
   - wait for `generator_artifact`
   - gate the artifact and actual deliverable
   - update state and progress

6. Evaluator
   - read `handoffs/evaluator.md`
   - send evaluation task to evaluator
   - wait for `evaluator_artifact`
   - gate the artifact and final verdict
   - update state and progress

7. Route, summary, teardown
   - read `handoffs/route-summary-teardown.md`
   - route from Evaluator verdict and next_route
   - write summary
   - request teammate shutdown
   - delete team
   - update progress

## Final Response

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
  - <contract_proposal_artifact>
  - <preflight_artifact>
  - <generator_artifact>
  - <evaluator_artifact>
  - <state_artifact>
  - <summary_artifact>
  - <progress_artifact>
  - .pge-artifacts/pge-smoke.txt
- blocker: <single concrete blocker or null>
```

## Forbidden Behavior

Do not:

- require `--plan`
- require a plan path from the user
- simulate agents in `main`
- replace Team flow with direct role-play
- auto-retry multiple rounds
- bury phase progress only in chat; update progress artifacts
- stop before waiting for the dispatched teammate artifact handoff
- accept `test` without the evaluator independently reading `.pge-artifacts/pge-smoke.txt`
