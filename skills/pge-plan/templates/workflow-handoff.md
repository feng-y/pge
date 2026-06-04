# Workflow Handoff

## Purpose

This file adapts a canonical PGE plan for Claude Code Dynamic Workflow execution.

It is not a replacement for the plan.

## Canonical Source

Read first:

@.pge/tasks-<slug>/plan.md

Use `plan.md` as the source of truth for:
- goal
- non-goals
- scope
- constraints
- forbidden areas
- acceptance criteria
- verification requirements
- stop / terminal conditions
- recorded assumptions, especially when `plan_route` is `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`
- issues and dependencies

## Execution Interpretation

Interpret PGE exec-oriented fields as workflow hints:

- `issues/*` are candidate implementation slices, not a fixed workflow graph.
- `Depends On` is a dependency / verification hint, not mandatory scheduling order.
- `AFK` means low-risk automation candidate.
- `HITL:verify` means stronger verification evidence is required.
- `Security=yes` means independent verification is required.
- `Verification Coupling` must be preserved in final evidence.
- `READY_FOR_EXECUTE_WITH_ASSUMPTIONS` means recorded assumptions must be preserved and reported in `workflow-result.md`.

Do not derive a reusable workflow graph, task DAG, or dependency JSON from this handoff.
Claude Dynamic Workflow owns its task-specific harness and orchestration.

## Workflow Autonomy

The workflow owns orchestration.

It may:
- choose decomposition and parallelism;
- split, merge, or reorder runtime tasks;
- perform additional read-only repo discovery;
- apply bounded local repair.

It must:
- preserve the canonical plan's goal, non-goals, scope, constraints, forbidden areas, acceptance criteria, verification requirements, and stop / terminal conditions;
- preserve recorded assumptions unless evidence breaks them;
- report any issue split, merge, or reorder in the final result;
- stop instead of forcing implementation if plan assumptions break, verification cannot run, or scope must expand.

## Pattern / Budget Hints

Use the canonical plan's acceptance criteria and stop / terminal conditions as the workflow goal boundary.

Prefer the lightest workflow shape that preserves the canonical plan.

Use quick/adversarial checks when the plan contains explicit assumptions or verification-heavy slices.

For meaningful code changes, prefer Claude Code native code-review as an optional adversarial verification pass before writing `workflow-result.md`. Record whether it was used, skipped, or unavailable.

Choose workflow patterns based on the profile and canonical plan:

- For `migration-refactor`: prefer fan-out across callsites/files/tests, isolated worktrees, adversarial review, and merge synthesis. Avoid resource-intensive commands when parallelism is high.
- For `deep-research`: prefer fan-out evidence gathering, source extraction, adversarial claim verification, and cited synthesis.
- For `deep-verification`: identify claims/acceptance criteria first, verify each independently, then synthesize failures and evidence quality.
- For `general-execution`: use the lightest workflow shape that preserves the plan.

Use a bounded token budget if the workflow would otherwise expand aggressively.

Do not use recurring `/loop` behavior for one-shot implementation plans unless explicitly requested.

If no profile is explicit in the plan or launcher context, use `general-execution`.
Do not create a fixed phase graph from these hints.
Native code-review is supporting evidence only. It does not create a shipping route and must not become a required dependency when unavailable.

## Resource / Safety Hints

Use worktrees or isolated execution when modifying code in parallel.

Avoid resource-intensive commands when parallelism is high.

Keep the workflow shape lightweight when a normal Claude Code session could safely complete the plan with less overhead.

## Implementation Notes

During execution, maintain:

.pge/tasks-<slug>/implementation-notes.md

Use it to capture anything the user should know about how the implementation interprets or diverges from the canonical plan:

- Design decisions: choices made where the plan was ambiguous
- Deviations: intentional departures from the plan and why
- Tradeoffs: alternatives considered and why one was chosen
- Open questions: anything the user should confirm or revise

This is a human review surface, not a runtime progress ledger.

## Resume

If this workflow is resumed by Claude Code runtime, continue from the runtime state.

If restarted from artifacts, read existing:

- .pge/tasks-<slug>/implementation-notes.md
- .pge/tasks-<slug>/workflow-result.md

Rules:
- If `workflow-result.md` is `PASS` or `LOCAL_REPAIRED`, do not rerun unless explicitly requested.
- If `workflow-result.md` is `CONFLICT` or `CONTRACT_BROKEN`, report the blocker and recommend `pge-plan` re-entry.
- If `workflow-result.md` is `VERIFICATION_BLOCKED`, report the unavailable verification and request the user/environment decision needed before downstream consumers can trust completion.
- If `workflow-result.md` is `BLOCKED`, classify the blocker as user decision, environment, or plan-contract before recommending the next step.
- If `workflow-result.md` is missing or incomplete, continue from the remaining unverified issue / acceptance mapping using `plan.md` as the source of truth.

## Result

Write the final result to:

.pge/tasks-<slug>/workflow-result.md

Include:
- status
- provenance
- issue mapping
- changed files
- verification evidence
- adversarial review evidence
- acceptance mapping
- local repairs
- confirmed assumptions
- broken assumptions
- unresolved risks
- downstream consumption recommendation
- replan recommendation

Required `workflow-result.md` sections:
- Provenance
- Summary
- Issue mapping
- Changed files
- Verification evidence
- Adversarial review
- Acceptance mapping
- Local repairs applied
- Confirmed assumptions
- Broken assumptions
- Unresolved risks
- Downstream consumption
- Replan recommendation

Allowed status values:

```text
PASS | LOCAL_REPAIRED | BLOCKED | CONFLICT | VERIFICATION_BLOCKED | CONTRACT_BROKEN
```

Minimum provenance fields:

```text
source_plan_path: .pge/tasks-<slug>/plan.md
source_plan_id: <plan Metadata plan_id, or "not_recorded">
source_plan_fingerprint: <sha256 of plan.md at workflow start>
workflow_handoff_path: .pge/tasks-<slug>/workflow-handoff.md
workflow_handoff_fingerprint: <sha256 of workflow-handoff.md at workflow start>
workflow_run_id: <runtime id, timestamp id, or "not_available">
base_ref: <git ref before workflow changes, or "not_available">
head_ref: <git ref after workflow changes, or "working_tree">
changed_diff_fingerprint: <sha256 of reviewed diff, or "not_available">
result_created_at: <ISO timestamp>
```

`workflow-result.md` status is not a `pge-exec` route or a `pge-review` route. It is evidence backflow for the next selected review, replan, ship, or handoff step. Any downstream consumer must use `plan.md` as the alignment source and `workflow-result.md` as execution evidence. `pge-plan` consumes `CONFLICT` / `CONTRACT_BROKEN` only after provenance is present enough to trust the reported blocker.

`Adversarial review` must record whether Claude Code native code-review was used, skipped, or unavailable. If skipped or unavailable, record the reason. This evidence is optional support only and does not create a shipping route or required dependency.
