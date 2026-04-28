# PGE Plugin Distribution

## Purpose

This repo is the **source repo** for the PGE Claude Code plugin.

It also serves as the **single-plugin marketplace repo** for `pge`, and it is not an installed `.claude/` runtime tree.

The goal of this packaging layer is to make PGE installable and updatable through the Claude Code plugin marketplace model while preserving the existing source-oriented layout.

## Source layout vs installed layout

### Source layout in this repo

Runtime-authoritative source artifacts remain here:

- `skills/pge-execute/SKILL.md`
- `agents/pge-planner.md`
- `agents/pge-generator.md`
- `agents/pge-evaluator.md`
- `skills/pge-execute/contracts/*.md`
- `.claude-plugin/plugin.json`

The repo-local `.claude/` directory is only a development-time projection surface used for local iteration. It is not the packaged runtime contract.

### Installed plugin layout

When Claude Code installs the plugin, the plugin-facing bundle should expose this shape:

```text
.claude-plugin/plugin.json
skills/pge-execute/SKILL.md
skills/pge-execute/contracts/*.md
agents/pge-planner.md
agents/pge-generator.md
agents/pge-evaluator.md
```

This keeps the source repo source-oriented without treating `contracts/` as a top-level installed runtime concept.

## Contracts placement

Contracts are installed as **plugin-owned supporting files** under `skills/pge-execute/contracts/` inside the plugin bundle.

Why this layout was chosen:
- `pge-execute` is the runtime-facing skill that consumes these contracts
- installed layout should make the ownership relation explicit
- plugin install correctness depends on skill-local files, not on a top-level `contracts/` directory
- this avoids a top-level `.claude/contracts/` runtime directory
- this avoids broader plugin architecture changes beyond the current install correction

The old top-level `contracts/` directory has been removed. Runtime authority remains skill-local.

## Plugin manifest

The plugin manifest for this repo lives at:

- `.claude-plugin/plugin.json`

The manifest is authoritative for:
- plugin identity (`name`)
- explicit plugin version (`version`)
- installable runtime-facing skill/agent exposure

## Marketplace manifest

This repo now includes a marketplace catalog at:

- `.claude-plugin/marketplace.json`

The catalog exposes a single plugin entry:
- marketplace name: `pge`
- plugin name: `pge`
- plugin source: `./`

Using `source: "./"` keeps the marketplace entry pointed at this repo's existing plugin root.
That allows Claude Code to:
- add `feng-y/pge` as a marketplace
- install `pge` from that marketplace with `pge@pge`

This is the minimum same-repo marketplace layout. A separate marketplace repo remains optional later, but it is not required for current install support.

## Versioning policy

Use semver in `.claude-plugin/plugin.json`.

Rules for this repo:
- bump the version for distributable plugin changes
- do not rely on source changes alone for plugin update detection
- keep versioning explicit so marketplace/plugin update behavior remains predictable

## Intended update path

Normal update flow:

1. The marketplace catalog points to the updated plugin source revision
2. The user refreshes or updates the plugin through the Claude Code plugin/marketplace flow
3. The user runs `/reload-plugins` if the current Claude Code session must reload plugin contents

This round intentionally does **not** add a custom updater mechanism beyond the built-in marketplace/plugin flow.

## Local development install

For local development only, this repo also provides a helper script:

- `bin/pge-local-install.sh`

The helper installs the minimum runtime-facing PGE payload as a dev-plugin override at:

- `~/.claude/dev-plugins/pge`

This local install exists only to shorten the validation loop while iterating on this repo.
It is not a replacement for marketplace/plugin install or update.

The installed payload should include:
- `.claude-plugin/plugin.json`
- `SKILL.md`
- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/contracts/*.md`
- `agents/pge-planner.md`
- `agents/pge-generator.md`
- `agents/pge-evaluator.md`

The helper must not create parallel top-level skill or agent surfaces under `~/.claude/skills/pge-execute` or `~/.claude/agents`.
If older helper-created paths still exist there, the helper removes them during install and clean.

The local install should not include repo-only material such as docs, proving artifacts, exec plans, or `.git/` state.

After installing locally:
1. run `/reload-plugins` if Claude Code is already running
2. run `claude -p "/pge-execute test"`
3. confirm the active override payload changed under `~/.claude/dev-plugins/pge/.claude-plugin/plugin.json`

The helper prints the installed plugin `name`, `version`, and `description` after each run.
For a visible install check, temporarily change `.claude-plugin/plugin.json` `version` or `description`, rerun the helper, and confirm both the helper output and the installed manifest changed under `~/.claude/dev-plugins/pge/.claude-plugin/plugin.json`.

This local install flow intentionally does not assume or manipulate undocumented Claude internal cache directories.
The helper copies the plugin root itself, so runtime-facing references must resolve from the installed plugin root rather than from repo-only top-level paths.

## What this round intentionally does not do

- redesign Planner / Generator / Evaluator semantics
- redesign runtime orchestration broadly
- convert the repo into a `.claude` runtime tree
- add a top-level `.claude/contracts/` runtime directory
- introduce broader packaging framework machinery beyond the minimum plugin layer
