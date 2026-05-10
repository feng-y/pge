# CURRENT_MAINLINE

## Current mainline

The active workflow is:

```text
pge-research -> pge-plan -> pge-exec
```

With `pge-setup` for one-time repo config and `pge-handoff` for session state persistence.

`pge-exec` is the execution surface. It is main-led, plan-driven, and route/state oriented.

## Why this is the mainline

Repo evidence:
- `skills/pge-setup/SKILL.md` — repo-local config scaffolding
- `skills/pge-research/SKILL.md` — pre-planning exploration
- `skills/pge-plan/SKILL.md` — bounded plan artifact creation
- `skills/pge-exec/SKILL.md` — numbered-issue execution with Generator + Evaluator
- `skills/pge-handoff/SKILL.md` — session state and knowledge extraction
- `.claude-plugin/plugin.json` projects only the five active skill surfaces

## Active stage

Stage 1.0 — pipeline operational, proving runs in progress

## Current focus

- Prove the full pipeline (research → plan → exec) on real repo tasks
- Accumulate run evidence under `.pge/runs/`
- Surface concrete missing AI-operability surfaces through execution failures

## Explicit non-goals

- restoring `TeamCreate`, `TeamDelete`, or `SendMessage` as active runtime requirements
- reviving Planner / Generator / Evaluator as resident runtime teammates
- implementing an SDK runner
- treating `pge-exec` as a TDD-only workflow
- broad design expansion

## Stage exit criteria

This stage is done when:
- at least 3 proving runs complete the full pipeline successfully
- run artifacts demonstrate bounded verification at each issue
- no active docs reference `pge-execute` as current truth
