# CURRENT_STEP

## Active stage

Stage 2 — Runtime team bootstrap

## Current step

Define and validate the minimal runtime team lifecycle for `pge-execute`.

## Why now

This is the smallest meaningful unit inside runtime-team bootstrap. Until the lifecycle is explicit, future rounds will keep mixing architecture, install, dispatch, and skill-shape work.

## Done when

- one minimal lifecycle is fixed for the current stage
- that lifecycle explicitly covers bootstrap, dispatch, handoff, and teardown
- `main` is the team lead / orchestration shell in that lifecycle
- `pge-planner`, `pge-generator`, and `pge-evaluator` are the only runtime teammates in that lifecycle
- the lifecycle is concrete enough that the next round can implement against it without reopening stage selection or architecture wording

## Inputs to read

Mandatory warmup order:
1. `docs/exec-plans/CURRENT_MAINLINE.md`
2. `docs/exec-plans/STAGE_PROGRESS.md`
3. `docs/exec-plans/CURRENT_STEP.md`
4. `skills/pge-execute/SKILL.md`
5. `skills/pge-execute/ORCHESTRATION.md`
6. `.claude-plugin/plugin.json`
7. any one additional file only if needed to resolve a contradiction for this step

## Non-goals

- implementing the full runtime bootstrap in this step
- activating multiple steps inside Stage 2
- reworking install/discovery
- introducing per-task file protocol
- doing contract convergence as an active task
- broadening into smoke-run work

## Evidence to collect

- a lifecycle description that names bootstrap, dispatch, handoff, and teardown explicitly
- a clear ownership split between `main` and the three runtime teammates
- a clear statement of what is deferred to later stages
- proof that future warmup can identify one goal, one stage, one step, and one next step

## Blockers

- none currently known

## Next step

Implement the Stage 2 lifecycle in the runtime workflow surfaces without changing the staged plan shape.
