# PGE Complexity Report Template

Use this structure by default for complexity analysis, audit, scan, review, or report requests.

## Complexity Report

- scope: `<path | staged | commit | diff | symbol | chain>`
- mode: `report-only`
- scanner: `<ran | skipped + reason>`
- stack detected: `<language/framework>`
- test/build commands detected: `<commands or unknown>`
- files modified: `no` unless explicitly requested

## Best Opportunities

1. `<file:line>` — `<short title>`
   - decision: `recommended now | needs measurement | defer | do not optimize`
   - why this ranks here: `<impact/confidence/safety/proof-cost/blast-radius>`
   - expected gain: `<complexity/runtime/memory/readability>`
   - implementation checkpoint: `<first safe implementation step>`
   - correctness gate: `<invariant + test that must pass before benchmark>`
   - rollback signal: `<metric/test/symptom that means revert>`
   - files likely touched: `<paths>`

## Findings

For each finding:

- location:
- signal:
- data-size driver:
- current complexity:
- proposed complexity:
- amplification point:
- expensive boundary:
- state complexity:
- attribution: `new | touched | pre-existing nearby | outside scope | not_applicable`
- correctness invariant:
- recommendation:
- expected impact:
- risk:
- tests needed:
- decision: `recommended now | needs measurement | defer | do not optimize`

## Not Changing

- `<finding/area>` — `<why not>`

## Changes Made

Only include when user explicitly requested implementation.

- files changed:
- main algorithmic change:
- complexity before:
- complexity after:
- correctness invariant preserved:

## Verification

- correctness tests run:
- build/type/lint run:
- benchmark or measurement:
- residual risk:
