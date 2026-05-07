# AGENTS.md

This repo uses `CLAUDE.md` as the primary resident agent entry point.

## Where to look

| What | Where |
|------|-------|
| Resident agent rules | `CLAUDE.md` |
| Project map | `README.md` |
| Runtime orchestration | `skills/pge-execute/SKILL.md`, `skills/pge-execute/ORCHESTRATION.md` |
| Runtime contracts | `skills/pge-execute/contracts/*.md` |
| P/G/E role behavior | `agents/pge-planner.md`, `agents/pge-generator.md`, `agents/pge-evaluator.md` |
| Current mainline | `docs/exec-plans/CURRENT_MAINLINE.md` |
| Issue ledger | `docs/exec-plans/ISSUES_LEDGER.md` |

## Key invariants

- P/G/E are workflow nodes, not roleplay prompts.
- `main` owns route, state, and gate decisions.
- Subagents are phase-local helpers, not workflow authorities.
- Only canonical P/G/E outputs drive phase completion.

Do not maintain separate agent rules in this file. All resident rules live in `CLAUDE.md`.
