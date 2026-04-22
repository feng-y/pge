---
name: pge-execute
description: Use this skill when bounded repo-internal work needs one explicit Planner → Generator → Evaluator execution round with clear acceptance gates.
version: 0.1.1
---

# pge-execute

Execute one bounded PGE round: freeze one current-task contract → generate → evaluate → route.

## When to use

Use this skill when:
- Multi-round repo-internal work spans multiple iterations
- Work must stay bounded and independently verifiable
- Upstream plan exists and needs execution with explicit acceptance gates
- Risk of scope drift, role mixing, or weak review exists

Do NOT use for:
- Single-shot tasks without iteration risk
- Work without an upstream plan
- External task execution (not yet supported)

## What this skill does

Executes one bounded PGE round:

1. **Planning phase**: Spawn pge-planner agent to freeze one current-task plan / bounded round contract
2. **Preflight check**: Validate the current-task contract is executable and independently evaluable
3. **Generation phase**: Spawn pge-generator agent to execute the current task and produce deliverable + local verification evidence
4. **Evaluation phase**: Spawn pge-evaluator agent to independently validate the current task deliverable
5. **Routing**: Route based on verdict and stop condition

## Input

Required:
- `upstream_plan`: The plan to execute (as text or file reference)

Optional:
- `run_stop_condition`: When to stop (`single_round` [default] | `until_converged` | custom)

## Agents used

This skill dispatches installed plugin agents by runtime-facing agent identity:

- **pge-planner**: Freezes one current-task plan / bounded round contract
- **pge-generator**: Executes one current task, performs local verification, and produces a deliverable bundle
- **pge-evaluator**: Independently validates the current task deliverable and issues the final gate verdict

The files in `../../agents/` are the packaged agent definitions that Claude Code auto-discovers at install time.
They are not runtime prompt attachments for the main session to read and replay.
The runtime path must dispatch the installed `pge-planner`, `pge-generator`, and `pge-evaluator` agents directly.

## Contracts

Installed plugin bundles treat these contracts as supporting files of `pge-execute` under `skills/pge-execute/contracts/`.
Canonical source contracts still live at repo root in `contracts/` for development.

Agent handoffs follow contracts defined in `./contracts/`:

- `entry-contract.md`: Entry conditions for PGE execution
- `round-contract.md`: Structure of round contracts
- `evaluation-contract.md`: Structure of evaluation verdicts
- `routing-contract.md`: Routing vocabulary and decisions
- `runtime-state-contract.md`: Runtime state tracking

## Orchestration flow

### 1. Initialize runtime state

Create runtime state at `.pge-runtime-state.json`:

```json
{
  "run_id": "run-{timestamp}",
  "round_id": "round-1",
  "state": "intake_pending",
  "upstream_plan_ref": "{upstream_plan}",
  "active_slice_ref": "",
  "active_round_contract_ref": "",
  "latest_preflight_result": "",
  "run_stop_condition": "{single_round|until_converged}",
  "latest_deliverable_ref": "",
  "latest_evidence_ref": "",
  "latest_evaluation_verdict": "",
  "latest_route": "",
  "unverified_areas": [],
  "accepted_deviations": [],
  "route_reason": "",
  "convergence_reason": ""
}
```

Transition to `planning_round` state.

### 2. Planning phase

Dispatch the installed **pge-planner** agent using the Agent tool:
- `subagent_type`: `pge-planner`
- Input: upstream plan, current runtime state, output artifact path, and the required contract fields from `./contracts/round-contract.md`
- Task: Freeze one current-task plan / bounded round contract

Do not have the main session read `../../agents/pge-planner.md` and simulate the role.
The installed `pge-planner` agent already carries its own role instructions at runtime.

The planner must produce a round contract artifact at `.pge-artifacts/{run_id}-planner-output.md` with:
- `goal`: What the current task must settle
- `in_scope`: What the current task may change
- `out_of_scope`: What must stay out of scope
- `actual_deliverable`: The real artifact to produce
- `verification_path`: How Generator verifies locally and Evaluator inspects independently
- `acceptance_criteria`: Minimum conditions for completion
- `required_evidence`: Evidence Evaluator needs
- `stop_condition`: What marks the current task as done for routing
- `handoff_seam`: Where later work can continue

Update runtime state:
- Set `active_round_contract_ref` to contract artifact path
- Transition to `preflight_pending`

### 3. Preflight check

Validate the current-task contract:
- Contract file exists
- Contains all required fields
- Is executable without guessing
- Is independently evaluable

If preflight passes:
- Update `latest_preflight_result` to `pass`
- Transition to `ready_to_generate`

If preflight fails:
- Update `latest_preflight_result` to `fail`
- Transition to `preflight_failed`
- Return to planning phase

### 4. Generation phase

Dispatch the installed **pge-generator** agent using the Agent tool:
- `subagent_type`: `pge-generator`
- Input: current-task contract, minimal repo context, output artifact path, and required implementation bundle fields
- Task: Execute the current task, run local verification, and produce the actual deliverable bundle

Do not have the main session read `../../agents/pge-generator.md` and simulate the role.
The installed `pge-generator` agent already carries its own role instructions at runtime.

The generator must produce an implementation bundle at `.pge-artifacts/{run_id}-generator-output.md` with:
- `current_task`: What current task was executed
- `boundary`: Applied in-scope / out-of-scope boundary
- `actual_deliverable`: What was actually delivered
- `deliverable_path`: Repo-relative path(s)
- `changed_files`: Files created or modified
- `local_verification`: Checks run and results
- `evidence`: Concrete evidence
- `known_limits`: Unverified areas
- `non_done_items`: Explicit items not completed in this round
- `deviations_from_spec`: Deviations with justifications
- `handoff_status`: Ready for evaluation or needs escalation

Update runtime state:
- Set `latest_deliverable_ref` to deliverable path
- Set `latest_evidence_ref` to evidence artifact
- Transition to `awaiting_evaluation`

### 5. Evaluation phase

Dispatch the installed **pge-evaluator** agent using the Agent tool:
- `subagent_type`: `pge-evaluator`
- Input: current-task contract, implementation bundle, current runtime state when needed, output artifact path, and required verdict bundle sections
- Task: Independently validate the current task deliverable against the same contract

Do not have the main session read `../../agents/pge-evaluator.md` and simulate the role.
The installed `pge-evaluator` agent already carries its own role instructions at runtime.

The evaluator must produce a verdict bundle at `.pge-artifacts/{run_id}-evaluator-verdict.md` using markdown with these top-level sections:
- `## verdict`
- `## evidence`
- `## violated_invariants_or_risks`
- `## required_fixes`
- `## next_route`

Section content must follow the evaluator contract:
- `verdict`: PASS | RETRY | BLOCK | ESCALATE
- `evidence`: Concrete evidence supporting verdict
- `violated_invariants_or_risks`: Issues found
- `required_fixes`: Specific fixes needed (if not PASS)
- `next_route`: continue | converged | retry | return_to_planner

Optional explanatory sections may follow, but the required bundle keys above must remain explicit and easy to parse from the artifact.

Update runtime state:
- Set `latest_evaluation_verdict` to verdict
- Transition to `routing`

### 6. Routing

Route based on verdict and stop condition per `./contracts/routing-contract.md`:

**PASS verdict:**
- If `run_stop_condition` is `single_round`: route to `converged`
- Otherwise: route to `continue` (next round)

**RETRY verdict:**
- Route to `retry` (regenerate with feedback)

**BLOCK verdict:**
- If current round still valid: route to `retry`
- If precondition missing: route to `return_to_planner`

**ESCALATE verdict:**
- Route to `return_to_planner`

Update runtime state:
- Set `latest_route` to routing decision
- Set `route_reason` to explanation
- If converged: set `convergence_reason` and transition to `converged`

### 7. Convergence

When routed to `converged`:
- Write round summary to `.pge-artifacts/{run_id}-round-summary.md`
- Report final state
- Stop execution

## Artifacts produced

All artifacts written to `.pge-artifacts/`:
- `{run_id}-planner-output.md`: Round contract
- `{run_id}-generator-output.md`: Implementation bundle
- `{run_id}-evaluator-verdict.md`: Evaluation verdict
- `{run_id}-round-summary.md`: Final summary (if converged)

Runtime state: `.pge-runtime-state.json`

## State transitions

Valid runtime states per `./contracts/runtime-state-contract.md`:
- `intake_pending`
- `planning_round`
- `preflight_pending`
- `preflight_failed`
- `ready_to_generate`
- `generating`
- `awaiting_evaluation`
- `evaluating`
- `routing`
- `converged`
- `failed_upstream`

Valid state transitions per `./contracts/runtime-state-contract.md`:
- `intake_pending` → `planning_round`
- `intake_pending` → `failed_upstream`
- `planning_round` → `preflight_pending`
- `planning_round` → `failed_upstream`
- `preflight_pending` → `ready_to_generate`
- `preflight_pending` → `preflight_failed`
- `preflight_failed` → `planning_round`
- `ready_to_generate` → `generating`
- `generating` → `awaiting_evaluation`
- `generating` → `routing`
- `awaiting_evaluation` → `evaluating`
- `evaluating` → `routing`
- `routing` → `planning_round`
- `routing` → `generating`
- `routing` → `converged`

Routing outcomes such as `continue`, `retry`, and `return_to_planner` are route tokens, not runtime states; apply them via `./contracts/routing-contract.md` to determine the next valid state transition.

## Non-goals

This skill does NOT:
- Define agent behavior (see `agents/` for that)
- Define contract structures (see `contracts/` for that)
- Support multi-round execution yet (single round only for MVP)
- Support external task execution yet (repo-internal only)

## Quality bar

A successful round:
- Planner produces an executable current-task contract
- Generator produces the actual deliverable plus local verification evidence (not placeholders)
- Evaluator independently validates the current task against the same contract
- Routing decision is explicit and justified
- All artifacts preserved for inspection

## Usage example

```
/pge-execute "Implement the user authentication flow as specified in docs/plans/auth-plan.md"
```

With custom stop condition:
```
/pge-execute "Fix all linting errors in src/" --run_stop_condition=until_converged
```
