# run-004 current round contract

## Task name

Freeze the first current round contract for `planning_round`.

## Why this belongs to the current phase

`run-002/upstream-plan.md` and `run-003/runtime-intake-state.md` already define the execute-first packet and the intake state anchor. The missing bounded artifact is the first explicit current round contract that Planner would hand to Generator.

## Boundary

Only freeze the first current round contract for the already verified runtime intake/state artifact.

## Deliverable

One handoff-ready current round contract for the first real bounded proving/development round.

## Validation baseline

Check the artifact against `contracts/round-contract.md`.

## Non-goals

- changing upstream packet semantics
- changing runtime-state semantics
- redesigning agent roles
- defining later rounds

## Handoff / seam

If accepted, Generator may use this contract to produce the first bounded deliverable without reopening upstream planning.

## Blockers / needs confirmation

None.

## Plan fidelity

This contract stays inside the existing execute-first chain:

- upstream packet verified in `run-002`
- runtime intake/state artifact verified in `run-003`
- current round contract frozen here

## Quality bar

The contract must be executable without guessing and independently evaluable as written.

## Required validation evidence

A field-by-field check against `contracts/round-contract.md`.

## Ambiguity stop rule

If any required round field cannot be named concretely from the existing upstream packet and runtime state, stop instead of guessing.

## Frozen current round contract

- `goal`: freeze the first handoff-ready current round contract for real proving execution
- `boundary`: only the first current round contract and its immediate deliverable/evidence references are in scope
- `deliverable`: one generator-ready round contract packet
- `verification_path`: field-by-field check against `contracts/round-contract.md`
- `acceptance_criteria`: all required round-contract fields exist and name one executable bounded round
- `required_evidence`: the contract text itself plus explicit field coverage against `contracts/round-contract.md`
- `allowed_deviation_policy`: no semantic deviation is accepted in this round; missing fields are blocking
- `no_touch_boundary`: `agents/*.md`, `contracts/*.md`, `skills/pge-execute/SKILL.md`, command entrypoints, proving README
- `handoff_seam`: Generator can execute the contract and produce one bounded deliverable with one primary verification path
