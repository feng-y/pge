# AGENTS.md

This repo uses `CLAUDE.md` as the primary resident agent entry point.

## Where to look

| What | Where |
|------|-------|
| Resident agent rules | `CLAUDE.md` |
| Project map | `README.md` |
| Active research surface | `skills/pge-research/SKILL.md` |
| Active planning surface | `skills/pge-plan/SKILL.md` |
| Active execution surface | `skills/pge-exec/SKILL.md` |
| Active handoff surface | `skills/pge-handoff/SKILL.md` |
| Active knowledge surface | `skills/pge-knowledge/SKILL.md` |
| Active review agents | `agents/pge-code-reviewer.md`, `agents/pge-code-simplifier.md` |

## Key invariants

- `pge-research`, `pge-plan`, `pge-exec`, `pge-handoff`, and `pge-knowledge` are the active workflow surfaces.
- `main` owns route, state, and gate decisions.
- Subagents are bounded helpers, not workflow authorities.
- Active flow is artifact-first: `.pge/tasks-<slug>/research.md` -> `.pge/tasks-<slug>/plan.md` -> `.pge/tasks-<slug>/runs/<run_id>/*`.
- `agents/pge-code-reviewer.md` and `agents/pge-code-simplifier.md` are spawned by pge-exec Final Review Gate.

Do not maintain separate agent rules in this file. All resident rules live in `CLAUDE.md`.
