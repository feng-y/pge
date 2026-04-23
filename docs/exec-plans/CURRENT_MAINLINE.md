# CURRENT_MAINLINE

## Current mainline

Make `pge-execute` a runnable thin skill with persistent runtime `pge-planner` / `pge-generator` / `pge-evaluator` teammates.

## Why this is the mainline

Repo evidence already supports the install/discovery baseline:
- `.claude-plugin/plugin.json` declares the plugin package and runtime agent entries
- `skills/pge-execute/SKILL.md` is already framed as a bounded execution entrypoint
- `skills/pge-execute/ORCHESTRATION.md` already defines `main` as the skill-internal orchestration shell

So the active problem is no longer install work. The active problem is making the runtime team lifecycle explicit enough that future implementation rounds can proceed without re-deciding the architecture.

## Active stage

Stage 2 — Runtime team bootstrap

## Current blocker

The thin-skill runtime-team direction is settled, but the minimal runtime team lifecycle is not yet captured as the single active implementation target for the next round.

## What this round is optimizing for

- keep `SKILL.md` thin
- keep `main` as the orchestration shell, not a peer agent
- treat `pge-planner`, `pge-generator`, and `pge-evaluator` as the persistent runtime teammates
- make bootstrap, dispatch, handoff, and teardown the runtime lifecycle backbone
- remove stage ambiguity so future rounds do not reopen install work or broader architecture

## Explicit non-goals

- more install or discovery work
- broad runtime implementation beyond the active step
- multi-round automation
- per-task file protocol design
- contract convergence work beyond what is needed to keep the current stage coherent
- broad process expansion outside the staged plan

## Next single action

Use `docs/exec-plans/CURRENT_STEP.md` to define and validate the minimal runtime team lifecycle for `pge-execute`.

## Stage exit criteria

Stage 2 is done when:
- `main` is unambiguously framed as the runtime team lead / orchestration shell
- runtime teammates are unambiguously `pge-planner`, `pge-generator`, and `pge-evaluator`
- the minimal lifecycle covers bootstrap, dispatch, handoff, and teardown
- the next implementation round can collect concrete lifecycle evidence without reopening architecture or install scope
