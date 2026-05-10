# PGE_EXECUTION_LAYER_PLAN

## What this plan defines

This document is a reference architecture note for the execution layer during the skill split.

It describes the direction PGE is converging toward, but it does not override the active runtime truth for day-to-day execution. Use these active sources first:

- `README.md`
- `CLAUDE.md`
- `skills/pge-setup/SKILL.md`
- `skills/pge-plan/SKILL.md`
- `skills/pge-exec/SKILL.md`
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`

## Core definition

PGE is converging toward a repo-coupled, plan-driven execution layer built around an artifact-first workflow:

```text
pge-setup -> pge-plan -> pge-exec
```

Its primary execution input is a bounded plan artifact. PGE is not a generic intent-understanding layer, not a generic project manager, and not a generic autonomous agent OS.

## Target runtime organization

### Main

`main` remains the orchestration authority for a run.

At a high level, `main` owns:
- setup/plan/run intake
- runtime-state ownership
- artifact persistence ownership
- route selection
- stop / recovery ownership

It must not be modeled as a peer worker role.

### Setup / Plan / Execute split

The active workflow surfaces are:
- `pge-setup` for repo-local config and setup status
- `pge-plan` for bounded plan artifact creation
- `pge-exec` for numbered-issue execution, lightweight gates, and routing

This split is the active direction of the repo.

## Execution backbone

The execution layer should preserve a visible file-based handoff chain:
- setup/config artifacts under `.pge/config/*`
- plan artifacts under `.pge/plans/<plan_id>.md`
- run artifacts under `.pge/runs/<run_id>/*`

That artifact chain is the backbone of the current split.

## Legacy runtime material

Older `skills/pge-execute/` and `agents/pge-*.md` surfaces remain in the repo as migration/reference material.

They may still contain Planner / Generator / Evaluator runtime language, but they do not define the preferred forward path for active work.

## Guardrails from review

The execution layer should continue to converge toward:
- explicit route/state vocabulary
- bounded execution windows
- artifact-first handoffs
- clear verification expectations
- fail-fast handling when required inputs are missing
- honest reporting of unsupported or deferred behavior

These guardrails should improve the split workflow, not reintroduce Team runtime semantics.

## What must remain true while evolving

- `main` stays the orchestration authority.
- active workflow truth stays with `pge-setup`, `pge-plan`, and `pge-exec`.
- artifact roots remain explicit and inspectable.
- route/state semantics stay concrete enough for proving.
- legacy runtime reference material must not silently regain active authority.

## What this plan does not require immediately

This reference plan does not claim that all future execution-layer mechanics are already implemented today.

In particular, it does not require:
- an SDK runner
- Team runtime lifecycle support
- broad autonomous multi-round execution
- generalized production-grade recovery
- new workflow surfaces beyond the current split

## Success condition for the broader plan

This direction is succeeding when:
- the repo consistently uses `pge-setup -> pge-plan -> pge-exec` as its active workflow story
- install surfaces project only the split skills by default
- execution docs stay aligned to route/state/artifact semantics
- legacy Team-runtime material remains reference-only
- future improvements tighten validation and proving rather than reopening settled split decisions
