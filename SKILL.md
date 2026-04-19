---
name: pge
description: Repo-level overview and skill index for the PGE skeleton-first layout.
---

# PGE Skill Index

## Repo purpose
PGE is a skeleton-first repo for bounded execution flow split across:
- `agents/` for responsibility boundaries
- `contracts/` for handoff boundaries
- `skills/` for invocation surfaces

## Current skills
- [`pge-execute`](./skills/pge-execute/SKILL.md)

## How to find a skill
- Start from `skills/`
- Open the specific skill directory
- Read that skill's `SKILL.md`
- Follow links from the skill into `agents/` and `contracts/`

## Structure
- `agents/` — responsibility layer
- `contracts/` — handoff layer
- `skills/` — invocation layer

## Expansion
The repo currently has one real skill: `skills/pge-execute/SKILL.md`.
The structure is intended to support future multi-skill expansion without another root-level refactor.