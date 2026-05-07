---
description: Install the local PGE skill and agents into Claude's standard local directories
---

# local-install

Use this command when you are maintaining PGE itself and need local source changes installed into Claude's standard local directories without publishing a new marketplace build yet.

## Required behavior

1. run `! ./bin/pge-local-install.sh`
2. confirm the helper reports installation targets under `~/.claude/skills` and `~/.claude/agents`
3. reload plugin discovery with `/reload-plugins`
4. optionally run `! claude -p "/pge-execute test"` only as a plugin-load / packaging check when that CLI is authenticated
5. run the real smoke test in a Claude Code runtime surface that can execute the Agent Team control-plane calls

Do not treat `claude -p "/pge-execute test"` as proof of the Agent Team runtime path by itself. Keep the concrete substrate blocker from the attempted runtime call. Do not add a separate capability check before execution.

If you need to install into another outer directory, run:

```text
! ./bin/pge-local-install.sh --root /path/to/base
```

This installs to:
- `/path/to/base/.claude/skills`
- `/path/to/base/.claude/agents`

## Behavior model

This helper installs into Claude's standard local surfaces:

```text
~/.claude/skills
~/.claude/agents
```

If older helper-created paths exist there, the helper replaces them during install and removes marker-owned paths during clean.

For normal published updates, use the marketplace path instead:

```text
/plugin marketplace update pge
/plugin update pge
/reload-plugins
```

## Verification note

The helper prints the installed plugin `name`, manifest `version`, and a content-derived `local build` after each run so you can see immediately whether the installed payload changed.
It also rewrites installed descriptions to start with `[local dev vX.Y.Z-BUILD]`, so the active local install surface shows which build is active.

For a stronger visible install check, you may temporarily change `.claude-plugin/plugin.json` `version` or `description`, rerun `./bin/pge-local-install.sh`, and confirm both the helper output and the installed files under `~/.claude/skills/pge-execute` and `~/.claude/agents` changed too.

## Prohibitions

Do not:

- treat this as the formal distribution path
- replace the marketplace/plugin install flow in docs
- copy docs, proving artifacts, or other repo-only files into the installed local surfaces
- assume undocumented Claude internal caches should be deleted
