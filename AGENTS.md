# AGENTS.md

This repo uses `CLAUDE.md` as the primary resident agent entry point.

## Where to look

| What | Where |
|------|-------|
| Resident agent rules | `CLAUDE.md` |
| Project map | `README.md` |
| Active setup surface | `skills/pge-setup/SKILL.md` |
| Active research surface | `skills/pge-research/SKILL.md` |
| Active planning surface | `skills/pge-plan/SKILL.md` |
| Active execution surface | `skills/pge-exec/SKILL.md` |
| Legacy runtime reference | `skills/pge-execute/`, `agents/pge-*.md` |

## Key invariants

- `pge-setup`, `pge-research`, `pge-plan`, and `pge-exec` are the active workflow surfaces.
- `main` owns route, state, and gate decisions.
- Subagents are bounded helpers, not workflow authorities.
- Active flow is artifact-first: `.pge/config/*` -> `.pge/tasks-<slug>/research.md` -> `.pge/tasks-<slug>/plan.md` -> `.pge/tasks-<slug>/runs/<run_id>/*`.
- Legacy `skills/pge-execute/` and `agents/pge-*.md` are migration/reference material, not active Team runtime truth.

Do not maintain separate agent rules in this file. All resident rules live in `CLAUDE.md`.
