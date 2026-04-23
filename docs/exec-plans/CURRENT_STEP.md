# CURRENT_STEP

## Active stage

Stage 2 — Runtime team bootstrap

## Current step

Define and validate the minimal runtime team lifecycle for `pge-execute`.

## Why this step matters now

This is the smallest meaningful unit inside Stage 2. Until the runtime lifecycle is explicit, future rounds will keep re-deciding install status, runtime ownership, and what `main` versus the runtime teammates are supposed to do.

## Done when

- one minimal lifecycle is fixed for the current stage
- that lifecycle explicitly covers `bootstrap`, `dispatch`, `handoff`, and `teardown`
- `main` is explicitly the team lead / orchestration shell in that lifecycle
- `pge-planner`, `pge-generator`, and `pge-evaluator` are explicitly the only runtime teammates in that lifecycle
- the next round can implement against the lifecycle without reopening stage selection, install scope, skill semantics, or agent semantics

## Inputs to read

1. `docs/exec-plans/CURRENT_MAINLINE.md`
2. `docs/exec-plans/STAGE_PROGRESS.md`
3. `docs/exec-plans/CURRENT_STEP.md`
4. `skills/pge-execute/SKILL.md`
5. `skills/pge-execute/ORCHESTRATION.md`
6. `.claude-plugin/plugin.json`
7. only the minimal additional source-of-truth files needed to resolve a direct contradiction for this step

## Non-goals

- implementing runtime behavior in this step
- redesigning the skill
- redesigning the agents
- reworking install/discovery
- introducing the per-task file protocol
- doing contract convergence as active work
- running the smoke path

## Evidence to collect

- a lifecycle description that explicitly names `bootstrap`, `dispatch`, `handoff`, and `teardown`
- a clear ownership split between `main` and the three runtime teammates
- a clear statement of what is intentionally deferred to later stages
- proof that a future round can identify one mainline, one active stage, one current step, and one next step from the control plane alone

## Blockers

- none currently known

## Next step after completion

Implement the Stage 2 runtime team lifecycle in the runtime workflow surfaces without changing the staged control-plane shape.
