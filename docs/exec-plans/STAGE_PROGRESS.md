# STAGE_PROGRESS

## Current mainline

Make `pge-execute` a runnable thin skill with persistent runtime `pge-planner` / `pge-generator` / `pge-evaluator` teammates.

## One active stage

- **Active:** Stage 2 — Runtime team bootstrap

## Stage status

- **Stage 0 — Freeze mainline** — done
  - Exit criteria met: the repo has one settled architecture target and the control plane now treats scope drift as a failure mode.
- **Stage 1 — Runtime install/discovery** — done
  - Exit criteria met: plugin packaging/discovery artifacts exist and the runtime-facing skill/agent surface is already present in repo state.
- **Stage 2 — Runtime team bootstrap** — active
  - Exit criteria:
    - define the minimal runtime lifecycle for `pge-execute`
    - make `main` the real team lead / orchestration shell
    - make `pge-planner`, `pge-generator`, and `pge-evaluator` the real runtime teammates
    - make bootstrap, dispatch, handoff, and teardown explicit
- **Stage 3 — Team dispatch / handoff closure** — pending
  - Exit criteria: dispatch and handoff behavior are implemented against the Stage 2 lifecycle without role simulation in `main`.
- **Stage 4 — Thin skill reshape** — pending
  - Exit criteria: `SKILL.md` is reduced to a runnable dispatcher and supporting workflow files carry the heavier runtime detail.
- **Stage 5 — Per-task file protocol** — pending
  - Exit criteria: per-task artifact conventions are introduced only after the lifecycle and dispatch path are stable.
- **Stage 6 — Contract convergence** — pending
  - Exit criteria: canonical and runtime-facing contracts are intentionally reconciled after the runtime workflow shape is stable.
- **Stage 7 — Smoke run** — pending
  - Exit criteria: the staged runtime path completes an end-to-end proving run on the thin-skill architecture.
- **Stage 8 — Post-smoke stabilization** — pending
  - Exit criteria: only issues exposed by the smoke run are addressed; no architecture reopening.

## Why Stage 2 is active now

Stage 1 is no longer the bottleneck. The repo already exposes the plugin, skill, and runtime teammate surface. The next coordination-saving move is to make the runtime team lifecycle the single active target.

## Backlog for deferred issues

- Stage 3: route-specific dispatch and handoff closure
- Stage 4: further thinning of `skills/pge-execute/SKILL.md`
- Stage 5: per-task file protocol
- Stage 6: contract convergence and drift-control hardening
- Stage 7: smoke-run proving
- Stage 8: stabilization from real run evidence

## Current step pointer

The only current step is tracked in `docs/exec-plans/CURRENT_STEP.md`.
