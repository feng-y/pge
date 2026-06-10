#!/bin/bash
# Test the complete agent auth failure → fallback flow
# This creates a minimal test scenario to verify the fix

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=== Agent Auth Fallback Flow Test ==="
echo ""

# Create a minimal test plan
TEST_DIR="$PROJECT_ROOT/.pge/tasks-test-agent-auth"
mkdir -p "$TEST_DIR/issues"

echo "📝 Creating minimal test plan..."

cat > "$TEST_DIR/plan.md" <<'EOF'
# Plan: Test Agent Auth Fallback

## schema_version: plan.v2

## goal
Verify pge-exec handles agent authentication failure gracefully by activating main_thread_fallback.

## selected_approach
- Approach: Create one simple issue that can execute in fallback mode
- Rationale: Minimal test case to verify fallback activation
- Basis: Testing fix for agent authentication inheritance

## target_areas
- Create test-output.txt — reason: test deliverable

## forbidden_areas
- None — reason: test case

## issues

| ID | File | Title | State | Depends On | Verification Coupling | Execution Type | Security | Parallel Hint |
|---|---|---|---|---|---|---|---|---|
| I001 | `issues/I001.md` | Create test file | READY_FOR_EXECUTE | none | independent | AFK | no | sequential base |

## acceptance
- test-output.txt exists with content "Agent auth fallback test passed"

## verification
```bash
test -f test-output.txt && grep -q "Agent auth fallback test passed" test-output.txt
```

## evidence_required
- test-output.txt created
- state.json shows execution_mode (agent or main_thread_fallback)

## stop_conditions
test-output.txt exists with expected content

## terminal_conditions

| Condition | Gate Verdict | Plan Route | Exec Allowed | Handling |
|-----------|--------------|------------|--------------|----------|
| none | PASS | READY_FOR_EXECUTE | yes | No terminal conditions identified. |

## plan_gate

- Verdict: PASS
- Exec Allowed: yes
- Failed Gate: none
- Failed Criterion: none
- Evidence: none
- Required Repair: none
- Rationale: Minimal test plan is complete

### Gate Checklist

| Gate | Status | Evidence | Required Repair |
|------|--------|----------|-----------------|
| Contract Completeness | PASS | All required sections present | none |
| Source Fidelity | SKIP_NOT_APPLICABLE | Test case | none |
| Plan Engineering Review | PASS | Single simple issue | none |
| Repo Reality | PASS | No repo dependencies | none |
| Execution Readiness | PASS | Issue file complete | none |
| Skill Execution Stability | PASS | Standard issue format | none |

## route

- plan_route: READY_FOR_EXECUTE
- Justification: Test plan is ready for execution

## Metadata

- plan_id: 20260606-1000-test-agent-auth
- created_at: 2026-06-06T10:00:00Z
- source_ref: docs/fix-agent-auth-inheritance.md
- fast_adopt: false
- source_type: current_prompt
- source_fidelity: SKIP_NOT_APPLICABLE
- task_dir: .pge/tasks-test-agent-auth/
- workflow_handoff_path: not_generated

## Handoff To Execute

- Process issues by number starting from Issue 1
- Eligible issues: I001
- AFK issues: I001
- HITL issues: none
- Issue files: issues/I001.md
- Forbidden areas: none
- Necessary context: Test case for agent auth fallback
- Recommended approach: Create simple text file
- Compile-coupled / shared-verification groups: none
- Parallel safety: same working tree allowed
- Optional risk-triggered checks: none
EOF

cat > "$TEST_DIR/issues/I001.md" <<'EOF'
# Issue I001: Create test file

## goal
Create a test output file to verify execution completed.

## plan_context
Test case for agent authentication fallback. This issue should execute successfully whether using agent lanes or main_thread_fallback.

## change
Create test-output.txt with specific content.

## target_areas
- Create test-output.txt

## recommended_approach
Use bash to create the file:
```bash
echo "Agent auth fallback test passed" > test-output.txt
```

## forbidden
- Do not modify any existing files
- Do not create files outside the current directory

## validation
```bash
test -f test-output.txt && grep -q "Agent auth fallback test passed" test-output.txt
```

Expected: Exit code 0, file exists with correct content.
EOF

echo "✅ Test plan created at: $TEST_DIR"
echo ""

echo "📋 Test execution instructions:"
echo ""
echo "  1. Run pge-exec on this test plan:"
echo "     /pge-exec test-agent-auth"
echo ""
echo "  2. Observe the behavior:"
echo "     - If agent spawn succeeds: normal lane execution"
echo "     - If agent spawn fails with auth error: fallback activation"
echo ""
echo "  3. Verify the results:"
echo "     - Check state.json:"
echo "       python3 bin/validate-fallback-state.py $TEST_DIR/runs/<run_id>/state.json"
echo ""
echo "     - Check manifest.md for fallback recording"
echo "     - Check implementation-notes.md for fallback note"
echo "     - Verify test-output.txt was created successfully"
echo ""

echo "✨ Expected outcomes:"
echo ""
echo "  Scenario A: Agent auth works"
echo "    - generator-1 sends lane_ready within 30s"
echo "    - Normal lane execution"
echo "    - state.json: execution_mode: agent"
echo ""
echo "  Scenario B: Agent auth fails (the fix scenario)"
echo "    - generator-1 does NOT send lane_ready (30s timeout)"
echo "    - Auth failure detected: 'Not logged in' or similar"
echo "    - Fallback automatically activated"
echo "    - Main thread executes issue directly"
echo "    - state.json: execution_mode: main_thread_fallback"
echo "    - state.json: startup_failure_surface: team_auth_failure"
echo "    - manifest.md: records fallback activation and reason"
echo "    - Test still completes successfully!"
echo ""

echo "🔍 Validation commands:"
echo ""
echo "  # After execution completes, run:"
echo "  RUN_ID=\$(ls -t $TEST_DIR/runs/ | head -1)"
echo "  python3 bin/validate-fallback-state.py $TEST_DIR/runs/\$RUN_ID/state.json"
echo "  cat $TEST_DIR/runs/\$RUN_ID/manifest.md"
echo "  cat $TEST_DIR/runs/\$RUN_ID/implementation-notes.md"
echo "  cat test-output.txt"
echo ""
