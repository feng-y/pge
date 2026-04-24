# CURRENT_MAINLINE

## Current mainline

Make `pge-execute` a runnable thin skill with persistent runtime `pge-planner` / `pge-generator` / `pge-evaluator` teammates.

## Why this is the mainline

Repo evidence supports the runtime team architecture:
- `.claude-plugin/plugin.json` declares the plugin package and runtime agent entries
- `skills/pge-execute/SKILL.md` is framed as a bounded execution entrypoint
- `skills/pge-execute/ORCHESTRATION.md` defines `main` as the skill-internal orchestration shell
- Stage 2 proved the minimal runtime team lifecycle works end-to-end through two successful smoke runs

The active problem is no longer runtime team bootstrap. The active problem is closing any remaining dispatch/handoff gaps in the runtime workflow surfaces.

## Active stage

Stage 3 — Team dispatch / handoff closure

## Current blocker

Stage 2 is complete. The minimal runtime team lifecycle has been proven through two successful smoke runs (`run-1777010098564`, `run-1777010525846`).

The current step is to identify and close any remaining dispatch/handoff gaps from the Stage 2 smoke runs, and verify that no role simulation remains in `main`.

## What this round is optimizing for

- keep `SKILL.md` thin
- keep `main` as the orchestration shell, not a peer agent
- treat `pge-planner`, `pge-generator`, and `pge-evaluator` as the persistent runtime teammates
- ensure all dispatch/handoff seams are file-backed
- verify no role simulation remains in `main`
- close Stage 3 without broadening into Stage 4+ work

## Explicit non-goals

- Stage 4 thin-skill reshape work
- per-task file protocol design
- contract convergence work beyond what is needed to keep Stage 3 coherent
- broad process expansion outside the staged plan
- multi-round automation
- self-hosting tasks
- Ralph loop

## Next single action

Identify remaining dispatch/handoff gaps from Stage 2 smoke runs and verify whether any role simulation remains in `main`.

## Stage exit criteria

Stage 3 is done when:
- all dispatch/handoff gaps identified from Stage 2 smoke runs are closed
- no role simulation remains in `main`
- the runtime workflow surfaces are complete for the current stage
- file-backed handoffs are confirmed for all seams
