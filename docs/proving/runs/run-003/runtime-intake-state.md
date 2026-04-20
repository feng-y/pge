# run-003 runtime intake state

## Purpose

Freeze the first runtime intake/state artifact for the first real bounded proving/development round using the verified upstream packet in `../run-002/upstream-plan.md`.

## Upstream linkage

- `upstream_plan_ref`: `run-002/upstream-plan`
- `active_slice_ref`: `slice-001-entry-gate-proof`
- `active_round_contract_ref`: `round-001-entry-gate-packet`

## Runtime state record

- `run_id`: `run-003`
- `round_id`: `round-01`
- `state`: `intake_pending`
- `upstream_plan_ref`: `run-002/upstream-plan`
- `active_slice_ref`: `slice-001-entry-gate-proof`
- `active_round_contract_ref`: `round-001-entry-gate-packet`
- `latest_preflight_result`: `unset`
- `run_stop_condition`: `single_round`
- `latest_deliverable_ref`: `unset`
- `latest_evidence_ref`: `unset`
- `latest_evaluation_verdict`: `unset`
- `latest_route`: `unset`
- `unverified_areas`: `[]`
- `accepted_deviations`: `[]`
- `route_reason`: `entry packet accepted; first runtime intake/state artifact frozen`
- `convergence_reason`: `unset`

## Identity meaning check

- `upstream_plan_ref` stays stable for the whole proving run authorized by `run-002/upstream-plan`
- `active_slice_ref` identifies the current bounded proving target: entry-gate proof
- `active_round_contract_ref` identifies the exact current round contract to be frozen next from this intake state

## State transition expectation

The next valid transition is:

- `intake_pending -> planning_round`

The transition is valid only if the next round freezes the first current round contract with an explicit route reason.

## Verification path

Check this artifact against `contracts/runtime-state-contract.md` for:

- required identity seams
- complete state record fields
- valid minimum state name
- explicit `run_stop_condition`
- explicit `route_reason`
- no artifact payloads embedded beyond named refs and empty placeholders

## No-touch boundary

- `agents/*.md`
- `contracts/*.md`
- `skills/pge-execute/SKILL.md`
- command entrypoints
- proving README

## Handoff seam

If this state artifact passes runtime-state verification, the next round may freeze the first current round contract for `planning_round` without reopening the upstream packet or redoing intake state naming.
