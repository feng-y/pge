# CURRENT_MAINLINE

## Current overall goal

Get `feat/pge-agents-contracts-skeleton` into its first real Phase 1 proving run.

## Current stage goal

Stop expanding design and use the existing skeleton to run one real proving/development loop.

## Current P0 blockers

1. No active P0 blocker prevents starting the `run-001` workflow loop.

## Explicit non-goals for this round

- broad harness redesign
- naming cleanup
- semantic polishing without a proving blocker
- Phase 2 / Phase 3 planning
- expanding P1 / P2 items during the active round

## Next single action

Use `docs/proving/runs/run-001/` plus `commands/start-round.md` and `commands/close-round.md` to start the first real bounded proving/development round.

## Round completion criteria

This support round is done when:
- repo-level working constraints are visible to Claude Code
- the mainline, blockers, and non-goals are recorded in one place
- the repo has a reusable round template and proving entrypoint

After this round lands, the next round should execute the first real bounded proving task using the `run-001` pack and command entrypoints.
