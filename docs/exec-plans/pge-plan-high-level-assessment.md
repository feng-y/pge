# PGE Plan High-Level Assessment

## Goal

Provide a focused high-level assessment of `pge-plan`.

This document intentionally follows the **skill-creator evaluation style**, adapted for an existing contract-heavy skill rather than a prompt/output benchmark loop.

So the assessment emphasizes:

- what the skill is supposed to enable
- when it should trigger
- whether its workflow is clear
- whether its context budget follows progressive disclosure
- whether its internal contract is coherent
- whether its execution handoff is reliable

This is **not** yet an implementation plan. It is the high-level assessment that should precede one.

---

## Assessment frame

For `pge-plan`, the right high-level process is:

1. consume `research` or other valid planning source
2. understand intent / requirements and clarify if necessary
3. bind the request to repo reality and produce an executable draft approach
4. use `plan-eng-review` to harden that draft into a real executable plan
5. emit issues / handoff shape so an execution backend can consume it

This sequence is the main backbone for the assessment below.

---

## What `pge-plan` should enable

At a high level, `pge-plan` should enable Claude to do one thing well:

> turn a stable problem contract into a stable execution contract.

More concretely, it should:

- take input from `research`, direct prompt, or another plan/spec source
- confirm that the goal/scope/success shape are actually plan-ready
- combine that problem contract with repo reality
- produce an executable approach rather than an abstract design note
- split work into progressive, verifiable, executable slices
- emit a backend-consumable plan contract without turning into an execution stage

It should **not**:

- redo broad problem discovery that belongs in `pge-research`
- perform implementation that belongs in execution
- hide plan gaps behind output formatting
- create a second canonical plan surface

---

## Trigger / entry assessment

### Current supported entry modes

From the current contract, `pge-plan` supports:

- direct prompt planning
- `research.v3` handoff
- fast-adopt of explicit external plans
- bare invocation with artifact discovery

### High-level judgment

This is a strong capability set.

The problem is not missing entry modes.
The problem is that the skill's **identity** is easier to read as:

- source adaptation
- gate handling
- artifact generation

than as:

- plan formation
- repo-aware draft creation
- plan hardening

### High-level recommendation

Keep all four entry modes.
Do **not** reduce the surface yet.

But move the explanatory emphasis so the user/maintainer sees:

1. why the skill is entered
2. what core transformation happens inside it
3. only then how many ingress modes it supports

---

# Step-by-step high-level assessment

## 1. Consume `research` or other valid planning source

### What is strong now

`pge-plan` is already strong at source intake.

It can consume:

- `research.v3`
- direct prompt
- external plan/spec-like docs
- `docs/exec-plans/` style material through fast-adopt

It also already has:

- source priority interpretation
- selected-source handling
- source contract checking
- rules against silently re-planning external plans

### What is weak now

This step is too **visible** relative to the rest of the skill.

It is easy to come away thinking `pge-plan` is mainly a source router / adapter, instead of understanding that source intake only exists to support plan formation.

### High-level conclusion

Step 1 is **capability-strong but identity-heavy**.

Do not simplify it first.
Reframe it so it supports the skill's core identity instead of overshadowing it.

---

## 2. Understand intent / requirements and clarify if necessary

### What is strong now

The contract already includes:

- current prompt priority
- source-contract readiness checks
- minimum-question clarification behavior
- explicit readiness tests for goal / scope / success shape

So `pge-plan` does already participate in requirement understanding.

### What is weak now

This step is not prominent enough in the overall reading flow.

A maintainer can read a lot of route/gate/output material before clearly seeing that `pge-plan` must still:

- understand the request
- confirm plan-readiness
- escalate only when a true planning blocker exists

### High-level conclusion

Step 2 is **present but under-centered**.

This matters because if it is not visibly central, later users may overuse direct prompt planning or underuse clarification discipline.

---

## 3. Bind the request to repo reality and produce an executable draft approach

### What is strong now

This is one of the strongest parts of the current skill.

The contract already includes:

- bounded repo/runtime truth extraction
- architecture-delta reasoning
- source fidelity handling
- explicit repo-evidence use
- approach selection grounded in repo reality

This means `pge-plan` is already more than a formatting layer.
It is already doing real solution-design work.

### What is weak now

This stage is not named clearly enough as an intermediate deliverable.

The current reading experience does not strongly distinguish:

- "we have a plan-ready input"
- "we now have a repo-aware executable draft"
- "we now have a hardened final plan"

Those are three different states, and the current skill flattens them too much.

### High-level conclusion

Step 3 is **capability-strong but phase-visibility-weak**.

The assessment should treat this as a main core, not a supporting subroutine.

---

## 4. Use `plan-eng-review` to harden the draft into a real executable plan

### What is strong now

This is the most important high-level strength of `pge-plan`.

The current contract already makes `Plan Engineering Review` central to:

- challenge the selected approach
- expose scope drift
- tighten verification
- harden slicing
- pull repo/architecture contradictions forward before execution

This is exactly the layer that closes the gap between:

- "a plan that sounds right"
- and
- "a plan that can really be executed against this repo"

### What is weak now

Its **status is still too easy to misread**.

Even though the capability is already there, it can still be perceived as:

- a hardening add-on
- a review pass
- a later refinement step

rather than:

- the stage where the initial executable draft becomes execution-real

### High-level conclusion

Step 4 is the **true center of gravity** of `pge-plan`.

If the skill is to be clarified, this step should become the clearest conceptual center.

---

## 5. Emit issues / handoff shape so an execution backend can consume it

### What is strong now

This is also very strong in the current implementation.

The current contract clearly supports:

- canonical `plan.md`
- issue index + `issues/Ixxx.md`
- verification coupling
- execution ordering hints
- workflow-handoff adapter generation

### What is weak now

This part is currently **too visible** compared with steps 2-4.

Because the output surface is mature and concrete, it visually dominates the skill.
That makes it too easy to misread `pge-plan` as:

- issue formatter
- execution-contract emitter
- handoff generator

instead of seeing those as the result of prior plan formation and hardening.

### High-level conclusion

Step 5 is **output-strong but should be identity-secondary**.

It is the result layer, not the main value-definition layer.

---

# Skill-creator style evaluation dimensions

## A. Workflow clarity

### Judgment

Moderately strong, but the visible ordering is not yet ideal.

### Why

The skill contains the right capabilities, but the perceived sequence is still too close to:

- source adaptation
- gate handling
- artifact output

instead of:

- understand
- draft against repo
- harden through plan-eng-review
- emit final execution contract

### Recommendation

Re-center the document flow around the 1-5 sequence above.

---

## B. Progressive disclosure / context economy

### Judgment

Functionally rich, but hot-path overloaded.

### Why

The main issue is not that there are too many functions.
The issue is that these are mixed together in the hot path:

- source adaptation
- core solution-design functions
- review/gate detail
- output schema detail
- handoff detail

### Recommendation

Do not remove core functions first.
Instead:

- keep core planning functions in hot path
- move more detailed gate mechanics, examples, and adapter detail into references/templates
- keep the top-level skill centered on the actual planning transformation

---

## C. Internal consistency

### Judgment

Generally strong, but conceptually misweighted.

### Why

The main inconsistency is not a direct contradiction.
It is a **weighting inconsistency**:

- output and route surfaces appear more central than plan formation
- `plan-eng-review` is functionally central but not narratively central
- backend handoff detail is mature enough to overshadow backend-agnostic contract design

### Recommendation

Clarify stage center of gravity rather than only reducing text.

---

## D. Execution reliability

### Judgment

High, but still slightly shaped around `pge-exec` as the most visible consumer.

### Why

At the ADR level, `pge-plan` already targets both execution backends.
But some of the emitted contract language still feels more `pge-exec`-shaped than fully backend-agnostic.

### Recommendation

The next assessment pass should ask:

- which plan fields are true shared execution contract
- which are historical `pge-exec` consumption shape
- which are workflow adapter-only additions

This is now the most important architectural question.

---

# Backend-agnostic assessment

## Current high-level state

`pge-plan` is conceptually already moving toward a shared execution contract.

Evidence:

- ADR treats `pge-exec` and Dynamic Workflow as execution backends
- `workflow-handoff.md` is defined as an adapter, not a second plan
- `plan.md` remains the canonical source of truth

## Current limitation

The contract still reads slightly `pge-exec`-first in places.

This does **not** mean the current design is wrong.
It means the next high-level question is:

> is `pge-plan` producing a truly backend-agnostic execution contract,
> or an `exec`-shaped contract with workflow compatibility layered on top?

## High-level conclusion

This is the most important future evaluation axis for `pge-plan`.

---

# Main high-level problems

## Problem 1 — the skill's main process is not visually centered enough
The current capability is good, but the main flow is not presented with the right weight.

## Problem 2 — `plan-eng-review` is central in function, but not yet central enough in perception
This is the biggest conceptual correction needed.

## Problem 3 — output/handoff maturity visually dominates the earlier planning work
This makes the skill easier to mistake for a contract emitter rather than a plan-forming stage.

## Problem 4 — backend-agnostic contract design is the next big architectural question
This is now more important than arguing first about local simplification.

---

# Recommended improvement order

## Phase 1 — reorder the high-level mental model
Re-express the skill around:

1. ingest source
2. understand / clarify intent
3. bind to repo reality and draft executable approach
4. harden with `plan-eng-review`
5. emit issues / backend handoff

## Phase 2 — separate core planning functions from output/handoff presentation
Make it clearer which parts define the plan itself and which parts are final organization layers.

## Phase 3 — evaluate the contract as backend-agnostic
Determine which emitted fields are:

- shared execution contract
- `pge-exec`-historical consumption shape
- workflow adapter-only structure

## Phase 4 — only then decide removal / relocation / simplification
Do not start by shrinking.
Start by clarifying stage identity and backend contract role.

---

# Final high-level judgment

`pge-plan` is already strong where it matters most.

Its problem is **not** that it lacks planning capability.
Its problem is that its strongest planning capabilities are not yet arranged with the right visible center of gravity.

So the right next move is:

- not to simplify first
- not to optimize for output first
- but to make the real 1-5 process explicit,
- and then evaluate the contract from a backend-agnostic standpoint.
