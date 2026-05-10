# ROUND_010_SINGLE_ROUND_RUNTIME_HARDENING

> Historical note: this round document is superseded on runtime-team architecture by `docs/exec-plans/ROUND_011_RUNTIME_TEAM_ORCHESTRATION_PLAN.md` and on control-plane behavior by `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md`. Keep it as historical context for bounded single-round hardening, not as the current architecture decision.

## Context

This round records the reviewed, conservative execution plan after multi-round review of the proposed PGE direction.

The long-term target remains useful: evolve `pge` toward a more general, plan-driven execution layer where an upstream plan can move through Planner / Generator / Evaluator with explicit routing, recoverable state, and lower human-in-the-loop.

However, the review result is clear: the current repo is **credible for bounded single-round execution proving**, but **not yet credible** for claims about persistent runtime P/G/E teams, true multi-round runtime continuation, or long-lived autonomous team lifecycle and recovery.

This round therefore does **not** claim the final target is already achieved. It narrows the next step to one honest hardening round: make the existing single-round runtime path operationally trustworthy, explicitly bounded, and explicit about unsupported routes.

## What review confirmed

### Already credible now

- `pge-execute` can accept an upstream plan shape and run a bounded Planner → Generator → Evaluator flow.
- File-based handoff is already real enough to reuse:
  - upstream plan
  - runtime intake/state
  - planner output
  - generator deliverable
  - evaluator verdict
  - routing outcome
- Route / verdict vocabulary is already strong enough for deterministic bounded orchestration.
- Per-run artifact isolation keyed by `run_id` is already proven and should remain normative.

### Not yet credible now

- Persistent runtime P/G/E team lifecycle.
- True multi-round runtime continuation (`continue`) across bounded slices.
- True retry loop execution beyond bounded single-round behavior.
- Long-lived recovery semantics for partially completed runtime teams.
- Strong claims that `main` is already an operational runtime scheduler rather than partly doctrinal control logic embedded in `SKILL.md`.

## Round objective

Harden the existing single-round runtime path so the repo can truthfully claim:

> `pge-execute` is an operationally trustworthy bounded single-round execution surface using installed runtime-facing agents, explicit artifacts, explicit routing, and explicit unsupported-route behavior.

## This round changes the claim, not the destination

This round does **not** abandon the broader execution-layer direction.
It changes what the repo is allowed to claim **now**.

- Final direction: broader plan-driven execution layer.
- Current executable claim: hardened, honest, bounded single-round runtime.

## Done-when

This round is done only when all of the following are true:

1. `CURRENT_MAINLINE.md` explicitly states what the runtime can do now and what is intentionally deferred.
2. `skills/pge-execute/SKILL.md` aligns with the runtime states and route behaviors it actually supports.
3. Unsupported routes (`retry`, `continue`, `return_to_planner` if not fully implemented in runtime flow) fail fast and explicitly instead of being implied by vocabulary alone.
4. Canonical contracts and runtime-facing contract copies are checked for drift by explicit process or validation rule.
5. The single-round path remains runnable end-to-end with explicit artifacts, explicit route reason, and explicit final outcome.

## Required evidence

- Updated mainline/control-plane text that distinguishes current capability from deferred capability.
- Evidence that `SKILL.md` and runtime-state/routing contracts describe the same actually supported single-round flow.
- Evidence that unsupported routes are handled explicitly rather than silently falling through.
- Evidence that contract drift between canonical and runtime-facing copies is reduced or explicitly guarded.
- One bounded proving run or equivalent repo-local validation showing the hardened single-round flow still converges.

## Explicit non-scope

This round does **not** implement or claim:

- persistent runtime teams
- multi-round runtime continuation
- autonomous long-lived team lifecycle
- planner/generator/evaluator runtime parallelism as a production-ready control plane
- broad redesign of agent semantics beyond what single-round hardening requires
- expansion into external task support

## Current blocker framing

### P0

- The repo currently risks overstating runtime maturity if it claims persistent runtime team capability or multi-round execution before the runtime actually supports it.

### P1

- Current runtime-state and route vocabulary are richer than the runtime flow that is actually enacted.
- Canonical contracts and runtime-facing copies may drift.
- `main` control logic is not yet cleanly separated from the orchestration embedded in `SKILL.md`.

### P2

- Broader execution-layer redesign beyond bounded single-round hardening.
- Persistent team lifecycle design.
- Generalized recovery model for long-lived autonomous runs.

## Route truth table for this stage

This table records what the repo is allowed to claim in the current stage.

| Evaluator verdict | Runtime claim now | Route behavior in this stage |
| --- | --- | --- |
| `PASS` + single-round stop condition met | Supported now | `converged` |
| `PASS` + non-single-round continuation implied | Not yet supported as runtime loop | explicit defer / fail-fast |
| `RETRY` | Vocabulary exists | explicit defer / fail-fast unless truly implemented |
| `BLOCK` repair within same round | Vocabulary exists | explicit defer / fail-fast unless truly implemented |
| `ESCALATE` / return to planner | Vocabulary exists | explicit defer / fail-fast unless truly implemented |

The key rule for this stage: **do not imply loop support that the runtime does not actually enact.**

## Next single action

Update the current mainline and runtime docs so they become operationally authoritative for bounded single-round execution:

1. clearly state current supported runtime behavior,
2. clearly state deferred runtime behavior,
3. align `SKILL.md` with actual state/route handling,
4. add explicit unsupported-route behavior instead of aspirational wording.

## Why this round matters

Without this hardening round, the repo risks planning against a runtime that sounds more capable than it really is. That increases human fallback, weakens trust in route/state semantics, and makes later execution-layer work less reliable.

A truthful, hardened single-round runtime is a better base than an overstated pseudo-general runtime.