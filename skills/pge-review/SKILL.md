---
name: pge-review
description: >
  Review-stage gate for changes since a fixed point. Standards axis checks
  repo conventions; Semantic Alignment axis checks against the originating plan/issue and user intent;
  Simplicity axis flags unnecessary complexity in new code; Verification
  checks whether evidence is strong enough to proceed. Use anytime — not
  limited to pge-exec.
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

Review-stage gate for the diff between `HEAD` and a fixed point:

- **Standards** — does the code conform to this repo's documented conventions?
- **Semantic Alignment** — does the code faithfully implement what was asked for, through the plan contract, without scope drift?
- **Simplicity** — is the new code as simple as it can be without losing behavior?
- **Verification** — is there enough evidence to proceed to prove-it / ship?

The standards, semantic alignment, and simplicity axes run as parallel sub-agents so they don't pollute each other's context. Verification is aggregated by the main review.

`pge-review` is the Review stage in the Research → Plan → Execute → Review → Ship arc. It must return a gate route, not just a list of observations.

Review is responsible for checking:

```text
diff still aligns with original user intent
```

The plan is the strongest implementation contract, but research/user intent remains relevant when judging whether the plan was narrowed, expanded, or conceptually replaced during execution.

## Process

### 1. Pin the fixed point

Use the argument as the fixed point (commit, branch, tag, `main`). If not provided, ask once: "Review against what?"

Capture: `git diff <fixed-point>...HEAD` and `git log <fixed-point>..HEAD --oneline`.

### 2. Identify the alignment source

Look for the originating intent/contract source in this order:

1. `.pge/tasks-*/plan.md` matching the current branch, task slug, or recent PGE work. Treat `plan.md` as the strongest implementation contract.
2. A path the user passed as argument, including a task directory or a specific plan/spec document.
3. Issue references in commit messages — fetch via `gh` when available.
4. Repo-local spec-like docs that clearly match the branch or task name: `docs/`, `specs/`, `.scratch/`, or `.pge/tasks-*/research.md`. Use research or handoff notes only to recover intent when no plan/spec exists.
5. If nothing specific is found, ask once. If no spec/intent source exists, skip the Semantic Alignment axis and say so.

When a matching `.pge/tasks-<slug>/research.md` exists beside the plan, read its minimum contract fields (`intent_spec`, `clarify_status`, `plan_delta`, `blockers`, `evidence`) only as needed to detect semantic drift between original intent, plan, and diff.

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

### 4.5 Review Gate

The review must end with one route:

- `BLOCK_SHIP` — do not proceed to `pge-challenge`, PR, merge, or deploy.
- `NEEDS_FIX` — fix bounded issues, then rerun review.
- `READY_FOR_CHALLENGE` — review passed; proceed to `pge-challenge` for adversarial proof.
- `READY_TO_SHIP` — only when the user explicitly requested review-only shipping readiness and prove-it evidence is already strong.

Route rules:

- Any **Required** finding → `BLOCK_SHIP`.
- Any unresolved **Important** finding → `NEEDS_FIX`, unless explicitly deferred with rationale and owner.
- Verification story `weak` → `BLOCK_SHIP` for behavior changes, `NEEDS_FIX` for docs-only or low-risk changes.
- Semantic Alignment axis skipped because no spec/intent source exists → `NEEDS_FIX` unless the diff is clearly unplanned maintenance and the review states that assumption.
- Standards source missing or stale → `NEEDS_FIX` if the diff touches workflow contracts, agent rules, build config, or shared interfaces.
- Only Advisory/FYI findings with strong or partial verification → `READY_FOR_CHALLENGE`.
- `READY_TO_SHIP` requires no Required/Important findings, strong verification story, and either a passed `pge-challenge` result or equivalent adversarial evidence in the review input.

The default successful route is `READY_FOR_CHALLENGE`, not `READY_TO_SHIP`.

### 5. Spawn three sub-agents in parallel

**Standards agent brief:**
> Read the selected standards sources. Read the diff. Report every place the diff violates a documented current standard. Cite the standard (file + rule). Distinguish hard violations from judgement calls. Skip anything tooling enforces. Do not cite optional or historical docs as binding unless the main review identified them as current. Label every finding: Required / Important / Advisory / FYI. Under 400 words.

**Semantic Alignment agent brief:**
> Read the selected plan/spec source and any adjacent research intent contract if provided. Read the diff. Report: (a) plan requirements missing or partial; (b) behaviour not asked for (scope creep); (c) places where the plan no longer appears to preserve the original user/research intent; (d) evidence gaps where the diff may be correct but does not prove the contract. Quote the plan/spec/research line for each finding. If no source exists, return "Semantic Alignment axis skipped: no spec or intent source found." Label every finding: Required / Important / Advisory / FYI. Under 400 words.

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
- Gate impact: blocks | needs_fix | proceed
```

If the verification story is weak, surface it as a review finding even if the code looks plausible.

### 7. Aggregate

Present four sections under `## Standards`, `## Semantic Alignment`, `## Simplicity`, and `## Verification Story`. Do not merge or rerank the three axes — keep them separate.

End with:
```
## Review Gate
- route: BLOCK_SHIP | NEEDS_FIX | READY_FOR_CHALLENGE | READY_TO_SHIP
- reason: <one sentence>
- required_before_next: <fixes/evidence or "none">
- next: fix and rerun pge-review | pge-challenge <task-slug> | ship

## Summary
- Standards: <N findings> (required: X, important: Y, advisory: Z)
- Semantic Alignment: <N findings> (required: X, important: Y, advisory: Z)
- Simplicity: <N findings> (required: X, important: Y, advisory: Z)
- Verification story: strong | partial | weak
- Worst issue: <one-line description or "none">
```
