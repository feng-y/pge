# run-001

## Objective

Prove that this repo can drive one bounded proving round end-to-end using the existing control-plane documents without reopening harness design.

## Why this run exists

The repo already has enough support-layer control artifacts to start a real proving/development loop. `run-001` is the first narrow run that turns that support surface into an executable workflow.

## First proving task

> Start and close one bounded repo-internal proving round using the existing control-plane documents, and leave behind the expected round artifacts without expanding scope.

This task validates workflow driveability, not harness completeness.

## Scope

- fix the first proving task explicitly
- record two bounded rounds
- add `commands/start-round.md`
- add `commands/close-round.md`
- update `docs/exec-plans/CURRENT_MAINLINE.md` if the next action changes
- update `docs/exec-plans/ISSUES_LEDGER.md` if issue state changes

## Success criteria

This run succeeds if all of the following are true:

- the first proving task is explicitly named in repo artifacts
- `round-01.md` records the task-fix round
- `round-02.md` records the workflow-close round
- `commands/start-round.md` and `commands/close-round.md` exist as thin operational entrypoints
- the current mainline and issue ledger reflect the new state
- the round stops after the workflow becomes executable

## Non-scope

- harness redesign
- broader strategy expansion
- normalized seam redesign under `agents/`, `contracts/`, or `skills/`
- adding more process machinery beyond the two thin command entrypoints
- starting a second proving task in this run

## Governing artifacts

This run is governed by:

- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`
- `docs/exec-plans/ROUND_TEMPLATE.md`
- `docs/proving/README.md`
