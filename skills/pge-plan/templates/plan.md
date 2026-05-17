# Plan: <title>

This is a minimum contract scaffold, not a fixed prose template. Keep simple plans short. Add optional sections only when they help `pge-exec` execute or help review detect scope drift.

## schema_version: plan.v2

## source_contract_check

Validate the upstream research/input before planning proceeds.

- Source: <path to research brief, upstream doc, or description>
- Intent confirmed: <yes — quote or reference the confirmed_intent / no — gap>
- Scope explicit: <yes — in/out boundaries clear / no — gap>
- Success shape usable: <yes — observable and verifiable / no — gap>
- Decision: CONTINUE_TO_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO
- Rationale: <one line explaining the decision>

## selected_approach

- Approach: <what to do — imperative summary>
- Rationale: <why this follows from research evidence and repo reality>
- Basis: <research decision ID, evidence, or repo convention>

## rejected_approaches

- <approach name>: <why rejected — evidence or reasoning>

## goal

<Target outcome translated from confirmed research intent>

## non_goals

- <scope that must not be implemented, with rationale>

## target_areas

- <file or module> — reason: <why it will be touched>

## issues

### Issue 1: <Title>

- ID: 1
- Title: <short title>
- Scope: <what this issue covers>
- Action: <imperative — what to DO>
- Deliverable: <what must exist when done>
- Target Areas: <exact file paths — Create: path | Modify: path>
- Acceptance Criteria: <checkable conditions>
- Verification Hint: <command or check>
- Verification Type: AUTOMATED | MANUAL | MIXED
- Execution Type: AFK | HITL:verify | HITL:decision | HITL:action
- Test Expectation: <happy path + edge case to test, or "none — [reason]">
- Required Evidence: <what must be shown to prove done>
- Dependencies: <issue IDs or "none">
- Risks: <what could go wrong>
- Security: yes | no
- upstream_decision_refs: <decision IDs from research/upstream, or "none">
- State: READY_FOR_EXECUTE

## acceptance

- <observable criterion that must be true when execution is complete>

### Success Shape → Acceptance + Verification Trace

| Acceptance Criterion | Source | Source Type | Acceptance Trace | Verification / Evidence Trace |
|---------------------|--------|-------------|------------------|-------------------------------|
| <criterion from acceptance section> | <where it comes from> | success_shape / upstream / prompt / technical | <one sentence: why this follows> | <how verification/evidence proves it> |

For LIGHT plans with 1-2 obvious criteria from a clear prompt, replace the table with a single sentence trace (e.g., "All criteria derive directly from the user prompt requesting X, and the verification/evidence section proves those criteria directly.").

## verification

<How to verify the plan as a whole is complete after all issues execute — commands, checks, or manual proof>

## evidence_required

- <what exec must show for review to confirm done>

## risks

- <risk> — impact: <what happens if unresolved> — mitigation: <how to handle>

## stop_conditions

<Observable state that means "done". Concrete enough that exec can check without interpretation.>

## route

<READY_FOR_EXECUTE | RETURN_TO_RESEARCH | NEEDS_INFO | BLOCKED | NEEDS_HUMAN>

Justification: <one line explaining why this route is correct>

## Metadata

- plan_id: <YYYYMMDD-HHMM-slug>
- created_at: <ISO date>
- source_ref: <path to research brief or upstream input>
- task_dir: .pge/tasks-<slug>/

## Handoff To Execute

- Process issues by number starting from Issue 1
- Eligible issues: <list>
- AFK issues: <list>
- HITL issues: <list>
- Upstream decisions to preserve: <decision IDs and short labels, or "none">
- Risks not to ignore: <list>

## Optional When Useful

### Plan Constraints

Authoritative upstream decisions that planning must inherit.

| Decision ID | Decision | Source | Plan handling |
|-------------|----------|--------|---------------|
| D1 | <upstream spec decision> | <research section / upstream path> | inherited as <constraint / issue ref / verification ref> |

### Coverage Audit

| Upstream ID | Requirement/Finding | Covered By | Status |
|-------------|---------------------|------------|--------|
| U1 | <requirement from upstream> | Issue N | covered |
| U2 | <requirement from upstream> | — | gap (reason) |

### Engineering Review Gate

- Depth: LIGHT | MEDIUM | DEEP
- Verdict: PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO
- Step 0 (Scope Challenge): <summary>
- Architecture: <summary or "N/A — LIGHT depth">
- Code Quality: <summary or "N/A — not DEEP">
- Test Coverage: <summary or "N/A — LIGHT depth">
- Verification Story: <how acceptance is proven by verification/evidence>
- Performance: <summary or "N/A — not DEEP">
- Failure Modes: <count identified, count mitigated>
- Semantic Evidence: <count rows recorded>
- ASCII Diagrams: <count or "none required">

### Engineering Review

#### Scope Challenge
- Minimum change set: <smallest set of changes that achieves the goal>
- Existing code that helps: <what already exists that can be reused>
- Complexity: <N files touched, N new abstractions introduced>

#### Architecture Assessment
- Boundaries: <component boundaries and coupling>
- Data flow: <key data flows, potential bottlenecks>
- Failure modes: <one realistic production failure per new codepath>

### Assumptions

- <assumption> — confidence: HIGH|MEDIUM|LOW — reason: <why reasonable> — verification: <how to confirm>

### Quality Gate Results

Use one compact record per gate or gate dimension when it helps downstream execution or review:

```text
gate: <gate name>
status: PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO | SKIP_NOT_APPLICABLE
reason: <one sentence explaining the verdict>
evidence: <file:line citations or semantic evidence rows>
required_plan_changes: <specific changes needed if REWORK_PLAN, or "none">
skip_reason: <required when status is SKIP_NOT_APPLICABLE>
audit_note: <required for automatic decisions — what was decided and why>
rating_before: <1-10 quality rating before the gate ran>
rating_after: <1-10 quality rating after fixes applied>
ten_out_of_ten_bar: <what would make this a 10/10>
```

Optional summary table when it helps:

| Gate | Status | Rating | Skip Reason | Audit Note |
|------|--------|--------|-------------|------------|
| Engineering Review | <status> | <before>→<after> | — | <note> |
| Experience Context | <status> | <before>→<after> | <reason if skipped> | <note> |

### Self-Evaluation

| Question | Classification | Blocking? | Decision |
|----------|---------------|-----------|----------|
| <potential question> | Mechanical / Taste / User Challenge | yes/no | SELF_ANSWERED / ASK_USER / ASSUME_AND_RECORD / BLOCK_PLAN |
