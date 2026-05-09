# PGE

## What PGE Is

PGE is a repo-coupled agentic engineering harness for evolving this repo toward AI-native development.

The repo is currently in a **skill-split migration**:

- `pge-setup` prepares repo-local PGE config under `.pge/config/*`
- `pge-plan` writes bounded plan artifacts under `.pge/plans/<plan_id>.md`
- `pge-exec` executes numbered plan issues and writes run artifacts under `.pge/runs/<run_id>/*`

The older `skills/pge-execute/` and `agents/pge-*.md` surfaces are still present in the repo as migration/reference material while the new split settles and marketplace / local-install alignment is finished.

## Current Mainline

The current mainline is the contract-first split toward:

```text
pge-setup -> pge-plan -> pge-exec
```

The target execution model for the new path is triage + state-machine execution, with TDD allowed only as one execution mode when appropriate.

Keep README as an entry map; use the live planning docs for current blockers and next action:

- [`docs/exec-plans/CURRENT_MAINLINE.md`](./docs/exec-plans/CURRENT_MAINLINE.md)
- [`docs/exec-plans/ISSUES_LEDGER.md`](./docs/exec-plans/ISSUES_LEDGER.md)
- [`docs/exec-plans/pge-skills-setup-plan-execute.md`](./docs/exec-plans/pge-skills-setup-plan-execute.md)
- [`docs/exec-plans/pge-skills-contract-first.md`](./docs/exec-plans/pge-skills-contract-first.md)

## Current Skill Surfaces

Primary split surfaces now present in the repo:

- [`skills/pge-setup/SKILL.md`](./skills/pge-setup/SKILL.md)
- [`skills/pge-plan/SKILL.md`](./skills/pge-plan/SKILL.md)
- [`skills/pge-exec/SKILL.md`](./skills/pge-exec/SKILL.md)

Migration/reference surfaces still present:

- [`skills/pge-execute/SKILL.md`](./skills/pge-execute/SKILL.md)
- [`skills/pge-execute/ORCHESTRATION.md`](./skills/pge-execute/ORCHESTRATION.md)
- [`agents/pge-planner.md`](./agents/pge-planner.md)
- [`agents/pge-generator.md`](./agents/pge-generator.md)
- [`agents/pge-evaluator.md`](./agents/pge-evaluator.md)

Interpretation rule:

- Use the new split skills for setup / planning / execution direction.
- Treat `skills/pge-execute/` and `agents/pge-*.md` as legacy runtime material until the migration is fully closed.
- Do not assume marketplace and local install have been fully aligned to hide or retire those legacy surfaces yet.

## Workflow Model

### pge-setup

`pge-setup` is the repo-convention and config scaffolding surface.

It owns:

- repo convention discovery
- `.pge/config/*` scaffolding
- route/state/docs/artifact/verification policy capture
- setup status reporting

It does not own planning or execution.

### pge-plan

`pge-plan` is the bounded planning surface.

It owns:

- intent shaping
- bounded slice definition
- assumptions / risks / blockers capture
- acceptance criteria
- verification hints
- execution handoff into `.pge/plans/<plan_id>.md`

It does not execute code.

### pge-exec

`pge-exec` is the main-led execution surface.

It owns:

- plan consumption
- issue ordering
- bounded worker dispatch when justified
- local repair
- lightweight gates
- next-route output under `.pge/runs/<run_id>/`

It is not a TDD skill, not an SDK runner, and not a Claude Code Agent Teams orchestrator.
TDD is only one possible execution mode.

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

## Runtime / Contract Truth

During the migration, treat truth in layers:

1. Active user instruction for the current task
2. [`CLAUDE.md`](./CLAUDE.md)
3. New split skill surfaces:
   - [`skills/pge-setup/SKILL.md`](./skills/pge-setup/SKILL.md)
   - [`skills/pge-plan/SKILL.md`](./skills/pge-plan/SKILL.md)
   - [`skills/pge-exec/SKILL.md`](./skills/pge-exec/SKILL.md)
4. Current execution-plan docs:
   - [`docs/exec-plans/CURRENT_MAINLINE.md`](./docs/exec-plans/CURRENT_MAINLINE.md)
   - [`docs/exec-plans/ISSUES_LEDGER.md`](./docs/exec-plans/ISSUES_LEDGER.md)
   - [`docs/exec-plans/pge-skills-setup-plan-execute.md`](./docs/exec-plans/pge-skills-setup-plan-execute.md)
   - [`docs/exec-plans/pge-skills-contract-first.md`](./docs/exec-plans/pge-skills-contract-first.md)
5. Legacy runtime material under [`skills/pge-execute/`](./skills/pge-execute/) and [`agents/pge-*.md`](./agents/)
6. Design/reference material under [`docs/design/`](./docs/design/)

Do not treat top-level or archived design material as active runtime authority, and do not assume legacy `skills/pge-execute/` semantics still define the preferred forward path.

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
- plugin-managed skill directories:
  - `pge-setup`
  - `pge-plan`
  - `pge-exec`
- legacy cleanup targets:
  - skill: `pge-execute`
  - agents: `pge-planner.md`, `pge-generator.md`, `pge-evaluator.md`

Important migration note:

- The repo now contains `pge-setup`, `pge-plan`, and `pge-exec` as the intended installed skill surfaces.
- Marketplace metadata and local install behavior are being aligned to install only those three skills by default.
- Legacy `pge-execute` / `agents/pge-*.md` are now treated as cleanup targets for local install rather than active installed runtime surfaces.

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

The helper is manifest-driven. It reads [`.claude-plugin/plugin.json`](./.claude-plugin/plugin.json), installs only the manifest-selected skill directories, installs any manifest-listed agents, and removes manifest-declared legacy local-dev surfaces when they are present with the local marker.

In the current split, local install should project:

- `pge-setup`
- `pge-plan`
- `pge-exec`

and should clean up locally installed legacy surfaces such as:

- `pge-execute`
- `pge-planner.md`
- `pge-generator.md`
- `pge-evaluator.md`

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
