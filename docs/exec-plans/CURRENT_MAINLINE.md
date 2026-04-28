# CURRENT_MAINLINE

## Current mainline

Make `pge-execute` a runnable thin skill with persistent runtime `pge-planner` / `pge-generator` / `pge-evaluator` teammates.

## Why this is the mainline

Repo evidence supports the runtime team architecture:
- `.claude-plugin/plugin.json` declares the plugin package and runtime agent entries
- `skills/pge-execute/SKILL.md` is framed as a bounded execution entrypoint
- `skills/pge-execute/ORCHESTRATION.md` defines `main` as the skill-internal orchestration shell
- `skills/pge-execute/handoffs/` now defines planner, preflight, generator, evaluator, and route/teardown seams explicitly
- `bin/pge-validate-contracts.sh` validates the current contract and workflow surface statically

Historical proving runs suggest the runtime bootstrap direction is viable, but the current thin-skill architecture has not yet been re-proven through a fresh runnable smoke pass.

The active problem is closing remaining dispatch/handoff gaps in the current workflow surfaces and preparing a trustworthy smoke-oriented validation path.

## Active stage

Stage 3 — Team dispatch / handoff closure

## Current blocker

The current skill/runtime surfaces are substantially aligned, but there is still no fresh runnable smoke proof for the current thin-skill architecture with bounded preflight negotiation.

The current step is to close remaining dispatch/handoff gaps and make smoke validation explicit instead of inferred from older proving runs.

## What this round is optimizing for

- keep `SKILL.md` thin
- keep `main` as the orchestration shell, not a peer agent
- treat `pge-planner`, `pge-generator`, and `pge-evaluator` as the persistent runtime teammates
- ensure all dispatch/handoff seams are file-backed
- verify no role simulation remains in `main`
- prepare a current smoke-oriented validation path without broadening into Stage 4+ work

## Explicit non-goals

- Stage 4 thin-skill reshape work
- per-task file protocol design
- contract convergence work beyond what is needed to keep Stage 3 coherent
- broad process expansion outside the staged plan
- multi-round automation
- self-hosting tasks
- Ralph loop

## Next single action

Close remaining dispatch/handoff gaps in the current workflow surfaces and prepare the next runnable smoke validation step.

## Stage exit criteria

Stage 3 is done when:
- dispatch/handoff gaps in the current workflow surfaces are closed
- no role simulation remains in `main`
- the runtime workflow surfaces are complete for the current stage
- file-backed handoffs are confirmed for all seams
