# Manifest: 20260511-0017-smoke

## Run Metadata
- run_id: 20260511-0017-smoke
- plan_id: inline-smoke-test
- plan_path: inline (smoke test)
- started: 2026-05-11T00:17:00Z
- completed: 2026-05-11T00:20:17Z
- route: SUCCESS
- team: generator + evaluator (Agent Teams)

## Issues
| ID | Title | Status | Attempts | Generator | Evaluator |
|----|-------|--------|----------|-----------|-----------|
| 1 | Write smoke file | PASS | 1 | READY (confidence: 100) | PASS |

## Skipped Issues
None

## Communication Protocol Verified
- Generator dispatch: structured execution pack sent via SendMessage
- Generator completion: structured response with status/evidence/changed_files/deviations
- Evaluator dispatch: structured criteria + generator claim sent via SendMessage
- Evaluator verdict: structured response with verdict/confidence/evidence_checked/scope_check
- Shutdown: graceful via shutdown_request
- Team lifecycle: TeamCreate → spawn → dispatch → completion → verdict → shutdown → TeamDelete

## Stop Condition
smoke.txt exists with correct content — PASS

## Review Gate
Skipped (smoke test, 1 file, no security surface)

## Changed Files
- .pge/runs/20260511-0017-smoke/deliverables/smoke.txt (created)
