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
- `planner` = resident researcher + architect teammate; owns initial evidence-backed plan workflow and later bounded research / architecture support for `main` and Generator
- `generator` = resident implementation teammate; owns bounded execution, integration, local verification, and later implementation clarification; asks Planner only for broad repo / architecture research that would otherwise pull Generator out of implementation
- `evaluator` = resident independent validation teammate; owns verdict workflow and later bounded verdict clarification

`main` is not a fourth agent.

Each teammate is a workflow actor, not a one-shot persona. Initial phase completion is a handoff event, not agent termination.

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
Foreground polling scripts and verbose verification transcripts are not the user-facing progress model. `main` should keep waiting/recovery observation quiet, append only structured progress events, and surface a concise status only when a gate passes, blocks, repairs, or degrades.

For the current stage:
- Planner writes the locked task-shape artifact
- Planner sends `planner_research_decision` to `main` before broad repo research for a non-test contract, then repeats the final `multi_agent_research_decision` inside `planner_note`; when the scale threshold is met, Planner chooses `mode: parallel_multi_agent_research` and launches bounded internal researcher subagents in parallel before continuing serial research unless a concrete exception is recorded
- Helper scale threshold: at least two independent evidence questions, two or more relevant subsystems/directories, or an unfamiliar nontrivial repo area
- Planner helper lanes are read-only evidence collectors; helpers are not PGE runtime stages and do not own contract authority
- `main` may log `planner_research_decision` as support traffic, but must not advance planning until `planner_contract_ready` arrives and the Planner artifact gate passes
- Planner freezes exactly one `current_round_slice` inside `handoff_seam` for the current lane; this is slice metadata for Generator/Evaluator, not a backlog or a new runtime stage
- `current_round_slice.ready_for_generator` must be true before `main` dispatches Generator; otherwise `main` treats the Planner artifact as not ready and stops before implementation
- Durable helper outputs follow `skills/pge-execute/contracts/helper-report-contract.md` and are referenced from the owning phase artifact; helper reports are advisory evidence only
- After `planner_contract_ready`, Planner does not exit; it remains resident, available, and responsive for bounded clarification, architecture guidance, and repo research until shutdown
- Generator first reviews Planner's frozen contract for executability, then executes against it
- Generator may run bounded coder workers and read-only reviewer helpers in parallel, but helpers are not PGE runtime stages and do not own integration, approval, or `generator_completion`
- Generator handles directly relevant local context itself; it asks resident Planner only for broad repo archaeology, architecture interpretation, contract-scope ambiguity, or multi-file research that would overload implementation
- Generator records this boundary in `planner_support_decision`; Planner support messages are advisory evidence, not phase progression events
- After `generator_completion`, Generator does not exit; it remains resident, available, and responsive for bounded implementation clarification or repair investigation until shutdown
- Evaluator performs the only approval gate
- Evaluator may run bounded read-only verification helpers in parallel for independent evidence checks, but helpers are not PGE runtime stages and do not own verdict/route authority
- After `final_verdict`, Evaluator does not exit; it remains resident, available, and responsive for bounded verdict clarification until shutdown
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

All tasks use the same resident P/G/E progression:
- Planner freezes the current contract
- Generator implements under that contract
- Evaluator validates independently
- retryable Evaluator feedback may loop back to resident Generator while the same contract remains fair

Task scale changes:
- how much context Planner loads
- how deep Generator's durable implementation bundle needs to be
- how deep Evaluator audits the result
- how many bounded Generator repair / Evaluator re-check attempts are justified

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
Support messages are coordination traffic. They may be logged, but they do not advance phases and do not consume the one repair attempt for missing phase-completion events.

## Main exception handling

`main` must protect the run from stuck resident teammates:

- Missing completion event: send one canonical resend request to the currently dispatched teammate; then either use explicit degraded artifact-gated recovery or stop with `protocol_violation: missing_team_message_event`.
- Malformed completion event: request one resend of the canonical event shape; if the resend is still malformed, stop with `protocol_violation: invalid_team_message_event`.
- Generator handoff gap: if the real deliverable exists but `generator.md` or `generator_completion` is missing, ask resident Generator to complete the durable handoff or send canonical BLOCKED before selecting a blocked route.
- Explicit blocked completion: record the blocker, do not dispatch downstream phases that depend on the missing work, route/status as blocked or unsupported, and teardown.
- Support-message traffic: log when useful and keep waiting for the current phase completion event.
- Substrate failure: record runtime/substrate blocker and teardown when a team exists.

`main` must not wait indefinitely after the single protocol repair attempt.

## Generator plan-review consumption

When a durable Generator artifact exists, `main` must inspect `self_review.generator_plan_review` after the `generator_completion` event and before dispatching Evaluator.

Use this rule:

- if `review_verdict = BLOCK`, stop and record a blocked run-level result; do not dispatch Evaluator
- if `missing_prerequisites` or `repair_direction` show a material execution blocker, stop and record the blocker even if the deliverable technically exists
- if `review_verdict = PASS` but `scope_risk`, `known_limits`, or weak evidence remain, record friction and continue to Evaluator
- if no durable Generator artifact exists in the smoke/test lane, `main` cannot inspect `generator_plan_review`; rely on deliverable existence plus `verification_result` and continue with the lightweight lane rules

`main` may classify and route these outcomes, but it must not rewrite Generator's technical judgment into a different contract interpretation.

## Route behavior

Current version supports one successful terminal route:
- `converged`

Current version also supports a bounded evaluator-to-generator repair loop:
- `retry` may redispatch resident Generator when Evaluator says the current contract remains fair and the required fixes are local to Generator
- after each repair, `main` dispatches bounded re-evaluation to Evaluator
- max generator attempts per round: 10 total attempts, including the initial generation
- same `failure_signature` repeated on 3 consecutive evaluations triggers a repair decision checkpoint
- stop the loop on `PASS`, `return_to_planner`, `ESCALATE`, max attempts exhausted, or main decision to stop after a checkpoint

## Repair loop communication protocol

The `generator <-> evaluator` loop is driven by `main`; Generator and Evaluator do not message each other to advance the loop.

For each retryable verdict:
1. `main` reads Evaluator `required_fixes`, `failure_signature`, `verdict`, `next_route`, and `route_reason`.
2. `main` checks that the Planner contract is still fair, the fix is local to Generator, total Generator attempts are below 10, and no same-failure checkpoint has stopped the loop.
3. `main` sends `generator_repair_request` to `generator` with attempt number, Planner artifact, current Generator artifact, Evaluator artifact, required fixes, failure signature, and same-contract scope boundary.
4. `main` waits for a fresh canonical `generator_completion`, then gates the repaired deliverable and durable Generator artifact.
5. `main` sends `evaluator_recheck_request` to `evaluator` with attempt number, Planner artifact, repaired Generator artifact, prior Evaluator artifact, prior failure signature, and required fixes.
6. `main` waits for a fresh canonical `final_verdict`, gates the Evaluator artifact, and either routes on PASS/non-retryable output or repeats the loop.

If the same `failure_signature` appears on 3 consecutive evaluations, or total Generator attempts reaches 10, `main` saves a repair snapshot before deciding whether to stop, ask one focused user question, or allow one more bounded attempt.

If evaluator returns anything else:
- record it
- append the route/blocker to the progress log
- treat canonical `continue` or `return_to_planner` as `unsupported_route`
- stop without redispatch except for the supported bounded same-contract `retry` loop
- do not retry beyond max generator attempts or checkpoint decision in the current stage

## Evaluator verdict consumption

After the `final_verdict` event and evaluator artifact gate:

- if `verdict = PASS` and `next_route = converged`, record success-path route data and continue to teardown
- if `verdict = PASS` and `next_route = continue`, record canonical route, downgrade to `unsupported_route` in the current stage, and stop cleanly
- if `verdict = RETRY`, record required fixes and dispatch Generator repair while attempts remain; otherwise stop as unsupported/failed
- if `verdict = BLOCK` and the required fixes describe missing execution evidence or incomplete delivery under a still-fair contract, dispatch Generator repair while attempts remain; otherwise record an execution blocker and stop
- if `verdict = BLOCK` and the route reason shows the contract is no longer a fair repair frame, classify it as contract friction and downgrade to `unsupported_route`
- if `verdict = ESCALATE`, classify it as a contract-level failure signal, record the escalation reason, downgrade to `unsupported_route`, and stop cleanly

When the same failure signature repeats or the total attempt budget is hit, `main` must save a repair snapshot before deciding. The snapshot records run id, attempt count, failure signature, last failed command/result, current artifacts, changed files, Evaluator required fixes, Generator repair notes, and the next main decision: continue one more attempt, return to Planner, or stop failed. If artifacts do not justify the decision, `main` may ask the user one focused question.

Task outcome and teardown outcome are separate. A failed verification path, including a crash/signal/non-zero result such as exit code `139`, is a deliverable correctness failure even if teardown later also fails. A noisy or failed teardown is teardown friction and must not overwrite the task verdict/route.

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
