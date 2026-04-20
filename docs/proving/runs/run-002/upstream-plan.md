# run-002 upstream plan

## Goal

Provide the first real execute-first upstream plan that can enter `skills/pge-execute/SKILL.md` through `contracts/entry-contract.md` without clarify-first repair.

## Boundary

This round defines only the first executable proving input packet for PGE.

It does not change runtime semantics, agent responsibilities, or contract vocabulary.

## Deliverable

A single upstream plan packet for the first real bounded proving/development round.

## Upstream plan packet

- `upstream_plan_ref`: `run-002/upstream-plan`
- `goal`: prove one real bounded PGE intake can be frozen into an executable current round contract without guessing
- `boundary`: only the proving packet and its first frozen round input are in scope
- `deliverable`: one explicit round input packet that names the first active slice and the expected artifact
- `verification_path`: check the packet against `contracts/entry-contract.md`
- `run_stop_condition`: `single_round`

## First active slice

- `active_slice_ref`: `slice-001-entry-gate-proof`
- `slice_goal`: prove that a real execute-first input can satisfy entry requirements and point to one bounded round

## First bounded round input

- `active_round_contract_ref`: `round-001-entry-gate-packet`
- `round_goal`: freeze the first real bounded round packet for PGE intake
- `round_boundary`: only the entry packet and its required state references may be named or updated
- `round_deliverable`: one intake packet that names `upstream_plan_ref`, `active_slice_ref`, `active_round_contract_ref`, and the expected runtime-state fields needed at intake
- `round_verification_path`: confirm the packet has a concrete goal, preserved boundary, named deliverable, plausible verification path, and explicit `run_stop_condition`
- `round_acceptance_criteria`: the packet is executable without clarify-first repair under `contracts/entry-contract.md`
- `round_required_evidence`: the packet text itself plus a field-by-field check against `contracts/entry-contract.md`

## No-touch boundary

- `agents/*.md`
- `contracts/*.md`
- `skills/pge-execute/SKILL.md`
- proving README and command entrypoints

## Handoff seam

If this packet passes entry-gate verification, the next round may freeze the first real runtime intake/state artifact without reopening this upstream plan.
