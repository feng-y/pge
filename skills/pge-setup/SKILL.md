---
name: pge-setup
description: Scaffold the repo-local `.pge/config/*` configuration that PGE planning and execution skills assume, including backlog backend, state/route vocabulary, docs policy, artifact layout, verification policy, and open setup gaps.
version: 0.1.0
argument-hint: "[optional setup notes]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---

# PGE Setup

Scaffold the repo-local configuration that later PGE skills assume.

This is a prompt-driven setup skill, not a deterministic installer. Explore the repo, detect existing conventions, present findings and recommended defaults, ask only critical questions, then write `.pge/config/*`.

`pge-setup` exists so `pge-research`, `pge-plan`, and `pge-exec` do not repeatedly guess this repo's planning, routing, documentation, artifact, and verification conventions.

## Anti-Pattern: "Let Me Set Up Everything Perfectly"

Setup is warmup, not a core phase. Write enough config for downstream skills to work, then stop. Missing optional docs are not blockers. Unconfirmed verification commands are recorded as unconfirmed, not invented. Perfection here delays actual work.

## Anti-Pattern: "Setup Must Run First"

Setup is recommended for complex or repo-wide work, but it is not a ceremony. `pge-research` and `pge-plan` can degrade gracefully without it. Do not block the user from starting work just because setup hasn't run.

## When Setup Is Worth Running

| Situation | Without Setup | With Setup | Verdict |
|-----------|--------------|-----------|---------|
| First task in a new repo | Research guesses conventions | Research knows conventions from config | Run setup |
| Simple single-file fix | Degraded mode works fine | Overhead not justified | Skip |
| Multi-module architectural work | Plan may contradict repo patterns | Plan uses config as constitution | Run setup |
| After 5+ pge-exec runs | Compound learnings already populated config | Setup would duplicate what compound learned | Skip |
| Team onboarding (new developer) | Each person's first run re-discovers conventions | Config captures once, shared by all | Run setup |

**Self-evolution replaces setup over time:** As pge-exec's compound phase accumulates learnings into `.pge/config/repo-profile.md`, the config grows organically. After enough runs, manual setup becomes unnecessary — the pipeline has already learned the repo's conventions through execution.

## Core Influence

This skill adapts the setup pattern from Matt Pocock's setup skill:

- issue tracker setup becomes PGE plan/backlog backend setup
- triage labels become PGE state/route vocabulary setup
- domain docs become PGE docs-policy setup

Use the same operating style:

1. Explore.
2. Present findings and defaults.
3. Ask only critical questions.
4. Write the repo-local config docs.
5. Report the final setup status and suggest the next skill.

## Workflow

### 1. Explore Repo

Read only enough repo context to detect conventions. Prefer cheap discovery first.

Inspect:

- `README.md`
- `CLAUDE.md`
- `AGENTS.md`
- `.claude-plugin/plugin.json`
- `skills/`
- `agents/`
- `docs/design/`
- `docs/exec-plans/`
- `contracts/` if present
- `skills/*/contracts/` if present
- existing `.pge/` if present
- existing `.scratch/`, `docs/agents/`, `CONTEXT.md`, `CONTEXT-MAP.md`, or `docs/adr/` if present
- validation scripts such as `bin/*validate*`, package scripts, Makefiles, or test commands when easy to locate

Useful commands:

```bash
git remote -v
rg --files
find .pge -maxdepth 3 -type f 2>/dev/null
```

Do not treat missing optional docs as blockers. Record them as open gaps only when downstream PGE skills would need to know.

### 2. Detect Existing Conventions

Detect:

- backlog / plan backend
- route and state vocabulary
- docs truth hierarchy
- artifact layout
- verification commands
- existing guardrails and non-goals
- open gaps that affect later planning or execution

Default backend for the first version:

```text
local_markdown: .pge/tasks-<slug>/plan.md
```

Default PGE state vocabulary:

- `NEEDS_TRIAGE`
- `NEEDS_INFO`
- `READY_FOR_EXECUTE`
- `IN_PROGRESS`
- `DONE_NEEDS_REVIEW`
- `RETRY_REQUIRED`
- `BLOCKED`
- `NEEDS_HUMAN`

Default downstream artifact roots:

- setup config: `.pge/config/*`
- research briefs: `.pge/tasks-<slug>/research.md`
- plans: `.pge/tasks-<slug>/plan.md`
- runs: `.pge/tasks-<slug>/runs/<run_id>/*`
- concurrent worker records: `.pge/tasks-<slug>/runs/<run_id>/workers/issue-<NNN>/*`
- legacy fallback (no task directory): `.pge/plans/<plan_id>.md`, `.pge/runs/<run_id>/*`

### 3. Present Findings And Recommended Defaults

Before writing, summarize:

- what backend was detected
- what docs are authoritative
- which state/route vocabulary will be used
- which artifact roots will be created
- which verification commands look available
- which critical gaps, if any, block setup

Then present recommended defaults. Keep this concise and operational.

### 4. Ask Only Critical Questions

Default to not asking questions. Ask only when continuing would write misleading config.

Critical questions include:

- The repo clearly uses a non-local backlog backend, but the backend cannot be inferred.
- The repo has conflicting resident-agent docs and no clear truth hierarchy.
- The user explicitly asks for a non-default backend or route vocabulary but does not give enough detail.

Do not ask about low-risk defaults:

- Use local markdown `.pge/tasks-<slug>/plan.md` when no clear external backlog backend exists.
- Use the default state vocabulary unless the repo already has a conflicting canonical one.
- Use the existing README / CLAUDE.md / AGENTS.md / docs layout as the docs policy.

### 5. Write `.pge/config/*`

Create `.pge/config/` if needed.

Write exactly these config files:

- `.pge/config/repo-profile.md`
- `.pge/config/backlog-policy.md`
- `.pge/config/docs-policy.md`
- `.pge/config/artifact-layout.md`
- `.pge/config/verification.md`
- `.pge/config/route-policy.md`
- `.pge/config/open-gaps.md`

Prefer updating existing files in place when rerun. Do not duplicate sections.

### 6. Report Setup Status

Use exactly one setup status:

- `SETUP_READY`
- `SETUP_PARTIAL`
- `SETUP_BLOCKED`

Status meanings:

- `SETUP_READY`: all required config files were written and no critical gap blocks downstream planning.
- `SETUP_PARTIAL`: config files were written, but one or more non-critical gaps remain.
- `SETUP_BLOCKED`: config files could not be written fairly because a critical question or filesystem blocker remains unresolved.

### 7. Suggest Next Skill

When setup is ready or partial, suggest:

```text
next_skill: pge-research (when intent is fuzzy or multiple approaches exist)
next_skill: pge-plan (when intent is already clear)
```

Do not invoke `pge-research` or `pge-plan`.

## Artifact Contracts

### `.pge/config/repo-profile.md`

Purpose: compact profile of the repo and PGE-relevant conventions.

Required sections:

- `# Repo Profile`
- `## Repo Root`
- `## Project Identity`
- `## Detected PGE Surfaces`
- `## Existing Config`
- `## Setup Status`

Record only observed facts and explicit inferences. Mark inference as inference.

### `.pge/config/backlog-policy.md`

Purpose: define where PGE plans/backlog items live and how downstream skills should read/write them.

Required sections:

- `# Backlog Policy`
- `## Backend`
- `## Plan Location`
- `## Plan ID Convention`
- `## Read Rules`
- `## Write Rules`
- `## Non-Goals`

First-version default:

```text
backend: local_markdown
plan_location: .pge/tasks-<slug>/plan.md
plan_file_pattern: .pge/tasks-<slug>/plan.md
legacy_fallback: .pge/plans/<plan_id>.md
```

### `.pge/config/docs-policy.md`

Purpose: define the repo's docs truth hierarchy and reading rules.

Required sections:

- `# Docs Policy`
- `## Truth Hierarchy`
- `## First Reads`
- `## Design Docs`
- `## Exec Plans`
- `## Contracts And Skills`
- `## Archived Or Reference Material`
- `## Reading Rules`

Default PGE truth hierarchy:

1. explicit user instruction for the current task
2. `CLAUDE.md` when present
3. `AGENTS.md`
4. `README.md`
5. active `.pge/config/*`
6. active skill and contract files under `skills/`
7. `docs/exec-plans/`
8. `docs/design/`
9. archived/reference docs

Adapt this hierarchy to observed repo facts when needed, but do not silently contradict resident instructions.

### `.pge/config/artifact-layout.md`

Purpose: define artifact roots used by setup, planning, and execution.

Required sections:

- `# Artifact Layout`
- `## Setup Artifacts`
- `## Plan Artifacts`
- `## Run Artifacts`
- `## Naming Rules`
- `## Cleanup Policy`

Required layout:

```text
.pge/config/*
.pge/tasks-<slug>/research.md
.pge/tasks-<slug>/plan.md
.pge/tasks-<slug>/runs/<run_id>/*
.pge/plans/<plan_id>.md              (legacy — when no task directory exists)
```

### `.pge/config/verification.md`

Purpose: define verification commands and how downstream skills should interpret them.

Required sections:

- `# Verification`
- `## Available Checks`
- `## Recommended Setup Check`
- `## Recommended Plan Check`
- `## Recommended Execute Check`
- `## Unknown Or Missing Checks`
- `## Verification Rules`

Record observed commands such as:

- `./bin/pge-validate-contracts.sh`
- `git diff --check`
- project-specific test commands if discovered

Do not invent commands. If a command is inferred but not confirmed, mark it as unconfirmed.

For `pge-exec`, this file should tell the controller which verification entries are available for focused issue checks and which command, if any, is appropriate for integration verification after multiple issue workers complete.

### `.pge/config/route-policy.md`

Purpose: define the state/route vocabulary that `pge-plan` and `pge-exec` should use.

Required sections:

- `# Route Policy`
- `## State Vocabulary`
- `## Route Vocabulary`
- `## State Meanings`
- `## Route Rules`
- `## Forbidden Runtime Claims`

Required state vocabulary:

- `NEEDS_TRIAGE`
- `NEEDS_INFO`
- `READY_FOR_EXECUTE`
- `IN_PROGRESS`
- `DONE_NEEDS_REVIEW`
- `RETRY_REQUIRED`
- `BLOCKED`
- `NEEDS_HUMAN`

Recommended route vocabulary:

- `READY_FOR_PLAN`
- `READY_FOR_EXECUTE`
- `DONE_NEEDS_REVIEW`
- `RETRY_RECOMMENDED`
- `NEEDS_INFO`
- `BLOCKED`
- `NEEDS_HUMAN`
- `NEEDS_MAIN_DECISION`

`DONE_NEEDS_REVIEW` means candidate completion with evidence and self-review, waiting for human review, a future evaluator, or a future SDK runner. It is not final PASS authority.

Forbidden output claims for `pge-exec`:

- `PASS`
- `MERGED`
- `SHIPPED`

### `.pge/config/open-gaps.md`

Purpose: record unresolved setup gaps without blocking low-risk defaults.

Required sections:

- `# Open Gaps`
- `## Critical`
- `## Non-Critical`
- `## Deferred`
- `## Suggested Follow-Up`

Use `None` when a section has no items.

## Handoff Rules

### Handoff To `pge-plan`

`pge-plan` should read:

- `.pge/config/repo-profile.md`
- `.pge/config/backlog-policy.md`
- `.pge/config/docs-policy.md`
- `.pge/config/artifact-layout.md`
- `.pge/config/route-policy.md`
- `.pge/config/open-gaps.md`

Hard dependency rule for `pge-plan`:

- `pge-plan` may degrade when `.pge/config/*` is missing.
- For complex tasks, `pge-plan` should recommend running `pge-setup` first.

### Handoff To `pge-exec`

`pge-exec` should read all `.pge/config/*` files before executing.

Hard dependency rule for `pge-exec`:

- `.pge/config/*` is a hard dependency for `pge-exec`.
- If required config is missing, `pge-exec` should stop before execution and route to `NEEDS_TRIAGE` or `NEEDS_INFO` according to the route policy.

## Guardrails

Do not:

- write business code
- generate or execute a PGE plan
- require setup as ceremony before every task
- output `PASS`, `MERGED`, or `SHIPPED`
- modify skill files for `pge-research`, `pge-plan`, or `pge-exec`

## Final Response

After writing config files, return:

```md
## PGE Setup Result
- status: <SETUP_READY | SETUP_PARTIAL | SETUP_BLOCKED>
- config_dir: <absolute path to .pge/config>
- files:
  - <absolute path to repo-profile.md>
  - <absolute path to backlog-policy.md>
  - <absolute path to docs-policy.md>
  - <absolute path to artifact-layout.md>
  - <absolute path to verification.md>
  - <absolute path to route-policy.md>
  - <absolute path to open-gaps.md>
- backend: <local_markdown | other>
- plan_location: .pge/tasks-<slug>/plan.md
- route_vocabulary: READY_FOR_PLAN, READY_FOR_EXECUTE, DONE_NEEDS_REVIEW, RETRY_RECOMMENDED, NEEDS_INFO, BLOCKED, NEEDS_HUMAN, NEEDS_MAIN_DECISION
- critical_gaps: <None or short list>
- next_skill: pge-research (fuzzy intent) or pge-plan (clear intent)
```

If setup is blocked, include the one critical question or blocker instead of guessing.
