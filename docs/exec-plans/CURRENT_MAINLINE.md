# CURRENT_MAINLINE

## Current mainline

Converge repo truth, install surfaces, and execution contracts around the split workflow:

```text
pge-setup -> pge-plan -> pge-exec
```

`pge-exec` is the active execution surface. It is main-led, plan-driven, and route/state oriented. It is not a Claude Code Agent Teams runtime, not a three-agent Planner / Generator / Evaluator orchestrator, and not a TDD skill.

## Why this is the mainline

Repo evidence now supports the split architecture:
- `skills/pge-setup/SKILL.md` defines repo-local setup/config scaffolding.
- `skills/pge-plan/SKILL.md` defines bounded plan artifact creation.
- `skills/pge-exec/SKILL.md` defines numbered-issue execution with route/state vocabulary.
- `.claude-plugin/plugin.json` and `bin/pge-local-install.sh` now project only the split skill surfaces for local install.
- Remaining work is closing legacy truth drift and any follow-on contract gaps, not restoring `TeamCreate` or Team lifecycle control-plane semantics.

## Active stage

Stage 0.5 — split-skill truth closure + contract/runtime alignment

## Current blocker

The split surfaces now exist, but some top-level and historical execution-plan docs still describe the legacy `pge-execute` Team runtime as current truth. The active lane is to:

- keep top-level docs aligned to `pge-setup -> pge-plan -> pge-exec`
- keep legacy `skills/pge-execute/` and `agents/pge-*.md` explicitly downgraded to migration/reference material
- keep install/runtime docs honest about what is already aligned versus what still needs proving
- avoid reintroducing Team runtime vocabulary into active setup/plan/exec surfaces

## What this round is optimizing for

- one clear active workflow story across `README.md`, `CLAUDE.md`, `AGENTS.md`, and `docs/exec-plans/*`
- artifact-first handoff semantics:
  - `.pge/config/*`
  - `.pge/plans/<plan_id>.md`
  - `.pge/runs/<run_id>/*`
- `pge-exec` as the route/state owner for execution decisions
- TDD framed only as one execution mode when appropriate
- legacy runtime material kept available for reference without claiming active authority

## Explicit non-goals

- restoring `TeamCreate`, `TeamDelete`, or `SendMessage` as active runtime requirements
- reviving Planner / Generator / Evaluator as resident runtime teammates
- implementing an SDK runner
- treating `pge-exec` as a TDD-only workflow
- broad design expansion beyond the current split migration

## Next single action

Finish downgrading the remaining top-level execution-plan docs that still present the legacy Team runtime as active truth, then rerun contract/install validation against the split surfaces.

## Stage exit criteria

This stage is done when:
- top-level runtime docs consistently describe the split workflow as current truth
- local install projects only `pge-setup`, `pge-plan`, and `pge-exec`
- legacy `skills/pge-execute/` and `agents/pge-*.md` are described as migration/reference material rather than active runtime surfaces
- active skill surfaces do not require `TeamCreate`, `TeamDelete`, or `SendMessage`
- active execution docs describe `pge-exec` as main-led, plan-driven, and route/state based
- remaining open items are concrete validation or contract follow-ups rather than architecture ambiguity
