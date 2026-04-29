---
name: pge-execute
description: Run one bounded PGE execution using a real Claude Code Agent Team (planner, generator, evaluator) with messaging-first coordination and durable phase artifacts.
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
- Runtime events: `contracts/runtime-event-contract.md`
- Contracts: `contracts/*.md` relative to this skill (authoritative for this skill)
- Minimal lifecycle reference: `ORCHESTRATION.md`
Design references live outside the skill at `docs/design/pge-execute/`; consult them when changing the skill, not during every normal run.

## Current Executable Claim
Supported in the current implementation lane:
- one Team
- exactly three teammates: planner, generator, evaluator
- messaging-first coordination for normal preflight interaction
- durable phase outputs instead of turn-by-turn file churn
- one bounded run with mode-aware closure (`FAST_PATH`, `LITE_PGE`, `FULL_PGE`)
- independent final evaluation
- explicit `unsupported_route` for recognized routes that are not yet redispatched
- progress artifact only when the chosen mode requires it

Not supported yet:
- automatic multi-round redispatch
- bounded retry loop
- return-to-planner loop
- product/spec planner split
- evaluator calibration fixtures
- full `LONG_RUNNING_PGE` execution

## Execution Flow
```text
User invokes /pge-execute
  -> pge-execute orchestrator skill
     -> initialize input/state artifacts
     -> create one per-run resident team
        - teammate `planner` runs agent surface `pge-planner`
        - teammate `generator` runs agent surface `pge-generator`
        - teammate `evaluator` runs agent surface `pge-evaluator`
     -> planner writes locked task-shape contract
     -> evaluator decides mode/fast finish; generator/evaluator negotiate only when mode requires it
     -> orchestrator executes the chosen bounded path
     -> evaluator phase resource checks the actual deliverable independently
     -> route/summary/teardown phase records outcome and deletes the team
```

The orchestrator advances from runtime events and then validates any referenced durable side effects. Agents do role work. Phase resources define the dispatch text, event schemas, and artifact gates.

## Hard Requirements
- Use Claude Code native Agent Teams.
- Create exactly one team for the run.
- Spawn exactly three teammates:
  - `planner` using `pge-planner`
  - `generator` using `pge-generator`
  - `evaluator` using `pge-evaluator`
- Dispatch work through `SendMessage`.
- Use messaging-first coordination for normal preflight interaction.
- Use files only for durable phase outputs and runtime state.
- Maintain `progress_artifact` only when the chosen mode requires it.
- Do not simulate Planner / Generator / Evaluator in `main`.
- Do not fall back to direct non-team Agent dispatch.
- Do not require the user to pass a plan path.
- Do not let Generator edit files before preflight passes.
- Do not give Planner authority to decide fast finish or final execution mode.
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
Before executing, read `runtime/artifacts-and-state.md`, `ORCHESTRATION.md`, and `contracts/runtime-event-contract.md`. For long-running or resumable behavior, also read `runtime/persistent-runner.md`.

1. Initialize
   - resolve task input
   - write `input_artifact`
   - write initial `state_artifact` with `mode = null`; do not default to `FULL_PGE`
   - do not initialize `progress_artifact` until mode requires it
   - verify the runtime can resolve the `pge-planner`, `pge-generator`, and `pge-evaluator` agent surfaces

2. Create team
   - `TeamCreate(team_name=team_name, description="PGE runtime team")`
   - spawn teammate `planner` using `pge-planner`
   - spawn teammate `generator` using `pge-generator`
   - spawn teammate `evaluator` using `pge-evaluator`
   - set `team_created = true`
   - update state; update progress only when enabled

3. Planner
   - read `handoffs/planner.md`
   - send work to planner
   - wait for `type: planner_contract_ready`
   - gate `planner_artifact`
   - update state; update progress only when enabled

4. Contract preflight
   - read `handoffs/preflight.md`
   - ask Evaluator for the execution-mode cost gate from the Planner contract
   - for deterministic `FAST_PATH`, accept only a `type: mode_decision` message and do not write proposal/preflight artifacts
   - for `LITE_PGE` / `FULL_PGE`, send proposal task to Generator and negotiate through `SendMessage`
   - wait for Evaluator's final preflight decision before Generator edits files
   - persist durable preflight outputs only when the matching event says they are required
   - gate the durable outputs referenced by the event
   - allow bounded proposal repair attempts before any repo edits
   - continue only on `PASS + ready_to_generate`

5. Execute chosen path
   - `FAST_PATH`: minimal artifacts + deterministic check + final Evaluator approval
   - `LITE_PGE`: reduced artifact surface + final Evaluator approval
   - `FULL_PGE`: full bounded flow
   - `LONG_RUNNING_PGE`: record unsupported path; do not pretend later phases already exist

6. Generator
   - read `handoffs/generator.md`
   - send implementation task to generator
   - wait for `type: generator_completion` in `FAST_PATH`; wait for `generator_artifact` only when mode requires it
   - gate the deliverable and any required durable generator output
   - update state and progress when enabled

7. Evaluator
   - read `handoffs/evaluator.md`
   - send evaluation task to evaluator
   - wait for `type: final_verdict`
   - gate `evaluator_artifact` and final verdict
   - update state and progress when enabled

8. Route, summary, teardown
   - read `handoffs/route-summary-teardown.md`
   - route from Evaluator verdict and next_route
   - write summary only when the chosen mode requires it
   - request teammate shutdown
   - delete team
   - update progress when enabled

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
    - <contract_proposal_artifact if written>
    - <preflight_artifact if written>
    - <generator_artifact if written>
    - <evaluator_artifact>
    - <state_artifact>
    - <summary_artifact if written>
    - <progress_artifact if written>
    - <deliverable if produced>
- blocker: <single concrete blocker or null>
```

## Forbidden Behavior

Do not:

- require `--plan`
- require a plan path from the user
- simulate agents in `main`
- replace Team flow with direct role-play
- use artifact files as the turn-by-turn preflight message bus
- advance from shell polling or mailbox file existence instead of a valid runtime event
- auto-retry multiple rounds
- bury phase progress only in chat; update progress artifacts
- stop before waiting for the dispatched teammate artifact handoff
- accept `test` without the evaluator independently reading `.pge-artifacts/pge-smoke.txt`
