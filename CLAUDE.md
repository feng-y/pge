# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Current repo state

- This repo is currently a docs/contracts skeleton for PGE, not a runtime implementation.
- Do not treat strategy docs as permission to keep expanding harness theory during normal repo work.

## Normative seams for proving runs

For proving runs, the authoritative execution-core seams are:
- `agents/*.md`
- `contracts/*.md`
- `skills/pge-execute/SKILL.md`

Supporting/reference docs may provide context, but they must not override normalized route/state/verdict vocabulary during proving.

## Current working mode

- Prioritize the current mainline over broad optimization or theoretical completeness.
- Only fix the current P0 blocker for the active round.
- Record P1 as follow-up and P2 as parked. Do not expand them in the active round.
- Prefer the smallest change that unblocks progress.
- Stop after the blocker is removed.

## Round discipline

- Work one bounded round at a time.
- Keep scope explicit. Do not reopen broad design unless the current blocker truly requires it.
- Use gradual disclosure in responses. Surface only the detail needed for the current blocker.

## Control-plane artifacts

For the current stage, update these artifacts each round:
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`
- use `docs/exec-plans/ROUND_TEMPLATE.md` when creating a new round record
- use `docs/proving/README.md` as the proving/development run entrypoint

## Response shape for the current stage

Structure round updates as:
- `本轮目标`
- `Progress`
- `Blockers`
- `Action`
