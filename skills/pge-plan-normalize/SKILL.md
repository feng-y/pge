---
name: pge-plan-normalize
description: >
  Convert a complete external plan into the canonical
  .pge/tasks-<slug>/plan.md contract without replanning.
argument-hint: "<source-plan-path-or-description>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# PGE Plan Normalize

Convert a high-quality external plan into a canonical `.pge/tasks-<slug>/plan.md` that `pge-exec` can consume.

This is a lossless adapter, not a planning workflow. It maps source structure into the PGE plan contract, records provenance, and stops when conversion would require inventing scope, acceptance, target areas, verification, or architecture.

## Critical Path

1. Read the selected source plan and any directly referenced source-of-truth files.
2. Check execution-critical coverage:
   - goal
   - observable stop condition
   - bounded scope or current phase
   - target areas or unambiguous ownership boundaries
   - acceptance criteria
   - verification or evidence expectation
   - dependencies, or explicit confirmation that dependencies are none
3. Build a coverage table with status `mapped | inferred | missing | conflicting | degraded`.
4. Choose exactly one route:
   - `READY_FOR_EXECUTE`
   - `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`
   - `NEEDS_HUMAN`
   - `BLOCKED`
5. If ready, write `.pge/tasks-<slug>/plan.md` using `skills/pge-plan/templates/plan.md`.
6. Record `source_plan`, `source_kind`, `normalization_only: true`, and every inferred execution-critical assumption.
7. Stop. Do not execute the plan.

## Accepted Inputs

- Claude Code plan mode output
- `docs/exec-plan/` structured execution documents
- reviewed workflow plans with explicit goal, scope, acceptance, and verification
- current conversation plan text only when it is complete enough to map without replanning

Reject vague brainstorms, partial issue notes, contradictory source plans, and docs that require inventing execution-critical fields.

## Route Rules

### `READY_FOR_EXECUTE`

Use only when:
- all execution-critical fields are directly mapped
- only non-critical fields, if any, are inferred
- no conflicts exist

### `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`

Use when:
- any execution-critical field is inferred
- the inference is mechanical and low-discretion
- the canonical plan records the assumption explicitly enough for `pge-exec` to consume without replanning

Any inferred execution-critical field forces this route. Plain `READY_FOR_EXECUTE` is reserved for mapped execution-critical fields.

### `NEEDS_HUMAN`

Use when:
- execution-critical fields are missing
- or resolving them requires a human decision
- and the source is not self-contradictory

### `BLOCKED`

Use when:
- the source conflicts with itself
- semantic ownership is ambiguous
- conversion would require inventing scope, acceptance, target areas, verification, or architecture

## Mapping Rules

- Preserve phase, scope, non-goals, semantic ownership, and success criteria from the source.
- Do not add helpers, flags, cleanup, validation systems, broad refactors, or abstractions unless explicitly authorized by the source or current user.
- Mechanical issue extraction may use source headings, implementation components, rollout phases, or explicitly listed core changes.
- Every generated issue must trace back to source content.
- Source documents remain provenance after normalization; `.pge/tasks-<slug>/plan.md` becomes the execution contract.

## Output Requirements

When writing a canonical plan:
- `plan_route`: `READY_FOR_EXECUTE` or `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`
- at least one issue with `State: READY_FOR_EXECUTE`
- `Stop Condition` present
- `normalization_only: true`
- `source_plan`: source path or `claude_plan_mode`
- `source_kind`: `claude_plan_mode | docs_exec_plan | foreign_workflow_plan | other_structured_plan`
- explicit assumptions when route is `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`

If the source changes later, rerun normalization before execution continues.

## Completion

End with:

```text
## PGE Plan Normalize Result
- route: READY_FOR_EXECUTE | READY_FOR_EXECUTE_WITH_ASSUMPTIONS | NEEDS_HUMAN | BLOCKED
- plan: .pge/tasks-<slug>/plan.md | none
- source_plan: <path-or-description>
- assumptions_recorded: yes | no
- next: pge-exec <task-slug> | human decision | revise source plan
```
