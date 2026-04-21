# Validation Task: Add examples section to entry-contract.md

## Goal

Add a concrete examples section to `contracts/entry-contract.md` to make entry criteria more actionable.

## Boundary

Only modify `contracts/entry-contract.md`. Do not change other contract files or agent files.

## Deliverable

Updated `contracts/entry-contract.md` with a new `## examples` section showing:
- One example of accepted upstream input
- One example of rejected upstream input

## Verification Path

1. File `contracts/entry-contract.md` contains new `## examples` section
2. Examples section has at least 2 concrete examples (accepted + rejected)
3. Examples align with the existing entry criteria
4. No other files modified

## Acceptance Criteria

- `contracts/entry-contract.md` has new `## examples` section
- Section contains at least one accepted example
- Section contains at least one rejected example
- Examples are concrete (not abstract)
- File syntax is valid markdown

## Required Evidence

- Path to modified file
- Line count before/after
- Grep output showing new `## examples` section exists
- Git diff showing only `contracts/entry-contract.md` changed

## Run Stop Condition

`single_round`

## Task Type

Bounded repo-internal documentation improvement
