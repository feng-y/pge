# Proving / Development Runs

## What a run is in this repo

A proving/development run is one bounded loop that uses the current PGE skeleton to move the mainline forward with the smallest viable step.

The purpose is not to perfect the harness design. The purpose is to run real work, expose real blockers, and only repair what proving actually needs.

## Entry criteria

Start a run only when all of the following are true:
- the current mainline is clear
- the next single action is clear
- the round goal is bounded
- the expected artifact for the round is named
- the active blocker, if any, is identified as P0 / P1 / P2

Use `docs/exec-plans/CURRENT_MAINLINE.md` and `docs/exec-plans/ISSUES_LEDGER.md` before starting.

## What artifacts a run must leave behind

Each run should leave behind:
- an updated `docs/exec-plans/CURRENT_MAINLINE.md` if the mainline or next action changed
- an updated `docs/exec-plans/ISSUES_LEDGER.md` if issues were discovered, resolved, or reclassified
- a round record using `docs/exec-plans/ROUND_TEMPLATE.md` in the working response or a dedicated round note if needed
- the actual repo artifact produced by the round, if any

## How success vs failure is recorded

### Success
Record success when the round goal is completed without opening a new P0 blocker.

### Stable failure
Record a stable failure when the round cannot complete, but the blocking condition is now explicit enough to classify and drive the next repair round.

A stable failed loop is still useful progress if it makes the blocker concrete.

## How discovered issues should be classified

- **P0 / Blocker** — cannot continue the current proving/development run without addressing it
- **P1 / Follow-up** — useful and maybe necessary later, but does not block the current run
- **P2 / Park** — record only; do not expand in the current stage

## Done for this round

A round is done when one of these is true:
- the intended bounded artifact was produced
- the blocker was removed and the next proving action is clear
- the run produced a stable failed loop with the blocker explicitly recorded

When the round is done, stop. Do not keep expanding scope inside the same round.
