# start-round

Use this command to start one bounded proving/development round.

## Required reads

Before doing anything else, read these files in order:

1. `docs/exec-plans/CURRENT_MAINLINE.md`
2. `docs/exec-plans/ISSUES_LEDGER.md`
3. `docs/proving/README.md`

## Required behavior

After the required reads:

1. identify the current single P0-only round goal
2. name the expected artifact for the round
3. classify the active issue as P0 / P1 / P2
4. create or update one bounded round record using `docs/exec-plans/ROUND_TEMPLATE.md`
5. keep the round scoped to one goal, one deliverable, and one primary verification path
6. stop after the round is defined

## Prohibitions

Do not:

- reopen broad design
- expand P1 or P2 work in the active round
- add extra process machinery
- continue into optimization after the bounded round is fixed
