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

PGE is a harness, not a heavy protocol engine. Default artifacts should give the model the goal, forbidden boundaries, necessary context, recommended direction when useful, and verification evidence expected. Detailed audit fields are risk-triggered, not default execution ceremony.

PGE execution principle:
- PGE is a do-my-best execution system under explicit goal and verification, not a prove-everything-before-execution system.
- `READY_FOR_EXECUTE` means the current contract is good enough to start, not that no clarification will ever be needed.
- Issues are the best current executable slices, not perfect closed-world objects.
- Validation is the strongest economical signal available now, not exhaustive proof.
- Exec should keep moving inside the contract and clarify only when continuing would change goal, scope, validation, boundaries, or authority.

- Research must expose `schema_version: research.v3`, goal, success shape, scope, non-goals, constraints, task-relevant context, candidate direction, open questions, and route. Implementation Friction, Progressive Feasibility, and Core Friction Confirmation are conditional gates only; unresolved core friction must carry explicit authority such as `observed_behavior` or `<base authority> / needs_confirmation`.
- Plan must expose `schema_version`, `source_contract_check`, `selected_approach`, `rejected_approaches`, `goal`, `non_goals`, `necessary_context`, `issues`, `target_areas`, `forbidden_areas`, `acceptance`, `verification`, `evidence_required`, `terminal_conditions`, `plan_gate`, `stop_conditions`, and `route`. Add recommended approach only when it helps execution without constraining useful implementation choice. In new executable plans, `plan.md ## issues` is a compact Execution Index; full issue contracts live in `.pge/tasks-<slug>/issues/Ixxx.md`.
- Exec must expose which issue each change implements, whether acceptance passed, what verification ran, any plan deviations, any stalled-lane recovery, and any Diagnostic Recovery record for unclear or repeated development failures.
- Review must check the diff against the plan and the original user intent, including scope drift and evidence gaps, and write exec-facing findings to the task directory when a PGE task exists.
- Every stage must consume its explicit input plus relevant current context. When context changes intent, scope, or the fix target, the stage must clarify before producing the next contract.
- Research owns problem discovery; Plan owns executable solution design. Exec should not be where major intent, scope, or acceptance ambiguity is resolved; that means the upstream contract was not ready.

### Stage Authority

| Stage | Owns | Does not own |
|---|---|---|
| Research | Problem contract: goal, success shape, scope, non-goals, constraints, candidate direction, route | Final solution approach, issue slicing, acceptance criteria, verification path, implementation |
| Plan | Executable solution contract: selected approach, issue index, issue files, target/forbidden areas, acceptance, verification, evidence, Plan Engineering Review, Final Plan Gate | Goal/scope redefinition, implementation code, shipping decision |
| Exec | Implementation and evidence inside plan contract: scheduling, bounded repair, deviation detection, Exec QA Gate | Plan mutation, scope expansion, verification waiver, shipping decision |
| Review | Alignment audit: diff vs plan vs original intent, shipping-readiness route | Implementation, plan changes, execution |

Templates are scaffolds for consistency. They are not a reason to pad simple tasks or bury the real decision.

## Quick Start

```
/pge-research   → understand the problem space
/pge-plan       → produce a bounded plan with issues and acceptance criteria
/pge-exec       → execute the plan with bounded lanes, evidence, and verification
/pge-review     → review the composed diff against standards, alignment, simplicity
/pge-challenge  → prove meaningful changes survive adversarial checks
```

## The Pipeline

```
pge-research → pge-plan → pge-exec → pge-review → pge-challenge → ship
```

Each skill produces an artifact or gate result that the next step consumes. You can enter at any point — skip research if you already know the landscape, skip planning if you already have a plan file, or run review/challenge on ordinary diffs outside the PGE pipeline.

If you are used to all-in-one feature development workflows, map the PGE stages like this:

| Plain phase | PGE surface | Role |
|---|---|---|
| Discovery / exploration | `pge-research` | Clarify goal, success shape, scope, constraints, relevant context, and route. |
| Design / architecture | `pge-plan` | Select the implementation approach and produce executable issue contracts. |
| Implementation | `pge-exec` | Execute ready issues with evidence and run artifacts. |
| Quality review | `pge-review` / `pge-challenge` | Check alignment, verification, simplicity, and prove-it concerns. |
| Learning | `pge-learn` | Turn repeated friction and useful recent-work evidence into durable candidates. |

PGE keeps these as separate surfaces rather than one command so each stage has a clear authority boundary and durable artifact.

PGE can also adopt plans produced by other workflows. A Claude plan mode output, `docs/exec-plans/` document, or foreign workflow plan is adoption-ready when its semantics are sufficient for `pge-plan` to confirm the goal, observable success or stop condition, bounded scope, fixed decisions and ownership boundaries, allowed/forbidden areas, verification/evidence expectations, and enough ordered work structure to derive executable issues without inventing scope or re-deciding architecture. The source can be prose, tables, issue lists, review comments, or other structured notes; it does not need canonical headings. Fast-adopt materializes those semantics into canonical `.pge/tasks-<slug>/plan.md` with `plan.v2` fields plus referenced `.pge/tasks-<slug>/issues/Ixxx.md` issue contracts, then runs the Final Plan Gate before execution is allowed. After adoption, `pge-exec` consumes the canonical plan index and selected issue files when `plan_gate` passes. Run artifacts and execution evidence live under `.pge/tasks-<slug>/runs/<run_id>/`. Review and challenge feedback that may trigger bounded repair reruns lives under `.pge/tasks-<slug>/`, but `pge-exec` must validate artifact provenance against the referenced run, canonical plan identity, and reviewed diff before consuming those task artifacts as repair input.

### Workflow Map

| Stage | PGE surface | Artifact / gate |
|---|---|---|
| Research | `pge-research` | `.pge/tasks-<slug>/research.md` with bounded `research.v3` problem-discovery contract |
| Plan | `pge-plan` | `.pge/tasks-<slug>/plan.md` with issue Execution Index, `.pge/tasks-<slug>/issues/Ixxx.md` issue contracts, and Final Plan Gate |
| Plan (external) | `pge-plan` fast-adopt | canonical `.pge/tasks-<slug>/plan.md` materialized from a semantically sufficient external plan after Final Plan Gate |
| Execute | `pge-exec` | `.pge/tasks-<slug>/runs/<run_id>/*` |
| Review | `pge-review` + optional `pge-challenge` | `.pge/tasks-<slug>/review.md` and `.pge/tasks-<slug>/challenge.md`; feedback can feed bounded repair reruns via `pge-exec` only after provenance validation, upstream to `pge-plan` only for contract changes, and `pge-challenge` is reached from a review-stage `READY_FOR_CHALLENGE` route |
| Ship | external git/PR/deploy workflow | commit, PR, merge, deploy, or handoff |

`pge-ai-native-refactor`, `pge-handoff`, `pge-learn`, `pge-html`, `pge-complexity`, `pge-diagnose`, `pge-grill-me`, `pge-redo`, and `pge-zoom-out` are support surfaces. They are useful around the arc, but they do not replace the main stage contract.

## Skills

### Pipeline

Skills you use in sequence to go from fuzzy intent to verified code.

- **[`/pge-research`](./skills/pge-research/SKILL.md)** — Produce a bounded `research.v3` problem-discovery brief before planning. Use when goal, success shape, scope, constraints, or repo reality is not clear enough for fair planning. Separates original goal A from implementation hypothesis B, records task-relevant context, triggers Implementation Friction or Progressive Feasibility only when needed, and stops with an explicit route.

- **[`/pge-plan`](./skills/pge-plan/SKILL.md)** — Produce a bounded executable solution-design contract under `.pge/tasks-<slug>/`: stable `plan.md` with an issue Execution Index plus `issues/Ixxx.md` issue contracts with goal, semantic plan context, change, target areas, recommended approach, forbidden boundaries, and validation. Includes depth-scaled Plan Engineering Review, repo reality checks, and a Final Plan Gate that must pass before `pge-exec`. Also supports fast-adopt for explicit external plans whose semantics are sufficient to materialize the canonical contract.

- **[`/pge-exec`](./skills/pge-exec/SKILL.md)** — Execute plan issues with lightweight coordination, compact bounded Generator lanes, staged verification, and final Evaluator pressure. Consumes a plan file, allows implementation adaptation inside the plan contract with `implementation-notes.md`, uses optional read-only prep hints when useful, and verifies the composed run rather than forcing per-issue Evaluator approval. Records evidence, reports plan deviations, recovers stalled lanes with Progress Watchdog, and escalates unclear development failures into Diagnostic Recovery instead of trial-and-error repair.

- **[`/pge-review`](./skills/pge-review/SKILL.md)** — Review-stage gate for changes since a fixed point. Checks standards, semantic alignment with the plan/original intent, simplicity, and verification story before routing to fix, challenge, or ship.

- **[`/pge-challenge`](./skills/pge-challenge/SKILL.md)** — Manual prove-it gate before PR/ship. Explains the diff, proves current prompt constraints when present, proves execution fulfilled the plan/development requirements, and challenges each meaningful change with evidence.

### Utilities

- **[`/pge-ai-native-refactor`](./skills/pge-ai-native-refactor/SKILL.md)** — Shape one human-selected repo evolution direction into a bounded AI-native refactor plan before PGE execution. Focuses one dominant friction: entry, containment, verification, structural toxicity, or a missing mechanical invariant.

- **[`/pge-spark`](./skills/pge-spark/SKILL.md)** — Superpowers-style brainstorming reference workflow for fuzzy, broad, value-laden, or solution-first prompts. It is not the canonical PGE research contract. Recovers original goal A before implementation hypothesis B, asks one question at a time, compares 2-3 framings or approaches, writes `.pge/tasks-<slug>/spark.md`, and stops after the user-approved spec for `pge-plan` consumption.

- **[`/pge-handoff`](./skills/pge-handoff/SKILL.md)** — Create a temporary, focused handoff for another agent or future session. Matt-style task slice only: no pipeline control and no knowledge extraction.

- **[`/pge-learn`](./skills/pge-learn/SKILL.md)** — Learn from context friction, agent memory, code summaries, and run artifacts. Uses `learn` as the default capture command, records raw workspace-local learning candidates when useful, and promotes only high-quality evidence-backed items into durable repo knowledge.

- **[`/pge-html`](./skills/pge-html/SKILL.md)** — Render canonical PGE artifacts into faithful single-file HTML pages and derived decision boards. Faithful pages preserve source structure; decision boards compress artifacts into issue, evidence, risk, gate, and human-attention views while keeping Markdown/JSON/evidence as the source of truth. Also accepts current-thread context, generated reports, command output, browser observations, and mixed source packets without requiring a Markdown file first; supports non-PGE cognition, design-to-HTML, presentation, and local-editor artifacts with semantic coverage and markup-integrity checks.

- **[`/pge-complexity`](./skills/pge-complexity/SKILL.md)** — Report-first complexity and performance-hotspot analysis. Finds likely algorithmic, nesting, function-size, and file-size hotspots; modifies code only when explicitly requested.

### Developer Tools

Independent skills for everyday development. Not part of the pipeline — use anytime.

- **[`/pge-diagnose`](./skills/pge-diagnose/SKILL.md)** — Structured 6-phase bug diagnosis: build feedback loop → reproduce → hypothesise → instrument → fix → cleanup. Use directly for bugs, and indirectly through `pge-exec` Diagnostic Recovery when execution hits an unclear or repeated development failure.

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
./bin/pge-progress-report.sh <progress.jsonl-or-task-dir>
```
