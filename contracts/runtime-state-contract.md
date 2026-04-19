# Runtime State Contract

## purpose
This contract defines the minimum explicit state record for one PGE run.

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
- `run_stop_condition`
- `latest_deliverable_ref`
- `latest_evidence_ref`
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
- `converged`
- `failed_upstream`

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
- `generating -> routing`
- `awaiting_evaluation -> evaluating`
- `evaluating -> routing`
- `routing -> planning_round`
- `routing -> generating`
- `routing -> converged`

## transition rule
A state change is valid only when the route reason is explicit.

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
