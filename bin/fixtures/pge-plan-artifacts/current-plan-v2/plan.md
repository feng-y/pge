# Plan: Current contract fixture

## schema_version: plan.v2

## source_contract_check

- Source: fixture
- Intent confirmed: yes
- Scope explicit: yes
- Success shape usable: yes
- Decision: CONTINUE_TO_PLAN
- Rationale: fixture exists to exercise the canonical contract

## selected_approach

- Approach: keep a minimal current-contract emitted artifact
- Rationale: this gives validator coverage a repo fixture instead of only temporary test data
- Basis: current `plan.v2` contract surfaces

## rejected_approaches

- Reuse historical `.pge/tasks-*` output as-is: rejected because many sampled artifacts predate the current canonical issue-index contract

## goal

Provide one minimal emitted `plan.v2` fixture that exercises the current canonical plan/issue/workflow contract.

## non_goals

- Migrate historical `.pge/tasks-*` artifacts
- Add implementation behavior beyond validation coverage

## necessary_context

- This fixture is for validator and smoke-test coverage only
- It must reflect the current contract, not historical task output

## target_areas

- `bin/fixtures/pge-plan-artifacts/current-plan-v2/plan.md` — reason: emitted plan fixture
- `bin/fixtures/pge-plan-artifacts/current-plan-v2/issues/I001.md` — reason: emitted issue fixture
- `bin/fixtures/pge-plan-artifacts/current-plan-v2/workflow-handoff.md` — reason: emitted workflow handoff fixture

## forbidden_areas

- `.pge/tasks-*` historical artifacts — reason: do not rewrite history in this fixture pass

## issues

`## issues` is an Execution Index, not full issue body storage. Full issue contracts live in `issues/Ixxx.md` using `skills/pge-plan/templates/issue.md`.

| ID | File | Title | State | Depends On | Verification Coupling | Execution Type | Security | Parallel Hint |
|---|---|---|---|---|---|---|---|---|
| I001 | `issues/I001.md` | Validate current contract fixture | READY_FOR_EXECUTE | none | independent | AFK | no | sequential base |

## acceptance

- The fixture passes the current artifact validator and exercises canonical plan/issue/workflow boundaries.

### Success Shape → Acceptance + Verification Trace

| Acceptance Criterion | Source | Source Type | Acceptance Trace | Verification / Evidence Trace |
|---------------------|--------|-------------|------------------|-------------------------------|
| The fixture passes the current artifact validator and exercises canonical boundaries | fixture purpose | technical | The fixture exists specifically to model the emitted current contract | `validate-pge-plan-artifacts.py` output and regression tests prove the shape |

## verification

Run `python3 bin/validate-pge-plan-artifacts.py bin/fixtures/pge-plan-artifacts/current-plan-v2/plan.md bin/fixtures/pge-plan-artifacts/current-plan-v2/workflow-handoff.md`.

## evidence_required

- validator JSON output for the current fixture
- regression test output covering canonical fixture success

## terminal_conditions

| Condition | Gate Verdict | Plan Route | Exec Allowed | Handling |
|-----------|--------------|------------|--------------|----------|
| none | PASS | READY_FOR_EXECUTE | yes | No terminal conditions identified. |

## plan_gate

- Verdict: PASS
- Exec Allowed: yes
- Failed Gate: none
- Failed Criterion: none
- Evidence: fixture
- Required Repair: none
- Rationale: fixture is intentionally minimal but canonically complete

### Gate Checklist

| Gate | Status | Evidence | Required Repair |
|------|--------|----------|-----------------|
| Contract Completeness | PASS | fixture | none |
| Source Fidelity | SKIP_NOT_APPLICABLE | fixture | none |
| Plan Engineering Review | PASS | fixture | none |
| Repo Reality | PASS | fixture | none |
| Execution Readiness | PASS | fixture | none |
| Skill Execution Stability | PASS | fixture | none |

## stop_conditions

The fixture validates successfully against the current mechanical contract checks.

## route

- plan_route: READY_FOR_EXECUTE

- Justification: fixture intentionally represents ready canonical output

## Metadata

- plan_id: 20260607-0000-current-plan-v2-fixture
- created_at: 2026-06-07T00:00:00Z
- source_ref: bin/fixtures/pge-plan-artifacts/current-plan-v2/plan.md
- fast_adopt: false
- source_type: current_prompt
- source_fidelity: SKIP_NOT_APPLICABLE
- task_dir: bin/fixtures/pge-plan-artifacts/current-plan-v2/
- workflow_handoff_path: bin/fixtures/pge-plan-artifacts/current-plan-v2/workflow-handoff.md

## Handoff To Execute

- Baseline execution order: process ready issues by issue number starting from Issue 1 unless `Depends On` or `Verification Coupling` requires stricter sequencing
- Eligible issues: I001
- AFK issues: I001
- HITL issues: none
- Issue files: `issues/I001.md`
- Forbidden areas: `.pge/tasks-*` historical artifacts
- Necessary context: validator coverage only
- Recommended approach: use this fixture only for contract validation coverage
- Compile-coupled / shared-verification groups: none
- Parallel safety: same working tree allowed
- Optional risk-triggered checks: none

### Optional Dynamic Workflow Backend

- Workflow handoff: bin/fixtures/pge-plan-artifacts/current-plan-v2/workflow-handoff.md
- Launch prompt: 创建一个 Dynamic Workflow 执行 @bin/fixtures/pge-plan-artifacts/current-plan-v2/workflow-handoff.md
- Result artifact: bin/fixtures/pge-plan-artifacts/current-plan-v2/workflow-result.md
- Result consumer: downstream review/replan/ship/handoff step uses `plan.md` as the alignment source and `workflow-result.md` as execution evidence
- Boundary: `workflow-handoff.md` is a launch adapter, not a second plan, workflow graph, task DAG, or dependency JSON
