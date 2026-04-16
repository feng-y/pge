# progress.md

Use this file when maintaining state across multiple rounds.

`progress.md` is maintained by Main / Scheduler and should stay short.

## What `progress.md` should record

- current phase,
- current task,
- current boundary,
- latest deliverable,
- latest evaluation verdict,
- open blockers,
- next planned step.

## What `progress.md` should not become

Do **not** turn `progress.md` into:
- a diary,
- a design doc,
- a full transcript,
- a backlog dump,
- a pseudo-plan for future phases.

Its job is to preserve the current execution state across rounds.

## Update points

Main / Scheduler should update `progress.md` at these points:
1. after contract freeze,
2. after the Generator returns the current deliverable,
3. after each evaluation round,
4. after convergence decides continue / retry / shrink / handoff.

## Why this matters

Without `progress.md`, state leaks back into conversational memory and each round risks reopening settled context.

A good `progress.md` lets the next round start from confirmed state instead of re-inflated discussion.
