# CURRENT_MAINLINE

## Current overall goal

Get `feat/pge-agents-contracts-skeleton` into its first real Phase 1 proving run.

## Current stage goal

Execute the MVP in three bounded rounds as defined in `docs/exec-plans/MVP_EXECUTION_PLAN.md`.

## Current P0 blockers

Generator and Evaluator agents are stubs - they produce test artifacts instead of executing real work. Exposed in post-MVP proving round 004.

## Explicit non-goals for this stage

- multi-round task execution
- Phase 2/3 harness expansion
- runtime state persistence beyond one round
- error recovery or retry logic
- parallel workstream support
- external proving tasks (only repo-internal for MVP)

## Next single action

Implement real generator and evaluator agents that execute actual work instead of producing stub artifacts.

## Round completion criteria

The MVP stage is done when:
- Round 3 succeeds with a real repo-internal task
- the skill routes to `converged` when the reviewer accepts
- the skill stops cleanly after convergence without manual intervention
