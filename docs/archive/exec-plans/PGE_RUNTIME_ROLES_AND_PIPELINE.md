# PGE Runtime Roles And Pipeline

## Purpose

This document is the execution-layer truth surface for PGE runtime behavior.

It answers five questions directly:

1. What is the fixed pipeline?
2. Which roles exist?
3. What does each role own?
4. What does each role consume and produce?
5. Which parts must be deterministic instead of prompt-interpreted?

If any prompt, handoff, or historical design doc disagrees with this file, this file wins for execution-layer reasoning.

## Fixed Pipeline

All real tasks use the same primary skeleton:

```text
user task / upstream intent
  -> main initializes run
  -> planner defines task contract
  -> main gates planner artifact
  -> generator reviews and executes contract
  -> main gates deliverable / generator output
  -> evaluator performs independent final review
  -> main gates evaluator artifact
  -> deterministic route reduction
  -> deterministic teardown
  -> final result returned
```

Important:

- Task complexity changes role depth, not the primary skeleton.
- Real tasks do not gain extra runtime stages by default.
- Preflight, retry, return-to-planner, and resume are future lanes, not current required stages.

## Flow Diagram

### Main runtime flow

```text
user / upstream task
  |
  v
main: initialize run
  - create input artifact
  - create / append progress log
  - create one team
  |
  v
planner
  - read task input
  - gather evidence
  - compare cuts when needed
  - produce planner artifact
  - emit planner_contract_ready
  |
  v
main gate
  - validate planner artifact
  - dispatch generator
  |
  v
generator
  - review contract for executability
  - execute contract
  - produce deliverable
  - optionally produce generator artifact
  - emit generator_completion
  |
  v
main gate
  - validate deliverable / generator output
  - dispatch evaluator
  |
  v
evaluator
  - independently inspect deliverable
  - produce evaluator artifact
  - emit final_verdict
  |
  v
main gate
  - validate evaluator artifact
  - deterministic route reduction
  - deterministic teardown
  - final result
```

### Role interaction flow

```text
main ----dispatch----> planner
main <-----event------ planner

main ----dispatch----> generator
main <-----event------ generator

main ----dispatch----> evaluator
main <-----event------ evaluator

main ----shutdown----> planner
main ----shutdown----> generator
main ----shutdown----> evaluator

main ----delete team----> runtime
```

## Role Inventory

There are exactly four execution-layer surfaces:

- `main`
- `planner`
- `generator`
- `evaluator`

`main` is orchestration only. It is not a peer worker.

## Role Matrix

| Surface | Owns | Must not own |
| --- | --- | --- |
| `main` | run initialization, dispatch, correction, exception handling, artifact gating, deterministic route/status mapping, deterministic teardown, progress append | planning, implementation, final quality judgment |
| `planner` | evidence gathering, task contract, scope boundary, acceptance criteria, verification path, required evidence, stop condition | implementation, final verdict, route, teardown |
| `generator` | contract executability review, real deliverable, local verification evidence, honest limits/deviations, integration review | final approval, route, teardown |
| `evaluator` | independent final validation, verdict, next_route signal | implementation, replanning, teardown |

## Per-Role Contract

### Main

**Inputs**
- user task / skill arguments
- runtime events
- planner / generator / evaluator artifacts

**Outputs**
- dispatches to teammates
- repair / correction decisions
- deterministic gate results
- deterministic route result
- deterministic teardown call
- final result block
- append-only progress log entries

**Core rule**
- `main` may orchestrate and reduce.
- `main` must not reinterpret task semantics that belong to planner/generator/evaluator.
- `main` is the run-level scheduler, corrector, and quality-governance owner, not a fourth expert worker.
- `main` is the only authoritative writer of progress/friction logs.

### Planner

**Inputs**
- task input
- minimal repo context when needed

**Outputs**
- `planner_artifact`
- `planner_contract_ready` event

**Core rule**
- Planner acts as researcher + architect + planner for one bounded round.
- Planner defines the task contract only.
- Planner does not choose verdict, route, or teardown behavior.

### Generator

**Inputs**
- planner artifact
- directly relevant repo context

**Outputs**
- real deliverable
- optional `generator_artifact`
- `generator_completion` event

**Core rule**
- Generator reviews the locked contract, completes the task, and provides evidence.
- Generator does not declare final success.

## Main consumption of `generator_plan_review`

When Generator writes a durable artifact, `main` must inspect the explicit `generator_plan_review` block inside `## self_review`.

Use this reduction:

- `review_verdict = BLOCK` -> do not dispatch Evaluator; record blocked result and blocker
- `review_verdict = PASS` + material `missing_prerequisites` / `repair_direction` -> stop and record blocked result
- `review_verdict = PASS` + non-blocking `scope_risk` / `known_limits` -> record friction and continue to Evaluator
- no durable Generator artifact -> use the lightweight path; rely on `deliverable_path` and `verification_result`

This keeps executability review explicit without adding a new runtime stage or a new progression event.

## Main consumption of evaluator verdicts

After `main` gates the evaluator artifact, use this reduction:

- `PASS + converged`
  - final success path
  - proceed to deterministic teardown

- `PASS + continue`
  - accepted current round, but non-terminal route
  - record canonical route and stop at `unsupported_route` in the current stage

- `RETRY`
  - treat as execution-level non-acceptance
  - record required fixes and friction
  - stop at `unsupported_route`

- `BLOCK`
  - if the evaluator still treats the current contract as fair, classify as execution blocker
  - if the evaluator indicates the contract is no longer a fair repair frame, classify as contract blocker
  - in both cases, stop at `unsupported_route` in the current stage

- `ESCALATE`
  - classify as contract-level failure signal
  - record escalation reason
  - stop at `unsupported_route`

`main` may reduce route/state/logging consequences.
`main` must not reinterpret the evaluator verdict into a different acceptance judgment.

### Evaluator

**Inputs**
- planner artifact
- real deliverable
- optional generator artifact

**Outputs**
- `evaluator_artifact`
- `final_verdict` event

**Core rule**
- Evaluator is the only final approval gate.
- Evaluator does not own route reduction or teardown.

## Runtime Events

Current executable lane requires only these teammate events:

- `planner_contract_ready`
- `generator_completion`
- `final_verdict`

`main` may additionally emit:

- `route_selected`

Anything else is non-authoritative chatter.

In particular:

- `idle_notification` is not a progression event
- natural-language summaries are not progression events
- progress-log lines are not progression events

## Artifact Chain

Current lane artifacts:

- `input_artifact`
- `planner_artifact`
- optional `generator_artifact`
- `evaluator_artifact`
- `progress_artifact`
- optional `summary_artifact`
- real deliverable(s)

The artifact chain exists to support inspection, not to invent new workflow stages.

## Deterministic Layer

These parts must be deterministic:

### 1. Event parsing

- `SendMessage.message` must be plain string
- event shape must be parsed mechanically
- object-vs-string ambiguity is not acceptable

### 2. Artifact gating

- section presence and required file checks should be rule-based
- gate result must not depend on freeform interpretation when a fixed check exists

### 3. Route reduction

Examples:

- `PASS + converged => SUCCESS`
- any non-terminal route must not report `SUCCESS`
- task-specific terminal rules must be explicit

### 4. Teardown

- `SendMessage(... shutdown_request ...)` shape must be fixed
- `TeamDelete()` must be zero-argument
- logging and teardown must never be fused into the same tool call

### 5. Progress append

- append-only
- fixed schema
- weak dependency
- not a gate

## Progress Log Schema

Every progress line should use the same core fields:

- `ts`
- `run_id`
- `actor`
- `phase`
- `event`
- `status`
- `artifact`
- `detail`
- `blocker`

Optional:

- `latency_ms`
- `bytes`
- `command`

If a line omits `ts`, it is not useful for performance diagnosis.

## Core Dependencies

The execution layer depends on:

1. Claude Code Agent Teams transport actually delivering teammate messages
2. Teammates emitting plain-string runtime events
3. `main` consuming only canonical events
4. Deterministic route + teardown semantics
5. Progress logging staying off the critical path

## Failure Ownership Matrix

| Failure class | Example | Owner |
| --- | --- | --- |
| Planner failure | unfair contract, unresolved blocking ambiguity, missing evidence basis | `planner` |
| Generator failure | missing deliverable, insufficient execution evidence, silent boundary drift | `generator` |
| Evaluator failure | invalid verdict bundle, missing independent verification, unsupported acceptance reasoning | `evaluator` |
| Protocol failure | invalid event shape, route contradiction, teardown command-shape issue | `main` |
| Runtime failure | TeamCreate / SendMessage / TeamDelete / permission / hook failure | runtime environment, surfaced by `main` |

Use this rule:

- agents repair their own role outputs
- `main` classifies failures, records them, and decides whether the run can continue
- `main` must not rewrite role semantics as a shortcut fix

## Known Failure Modes

The current system has repeatedly shown these failure modes:

- teammate emits event late or event reaches `main` late
- object-shaped `message` passed to `SendMessage`
- `TeamDelete` called with unrelated fields
- `PASS` combined with non-terminal route
- progress written as after-the-fact summary instead of timed event log
- idle messages causing extra orchestration churn

These are execution-layer problems, not task-contract problems.

## MVP Improvement Order

1. Stabilize protocol
   - plain-string events
   - zero-arg `TeamDelete`
   - fixed route/status mapping

2. Stabilize observability
   - canonical progress schema
   - timestamps everywhere
   - gap reporting

3. Thin orchestrator
   - drop non-authoritative chatter from the critical path
   - keep `main` focused on dispatch/gate/reduce/teardown

4. Validate on real tasks
   - planner weight
   - generator/evaluator wait gaps
   - route/result consistency

## What This Means In Practice

When debugging PGE runtime, ask these questions in order:

1. Did the role produce the correct artifact?
2. Did it emit the canonical event?
3. Did `main` receive that event quickly?
4. Did the deterministic gate accept it?
5. Did deterministic route reduction produce a legal result?
6. Did deterministic teardown finish?

If a problem appears before step 3, it is usually a teammate/protocol issue.
If it appears after step 3, it is usually a `main` orchestration issue.
