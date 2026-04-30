# Runtime State Contract

Archived future-design note:
This file is not part of the current executable lane.
Current execution uses planner/generator/evaluator artifacts plus the shared progress log instead of a required runtime state file.

## purpose
This contract defines the minimum explicit state record for one PGE run.

## framing
This file is the normative semantic superset for runtime state.

It defines the richer state vocabulary and transition semantics that PGE should preserve across stages, even when the currently executable runtime only implements a smaller subset.

The current executable subset for `pge-execute` lives in `skills/pge-execute/runtime/artifacts-and-state.md` and `skills/pge-execute/ORCHESTRATION.md`.

## state identity seams
A runtime state must distinguish:
- `upstream_plan_ref`: the higher-level plan or proving packet that authorized the run
- `active_slice_ref`: the currently active bounded slice under that upstream plan
- `active_round_contract_ref`: the exact current round contract being executed now

## state record
A run state must carry:
- `run_id`
- `round_id`
- `state`
- `upstream_plan_ref`
- `active_slice_ref`
- `active_round_contract_ref`
- `latest_preflight_result`
- `run_stop_condition`
- `latest_deliverable_ref`
- `latest_evidence_ref` — points to the current generator evidence bundle for the active round; when stored as a fragment reference it should resolve into the generator artifact rather than a separate evidence file
- `latest_evaluation_verdict`
- `latest_route`
- `unverified_areas`
- `accepted_deviations`
- `route_reason`
- `convergence_reason`

## identity meanings
- `upstream_plan_ref` stays stable while multiple bounded slices are executed under the same higher-level plan
- `active_slice_ref` changes when the run moves from one bounded slice to another under the same upstream plan
- `active_round_contract_ref` changes whenever Planner freezes a new current round contract, even inside the same slice

## stop condition meaning
- `run_stop_condition` defines when an accepted round should route to `converged` instead of `continue`
- this field is set at run initialization from the upstream plan or explicit run input
- typical values: `single_round`, `slice_complete`, `goal_satisfied`, `deliverable_count:N`, or a named stopping criterion
- Router uses this field plus current round state to decide `continue` vs `converged` mechanically

## preflight result meaning
- `latest_preflight_result` records the latest explicit preflight outcome for the active frozen round contract
- use `pass` when the frozen round is executable without guessing and independently evaluable as written
- use `fail` when preflight returns the run to planning before generation starts
- preserve this field when transitioning from `preflight_failed` back to `planning_round` so the failed pre-generation trace remains explicit in runtime state

## minimum states
- `intake_pending`
- `planning_round`
- `preflight_pending`
- `preflight_failed`
- `ready_to_generate`
- `generating`
- `awaiting_evaluation`
- `evaluating`
- `routing`
- `unsupported_route`
- `artifact_gate_failed`
- `converged`
- `failed_upstream`

## lifecycle mapping for Stage 2
- `bootstrap` covers `intake_pending`, entry validation, and transition into `planning_round`
- `dispatch` covers planner/generator/evaluator dispatch across `planning_round`, `ready_to_generate`, `generating`, `awaiting_evaluation`, `evaluating`, and `routing`
- `handoff` covers the file-backed artifact gates between planner, generator, and evaluator seams
- `teardown` covers terminal stop behavior for `converged` and `unsupported_route`

This lifecycle mapping is the minimal runtime-team lifecycle for the current stage. It does not imply automatic multi-round execution.

## preflight states meaning
- `preflight_pending`: round contract is frozen, awaiting preflight/contract-ack confirmation
- `preflight_failed`: preflight determined the frozen contract is not executable or not independently evaluable as written
- preflight is the lightweight check that confirms the frozen round contract can be executed without guessing and evaluated independently before Generator starts

## allowed transitions
- `intake_pending -> planning_round`
- `intake_pending -> failed_upstream`
- `planning_round -> preflight_pending`
- `planning_round -> failed_upstream`
- `preflight_pending -> ready_to_generate`
- `preflight_pending -> preflight_failed`
- `preflight_failed -> planning_round`
- `ready_to_generate -> generating`
- `generating -> awaiting_evaluation`
- `generating -> artifact_gate_failed`
- `awaiting_evaluation -> evaluating`
- `evaluating -> routing`
- `evaluating -> artifact_gate_failed`
- `routing -> unsupported_route`
- `routing -> converged`

## transition rule
A state change is valid only when the route reason is explicit.

For the current stage, `continue`, `retry`, and `return_to_planner` remain canonical route tokens but are not yet automatic runtime transitions. If one of those routes is selected, runtime must stop explicitly at `unsupported_route` rather than silently redispatching.

## identity update rule
- keep `upstream_plan_ref` stable unless the run is re-entered from a different upstream plan
- keep `active_slice_ref` stable while the bounded proving target remains the same
- update `active_round_contract_ref` whenever Planner freezes a new current round contract

## slice progression rule
If the runtime continues under the same upstream plan but changes the bounded proving target,
`active_slice_ref` must be updated even when `upstream_plan_ref` remains unchanged.

## non-goals
- defining planner behavior
- defining generator behavior
- defining evaluator behavior
- storing full artifacts inside the state record
