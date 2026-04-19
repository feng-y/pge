# PGE

PGE is a skeleton-first repo for bounded execution flow.

## Structure

```text
agents/
contracts/
skills/
```

- `agents/` — responsibility layer
- `contracts/` — handoff layer
- `skills/` — invocation layer

## Current skill
- `skills/pge-execute/SKILL.md`

## Normalized execution-core seams

For proving runs, the following files define the normative execution-core semantics:
- `agents/*.md` — role responsibilities
- `contracts/*.md` — handoff contracts
- `skills/pge-execute/SKILL.md` — invocation surface

These seams are the source of truth for runtime state, verdict, routing, and stop-condition decisions.
For proving runs, preflight, route, state, and stop-condition vocabulary must come from these seams; legacy/reference docs may provide context but must not override them.

## Harness support surface

For current repo driving and proving/development rounds, start here:
- [`CLAUDE.md`](./CLAUDE.md) — repo-level working constraints for Claude Code
- [`docs/exec-plans/CURRENT_MAINLINE.md`](./docs/exec-plans/CURRENT_MAINLINE.md) — current goal, P0 blockers, non-goals, next action
- [`docs/exec-plans/ISSUES_LEDGER.md`](./docs/exec-plans/ISSUES_LEDGER.md) — P0 / P1 / P2 / resolved / decisions ledger
- [`docs/exec-plans/ROUND_TEMPLATE.md`](./docs/exec-plans/ROUND_TEMPLATE.md) — reusable round structure
- [`docs/proving/README.md`](./docs/proving/README.md) — entrypoint for proving/development runs

## Supporting reference docs

The following files provide richer governance guidance but must not override the normalized seams:
- [`phase-contract.md`](./phase-contract.md) — stronger planning guidance
- [`evaluation-gate.md`](./evaluation-gate.md) — richer evaluator guidance
- [`progress-md.md`](./progress-md.md) — progress consensus guidance

When proving the execution core, use these reference docs to enrich interpretation, but route/state/verdict vocabulary must follow the normalized contracts.