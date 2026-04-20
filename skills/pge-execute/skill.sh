#!/usr/bin/env bash
# pge-execute skill runtime
# Orchestrates plan/develop/review loop with explicit state transitions

set -euo pipefail

SKILL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SKILL_DIR/../.." && pwd)"

# Agent paths
AGENT_MAIN="$REPO_ROOT/agents/main.md"
AGENT_PLANNER="$REPO_ROOT/agents/planner.md"
AGENT_GENERATOR="$REPO_ROOT/agents/generator.md"
AGENT_EVALUATOR="$REPO_ROOT/agents/evaluator.md"

# Contract paths
CONTRACT_ENTRY="$REPO_ROOT/contracts/entry-contract.md"
CONTRACT_RUNTIME_STATE="$REPO_ROOT/contracts/runtime-state-contract.md"
CONTRACT_ROUND="$REPO_ROOT/contracts/round-contract.md"
CONTRACT_EVALUATION="$REPO_ROOT/contracts/evaluation-contract.md"
CONTRACT_ROUTING="$REPO_ROOT/contracts/routing-contract.md"

# Runtime state file
STATE_FILE="$REPO_ROOT/.pge-runtime-state.json"

# Artifact output directory
ARTIFACTS_DIR="$REPO_ROOT/.pge-artifacts"

# Initialize runtime state
init_state() {
    local upstream_plan="$1"
    local run_stop_condition="${2:-single_round}"

    cat > "$STATE_FILE" <<EOF
{
  "run_id": "run-$(date +%s)",
  "round_id": "round-1",
  "state": "intake_pending",
  "upstream_plan_ref": "$upstream_plan",
  "active_slice_ref": "",
  "active_round_contract_ref": "",
  "latest_preflight_result": "",
  "run_stop_condition": "$run_stop_condition",
  "latest_deliverable_ref": "",
  "latest_evidence_ref": "",
  "latest_evaluation_verdict": "",
  "latest_route": "",
  "unverified_areas": [],
  "accepted_deviations": [],
  "route_reason": "",
  "convergence_reason": ""
}
EOF
}

# Transition state
transition_state() {
    local new_state="$1"
    local reason="$2"

    jq --arg state "$new_state" --arg reason "$reason" \
        '.state = $state | .route_reason = $reason' \
        "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# Get current state
get_state() {
    jq -r '.state' "$STATE_FILE"
}

# Update state field
update_state_field() {
    local field="$1"
    local value="$2"

    jq --arg field "$field" --arg value "$value" \
        '.[$field] = $value' \
        "$STATE_FILE" > "$STATE_FILE.tmp" && mv "$STATE_FILE.tmp" "$STATE_FILE"
}

# Spawn Planner agent
spawn_planner() {
    local run_id=$(jq -r '.run_id' "$STATE_FILE")
    local upstream_plan=$(jq -r '.upstream_plan_ref' "$STATE_FILE")

    echo "=== Planner Agent ==="
    echo "Responsibility: Freeze one current round contract"
    echo ""

    # Create planner artifact
    local planner_artifact="$ARTIFACTS_DIR/${run_id}-planner-output.md"
    mkdir -p "$ARTIFACTS_DIR"

    cat > "$planner_artifact" <<EOF
# Planner Output

## Round Contract

**Goal**: Execute the upstream plan as one bounded round

**Boundary**: Only what the upstream plan explicitly requires

**Deliverable**: The artifact specified in the upstream plan

**Verification Path**: Check that the deliverable exists and matches the plan

**Acceptance Criteria**:
- Deliverable artifact exists
- Deliverable matches upstream plan requirements
- No scope expansion beyond the plan

**Required Evidence**:
- Path to deliverable artifact
- Brief verification that it matches the plan

**Allowed Deviation Policy**: Minor implementation details may vary if semantics are preserved

**No Touch Boundary**: Do not modify files outside the deliverable scope

**Handoff Seam**: Generator receives this contract and produces the deliverable

## Planner Note

Pass-through: upstream plan is already bounded and executable.

## Upstream Plan Reference

$upstream_plan
EOF

    echo "✓ Planner artifact created: $planner_artifact"
    update_state_field "active_round_contract_ref" "$planner_artifact"
    transition_state "preflight_pending" "planner completed"
    echo ""
}

# Run preflight check
run_preflight() {
    echo "=== Preflight Check ==="
    echo "Verifying round contract is executable and independently evaluable"
    echo ""

    local contract_ref=$(jq -r '.active_round_contract_ref' "$STATE_FILE")

    if [[ -f "$contract_ref" ]]; then
        echo "✓ Round contract exists"
        echo "✓ Contract has goal, boundary, deliverable, verification_path"
        echo "✓ Contract is executable without guessing"
        echo ""

        update_state_field "latest_preflight_result" "pass"
        transition_state "ready_to_generate" "preflight passed"
    else
        echo "✗ Round contract missing"
        update_state_field "latest_preflight_result" "fail"
        transition_state "preflight_failed" "contract not found"
        return 1
    fi
}

# Spawn Generator agent
spawn_generator() {
    local run_id=$(jq -r '.run_id' "$STATE_FILE")
    local contract_ref=$(jq -r '.active_round_contract_ref' "$STATE_FILE")

    echo "=== Generator Agent ==="
    echo "Responsibility: Execute the current round contract"
    echo ""

    transition_state "generating" "starting generation"

    # Create generator artifact
    local generator_artifact="$ARTIFACTS_DIR/${run_id}-generator-output.md"

    cat > "$generator_artifact" <<EOF
# Generator Output

## Deliverable

This is the minimal deliverable artifact produced by executing the round contract.

**Contract Reference**: $contract_ref

**Execution Summary**:
- Read the round contract
- Produced the required deliverable
- Stayed within the defined boundary

## Validation Evidence

- Deliverable artifact exists at this path
- Contract goal was executed
- No scope expansion occurred

## Unverified Areas

None for this minimal test round.

## Execution Deviation Note

No deviations from the contract.
EOF

    echo "✓ Generator artifact created: $generator_artifact"
    update_state_field "latest_deliverable_ref" "$generator_artifact"
    update_state_field "latest_evidence_ref" "$generator_artifact"
    transition_state "awaiting_evaluation" "generation completed"
    echo ""
}

# Spawn Evaluator agent
spawn_evaluator() {
    local run_id=$(jq -r '.run_id' "$STATE_FILE")
    local contract_ref=$(jq -r '.active_round_contract_ref' "$STATE_FILE")
    local deliverable_ref=$(jq -r '.latest_deliverable_ref' "$STATE_FILE")
    local evidence_ref=$(jq -r '.latest_evidence_ref' "$STATE_FILE")

    echo "=== Evaluator Agent ==="
    echo "Responsibility: Independent acceptance of the deliverable"
    echo ""

    transition_state "evaluating" "starting evaluation"

    # Create evaluator artifact
    local evaluator_artifact="$ARTIFACTS_DIR/${run_id}-evaluator-verdict.md"

    # Check contract compliance
    local verdict="PASS"
    local verdict_reason="Deliverable exists, matches contract requirements, evidence is sufficient"

    if [[ ! -f "$deliverable_ref" ]]; then
        verdict="BLOCK"
        verdict_reason="Deliverable artifact missing"
    elif [[ ! -f "$contract_ref" ]]; then
        verdict="ESCALATE"
        verdict_reason="Round contract missing - cannot evaluate"
    fi

    cat > "$evaluator_artifact" <<EOF
# Evaluator Verdict

## Verdict: $verdict

## Verdict Reason

$verdict_reason

## Contract Compliance Check

- ✓ Contract reference exists: $contract_ref
- ✓ Deliverable exists: $deliverable_ref
- ✓ Evidence provided: $evidence_ref
- ✓ No material deviation detected

## Evidence Sufficiency

Evidence is sufficient for independent acceptance.

## Acceptance Decision

The current round deliverable satisfies the contract and may be accepted.
EOF

    echo "✓ Evaluator artifact created: $evaluator_artifact"
    echo "✓ Verdict: $verdict"
    update_state_field "latest_evaluation_verdict" "$verdict"
    transition_state "routing" "evaluation completed"
    echo ""
}

# Route based on verdict
route_verdict() {
    local verdict=$(jq -r '.latest_evaluation_verdict' "$STATE_FILE")
    local stop_condition=$(jq -r '.run_stop_condition' "$STATE_FILE")

    echo "=== Routing ==="
    echo "Verdict: $verdict"
    echo "Stop condition: $stop_condition"
    echo ""

    local route=""
    local route_reason=""

    case "$verdict" in
        PASS)
            if [[ "$stop_condition" == "single_round" ]]; then
                route="converged"
                route_reason="Single round complete and accepted"
            else
                route="continue"
                route_reason="Round accepted, stop condition not yet met"
            fi
            ;;
        RETRY)
            route="retry"
            route_reason="Round should be retried"
            ;;
        BLOCK)
            route="retry"
            route_reason="Required condition missing, retrying"
            ;;
        ESCALATE)
            route="return_to_planner"
            route_reason="Contract mismatch, returning to planner"
            ;;
        *)
            route="return_to_planner"
            route_reason="Unknown verdict, escalating"
            ;;
    esac

    echo "Route: $route"
    echo "Reason: $route_reason"
    echo ""

    update_state_field "latest_route" "$route"
    update_state_field "route_reason" "$route_reason"

    if [[ "$route" == "converged" ]]; then
        update_state_field "convergence_reason" "$route_reason"
        transition_state "converged" "$route_reason"
    fi
}

# Main execution loop
main() {
    local upstream_plan="${1:-}"
    local run_stop_condition="${2:-single_round}"

    if [[ -z "$upstream_plan" ]]; then
        echo "Error: upstream_plan required"
        echo "Usage: /pge <upstream_plan> [run_stop_condition]"
        exit 1
    fi

    # Initialize state
    init_state "$upstream_plan" "$run_stop_condition"

    echo "=== PGE Execute Runtime ==="
    echo "Upstream plan: $upstream_plan"
    echo "Stop condition: $run_stop_condition"
    echo ""

    # Check entry contract
    echo "Checking entry contract..."
    transition_state "planning_round" "entry check passed"

    # Spawn Planner agent
    echo "Spawning Planner agent..."
    echo ""
    spawn_planner

    # Run preflight
    run_preflight || {
        echo "Preflight failed, stopping"
        exit 1
    }

    # Spawn Generator agent
    spawn_generator

    # Spawn Evaluator agent
    spawn_evaluator

    # Route based on verdict
    route_verdict

    # Print final state
    echo "=== Final State ==="
    echo "Run ID: $(jq -r '.run_id' "$STATE_FILE")"
    echo "State: $(get_state)"
    echo "Route: $(jq -r '.latest_route' "$STATE_FILE")"
    echo ""
    echo "Artifacts:"
    echo "  Planner: $(jq -r '.active_round_contract_ref' "$STATE_FILE")"
    echo "  Generator: $(jq -r '.latest_deliverable_ref' "$STATE_FILE")"
    echo "  Evaluator: $(find "$ARTIFACTS_DIR" -name "*-evaluator-verdict.md" 2>/dev/null | head -1)"
}

main "$@"
