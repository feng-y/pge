# CURRENT_STEP

## Active stage

Stage 3 — Team dispatch / handoff closure

## Current step

Identify and close any remaining dispatch/handoff gaps in the runtime workflow surfaces.

## Why this step matters now

Stage 2 proved the minimal runtime bootstrap path works end-to-end through two successful smoke runs. The lifecycle (bootstrap, dispatch, handoff, teardown) is exercised and repeatable. The next step is to ensure the runtime workflow surfaces are complete and no role simulation remains in `main`.

## Done when

- All dispatch/handoff gaps identified from the Stage 2 smoke runs are closed
- No role simulation remains in `main`
- The runtime workflow surfaces are complete for the current stage

## Inputs to read

1. `docs/exec-plans/CURRENT_MAINLINE.md`
2. `docs/exec-plans/STAGE_PROGRESS.md`
3. `docs/exec-plans/CURRENT_STEP.md`
4. `skills/pge-execute/SKILL.md`
5. `skills/pge-execute/ORCHESTRATION.md`
6. `.claude-plugin/plugin.json`
7. Stage 2 smoke run artifacts for gap analysis

## Non-goals

- implementing full smoke-run business capability
- redesigning the skill
- redesigning the agents
- reworking install/discovery
- introducing the per-task file protocol
- doing contract convergence as active work
- broadening into Stage 4+

## Evidence to collect

- Gap analysis from Stage 2 smoke runs
- Identification of any role simulation in `main`
- Verification that all dispatch/handoff seams are file-backed

## Blockers

- none currently known

## Next step after completion

Move to Stage 4 — Thin skill reshape.
