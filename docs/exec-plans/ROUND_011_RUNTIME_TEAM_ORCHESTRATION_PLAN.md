# ROUND_011_RUNTIME_TEAM_ORCHESTRATION_PLAN

## Context

After multi-round review, the architecture decision is now explicit:

> `pge` should evolve into a generic, plan-driven execution layer organized around `main` plus a persistent runtime Planner / Generator / Evaluator team.

This is not an optional upgrade. The review result is that without runtime team organization, P/G/E responsibility surfaces do not fully stand up: collaboration, retry, recovery, and boundary ownership remain too dependent on prompt text and human interpretation.

At the same time, review also showed that the current repo is **not yet operationally ready** to claim that this runtime team architecture has been fully implemented. The blocking gap is not whether teams are needed; it is that orchestration closure is still incomplete.

So this round records both truths at once:
- **Target architecture**: `main` + persistent runtime P/G/E team is the intended execution model.
- **Current bounded implementation goal**: make orchestration authoritative enough that this team model can be implemented without ambiguity or control-surface drift.

## Final target architecture

### Main

`main` is the run-level scheduler and control-plane owner.

It owns:
- upstream plan intake
- run initialization
- runtime state ownership
- artifact persistence ownership
- route selection from verdict + stop condition
- stop / recovery ownership
- team lifecycle ownership

It does **not** perform Planner / Generator / Evaluator role work itself.

### Planner

Planner is the slice scheduler and boundary owner.

It owns:
- freezing the current executable slice from the upstream plan
- deciding whether to pass through or cut a smaller slice
- naming the current boundary, deliverable, verification path, and handoff seam
- advising whether the current slice should continue locally or be re-planned

It does **not** own run-level routing, stop, recovery, or team lifecycle.

### Generator

Generator is the deliverable owner.

It owns:
- producing the real repo deliverable for the current slice
- running required local verification
- emitting concrete evidence
- declaring known limits, deviations, and non-done items honestly

It does **not** own acceptance or routing.

### Evaluator

Evaluator is the validation gate and route-signal producer.

It owns:
- independently validating the real deliverable
- validating evidence sufficiency
- issuing canonical verdict
- emitting next-route signal for `main`

It does **not** implement fixes or rewrite planning.

## What multi-round review confirmed

### Strong evidence already present

- The repo already has a real file-based handoff chain:
  - upstream plan
  - runtime intake state
  - planner output
  - generator deliverable
  - evaluator verdict
  - routing outcome
- Route / verdict vocabulary is already strong enough to support deterministic bounded orchestration.
- Per-run artifact isolation keyed by `run_id` is already a real and useful runtime primitive.
- Existing roles and contracts already separate planning, generation, evaluation, and routing semantics better than an ad hoc prompt loop.

### Gaps that still block a credible runtime-team claim

1. **Orchestration truth is split**
   - too much authoritative runtime behavior still lives in `skills/pge-execute/SKILL.md`
   - `agents/main.md` is not yet a strong enough run-level scheduler contract

2. **Team lifecycle is not operationally closed**
   - no explicit runtime mechanism yet for persistent team identity, recovery after partial failure, or resumable intra-run orchestration

3. **Slice ownership is not fully closed**
   - Planner clearly owns slice shaping, but `active_slice_ref` advancement and run-level control boundaries are not yet pinned tightly enough

4. **Route / recovery support exceeds current runtime implementation**
   - route vocabulary is richer than the currently proven runtime flow
   - unsupported routes can still be implied more strongly than they are enacted

5. **Artifact-chain validation is incomplete**
   - planner preflight is clearer than generator/evaluator artifact validation before final routing

6. **Contract drift risk remains**
   - canonical `contracts/*` and runtime-facing copies can drift without a sufficiently explicit sync/validation mechanism

## Round objective

Do the minimum hardening required so the runtime team architecture becomes implementable on a stable base.

The authoritative orchestration source of truth for this round is:
- `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md`

This round should therefore focus on:

1. establishing a single operational source of truth for runtime orchestration,
2. making route and recovery behavior explicit and fail-fast where not yet supported,
3. tightening ownership boundaries between `main` and Planner,
4. tightening artifact-chain validation,
5. reducing contract drift risk,
6. introducing explicit runtime shell guardrails validated by external harness practice:
   - explicit run-state machine
   - durable checkpoints / resumability
   - scoped delegation boundaries
   - append-only evidence / trace record

## What this round must change first

### 1. Establish one orchestration source of truth

The repo needs one authoritative runtime-orchestration definition that unifies:
- state transitions
- route policy
- unsupported-route handling
- recovery entry points
- team lifecycle assumptions
- explicit terminal / paused / failed states

`SKILL.md` should become a thin dispatcher to this orchestration truth rather than remaining the de facto full runtime specification.

This source of truth should be shaped as an explicit runtime FSM rather than a loose prose flow. At minimum it should distinguish:
- planning
- executing
- evaluating
- paused / waiting
- failed
- completed

### 2. Make unsupported routes explicit

Until true multi-round team execution is real, the runtime must not imply more than it supports.

For this stage:
- `converged` on bounded single-round success is supported
- richer paths like `retry`, `continue`, and `return_to_planner` should be explicit, bounded, and fail-fast unless genuinely implemented in runtime flow

### 3. Close ownership boundaries

- `main` owns run-level state and route
- Planner owns slice shaping and slice-status advice
- Planner may emit something like `slice_status: continue_slice | new_slice_needed`, but that remains advisory to `main`
- Generator and Evaluator cannot redefine slice or route semantics

### 4. Add artifact-chain gates before final routing

Before route finalization, runtime should be able to confirm:
- planner artifact is structurally usable
- generator artifact names resolvable deliverables and evidence
- evaluator verdict artifact is structurally complete and route-usable
- the current step leaves an append-only evidence / trace record with state-before/state-after, artifact refs, and verifier outcome

### 5. Add explicit drift control for contracts

The repo should not keep claiming canonical/runtime-facing contract parity without an explicit check or synchronization rule.

### 6. Make recovery checkpoint-driven

Persistent teams should not rely on hidden conversational continuity as their only recovery mechanism.
For this stage, recovery should be defined from durable runtime records:
- latest runtime state
- latest accepted artifact refs
- latest route reason
- latest verifier outcome

This means future retry / resume / re-plan behavior should be checkpoint-driven, not transcript-dependent.

### 7. Keep delegation scoped

Persistent teams do not imply unconstrained context sharing.
The runtime should keep role inputs minimal and explicit:
- Planner receives upstream plan plus the current bounded runtime context
- Generator receives the approved current slice plus the minimum execution context needed for delivery
- Evaluator receives the approved slice, actual deliverable, and evidence bundle

This preserves responsibility boundaries and reduces drift across long-running orchestration.

## Done-when

This round is done only when all of the following are true:

1. The docs explicitly state that runtime P/G/E teams are the intended target architecture.
2. The docs explicitly state that current runtime support is still bounded and what remains deferred.
3. There is one operationally authoritative orchestration definition for state/route/recovery behavior.
4. `main` vs Planner responsibility boundaries are explicit and non-overlapping.
5. Unsupported routes fail fast and explicitly instead of being implied.
6. Artifact-chain validation before final routing is explicitly required.
7. Contract drift control between canonical and runtime-facing copies is explicitly addressed.
8. The runtime orchestration definition includes explicit FSM states, checkpoint-based recovery expectations, scoped delegation rules, and append-only evidence recording expectations.

## Required evidence

- Updated control-plane text reflecting runtime-team target architecture.
- Updated orchestration text showing one runtime source of truth.
- Explicit unsupported-route behavior documented for the current stage.
- Explicit ownership table for `main`, Planner, Generator, Evaluator.
- Explicit artifact-chain validation expectations before route finalization.
- Explicit contract-sync / drift-control rule.

## Explicit non-scope

This round does **not** claim that the full persistent runtime team lifecycle is already implemented.

It does **not** require in this same round:
- full multi-round execution support
- full autonomous retry loop support
- broad external task support
- generalized long-running production recovery semantics
- broad agent-semantic redesign beyond orchestration closure

## Why this is the right bounded round

Multi-round review converged on the same answer:
- team architecture is required,
- but team architecture without orchestration closure would remain unstable and ambiguous.

So the highest-leverage next step is not to postpone teams, and not to claim they already work.
It is to make the orchestration core authoritative enough that runtime teams can stand up without hidden ownership conflicts, unsupported route ambiguity, or artifact-chain drift.