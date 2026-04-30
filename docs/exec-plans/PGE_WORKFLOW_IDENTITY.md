# PGE Workflow Identity

## Purpose

This document defines what `PGE` is as a workflow product.

It does not define low-level runtime mechanics.
It defines:

- what kind of workflow PGE is
- when PGE should be used
- when PGE should not be used
- the fixed execution skeleton
- the role boundaries
- the protocol boundaries
- how PGE differs from peer workflows such as `gstack` and `superpowers`

If PGE is not clear at this level, runtime refinements will continue to drift.

## Core Definition

PGE is a **small, end-to-end development workflow** built around three roles:

- `planner`
- `generator`
- `evaluator`

It is not:

- a generic intent-discovery system
- a product brainstorming framework
- a giant project management workflow
- a general-purpose agent operating system

PGE's core promise is:

> take one bounded task, run it through `planner -> generator -> evaluator`, and return a result with explicit artifacts and explicit validation.

## Workflow Class

PGE belongs to the same class of system as:

- `gstack`
- `superpowers`

These are peers, not parent/child systems.

Each is a small workflow product with its own:

- trigger conditions
- role model
- execution philosophy
- observability style
- verification style

PGE should be judged as an independent workflow on those terms.

## What PGE Is For

PGE is for tasks that need:

- a bounded contract before execution
- a real deliverable
- independent final validation
- explicit artifact visibility

Good fits:

- a bounded code change
- a focused refactor
- a docs or config task where scope needs freezing
- a repo-internal proving task
- a real development task where "do the change, then independently check it" is the right loop

## What PGE Is Not For

PGE is not the best default for:

- raw product ideation
- ambiguous founder brainstorming
- multi-week roadmap planning
- giant multi-stream project coordination
- tasks so trivial they should be done inline with no role overhead

Those may be better served by peer workflows.

## Trigger Condition

PGE should start only when the task is already bounded enough that:

- `planner` can freeze one executable task
- `generator` can execute without guessing too much
- `evaluator` can validate independently

If the input is still vague at the "what are we even building?" level, PGE is the wrong workflow entrypoint.

## Fixed Workflow Skeleton

PGE's fixed skeleton is:

```text
input
  -> planner
  -> generator
  -> evaluator
  -> result
```

Expanded form:

```text
input
  -> main initializes run
  -> planner defines one task contract
  -> main gates planner artifact
  -> generator executes the task
  -> main gates deliverable / generator output
  -> evaluator performs independent final review
  -> main gates evaluator artifact
  -> main reduces verdict + route
  -> main tears down
  -> final result
```

The primary skeleton does not change per task.

Task complexity should change:

- how much work `planner` does
- how much work `generator` does
- how much depth `evaluator` uses

Task complexity should **not** create ad-hoc extra stages by default.

## Role Matrix

| Role | Owns | Inputs | Outputs | Must not own |
| --- | --- | --- | --- | --- |
| `planner` | task contract | task input, minimal repo context | planner artifact, planner event | implementation, final verdict, route, teardown |
| `generator` | real deliverable + local evidence | planner artifact, repo context | deliverable, optional generator artifact, generator event | final approval, route, teardown |
| `evaluator` | independent final validation | planner artifact, deliverable, optional generator artifact | evaluator artifact, final verdict event | implementation, replanning, teardown |
| `main` | orchestration and deterministic closure | events, artifacts, task input | dispatches, gate decisions, route result, teardown, final result, progress log | planner/generator/evaluator role work |

## Main's Identity

`main` is:

- orchestrator
- event consumer
- artifact gatekeeper
- deterministic route reducer
- deterministic teardown caller
- progress appender

`main` is not:

- a fourth worker
- a hidden planner
- a hidden evaluator
- a freeform state machine narrator

## Protocol Boundaries

PGE should have a small protocol surface.

### Canonical teammate events

- `planner_contract_ready`
- `generator_completion`
- `final_verdict`

### Canonical `main` event

- `route_selected`

### Non-authoritative chatter

These must not drive progression:

- `idle_notification`
- natural-language "task complete" messages
- progress-log entries
- artifact existence without matching event

## Artifact Boundaries

Current workflow-visible artifacts:

- `input_artifact`
- `planner_artifact`
- optional `generator_artifact`
- `evaluator_artifact`
- `progress_artifact`
- optional `summary_artifact`
- real deliverable(s)

Artifacts exist to make the workflow inspectable.
They should not create fake extra stages.

## Verification Philosophy

PGE should be explicit about two different checks:

1. **Generator local verification**
   - confidence-building
   - never final approval

2. **Evaluator independent verification**
   - final approval gate
   - independent from generator claims

This separation is essential to PGE's identity.

## Progress / Logging Philosophy

`progress` exists for:

- observability
- friction analysis
- later workflow iteration

It does not exist to:

- drive execution
- replace role outputs
- act as a state machine

PGE should prefer:

- append-only
- timestamped
- schema-fixed
- weak-dependency logging

## Result Semantics

PGE must return explicit result semantics.

At minimum:

- `verdict`
- `route`
- final `status`

These must not contradict each other.

Example invariant:

- `SUCCESS` is valid only when the workflow has reached a terminal accepted route

The workflow must never present a "successful but still continuing" result.

## How PGE Differs From gstack

PGE differs from `gstack` in emphasis:

- PGE is a tighter three-role execution loop
- gstack is a larger family of specialized workflows
- gstack emphasizes workflow selection and toolchain breadth
- PGE emphasizes one explicit plan/develop/review loop

Learning from gstack:

- keep orchestrator lean
- stratify workflow thickness
- make observability first-class

## How PGE Differs From superpowers

PGE differs from `superpowers` in emphasis:

- PGE is a concrete execution workflow
- superpowers is more skill-first and process-discipline oriented
- superpowers is strong on entry clarity and composable guidance
- PGE must be strong on runtime role clarity and execution closure

Learning from superpowers:

- define entry conditions clearly
- keep workflow identity crisp
- reduce process slop

## What PGE Must Get Right To Be Coherent

For PGE to make sense as an independent workflow, these must become stable:

1. fixed skeleton
2. sharp role ownership
3. small event protocol
4. deterministic route reduction
5. deterministic teardown
6. progress as observability only

If these are unstable, PGE is not a workflow.
It is just a pile of prompts.

## Near-Term Improvement Priorities

1. Stabilize protocol
   - event shape
   - message shape
   - route/status invariants

2. Stabilize deterministic closure
   - route reduction
   - teardown
   - final result mapping

3. Stabilize observability
   - progress schema
   - timestamps
   - measurable gaps

4. Validate on real tasks
   - planner depth
   - generator/evaluator wait chain
   - closure correctness

## Bottom Line

PGE should be understood as:

> an independent, bounded, end-to-end development workflow centered on `planner -> generator -> evaluator`, with a thin `main` orchestrator and explicit artifact-driven validation.

That identity should stay fixed while the runtime gets less brittle.
