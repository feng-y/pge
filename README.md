# PGE

## What PGE Is

PGE is a repo-coupled agentic engineering harness for evolving this repo toward AI-native development.

It runs bounded repo-local engineering work through a real Claude Code Agent Team:

- `main` is the orchestration shell, route owner, progress writer, and gate owner.
- `pge-planner` compiles upstream input into one current-round contract.
- `pge-generator` executes real repo work, verifies locally, and packages evidence.
- `pge-evaluator` independently validates the deliverable and returns the verdict / route signal.

PGE is not just a set of role prompts. It is a workflow runtime surface for bounded execution.

## Current Mainline

The current mainline is to converge the `0.5A / 0.5B` runtime lane so `pge-execute` uses a real persistent Planner / Generator / Evaluator team with messaging-first coordination, durable phase artifacts, and lighter closure for deterministic tasks.

The active stage is Planner / Generator / Evaluator responsibility stabilization inside the Agent Teams runtime lane. Keep README as an entry map; use the live planning docs for current blockers and next action:

- [`docs/exec-plans/CURRENT_MAINLINE.md`](./docs/exec-plans/CURRENT_MAINLINE.md)
- [`docs/exec-plans/ISSUES_LEDGER.md`](./docs/exec-plans/ISSUES_LEDGER.md)

## Current Executable Claim

The runnable surface is [`skills/pge-execute/SKILL.md`](./skills/pge-execute/SKILL.md).

Current implementation supports:

- one Claude Code Agent Team per run
- exactly three teammates: `planner`, `generator`, `evaluator`
- one bounded run using the normal flow `planner -> generator -> evaluator`
- a bounded same-contract evaluator-to-generator repair loop for retryable failures
- `SendMessage` coordination with canonical runtime events
- durable phase outputs
- one shared append-only progress log
- independent Evaluator verdicts

Current implementation does not claim:

- automatic multi-round redispatch
- full autonomous retry loops beyond the bounded same-contract repair loop
- return-to-planner loop execution
- checkpoint / resume execution
- generic long-running agent OS behavior
- unlimited autonomous self-evolution

`retry` is a bounded same-contract repair loop, not a full autonomous multi-round retry system.

## Workflow Model

### main

`main` is skill-internal orchestration, not a fourth agent.

`main` owns:

- input resolution
- run initialization
- Team creation and deletion
- Planner / Generator / Evaluator dispatch
- canonical event and artifact gates
- deterministic route reduction
- progress and friction logging
- teardown

`main` does not:

- simulate Planner / Generator / Evaluator
- implement deliverables
- replace specialist judgment
- treat itself as a peer runtime agent

### Planner

Planner is the resident researcher + architect teammate and current-round contract owner.

Planner owns:

- evidence basis
- scope boundary
- current-round deliverable definition
- acceptance criteria
- verification path
- required evidence
- stop condition
- planner escalation when the contract cannot be frozen fairly

Planner may use bounded read-only researcher subagents when repo understanding crosses the current scale threshold. Planner does not implement and does not own final acceptance.

### Generator

Generator is the resident implementation workflow actor.

Generator owns:

- real repo work
- implementation shaping and integration
- local verification
- evidence packaging
- durable Generator artifact when required
- bounded coder workers and read-only reviewer helpers when justified
- bounded repair work when Evaluator sends retryable required fixes

Generator does not self-approve and does not redefine Planner's contract.

### Evaluator

Evaluator is the resident independent validation teammate.

Evaluator owns:

- direct deliverable inspection
- evidence sufficiency checks
- independent verification
- verdict: `PASS`, `RETRY`, `BLOCK`, or `ESCALATE`
- route signal: `continue`, `converged`, `retry`, or `return_to_planner`

Evaluator does not implement fixes and does not use Generator self-review as final approval.

## Repo Co-evolution Goal

PGE is intended to co-evolve with this repo.

Each useful run should either:

- produce a bounded verified repo improvement, or
- expose a concrete missing AI-operability surface.

AI-operability surfaces include:

- architecture and docs entrypoints
- runtime contracts
- validation commands
- evidence conventions
- failure ledger
- current mainline and issue ledger

This is the current direction, not a claim that all long-running or self-evolution mechanics are fully implemented.

## Runtime Source of Truth

Runtime behavior, route vocabulary, event vocabulary, verdict semantics, and stop conditions must come from these files:

- [`skills/pge-execute/SKILL.md`](./skills/pge-execute/SKILL.md)
- [`skills/pge-execute/ORCHESTRATION.md`](./skills/pge-execute/ORCHESTRATION.md)
- [`skills/pge-execute/contracts/*.md`](./skills/pge-execute/contracts/)
- [`agents/pge-planner.md`](./agents/pge-planner.md)
- [`agents/pge-generator.md`](./agents/pge-generator.md)
- [`agents/pge-evaluator.md`](./agents/pge-evaluator.md)
- [`docs/exec-plans/CURRENT_MAINLINE.md`](./docs/exec-plans/CURRENT_MAINLINE.md)
- [`docs/exec-plans/ISSUES_LEDGER.md`](./docs/exec-plans/ISSUES_LEDGER.md)

Do not treat top-level or archived design material as runtime authority during execution.

## Reference / Design Docs

Reference and design docs can inform future changes, but they must not override the runtime source of truth during execution.

Useful reference areas:

- [`docs/design/`](./docs/design/) — design notes, archived concepts, and future-facing architecture sketches
- [`docs/design/research/`](./docs/design/research/) — research/reference notes
- [`docs/proving/README.md`](./docs/proving/README.md) — proving/development run discipline

Reference docs are inputs for future design rounds, not live route or event contracts.

## Install / Local Development

### Marketplace / Plugin Path

This repo carries Claude Code plugin metadata:

- [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json)
- [`.claude-plugin/marketplace.json`](./.claude-plugin/marketplace.json)

Current manifest facts:

- plugin name: `pge`
- plugin version: `0.1.5`
- marketplace name: `pge`
- marketplace source: `./`
- plugin skills root: `./skills/`
- plugin agents:
  - `./agents/pge-planner.md`
  - `./agents/pge-generator.md`
  - `./agents/pge-evaluator.md`

When using the published marketplace path, register the marketplace and install the plugin:

```text
/plugin marketplace add feng-y/pge
/plugin install pge@pge
```

For project-scoped marketplace registration through the CLI:

```bash
claude plugin marketplace add --scope project feng-y/pge
```

Refresh and update installed plugin contents with:

```text
/plugin marketplace update pge
/plugin update pge
/reload-plugins
```

The marketplace install path is still tracked as a validation follow-up in [`docs/exec-plans/ISSUES_LEDGER.md`](./docs/exec-plans/ISSUES_LEDGER.md).

### Local Development Install

For repo-local validation, use the local install helper:

```bash
./bin/pge-local-install.sh
```

The helper is manifest-driven. It reads [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json), copies skill directories under `skills/` that contain `SKILL.md`, and copies the manifest-listed agents.

Default targets:

```text
~/.claude/skills/
~/.claude/agents/
```

Install to a different base directory:

```bash
./bin/pge-local-install.sh --root /path/to/base
```

This installs to:

```text
/path/to/base/.claude/skills/
/path/to/base/.claude/agents/
```

Uninstall locally installed components:

```bash
./bin/pge-local-install.sh --uninstall
./bin/pge-local-install.sh --root /path/to/base --uninstall
```

The installer writes a local dev marker into installed skill and agent frontmatter descriptions. Uninstall removes only components carrying that marker.

After local install in an already-running Claude Code session, run:

```text
/reload-plugins
```

## Proving / Development Runs

Start with [`docs/proving/README.md`](./docs/proving/README.md).

A proving/development run is a bounded loop that moves the current mainline forward with the smallest viable step. It should produce a concrete repo artifact or make a blocker explicit enough to drive the next repair round.

For proving, use:

- [`docs/exec-plans/CURRENT_MAINLINE.md`](./docs/exec-plans/CURRENT_MAINLINE.md)
- [`docs/exec-plans/ISSUES_LEDGER.md`](./docs/exec-plans/ISSUES_LEDGER.md)
- [`docs/proving/README.md`](./docs/proving/README.md)

Do not turn a proving run into broad design expansion.

## Development Discipline

- Update README when project identity or runtime entrypoints change.
- Keep README as an entry map, not a full design document.
- Keep runtime semantics in skill, agent, and contract files.
- Keep research references separate from runtime authority.
- Work one bounded improvement at a time.
- Record live blockers in `CURRENT_MAINLINE.md` and `ISSUES_LEDGER.md`.
- Do not expand PGE into a generic agent OS.

## Non-goals

PGE is not:

- a generic chatbot
- a generic project manager
- a GitHub issue tracker replacement
- a production deployment autopilot
- a long-term memory system
- an unlimited autonomous self-evolution system
- a collection of roleplay prompts
