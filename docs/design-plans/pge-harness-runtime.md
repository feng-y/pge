# PGE Harness Runtime Plan

## Problem

The current PGE repo has already moved beyond a single root prompt, but it is still fundamentally doc-defined.

Today we have:
- `agents/` for responsibility boundaries
- `contracts/` for handoff boundaries
- `skills/pge-execute/SKILL.md` for the current invocation surface
- legacy governance docs such as `phase-contract.md`, `evaluation-gate.md`, and `progress-md.md`

This is enough to describe a loop, but not enough to run one reliably.

The main problems are:
- execution semantics are still prose-only
- state transitions are implied, not normalized
- contract handoff exists conceptually, but not yet as a stable runtime model
- evaluation and routing rules exist, but they are not yet gathered into one top-level runtime design
- the repo can explain PGE, but it cannot yet stably carry `plan -> execution -> evaluation -> routing` across real multi-round work

The current shape is therefore a good structural skeleton, but not yet a harness runtime.

## Goal

Build our own PGE-centered harness runtime.

The goal is not to reproduce Anthropic’s internal harness design, and not to assemble a platform out of unrelated ideas. The goal is to create a runtime layer that is appropriate for our own workflow and that can gradually evolve from the current repo.

The runtime should be able to:
- accept an upstream writing-plan
- reduce that input into one bounded round
- drive generation against a clear round contract
- run independent evaluation against evidence and contract
- route the next state explicitly
- preserve progress and handoff state across rounds
- evolve from a single-skill runtime into a stronger multi-skill runtime later

## Non-goals

This phase should explicitly not do the following:
- copy Anthropic runtime internals
- build a general workflow engine
- introduce a full multi-agent runtime from the start
- create a large state platform before one real loop works
- expand immediately into many skills
- add `runtime/`, `commands/`, or a large execution framework in the same phase
- collapse the runtime back into one large prompt or one root document

The first job is to make one loop stable, not to design a platform.

## Sources of inspiration

### Anthropic

We borrow the main harness axes, not the surface form.

What to take:
- planner / generator / evaluator separation
- independent evaluation instead of self-certification
- contract and artifact handoff as the stabilizing mechanism for long-running work
- the idea that harness structure should remain stable while runtime internals can evolve

What not to take:
- assumptions about Anthropic-specific runtime internals
- assumptions about isolation, concurrency, or orchestration features we do not yet have
- pressure to imitate their implementation details instead of solving our own runtime problem

### superpower

We borrow upstream shaping.

What to take:
- the ability to turn a vague request into a usable writing-plan before execution begins
- the discipline of separating plan formation from bounded execution

Why it matters:
- PGE should not absorb all pre-clarification work into the runtime loop itself
- the runtime becomes more stable if its upstream input is already shaped enough to enter execution

### gsd

We borrow progressive execution discipline.

What to take:
- bounded phase/slice progression
- explicit seams between rounds
- visible state instead of hidden conversational continuity
- the expectation that large work advances through a sequence of stable bounded rounds

Why it matters:
- PGE is not supposed to finish everything in one pass
- it should advance through well-bounded execution slices while keeping the route to the next slice clear

### gstack

We borrow review pressure and routing taste.

What to take:
- independent review posture before or after execution where needed
- clear route outcomes instead of fuzzy completion
- the idea that execution should be surrounded by explicit judgment points

Why it matters:
- routing quality matters as much as generation quality
- without clear route outcomes, the loop turns back into improvised chat

## Runtime model

This document owns **runtime orchestration semantics only**.

It does not redefine the detailed role charters or contract fields already defined in:
- `agents/*.md`
- `contracts/*.md`
- `evaluation-gate.md`
- `progress-md.md`

Those files remain the canonical definition of role and handoff content. This document defines how they run together as one loop.

### Runtime inputs

The runtime accepts an **upstream writing-plan**.

The writing-plan must be shaped enough to enter execution. At minimum it must provide:
- a concrete execution goal
- an identifiable scope boundary
- a plausible deliverable shape
- a minimum verification direction

Fail-fast rule:
- if these conditions are missing, intake fails and the request stays upstream
- PGE runtime should not absorb clarify-first work into the execution loop

This aligns with `contracts/entry-contract.md`.

### Canonical loop

The first runtime should implement one stable control loop:

`writing-plan -> entry check -> planner -> round contract -> generator -> deliverable + evidence -> evaluator -> verdict -> main/router -> next state`

This is the smallest loop that preserves:
- bounded execution
- independent acceptance
- explicit routing
- resumable multi-round state

### v1 state machine

The v1 runtime state machine should be explicit.

States:
- `intake_pending`
- `planning_round`
- `ready_to_generate`
- `generating`
- `awaiting_evaluation`
- `evaluating`
- `routing`
- `converged`
- `failed_upstream`

Allowed transitions:
- `intake_pending -> planning_round`
- `intake_pending -> failed_upstream`
- `planning_round -> ready_to_generate`
- `planning_round -> failed_upstream`
- `ready_to_generate -> generating`
- `generating -> awaiting_evaluation`
- `generating -> routing` when generation escalates instead of producing an acceptable handoff
- `awaiting_evaluation -> evaluating`
- `evaluating -> routing`
- `routing -> planning_round` on `return_to_planner`
- `routing -> generating` on `retry`
- `routing -> planning_round` on `continue` for the next bounded round
- `routing -> converged`

The runtime should reject hidden transitions. If the state changes, the route reason must be recorded.

### Runtime state record

A first runtime does not need a large state system, but it does need one canonical state record.

The canonical state definition now lives in `contracts/runtime-state-contract.md`.

For v1, that contract should remain small enough to operate manually at first, but explicit enough to become runtime-managed later.

### Failure semantics

The first runtime should make failure behavior explicit.

#### Intake failure
- condition: upstream plan fails entry conditions
- route: do not start PGE loop
- state result: `failed_upstream`

#### Planner failure
- condition: planner cannot freeze one bounded round cleanly
- route: `return_to_planner` or upstream failure depending on whether the issue is local ambiguity or invalid intake
- state result: stay in planning lane with recorded reason

#### Generator failure
- condition: generator cannot execute without guessing, or execution cannot produce the named deliverable/evidence handoff
- route: `routing`
- allowed next outcomes: `retry` or `return_to_planner`

#### Evaluator failure
- condition: required evidence is missing, contract is violated, or deviation is unresolved
- route: `routing`
- allowed next outcomes: `retry`, `return_to_planner`, or `converged` only if evaluator passes

#### Router failure
- condition: router cannot explain why the next state follows from the verdict and current state
- rule: this is a runtime design error, not a soft concern
- state result: stop and surface the missing routing rationale

### Role and contract ownership

Runtime ownership should stay narrow:
- planner owns bounded round formation
- generator owns deliverable and evidence production
- evaluator owns independent acceptance
- main/router owns state transition decisions

Canonical references:
- planner: `agents/planner.md`
- generator: `agents/generator.md`
- evaluator: `agents/evaluator.md`
- main/router: `agents/main.md`
- round contract: `contracts/round-contract.md`
- evaluation contract: `contracts/evaluation-contract.md`
- routing contract: `contracts/routing-contract.md`

This doc should not restate those files in detail.

### End-to-end trace

A v1 loop should be understandable through one concrete trace:

1. `intake_pending`
   - runtime receives a writing-plan
   - entry check passes
2. `planning_round`
   - planner freezes exactly one bounded round contract
3. `ready_to_generate -> generating`
   - generator executes that contract
4. `awaiting_evaluation -> evaluating`
   - generator returns deliverable, evidence, and unverified areas
   - evaluator judges artifact plus evidence
5. `routing`
   - router records verdict and route reason
   - if verdict is `RETRY`, return to generation for the same round
   - if verdict requires contract repair, route to planner
   - if current round is accepted but more bounded work remains, continue to the next round
   - if accepted work reaches the stopping point, mark `converged`

This trace is the minimum runtime behavior we need to prove.

## Repository evolution

The current repo has already completed the first structural move:
- from root-doc dominance
- to `agents/`, `contracts/`, and `skills/` as the main structure

That evolution should now continue in one direction only:
- from structure-first repo
- to runtime-defined repo

The intended evolution is:

### Past
- root `README.md` and root `SKILL.md` carried most of the effective semantics
- role boundaries and handoffs were embedded in large documents

### Present
- `agents/` defines responsibility surfaces
- `contracts/` defines handoff surfaces
- `skills/` defines invocation surfaces
- supporting governance docs still exist as richer reference material

### Next
- `docs/design-plans/pge-harness-runtime.md` becomes the top-level runtime construction plan
- legacy supporting docs are treated as inputs and references, not the runtime center
- the runtime model becomes the thing we implement against

### Later
- `pge-execute` becomes a real runtime loop over the current structure
- additional skills can share the same contract and state model without another repo restructure

## Phased roadmap

### v0: structure-first skeleton

Objective:
- finish the structural transition and define the runtime plan

What exists already:
- `agents/`
- `contracts/`
- `skills/pge-execute/SKILL.md`

What v0 still needs:
- this design document
- one canonical runtime state model
- agreement that the repo has moved from skill-doc design to runtime-plan design

### v1: single `pge-execute` runtime loop

Objective:
- prove one stable execution loop

Scope:
- one upstream writing-plan enters the loop
- planner freezes one bounded round
- generator executes the round
- evaluator judges independently
- main/router decides next transition
- state is updated explicitly after each round

Success criteria:
- one real plan can move through multiple rounds without semantic collapse
- contract boundaries remain visible
- evaluator verdicts actually affect routing
- state can be resumed without reconstructing everything from chat

### v2: multi-skill expansion

Objective:
- allow more than one skill to share the runtime substrate

Scope:
- keep PGE core loop reusable
- introduce additional invocation surfaces only when they share the same contract and state model
- avoid per-skill reinvention of planner/generator/evaluator/routing semantics

Success criteria:
- adding a new skill does not require rebuilding the runtime model
- the repo remains structure-first instead of proliferating special-case prompts

### v3: stronger runtime orchestration

Objective:
- improve loop quality without turning the system into a platform prematurely

Possible additions:
- stronger retry and escalation handling
- stronger evaluator enforcement
- clearer boundaries between runtime state and conversational state
- stronger session and sandbox semantics
- optional stronger agentization if it solves a proven problem

Success criteria:
- orchestration becomes more stable without losing bounded execution discipline
- new capability is justified by runtime friction, not by abstract completeness

## First proving task

The first proving task should be real, bounded, and measurable.

Current recommended candidate:
- `/Users/yan./git/b/data_router/docs/timeout_and_backpressure_plan.md`

Why this is a good first proof:
- it already has a concrete operational problem
- it includes bounded implementation ideas
- it contains measurable success criteria
- it is rich enough to test plan intake, slicing, generation, evaluation, and routing
- it is not so large that the first runtime proof becomes a platform exercise

This proving task is not chosen because it belongs to PGE itself. It is chosen because it is a good runtime testbed.

## Immediate next step for this repo

The next step should remain narrow.

Do now:
1. land this design document
2. use it as the top-level runtime reference
3. keep the next implementation patch focused on one runtime-shaped proving step

Do not do now:
- add `runtime/`
- add `commands/`
- add multiple new skills
- turn the repo into a workflow platform
- rewrite the current role and contract skeletons before the runtime plan is tested

The repo should now use this design document as the top-level construction plan for evolving PGE into our own harness runtime.
