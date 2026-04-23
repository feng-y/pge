# CURRENT_MAINLINE

## Current overall goal

Converge `pge` toward a generic, plan-driven execution layer organized around `main` plus a persistent runtime Planner / Generator / Evaluator team.

See the main architecture plan at `docs/exec-plans/PGE_EXECUTION_LAYER_PLAN.md`.

## Current stage goal

Make runtime orchestration authoritative enough that the intended runtime-team architecture can stand up without ambiguity, control-surface drift, or hidden ownership conflicts.

This stage does **not** defer runtime teams as optional. Runtime teams are the target architecture. The current bounded round exists to make that architecture implementable on a stable base.

## Current P0 blockers

- Persistent runtime-team lifecycle, route/recovery behavior, and ownership boundaries are not yet operationally closed strongly enough to claim the team architecture is fully implemented.

## Runtime orchestration authority for this stage

The authoritative orchestration source of truth is:
- `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md`

For the current stage, that file defines:
- runtime state transitions
- route policy
- unsupported-route handling
- recovery entry points
- team lifecycle assumptions
- artifact-chain gates before final routing
- the checkpoint mini-schema

If older round notes, checklist prose, or `skills/pge-execute/SKILL.md` conflict with that file, the orchestration authority file wins.

## Explicit non-goals for this stage

- broad external task support
- full multi-round execution support in the same round
- claiming persistent runtime-team lifecycle is already fully implemented
- broad agent semantic redesign beyond orchestration closure
- uncontrolled workflow/process expansion outside the execution-layer target

## Next single action

Start the next runtime implementation round directly from the authoritative control plane:
- enforce artifact-chain gates in the executable runtime path, not only in docs
- write and consume checkpoints from `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md`
- keep unsupported-route handling fail-fast in the runtime surface
- close the remaining runtime lifecycle mechanics without reopening architecture

## Round completion criteria

This stage is done when:
- runtime P/G/E teams are explicitly documented as the intended target architecture
- one operational source of truth exists for runtime orchestration, state/route/recovery behavior, and unsupported-route handling
- `main` vs Planner responsibilities are explicit and non-overlapping
- artifact-chain validation requirements are explicit before final routing
- contract drift control between canonical and runtime-facing copies is explicitly addressed
- the current bounded runtime path remains runnable end-to-end with explicit artifacts, explicit route reason, and explicit final outcome
- the repo does not overclaim persistent runtime-team capability before orchestration closure is actually implemented
