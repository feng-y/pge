# PGE_ORCHESTRATION_CONTRACT

## Purpose

This file is the architectural control-plane contract for how PGE is orchestrated.

It defines, in one place:
- what `main` is
- what `main` is not
- the ownership split between run-level orchestration and runtime execution
- the normalized relationship between upstream plan intake, `main`, and the persistent runtime team

The active operational seam for `main` now lives in `skills/pge-execute/ORCHESTRATION.md`.
If any older doc or checklist models `main` as a peer worker role or an `agents/` seam, this file wins at the architectural level.

## Normalized architecture

PGE should be described like this:
- an upstream plan enters PGE
- skill-internal `main` orchestration logic runs inside `/pge-execute`
- Planner / Generator / Evaluator execute as the persistent runtime team
- file-based handoff remains the execution backbone

The persistent runtime team is Planner / Generator / Evaluator only.

`main` is outside that team as the orchestration shell and control-plane authority for the run. It is not an `agents/` seam.

## What `main` is

`main` is the skill-internal:
- run-level scheduler
- runtime-state owner
- route / stop / recovery owner
- team lifecycle owner
- artifact persistence owner
- upstream plan intake owner

## What `main` is not

`main` is **not**:
- an agent
- an `agents/` seam
- a peer role alongside Planner / Generator / Evaluator
- a Planner / Generator / Evaluator substitute
- a hidden fourth worker that absorbs planning, delivery, or evaluation duties

`main` may dispatch Planner / Generator / Evaluator and persist their artifacts, but it must not perform their role work itself.

## Explicit role split

| Surface | Owner | Must not own |
| --- | --- | --- |
| run-level scheduling, runtime state, routing, stop, recovery, team lifecycle, artifact persistence | `main` | slice shaping, deliverable production, independent evaluation |
| slice scheduling, boundary ownership, executable-slice framing, verification path, slice-status advice | Planner | run-level route, stop, recovery, team lifecycle |
| deliverable production, local verification, concrete execution evidence | Generator | acceptance, final route selection |
| validation gate, evidence sufficiency, canonical verdict, route signal | Evaluator | implementation fixes, replanning, hidden route invention |

Planner is the slice scheduler and boundary owner.
Generator is the deliverable owner.
Evaluator is the validation gate and route-signal producer.

Planner may advise on slice status, but `main` remains the run-level route owner.

## Relationship to other authoritative seams

- `skills/pge-execute/ORCHESTRATION.md` is the active operational seam for `main` inside the skill layer.
- `skills/pge-execute/SKILL.md` stays thin and dispatches according to that operational seam.
- `docs/exec-plans/PGE_EXECUTION_LAYER_PLAN.md` defines the broader execution-layer architecture.
- `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md` defines the current-stage runtime FSM, route policy, unsupported-route handling, recovery entry points, and artifact-gate behavior that the skill layer operationalizes.
- `contracts/*` remain the canonical normalized vocabulary for route/state/verdict semantics.

## Normalization rules

To avoid reintroducing the old confusion:
- do not list `main` inside the persistent runtime team inventory
- do not describe `main` as a peer agent to Planner / Generator / Evaluator
- do not describe `main` as an `agents/` seam
- do not use `main` as shorthand for a fourth runtime worker role
- when docs say "runtime team," they mean Planner / Generator / Evaluator under `main` orchestration
- when docs say "orchestration authority," they mean skill-internal `main` logic at the run level

## Current-stage boundary

This contract fixes the control-plane split. It does not reopen whether runtime teams are needed.

The reviewed target architecture remains:
- upstream plan enters PGE
- `main` orchestrates
- a persistent Planner / Generator / Evaluator runtime team executes
- file-based handoff remains the backbone

Current-stage runtime behavior remains bounded by `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md`.
