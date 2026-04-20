# ISSUES_LEDGER

Keep this file lightweight. Record only items that help the current mainline move.

## P0 / Blocker

- The first real bounded proving/development round still needs its first runtime intake/state artifact frozen from the verified upstream packet.

## P1 / Follow-up

- Refine supporting governance docs only if a real proving run exposes contradiction or driveability pain.
- Add richer runtime/progress formalization only if the first proving runs show the current control plane is insufficient.

## P2 / Park

- Broader harness strategy expansion.
- Naming and terminology polish that does not unblock proving.
- Additional workflow/process machinery beyond the current minimal support layer.

## Resolved

- The support-layer setup round has landed.
- The first proving task is fixed as `run-001`.
- `commands/start-round.md` and `commands/close-round.md` now provide the executable round entry/closure path.
- `docs/proving/runs/run-002/upstream-plan.md` now provides the first verified execute-first upstream packet for real proving intake.
- No proving task is fixed yet.
- Preflight is now represented consistently enough across loop / state / skill for proving.
- `continue` vs `converged` is now driven by explicit `run_stop_condition` rather than prose-only judgment.
- Repo-level harness support surface has been added for future Claude Code sessions.

## Important decisions

- Current mainline is proving-first, not design-first.
- Only P0 should be worked in the active round.
- P1 is recorded but not expanded during the active round.
- P2 is parked without further discussion.
- Normalized seams under `agents/`, `contracts/`, and `skills/` are authoritative for proving runs.
