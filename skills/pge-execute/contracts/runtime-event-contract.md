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
Instead, `main` must explicitly ask the currently dispatched teammate to send the canonical notification shape for the phase, using a blocked / not-ready status when the phase cannot complete.

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
- `ready_for_generation: true|false`

Meaning:
- Planner finished the current-round contract or surfaced a planning blocker
- when `ready_for_generation: true`, `main` may gate `planner_artifact` and dispatch Generator
- when `ready_for_generation: false`, `main` must record Planner blocker/escalation and stop before dispatching Generator

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

## support messages

Support messages are allowed teammate coordination messages, but they are not phase-completion events and do not advance `main`.

### `planner_support_request`

Producer: `generator` or `main`

Required fields:
- `type: planner_support_request`
- `run_id`
- `question`
- `why_generator_cannot_resolve_locally`
- `scope_boundary`
- `needed_by`
- `reply_to`

Meaning:
- Generator or `main` needs bounded research / architecture / contract-scope support from the resident Planner
- the request is justified only when routine local context is insufficient
- the request must not ask Planner to implement, approve, route, or mutate the frozen contract
- when Generator sends the request, it must be delivered directly to `planner` with `reply_to: generator`

### `planner_support_response`

Producer: `planner`

Required fields:
- `type: planner_support_response`
- `run_id`
- `answer`
- `evidence`
- `confidence`
- `replan_needed: true|false`
- `reply_to`

Meaning:
- Planner answered a bounded support request with evidence-backed guidance
- the response is advisory unless `replan_needed: true`
- if `replan_needed: true`, `main` owns any route or stop decision; Planner does not silently mutate the frozen contract
- Planner must send the response directly to the requester named by `reply_to`
- if a response to Generator has `replan_needed: true`, Generator must stop implementation and send canonical `generator_completion` with `handoff_status: BLOCKED`

Support messages may be referenced from durable artifacts, especially Generator `planner_support_decision`, but artifact references to support messages are evidence only.
They do not replace `planner_contract_ready`, `generator_completion`, or `final_verdict`.

While `main` is waiting for a phase-completion event, support messages are neither completion hints nor protocol-repair triggers.
`main` may log them as support traffic when visible, but must continue waiting for the current phase's canonical completion event unless an explicit substrate failure occurs.

If Generator sends one `planner_support_request` and no valid `planner_support_response` arrives, Generator must stop the support wait and send canonical `generator_completion` with `handoff_status: BLOCKED`.
Generator must not wait indefinitely for Planner support.

## main exception handling rule

For each dispatched Planner / Generator / Evaluator phase, `main` must handle abnormal communication in this order:

1. If a canonical BLOCKED / not-ready event arrives, stop the current phase, record the blocker, route/status as blocked or unsupported as appropriate, and proceed to teardown.
2. If a ready canonical event arrives, run the matching phase gate.
3. If a support message arrives, optionally log it and continue waiting for the canonical event.
4. For Generator only: if a real deliverable or artifact-written hint exists but the required `generator_artifact` or `generator_completion` is missing, treat this as a recoverable handoff gap and use the one repair request to ask Generator to either finish the durable artifact plus canonical event or return canonical BLOCKED.
5. If another non-canonical completion hint arrives, send exactly one protocol repair request to the currently dispatched teammate asking for only the canonical event, with blocked / not-ready status when appropriate.
6. If the canonical event is still missing after one repair, use degraded artifact-gated recovery only when the current-phase gate passes and the artifact unambiguously belongs to the current run.
7. If degraded recovery cannot be proven, stop with `protocol_violation: missing_team_message_event`, record progress friction, and proceed to teardown when a team exists.

`main` must not spin indefinitely after one repair attempt.
`main` must not convert a visible generated deliverable plus missing Generator handoff artifacts directly into route BLOCK before the Generator repair path has failed.

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

When requesting resend, `main` should ask for the canonical notification text only, with no recap, summary wrapper, idle wrapper, or explanatory prefix. The teammate must use the blocked / not-ready canonical form when it cannot complete the phase.
Generator handoff-gap repair overrides this generic event-only resend: when the required durable `generator_artifact` is missing, the one repair request must ask Generator to write/repair that artifact and then send canonical `generator_completion`, or send canonical BLOCKED if it cannot.

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
