# Runtime Event Contract

## purpose

This contract defines the only runtime events that may advance `main`.

`main` must not advance from a mix of ad-hoc shell polling, artifact existence alone, mailbox filenames, or phase-name folklore.

Artifacts remain durable side effects. Events are the progression contract.

## progression rule

`main` advances only when it receives a valid runtime event defined here.

When an event references a durable artifact:
- the event is the progression trigger
- the artifact gate validates the referenced durable side effect
- artifact existence alone is never enough to advance

## event source rule

Events may arrive through Agent Teams `SendMessage` or an equivalent runtime delivery mechanism.

The transport is not the contract. The event shape is the contract.

## planner event

### `planner_contract_ready`

Producer: `planner`

Required fields:
- `type: planner_contract_ready`
- `planner_artifact`
- `planner_note`
- `planner_escalation`
- `ready_for_preflight: true`

Meaning:
- Planner finished the current-round contract
- `main` may now gate `planner_artifact` and enter cost gate / preflight

## cost gate event

### `mode_decision`

Producer: `evaluator`

Required fields:
- `type: mode_decision`
- `preflight_verdict`
- `execution_mode`
- `fast_finish_approved`
- `next_route`
- `requires_durable_proposal`
- `requires_durable_preflight`
- `reason`

Allowed `execution_mode`:
- `FAST_PATH`
- `LITE_PGE`
- `FULL_PGE`
- `LONG_RUNNING_PGE`

Meaning:
- Evaluator has made the execution cost-gate decision
- `main` updates runtime state from this event
- if `requires_durable_proposal = false` and `requires_durable_preflight = false`, `main` must not wait for those artifacts

## proposal event

### `proposal_ready`

Producer: `generator`

Required fields:
- `type: proposal_ready`
- `contract_proposal_artifact`
- `preflight_status`
- `unresolved_blockers`

Meaning:
- Generator finished the durable proposal required for non-FAST preflight
- `main` may gate `contract_proposal_artifact` and request Evaluator preflight review

## preflight decision event

### `preflight_decision`

Producer: `evaluator`

Required fields:
- `type: preflight_decision`
- `preflight_verdict`
- `execution_mode`
- `repair_owner`
- `next_route`
- `preflight_artifact`
- `reason`

Meaning:
- Evaluator completed non-FAST preflight review
- `main` may gate `preflight_artifact` when one is required and then route to generation or stop

## generation event

### `generator_completion`

Producer: `generator`

Required fields:
- `type: generator_completion`
- `handoff_status`
- `deliverable_path`
- `verification_result`
- `generator_artifact`

Meaning:
- Generator finished the real deliverable
- `generator_artifact` may be `null` in `FAST_PATH`
- `main` may gate the deliverable and any required durable Generator output, then request final evaluation

## evaluation event

### `final_verdict`

Producer: `evaluator`

Required fields:
- `type: final_verdict`
- `verdict`
- `next_route`
- `evaluator_artifact`
- `route_reason`

Meaning:
- Evaluator completed final independent validation
- `main` may gate `evaluator_artifact` and then perform route selection

## route event

### `route_selected`

Producer: `main`

Required fields:
- `type: route_selected`
- `verdict`
- `route`
- `state`
- `reason`

Meaning:
- `main` finalized the bounded run route decision
- this is the final progression event before teardown

## forbidden progression inputs

`main` must not advance solely because:
- an artifact file exists
- a shell polling command succeeds
- a mailbox path exists
- a teammate writes narrative text without a valid event shape
- a phase name suggests a likely next step

## current-stage note

The current implementation stage still uses artifact gates for durable outputs.

That is allowed only as validation after the matching event is received.
