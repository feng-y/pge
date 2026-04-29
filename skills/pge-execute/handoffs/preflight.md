# Contract Preflight Handoff

Preflight shifts quality left before Generator edits files.

Communication rule for this phase:

- Generator and Evaluator negotiate primarily through Agent Teams `SendMessage`
- `main` dispatches, observes, and routes; it is not the turn-by-turn message bus
- files are reserved for durable phase outputs, not intermediate discussion turns

## Fast Path Cost Gate

Before asking Generator for a durable proposal, ask Evaluator for a lightweight cost-gate decision from the Planner contract.

For deterministic tasks such as `test`, Evaluator may approve `FAST_PATH` and `fast_finish_approved = true` by direct `SendMessage`. When this happens:
- do not ask Generator to write `contract_proposal_artifact`
- do not ask Evaluator to write `preflight_artifact`
- set `mode = "FAST_PATH"`, `mode_decision_owner = "evaluator"`, `fast_finish_approved = true`
- continue to Generator execution without repo edits before this approval
- persist only state; final durable validation remains the Evaluator verdict artifact

The FAST_PATH cost-gate message must have exactly this shape:

```text
type: mode_decision
preflight_verdict: PASS
execution_mode: FAST_PATH
fast_finish_approved: true
next_route: ready_to_generate
requires_durable_proposal: false
requires_durable_preflight: false
reason: <one short reason>
```

If Evaluator does not approve `FAST_PATH`, send this task to `generator`.

## Generator Proposal

```text
You are @generator in the PGE runtime team.

run_id: <run_id>
planner_artifact: <planner_artifact>
preflight_attempt_id: <preflight_attempt_id>
max_preflight_attempts: <max_preflight_attempts>
output_artifact: <contract_proposal_artifact>

Preflight only. Do not modify repo files.

Read the Planner contract and confirm whether it is executable without guessing.
Treat Planner as the evidence/design authority for the current round; do not silently override its constraints.
If this is a repair attempt, also read the prior preflight feedback and address it explicitly without broadening scope.
Use direct messages with @evaluator for clarification, challenge-response, and proposal repair. Do not treat <contract_proposal_artifact> as a turn-by-turn message log.

If the final chosen mode requires a durable proposal artifact, write markdown to <contract_proposal_artifact> with exactly these top-level sections:
- ## current_task
- ## execution_boundary_ack
- ## deliverable_ack
- ## verification_plan
- ## evidence_plan
- ## addressed_preflight_feedback
- ## unresolved_blockers
- ## preflight_status

Allowed preflight_status values:
- READY_FOR_EVALUATOR
- BLOCKED

After writing <contract_proposal_artifact>, send this runtime event to `main`:

```text
type: proposal_ready
contract_proposal_artifact: <contract_proposal_artifact>
preflight_status: READY_FOR_EVALUATOR | BLOCKED
unresolved_blockers: <short summary or None>
```
```

Gate when `contract_proposal_artifact` is written:

- artifact exists
- `## current_task` exists
- `## execution_boundary_ack` exists
- `## deliverable_ack` exists
- `## verification_plan` exists
- `## evidence_plan` exists
- `## addressed_preflight_feedback` exists
- `## unresolved_blockers` exists
- `## preflight_status` exists

## Evaluator Preflight

Send this task to `evaluator` for non-FAST preflight, or as the lightweight FAST_PATH cost gate when no durable Generator proposal is needed.

```text
You are @evaluator in the PGE runtime team.

run_id: <run_id>
planner_artifact: <planner_artifact>
contract_proposal_artifact: <contract_proposal_artifact or None for FAST_PATH>
preflight_attempt_id: <preflight_attempt_id>
max_preflight_attempts: <max_preflight_attempts>
output_artifact: <preflight_artifact or None for FAST_PATH>

Preflight only. Do not modify repo files.

Review whether the Planner contract plus Generator proposal create a fair, executable, independently evaluable current round. For deterministic FAST_PATH candidates, the Generator proposal may be absent; judge only whether the Planner contract is precise enough for a deterministic implementation and independent final check.
Do not approve vague, untestable, overbroad, or self-contradictory contracts.
You own the Execution Cost Gate for this phase:
- classify the attempt as `FAST_PATH`, `LITE_PGE`, `FULL_PGE`, or `LONG_RUNNING_PGE`
- confirm whether fast finish is allowed
- when a Generator proposal is present, communicate with @generator directly for challenge, clarification, and repair before writing the durable preflight verdict

If the final chosen mode requires a durable preflight artifact, write markdown to <preflight_artifact> with exactly these top-level sections:
- ## preflight_verdict
- ## execution_mode
- ## evidence
- ## contract_risks
- ## required_contract_fixes
- ## repair_owner
- ## next_route

Allowed preflight_verdict values:
- PASS
- BLOCK
- ESCALATE

Allowed next_route values:
- ready_to_generate
- return_to_planner

Allowed repair_owner values:
- generator
- planner

Use `generator` only when the Planner contract can remain frozen and the Generator proposal can be repaired without guessing.
Use `planner` when the contract itself is ambiguous, unfair, contradictory, oversized, or missing the basis needed for an executable round.

When the chosen mode requires a durable preflight verdict, send this runtime event to `main` after writing <preflight_artifact>:

```text
type: preflight_decision
preflight_verdict: PASS | BLOCK | ESCALATE
execution_mode: FAST_PATH | LITE_PGE | FULL_PGE | LONG_RUNNING_PGE
repair_owner: generator | planner
next_route: ready_to_generate | return_to_planner
preflight_artifact: <preflight_artifact>
reason: <one short reason>
```
```

Gate when `preflight_artifact` is written:

- artifact exists
- `## preflight_verdict` exists
- `## execution_mode` exists
- `## evidence` exists
- `## contract_risks` exists
- `## required_contract_fixes` exists
- `## repair_owner` exists
- `## next_route` exists

## Routing

- `FAST_PATH + fast_finish_approved = true`: set `state = "ready_to_generate"`, set `preflight_called = true`, do not persist proposal/preflight refs, record `mode = "FAST_PATH"`, `mode_decision_owner = "evaluator"`, `fast_finish_approved = true`, and continue without progress unless progress is already enabled.
- `PASS + ready_to_generate`: set `state = "ready_to_generate"`, set `preflight_called = true`, persist proposal/preflight refs only when the chosen mode requires them, record `mode`, `mode_decision_owner = "evaluator"`, and `fast_finish_approved` in state, then update progress if enabled.
- `BLOCK + repair_owner = generator` with attempts remaining: persist proposal/preflight refs, record fixes/risks, increment `preflight_attempt_id`, keep `state = "preflight_pending"`, update progress, redispatch Generator proposal repair, and keep repo edits forbidden.
- Any gate failure: set `state = "failed"`, set `preflight_called = true`, record blocker, write state, update progress, stop.
- `BLOCK + repair_owner = planner`, `ESCALATE`, or exhausted preflight attempts: set `state = "unsupported_route"`, set `preflight_called = true`, set route to `return_to_planner` when present, record fixes/risks, persist refs, write state, update progress, stop without redispatch.
