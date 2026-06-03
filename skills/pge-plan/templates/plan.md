# Plan: <title>

This is a minimum contract scaffold, not a fixed prose template. Keep simple plans short. Add optional sections only when they help `pge-exec` execute or help review detect scope drift.

## schema_version: plan.v2

## source_contract_check

Validate the upstream research/input before planning proceeds.

- Source: <path to research brief, upstream doc, or description>
- Intent confirmed: <yes — quote or reference research.v3 goal / current source semantics / no — gap>
- Scope explicit: <yes — in/out boundaries clear / no — gap>
- Success shape usable: <yes — observable and verifiable / no — gap>
- Decision: CONTINUE_TO_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO | BLOCKED
- Rationale: <one line explaining the decision>

## selected_approach

- Approach: <what to do — imperative summary>
- Rationale: <why this follows from research evidence and repo reality>
- Basis: <research decision ID, evidence, or repo convention>

## rejected_approaches

- <approach name>: <why rejected — evidence or reasoning>

## goal

<Target outcome translated from research.v3 goal or current source goal semantics>

## non_goals

- <scope that must not be implemented, with rationale>

## necessary_context

- <only context pge-exec / Generator needs to execute without guessing>

## target_areas

- <file or module> — reason: <why it will be touched>

## forbidden_areas

- <file, module, behavior, or scope area exec must not touch> — reason: <why excluded>

## issues

`## issues` is an Execution Index, not full issue body storage. Full issue contracts live in `issues/Ixxx.md` using `skills/pge-plan/templates/issue.md`.

| ID | File | Title | State | Depends On | Verification Coupling | Execution Type | Security | Parallel Hint |
|---|---|---|---|---|---|---|---|---|
| I001 | `issues/I001.md` | <short title> | READY_FOR_EXECUTE | none | independent | AFK | no | sequential base |

Required index fields: `ID`, `File`, `Title`, `State`, `Depends On`, `Verification Coupling`, `Execution Type`, and `Security`.

Do not embed full executable issue bodies in `plan.md`. If a selected source has embedded issue bodies, fast-adopt upgrades them into `issues/Ixxx.md` before Final Plan Gate can pass.

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

## plan_gate_inputs

This section is required for MEDIUM/DEEP Architecture Delta Contracts, workflow-contract changes, artifact-schema changes, validation-contract changes, gate/tooling changes, or plans with material forbidden-zone risk. LIGHT plans may omit it when the ordinary Final Plan Gate checklist is sufficient.

### Declared Change Types

- <change_type> - reason: <why this type applies> - target issues: <IDs>

### Required Claims

| Claim ID | Claim | Required By | Evidence Type | Required Shape | Provided Evidence | Status |
|----------|-------|-------------|---------------|----------------|-------------------|--------|
| C1 | <claim the gate must trust> | <change type / issue / acceptance criterion> | code_pointer_set / doc_pointer / command_output / artifact_field / user_statement / negative_boundary / manual_review | <specific shape> | <evidence reference> | satisfied / pending / not_applicable |

### Boundary Checks

| Check ID | Boundary | Rule | Evidence | Future Tool Check | Status |
|----------|----------|------|----------|-------------------|--------|
| B1 | allowed_targets / forbidden_paths / forbidden_semantics / generated_artifacts / route_vocabulary / schema_fields | <rule> | <evidence reference> | changed_files_intersection / section_diff / route_vocab_scan / schema_field_scan / manual_review | pass / pending / not_applicable |

### Validation Reality

- Cheap feedback: <checks useful during implementation>
- Trust gates: <checks/evidence required before review can trust completion>
- Unavailable checks: <checks that cannot run now, with fallback evidence or terminal handling>

## terminal_conditions

| Condition | Gate Verdict | Plan Route | Exec Allowed | Handling |
|-----------|--------------|------------|--------------|----------|
| none | PASS | READY_FOR_EXECUTE | yes | No terminal conditions identified. |
| <missing evidence / ambiguous selector / stale artifact / plan-changing context / human-only decision / unavailable check / unsafe scope expansion> | REVISE / ESCALATE / REJECT | NEEDS_INFO / NEEDS_HUMAN / RETURN_TO_RESEARCH / BLOCKED / no final route until repaired | yes/no | <self-resolve from evidence, clarify until executable, require human decision, or stop before exec> |

## plan_gate

- Verdict: PASS | REVISE | ESCALATE | REJECT
- Exec Allowed: yes | no
- Failed Gate: Contract Completeness | Source Fidelity | Plan Engineering Review | Repo Reality | Execution Readiness | Skill Execution Stability | none
- Failed Criterion: <criterion or "none">
- Evidence: <file:line / artifact / command / user statement / "none">
- Required Repair: <specific repair or "none">
- Rationale: <one sentence>

### Gate Checklist

| Gate | Status | Evidence | Required Repair |
|------|--------|----------|-----------------|
| Contract Completeness | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
| Source Fidelity | PASS / REVISE / ESCALATE / REJECT / SKIP_NOT_APPLICABLE | <evidence> | <repair or none> |
| Plan Engineering Review | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
| Repo Reality | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
| Execution Readiness | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
| Skill Execution Stability | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |

## stop_conditions

<Observable state that means "done". Concrete enough that exec can check without interpretation.>

## route

- plan_route: READY_FOR_EXECUTE | READY_FOR_EXECUTE_WITH_ASSUMPTIONS | RETURN_TO_RESEARCH | NEEDS_INFO | BLOCKED | NEEDS_HUMAN

- Justification: <one line explaining why this route is correct>

## Metadata

- plan_id: <YYYYMMDD-HHMM-slug>
- created_at: <ISO date>
- source_ref: <path to research brief or upstream input>
- fast_adopt: true | false
- source_type: research.v3 | current_prompt | external_plan | claude_plan_mode | docs_exec_plan | mixed
- source_fidelity: PASS | REVISE | ESCALATE | REJECT | SKIP_NOT_APPLICABLE
- task_dir: .pge/tasks-<slug>/

## Handoff To Execute

- Process issues by number starting from Issue 1
- Eligible issues: <list>
- AFK issues: <list>
- HITL issues: <list>
- Issue files: <relative paths from `## issues` index>
- Forbidden areas: <list>
- Necessary context: <short list, or "see ## necessary_context">
- Recommended approach: <summary or "none">
- Compile-coupled / shared-verification groups: <issue groups and safe strategy, or "none">
- Parallel safety: <same working tree allowed | isolated worktrees required | serial verification required>
- Optional risk-triggered checks: <security / public API / schema / performance / none>

## Optional When Useful

### Source Semantics Ledger

For Fast Adopt, include this compact ledger when source fidelity is not obvious from issue-level source refs.

| Source item | Authority | Meaning | Canonical location | Transform |
|---|---|---|---|---|
| <source goal / decision / boundary / step> | source_plan / research / user / repo_evidence / inferred | <semantic interpretation> | <plan section or issue ID> | preserved / operationalized / split / merged / omitted / changed |

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

### Plan Engineering Review

Record when the plan risk/depth needs an explicit record. LIGHT plans may use a compact paragraph, short bullet list, or omit entirely if trivial. MEDIUM/DEEP plans should include this section.

- Depth: LIGHT | MEDIUM | DEEP
- Result: PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO
- Selected Approach: <approach and why it satisfies the inherited problem contract>
- Rejected Approaches: <approaches rejected and why>
- Complexity / Risk Reduction: <how the plan reduces implementation friction and blast radius>
- Scope Drift Check: <why goal/scope/non-goals/constraints are preserved>
- Verification Strategy: <first trustworthy verification point and final evidence>
- Issue Slicing / Coupling: <execution order, dependencies, verification coupling classification, or "N/A — LIGHT">
- Protocol Coherence: <producer/consumer/validator/evidence check when relevant, or "N/A">
- Remaining Findings: <none, or bounded issue fixed before Final Plan Gate>

Closed-loop issue slicing review for MEDIUM/DEEP plans:

| Issue | Issue-local goal | Change | Validation closure | Independent? | Coupling / first trustworthy verification | Review action |
|---|---|---|---|---|---|---|
| I001 | <goal> | <bounded change> | expected + check + evidence present? | yes/no | <none or explicit coupling> | keep / split / merge / rework |

Evidence gathered during Plan exploration (runtime paths, protocol surfaces, coupling hotspots, verification constraints, migration blockers) should be embedded here or in approach rationale when it informs traceable decisions.

### Approach Review Details

#### Scope Challenge
- Minimum change set: <smallest set of changes that achieves the goal>
- Existing code that helps: <what already exists that can be reused>
- Complexity: <why the issue count/file count is necessary, or how it was reduced>

#### Architecture / Verification Assessment
- Boundaries: <component boundaries and coupling>
- Data flow: <key data flows, potential bottlenecks>
- Failure modes: <one realistic failure scenario per risky new/changed path>
- Verification topology: <independent vs coupled checks and first trustworthy verification point>

### Assumptions

- <assumption> — confidence: HIGH|MEDIUM|LOW — reason: <why reasonable> — verification: <how to confirm>

### Quality Check Results

Use one compact record per check or review dimension only when it helps downstream execution or review:

```text
check: <check name>
status: PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO | SKIP_NOT_APPLICABLE
reason: <one sentence explaining the result>
evidence: <file:line citations or semantic evidence rows>
required_plan_changes: <specific changes needed if REWORK_PLAN, or "none">
skip_reason: <required when status is SKIP_NOT_APPLICABLE>
audit_note: <optional; what was decided automatically and why>
```

Optional summary table when it helps:

| Check | Status | Skip Reason | Audit Note |
|------|--------|-------------|------------|
| Source Fidelity | <status> | <reason if skipped> | <note> |
| Plan Engineering Review | <status> | <reason if skipped for LIGHT> | <note> |
| Experience Context Check | <status> | <reason if skipped> | <note> |

### Self-Evaluation

| Question | Classification | Blocking? | Decision |
|----------|---------------|-----------|----------|
| <potential question> | Mechanical / Taste / Core Friction / User Challenge | yes/no | SELF_ANSWERED / ASK_USER / ASSUME_AND_RECORD / DEFER_TO_SLICE / LOCK_IN_ACCEPTANCE / BLOCK_PLAN |
