# RUNTIME_ORCHESTRATION_AUTHORITY

## Purpose

This file records the current-stage runtime-control policy for the split workflow.

It defines, in one place:
- runtime state/route expectations at a reference level
- artifact-chain expectations
- recovery/reporting boundaries
- how to talk about active execution without restoring legacy Team runtime assumptions

This file is reference material. The active execution seam is `skills/pge-exec/SKILL.md`, and current forward-path truth lives in `docs/exec-plans/CURRENT_MAINLINE.md`.

## Relationship to other seams

- `skills/pge-exec/SKILL.md` is the active skill-owned execution surface.
- `docs/exec-plans/CURRENT_MAINLINE.md` defines the current migration lane.
- `docs/exec-plans/ISSUES_LEDGER.md` records blockers and follow-ups.
- `docs/exec-plans/PGE_ORCHESTRATION_CONTRACT.md` records the normalized orchestration split.
- legacy `skills/pge-execute/*` remains migration/reference material and must not be treated as the preferred forward path.

## Current-stage claim

The active runtime direction is:

```text
pge-setup -> pge-plan -> pge-exec
```

Within that direction:
- `main` owns run-level route, stop, and recovery decisions
- `pge-exec` is the execution surface
- execution is plan-driven, artifact-first, and route/state oriented
- TDD is only one possible execution mode

This file does not require Team runtime lifecycle semantics.

## Ownership boundaries

| Surface | Owner | Must not own |
| --- | --- | --- |
| run-level route, stop, recovery, state tracking | `main` | unconstrained replanning or setup work |
| repo-local setup/config artifacts | `pge-setup` | execution routing |
| bounded plan artifact and execution hints | `pge-plan` | implementation work |
| numbered-issue execution, verification, run evidence, next route | `pge-exec` | setup scaffolding, broad design reset |

## Runtime state and route expectations

The active execution surface should keep state/route semantics explicit enough to prove bounded progress.

Reference expectations:
- input is either a valid plan artifact or a clearly documented fallback case
- missing required inputs should route to an info/blocker path rather than silent improvisation
- run artifacts should make selected issues, verification, evidence, and next route inspectable
- unsupported behavior should be reported honestly instead of implied as implemented
- final outputs should avoid `PASS`, `MERGED`, and `SHIPPED` as execution-surface route claims

Use the active `skills/pge-exec/SKILL.md` vocabulary when there is any conflict with older notes.

## Artifact-chain expectations

The split workflow should preserve a visible artifact chain:
- `.pge/config/*`
- `.pge/plans/<plan_id>.md`
- `.pge/runs/<run_id>/*`

Before routing, active execution should leave enough artifacts for a later human or tool to inspect:
- selected issue scope
- verification performed or explicitly unavailable
- changed files or no-change outcome
- evidence summary
- next-route rationale

## Recovery and reporting boundaries

Current-stage reporting should stay bounded and honest:
- report blockers when required inputs or verification entrypoints are missing
- record retry recommendations only when the same bounded issue still has a fair next attempt
- surface decision forks as decision-needed output rather than silent plan drift
- keep recovery/reporting tied to actual run artifacts instead of legacy Team-message protocols

## Anti-regression rules

To avoid sliding back into legacy runtime claims:
- do not require `TeamCreate`, `TeamDelete`, or `SendMessage` in active runtime docs
- do not describe Planner / Generator / Evaluator as the active preferred runtime lifecycle
- do not present legacy `skills/pge-execute/*` control-plane notes as current truth
- do not let TDD become the sole identity of execution

## Current-stage boundary

This file is intentionally modest. It does not claim:
- Team runtime lifecycle support
- an SDK runner
- automatic multi-round orchestration
- generalized autonomous recovery beyond the bounded run artifacts the split workflow already uses

Future design can extend these areas, but active repo truth should remain anchored to the split skills and their artifact contracts.
