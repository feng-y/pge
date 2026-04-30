# PGE Execution Core Proving Prerequisites

> Date: 2026-04-30
> Status: Draft
> Purpose: define what must be true before using a real bounded task to prove the current PGE execution core.

---

## 1. Why this document exists

A real bounded task proving run should validate:

- whether the current execution core works
- whether the role boundaries hold
- whether the gates catch the right failures
- whether the orchestration shell stays lean under pressure

It should **not** be used to discover basic execution-core confusion that could have been caught before the run.

Without a proving-readiness checklist, a failed real task can mean at least three different things:

1. the task itself was too hard or too broad
2. the execution core was still under-specified
3. the control-plane rules were unstable

This document exists to separate those cases.

---

## 2. Scope

This document is about the **active execution core only**:

- `main`
- `planner`
- `generator`
- `evaluator`
- the current bounded single-run skeleton

It is not about:

- future preflight lane
- multi-round redispatch
- resume / checkpoint recovery
- product-level planning systems

---

## 3. What a real bounded task proving run is for

A real bounded task proving run is for answering questions like:

- does Planner freeze a contract Generator can actually execute?
- does Generator stay faithful to the contract?
- does Evaluator independently validate the actual deliverable?
- does `main` classify blockers and friction correctly?
- does the system stay stable without inventing extra phases?

It is **not** for:

- debugging obvious documentation drift
- discovering whether `main` even knows its own lifecycle
- discovering whether agents are still writing progress directly
- discovering whether verdict-to-route reduction is undefined

Those should already be settled before the run.

---

## 4. Minimum readiness conditions

Before a real bounded task is used for proving, all of the following should be true.

### 4.1 Active skeleton is fixed

The active lane must already be fixed as:

```text
main initialize run
-> main create agents team
-> main dispatch planner
-> main gate planner artifact
-> main dispatch generator
-> main gate deliverable / generator artifact
-> main dispatch evaluator
-> main gate evaluator artifact
-> main deterministic route reduction
-> main deterministic teardown
```

If the team still debates the primary skeleton, it is too early for real proving.

### 4.2 Role boundaries are explicit

All four surfaces must already be clear:

- `main` = control-plane owner
- `planner` = researcher + architect + planner
- `generator` = coder + integrator + local reviewer
- `evaluator` = independent final validator

If any role still needs `main` to invent specialist semantics mid-run, proving is premature.

### 4.3 Inputs and outputs are explicit

Each role must already have:

- explicit inputs
- explicit outputs
- non-responsibilities
- gateable artifact surfaces

If a role still depends on freeform interpretation instead of stable I/O, real proving will be noisy and hard to diagnose.

### 4.4 The three hard review points are fixed

The current lane must already have exactly these hard review points:

1. Planner artifact gate
2. Generator deliverable / artifact gate
3. Evaluator verdict gate

If the team is still adding or removing default review stages, proving will measure moving targets.

### 4.5 Progress ownership is fixed

Before real proving:

- `main` must already be the only authoritative progress writer
- teammates must not write authoritative progress directly
- progress must already be observability-only, not progression logic

Otherwise proving will mix control-plane bugs with role behavior.

### 4.6 Verdict reduction is fixed

Before proving, `main` must already have deterministic rules for:

- `generator_plan_review` consumption
- evaluator verdict consumption
- route reduction
- teardown

If verdict handling still depends on ad-hoc interpretation, real-task results will not be trustworthy.

### 4.7 Hard blocker vs friction distinction exists

The current lane must already distinguish:

- hard blockers
- soft blockers / friction

If every issue causes a stop, the system is too brittle.
If nothing causes a stop, the system is too loose.

Either failure makes a proving run low-value.

---

## 5. Interaction audit prerequisites

Before proving, the key interactions should already be justified.

For each interaction, the team should be able to answer:

1. what new information does it create?
2. what decision does it change?
3. who owns failure at this seam?
4. what happens if we remove it?

If an interaction exists only to repeat context or create waiting, it should be removed before real proving.

At minimum, this audit should already be true for:

- `main -> planner`
- planner gate
- `main -> generator`
- `generator_plan_review`
- generator gate
- `main -> evaluator`
- evaluator gate
- route reduction
- progress logging

---

## 6. Failure-handling prerequisites

Before proving, the execution core should already have:

### 6.1 Failure ownership classification

Clear categories:

- planner failure
- generator failure
- evaluator failure
- protocol failure
- runtime failure

### 6.2 Failure action matrix

For each category, the system should already know:

- what `main` records
- whether the run stops
- whether the issue is friction only
- which role owns the repair
- whether the current stage downgrades to `unsupported_route`

If these are still undefined, the proving run will expose confusion rather than capability.

---

## 7. Readiness checklist

Use this as the direct proving gate:

- [ ] active execution skeleton is fixed
- [ ] role boundaries are explicit
- [ ] role inputs and outputs are explicit
- [ ] three hard review points are fixed
- [ ] `main` is the only authoritative progress writer
- [ ] `main` has deterministic rules for generator/evaluator consumption
- [ ] route reduction is deterministic
- [ ] teardown is deterministic
- [ ] hard blocker vs friction distinction is explicit
- [ ] failure ownership categories are explicit
- [ ] failure action matrix exists
- [ ] no known interaction remains that only duplicates information or creates waiting

If any high-signal box is unchecked, use another design pass instead of a real proving run.

---

## 8. Good proving target properties

A good first real bounded proving task should be:

- real repo work
- bounded enough for one round
- meaningful enough to exercise Planner / Generator / Evaluator
- not so large that failure cause becomes ambiguous

Good examples:

- small but real docs or config refactor with verification
- one bounded implementation slice with concrete deliverable
- one narrow correctness fix with inspectable evidence

Bad examples:

- trivial smoke-only file write
- broad product redesign
- large multi-module architectural migration
- task that still needs unresolved upstream clarification

---

## 9. What proving should measure

A real bounded task proving run should measure:

1. whether Planner writes a contract Generator can actually execute
2. whether Generator stays within contract boundaries
3. whether Evaluator remains independent and compact
4. whether `main` stays lean instead of becoming the fourth expert
5. whether friction is recorded usefully
6. whether hard blockers vs soft blockers are being classified correctly

---

## 10. Failure interpretation rule

When a proving run fails, do not immediately conclude the role prompts are bad.

First classify the failure:

- task too broad?
- Planner contract failure?
- Generator execution failure?
- Evaluator verdict failure?
- `main` orchestration failure?
- runtime/substrate failure?

Only after that classification should the team decide what to change.

---

## 11. Bottom line

The goal of a real bounded task proving run is to validate the execution core, not to use a real task as an informal design workshop.

Before proving begins, the core should already have:

- fixed skeleton
- fixed role boundaries
- fixed gates
- fixed progress ownership
- fixed failure ownership
- fixed reduction rules

Once those are true, a real bounded task becomes a useful proving target instead of a noisy debugging surface.
