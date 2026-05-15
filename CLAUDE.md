# CLAUDE.md

## PGE repo identity

PGE is a repo-coupled agentic engineering harness for evolving this repo toward AI-native development.

The system is defined through markdown contracts, agent definitions, and shell scripts. PGE and the repo co-evolve: each useful run either produces a bounded verified repo improvement or exposes a concrete missing AI-operability surface.

Do not treat strategy docs as permission to expand harness theory during normal work.

## First reads

Before non-trivial work, read in this order:

1. `README.md`
2. `skills/pge-research/SKILL.md`
3. `skills/pge-plan/SKILL.md`
4. `skills/pge-plan-normalize/SKILL.md`
5. `skills/pge-exec/SKILL.md`
6. `skills/pge-review/SKILL.md`
7. `skills/pge-challenge/SKILL.md`
8. `skills/pge-ai-native-refactor/SKILL.md`
9. `skills/pge-handoff/SKILL.md`
10. `skills/pge-knowledge/SKILL.md`

## Truth hierarchy

Active skill surfaces (authoritative):
- `skills/pge-research/SKILL.md`
- `skills/pge-plan/SKILL.md`
- `skills/pge-plan-normalize/SKILL.md`
- `skills/pge-exec/SKILL.md`
- `skills/pge-review/SKILL.md`
- `skills/pge-challenge/SKILL.md`
- `skills/pge-ai-native-refactor/SKILL.md`
- `skills/pge-handoff/SKILL.md`
- `skills/pge-knowledge/SKILL.md`

Project map:
- `README.md`

Research/reference (may inform design, must not override active skill truth):
- `docs/research/ref-*.md`

Legacy (archived, do not treat as active runtime):
- `skills/pge-execute/` — removed (superseded by `pge-exec`)
- `skills/pge-setup/` — removed (unnecessary; .pge/ directory created by pipeline skills on demand)
- `agents/pge-planner.md`, `agents/pge-generator.md`, `agents/pge-evaluator.md` — removed (superseded by `pge-exec` handoffs + references)

Review agents (active, spawned by pge-exec Final Review Gate):
- `agents/pge-code-reviewer.md` — 5-axis code review
- `agents/pge-code-simplifier.md` — simplification pressure

## Work discipline

- Understand before changing.
- Do not present guesses as facts.
- Keep changes minimal and relevant.
- Prefer bounded, verifiable slices.
- Work one bounded round at a time.
- Only fix the current P0 blocker for the active round.
- Record P1 as follow-up, P2 as parked. Do not expand them in the active round.
- Prefer the smallest change that unblocks progress.
- Stop after the blocker is removed.
- Do not expand PGE into a generic agent OS.
- Do not add resident agents unless current mainline explicitly requires it.
- Every meaningful change should improve either task delivery or future AI-operability.

## Core invariant

Every stage must preserve semantic alignment with the original user intent. Artifacts exist to expose and verify that alignment, not to satisfy a fixed document shape.

PGE requires contract discipline, not template bureaucracy:
- Research must expose enough intent, ambiguity status, and evidence for planning.
- Plan must translate that intent into executable issue contracts without scope drift.
- Exec must prove code changes satisfy the plan contract.
- Review must judge whether the diff still aligns with the original intent through the plan.
- Every stage must consume its explicit invocation input plus relevant current context, including recent user corrections, observed failures, and fresh artifacts. If context changes the goal, scope, or fix target, confirm the interpretation before producing the next contract.
- Research and plan own intent discovery, repo investigation, option shaping, and plan-changing clarification. Exec consumes a ready contract; if many goal/scope/acceptance questions remain at exec time, route back because research or plan did not finish its job.

Templates are scaffolds. Required field semantics are binding; prose shape and optional sections should scale with task complexity.

## Workflow authority

- PGE follows the common arc: Research → Plan → Execute → Review → Ship.
- `pge-research`, `pge-plan`, `pge-plan-normalize`, `pge-exec`, `pge-review`, `pge-challenge`, `pge-ai-native-refactor`, `pge-handoff`, and `pge-knowledge` are the active workflow surfaces.
- `pge-exec` owns route, state, gates, and execution-window decisions.
- `pge-research` owns evidence gathering and ambiguity resolution.
- `pge-plan-normalize` owns lossless conversion of complete external plans into canonical `.pge/tasks-<slug>/plan.md`; exec must not normalize non-canonical sources.
- `pge-review` owns the review-stage gate. It must return `BLOCK_SHIP`, `NEEDS_FIX`, `READY_FOR_CHALLENGE`, or `READY_TO_SHIP`; findings alone are not enough.
- `pge-challenge` owns the manual prove-it gate inside the Review stage before PR/ship.
- `pge-ai-native-refactor` owns pre-PGE shaping for one human-selected AI-friction direction. It must not execute implementation or invoke PGE automatically.
- `pge-handoff` owns temporary session handoff only; it must not extract durable knowledge.
- `pge-knowledge` owns quality evaluation for context friction, memory/code summaries, and run artifact candidates before any durable repo knowledge is promoted.
- Planning outputs and run artifacts under `.pge/tasks-<slug>/` are the handoff seams.
- Clear and complete plans from outside PGE may be adopted into repo management by `pge-plan-normalize` normalization into `.pge/tasks-<slug>/plan.md`. After adoption, `.pge/` artifacts are authoritative; the external plan remains source evidence, not a parallel runtime contract.
- Subagents/workers are bounded helpers, not workflow authorities.
- Do not silently restore a Planner / Generator / Evaluator Claude Code Agent Teams orchestrator.
- `agents/pge-code-reviewer.md` and `agents/pge-code-simplifier.md` are active review agents spawned by pge-exec Final Review Gate.

## Missing detail policy

Do not treat every unresolved implementation detail as a blocking question.

Classify missing information:

- **requirement gap**: affects goal / scope / acceptance / safety → ask the user
- **design choice**: multiple valid options → generate options, recommend a default, proceed
- **implementation detail**: resolve by repo convention or leave to Generator freedom

Only ask the user for true requirement gaps that block a fair contract.

## Current non-goals

- no generic autonomous agent OS
- no GitHub issue/backlog workflow unless explicitly planned
- no default heavy thinking (parallel reasoning) unless task warrants it
- no default grill-style questioning for every input
- no broad rewrite without run evidence
- no runtime prompt changes without current mainline or failure evidence

## Validation commands

```bash
./bin/pge-validate-contracts.sh     # Validate semantic contract structure
./bin/pge-progress-report.sh        # Generate progress report
./bin/pge-local-install.sh          # Install plugin to ~/.claude
```

## Key gotchas

- Plugin source and marketplace source are the same repo. Installed layout differs from source layout.
- `agents/pge-code-reviewer.md` and `agents/pge-code-simplifier.md` are active review agents. Other legacy agent/skill files have been removed.

## Skill routing

When the user's request matches an available skill, ALWAYS invoke it using the Skill
tool as your FIRST action. Do NOT answer directly, do NOT use other tools first.
The skill has specialized workflows that produce better results than ad-hoc answers.

Key routing rules:
- Product ideas, "is this worth building", brainstorming → invoke office-hours
- Bugs, errors, "why is this broken", 500 errors → invoke investigate
- Ship, deploy, push, create PR → invoke ship
- QA, test the site, find bugs → invoke qa
- Code review, check my diff → invoke review
- Update docs after shipping → invoke document-release
- Weekly retro → invoke retro
- Design system, brand → invoke design-consultation
- Visual audit, design polish → invoke design-review
- Architecture review → invoke plan-eng-review
