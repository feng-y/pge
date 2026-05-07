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
4. `skills/pge-execute/SKILL.md`
5. `skills/pge-execute/ORCHESTRATION.md`

When working on specific P/G/E behavior, also read:

6. `agents/pge-planner.md`
7. `agents/pge-generator.md`
8. `agents/pge-evaluator.md`

## Truth hierarchy

Runtime truth (authoritative during execution, overrides all other docs):
- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `skills/pge-execute/contracts/*.md`
- `agents/pge-planner.md`
- `agents/pge-generator.md`
- `agents/pge-evaluator.md`
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`

Project map:
- `README.md`

Research/reference (may inform design, must not override runtime truth):
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

- P/G/E are workflow nodes, not roleplay prompts.
- `main` owns route, state, gate, and teardown decisions.
- Only canonical P/G/E outputs (artifacts + events) drive phase completion.
- Subagents are phase-local helpers, not workflow authorities.
- Main orchestration owns route, stop, and recovery — agents produce artifacts but don't self-route.
- Planner is resident (stays alive for entire run), not one-shot.

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
- Runtime state persists to `.pge-artifacts/{run_id}-runtime-state.json`. Legacy `.pge-runtime-state.json` is deprecated.
- Planner is resident (stays alive for entire run), not one-shot.
- Main orchestration owns route, stop, and recovery decisions — agents produce artifacts but don't self-route.
