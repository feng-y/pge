# RUNTIME_ORCHESTRATION_AUTHORITY

## Purpose

This file is the authoritative current-stage runtime-control policy for PGE orchestration.

It defines, in one place:
- runtime state transitions
- route policy
- unsupported-route handling
- recovery entry points
- team lifecycle assumptions
- artifact-chain gates required before final routing
- the minimal checkpoint schema for recovery

The active operational seam for these rules lives in `skills/pge-execute/ORCHESTRATION.md`.
If this file conflicts with older round notes or checklist prose, this file wins as the current-stage runtime-control policy and the skill layer must be aligned to it.

## Relationship to other seams

- `skills/pge-execute/ORCHESTRATION.md` is the active skill-owned operational seam for `main`.
- `skills/pge-execute/SKILL.md` is the bounded dispatcher/orchestrator entrypoint.
- `docs/exec-plans/PGE_EXECUTION_LAYER_PLAN.md` defines the broader execution-layer architecture.
- `docs/exec-plans/PGE_ORCHESTRATION_CONTRACT.md` defines the architectural ownership split and the normalized meaning of `main`.
- `contracts/*` define the canonical route/state/verdict vocabulary.
- `skills/pge-execute/contracts/*` are runtime-facing copies used by the installed skill.

`main` is the orchestration主体 for a run: the skill-internal run-level scheduler, state owner, router, and recovery owner. This file defines the current-stage runtime behavior that the skill layer must follow.

This file defines orchestration behavior for the current stage. It does not broaden the target architecture beyond what the runtime can honestly support today.

## Current-stage claim

The target architecture remains:

> `main` orchestrates a persistent runtime Planner / Generator / Evaluator team

That architecture is not optional and is not reopened here.

Current-stage runtime support remains bounded:
- one bounded execution round is supported
- file-based handoff remains the execution backbone
- canonical route and verdict vocabulary remains in use
- automatic runtime execution beyond the bounded round is not yet supported

So this file separates two things cleanly:
- **target architecture**: persistent runtime team organization is required
- **current-stage runtime behavior**: only the bounded single-round orchestration path is executable today

## Ownership boundaries

| Surface | Owner | Must not own |
| --- | --- | --- |
| run initialization, runtime state, routing, stop, recovery, team lifecycle | `main` | slice shaping, implementation work, evaluation work |
| slice shaping, boundary, deliverable framing, verification path, slice-status advice | Planner | run-level route, stop, recovery, team lifecycle |
| deliverable production, local verification, concrete evidence, explicit limits/deviations | Generator | acceptance, final route selection |
| independent validation, evidence sufficiency, canonical verdict, route signal | Evaluator | implementation fixes, replanning, hidden route invention |

Planner may emit slice-status advice. `main` remains the run-level route owner.

## Runtime state machine for the current stage

### Required states

- `intake_pending`
- `planning_round`
- `preflight_pending`
- `preflight_failed`
- `ready_to_generate`
- `generating`
- `awaiting_evaluation`
- `evaluating`
- `routing`
- `unsupported_route`
- `artifact_gate_failed`
- `converged`
- `failed_upstream`

### Supported transitions in the current stage

- `intake_pending -> planning_round`
- `intake_pending -> failed_upstream`
- `planning_round -> preflight_pending`
- `planning_round -> failed_upstream`
- `preflight_pending -> ready_to_generate`
- `preflight_pending -> preflight_failed`
- `preflight_failed -> planning_round`
- `ready_to_generate -> generating`
- `generating -> awaiting_evaluation`
- `generating -> artifact_gate_failed`
- `awaiting_evaluation -> evaluating`
- `evaluating -> routing`
- `evaluating -> artifact_gate_failed`
- `routing -> converged`
- `routing -> unsupported_route`

### Not yet enacted automatically in the current stage

These remain target-runtime transitions, not current-stage executable loop behavior:
- `routing -> planning_round` from `continue` or `return_to_planner`
- `routing -> generating` from `retry`

If one of those routes is selected canonically, the runtime must fail fast through `unsupported_route` instead of pretending the loop exists.

## Route policy

### Canonical route vocabulary

- `continue`
- `retry`
- `return_to_planner`
- `converged`

The vocabulary remains canonical even when the current stage does not yet execute every route automatically.

### Canonical verdict-to-route mapping

- `PASS` + stop condition satisfied => `converged`
- `PASS` + stop condition not satisfied => `continue`
- `RETRY` => `retry`
- `BLOCK` => `retry` when the current round is still the correct repair frame
- `BLOCK` => `return_to_planner` when the current round is no longer the correct repair frame
- `ESCALATE` => `return_to_planner`

### Current-stage route truth table

| Canonical route selected by `main` | Current-stage execution support | Required behavior now |
| --- | --- | --- |
| `converged` | Supported | Persist final state and summary; stop successfully |
| `continue` | Not supported yet | Fail fast via `unsupported_route`; persist checkpoint; stop without redispatch |
| `retry` | Not supported yet | Fail fast via `unsupported_route`; persist checkpoint; stop without redispatch |
| `return_to_planner` | Not supported yet | Fail fast via `unsupported_route`; persist checkpoint; stop without redispatch |

## Unsupported-route handling

If `main` selects `continue`, `retry`, or `return_to_planner` in the current stage, it must:

1. preserve the canonical selected route in runtime state
2. set runtime `state` to `unsupported_route`
3. write a recovery checkpoint before stopping
4. report that the selected route is valid vocabulary but unsupported for automatic execution in the current stage
5. stop without silently redispatching Planner, Generator, or Evaluator

This preserves canonical route identity while preventing false claims about loop support.

## Artifact-chain gates before final routing

`main` must not finalize routing until all three role artifacts are structurally usable.

### Planner artifact gate

The planner artifact must:
- exist
- include these top-level sections:
  - `## goal`
  - `## in_scope`
  - `## out_of_scope`
  - `## actual_deliverable`
  - `## acceptance_criteria`
  - `## verification_path`
  - `## stop_condition`
  - `## required_evidence`
  - `## handoff_seam`
- make the current round executable without guesswork

### Generator artifact gate

The generator artifact must:
- exist
- include these top-level sections:
  - `## current_task`
  - `## boundary`
  - `## actual_deliverable`
  - `## deliverable_path`
  - `## changed_files`
  - `## local_verification`
  - `## evidence`
  - `## known_limits`
  - `## non_done_items`
  - `## deviations_from_spec`
  - `## handoff_status`
- make `actual_deliverable`, `deliverable_path`, and `evidence` resolvable from the artifact itself
- make local verification claims inspectable rather than implied

### Evaluator artifact gate

The evaluator artifact must:
- exist
- include these top-level sections:
  - `## verdict`
  - `## evidence`
  - `## violated_invariants_or_risks`
  - `## required_fixes`
  - `## next_route`
- use canonical verdict vocabulary
- use canonical route vocabulary in `next_route`
- make evidence sufficient for `main` to explain the selected route

### Append-only step record gate

Before final route exit, the runtime must leave an append-only route record that names:
- state before route finalization
- state after route finalization
- planner/generator/evaluator artifact refs
- latest evaluator verdict
- selected canonical route
- route reason

For the current stage:
- unsupported-route stops satisfy this requirement through `checkpoint_artifact`
- converged stops satisfy this requirement through final `runtime_state` plus `summary_artifact`

If any artifact gate fails, the runtime must stop with `artifact_gate_failed` instead of inventing a route.

## Checkpoint / recovery mini-schema

### File location

The minimal recovery checkpoint for a run must be written at:

`{repo_root}/.pge-artifacts/{run_id}-checkpoint.json`

### Required fields

- `run_id`
- `round_id`
- `checkpoint_version`
- `checkpoint_reason`
- `state`
- `recovery_entry_point`
- `upstream_plan_ref`
- `active_slice_ref`
- `active_round_contract_ref`
- `planner_artifact_ref`
- `generator_artifact_ref`
- `evaluator_artifact_ref`
- `latest_deliverable_ref`
- `latest_evidence_ref`
- `latest_evaluation_verdict`
- `latest_route`
- `route_reason`
- `written_at`

### When the checkpoint must be written

The current stage requires checkpoint writes at these minimum points:
- after planner artifact passes preflight and the run becomes `ready_to_generate`
- after generator artifact passes its gate and the run becomes `awaiting_evaluation`
- after evaluator artifact is accepted for routing when the runtime is about to stop before automatic redispatch
- immediately before stopping on `unsupported_route`

For `converged`, final `runtime_state` plus `summary_artifact` act as the terminal route record instead of an additional recovery checkpoint.

### Recovery entry points

The current stage supports these explicit recovery entry points from the checkpoint:
- `resume_generation` — planner artifact accepted; Generator has not yet completed
- `resume_evaluation` — generator artifact accepted; Evaluator has not yet completed
- `resume_from_route_decision` — evaluator verdict and selected canonical route are known; no automatic redispatch occurred because the selected route was unsupported in the current stage

Recovery must use checkpointed records, not transcript reconstruction, as the durable source of truth.

## Team lifecycle assumptions

The control-plane assumption remains:
- `main` is the skill-internal run-level scheduler and team lifecycle owner
- `main` is outside the runtime worker team and must not be modeled as a peer agent role or `agents/` seam relative to Planner / Generator / Evaluator
- Planner / Generator / Evaluator are the intended persistent runtime team members for a run

What remains intentionally deferred in the current stage:
- persistent team identity across retries/continues
- automatic multi-round redispatch under the same run
- generalized long-lived autonomous recovery
- production-grade team lifecycle management beyond the bounded round

So the repo should now speak about runtime teams like this:
- **required target architecture**: yes
- **already fully implemented runtime lifecycle**: no

## Contract drift control

`contracts/*` remain the canonical normalized seams.

`skills/pge-execute/contracts/*` are runtime-facing copies used by the installed skill.

Whenever route, state, verdict, artifact-gate, or checkpoint semantics change:
1. update the canonical contract under `contracts/*`
2. update the runtime-facing copy under `skills/pge-execute/contracts/*`
3. update `skills/pge-execute/ORCHESTRATION.md` in the same change if runtime behavior is affected
4. update `skills/pge-execute/SKILL.md` in the same change if the dispatcher surface is affected

Do not claim control-plane parity if only one of those surfaces was updated.
