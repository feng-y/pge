# WARMUP

Warmup is mandatory before every future implementation round.

## Required read order

Always read these files first, in this order:

1. `docs/exec-plans/CURRENT_MAINLINE.md`
2. `docs/exec-plans/STAGE_PROGRESS.md`
3. `docs/exec-plans/CURRENT_STEP.md`
4. `skills/pge-execute/SKILL.md`
5. `skills/pge-execute/ORCHESTRATION.md`
6. `.claude-plugin/plugin.json`

After that, read only the minimal additional source-of-truth files needed for the current step.

## Required warmup report

Before implementation starts, report all of the following:

- current mainline
- active stage
- current step
- done-when
- non-goals

If any item is unclear after warmup, stop and repair the control plane before implementation.

## Warmup guardrails

- do not create a parallel planning system
- do not reopen settled architecture during warmup
- do not reactivate completed stages
- do not start multiple current steps
- do not read broad supporting materials unless the current step needs them as source of truth
- do not jump ahead to later-stage concerns unless the current step is blocked by a direct contradiction

## Purpose

Warmup exists so a future Claude Code round can read a small fixed set of files, restate the current execution target, and know exactly what to do next without reopening the architecture.
