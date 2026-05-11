---
name: pge-review
description: >
  Three-axis review of changes since a fixed point. Standards axis checks
  repo conventions; Spec axis checks against the originating plan/issue;
  Simplicity axis flags unnecessary complexity in new code.
  Runs all three in parallel sub-agents. Use anytime — not limited to pge-exec.
argument-hint: "<fixed-point: branch, commit, tag, or main>"
allowed-tools:
  - Read
  - Bash
  - Grep
  - Glob
  - Agent
# inspired by: https://github.com/mattpocock/skills/blob/main/skills/in-progress/review/SKILL.md
---

# PGE Review

Three-axis review of the diff between `HEAD` and a fixed point:

- **Standards** — does the code conform to this repo's documented conventions?
- **Spec** — does the code faithfully implement what was asked for?
- **Simplicity** — is the new code as simple as it can be without losing behavior?

All three axes run as parallel sub-agents so they don't pollute each other's context.

## Process

### 1. Pin the fixed point

Use the argument as the fixed point (commit, branch, tag, `main`). If not provided, ask once: "Review against what?"

Capture: `git diff <fixed-point>...HEAD` and `git log <fixed-point>..HEAD --oneline`.

### 2. Identify the spec source

Look for the originating spec in this order:

1. `.pge/tasks-*/plan.md` matching the current branch or recent work
2. Issue references in commit messages — fetch via `gh`
3. A path the user passed as argument
4. If nothing found, ask. If no spec exists, skip the Spec axis.

### 3. Identify the standards sources

Collect from:
- `CLAUDE.md`, `CONTEXT.md`
- `.pge/config/repo-profile.md`
- `docs/adr/`
- Linter/formatter configs (note but don't re-check what tooling enforces)
- `CONTRIBUTING.md`, `STYLE.md` if present

### 4. Spawn three sub-agents in parallel

**Standards agent brief:**
> Read the standards docs. Read the diff. Report every place the diff violates a documented standard. Cite the standard (file + rule). Distinguish hard violations from judgement calls. Skip anything tooling enforces. Under 400 words.

**Spec agent brief:**
> Read the spec. Read the diff. Report: (a) requirements missing or partial; (b) behaviour not asked for (scope creep); (c) requirements where implementation looks wrong. Quote the spec line for each finding. Under 400 words.

**Simplicity agent brief:**
> Read the diff. For NEW code only (not pre-existing), flag: deep nesting (3+), long functions (50+ lines), generic names, dead code, unnecessary abstractions (single call site), over-engineered patterns (factory-for-factory, strategy-with-one-strategy), speculative flexibility (config for one value, abstract base with one impl). For each finding: file:line, signal, concrete "do this instead". Skip if simpler version would be harder to understand. Under 400 words.

### 5. Aggregate

Present three reports under `## Standards`, `## Spec`, and `## Simplicity` headings. Do not merge or rerank — the three axes stay separate.

End with:
```
## Summary
- Standards: <N findings> (critical: X, advisory: Y)
- Spec: <N findings> (missing: X, creep: Y, wrong: Z)
- Simplicity: <N findings> (high-value: X, optional: Y)
- Worst issue: <one-line description or "none">
```
