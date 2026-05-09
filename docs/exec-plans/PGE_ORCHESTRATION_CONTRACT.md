# PGE_ORCHESTRATION_CONTRACT

## Purpose

This file records the normalized orchestration split for the current PGE direction.

It defines, in one place:
- what `main` is
- what `main` is not
- how orchestration ownership relates to the split workflow
- how artifact-first execution should be described without restoring Team runtime claims

This file is a reference contract. For active day-to-day runtime truth, use:
- `skills/pge-exec/SKILL.md`
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`

## Normalized architecture

PGE should be described like this:
- `pge-setup` prepares repo-local config under `.pge/config/*`
- `pge-plan` writes one bounded plan artifact under `.pge/plans/<plan_id>.md`
- `pge-exec` consumes the plan and writes run artifacts under `.pge/runs/<run_id>/*`
- `main` remains the orchestration shell and control-plane authority for the run

## What `main` is

`main` is the skill-internal:
- run-level scheduler
- runtime-state owner
- route / stop / recovery owner
- artifact persistence owner
- input/handoff owner across setup, planning, and execution

## What `main` is not

`main` is **not**:
- a peer worker role
- a hidden substitute for setup/planning/execution surfaces
- a reason to restore resident Planner / Generator / Evaluator runtime semantics
- a generic agent OS control plane

`main` may use bounded helpers when justified, but helpers do not own workflow truth.

## Explicit split ownership

| Surface | Owner | Must not own |
| --- | --- | --- |
| repo-local setup/config checks and setup artifacts | `pge-setup` | planning, implementation, final route decisions |
| bounded goal shaping, scope, acceptance, verification hints, handoff plan artifact | `pge-plan` | code execution, final run routing |
| numbered-issue execution, verification, route/state handling, run artifacts | `pge-exec` | setup scaffolding, unconstrained replanning |
| run-level route, stop, and recovery decisions across the active workflow | `main` | silently reviving legacy Team orchestration as active truth |

## Relationship to other seams

- `skills/pge-exec/SKILL.md` is the active execution surface.
- `docs/exec-plans/CURRENT_MAINLINE.md` is the current forward-path summary.
- `docs/exec-plans/ISSUES_LEDGER.md` records the current blockers and follow-ups.
- legacy `skills/pge-execute/` and `agents/pge-*.md` remain reference/migration material only.

## Normalization rules

To avoid reintroducing old control-plane confusion:
- do not describe Planner / Generator / Evaluator as the active runtime team
- do not require `TeamCreate`, `TeamDelete`, or `SendMessage` in active split workflow docs
- do not describe `main` as a fourth worker role
- do not use legacy `pge-execute` runtime material as the preferred forward path
- when docs say "active workflow," they mean `pge-setup`, `pge-plan`, and `pge-exec`

## Current-stage boundary

This contract fixes the orchestration split for the current migration stage.

It does not claim:
- an SDK runner
- full autonomous retry loops
- persistent Team lifecycle support
- new workflow surfaces beyond the current split

Future execution-layer design can build on this contract, but active repo truth should stay anchored to the split skills and current execution-plan docs.
