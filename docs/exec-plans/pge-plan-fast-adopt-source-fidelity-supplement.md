# PGE Plan Fast Adopt Source Fidelity Supplement

## Goal

Strengthen `pge-plan` Fast Adopt so external plans can be converted into canonical `.pge/tasks-<slug>/plan.md` execution contracts without semantic drift.

This supplement covers Claude Code plan mode output, gstack/Codex-reviewed plans, docs execution plans, and other structured workflow plans. It complements the Plan Responsibility Realignment proposal by preserving Fast Adopt while making source fidelity explicit.

## Core Principle

Fast Adopt is semantic conversion, not replanning.

```text
source plan semantics
→ canonical PGE execution contract
→ pge-exec
```

`pge-plan` may materialize, split, merge, and operationalize source semantics into the canonical PGE plan shape. It must not silently change the source plan's goal, phase/scope, semantic ownership, non-goals, acceptance meaning, or verification burden.

Any semantic change must be recorded as an override and cannot route `READY_FOR_EXECUTE` without current user confirmation or return-to-research resolution.

## Input Semantics, Not Source Fields

Adoption readiness is a semantic judgment, not a field or heading check.

The selected source does not need literal headings such as `goal`, `non_goals`, `target_modules`, or `verification`. It is adoption-ready when its content is semantically sufficient for `pge-plan` to derive, without inventing scope:

- goal and observable success or stop condition
- bounded phase/scope
- implementation decisions and semantic ownership boundaries
- non-goals, exclusions, or narrowed scope limits
- target modules/files or unambiguous ownership areas
- verification expectations or evidence requirements
- enough ordered work structure to derive executable issues

The source semantics may be distributed across prose, tables, bullet lists, issue lists, review comments, or plan-mode output.

The distinction is:

- **Input:** semantic sufficiency; no fixed source fields required.
- **Output:** canonical `.pge/tasks-<slug>/plan.md` fields are required because `pge-exec` consumes them.

If the source lacks semantic sufficiency, Fast Adopt must stop with `NEEDS_INFO` or route through normal `pge-plan` planning. It must not pretend an incomplete source is already a complete execution contract.

## Allowed And Forbidden Transformations

Fast Adopt may:

- convert prose, tables, or checklists into canonical PGE fields
- split one source step into multiple executable issues
- merge multiple source steps into one issue when execution remains faithful
- materialize implicit verification into required evidence when the verification meaning is already present
- derive dependencies, target areas, forbidden areas, and verification coupling from source semantics and repo evidence
- strengthen verification without expanding scope
- correct target paths from repo evidence when the source's semantic ownership remains unchanged

Fast Adopt must not:

- change the goal
- change the phase or bounded scope
- change semantic ownership
- weaken or replace non-goals and exclusions
- introduce helpers, flags, cleanup, abstractions, or validation systems not authorized by the source
- weaken verification or evidence burden
- convert research blocking questions into assumptions
- treat `pge-plan` inferences as source decisions
- turn adoption into a fresh architecture redesign

## Alignment Priority

Fast Adopt must align three inputs at the same time:

```text
current user prompt
external/source plan
research contract
```

Priority order:

1. Current user prompt and trailing constraints are highest priority.
2. Research problem contract governs goal, success shape, scope, non-goals, constraints, Implementation Friction, and Progressive Feasibility when present.
3. External/source plan governs implementation path, phase, semantic ownership, ordering, and source decisions.
4. Repo evidence may correct factual assumptions, but cannot silently change requirements.
5. `pge-plan` inference may fill execution details only; it must not add scope.

Conflict handling:

- If source plan and research conflict on implementation approach, Plan may choose an approach and record rationale.
- If they conflict on goal, scope, success shape, non-goals, constraints, phase, or semantic ownership, Fast Adopt cannot route ready. It must ask the user, route `NEEDS_INFO`, or return to research.
- If current user constraints override either artifact, record the override and apply the latest user constraint.
- If repo evidence proves a source factual claim stale or impossible, record the contradiction and route according to whether the problem contract must change.

## Source Semantics Ledger

Before writing or finalizing the canonical plan, Fast Adopt should build a lightweight Source Semantics Ledger. This may be an internal planning artifact or a compact section in the canonical plan when useful for review.

```md
### Source Semantics Ledger

| Source item | Authority | Meaning | Canonical location | Transform |
|---|---|---|---|---|
| <source goal / decision / boundary / step> | source_plan / research / user / repo_evidence / inferred | <semantic interpretation> | <plan section or issue ID> | preserved / operationalized / split / merged / omitted / changed |
```

Transform meanings:

- `preserved`: semantic meaning carried forward unchanged.
- `operationalized`: semantic meaning unchanged, rewritten into executable PGE fields.
- `split`: one source item became multiple issues or criteria.
- `merged`: multiple source items became one issue or criterion.
- `omitted`: source item intentionally not included; requires reason.
- `changed`: semantic meaning changed; not allowed for ready execution without explicit override resolution.

Every source item that affects goal, scope, phase, ownership, non-goals, verification, evidence, or issue behavior must be covered, explicitly omitted, or escalated. Silent drops are plan failures.

## Source Fidelity Gate

Fast Adopt must prove source fidelity before execution readiness. This can be a dedicated section or a required subsection of Final Plan Gate.

Minimum checks:

```md
### Source Fidelity Gate

- Goal preserved: yes/no
- Success or stop condition preserved or strengthened without scope expansion: yes/no
- Scope and phase boundary preserved: yes/no
- Source implementation decisions preserved: yes/no
- Semantic ownership preserved: yes/no
- Non-goals and exclusions preserved: yes/no
- Target areas derived without invention: yes/no
- Verification and evidence not weakened: yes/no
- No unauthorized helpers, flags, cleanup, abstractions, or validation systems: yes/no
- Every issue traces to source semantics or necessary mechanical execution support: yes/no
- Every material source item is covered, explicitly omitted, or escalated: yes/no
- Research problem contract preserved when present: yes/no/not_applicable
```

Any `no` blocks `READY_FOR_EXECUTE`.

Resolution rules:

- If the issue can be repaired from source text or repo evidence, repair the canonical plan and rerun the affected check.
- If the issue requires a source-scope decision, ask one focused user question or route `NEEDS_INFO`.
- If the issue changes the research problem contract, route `RETURN_TO_RESEARCH` or `NEEDS_HUMAN`.
- If the source itself is incomplete, leave Fast Adopt and continue only through normal planning when allowed by current user intent.

## Issue-Level Source References

For Fast Adopt plans, each ready issue should include source references sufficient to audit semantic alignment.

Recommended shape:

```md
- Source refs:
  - source_plan: <section / paragraph / bullet / table row / review note>
  - research: <field or not_applicable>
  - user_constraint: <current prompt constraint or not_applicable>
```

Issue construction rule:

```text
issue action = executable form of a source semantic item
acceptance = proof form of source success / research success shape
verification = evidence path for acceptance
```

An issue that cannot trace to source semantics, current user constraint, research contract, or necessary mechanical execution support is unauthorized expansion.

## New Content Classification

Any content introduced during conversion must be classified before the plan can route ready.

| New content type | Allowed? | Requirement |
|---|---|---|
| mechanical canonicalization such as IDs, headings, state values, evidence wording | yes | Must not change source meaning |
| repo-evidence-derived path correction | yes | Cite evidence and preserve semantic ownership |
| verification strengthening without scope expansion | yes | Explain why it proves the same acceptance |
| implementation detail intentionally left to exec | yes | Keep out of plan unless contract-relevant |
| new helper, abstraction, flag, cleanup, validation layer, or framework | no by default | Requires explicit source authorization or user confirmation |
| new target area | no by default | Requires repo evidence that it is necessary for the source-owned behavior |
| changed rollout, phase, ownership, or migration shape | no | Requires user confirmation or upstream routing |
| changed goal, scope, success shape, non-goal, or research constraint | no | Requires user confirmation or return to research |

## Plan Gate Integration

Final Plan Gate should include Fast Adopt source fidelity when `fast_adopt: true` or when the selected source is an external plan.

The gate should reject a ready route when:

- source semantics are not traceable into canonical fields
- an issue introduces unreferenced scope
- research problem-contract fields are changed without resolution
- verification is weaker than the source or research success shape requires
- source decisions are omitted without explicit reason
- `pge-plan` inferences are recorded as if they came from the source

`plan_gate Verdict: PASS` and `Exec Allowed: yes` require both execution readiness and source fidelity.

## Final Sanity Pass Integration

The Final Sanity Pass should strengthen these checks for Fast Adopt without restoring the older heavy self-review loop:

1. Goal-backward verification must start from both source plan goal and research goal when present.
2. Upstream coverage must include every material external plan decision and source boundary.
3. Traceability must map source plan items, research contract fields, and current user constraints to canonical plan locations.
4. Spec decision coverage must include source phase, rollout, semantic ownership, architecture direction, non-goals, and verification burden.
5. Consistency check must reject issue scopes that add unreferenced target areas or implementation concepts.
6. Downstream simulation must ask whether Generator could implement the issue without inventing source semantics.

## Success Criteria

This supplement succeeds when:

- CC plan mode output and other workflow plans can still enter PGE through `pge-plan` Fast Adopt.
- Adoption readiness is judged by semantic sufficiency, not literal source headings.
- Canonical PGE output remains strict enough for `pge-exec` to consume.
- Every ready Fast Adopt issue traces back to source semantics, current user constraint, research contract, or mechanical execution support.
- Source plan semantics and research problem contract cannot be silently changed during conversion.
- Any semantic change becomes an explicit override, user question, `NEEDS_INFO`, `NEEDS_HUMAN`, or `RETURN_TO_RESEARCH` route.

## Non-Goals

- Do not add a new workflow stage.
- Do not require external plans to be written in PGE format.
- Do not make Fast Adopt a heavier default template for direct prompt planning.
- Do not require long ledgers for LIGHT tasks when source fidelity is obvious and compactly provable.
- Do not weaken the canonical output fields required by `pge-exec`.
