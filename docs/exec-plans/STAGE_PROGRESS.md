# STAGE_PROGRESS

## Current mainline

Make `pge-execute` a runnable thin skill with persistent runtime `pge-planner` / `pge-generator` / `pge-evaluator` teammates.

## Active stage

Stage 3 — Team dispatch / handoff closure

## Stage list

- **Stage 0 — Freeze mainline** — **DONE**
  - Exit criteria: one mainline is fixed; install work is no longer treated as the active problem.
- **Stage 1 — Runtime install/discovery** — **DONE**
  - Exit criteria: `.claude-plugin/plugin.json` declares the plugin package and runtime agent entries, and `skills/pge-execute/` is already the runnable orchestration entry surface.
- **Stage 2 — Runtime team bootstrap** — **DONE**
  - Exit criteria: the minimal runtime team lifecycle for `pge-execute` is fixed with explicit `bootstrap`, `dispatch`, `handoff`, and `teardown`, with `main` as orchestration shell and `pge-planner` / `pge-generator` / `pge-evaluator` as the runtime teammates.
  - **Completion evidence**: Two successful smoke runs (`run-1777010098564`, `run-1777010525846`) proving the runtime bootstrap path works end-to-end with repeatable lifecycle execution.
- **Stage 3 — Team dispatch / handoff closure** — **ACTIVE**
  - Exit criteria: the Stage 2 lifecycle is implemented in the runtime workflow surfaces with file-backed handoffs and no role simulation in `main`.
- **Stage 4 — Thin skill reshape** — **TODO**
  - Exit criteria: `skills/pge-execute/SKILL.md` is reduced to a thin runnable entrypoint while orchestration detail lives in the supporting control-plane seams.
- **Stage 5 — Per-task file protocol** — **TODO**
  - Exit criteria: per-task file protocol is introduced only after the runtime lifecycle and dispatch path are stable.
- **Stage 6 — Contract convergence** — **TODO**
  - Exit criteria: canonical and runtime-facing contracts are reconciled intentionally after the runtime workflow shape is stable.
- **Stage 7 — Smoke run** — **TODO**
  - Exit criteria: the staged runtime path completes one end-to-end proving smoke run on the thin-skill architecture.
- **Stage 8 — Post-smoke stabilization** — **TODO**
  - Exit criteria: only issues exposed by the smoke run are fixed without reopening the architecture.

## Why Stage 3 is active

Stage 2 is complete. The minimal runtime team lifecycle has been proven through two successful smoke runs. The next step is to close any remaining dispatch/handoff gaps in the runtime workflow surfaces.

## Backlog

- Further thinning of `skills/pge-execute/SKILL.md` once runtime lifecycle behavior is implemented.
- Per-task file protocol design.
- Contract convergence and drift-control hardening.
- Smoke-run proving.
- Post-smoke stabilization from real run evidence.

## Notes

- There is exactly one active stage: Stage 3.
- The only current step is tracked in `docs/exec-plans/CURRENT_STEP.md`.
