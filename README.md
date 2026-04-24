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
- This repo now serves as both the plugin source repo and the single-plugin marketplace source for `pge`

Installed plugin bundles should expose this plugin-facing layout:

```text
.claude-plugin/plugin.json
skills/pge-execute/SKILL.md
skills/pge-execute/ORCHESTRATION.md
skills/pge-execute/contracts/*.md
agents/pge-planner.md
agents/pge-generator.md
agents/pge-evaluator.md
```

`contracts/` remains the canonical source location in this repo, but the installed/plugin-facing payload treats those files as supporting files of `pge-execute` under `skills/pge-execute/contracts/`.
They are not installed as a top-level `.claude/contracts/` runtime directory.

## Install and update flow

### Claude Code marketplace install

PGE is installed through the Claude Code marketplace at `feng-y/pge`.

Plugin name: `pge`
Marketplace name: `pge`

This repo now includes both manifests Claude Code expects:
- `.claude-plugin/marketplace.json` for marketplace registration
- `.claude-plugin/plugin.json` for the plugin itself

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

### Discoverability troubleshooting

If the installed skill or agents look stale after a GitHub or marketplace update:
- run `/reload-plugins`
- if the current session still looks stale, restart Claude Code
- if you previously used local/dev installs, clear old conflicting state before trusting discovery, especially `~/.claude/dev-plugins/pge`

Do not use the local helper as a workaround for marketplace discoverability. Fix the marketplace install state instead.

### Local development install

Use `./bin/pge-local-install.sh` only for maintainer/dev validation in a clean local environment.
It is not the formal install or update path, and it is not the right fix for marketplace/GitHub discoverability issues.

Normal users should stay on the marketplace path:

```text
/plugin marketplace update pge
/plugin update pge
/reload-plugins
```

If you need a clean reinstall:

```text
/plugin uninstall pge
/plugin install pge@pge
```

The local helper installs the minimum runtime-facing payload into `~/.claude/skills/pge` and exposes `~/.claude/skills/pge-execute/SKILL.md` for local validation only.
It intentionally does not copy docs, proving artifacts, or other repo-only files.

The helper now refuses to run if either of these conflict states is present:
- marketplace-installed plugin `pge@pge`
- legacy local state at `~/.claude/dev-plugins/pge`

If Claude Code is already running and marketplace changes are not discovered immediately, run `/reload-plugins` first, then restart the current session if needed.

## Normalized execution-core seams

For proving runs, the following files define the normative execution-core semantics:
- `agents/*.md` — P/G/E role responsibilities
- `contracts/*.md` — handoff contracts
- `skills/pge-execute/SKILL.md` — invocation surface
- `skills/pge-execute/ORCHESTRATION.md` — skill-internal run orchestration

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