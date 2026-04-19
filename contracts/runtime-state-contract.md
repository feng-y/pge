# Runtime State Contract

## purpose
This contract defines the minimum explicit state record for one PGE run.

## state record
A run state must carry:
- `run_id`
- `round_id`
- `state`
- `upstream_plan_ref`
- `active_round_contract_ref`
- `latest_deliverable_ref`
- `latest_evidence_ref`
- `latest_evaluation_verdict`
- `latest_route`
- `unverified_areas`
- `accepted_deviations`
- `route_reason`
- `convergence_reason`

## minimum states
- `intake_pending`
- `planning_round`
- `ready_to_generate`
- `generating`
- `awaiting_evaluation`
- `evaluating`
- `routing`
- `converged`
- `failed_upstream`

## allowed transitions
- `intake_pending -> planning_round`
- `intake_pending -> failed_upstream`
- `planning_round -> ready_to_generate`
- `planning_round -> failed_upstream`
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

## non-goals
- defining planner behavior
- defining generator behavior
- defining evaluator behavior
- storing full artifacts inside the state record
