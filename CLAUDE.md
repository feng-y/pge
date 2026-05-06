# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repo is

A docs/contracts skeleton for PGE (Planner/Generator/Evaluator) — a bounded execution workflow plugin for Claude Code. No runtime code; the system is defined through markdown contracts, agent definitions, and shell scripts.

Do not treat strategy docs as permission to expand harness theory during normal work.

## Normative seams

For proving runs, these files are authoritative and override all other docs:
- `agents/*.md`
- `skills/pge-execute/contracts/*.md`
- `skills/pge-execute/SKILL.md`

Supporting docs provide context but must not override normalized route/state/verdict vocabulary.

## Execution discipline

- Work one bounded round at a time.
- Only fix the current P0 blocker for the active round.
- Record P1 as follow-up, P2 as parked. Do not expand them in the active round.
- Prefer the smallest change that unblocks progress.
- Stop after the blocker is removed.
- Keep scope explicit. Do not reopen broad design unless the current blocker requires it.
- Use gradual disclosure — surface only the detail needed for the current blocker.

## Control-plane artifacts

Update these each round:
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`

Use `docs/exec-plans/ROUND_TEMPLATE.md` when creating a new round record.
Use `docs/proving/README.md` as the proving/development run entrypoint.

## Response shape (proving runs)

Structure round updates as:
- `本轮目标`
- `Progress`
- `Blockers`
- `Action`

## Validation commands

```bash
./bin/pge-validate-contracts.sh     # Validate contract structure
./bin/pge-progress-report.sh        # Generate progress report
./bin/pge-local-install.sh          # Install plugin to ~/.claude
```

## Key gotchas

- Plugin source and marketplace source are the same repo. Installed layout differs from source layout.
- Runtime state persists to `.pge-artifacts/{run_id}-runtime-state.json`. Legacy `.pge-runtime-state.json` is deprecated.
- Planner is resident (stays alive for entire run), not one-shot.
- Main orchestration owns route, stop, and recovery decisions — agents produce artifacts but don't self-route.
