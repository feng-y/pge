#!/bin/bash
# Test script to verify Agent authentication fallback behavior
# Usage: ./bin/test-agent-auth-fallback.sh

set -euo pipefail

echo "=== Testing Agent Authentication Fallback ==="
echo ""

# Test 1: Check if TeamCreate works
echo "Test 1: TeamCreate capability"
cat > /tmp/test-team.md <<'EOF'
Test if we can create a team and spawn agents.

Steps:
1. Call TeamCreate(team_name="test-auth-team")
2. Spawn Agent(subagent_type="general-purpose", team_name="test-auth-team", name="test-agent")
3. Wait 30s for lane_ready
4. Record if agent registered in Team runtime
5. Record if agent shows auth failure
6. Clean up with TeamDelete()

Expected: Either agent works, or we get auth failure signal
EOF

echo "  → Test plan written to /tmp/test-team.md"
echo ""

# Test 2: Check current pge-exec behavior on auth failure
echo "Test 2: Verify pge-exec Fallback Protocol activation"
cat > /tmp/verify-fallback.md <<'EOF'
Verify pge-exec handles auth failure correctly per line 336-343.

Scenario:
- Agent spawn succeeds
- No lane_ready received (30s timeout)
- Check shows auth failure: "Not logged in"

Expected per lines 375, 387-388:
1. Do NOT retry spawn
2. Record startup_status: FAILED
3. Record startup_failure_surface: team_auth_failure
4. Record execution_mode: main_thread_fallback
5. Main thread executes issue directly
6. Write to state.json, manifest.md, implementation-notes.md

Current fix (line 336-343):
- Removed incorrect "inherit authentication" assumption
- Made fallback explicit for auth failures
- Clarified this is a startup boundary, not implementation blocker
EOF

echo "  → Verification criteria written to /tmp/verify-fallback.md"
echo ""

# Test 3: Suggest concrete exec improvement
echo "Test 3: Improvement recommendations"
cat > /tmp/exec-improvements.md <<'EOF'
## Recommended Improvements

### Immediate (already done):
1. ✅ Line 336: Remove "inherit authentication" assumption
2. ✅ Line 336-343: Add explicit auth inheritance guidance
3. ✅ Clarify fallback activation for auth failures

### Short-term (scripted checks):
1. Create bin/pge-check-agent-auth.sh:
   - Spawn test agent
   - Check registration
   - Check auth state
   - Return JSON: {"auth_works": true/false, "reason": "..."}
   - Use BEFORE creating multi-lane teams

2. Add to Agent Startup Verification (line 351):
   - Before waiting 30s, do quick auth check (5s timeout)
   - If auth fails immediately, skip to fallback
   - Save 25s on known auth failures

### Medium-term (better diagnostics):
1. Enhanced state.json lane_health:
   - Add "auth_check_result" field
   - Add "lane_ready_received_at" timestamp
   - Add "startup_logs" excerpt (last 10 lines)

2. Structured startup failure reporting:
   ```json
   {
     "startup_failure_surface": "team_auth_failure",
     "auth_check": {
       "attempted": true,
       "passed": false,
       "error": "Not logged in",
       "timestamp": "..."
     },
     "lane_ready_wait": {
       "timeout_ms": 30000,
       "received": false
     }
   }
   ```

### Long-term (runtime improvement):
1. Request Claude Code team to fix:
   - Native Agent Teams should inherit auth by default
   - Or provide explicit auth propagation API
   - Document expected behavior clearly

2. Fallback should be rare, not default execution mode
EOF

echo "  → Improvements written to /tmp/exec-improvements.md"
echo ""

echo "=== Summary ==="
echo "✅ pge-exec SKILL.md updated (line 336-343)"
echo "📋 Test plans created in /tmp/"
echo "🔍 Next steps:"
echo "   1. Review /tmp/verify-fallback.md for expected behavior"
echo "   2. Test actual pge-exec with a simple plan"
echo "   3. Verify fallback activates correctly on auth failure"
echo "   4. Consider implementing bin/pge-check-agent-auth.sh"
echo ""
