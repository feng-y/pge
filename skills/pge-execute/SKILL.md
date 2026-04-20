# pge-execute

Execute one bounded PGE round: plan → generate → evaluate → route.

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

1. **Planning phase**: Spawn Planner agent to freeze one current round contract
2. **Preflight check**: Validate contract is executable and independently evaluable
3. **Generation phase**: Spawn Generator agent to execute contract and produce deliverable
4. **Evaluation phase**: Spawn Evaluator agent to independently validate deliverable
5. **Routing**: Route based on verdict and stop condition

## Input

Required:
- `upstream_plan`: The plan to execute (as text or file reference)

Optional:
- `run_stop_condition`: When to stop (`single_round` [default] | `until_converged` | custom)

## Agents used

This skill spawns specialized agents defined in `../../agents/`:

- **planner** (`../../agents/planner.md`): Freezes one current round contract
- **generator** (`../../agents/generator.md`): Executes contract and produces deliverable
- **evaluator** (`../../agents/evaluator.md`): Independently validates deliverable

Each agent has a defined responsibility boundary. See `agents/` for their contracts.

## Contracts

Agent handoffs follow contracts defined in `../../contracts/`:

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
  "active_round_contract_ref": "",
  "latest_preflight_result": "",
  "run_stop_condition": "{single_round|until_converged}",
  "latest_deliverable_ref": "",
  "latest_evidence_ref": "",
  "latest_evaluation_verdict": "",
  "latest_route": "",
  "route_reason": "",
  "convergence_reason": ""
}
```

Transition to `planning_round` state.

### 2. Planning phase

Spawn **planner** agent using the Agent tool:
- `subagent_type`: "general-purpose"
- `prompt`: Load and provide `../../agents/planner.md` instructions
- Input: upstream plan, current runtime state
- Task: Freeze one current round contract per `../../contracts/round-contract.md`

The planner must produce a round contract artifact at `.pge-artifacts/{run_id}-planner-output.md` with:
- `goal`: What this round must settle
- `boundary`: What this round may change
- `deliverable`: The artifact to produce
- `verification_path`: How to verify
- `acceptance_criteria`: Minimum conditions for completion
- `required_evidence`: Evidence Evaluator needs
- `allowed_deviation_policy`: Which deviations are acceptable
- `no_touch_boundary`: What must stay out of scope
- `handoff_seam`: Where later work can continue

Update runtime state:
- Set `active_round_contract_ref` to contract artifact path
- Transition to `preflight_pending`

### 3. Preflight check

Validate the round contract:
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

Spawn **generator** agent using the Agent tool:
- `subagent_type`: "general-purpose"
- `prompt`: Load and provide `../../agents/generator.md` instructions
- Input: round contract, minimal repo context
- Task: Execute contract and produce actual deliverable

The generator must produce an implementation bundle at `.pge-artifacts/{run_id}-generator-output.md` with:
- `actual_deliverable`: What was actually delivered
- `deliverable_path`: Repo-relative path(s)
- `changed_files`: Files created or modified
- `local_verification`: Checks run and results
- `evidence`: Concrete evidence
- `known_limits`: Unverified areas
- `deviations_from_spec`: Deviations with justifications

Update runtime state:
- Set `latest_deliverable_ref` to deliverable path
- Set `latest_evidence_ref` to evidence artifact
- Transition to `awaiting_evaluation`

### 5. Evaluation phase

Spawn **evaluator** agent using the Agent tool:
- `subagent_type`: "general-purpose"
- `prompt`: Load and provide `../../agents/evaluator.md` instructions
- Input: round contract, implementation bundle
- Task: Independently validate deliverable against contract

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

Route based on verdict and stop condition per `../../contracts/routing-contract.md`:

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

Valid state transitions per `../../contracts/runtime-state-contract.md`:
- `intake_pending` → `planning_round`
- `planning_round` → `preflight_pending`
- `preflight_pending` → `ready_to_generate` | `preflight_failed`
- `preflight_failed` → `planning_round`
- `ready_to_generate` → `generating`
- `generating` → `awaiting_evaluation`
- `awaiting_evaluation` → `evaluating`
- `evaluating` → `routing`
- `routing` → `converged` | `retry` | `return_to_planner` | `continue`

## Non-goals

This skill does NOT:
- Define agent behavior (see `agents/` for that)
- Define contract structures (see `contracts/` for that)
- Support multi-round execution yet (single round only for MVP)
- Support external task execution yet (repo-internal only)

## Quality bar

A successful round:
- Planner produces executable contract
- Generator produces actual deliverable (not placeholders)
- Evaluator independently validates against contract
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
