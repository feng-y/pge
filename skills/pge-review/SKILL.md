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
  - Write
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

When review can resolve a matching `.pge/tasks-<slug>/` task directory, it must write its durable output to `.pge/tasks-<slug>/review.md`. That task artifact is the default repair handoff back into `pge-exec`.

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

Treat the selected source as the strongest available contract, not just background context. A contract may be a PGE plan, spec, issue, design document, current prompt, or other structured source that defines goal, scope, acceptance, verification, evidence, route, or downstream handoff semantics.

When the selected source is a PGE plan, extract its contract-bearing fields before review:
- `goal`, `non_goals`, `issues`, `target_areas`, `acceptance`, `verification`, `evidence_required`, `risks`, `stop_conditions`, and route/state vocabulary.
- Any cross-issue verification commands, grep scopes, evidence tables, or manual walkthrough checks.
- Any templates, examples, evals, references, handoffs, or final response/output formats named by the plan or touched by the diff.

When a matching `.pge/tasks-<slug>/research.md` exists beside the plan, read its v2 minimum contract fields (`schema_version`, `intent_framings`, `confirmed_intent`, `scope_contract`, `success_shape`, `upstream_contract`, `evidence`, `ambiguities`, `planning_handoff`, `route`) only as needed to detect semantic drift between original intent, plan, and diff. Legacy fields such as `intent_spec`, `plan_delta`, and `blockers` are compatibility input only; do not treat them as stronger than the current plan/research contract.

If the selected contract declares verification scope or evidence requirements, review must treat them as binding review inputs, not optional author notes. Recursive directory scopes include active calibration surfaces under that directory — `templates/`, `examples`, `evals/`, `references/`, `handoffs/`, and final response/output formats — unless the contract explicitly excludes them.

If the diff changes a contract-bearing surface, also inspect active calibration surfaces that could preserve old behavior: templates, examples, evals, references, handoffs, route/state/verdict definitions, and final response/output formats.

When review resolves a `.pge/tasks-<slug>/` source, set:
- `task_dir: .pge/tasks-<slug>/`
- `artifact_path: .pge/tasks-<slug>/review.md`

Write the final review output there before the final response. This artifact is the durable repair seam for `pge-exec` bounded repair reruns.

### 3. Identify the standards sources

Collect from:
- `CLAUDE.md` as the primary resident rules, plus `AGENTS.md` for repo routing/invariants when present.
- `CONTEXT.md`, `CONTEXT-MAP.md`, or similar domain/context maps when present.
- `.pge/config/*.md`, especially `repo-profile.md` and `docs-policy.md`.
- `docs/adr/` and focused repo docs that declare conventions or architectural decisions.
- `CONTRIBUTING.md`, `STYLE.md`, `STANDARDS.md`, `STYLEGUIDE.md`, or similarly named project standards when present.
- Linter/formatter configs (note but don't re-check what tooling enforces)

Do not treat broad research notes or historical handoffs as standards unless they explicitly define a current convention.

Standards review is semantic, not just lexical. When the diff changes workflow contracts, skill contracts, agent rules, routing, authority, artifact paths, or output formats, check whether the changed contract remains consistent with the current standards sources even when old terms no longer appear.

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

### 4.6 Task Artifact + Exec Repair Contract

Every review finding that could drive follow-up work must be execution-facing, not just reviewer-facing.

When `task_dir` is available, the task artifact must include a provenance block with the minimum repair identity fields:
- `source_run_id`
- `reviewed_head`
- `reviewed_base_ref` or a resolved equivalent base commit identity
- `reviewed_diff_fingerprint` or an equivalent stable diff identity

A task artifact is consumable for bounded repair only when that provenance block is present and all minimum fields resolve to the exact reviewed run/diff. Missing, placeholder, or partial provenance makes the artifact non-consumable for repair; fail closed and require a fresh review artifact instead of best-effort matching.

Required per-finding fields:
- `source`: `standards | semantic_alignment | simplicity | verification`
- `severity`: `Required | Important | Advisory | FYI`
- `scope`: `in-contract | contract-change`
- `bounded_fix`: the smallest concrete bounded repair needed, or `none`
- `evidence`: exact spec/diff/verification citation supporting the finding
- `next_repair_path`: `pge-exec repair review findings for <task-slug>` when `scope: in-contract`; `route upstream to pge-plan` when `scope: contract-change`

Scope classification rules:
- `in-contract`: the fix stays inside the current plan contract and can be rerun as bounded repair work in `pge-exec`
- `contract-change`: fixing it would change the plan contract itself — goal, scope, acceptance, target areas, verification, or non-goals

Default repair path:
- Review findings go back to `pge-exec` as bounded repair input.
- Only `contract-change` findings route upstream to `pge-plan`.

### 5. Spawn three sub-agents in parallel

**Standards agent brief:**
> Read the selected standards sources. Read the diff. Report every place the diff violates a documented current standard. Cite the standard (file + rule). Distinguish hard violations from judgement calls. Skip anything tooling enforces. Do not cite optional or historical docs as binding unless the main review identified them as current. Do not only search for changed terms; check whether changed contracts remain semantically consistent with standards sources, including ownership, routing, authority, artifact paths, and workflow invariants. Label every finding: Required / Important / Advisory / FYI. Under 400 words.

**Semantic Alignment agent brief:**
> Read the selected plan/spec source and any adjacent research intent contract if provided. Treat the selected source's verification, evidence_required, target areas, acceptance, route/state vocabulary, templates/examples/evals/references/handoffs, and final response/output formats as review scope when they are declared by the contract or touched by the diff. Read the diff. Report: (a) plan requirements missing or partial; (b) behaviour not asked for (scope creep); (c) places where the plan no longer appears to preserve the original user/research intent; (d) evidence gaps where the diff may be correct but does not prove the contract; (e) active calibration surfaces that preserve old contract behavior; (f) route/state/verdict vocabulary mismatches between definitions, templates, handoffs, final responses, examples, and evals. Quote the plan/spec/research line for each finding. If no source exists, return "Semantic Alignment axis skipped: no spec or intent source found." Label every finding: Required / Important / Advisory / FYI. Under 400 words.

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

### 6.4 Coherence Pass (triggered)

When the diff changes a semantic contract surface, expand review from diff-local inspection to producer / consumer / validator / evidence coherence checking. This pass is bounded to the changed surface, not the whole repo.

**Trigger surfaces:**
- semantic contracts (skill contracts, handoff schemas, artifact layouts)
- route / state / verdict vocabulary
- public APIs or CLI interfaces
- schemas, manifests, or config consumed by other components
- shared helpers or behavior with downstream consumers

**When triggered, for each changed surface:**

1. Identify the **producer** (what writes or defines the value/contract).
2. Identify the **consumer(s)** (what reads, executes, or depends on it).
3. Identify the **validator** (what accepts, rejects, or gates it).
4. Check the **post-change artifact or behavior as a whole** for the triggered contract — not only the changed lines.
5. Verify that producer output, consumer expectation, and validator acceptance still agree after the change.

**Evidence rules:**
- Grep can support coherence evidence but cannot be the sole proof. A grep hit confirms a string exists; it does not confirm that producer, consumer, and validator still agree semantically.
- The pass must inspect the post-change state of the contract, not only the diff hunks.

**Findings:** Coherence failures become normal review findings using the existing severity model (Required / Important / Advisory / FYI) and repair routing (in-contract / contract-change). A coherence failure where producer and validator disagree on allowed values is typically Required. A coherence failure where documentation lags behind implementation is typically Important.

**Skip condition:** If the diff does not touch any trigger surface, this pass does not run.

### 6.5 Main Cross-Contract Sweep

Before aggregating sub-agent results, main review must do one independent contract-aware sweep. This is not a validator script and not a replacement for sub-agents; it catches cross-file drift that individual axes can miss.

Check:
- Standards source semantic consistency: changed contract ownership, routing, authority, artifact paths, and output formats still align with `CLAUDE.md`, `AGENTS.md`, `README.md`, and selected standards.
- Contract-declared review scope: every plan/spec `verification`, `evidence_required`, cross-issue grep scope, or evidence table was actually reviewed or explicitly marked out of scope with rationale.
- Vocabulary consistency: documented route/state/verdict names are representable in definitions, templates, handoffs, final responses, examples, and evals.
- Calibration drift: active templates, examples, evals, references, and handoffs do not preserve behavior that the diff claims to replace.

Any failure found here becomes a normal review finding under `standards`, `semantic_alignment`, or `verification` with severity based on impact.

### 7. Aggregate

Present four sections under `## Standards`, `## Semantic Alignment`, `## Simplicity`, and `## Verification Story`. Do not merge or rerank the three axes — keep them separate.

When `task_dir` is available, write the final output to `artifact_path` before the final response.

End with:
```
## Review Artifact
- task_dir: .pge/tasks-<slug>/ | not_available
- artifact_path: .pge/tasks-<slug>/review.md | not_available
- review_result: BLOCK_SHIP | NEEDS_FIX | READY_FOR_CHALLENGE | READY_TO_SHIP
- default_repair_path: pge-exec repair review findings for <task-slug> | route upstream to `pge-plan`

## Review Provenance
- source_run_id: <reviewed run_id or not_available>
- reviewed_head: <exact reviewed HEAD commit sha>
- reviewed_base_ref: <exact base ref used for review, or resolved equivalent base commit>
- reviewed_diff_fingerprint: <stable identity for the reviewed diff>

## Exec Repair Contract
| Finding ID | Source | Severity | Scope | Bounded Fix | Evidence | Next Repair Path |
|---|---|---|---|---|---|---|
| <id> | <standards / semantic_alignment / simplicity / verification> | <Required / Important / Advisory / FYI> | <in-contract / contract-change> | <smallest concrete bounded repair or none> | <file:line / diff / verification citation> | <pge-exec repair review findings for <task-slug> / route upstream to `pge-plan`> |

## Review Gate
- route: BLOCK_SHIP | NEEDS_FIX | READY_FOR_CHALLENGE | READY_TO_SHIP
- reason: <one sentence>
- required_before_next: <fixes/evidence or "none">
- next: pge-exec repair review findings for <task-slug> | pge-challenge <task-slug> | ship | route upstream to `pge-plan`

## Summary
- Standards: <N findings> (required: X, important: Y, advisory: Z)
- Semantic Alignment: <N findings> (required: X, important: Y, advisory: Z)
- Simplicity: <N findings> (required: X, important: Y, advisory: Z)
- Verification story: strong | partial | weak
- Worst issue: <one-line description or "none">
```
