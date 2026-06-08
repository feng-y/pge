#!/usr/bin/env python3
"""
Smoke-test the raw pge-plan template surfaces.

This validates canonical headings and adapter-boundary expectations on the
checked-in templates themselves, without treating unresolved placeholders as
emitted task artifacts.
"""

from pathlib import Path


REPO_ROOT = Path(__file__).resolve().parent.parent
PLAN_TEMPLATE = REPO_ROOT / "skills/pge-plan/templates/plan.md"
ISSUE_TEMPLATE = REPO_ROOT / "skills/pge-plan/templates/issue.md"
WORKFLOW_TEMPLATE = REPO_ROOT / "skills/pge-plan/templates/workflow-handoff.md"

REQUIRED_PLAN_HEADINGS = [
    "## schema_version: plan.v2",
    "## source_contract_check",
    "## selected_approach",
    "## goal",
    "## non_goals",
    "## necessary_context",
    "## target_areas",
    "## forbidden_areas",
    "## issues",
    "## acceptance",
    "## verification",
    "## evidence_required",
    "## terminal_conditions",
    "## plan_gate",
    "## stop_conditions",
    "## route",
]

REQUIRED_ISSUE_HEADINGS = [
    "## goal",
    "## plan_context",
    "## change",
    "## target_areas",
    "## recommended_approach",
    "## forbidden",
    "## validation",
]

REQUIRED_WORKFLOW_PHRASES = [
    "It is not a replacement for the plan.",
    "Use `plan.md` as the source of truth for:",
    "Issue numbering is the baseline recommended execution order from the canonical plan.",
    "Do not derive a reusable workflow graph, task DAG, or dependency JSON from this handoff.",
    "preserve baseline issue-number order unless `Depends On`, `Verification Coupling`, or stronger evidence justifies equivalent safe regrouping;",
    "preserve hard dependencies, first trustworthy verification points, and serial / isolated-worktree safety rules when regrouping runtime tasks;",
    "`workflow-result.md` status is not a `pge-exec` route or a `pge-review` route.",
]


def assert_contains_lines(text: str, required_lines: list[str], label: str) -> None:
    lines = text.splitlines()
    for required in required_lines:
        assert required in lines, f"{label} missing required line: {required}"


def assert_contains_phrases(text: str, required_phrases: list[str], label: str) -> None:
    for phrase in required_phrases:
        assert phrase in text, f"{label} missing required phrase: {phrase}"


def main() -> None:
    plan_text = PLAN_TEMPLATE.read_text(encoding="utf-8")
    issue_text = ISSUE_TEMPLATE.read_text(encoding="utf-8")
    workflow_text = WORKFLOW_TEMPLATE.read_text(encoding="utf-8")

    assert_contains_lines(plan_text, REQUIRED_PLAN_HEADINGS, "plan template")
    assert "`## issues` is an Execution Index, not full issue body storage." in plan_text
    assert "Do not embed full executable issue bodies in `plan.md`." in plan_text
    assert "`workflow-handoff.md` is a launch adapter, not a second plan" in plan_text

    assert_contains_lines(issue_text, REQUIRED_ISSUE_HEADINGS, "issue template")
    assert "Issue-local proof only." in issue_text
    assert "isolated worktrees required" in issue_text

    assert_contains_phrases(workflow_text, REQUIRED_WORKFLOW_PHRASES, "workflow template")

    print("pge-plan template contract smoke tests passed")


if __name__ == "__main__":
    main()
