# PGE Plugin Distribution

## Purpose

This repo is the **source repo** for the PGE Claude Code plugin.

It is not the marketplace catalog repo, and it is not an installed `.claude/` runtime tree.

The goal of this packaging layer is to make PGE installable and updatable through the Claude Code plugin marketplace model while preserving the existing source-oriented layout.

## Source layout vs installed layout

### Source layout in this repo

Canonical source artifacts remain here:

- `skills/pge-execute/SKILL.md`
- `agents/planner.md`
- `agents/generator.md`
- `agents/evaluator.md`
- `contracts/*.md`
- `.claude-plugin/plugin.json`

The repo-local `.claude/` directory is only a development-time projection surface used for local iteration. It is not the packaged runtime contract.

### Installed plugin layout

When Claude Code installs the plugin, the bundle should preserve the same component-oriented shape:

```text
.claude-plugin/plugin.json
skills/pge-execute/SKILL.md
agents/planner.md
agents/generator.md
agents/evaluator.md
contracts/*.md
```

This keeps the source layout and installed layout aligned semantically without forcing the source repo to become an installed runtime tree.

## Contracts placement

Contracts are installed as **plugin-owned supporting files** under `contracts/` inside the plugin bundle.

Why this layout was chosen:
- `pge-execute` already references contracts by relative path from `skills/pge-execute/SKILL.md`
- packaging contracts at plugin root keeps those references stable
- contracts remain bundled with the plugin
- this avoids a top-level `.claude/contracts/` runtime directory
- this avoids duplicating the contract files under the skill directory

## Plugin manifest

The plugin manifest for this repo lives at:

- `.claude-plugin/plugin.json`

The manifest is authoritative for:
- plugin identity (`name`)
- explicit plugin version (`version`)
- installable runtime-facing skill/agent exposure

## Marketplace catalog separation

Official Claude Code marketplace catalogs live in a **separate marketplace repo** and define entries in `.claude-plugin/marketplace.json`.

This source repo should not pretend to be the marketplace host.

Instead, a marketplace repo should carry an entry for this plugin that points to this source repo.

Illustrative marketplace entry shape:

```json
{
  "name": "pge",
  "source": {
    "type": "github",
    "repo": "OWNER/REPO"
  }
}
```

The exact marketplace catalog belongs outside this repo.

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

## What this round intentionally does not do

- redesign Planner / Generator / Evaluator semantics
- redesign runtime orchestration broadly
- convert the repo into a `.claude` runtime tree
- add a top-level `.claude/contracts/` runtime directory
- introduce broader packaging framework machinery beyond the minimum plugin layer
