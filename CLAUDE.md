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
4. `skills/pge-exec/SKILL.md`
5. `skills/pge-review/SKILL.md`
6. `skills/pge-challenge/SKILL.md`
7. `skills/pge-ai-native-refactor/SKILL.md`
8. `skills/pge-handoff/SKILL.md`
9. `skills/pge-knowledge/SKILL.md`

## Truth hierarchy

Active skill surfaces (authoritative):
- `skills/pge-research/SKILL.md`
- `skills/pge-plan/SKILL.md`
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
- Research must expose confirmed intent, scope, success shape, evidence, and planning handoff for planning.
- Plan must translate that intent into executable issue contracts without scope drift.
- Exec must prove code changes satisfy the plan contract.
- Review must judge whether the diff still aligns with the original intent through the plan.
- Every stage must consume its explicit invocation input plus relevant current context, including recent user corrections, observed failures, and fresh artifacts. If context changes the goal, scope, or fix target, confirm the interpretation before producing the next contract.
- Research owns confirmed problem: intent discovery, scope, evidence, ambiguity resolution, and when relevant the problem-side experience/design context for human-facing or artifact-facing work. Plan owns executable solution: approach selection, engineering review, and plan-changing clarification. Plan must consume that experience context in acceptance, verification, and evidence without moving solution ownership back into research. Exec consumes a ready contract; if many goal/scope/acceptance questions remain at exec time, route back because research or plan did not finish its job.

Templates are scaffolds. Required field semantics are binding; prose shape and optional sections should scale with task complexity.

## Workflow authority

- PGE follows the common arc: Research → Plan → Execute → Review → Ship.
- `pge-research`, `pge-plan`, `pge-exec`, `pge-review`, `pge-challenge`, `pge-ai-native-refactor`, `pge-handoff`, and `pge-knowledge` are the active workflow surfaces.
- `pge-exec` owns route, state, gates, and execution-window decisions, including bounded reruns from task-artifact review/challenge feedback only after provenance validation against the referenced run, canonical plan identity, and reviewed diff.
- `pge-research` owns confirmed problem: intent, scope, success shape, evidence, ambiguity resolution, and planning handoff.
- `pge-review` owns the review-stage gate. It must return `BLOCK_SHIP`, `NEEDS_FIX`, `READY_FOR_CHALLENGE`, or `READY_TO_SHIP`; findings alone are not enough. When a task directory exists, review feedback is written there in a provenance-bearing exec-facing repair format.
- `pge-challenge` owns the manual prove-it gate inside the Review stage before PR/ship. When a task directory exists, challenge feedback is written there in a provenance-bearing exec-facing repair format. `pge-exec` may hand off directly to it only as the next legal prove-it step inside the Review stage, not as a bypass around review authority.
- `pge-ai-native-refactor` owns pre-PGE shaping for one human-selected AI-friction direction. It must not execute implementation or invoke PGE automatically.
- `pge-handoff` owns temporary session handoff only; it must not extract durable knowledge.
- `pge-knowledge` owns quality evaluation for context friction, memory/code summaries, and run artifact candidates before any durable repo knowledge is promoted.
- Planning outputs, run artifacts, and review/challenge feedback under `.pge/tasks-<slug>/` are the handoff seams.
- Clear and complete plans from outside PGE may be adopted into repo management by `pge-plan` fast-adopt into `.pge/tasks-<slug>/plan.md`. After adoption, `.pge/` artifacts are authoritative; the external plan remains source evidence, not a parallel runtime contract.
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
./bin/pge-progress-report.sh        # Generate progress report
./bin/pge-local-install.sh          # Install plugin to ~/.claude
```

## Key gotchas

- Plugin source and marketplace source are the same repo. Installed layout differs from source layout.
- `agents/pge-code-reviewer.md` and `agents/pge-code-simplifier.md` are active review agents. Other legacy agent/skill files have been removed.
