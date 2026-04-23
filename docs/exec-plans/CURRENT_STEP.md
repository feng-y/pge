# CURRENT_STEP

## Active stage

Stage 2 — Runtime team bootstrap

## Current step

Implement and validate the minimal runtime bootstrap path for `pge-execute`.

## Why this step matters now

This is the smallest meaningful implementation unit inside Stage 2. The lifecycle is already defined; the missing proof is that `main` can enter the runtime path, dispatch the installed teammates, persist file-backed handoffs, and stop through explicit teardown.

## Done when

- the minimal Stage 2 lifecycle is exercised through `bootstrap`, `dispatch`, `handoff`, and `teardown`
- `main` enters the runtime path as the orchestration shell
- installed `pge-planner`, `pge-generator`, and `pge-evaluator` are actually dispatched
- planner, generator, evaluator, runtime-state, and terminal teardown artifacts are persisted for one bounded run
- one minimal smoke check proves the lifecycle is exercised without broadening into Stage 3+ or full smoke-run quality claims

## Inputs to read

1. `docs/exec-plans/CURRENT_MAINLINE.md`
2. `docs/exec-plans/STAGE_PROGRESS.md`
3. `docs/exec-plans/CURRENT_STEP.md`
4. `skills/pge-execute/SKILL.md`
5. `skills/pge-execute/ORCHESTRATION.md`
6. `.claude-plugin/plugin.json`
7. only the minimal additional source-of-truth files needed to resolve a direct contradiction for this step

## Non-goals

- implementing full smoke-run business capability
- redesigning the skill
- redesigning the agents
- reworking install/discovery
- introducing the per-task file protocol
- doing contract convergence as active work
- broadening into Stage 3+

## Evidence to collect

- one run id for the bounded smoke path
- persisted planner, generator, evaluator, runtime-state, and terminal teardown artifacts
- evidence that the installed `pge-planner`, `pge-generator`, and `pge-evaluator` were dispatched
- evidence that handoff happened through persisted artifacts rather than transcript-only state
- evidence that teardown was explicit through runtime-state plus checkpoint or summary output

## Blockers

- none currently known

## Next step after completion

Close the remaining Stage 2 implementation gaps without broadening into Stage 3 dispatch-loop behavior.
