---
name: pge-html
description: >
  Convert any Markdown file or agent output into a polished, readable HTML page.
  Use when: sharing a plan/report with teammates, reviewing a long document visually,
  wanting interactive elements (tabs, diagrams, collapsible sections), or generating
  a dashboard from run artifacts. Human-facing HTML layer inspired by Thariq's
  "unreasonable effectiveness of HTML" examples. Not part of the pipeline.
argument-hint: "<file.md> [--open] [--style minimal|rich|dashboard|comparison|review|explainer|module-map|code-review|pr-writeup]"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---

# PGE HTML

Convert Markdown files into polished, self-contained HTML pages. Standalone utility — not a pipeline stage.

HTML is for human understanding and decision-making, not for skill-to-skill contracts. Keep canonical PGE artifacts in Markdown; generate HTML views when the user needs to inspect, compare, present, tune, or hand off the information visually.

## When to Use

- Sharing a plan or research brief with teammates who won't read raw Markdown
- Reviewing a long document (100+ lines) that benefits from visual hierarchy
- Generating a run dashboard from exec artifacts
- Creating an interactive view with tabs, collapsible sections, or diagrams
- Presenting options side-by-side for decision-making
- Turning review output into annotated findings with severity tags and jump links
- Presenting a PR with motivation, file-by-file tour, and review focus areas
- Turning repo/code summaries into module maps or feature explainers
- Creating a small "copy as prompt" panel that exports the user's chosen option back to Markdown

## When NOT to Use

- Pipeline artifacts that other skills consume (keep those as .md)
- Quick notes or scratch files
- Files that need version-control-friendly diffs

## Process

1. Read the source file(s)
2. Determine style — explicit `--style` overrides auto-detection:

### Auto-Detection Rules

| Signal in source file | Style | Template |
|---|---|---|
| Contains multiple options, alternatives, or approaches to choose between | `comparison` | comparison-board.html |
| Contains `## Standards`, `## Spec`, `## Simplicity` **plus** diff context (`@@`, `---`/`+++`, or dense `file:line` with code) | `code-review` | code-review.html |
| Contains `## Standards`, `## Spec`, `## Simplicity`, or review findings (no diff context) | `review` | review-annotated.html |
| Contains `status:`, `verdict:`, `issues_passed:`, or table with PASS/BLOCK/RETRY | `dashboard` | status-report.html |
| Contains `## Motivation` + `## File Tour`, or `## Before`/`## After` with file changes, or PR metadata | `pr-writeup` | pr-writeup.html |
| Contains `## Options`, `## Findings`, `research_route:` | `rich` | research-explainer.html |
| Contains `## Slices`, `Issue N:`, `Action:`, `Target Areas:` | `rich` | implementation-plan.html |
| Contains `digraph`, `graph {`, or mermaid fences | `rich` | flowchart-diagram.html |
| Contains `module`, `owner`, `callers`, `callees`, `entrypoint`, or `data flow` summaries | `module-map` | module-map.html |
| Contains `quality_score:`, `context-friction`, `repo-memory`, or `code-summary` | `explainer` | research-explainer.html |
| File is under `.pge/tasks-*/runs/` | `dashboard` | status-report.html |
| File is `research.md` or under `.pge/tasks-*/` with findings | `rich` | research-explainer.html |
| File is `plan.md` | `rich` | implementation-plan.html |
| None of the above | `minimal` | (no template, clean typography) |

When multiple signals match, prefer the first match in the table above.

3. Read the matched template from `templates/` as quality reference
4. Generate a single self-contained HTML file (inline CSS, no external deps)
5. Write to same directory as source: `<filename>.html`
6. If `--open` specified, open in browser via `open` or `xdg-open`

## Design Principles

- **Self-contained** — single file, no CDN links, works offline
- **Readable** — optimized for scanning, not for editing
- **Responsive** — works on mobile if shared via URL
- **Copy-friendly** — code blocks have copy buttons, key values are selectable

## Style Guide

All styles share:
- System font stack (no web fonts to load)
- Max-width content area (700px prose, wider for tables/diagrams)
- Proper heading hierarchy with anchor links
- Syntax-highlighted code blocks
- Tables with alternating row colors

`rich` adds:
- Collapsible sections for long content
- Tabbed views when multiple options/issues exist
- SVG diagrams for flows described in dot/mermaid notation
- Color-coded status badges (PASS=green, RETRY=amber, BLOCK=red)
- Sticky table-of-contents sidebar

`dashboard` adds:
- Card grid layout for issues/metrics
- Progress indicators
- Summary stats at top (passed/blocked/total)
- Timeline view for sequential events

`comparison` adds:
- Side-by-side option cards with trade-offs, risks, and recommended/default choice
- A compact decision table for user selection
- Optional "copy selected option as prompt" output

`review` adds:
- Severity-filtered findings
- Annotated file/line references
- Verification story summary
- Reviewer focus areas and "what to fix first"

`code-review` adds:
- Rendered diff view with line numbers and +/- coloring
- Margin annotations pinned to diff lines with severity badges
- Per-file finding counts in a sticky sidebar with severity filters
- Fix-first prioritized callout at top
- Diff context for each finding (shows the actual code, not just file:line)

`pr-writeup` adds:
- Motivation callout with clay accent
- Before/after side-by-side comparison cards
- File-by-file tour with change-type badges and per-file rationale
- Review focus areas as risk-colored cards (high/medium/low)
- Testing notes with runnable commands
- Open decisions section

`explainer` adds:
- TL;DR box
- Collapsible deep dives
- Glossary or concept rail when helpful
- Code/path callouts that make a repo summary navigable

`module-map` adds:
- Repo/module ownership map with entrypoints, callers, callees, and risky seams
- Dependency arrows or adjacency lists that are readable without opening the codebase
- File-path rail for fast navigation
- Context-friction notes: what future agents usually miss, where to start, and what not to touch

## HTML Effectiveness Pattern

Use HTML when structure helps the user think:

| Need | HTML Shape |
|---|---|
| Choose between approaches | side-by-side comparison |
| Understand unfamiliar code | module map, flow diagram, call-path explainer |
| Review a diff | annotated findings, jump links, severity filters |
| Inspect execution status | dashboard, timeline, evidence cards |
| Learn a concept | collapsible explainer, glossary, interactive diagram |
| Tune a prompt/config | small editor with copy/export button |
| Present a PR | motivation callout, file tour, review focus cards |

Avoid HTML when the output is primarily for downstream skills, grep, code review diffs, or long-lived canonical truth.

## Templates

Reference templates in `templates/` (from Thariq's html-effectiveness examples):

| Template | Use for | Style |
|----------|---------|-------|
| `status-report.html` | exec manifests, run dashboards, weekly reports | dashboard |
| `research-explainer.html` | research briefs, feature explainers | rich |
| `implementation-plan.html` | plan artifacts with issues, flow diagrams | rich |
| `flowchart-diagram.html` | dot flow visualization, architecture diagrams | rich |
| `module-map.html` | repo/module maps, code summaries, ownership and call-path explainers | module-map |
| `comparison-board.html` | options, alternatives, architecture trade-offs, prompt/config tuning | comparison |
| `review-annotated.html` | pge-review findings without diff context | review |
| `code-review.html` | pge-review or pge-challenge output **with** diff hunks or dense file:line code references | code-review |
| `pr-writeup.html` | PR descriptions, branch writeups, pre-merge summaries | pr-writeup |

Read the relevant template before generating. Match its structure and visual quality — these are the quality bar, not suggestions.

## Examples

```
/pge-html .pge/tasks-auth/plan.md --style rich
/pge-html .pge/tasks-auth/runs/run-001/manifest.md --style dashboard
/pge-html docs/research/ref-superpowers.md --style minimal --open
/pge-html .pge/tasks-auth/runs/run-001/review.md --style code-review
/pge-html docs/pr-auth-rewrite.md --style pr-writeup --open
```

## Output

```md
## PGE HTML Result
- source: <input file>
- output: <output .html file>
- style: minimal | rich | dashboard | comparison | review | explainer | module-map | code-review | pr-writeup
- opened: yes | no
```
