#!/usr/bin/env python3
"""
Regression coverage for validate-pge-plan-artifacts.py.

Builds temporary canonical and non-canonical artifacts to verify:
- pass on a minimal current-canonical fixture
- fail on missing plan headings
- fail on bad route/gate vocabulary
- fail on missing issue files
- fail on bad dependency references
- fail on incomplete verification-coupling semantics
- fail on embedded issue-body content under ## issues
- fail on workflow-handoff boundary drift
"""

import importlib.util
import json
import tempfile
from pathlib import Path


VALIDATOR_PATH = Path(__file__).with_name("validate-pge-plan-artifacts.py")


CANONICAL_PLAN = """# Plan: Example\n\n## schema_version: plan.v2\n\n## source_contract_check\n\n- Source: prompt\n- Intent confirmed: yes\n- Scope explicit: yes\n- Success shape usable: yes\n- Decision: CONTINUE_TO_PLAN\n- Rationale: source is sufficient\n\n## selected_approach\n\n- Approach: keep contract shape\n- Rationale: preserve canonical form\n- Basis: repo contract\n\n## goal\n\nValidate plan artifacts mechanically.\n\n## non_goals\n\n- Rewrite planning semantics\n\n## necessary_context\n\n- Validation should remain mechanical\n\n## target_areas\n\n- .pge/tasks-example/plan.md — reason: canonical artifact\n\n## forbidden_areas\n\n- skills/pge-plan/SKILL.md — reason: out of scope for this fixture\n\n## issues\n\n`## issues` is an Execution Index, not full issue body storage. Full issue contracts live in `issues/Ixxx.md` using `skills/pge-plan/templates/issue.md`.\n\n| ID | File | Title | State | Depends On | Verification Coupling | Execution Type | Security | Parallel Hint |\n|---|---|---|---|---|---|---|---|---|\n| I001 | `issues/I001.md` | Validate artifact shape | READY_FOR_EXECUTE | none | independent | AFK | no | sequential base |\n\n## acceptance\n\n- Validator accepts canonical artifact shape\n\n### Success Shape → Acceptance + Verification Trace\n\n| Acceptance Criterion | Source | Source Type | Acceptance Trace | Verification / Evidence Trace |\n|---------------------|--------|-------------|------------------|-------------------------------|\n| Validator accepts canonical artifact shape | prompt | prompt | direct user request | validator + regression test |\n\n## verification\n\nRun the validator and regression test.\n\n## evidence_required\n\n- validator JSON output\n\n## terminal_conditions\n\n| Condition | Gate Verdict | Plan Route | Exec Allowed | Handling |\n|-----------|--------------|------------|--------------|----------|\n| none | PASS | READY_FOR_EXECUTE | yes | No terminal conditions identified. |\n\n## plan_gate\n\n- Verdict: PASS\n- Exec Allowed: yes\n- Failed Gate: none\n- Failed Criterion: none\n- Evidence: fixture\n- Required Repair: none\n- Rationale: canonical fixture is complete\n\n### Gate Checklist\n\n| Gate | Status | Evidence | Required Repair |\n|------|--------|----------|-----------------|\n| Contract Completeness | PASS | fixture | none |\n| Source Fidelity | SKIP_NOT_APPLICABLE | fixture | none |\n| Plan Engineering Review | PASS | fixture | none |\n| Repo Reality | PASS | fixture | none |\n| Execution Readiness | PASS | fixture | none |\n| Skill Execution Stability | PASS | fixture | none |\n\n## stop_conditions\n\nValidator exits successfully for canonical artifacts.\n\n## route\n\n- plan_route: READY_FOR_EXECUTE\n\n- Justification: fixture is fully canonical\n"""


CANONICAL_ISSUE = """# I001: Validate artifact shape\n\n## goal\n\nValidate the canonical fixture.\n\n## plan_context\n\nSupports the fixture plan goal.\n\n## change\n\nNo code changes; fixture exists for validation only.\n\n## target_areas\n\n- Create: issues/I001.md\n\n## recommended_approach\n\nUse the canonical issue template headings.\n\n## forbidden\n\n- Do not expand beyond fixture scope\n\n## validation\n\n- Expected: issue shape matches template requirements\n- Check: validator inspects required sections\n- Evidence: validator JSON output\n"""


CANONICAL_WORKFLOW = """# Workflow Handoff\n\n## Purpose\n\nThis file adapts a canonical PGE plan for Claude Code Dynamic Workflow execution.\n\nIt is not a replacement for the plan.\n\n## Canonical Source\n\nRead first:\n\n@.pge/tasks-<slug>/plan.md\n\nUse `plan.md` as the source of truth for:\n- goal\n- non-goals\n- scope\n- constraints\n- forbidden areas\n- acceptance criteria\n- verification requirements\n- stop / terminal conditions\n- recorded assumptions, especially when `plan_route` is `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`\n- issues and dependencies\n\n## Execution Interpretation\n\nInterpret PGE exec-oriented fields as workflow hints:\n\n- `issues/*` are candidate implementation slices, not a fixed workflow graph.\n- Issue numbering is the baseline recommended execution order from the canonical plan.\n- `Depends On` is a hard dependency / verification constraint, not optional scheduling prose.\n- `Verification Coupling` must be preserved in final evidence, including the first trustworthy verification point and safe execution strategy for any non-independent issue.\n\nDo not derive a reusable workflow graph, task DAG, or dependency JSON from this handoff.\nClaude Dynamic Workflow owns its task-specific harness and orchestration.\n\n## Workflow Autonomy\n\nThe workflow owns orchestration.\n\nIt must:\n- preserve the canonical plan's goal, non-goals, scope, constraints, forbidden areas, acceptance criteria, verification requirements, and stop / terminal conditions;\n- preserve baseline issue-number order unless `Depends On`, `Verification Coupling`, or stronger evidence justifies equivalent safe regrouping;\n- preserve hard dependencies, first trustworthy verification points, and serial / isolated-worktree safety rules when regrouping runtime tasks;\n- stop instead of forcing implementation if plan assumptions break, verification cannot run, or scope must expand.\n\n## Result\n\nWrite the final result to:\n\n.pge/tasks-<slug>/workflow-result.md\n\n`workflow-result.md` status is not a `pge-exec` route or a `pge-review` route.\n"""


def load_validator_module():
    spec = importlib.util.spec_from_file_location(
        "validate_pge_plan_artifacts_module", VALIDATOR_PATH
    )
    if spec is None or spec.loader is None:
        raise RuntimeError(f"Failed to load validator from {VALIDATOR_PATH}")

    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def write_fixture(
    task_dir: Path,
    plan_text=CANONICAL_PLAN,
    issue_text=CANONICAL_ISSUE,
    workflow_text=CANONICAL_WORKFLOW,
    include_issue=True,
    include_workflow=True,
):
    issues_dir = task_dir / "issues"
    issues_dir.mkdir(parents=True, exist_ok=True)

    plan_path = task_dir / "plan.md"
    plan_path.write_text(plan_text, encoding="utf-8")

    if include_issue:
        (issues_dir / "I001.md").write_text(issue_text, encoding="utf-8")

    workflow_path = task_dir / "workflow-handoff.md"
    if include_workflow:
        workflow_path.write_text(workflow_text, encoding="utf-8")

    return plan_path, workflow_path


def assert_invalid_contains(result, expected_substring):
    assert not result["valid"], result
    assert any(expected_substring in error for error in result["errors"]), result


def main():
    module = load_validator_module()

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        plan_path, workflow_path = write_fixture(task_dir)

        valid_result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert valid_result["valid"], json.dumps(valid_result, indent=2)
        assert valid_result["errors"] == [], valid_result
        assert valid_result["warnings"] == [], valid_result
        assert valid_result["plan_route"] == "READY_FOR_EXECUTE", valid_result
        assert valid_result["plan_gate_verdict"] == "PASS", valid_result
        assert valid_result["exec_allowed"] == "yes", valid_result
        assert valid_result["checked_issue_files"] == ["issues/I001.md"], valid_result

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        broken_plan = CANONICAL_PLAN.replace("## source_contract_check\n\n", "")
        plan_path, workflow_path = write_fixture(task_dir, plan_text=broken_plan)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert_invalid_contains(result, "Missing required plan heading: ## source_contract_check")

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        broken_plan = CANONICAL_PLAN.replace(
            "- plan_route: READY_FOR_EXECUTE\n",
            "- plan_route: READY_TO_EXECUTE_SOON\n",
        )
        plan_path, workflow_path = write_fixture(task_dir, plan_text=broken_plan)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert_invalid_contains(result, "Non-canonical plan_route=READY_TO_EXECUTE_SOON")

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        broken_plan = CANONICAL_PLAN.replace("- Verdict: PASS\n", "- Verdict: APPROVED\n")
        plan_path, workflow_path = write_fixture(task_dir, plan_text=broken_plan)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert_invalid_contains(result, "Non-canonical plan_gate Verdict=APPROVED")

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        plan_path, workflow_path = write_fixture(task_dir, include_issue=False)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert_invalid_contains(result, "Referenced issue file does not exist")

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        broken_plan = CANONICAL_PLAN.replace(
            "| I001 | `issues/I001.md` | Validate artifact shape | READY_FOR_EXECUTE | none | independent | AFK | no | sequential base |\n",
            "| I001 | `issues/I001.md` | Validate artifact shape | READY_FOR_EXECUTE | I999 | independent | AFK | no | sequential base |\n",
        )
        plan_path, workflow_path = write_fixture(task_dir, plan_text=broken_plan)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert_invalid_contains(result, "Depends On references unknown issue IDs")

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        broken_plan = CANONICAL_PLAN.replace(
            "| I001 | `issues/I001.md` | Validate artifact shape | READY_FOR_EXECUTE | none | independent | AFK | no | sequential base |\n",
            "| I001 | `issues/I001.md` | Validate artifact shape | READY_FOR_EXECUTE | none | shared verification with Issue 2 | AFK | no | sequential base |\n",
        )
        plan_path, workflow_path = write_fixture(task_dir, plan_text=broken_plan)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert_invalid_contains(result, "Verification Coupling is missing a safe execution strategy")
        assert_invalid_contains(result, "Verification Coupling is missing the first trustworthy verification point")
        assert_invalid_contains(result, "Verification Coupling references unknown issue IDs")

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        plural_safe_plan = CANONICAL_PLAN.replace(
            "| I001 | `issues/I001.md` | Validate artifact shape | READY_FOR_EXECUTE | none | independent | AFK | no | sequential base |\n",
            "| I001 | `issues/I001.md` | Validate artifact shape | READY_FOR_EXECUTE | none | shared verification with Issue 1; first trustworthy verification point: integrated test run; isolated worktrees required | AFK | no | sequential base |\n",
        )
        plan_path, workflow_path = write_fixture(task_dir, plan_text=plural_safe_plan)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert result["valid"], result

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        embedded_issue_plan = CANONICAL_PLAN.replace(
            "## acceptance\n\n- Validator accepts canonical artifact shape\n",
            "**ID:** 1\n**Title:** Embedded issue body\n\n## acceptance\n\n- Validator accepts canonical artifact shape\n",
        )
        plan_path, workflow_path = write_fixture(task_dir, plan_text=embedded_issue_plan)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert_invalid_contains(result, "Detected embedded issue-body content under ## issues")

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        broken_workflow = CANONICAL_WORKFLOW.replace(
            "Do not derive a reusable workflow graph, task DAG, or dependency JSON from this handoff.\n",
            "",
        )
        plan_path, workflow_path = write_fixture(task_dir, workflow_text=broken_workflow)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert_invalid_contains(result, "semantic requirement 'no_dag_derivation'")

    with tempfile.TemporaryDirectory() as tmp_dir:
        task_dir = Path(tmp_dir) / "task"
        broken_workflow = CANONICAL_WORKFLOW.replace(
            "- preserve baseline issue-number order unless `Depends On`, `Verification Coupling`, or stronger evidence justifies equivalent safe regrouping;\n",
            "- regroup runtime tasks when useful.\n",
        )
        plan_path, workflow_path = write_fixture(task_dir, workflow_text=broken_workflow)
        result = module.validate_plan_artifacts(str(plan_path), str(workflow_path))
        assert_invalid_contains(result, "semantic requirement 'preserve_issue_order'")

    print("validate-pge-plan-artifacts regression tests passed")


if __name__ == "__main__":
    main()
