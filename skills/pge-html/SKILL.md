---
name: pge-html
description: >
  Convert Markdown files or agent output into self-contained HTML cognition
  tools. Use when a human needs to inspect, compare, explain, review, present,
  or navigate complex repo artifacts visually. Not part of the pipeline.
argument-hint: "<file.md> [--open] [--style minimal|rich|dashboard|comparison|review|explainer|module-map|execution-semantics|code-review|pr-writeup]"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---

# PGE HTML

Convert Markdown into polished, self-contained HTML pages. Standalone utility — not a pipeline stage.

HTML is for human understanding and decision-making, not for skill-to-skill contracts. Keep canonical PGE artifacts in Markdown. Generate HTML only when the user benefits from a visual, navigable, or interactive cognition tool.

## Core Rule

Do not just make Markdown prettier. Before writing HTML, state the cognitive job the page replaces:
- choose between approaches
- understand code structure
- understand runtime/execution semantics
- review a diff
- inspect run status
- explain a concept
- present a PR
- tune a prompt/config

If the output does not make that job faster than reading Markdown, repair it before returning.

## When To Use

- Sharing a plan or research brief with teammates who will not read raw Markdown
- Reviewing a long document that benefits from visual hierarchy
- Generating a run dashboard from exec artifacts
- Creating an interactive view with tabs, collapsible sections, or diagrams
- Presenting options side-by-side for decision-making
- Turning review output into annotated findings with severity tags and jump links
- Presenting a PR with motivation, file-by-file tour, and review focus areas
- Turning repo/code summaries into module maps, execution maps, or feature explainers
- Creating a small "copy as prompt" panel that exports the user's chosen option back to Markdown

## When Not To Use

- Pipeline artifacts that other skills consume directly
- Quick notes or scratch files
- Files that need version-control-friendly diffs
- Long-lived canonical truth that should remain greppable Markdown

## Process

1. Read the source file(s).
2. Define the cognitive job in one sentence.
3. Extract a content model before rendering:
   - entities: modules, files, actors, issues, options, findings, or phases
   - relationships: flow, dependency, ownership, before/after, cause/effect
   - transformations: input → intermediate → output
   - decisions: recommended/default, alternatives, rejects
   - risks/friction: what future agents or reviewers usually miss
   - verification: commands, evidence, hotspots, confidence
4. Determine style. Explicit `--style` overrides auto-detection.
5. Read `references/template-contracts.md`.
6. Read the matched template from `templates/`.
7. Generate one self-contained HTML file with inline CSS and no external deps.
8. Run the style-specific quality gate from `template-contracts.md`.
9. Write to the same directory as source: `<filename>.html`.
10. If `--open` is specified, open in browser via `open` or `xdg-open`.

## Auto-Detection Rules

Prefer explicit style, then canonical path/name signals, then content signals.

| Signal | Style | Template |
|---|---|---|
| Explicit `--style <style>` | requested style | requested template |
| File is under `.pge/tasks-*/runs/` | `dashboard` | status-report.html |
| File is `plan.md` or contains `## Slices` / `Issue N:` / `Action:` / `Target Areas:` | `rich` | implementation-plan.html |
| File is `research.md` or contains `research_route:` / `## Findings` | `explainer` | research-explainer.html |
| Contains execution semantics, feature execution, runtime path, tensor/data shape transforms, input → intermediate → output, or terms like `generate_input`, `batch_size`, `mask`, `gather`, `indices`, `padding` | `execution-semantics` | execution-semantics.html |
| Contains `## Standards`, `## Spec`, `## Simplicity` plus diff context (`@@`, `---`/`+++`, or dense `file:line` with code) | `code-review` | code-review.html |
| Contains `## Standards`, `## Spec`, `## Simplicity`, or review findings without diff context | `review` | review-annotated.html |
| Contains `status:`, `verdict:`, `issues_passed:`, or table with PASS/BLOCK/RETRY | `dashboard` | status-report.html |
| Contains `## Motivation` + `## File Tour`, or `## Before`/`## After` with file changes, or PR metadata | `pr-writeup` | pr-writeup.html |
| Contains multiple options, alternatives, approaches, or trade-offs to choose between | `comparison` | comparison-board.html |
| Contains module, owner, callers, callees, entrypoint, data flow, seams, or repo map summaries | `module-map` | module-map.html |
| Contains `quality_score:`, `context-friction`, `repo-memory`, or `code-summary` | `explainer` | research-explainer.html |
| Contains `digraph`, `graph {`, mermaid fences, or architecture flow notation | `rich` | flowchart-diagram.html |
| None of the above | `minimal` | no template; clean typography |

When multiple signals match, prefer the first match in the table.

## Required Template Contracts

Every style has required components. Read `references/template-contracts.md` before generating and satisfy the selected style's contract. Missing required components are a generation failure, not optional polish.

Common requirements:
- top-level cognitive job statement
- at least one visual structure that is not just a long prose column
- "start here" or equivalent orientation when the source is code/domain knowledge
- verification/evidence surface when the source is plan, review, execution, or code semantics
- context-friction or gotchas when the page is meant to guide future agents
- copy/export panel only when it has a useful downstream prompt or action

## Safety And Escaping

Treat source Markdown and agent output as untrusted text.

- Escape all source text before inserting into HTML.
- Put code, paths, diff lines, review findings, and prompt exports into text nodes or escaped markup.
- Do not use `innerHTML` for user/source-derived content.
- Do not include CDN links, external scripts, remote fonts, `fetch()`, or network resources.
- Inline JavaScript is allowed only for local UI state: tabs, filters, copy buttons, and collapsible sections.
- Generated HTML must work offline as a single file.

## Design Principles

- **Cognition first** — structure replaces a thinking task, not just a reading surface.
- **Self-contained** — single file, no external dependencies.
- **Progressive disclosure** — summary first, details on demand.
- **Evidence-visible** — important claims point to source paths, commands, or confidence.
- **Agent-useful** — for repo knowledge, include what future agents should start with, avoid, and verify.
- **Responsive** — no desktop-only grids; collapse dense maps on narrow screens.
- **Copy-friendly** — code blocks and prompts are selectable; copy buttons are optional.

## Templates

Reference templates in `templates/`. They are visual examples; `references/template-contracts.md` is the contract.

| Template | Use for | Style |
|---|---|---|
| `status-report.html` | exec manifests, run dashboards, weekly reports | dashboard |
| `research-explainer.html` | research briefs, feature explainers | explainer |
| `implementation-plan.html` | plan artifacts with issues, flow diagrams | rich |
| `flowchart-diagram.html` | dot flow visualization, architecture diagrams | rich |
| `module-map.html` | repo/module maps, ownership and call-path explainers | module-map |
| `execution-semantics.html` | runtime paths, feature execution, data-shape transformations | execution-semantics |
| `comparison-board.html` | options, alternatives, architecture trade-offs, prompt/config tuning | comparison |
| `review-annotated.html` | pge-review findings without diff context | review |
| `code-review.html` | pge-review or pge-challenge output with diff hunks or dense file:line code references | code-review |
| `pr-writeup.html` | PR descriptions, branch writeups, pre-merge summaries | pr-writeup |

## Examples

```text
/pge-html .pge/tasks-auth/plan.md --style rich
/pge-html .pge/tasks-auth/runs/run-001/manifest.md --style dashboard
/pge-html docs/domain-knowledge/listwise-feature-execution.md --style execution-semantics --open
/pge-html docs/research/ref-superpowers.md --style minimal --open
/pge-html .pge/tasks-auth/runs/run-001/review.md --style code-review
/pge-html docs/pr-auth-rewrite.md --style pr-writeup --open
```

## Output

```md
## PGE HTML Result
- source: <input file>
- output: <output .html file>
- style: minimal | rich | dashboard | comparison | review | explainer | module-map | execution-semantics | code-review | pr-writeup
- cognitive_job: <what this page helps the reader do faster>
- required_components: pass | repaired | failed
- opened: yes | no
```
