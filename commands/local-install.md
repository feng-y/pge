---
description: Run the maintainer-only local PGE install helper in a clean development environment
---

# local-install

Use this command only when you are maintaining PGE itself and need a local validation loop without publishing a new marketplace build yet.
It is not the formal install path, and it must not be used to paper over marketplace/GitHub discoverability issues.

## Required behavior

1. confirm there is no marketplace-installed `pge@pge`
2. confirm there is no legacy local state at `~/.claude/dev-plugins/pge`
3. run `! ./bin/pge-local-install.sh`
4. confirm the helper reports installation into `~/.claude/skills/pge`
5. confirm the top-level skill entry exists at `~/.claude/skills/pge-execute/SKILL.md`
6. smoke-test with `! claude -p "/pge-execute test"`

## Conflict policy

If `pge@pge` is installed through the marketplace, or if `~/.claude/dev-plugins/pge` still exists, stop and fix that state first.
Do not trust the skill list until the conflicting install surface is removed.

For normal installs and updates, use the marketplace path instead:

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

## Verification note

The helper prints the installed plugin `name`, manifest `version`, and a content-derived `local build` after each run so you can see immediately whether the installed local payload changed.
It also rewrites the installed `pge-execute` skill description to start with `[local dev vX.Y.Z-BUILD]`, so the Claude skill list shows that the discovered skill came from the local install and whether it changed.

For a stronger visible install check, you may temporarily change `.claude-plugin/plugin.json` `version` or `description`, rerun `./bin/pge-local-install.sh`, and confirm both the helper output and the installed manifest under `~/.claude/skills/pge/.claude-plugin/plugin.json` changed too.

## Prohibitions

Do not:

- treat this as the formal distribution path
- use this helper to fix marketplace/GitHub discoverability
- replace the marketplace/plugin install flow in docs
- copy docs, proving artifacts, or other repo-only files into `~/.claude/skills/pge`
- assume undocumented Claude internal caches should be deleted
