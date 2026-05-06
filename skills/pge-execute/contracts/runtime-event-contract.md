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

If the expected notification is missing, `main` must not advance from artifact existence alone.
Instead, `main` must explicitly ask the currently dispatched teammate to confirm whether the phase is complete and, if complete, to resend the canonical notification shape.

If a teammate confirms completion but the data gate fails, the phase is not accepted and the teammate must repair or re-execute the phase work rather than merely resend the notification.

## event source rule

PGE currently targets Claude Code Agent Teams for runtime execution.

In the current executable lane, the canonical runtime event must be delivered as a teammate-to-main team message through `SendMessage`.

The transport is not the contract. The notification shape is the contract.

The teammate-to-main message is the only legal progression trigger in the current Agent Teams lane.
Artifact existence, progress logs, pane output, task state, or prose summaries do not replace it.
`TaskUpdate(status: completed)` is task bookkeeping only; it is not a PGE phase-completion event and must not be the teammate's substitute for the canonical `SendMessage`.

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
- `TaskUpdate(status: completed)` / task-list completion
- recovery / resume recap
- "I already completed task #N" replay

then `main` may use those hints only to initiate a single clarification / resend request to that same teammate.

Those hints do not authorize phase advancement by themselves.

When requesting resend, `main` should ask for the canonical notification text only, with no recap, summary wrapper, idle wrapper, or explanatory prefix.

## bounded recovery rule

If the canonical teammate-to-main message still does not arrive after one protocol repair request, `main` may continue only when all of these are true:

- the expected current-phase artifact exists under the current run directory
- the full phase gate for that artifact passes
- the artifact unambiguously belongs to the currently dispatched teammate and current run
- `main` records degraded progression in `progress_artifact`

This is degraded progression, not a normal pass.
The progress event must include:

`protocol_recovery: missing_team_message_event_artifact_gate`

If any condition is not met, `main` must stop with:

`protocol_violation: missing_team_message_event`

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
