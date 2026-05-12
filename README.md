# PGE

A Claude Code plugin that turns multi-step engineering work into bounded, verified execution.

## Why PGE Exists

AI coding agents are great at single-shot tasks. Ask them to fix a typo or add a function — done. But real engineering work is multi-step: research the problem, plan the approach, execute issue by issue, verify each piece. This is where agents fall apart.

**The failure modes:**

1. **Drift** — the agent starts executing, loses track of the plan, and builds something you didn't ask for
2. **Skipped verification** — code gets written but never tested against the acceptance criteria
3. **Context collapse** — on larger tasks, the agent forgets constraints from earlier in the conversation and contradicts its own plan

**The fix:** PGE structures work into the common agentic engineering arc: Research → Plan → Execute → Review → Ship. Each boundary has an explicit artifact or gate. Research produces findings. Planning produces a contract. Execution consumes that contract issue-by-issue with built-in verification. Review owns the composed-diff gates, including prove-it checks before shipping. Each phase is a separate skill invocation — you stay in control of when to advance.

## Quick Start

```
/pge-research   → understand the problem space
/pge-plan       → produce a bounded plan with issues and acceptance criteria
/pge-exec       → execute the plan issue by issue with verification
/pge-review     → review the composed diff against standards, spec, simplicity
/pge-challenge  → prove meaningful changes survive adversarial checks
```

## The Pipeline

```
pge-research → pge-plan → pge-exec → pge-review → pge-challenge → ship
```

Each skill produces an artifact or gate result that the next step consumes. You can enter at any point — skip research if you already know the landscape, skip planning if you already have a plan file, or run review/challenge on ordinary diffs outside the PGE pipeline.

### Workflow Map

| Stage | PGE surface | Artifact / gate |
|---|---|---|
| Research | `pge-research` | `.pge/tasks-<slug>/research.md` |
| Plan | `pge-plan` | `.pge/tasks-<slug>/plan.md` |
| Execute | `pge-exec` | `.pge/tasks-<slug>/runs/<run_id>/*` |
| Review | `pge-review` + optional `pge-challenge` | Review gate: `BLOCK_SHIP`, `NEEDS_FIX`, `READY_FOR_CHALLENGE`, or `READY_TO_SHIP`; prove-it evidence when needed |
| Ship | external git/PR/deploy workflow | commit, PR, merge, deploy, or handoff |

`pge-ai-native-refactor`, `pge-handoff`, `pge-knowledge`, `pge-html`, `pge-diagnose`, `pge-grill-me`, `pge-redo`, and `pge-zoom-out` are support surfaces. They are useful around the arc, but they do not replace the main stage contract.

## Skills

### Pipeline

Skills you use in sequence to go from fuzzy intent to verified code.

- **[`/pge-research`](./skills/pge-research/SKILL.md)** — Explore the problem space before planning. Use when intent is still fuzzy, multiple approaches seem viable, or the task touches unfamiliar code. Reads the repo, resolves ambiguity from code and docs, and writes a research brief that feeds into planning.

- **[`/pge-plan`](./skills/pge-plan/SKILL.md)** — Produce a bounded, engineering-reviewed plan under `.pge/tasks-<slug>/plan.md`. Challenges approaches, synthesizes intent, and decomposes into numbered executable issues with acceptance criteria and verification hints.

- **[`/pge-exec`](./skills/pge-exec/SKILL.md)** — Execute plan issues using Generator + Evaluator agents. Consumes a plan file, dispatches per-issue execution, validates with an independent Evaluator, runs a bounded repair loop on failures, and accumulates learnings across issues.

- **[`/pge-review`](./skills/pge-review/SKILL.md)** — Review-stage gate for changes since a fixed point. Checks standards, spec, simplicity, and verification story before routing to fix, challenge, or ship.

- **[`/pge-challenge`](./skills/pge-challenge/SKILL.md)** — Manual verify / prove-it gate before PR. Diffs branch against main, constructs failure scenarios, and verifies each meaningful change with evidence.

### Utilities

- **[`/pge-ai-native-refactor`](./skills/pge-ai-native-refactor/SKILL.md)** — Shape one human-selected repo evolution direction into a bounded AI-native refactor plan before PGE execution. Focuses one dominant friction: entry, containment, verification, structural toxicity, or a missing mechanical invariant.

- **[`/pge-handoff`](./skills/pge-handoff/SKILL.md)** — Create a compact, one-off handoff document for another agent or future session. Matt-style observer summary only: no pipeline control and no knowledge extraction.

- **[`/pge-knowledge`](./skills/pge-knowledge/SKILL.md)** — Evaluate context friction, agent memory, code summaries, and run learnings before promoting high-quality candidates into repo knowledge.

- **[`/pge-html`](./skills/pge-html/SKILL.md)** — Generate human-facing HTML views for plans, reports, reviews, comparisons, dashboards, and code explainers while keeping Markdown as the canonical pipeline artifact.

### Developer Tools

Independent skills for everyday development. Not part of the pipeline — use anytime.

- **[`/pge-diagnose`](./skills/pge-diagnose/SKILL.md)** — Structured 6-phase bug diagnosis: build feedback loop → reproduce → hypothesise → instrument → fix → cleanup.

- **[`/pge-grill-me`](./skills/pge-grill-me/SKILL.md)** — Stress-test a plan or design via relentless interrogation. Walks each branch of the decision tree.

- **[`/pge-redo`](./skills/pge-redo/SKILL.md)** — Scrap a mediocre fix and redo it elegantly using accumulated context from failed attempts.

- **[`/pge-zoom-out`](./skills/pge-zoom-out/SKILL.md)** — Map relevant modules, callers, and data flow at a higher abstraction layer.

## Install

Marketplace:

```
/plugin marketplace add feng-y/pge
/plugin install pge@pge
```

Local development:

```bash
./bin/pge-local-install.sh
```

## Development

Validate contracts and check progress:

```bash
./bin/pge-validate-contracts.sh
./bin/pge-progress-report.sh
```
