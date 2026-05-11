---
name: pge-html
description: >
  Convert any Markdown file or agent output into a polished, readable HTML page.
  Use when: sharing a plan/report with teammates, reviewing a long document visually,
  wanting interactive elements (tabs, diagrams, collapsible sections), or generating
  a dashboard from run artifacts. Not part of the pipeline — a standalone utility.
argument-hint: "<file.md> [--open] [--style minimal|rich|dashboard]"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
---

# PGE HTML

Convert Markdown files into polished, self-contained HTML pages. Standalone utility — not a pipeline stage.

## When to Use

- Sharing a plan or research brief with teammates who won't read raw Markdown
- Reviewing a long document (100+ lines) that benefits from visual hierarchy
- Generating a run dashboard from exec artifacts
- Creating an interactive view with tabs, collapsible sections, or diagrams
- Presenting options side-by-side for decision-making

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
| Contains `status:`, `verdict:`, `issues_passed:`, or table with PASS/BLOCK/RETRY | `dashboard` | status-report.html |
| Contains `## Options`, `## Findings`, `research_route:` | `rich` | research-explainer.html |
| Contains `## Slices`, `Issue N:`, `Action:`, `Target Areas:` | `rich` | implementation-plan.html |
| Contains `digraph`, `graph {`, or mermaid fences | `rich` | flowchart-diagram.html |
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

## Templates

Reference templates in `templates/` (from Thariq's html-effectiveness examples):

| Template | Use for | Style |
|----------|---------|-------|
| `status-report.html` | exec manifests, run dashboards, weekly reports | dashboard |
| `research-explainer.html` | research briefs, feature explainers | rich |
| `implementation-plan.html` | plan artifacts with issues, flow diagrams | rich |
| `flowchart-diagram.html` | dot flow visualization, architecture diagrams | rich |

Read the relevant template before generating. Match its structure and visual quality — these are the quality bar, not suggestions.

## Examples

```
/pge-html .pge/tasks-auth/plan.md --style rich
/pge-html .pge/tasks-auth/runs/run-001/manifest.md --style dashboard
/pge-html docs/research/ref-superpowers.md --style minimal --open
```

## Output

```md
## PGE HTML Result
- source: <input file>
- output: <output .html file>
- style: minimal | rich | dashboard
- opened: yes | no
```
