# Runtime Event Contract

## purpose

This contract defines the only runtime events that may advance `main` in the current executable lane.

`main` must not advance from ad-hoc shell polling, artifact existence alone, progress-log lines, or phase-name folklore.

## progression rule

`main` advances only when it receives a valid runtime event defined here.

When an event references a durable artifact:
- the event is the progression trigger
- the artifact gate validates the durable side effect
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
- `ready_for_generation: true`

Meaning:
- Planner finished the current-round contract
- `main` may gate `planner_artifact` and dispatch Generator

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
- `generator_artifact` may be `null` for very small deterministic tasks
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
- `reason`

Meaning:
- `main` finalized the bounded run route decision
- this is the final progression event before teardown

## forbidden progression inputs

`main` must not advance solely because:
- an artifact file exists
- a shell polling command succeeds
- a progress-log line exists
- a teammate writes narrative text without a valid event shape
- a phase name suggests a likely next step

## current-stage note

The current executable lane uses one skeleton: `planner -> generator -> evaluator`.

Task scale changes how much work each role performs, not which extra runtime events are required.
