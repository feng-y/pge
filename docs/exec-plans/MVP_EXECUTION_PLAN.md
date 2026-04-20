# MVP Execution Plan

## What is the repo MVP?

A working PGE skill that can execute one real bounded repo-internal task end-to-end through the plan/develop/review loop with explicit slice control, independent acceptance, and convergence routing.

The MVP is complete when:
- one real repo task enters through upstream intake
- the skill drives the task through all three roles (planner, developer, reviewer)
- each role produces its expected artifact
- the skill routes to `converged` under an explicit stop condition
- the round closes with a clean verdict

## Explicit non-scope for MVP

- multi-round task execution
- Phase 2/3 harness expansion
- runtime state persistence beyond one round
- error recovery or retry logic
- parallel workstream support
- external proving tasks (only repo-internal for MVP)

## Next 3 bounded rounds

### Round 1: Wire the skill runtime

**Artifact**: `skills/pge-execute/skill.sh` that can invoke the three role agents and route between them

**Verification**: The skill can be invoked via `/pge` and reaches the planner agent without error

**Stop condition**: The skill entry point exists and the first agent spawns successfully

### Round 2: Complete one role cycle

**Artifact**: One complete planner → developer → reviewer cycle with all three artifacts produced

**Verification**: All three role artifacts exist in the expected locations after one cycle

**Stop condition**: The reviewer produces a verdict and the skill routes based on that verdict

### Round 3: Close the convergence loop

**Artifact**: The skill routes to `converged` when the reviewer accepts, and produces a final round summary

**Verification**: A test task enters, executes, converges, and leaves behind the expected round record

**Stop condition**: The skill stops cleanly after convergence without manual intervention

## MVP stop condition

The MVP is done when Round 3 succeeds with a real repo-internal task.

After MVP, the next work should be:
- proving with external tasks
- multi-round task support
- runtime state refinement based on real proving pain
