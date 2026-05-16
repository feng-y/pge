# PGE

A Claude Code plugin that turns multi-step engineering work into bounded, verified execution.

## Why PGE Exists

AI coding agents are great at single-shot tasks. Ask them to fix a typo or add a function — done. But real engineering work is multi-step: research the problem, plan the approach, execute issue by issue, verify each piece. This is where agents fall apart.

**The failure modes:**

1. **Drift** — the agent starts executing, loses track of the plan, and builds something you didn't ask for
2. **Skipped verification** — code gets written but never tested against the acceptance criteria
3. **Context collapse** — on larger tasks, the agent forgets constraints from earlier in the conversation and contradicts its own plan

**The fix:** PGE structures work into the common agentic engineering arc: Research → Plan → Execute → Review → Ship. Each boundary has an explicit artifact or gate, but the invariant is semantic alignment, not fixed formatting. Research proves it understands the user's intent. Planning turns that intent into an executable contract. Execution proves code changes satisfy that contract. Review checks the diff still aligns with the original intent before shipping. Each phase is a separate skill invocation — you stay in control of when to advance.

## Core Contract

PGE uses fixed interfaces with flexible expression.

- Research must expose `intent_spec`, `clarify_status`, `plan_delta`, `blockers`, and `evidence`.
- Plan must expose `goal`, `non_goals`, `issues`, `target_areas`, `acceptance`, `verification`, `evidence_required`, and `risks`.
- Exec must expose which issue each change implements, whether acceptance passed, what verification ran, and any plan deviations.
- Review must check the diff against the plan and the original user intent, including scope drift and evidence gaps, and write exec-facing findings to the task directory when a PGE task exists.
- Every stage must consume its explicit input plus relevant current context. When context changes intent, scope, or the fix target, the stage must clarify before producing the next contract.
- Research and plan own discovery and clarification. Exec should not be where major intent or acceptance ambiguity is resolved; that means the upstream contract was not ready.

Templates are scaffolds for consistency. They are not a reason to pad simple tasks or bury the real decision.

## Quick Start

```
/pge-research   → understand the problem space
/pge-plan       → produce a bounded plan with issues and acceptance criteria
/pge-exec       → execute the plan issue by issue with verification
/pge-review     → review the composed diff against standards, alignment, simplicity
/pge-challenge  → prove meaningful changes survive adversarial checks
```

## The Pipeline

```
pge-research → pge-plan → pge-exec → pge-review → pge-challenge → ship
```

Each skill produces an artifact or gate result that the next step consumes. You can enter at any point — skip research if you already know the landscape, skip planning if you already have a plan file, or run review/challenge on ordinary diffs outside the PGE pipeline.

PGE can also adopt plans produced by other workflows. If a Claude plan mode output, `docs/exec-plan/` document, or foreign workflow plan is clear and complete — goal, scope, semantic ownership, non-goals, target areas or ownership boundaries, implementation direction, and verification/evidence checkpoints are all present — `pge-plan-normalize` may convert it into `.pge/tasks-<slug>/plan.md`. After normalization, `pge-exec` consumes only that canonical artifact. Run artifacts and execution evidence live under `.pge/tasks-<slug>/runs/<run_id>/`. Review and challenge feedback that may trigger bounded repair reruns lives under `.pge/tasks-<slug>/`, but `pge-exec` must validate artifact provenance against the referenced run, canonical plan identity, and reviewed diff before consuming those task artifacts as repair input.

### Workflow Map

| Stage | PGE surface | Artifact / gate |
|---|---|---|
| Research | `pge-research` | `.pge/tasks-<slug>/research.md` with intent/evidence contract |
| Plan | `pge-plan` | `.pge/tasks-<slug>/plan.md` with executable issue contract |
| Normalize | `pge-plan-normalize` | canonical `.pge/tasks-<slug>/plan.md` adopted from a complete external plan |
| Execute | `pge-exec` | `.pge/tasks-<slug>/runs/<run_id>/*` |
| Review | `pge-review` + optional `pge-challenge` | `.pge/tasks-<slug>/review.md` and `.pge/tasks-<slug>/challenge.md`; feedback can feed bounded repair reruns via `pge-exec` only after provenance validation, upstream to `pge-plan` only for contract changes, and exec may hand off directly to challenge as the prove-it gate inside the Review stage |
| Ship | external git/PR/deploy workflow | commit, PR, merge, deploy, or handoff |

`pge-ai-native-refactor`, `pge-handoff`, `pge-knowledge`, `pge-html`, `pge-diagnose`, `pge-grill-me`, `pge-redo`, and `pge-zoom-out` are support surfaces. They are useful around the arc, but they do not replace the main stage contract.

## Skills

### Pipeline

Skills you use in sequence to go from fuzzy intent to verified code.

- **[`/pge-research`](./skills/pge-research/SKILL.md)** — Align research understanding with the user's real intent before planning. Use when intent is still fuzzy, multiple approaches seem viable, or the task touches unfamiliar code. Reads the repo, resolves ambiguity from code and docs, and writes the minimum intent/evidence contract that feeds planning.

- **[`/pge-plan`](./skills/pge-plan/SKILL.md)** — Produce a bounded, engineering-reviewed plan under `.pge/tasks-<slug>/plan.md`. Translates intent into numbered executable issue contracts with acceptance criteria, verification hints, and evidence requirements.

- **[`/pge-plan-normalize`](./skills/pge-plan-normalize/SKILL.md)** — Convert a complete external plan into the canonical `.pge/tasks-<slug>/plan.md` contract without replanning. Use this before execution when the source is already clear but not in PGE format.

- **[`/pge-exec`](./skills/pge-exec/SKILL.md)** — Execute plan issues using Generator + Evaluator agents. Consumes a plan file, dispatches per-issue execution, validates with an independent Evaluator, records evidence, and reports any plan deviation.

- **[`/pge-review`](./skills/pge-review/SKILL.md)** — Review-stage gate for changes since a fixed point. Checks standards, semantic alignment with the plan/original intent, simplicity, and verification story before routing to fix, challenge, or ship.

- **[`/pge-challenge`](./skills/pge-challenge/SKILL.md)** — Manual prove-it gate before PR/ship. Explains the diff, proves current prompt constraints when present, proves execution fulfilled the plan/development requirements, and challenges each meaningful change with evidence.

### Utilities

- **[`/pge-ai-native-refactor`](./skills/pge-ai-native-refactor/SKILL.md)** — Shape one human-selected repo evolution direction into a bounded AI-native refactor plan before PGE execution. Focuses one dominant friction: entry, containment, verification, structural toxicity, or a missing mechanical invariant.

- **[`/pge-handoff`](./skills/pge-handoff/SKILL.md)** — Create a compact, one-off handoff document for another agent or future session. Matt-style observer summary only: no pipeline control and no knowledge extraction.

- **[`/pge-knowledge`](./skills/pge-knowledge/SKILL.md)** — Evaluate context friction, agent memory, code summaries, and run artifact candidates before promoting high-quality candidates into repo knowledge.

- **[`/pge-html`](./skills/pge-html/SKILL.md)** — Generate human-facing HTML cognition tools for plans, reports, reviews, comparisons, dashboards, module maps, and execution semantics while keeping Markdown as the canonical pipeline artifact.

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

Check progress:

```bash
./bin/pge-progress-report.sh
```
