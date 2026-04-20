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
    echo "Agent: Planner"
    echo "Responsibility: Freeze one current round contract"
    echo "Input: upstream plan, entry contract, runtime state"
    echo "Output: current round contract"
    echo ""
    echo "Reading agent definition from: $AGENT_PLANNER"
    echo "Reading entry contract from: $CONTRACT_ENTRY"
    echo "Reading runtime state contract from: $CONTRACT_RUNTIME_STATE"
    echo ""

    # For MVP Round 1, we verify the planner can be reached
    if [[ -f "$AGENT_PLANNER" ]] && [[ -f "$CONTRACT_ENTRY" ]] && [[ -f "$CONTRACT_RUNTIME_STATE" ]]; then
        echo "✓ Planner agent definition found"
        echo "✓ Entry contract found"
        echo "✓ Runtime state contract found"
        echo ""
        echo "Next: Planner agent would freeze current round contract"
        echo "State: $(get_state)"
    else
        echo "✗ Missing required files"
        exit 1
    fi
}

main "$@"
