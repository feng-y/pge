# Runtime Event Contract

## purpose

This contract defines the canonical runtime notifications that coordinate `main` in the current executable lane.

`main` must not advance from ad-hoc shell polling, artifact existence alone, progress-log lines, or phase-name folklore.

## progression rule

`main` advances a phase only after:
- receiving a valid runtime notification for the currently dispatched teammate
- validating the referenced artifact/data gate for that same phase

When an event references a durable artifact:
- the event is the teammate notification that inspection should start
- the artifact gate validates the durable side effect
- artifact existence alone is never enough to advance

If the expected notification is missing, `main` must not advance from data alone.
Instead, `main` must explicitly ask the currently dispatched teammate to confirm whether the phase is complete and, if complete, to resend the canonical notification shape.

If a teammate confirms completion but the data gate fails, the phase is not accepted and the teammate must repair or re-execute the phase work rather than merely resend the notification.

## event source rule

Notifications may arrive through Agent Teams `SendMessage` or an equivalent runtime delivery mechanism.

The transport is not the contract. The notification shape is the contract.

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

## notification repair rule

If `main` observes non-canonical completion hints from the currently dispatched teammate, such as:
- `idle_notification`
- natural-language summary
- artifact-written claim
- task-completed claim
- recovery / resume recap
- "I already completed task #N" replay

then `main` may use those hints only to initiate a clarification / resend request to that same teammate.

Those hints do not authorize phase advancement by themselves.

When requesting resend, `main` should ask for the canonical notification text only, with no recap, summary wrapper, idle wrapper, or explanatory prefix.

## forbidden progression inputs

`main` must not advance solely because:
- an artifact file exists
- a shell polling command succeeds
- a progress-log line exists
- a teammate writes narrative text without a valid notification shape
- a phase name suggests a likely next step

## current-stage note

The current executable lane uses one skeleton: `planner -> generator -> evaluator`.

Task scale changes how much work each role performs, not which extra runtime events are required.
