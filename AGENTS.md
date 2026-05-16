# AGENTS.md

This repo uses `CLAUDE.md` as the primary resident agent entry point.

## Where to look

| What | Where |
|------|-------|
| Resident agent rules | `CLAUDE.md` |
| Project map | `README.md` |
| Active research surface | `skills/pge-research/SKILL.md` |
| Active planning surface | `skills/pge-plan/SKILL.md` |
| Active normalization surface | `skills/pge-plan-normalize/SKILL.md` |
| Active execution surface | `skills/pge-exec/SKILL.md` |
| Active review surface | `skills/pge-review/SKILL.md` |
| Active prove-it surface | `skills/pge-challenge/SKILL.md` |
| Active AI-native refactor shaping surface | `skills/pge-ai-native-refactor/SKILL.md` |
| Active handoff surface | `skills/pge-handoff/SKILL.md` |
| Active knowledge surface | `skills/pge-knowledge/SKILL.md` |
| Active review agents | `agents/pge-code-reviewer.md`, `agents/pge-code-simplifier.md` |

## Key invariants

- `pge-research`, `pge-plan`, `pge-plan-normalize`, `pge-exec`, `pge-review`, `pge-challenge`, `pge-ai-native-refactor`, `pge-handoff`, and `pge-knowledge` are the active workflow surfaces.
- Active flow aligns to Research -> Plan -> Execute -> Review -> Ship.
- `main` owns route, state, and gate decisions.
- Subagents are bounded helpers, not workflow authorities.
- Active flow is artifact-first: `.pge/tasks-<slug>/research.md` -> `.pge/tasks-<slug>/plan.md` -> `.pge/tasks-<slug>/runs/<run_id>/*`, with `.pge/tasks-<slug>/review.md` and `.pge/tasks-<slug>/challenge.md` as bounded repair / prove-it handoff artifacts.
- `agents/pge-code-reviewer.md` and `agents/pge-code-simplifier.md` are spawned by pge-exec Final Review Gate.

Do not maintain separate agent rules in this file. All resident rules live in `CLAUDE.md`.
