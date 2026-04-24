---
description: Install the local PGE plugin as a dev-plugin override over the marketplace install surface
---

# local-install

Use this command when you are maintaining PGE itself and need local source changes to override the installed marketplace plugin without publishing a new marketplace build yet.

## Required behavior

1. run `! ./bin/pge-local-install.sh`
2. confirm the helper reports installation into `~/.claude/dev-plugins/pge`
3. confirm legacy helper-created paths do not exist after install:
   - `~/.claude/skills/pge`
   - `~/.claude/skills/pge-execute`
   - `~/.claude/agents/pge-planner.md`
   - `~/.claude/agents/pge-generator.md`
   - `~/.claude/agents/pge-evaluator.md`
4. reload plugin discovery with `/reload-plugins`
5. smoke-test with `! claude -p "/pge-execute test"`

## Behavior model

This helper creates one local override surface only:

```text
~/.claude/dev-plugins/pge
```

It must not create a parallel top-level discovered skill entry or copy discoverable agents into `~/.claude/agents`.
If older helper-created paths exist, the helper removes them during install and clean.

For normal published updates, use the marketplace path instead:

```text
/plugin marketplace update pge
/plugin update pge
/reload-plugins
```

## Verification note

The helper prints the installed plugin `name`, manifest `version`, and a content-derived `local build` after each run so you can see immediately whether the dev-plugin override payload changed.
It also rewrites the installed `pge-execute` skill description to start with `[local dev vX.Y.Z-BUILD]`, so the skill surface shows that the active PGE plugin came from the local override and whether it changed.

For a stronger visible install check, you may temporarily change `.claude-plugin/plugin.json` `version` or `description`, rerun `./bin/pge-local-install.sh`, and confirm both the helper output and the installed manifest under `~/.claude/dev-plugins/pge/.claude-plugin/plugin.json` changed too.

## Prohibitions

Do not:

- treat this as the formal distribution path
- create parallel helper install surfaces under `~/.claude/skills/pge-execute` or `~/.claude/agents`
- replace the marketplace/plugin install flow in docs
- copy docs, proving artifacts, or other repo-only files into the dev-plugin override
- assume undocumented Claude internal caches should be deleted
