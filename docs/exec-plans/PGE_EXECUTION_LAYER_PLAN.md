# PGE_EXECUTION_LAYER_PLAN

## What this plan defines

This is the main architecture plan for PGE.
It defines what `pge` is becoming, what the intended runtime organization is, and what execution-layer properties the repo should converge toward.

Round plans may narrow or sequence the work, but they should not redefine this architecture casually.

For normalized orchestration ownership and the definition of `main`, the architectural control-plane source is `docs/exec-plans/PGE_ORCHESTRATION_CONTRACT.md`.

For active skill-layer orchestration behavior, use `skills/pge-execute/ORCHESTRATION.md`.

For current-stage runtime orchestration policy, the authoritative runtime-control source is `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md`.

## Core definition

`pge` should evolve into a generic, plan-driven execution layer.

Its primary input is an **upstream plan**.
That plan may originate from prompt, intent, or spec upstream, but PGE itself is not the generic intent-understanding layer. By the time work enters PGE, the input should already be shaped enough to execute.

PGE's job is to let skill-internal `main` orchestration inside `/pge-execute` coordinate a persistent runtime team of Planner / Generator / Evaluator so the whole execution layer can achieve end-to-end development efficiently and stably.

## Target runtime organization

### Main

`main` is the skill-internal run-level scheduler and orchestration authority.

For the architectural control-plane definition of what `main` is and is not, use `docs/exec-plans/PGE_ORCHESTRATION_CONTRACT.md`.
For the active operational seam, use `skills/pge-execute/ORCHESTRATION.md`.

At a high level, `main` owns:
- upstream plan intake
- run initialization
- runtime-state ownership
- artifact persistence ownership
- route selection from verdict + stop condition
- stop / recovery ownership
- persistent team lifecycle ownership

It does **not** perform Planner / Generator / Evaluator role work itself, and it must not be modeled as a peer runtime agent role.

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

## Why persistent runtime teams are required

P/G/E should be organized as a persistent runtime team during a task / run.
This is not an optional future upgrade.

Without runtime team organization:
- responsibility surfaces stay blurry
- recovery falls back to conversation state or human intervention
- retry / re-plan / resume semantics remain weak
- collaboration reduces to repeated re-invocation instead of stable orchestration

So the intended architecture is:

> `main` orchestrates a persistent runtime Planner / Generator / Evaluator team

The remaining question is not whether teams are needed.
The remaining question is how to make orchestration closure strong enough that the team model can stand up operationally.

## Core execution model

The execution layer should preserve a visible file-based handoff chain:
- upstream plan
- runtime intake / state
- planner output
- generator deliverable
- evaluator verdict
- routing outcome / summary

This chain is a real strength in the current repo and should remain the visible execution backbone.

## Runtime shell support surfaces

These are not the primary input to PGE, but they are required support surfaces for stable execution:
- runtime state
- boundary state
- verification state
- recovery checkpoints
- minimal progress / judgment records
- append-only evidence / trace records

The runtime shell should keep these explicit so work can resume from records rather than transcript reconstruction.

## Guardrails from review and external practice

The execution layer should converge toward the following runtime properties:
- explicit run-state machine
- bounded autonomous loops
- checkpoint-driven recovery
- scoped delegation boundaries
- append-only evidence / trace record
- explicit fail-fast behavior for unsupported routes

These should strengthen the runtime shell, not turn the docs into abstract theory.

## What must remain true while evolving

- `SKILL.md` should become thinner, not thicker.
- `main` should remain a clearer orchestration authority, not an agent-shaped peer or hidden planner.
- file-based handoff should strengthen, not disappear.
- contracts should remain the minimum supporting vocabulary, not retake control as a heavy schema-first center.
- progress / support docs should stay anti-corruption oriented: short, revisable, and disposable when stale.

## What this plan does not require immediately

This architecture plan does **not** claim that all of the following are already implemented today:
- full persistent runtime team lifecycle
- full multi-round execution support
- full autonomous retry loop support
- generalized production-grade long-running recovery
- broad external task support

Those belong to implementation rounds.

## What current rounds should optimize for

Each bounded round should move the repo toward this architecture by improving one of the following:
- orchestration truth and ownership boundaries
- runtime-team lifecycle readiness
- route / recovery closure
- artifact-chain integrity
- contract drift control
- runtime shell observability and resumability

## Success condition for the broader plan

This architecture is succeeding when:
- an upstream plan can reliably enter PGE,
- `main` can keep the runtime organized without role confusion,
- P/G/E can collaborate as a stable runtime team,
- the artifact chain stays explicit and inspectable,
- route / recovery behavior is deterministic enough to lower human fallback,
- and execution progress survives beyond ephemeral conversation state.