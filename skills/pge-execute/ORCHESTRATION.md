# PGE_EXECUTE_ORCHESTRATION

## Purpose

This file records the minimal orchestration behavior for `/pge-execute` in the current stage.

Current priority is this:
- keep one real Agent Team for the run
- shift normal coordination to Agent Teams messaging
- preserve durable artifacts only for phase results and the shared progress log
- keep one execution skeleton for all tasks
- keep the current executable lane bounded to one run

Do not broaden this seam into a larger workflow framework.

## Runtime roles

- `main` = orchestration shell only
- `planner` = round contract owner applying research grounding, architecture judgment, and engineering-review pressure for one bounded round
- `generator` = coder + integrator + local reviewer for one bounded round
- `evaluator` = independently validate and issue verdict/route

`main` is not a fourth agent.

`main` owns:
- dispatch
- correction / repair routing
- exception handling
- run-level progress
- quality-governance gates

`main` does not own:
- research
- implementation
- final independent quality judgment

## Required lifecycle

Single-run lifecycle:
1. initialize run
2. create team
3. planner handoff
4. generator handoff
5. evaluator handoff / final verdict
6. route
7. optional summary
8. teardown

## Core rule

Normal coordination is message-first.
`main` advances only after a canonical teammate-to-main `SendMessage` notification plus the matching phase gate defined in `skills/pge-execute/contracts/runtime-event-contract.md`.

Durable artifacts are side effects validated after the matching notification is received.
Progress log entries are best-effort observability only and must never advance the run.

If the currently dispatched teammate sends only non-canonical completion hints, `main` must send exactly one protocol repair message asking that teammate to resend only the canonical teammate-to-main notification before running the phase gate.
`main` must not advance from artifact presence alone.
If the canonical message still does not arrive after repair but the current-phase artifact passes the full gate and unambiguously belongs to the current run, `main` may continue with degraded progression recorded as `protocol_recovery: missing_team_message_event_artifact_gate`.
Recovery/resume recap and task-state replay are still non-canonical hints unless the canonical notification text is present verbatim.
`TaskUpdate(status: completed)` is teammate bookkeeping only; it is not a phase-completion event and must not replace the canonical teammate-to-main `SendMessage`.

For the current stage:
- Planner writes the locked task-shape artifact
- Generator first reviews Planner's frozen contract for executability, then executes against it
- Evaluator performs the only approval gate
- only durable phase outputs plus the shared progress log are written to disk

## Smoke task

For `/pge-execute test`:
- planner remains part of the active skeleton; the smoke path only keeps Planner as thin as possible
- generator must write `.pge-artifacts/<run_id>/deliverables/smoke.txt`
- file content must be exactly `pge smoke`
- evaluator must independently read that file
- PASS requires `verdict = PASS` and `next_route = converged`
- management artifacts, excluding `input_artifact` and the smoke deliverable, should stay minimal: `planner_artifact`, `evaluator_artifact`, and the shared `progress_artifact`
- smoke is a lighter verification lane, not a different orchestration skeleton

## Required run artifacts

Required artifacts in the current executable lane:
- all runs: `.pge-artifacts/<run_id>/planner.md`, `.pge-artifacts/<run_id>/evaluator.md`, `.pge-artifacts/<run_id>/progress.jsonl`, `.pge-artifacts/<run_id>/manifest.json`
- smoke/test may omit `.pge-artifacts/<run_id>/generator.md`
- normal non-test runs must persist `.pge-artifacts/<run_id>/generator.md`
- summary is optional: `.pge-artifacts/<run_id>/summary.md`
- deliverable when applicable: run-scoped repo work such as `.pge-artifacts/<run_id>/deliverables/smoke.txt`

`manifest.json` is the run-directory index written by `main`.
It does not advance the run, but it should always point to the current authoritative artifacts for inspection and tooling.

## Execution depth

All tasks use the same skeleton: `planner -> generator -> evaluator`.

Task scale changes:
- how much context Planner loads
- how deep Generator's durable implementation bundle needs to be
- how deep Evaluator audits the result

Task scale does not create new required orchestration stages in the current lane.

## Progress tracking

The progress artifact is one shared append-only execution log:
- `.pge-artifacts/<run_id>/progress.jsonl`
- `main` is the only authoritative writer
- it records scheduler actions, gate outcomes, route outcomes, repeated failures, and friction
- it is useful for debugging and later PGE iteration
- it is not a gate, not a state machine, and not a recovery primitive

Agents do not append authoritative progress directly.
They emit canonical teammate-to-main runtime events and artifacts; `main` records the orchestration-visible consequences.
If runtime-event delivery is malformed or incomplete, `main` records protocol friction, sends one canonical resend request to the same teammate, then either continues through explicit degraded artifact-gated recovery or stops with `protocol_violation: missing_team_message_event`.

## Generator plan-review consumption

When a durable Generator artifact exists, `main` must inspect `self_review.generator_plan_review` after the `generator_completion` event and before dispatching Evaluator.

Use this rule:

- if `review_verdict = BLOCK`, stop and record a blocked run-level result; do not dispatch Evaluator
- if `missing_prerequisites` or `repair_direction` show a material execution blocker, stop and record the blocker even if the deliverable technically exists
- if `review_verdict = PASS` but `scope_risk`, `known_limits`, or weak evidence remain, record friction and continue to Evaluator
- if no durable Generator artifact exists in the smoke/test lane, `main` cannot inspect `generator_plan_review`; rely on deliverable existence plus `verification_result` and continue with the lightweight lane rules

`main` may classify and route these outcomes, but it must not rewrite Generator's technical judgment into a different contract interpretation.

## Route behavior

Current version supports only one successful terminal route:
- `converged`

If evaluator returns anything else:
- record it
- append the route/blocker to the progress log
- treat canonical `continue`, `retry`, or `return_to_planner` as `unsupported_route`
- stop without redispatch
- do not auto-retry in the current smoke stage

## Evaluator verdict consumption

After the `final_verdict` event and evaluator artifact gate:

- if `verdict = PASS` and `next_route = converged`, record success-path route data and continue to teardown
- if `verdict = PASS` and `next_route = continue`, record canonical route, downgrade to `unsupported_route` in the current stage, and stop cleanly
- if `verdict = RETRY`, treat it as an execution-level non-acceptance result, record required fixes and friction, downgrade to `unsupported_route`, and stop cleanly
- if `verdict = BLOCK` and the required fixes describe missing execution evidence or incomplete delivery under a still-fair contract, record an execution blocker and downgrade to `unsupported_route`
- if `verdict = BLOCK` and the route reason shows the contract is no longer a fair repair frame, classify it as contract friction and downgrade to `unsupported_route`
- if `verdict = ESCALATE`, classify it as a contract-level failure signal, record the escalation reason, downgrade to `unsupported_route`, and stop cleanly

`main` may classify the result as:
- success-path
- execution blocker
- contract blocker
- protocol blocker

But `main` must not rewrite the evaluator verdict into a different acceptance judgment.

## Failure ownership matrix

Use this ownership split:

- **Planner failure**
  - missing or unfair contract
  - unresolved blocking ambiguity
  - evidence gathering failure
  - owner: `planner`

- **Generator failure**
  - missing deliverable
  - unverifiable execution
  - silent boundary drift
  - insufficient execution evidence
  - owner: `generator`

- **Evaluator failure**
  - invalid verdict bundle
  - missing independent verification
  - unsupported acceptance reasoning
  - owner: `evaluator`

- **Protocol / control-plane failure**
  - invalid event shape
  - route reduction contradiction
  - progress schema violation
  - teardown command-shape failure
  - owner: `main`

- **Runtime / substrate failure**
  - TeamCreate / SendMessage / TeamDelete failure
  - permission / hook / session transport failure
  - owner: runtime environment, surfaced by `main`

`main` owns failure classification and logging.
Agents own repairing their own role outputs.
`main` must not repair role semantics directly.

## Guardrails

- Use real Agent Teams or stop with a blocker.
- Do not simulate planner/generator/evaluator inside `main`.
- Do not let Planner or Generator decide the final verdict.
- Do not let `main` become a fourth domain expert; it may route, gate, and correct, but it must not rewrite Planner or Generator semantics itself.
- Do not advance from artifact existence alone; require the matching runtime event first.
- Keep the current lane bounded to one run.
- Do not turn progress logging into an execution dependency.
- Keep changes minimal and execution-first.
