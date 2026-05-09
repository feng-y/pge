# CLAUDE.md

## PGE repo identity

PGE is a repo-coupled agentic engineering harness for evolving this repo toward AI-native development.

The system is defined through markdown contracts, agent definitions, and shell scripts. PGE and the repo co-evolve: each useful run either produces a bounded verified repo improvement or exposes a concrete missing AI-operability surface.

Do not treat strategy docs as permission to expand harness theory during normal work.

## First reads

Before non-trivial work, read in this order:

1. `README.md`
2. `docs/exec-plans/CURRENT_MAINLINE.md`
3. `docs/exec-plans/ISSUES_LEDGER.md`
4. `docs/exec-plans/pge-skills-setup-plan-execute.md`
5. `docs/exec-plans/pge-skills-contract-first.md`
6. `skills/pge-setup/SKILL.md`
7. `skills/pge-plan/SKILL.md`
8. `skills/pge-exec/SKILL.md`

When working on migration/legacy `pge-execute` material, also read:

9. `skills/pge-execute/SKILL.md`
10. `skills/pge-execute/ORCHESTRATION.md`
11. `agents/pge-planner.md`
12. `agents/pge-generator.md`
13. `agents/pge-evaluator.md`

## Truth hierarchy

Migration truth (authoritative during the current split, overrides older runtime prose):
- `skills/pge-setup/SKILL.md`
- `skills/pge-plan/SKILL.md`
- `skills/pge-exec/SKILL.md`
- `docs/exec-plans/pge-skills-setup-plan-execute.md`
- `docs/exec-plans/pge-skills-contract-first.md`
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`

Project map:
- `README.md`

Legacy runtime/reference material (read when touching migration seams, must not silently override the split direction):
- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `skills/pge-execute/contracts/*.md`
- `agents/pge-planner.md`
- `agents/pge-generator.md`
- `agents/pge-evaluator.md`

Research/reference (may inform design, must not override active skill truth):
- `docs/design/research/ref-*.md`
- `docs/design/`

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

## Workflow authority

- `pge-setup`, `pge-plan`, and `pge-exec` are the active workflow surfaces.
- `pge-exec` owns route, state, gates, and execution-window decisions.
- Planning outputs and run artifacts are the preferred handoff seams.
- Subagents/workers are bounded helpers, not workflow authorities.
- Do not silently restore a Planner / Generator / Evaluator Claude Code Agent Teams orchestrator.
- Treat source `agents/pge-*.md` as role-spec / prompt material / future SDK-runner material unless a future mainline explicitly reactivates them.

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
- Marketplace metadata and local install behavior are still being aligned with the new `pge-setup` / `pge-plan` / `pge-exec` split.
- Until that alignment lands, installed plugin contents may still expose legacy `agents/pge-*.md` alongside the new skills.
- Treat legacy `skills/pge-execute/` and `agents/pge-*.md` as migration/reference material unless the current mainline explicitly says otherwise.
