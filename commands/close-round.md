---
description: Close one bounded proving or development round
---

# close-round

Use this command to close one bounded proving/development round.

## Required updates

At round close:

1. update `docs/exec-plan/CURRENT_MAINLINE.md` if the next action changed
2. update `docs/exec-plan/ISSUES_LEDGER.md` if issues changed, were resolved, or were reclassified
3. record whether the round succeeded or failed stably
4. record the artifact produced
5. record the next action
6. stop once the current bounded round is closed

## Required closure rule

A round may close only when one of these is true:

- the intended bounded artifact was produced
- the blocker was removed and the next proving action is clear
- the run produced a stable failed loop with the blocker explicitly recorded

## Prohibitions

Do not:

- expand into extra optimization after closure
- reopen broader harness design inside the same round
- add new process layers because the round succeeded
