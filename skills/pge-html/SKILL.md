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
2. Determine style from argument or content:
   - `minimal` — clean typography, no frills, fast to generate
   - `rich` — color-coded sections, SVG diagrams, navigation sidebar
   - `dashboard` — cards, metrics, status indicators (for run manifests/learnings)
3. Generate a single self-contained HTML file (inline CSS, no external deps)
4. Write to same directory as source: `<filename>.html`
5. If `--open` specified, open in browser via `open` or `xdg-open`

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
