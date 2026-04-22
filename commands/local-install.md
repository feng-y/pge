---
description: Install the local PGE skill into ~/.claude/skills for development-time validation
---

# local-install

Use this command when you need to validate PGE locally without pushing to `main` and reinstalling through the marketplace flow.

## Required behavior

1. run `! ./bin/pge-local-install.sh`
2. confirm the helper reports installation into `~/.claude/skills/pge`
3. confirm the top-level skill entry exists at `~/.claude/skills/pge-execute/SKILL.md`
4. if the helper warns that `pge@pge` is still installed in the Claude plugin registry, uninstall that marketplace plugin before trusting the skill list
5. smoke-test with `! claude -p "/pge-execute test"`
6. if Claude Code is already running and `/pge-execute` is still not discovered, restart the current session

## Verification note

The helper prints the installed plugin `name`, `version`, and `description` after each run so you can see immediately which local install is active.
It also rewrites the installed `pge` and `pge-execute` skill descriptions to start with `[local dev vX.Y.Z]`, so the Claude skill list shows that the discovered skill came from the local install.

For a stronger visible install check, you may temporarily change `.claude-plugin/plugin.json` `version` or `description`, rerun `./bin/pge-local-install.sh`, and confirm both the helper output and the installed manifest under `~/.claude/skills/pge/.claude-plugin/plugin.json` changed too.

For a visible runtime check, prefer a harmless change in `skills/pge-execute/SKILL.md`, rerun the helper, and then rerun `/pge-execute test`.

## Prohibitions

Do not:

- treat this as the formal distribution path
- replace the marketplace/plugin install flow in docs
- copy docs, proving artifacts, or other repo-only files into `~/.claude/skills/pge`
- assume undocumented Claude internal caches should be deleted
