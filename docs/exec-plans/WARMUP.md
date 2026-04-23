# WARMUP

Warmup is mandatory before any new implementation round.

## Required read order

1. `docs/exec-plans/CURRENT_MAINLINE.md`
2. `docs/exec-plans/STAGE_PROGRESS.md`
3. `docs/exec-plans/CURRENT_STEP.md`
4. the minimum source-of-truth files for the active step

For the current step, read:
- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `.claude-plugin/plugin.json`

Read additional files only if they are needed to resolve a concrete contradiction for the active step.

## Required pre-implementation report

Before editing code, report all of the following:
- current mainline
- active stage
- current step
- done-when for the current step
- explicit non-goals for the current step

If any of those are unclear after warmup, stop and repair the control plane before implementation.

## Warmup guardrails

- do not reopen settled architecture during warmup
- do not reactivate completed stages
- do not start multiple current steps
- do not jump ahead to later-stage concerns unless the current step is blocked by a direct contradiction

## Purpose

Warmup exists to reduce coordination overhead. A future round should be able to read these files and know what to do now, what not to do now, what evidence to collect, and what comes next.
