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

1. `.pge/tasks-*/plan.md` matching the current branch, task slug, or recent PGE work. Treat `plan.md` as the strongest implementation contract.
2. A path the user passed as argument, including a task directory or a specific plan/spec document.
3. Issue references in commit messages — fetch via `gh` when available.
4. Repo-local spec-like docs that clearly match the branch or task name: `docs/`, `specs/`, `.scratch/`, or `.pge/tasks-*/research.md`. Use research or handoff notes only to recover intent when no plan/spec exists.
5. If nothing specific is found, ask once. If no spec exists, skip the Spec axis and say so.

### 3. Identify the standards sources

Collect from:
- `CLAUDE.md` as the primary resident rules, plus `AGENTS.md` for repo routing/invariants when present.
- `CONTEXT.md`, `CONTEXT-MAP.md`, or similar domain/context maps when present.
- `.pge/config/*.md`, especially `repo-profile.md` and `docs-policy.md`.
- `docs/adr/` and focused repo docs that declare conventions or architectural decisions.
- `CONTRIBUTING.md`, `STYLE.md`, `STANDARDS.md`, `STYLEGUIDE.md`, or similarly named project standards when present.
- Linter/formatter configs (note but don't re-check what tooling enforces)

Do not treat broad research notes or historical handoffs as standards unless they explicitly define a current convention.

### 4. Review Contract

Every finding must carry a severity label:

- **Required** — must be fixed before merge / ship
- **Important** — likely reviewer-blocking unless explicitly deferred with rationale
- **Advisory** — worthwhile improvement, not required
- **FYI** — informational only

Use these labels consistently across all three axes. Avoid unlabeled findings.

### 5. Spawn three sub-agents in parallel

**Standards agent brief:**
> Read the selected standards sources. Read the diff. Report every place the diff violates a documented current standard. Cite the standard (file + rule). Distinguish hard violations from judgement calls. Skip anything tooling enforces. Do not cite optional or historical docs as binding unless the main review identified them as current. Label every finding: Required / Important / Advisory / FYI. Under 400 words.

**Spec agent brief:**
> Read the selected spec source. Read the diff. Report: (a) requirements missing or partial; (b) behaviour not asked for (scope creep); (c) requirements where implementation looks wrong. Quote the spec line for each finding. If no spec source exists, return "Spec axis skipped: no spec source found." Label every finding: Required / Important / Advisory / FYI. Under 400 words.

**Simplicity agent brief:**
> Read the diff. For NEW code only (not pre-existing), flag: deep nesting (3+), long functions (50+ lines), generic names, dead code, unnecessary abstractions (single call site), over-engineered patterns (factory-for-factory, strategy-with-one-strategy), speculative flexibility (config for one value, abstract base with one impl). For each finding: file:line, signal, concrete "do this instead". Skip if simpler version would be harder to understand. Label every finding: Required / Important / Advisory / FYI. Under 400 words.

### 6. Verification Story

Before finalizing the review, inspect the verification evidence behind the diff:

- What tests were run?
- Do those tests actually cover the changed behavior, or just exercise code paths superficially?
- Is there manual verification evidence if the change affects UI / runtime behavior?
- If the author/agent claims "tests pass", is that sufficient to prove the spec was implemented?

Report this as a separate section:

```md
## Verification Story
- Evidence reviewed: <tests / commands / screenshots / none>
- Coverage judgment: strong | partial | weak
- Gaps: <what is still unproven>
```

If the verification story is weak, surface it as a review finding even if the code looks plausible.

### 7. Aggregate

Present four sections under `## Standards`, `## Spec`, `## Simplicity`, and `## Verification Story`. Do not merge or rerank the three axes — keep them separate.

End with:
```
## Summary
- Standards: <N findings> (required: X, important: Y, advisory: Z)
- Spec: <N findings> (required: X, important: Y, advisory: Z)
- Simplicity: <N findings> (required: X, important: Y, advisory: Z)
- Verification story: strong | partial | weak
- Worst issue: <one-line description or "none">
```
