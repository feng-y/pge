# PGE

PGE is a Claude Code plugin for plan-grounded engineering work.

It turns fuzzy intent or an external plan into a canonical repo-local contract, then lets an execution backend implement against that contract with evidence. The point is not to make agents follow more ceremony. The point is to improve execution quality: preserve intent, keep scope bounded, expose verification, and make failures useful.

## Positioning

PGE is a harness, not an agent OS.

It does three jobs:

1. **Clarify the work**: capture goal, success shape, scope, constraints, and current repo reality.
2. **Freeze an executable contract**: choose an approach, slice work into issue contracts, define acceptance and verification, and preserve forbidden areas.
3. **Route evidence back**: execution produces verifiable evidence or a useful blocker for review, replan, ship, or handoff.

PGE does not try to replace Claude Code's native execution ability. `pge-exec` remains the default PGE execution surface. Ready plans may also expose `workflow-handoff.md` so Claude Code Dynamic Workflow can own task-specific orchestration while still reading the same canonical plan.

## Core Model

The durable source of truth is the task directory:

```text
.pge/tasks-<slug>/
  research.md                     # optional problem-discovery contract
  plan.md                         # canonical plan contract
  issues/Ixxx.md                  # full issue execution contracts
  workflow-handoff.md             # optional Dynamic Workflow launch adapter
  runs/<run_id>/*                 # pge-exec run artifacts
  workflow-result.md              # optional Dynamic Workflow evidence backflow
  review.md / challenge.md        # bounded review/prove-it feedback when invoked
```

The invariant is semantic alignment, not fixed formatting. Templates are scaffolds. Required meanings matter more than prose shape.

## Flow

```text
Research -> Plan -> Execute backend -> Evidence backflow -> Review / Challenge / Ship
```

Execution backend options:

| Backend | Input | Output | Owns |
|---|---|---|---|
| `pge-exec` | `plan.md` + selected `issues/Ixxx.md` | `.pge/tasks-<slug>/runs/<run_id>/*` | default PGE execution lanes, bounded repair, staged verification, Exec QA Gate |
| Claude Code Dynamic Workflow | `workflow-handoff.md` -> `plan.md` | `.pge/tasks-<slug>/workflow-result.md` | task-specific orchestration, parallelism, bounded local repair, verification, result production |

`workflow-result.md` is not a `pge-exec` repair artifact and not a `pge-review` route. It is evidence backflow for the next selected review, replan, ship, or handoff step.

## Stage Authority

| Surface | Owns | Does not own |
|---|---|---|
| `pge-research` | Problem contract: goal, success shape, scope, non-goals, constraints, relevant context, route | Final solution approach, issue slicing, implementation |
| `pge-plan` | Executable solution contract: selected approach, issue index, issue files, target/forbidden areas, acceptance, verification, evidence, Final Plan Gate | Implementation code, runtime orchestration, shipping decision |
| `pge-exec` | Default execution inside the plan contract, run evidence, bounded repair, Diagnostic Recovery | Plan mutation, scope expansion, verification waiver, shipping decision |
| Dynamic Workflow | Optional execution backend interpreting the same canonical plan through `workflow-handoff.md` | Rewriting the plan into a reusable graph, creating PGE routes, replacing the canonical plan |
| `pge-review` | Review verdict when explicitly invoked: alignment, simplicity, standards, verification story | Default ownership of all workflow results, implementation, plan mutation |
| `pge-challenge` | Manual prove-it pressure before PR/ship when invoked | Planning or implementation authority |

Subagents and workers are bounded helpers, not workflow authorities.

## Plan Contract

`pge-plan` produces the canonical contract under `.pge/tasks-<slug>/`.

A ready plan includes:

- `plan.md` with `schema_version`, source contract check, selected/rejected approaches, goal, non-goals, necessary context, issue index, target areas, forbidden areas, acceptance, verification, evidence required, terminal conditions, plan gate, stop conditions, and route.
- `issues/Ixxx.md` files containing full issue contracts. `plan.md ## issues` is only a compact Execution Index.
- `workflow-handoff.md` for ready routes, as an optional Dynamic Workflow launch adapter.

`workflow-handoff.md` points back to `plan.md`. It must not copy acceptance criteria, issue bodies, verification details, or derive a reusable workflow graph, task DAG, dependency JSON, or subagent topology.

## External Plans

PGE can adopt plans produced outside PGE: Claude plan mode output, `docs/exec-plans/` documents, review comments, issue lists, or other structured notes.

Fast-adopt is allowed only when the source semantics are sufficient for `pge-plan` to confirm:

- goal and observable success or stop condition
- bounded scope and non-goals
- fixed decisions and ownership boundaries
- allowed and forbidden areas
- verification and evidence expectations
- enough ordered work structure to derive executable issues without inventing scope or re-deciding architecture

After adoption, `.pge/tasks-<slug>/plan.md` is authoritative. The external plan remains source evidence, not a parallel runtime contract.

## Skills

### Main Surfaces

- **[`/pge-research`](./skills/pge-research/SKILL.md)** — Produce a bounded `research.v3` problem-discovery brief when goal, success shape, scope, constraints, or repo reality is not clear enough for fair planning.

- **[`/pge-plan`](./skills/pge-plan/SKILL.md)** — Produce the canonical executable solution contract: `plan.md`, `issues/Ixxx.md`, Final Plan Gate, and optional `workflow-handoff.md` for ready plans.

- **[`/pge-exec`](./skills/pge-exec/SKILL.md)** — Execute plan issues through the default PGE backend, with bounded lanes, verification evidence, implementation notes, and Diagnostic Recovery for unclear or repeated development failures.

- **[`/pge-review`](./skills/pge-review/SKILL.md)** — Review changes since a fixed point when invoked. Checks alignment with plan/original intent, standards, simplicity, and verification story, then returns a bounded review verdict.

- **[`/pge-challenge`](./skills/pge-challenge/SKILL.md)** — Manual prove-it gate when invoked. Challenges meaningful changes with evidence before PR/ship.

### Support Surfaces

- **[`/pge-ai-native-refactor`](./skills/pge-ai-native-refactor/SKILL.md)** — Shape one human-selected repo evolution direction before PGE execution.
- **[`/pge-spark`](./skills/pge-spark/SKILL.md)** — Superpowers-style brainstorming shim for fuzzy or solution-first inputs before planning.
- **[`/pge-handoff`](./skills/pge-handoff/SKILL.md)** — Create a temporary focused handoff for another agent or future session.
- **[`/pge-learn`](./skills/pge-learn/SKILL.md)** — Capture high-quality learning candidates from context friction, agent memory, code summaries, and run artifacts.
- **[`/pge-html`](./skills/pge-html/SKILL.md)** — Render PGE artifacts or current-thread source packets into faithful HTML pages and decision boards.
- **[`/pge-complexity`](./skills/pge-complexity/SKILL.md)** — Report-first complexity and performance-hotspot analysis.
- **[`/pge-diagnose`](./skills/pge-diagnose/SKILL.md)** — Structured bug diagnosis.
- **[`/pge-grill-me`](./skills/pge-grill-me/SKILL.md)** — Stress-test a plan or design.
- **[`/pge-redo`](./skills/pge-redo/SKILL.md)** — Redo a mediocre fix using accumulated context.
- **[`/pge-zoom-out`](./skills/pge-zoom-out/SKILL.md)** — Map relevant modules, callers, and data flow at a higher abstraction layer.

## Install

Marketplace:

```text
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
./bin/pge-progress-report.sh <progress.jsonl-or-task-dir>
```
