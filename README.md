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

## Plugin packaging

PGE is now packaged as a Claude Code plugin source repo.

- Plugin metadata lives at `.claude-plugin/plugin.json`
- Canonical source artifacts remain in `skills/`, `agents/`, and `contracts/`
- The repo-local `.claude/` tree is a development-time projection surface only; it is not the packaged runtime layout
- Marketplace catalog entries belong in a separate marketplace repo, not in this source repo

Installed plugin bundles should expose this plugin-facing layout:

```text
.claude-plugin/plugin.json
skills/pge-execute/SKILL.md
skills/pge-execute/contracts/*.md
agents/planner.md
agents/generator.md
agents/evaluator.md
```

`contracts/` remains the canonical source location in this repo, but the installed/plugin-facing payload treats those files as supporting files of `pge-execute` under `skills/pge-execute/contracts/`.
They are not installed as a top-level `.claude/contracts/` runtime directory.

## Install and update flow

### Claude Code marketplace install

PGE is installed through the Claude Code marketplace at `feng-y/pge`.

Plugin name: `pge`
Marketplace name: `pge`

In Claude Code, register the marketplace first:

```text
/plugin marketplace add feng-y/pge
```

Then install the plugin from that marketplace:

```text
/plugin install pge@pge
```

If you want the marketplace registered at project scope instead of user scope, use the CLI form:

```bash
claude plugin marketplace add --scope project feng-y/pge
```

### Update marketplace metadata

Refresh all configured marketplaces:

```text
/plugin marketplace update
```

Or refresh this marketplace explicitly:

```text
/plugin marketplace update pge
```

### Update or reinstall PGE

Update the installed plugin:

```text
/plugin update pge
```

If you need a clean reinstall:

```text
/plugin uninstall pge
/plugin install pge@pge
```

### Reload plugins in the current session

If Claude Code is already running, reload installed plugin contents:

```text
/reload-plugins
```

Distributable changes should bump the version in `.claude-plugin/plugin.json` so marketplace/plugin update detection remains explicit.

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