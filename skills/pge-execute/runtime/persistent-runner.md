# PGE Persistent Runner

## Purpose

Define how PGE can run for longer than one phase while remaining recoverable, bounded, and honest about unsupported routes.

The current executable runtime is still one implementation round. This document defines the persistence model needed for future retry, return-to-planner, and continue loops.

## Current Runtime Invariants

- The current executable runtime is still a single implementation round.
- `retry`, `continue`, and `return_to_planner` have communication and persistence models, but automatic redispatch is not implemented yet.
- Durable truth is `state_artifact`, `progress_artifact`, and phase artifacts. Chat history is not durable state.
- If a team is lost, future recovery must recreate a same-role team from artifacts instead of relying on old conversational context.

## Persistence Model

The durable source of truth is the artifact set:

- `state_artifact`: machine-readable state and route
- `progress_artifact`: human-readable phase/status view
- phase artifacts: planner, preflight, generator, evaluator
- actual deliverables

Chat history is not durable state.

## Required Persistent Fields

Future persistent runtime state should extend the current state with:

```json
{
  "run_id": "<run_id>",
  "round_id": 1,
  "attempt_id": 1,
  "preflight_attempt_id": 1,
  "max_rounds": 5,
  "max_attempts_per_round": 3,
  "max_preflight_attempts": 2,
  "state": "<state>",
  "team_name": "<team_name>",
  "team_status": "active",
  "active_phase": "<phase>",
  "run_stop_condition": "single_round",
  "active_round_contract_ref": "<planner_artifact>",
  "latest_generator_ref": "<generator_artifact>",
  "latest_evaluator_ref": "<evaluator_artifact>",
  "latest_route": null,
  "route_reason": null,
  "artifact_refs": {},
  "error_or_blocker": null
}
```

## Artifact-Guided Round Shape

Long-running PGE should stay closer to an artifact-guided workflow than a chat-driven workflow:

- Planner artifact is the current round's proposal/spec/design/task frame.
- Preflight artifact freezes whether that frame is executable and independently testable.
- Generator artifact records implementation, evidence, and self-review for one attempt.
- Evaluator artifact records independent acceptance, next route, and required observable fixes.
- Summary artifact archives the run outcome before teardown.

The current executable runtime still produces only one round. These fields and artifacts are the minimum shape needed before automatic redispatch can be implemented truthfully.

## Long-Running State Machine

```text
initialized
  -> team_created
  -> planning
  -> preflight_pending
  -> ready_to_generate
  -> generating
  -> evaluating
  -> routing
  -> converged
```

Future redispatch transitions:

```text
preflight_pending + proposal repair
  -> preflight_pending(preflight_attempt_id + 1)

routing + retry
  -> generating(attempt_id + 1)

routing + return_to_planner
  -> planning(round_id + 1)

routing + continue
  -> planning(round_id + 1)
```

Stop transitions:

```text
routing + unsupported canonical route -> unsupported_route
gate failure -> failed
max attempts exceeded -> failed or stopped
team unavailable with recoverable artifacts -> stopped
```

## Recovery Protocol

To resume a run:

1. Read `state_artifact`.
2. Read `progress_artifact`.
3. Verify `artifact_refs` point to existing files.
4. Re-run the gate for the latest completed artifact.
5. Continue from the next incomplete phase.
6. If the team no longer exists, recreate exactly one team with the same role names and continue from artifacts.
7. Never infer completion from chat logs.

Recovery examples:

- State is `planning`, planner artifact missing: redispatch Planner.
- State is `planning`, planner artifact exists and gates pass: advance to preflight.
- State is `generating`, generator artifact missing: redispatch Generator with the same inputs.
- State is `evaluating`, evaluator artifact exists and gates pass: route.
- State is `unsupported_route`: do not redispatch unless the corresponding route loop is implemented.

## Heartbeat And Timeout

Main should use bounded waits for artifact handoff.

On timeout:

1. Send a status request to the active teammate.
2. Continue waiting for a short bounded interval.
3. If still missing, record timeout in `progress_artifact`.
4. Mark state `stopped` unless the phase can be safely redispatched from artifacts.

Timeouts must not be converted into PASS or convergence.

## Loop Limits

Persistent routes need hard caps:

- max preflight proposal repairs: 2
- max generator attempts per round: 3
- max rounds per run: 5 by default

At the cap:

- write the latest blocker
- preserve all artifacts
- set route/state honestly
- tear down or stop cleanly

## Team Lifecycle

Default lifecycle:

1. create team at run start
2. keep all three teammates alive through the run
3. use artifacts to avoid context dependence
4. send shutdown requests after terminal route
5. delete team

If long-running context quality degrades, prefer recreating the team from artifacts instead of relying on old chat context.

## Completion Gate

A persistent run is complete only when:

- Evaluator returns `PASS`
- `next_route` is `converged`
- `state_artifact` is written with `state = "converged"`
- `summary_artifact` exists
- `progress_artifact` marks terminal status
- teardown has been attempted and recorded
