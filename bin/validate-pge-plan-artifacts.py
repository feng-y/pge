#!/usr/bin/env python3
"""
Validate canonical pge-plan artifacts for shared/high-risk contract invariants.

Usage:
  python3 bin/validate-pge-plan-artifacts.py .pge/tasks-<slug>/plan.md
  python3 bin/validate-pge-plan-artifacts.py .pge/tasks-<slug>/plan.md .pge/tasks-<slug>/workflow-handoff.md
"""

from __future__ import annotations

import json
import re
import sys
from pathlib import Path


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

REQUIRED_ISSUE_COLUMNS = [
    "ID",
    "File",
    "Title",
    "State",
    "Depends On",
    "Verification Coupling",
    "Execution Type",
    "Security",
]

REQUIRED_ISSUE_SECTIONS = [
    "## goal",
    "## plan_context",
    "## change",
    "## target_areas",
    "## recommended_approach",
    "## forbidden",
    "## validation",
]

ALLOWED_PLAN_ROUTES = {
    "READY_FOR_EXECUTE",
    "READY_FOR_EXECUTE_WITH_ASSUMPTIONS",
    "RETURN_TO_RESEARCH",
    "NEEDS_INFO",
    "BLOCKED",
    "NEEDS_HUMAN",
}

ALLOWED_GATE_VERDICTS = {"PASS", "REVISE", "ESCALATE", "REJECT"}
ALLOWED_EXEC_ALLOWED = {"yes", "no"}
ALLOWED_ISSUE_STATES = {"READY_FOR_EXECUTE", "NEEDS_INFO", "BLOCKED", "NEEDS_HUMAN"}
ALLOWED_EXECUTION_TYPES = {"AFK", "HITL:verify", "HITL:decision", "HITL:action"}
ALLOWED_SECURITY_VALUES = {"yes", "no"}

INDEPENDENT_COUPLING_VALUES = {"none", "independent"}
NON_INDEPENDENT_COUPLING_MARKERS = (
    "compile-coupled",
    "shared verification",
    "integration-only",
    "serial verification required",
    "isolated worktree required",
    "isolated worktrees required",
)
SAFE_STRATEGY_MARKERS = (
    "serial verification required",
    "isolated worktree required",
    "isolated worktrees required",
)
VERIFICATION_POINT_MARKERS = (
    "first trustworthy verification point",
    "verification point",
    "until ",
)

REQUIRED_WORKFLOW_HEADINGS = [
    "## Canonical Source",
    "## Execution Interpretation",
    "## Workflow Autonomy",
    "## Result",
]

WORKFLOW_SEMANTIC_REQUIREMENTS = {
    "not_replacement": "It is not a replacement for the plan.",
    "canonical_source_truth": "Use `plan.md` as the source of truth for:",
    "issue_order_baseline": "Issue numbering is the baseline recommended execution order from the canonical plan.",
    "no_dag_derivation": "Do not derive a reusable workflow graph, task DAG, or dependency JSON from this handoff.",
    "preserve_issue_order": "preserve baseline issue-number order unless `Depends On`, `Verification Coupling`, or stronger evidence justifies equivalent safe regrouping;",
    "preserve_dependency_and_safety": "preserve hard dependencies, first trustworthy verification points, and serial / isolated-worktree safety rules when regrouping runtime tasks;",
    "result_status_boundary": "`workflow-result.md` status is not a `pge-exec` route or a `pge-review` route.",
}

EMBEDDED_ISSUE_PATTERNS = [
    r"^###\s+Issue\b",
    r"^\*\*ID:\*\*",
    r"^\*\*Title:\*\*",
    r"^\*\*State:\*\*",
    r"^\*\*Dependencies:\*\*",
    r"^\*\*Execution Type:\*\*",
]

ISSUE_REFERENCE_PATTERN = re.compile(r"I\d+|Issue\s+\d+|\b\d+\b")


def read_text(path: Path) -> str:
    return path.read_text(encoding="utf-8")


def extract_section(lines: list[str], heading: str) -> list[str]:
    start = None
    for index, line in enumerate(lines):
        if line.strip() == heading:
            start = index
            break
    if start is None:
        return []

    end = len(lines)
    for index in range(start + 1, len(lines)):
        if lines[index].startswith("## "):
            end = index
            break
    return lines[start:end]


def extract_table(section_lines: list[str]) -> list[str]:
    table_lines = []
    in_table = False
    for line in section_lines:
        if line.strip().startswith("|"):
            in_table = True
            table_lines.append(line.rstrip())
            continue
        if in_table:
            break
    return table_lines


def split_markdown_row(row: str) -> list[str]:
    return [cell.strip() for cell in row.strip().strip("|").split("|")]


def parse_markdown_table(table_lines: list[str]) -> tuple[list[str], list[dict[str, str]]]:
    if len(table_lines) < 3:
        return [], []

    headers = split_markdown_row(table_lines[0])
    rows = []
    for line in table_lines[2:]:
        if not line.strip().startswith("|"):
            continue
        cells = split_markdown_row(line)
        if len(cells) != len(headers):
            continue
        rows.append(dict(zip(headers, cells)))
    return headers, rows


def normalize_issue_reference(value: str) -> int | None:
    match = re.search(r"(\d+)", value)
    if match is None:
        return None
    return int(match.group(1))


def extract_issue_references(value: str) -> list[str]:
    return ISSUE_REFERENCE_PATTERN.findall(value)


def validate_required_plan_headings(text: str, errors: list[str]) -> None:
    lines = text.splitlines()
    for heading in REQUIRED_PLAN_HEADINGS:
        if heading not in lines:
            errors.append(f"Missing required plan heading: {heading}")


def validate_plan_gate_and_route(lines: list[str], errors: list[str], result: dict) -> None:
    route_section = extract_section(lines, "## route")
    plan_gate_section = extract_section(lines, "## plan_gate")

    route_text = "\n".join(route_section)
    plan_gate_text = "\n".join(plan_gate_section)

    route_match = re.search(r"plan_route:\s*([A-Z_]+)", route_text)
    verdict_match = re.search(r"-\s*Verdict:\s*([A-Z_]+)", plan_gate_text)
    exec_allowed_match = re.search(r"-\s*Exec Allowed:\s*(yes|no)", plan_gate_text)

    plan_route = route_match.group(1) if route_match else None
    verdict = verdict_match.group(1) if verdict_match else None
    exec_allowed = exec_allowed_match.group(1) if exec_allowed_match else None

    result["plan_route"] = plan_route
    result["plan_gate_verdict"] = verdict
    result["exec_allowed"] = exec_allowed

    if not plan_route:
        errors.append("Missing plan_route under ## route")
    elif plan_route not in ALLOWED_PLAN_ROUTES:
        errors.append(
            f"Non-canonical plan_route={plan_route} "
            f"(allowed: {', '.join(sorted(ALLOWED_PLAN_ROUTES))})"
        )

    if not verdict:
        errors.append("Missing plan_gate Verdict under ## plan_gate")
    elif verdict not in ALLOWED_GATE_VERDICTS:
        errors.append(
            f"Non-canonical plan_gate Verdict={verdict} "
            f"(allowed: {', '.join(sorted(ALLOWED_GATE_VERDICTS))})"
        )

    if not exec_allowed:
        errors.append("Missing Exec Allowed under ## plan_gate")
    elif exec_allowed not in ALLOWED_EXEC_ALLOWED:
        errors.append(
            f"Non-canonical Exec Allowed={exec_allowed} "
            f"(allowed: {', '.join(sorted(ALLOWED_EXEC_ALLOWED))})"
        )

    if verdict == "PASS" and exec_allowed != "yes":
        errors.append("plan_gate Verdict=PASS requires Exec Allowed: yes")
    if verdict and verdict != "PASS" and exec_allowed == "yes":
        errors.append("Exec Allowed: yes is only valid when plan_gate Verdict=PASS")
    if plan_route in {"READY_FOR_EXECUTE", "READY_FOR_EXECUTE_WITH_ASSUMPTIONS"}:
        if verdict != "PASS" or exec_allowed != "yes":
            errors.append(
                f"Ready route {plan_route} requires plan_gate Verdict=PASS and Exec Allowed: yes"
            )


def validate_issue_file(issue_path: Path, issue_id: str, errors: list[str]) -> None:
    try:
        issue_text = read_text(issue_path)
    except OSError as exc:
        errors.append(f"Failed to read issue file {issue_path}: {exc}")
        return

    issue_lines = issue_text.splitlines()
    if not issue_lines:
        errors.append(f"Issue file is empty: {issue_path}")
        return

    if not issue_lines[0].startswith(f"# {issue_id}:"):
        errors.append(
            f"Issue file {issue_path} does not start with '# {issue_id}:' for index/file consistency"
        )

    for heading in REQUIRED_ISSUE_SECTIONS:
        if heading not in issue_lines:
            errors.append(f"Issue file {issue_path} is missing required section: {heading}")


def validate_dependency_references(
    issue_id: str,
    depends_on: str,
    known_issue_numbers: set[int],
    errors: list[str],
) -> None:
    if depends_on.lower() == "none":
        return

    references = extract_issue_references(depends_on)
    if not references:
        errors.append(
            f"Issue {issue_id} has non-canonical Depends On value with no issue references: {depends_on}"
        )
        return

    unknown = []
    for reference in references:
        normalized = normalize_issue_reference(reference)
        if normalized is None or normalized not in known_issue_numbers:
            unknown.append(reference)

    if unknown:
        errors.append(
            f"Issue {issue_id} Depends On references unknown issue IDs: {', '.join(unknown)}"
        )


def validate_verification_coupling(
    issue_id: str,
    coupling: str,
    known_issue_numbers: set[int],
    errors: list[str],
) -> None:
    normalized = coupling.strip().lower()
    if normalized in INDEPENDENT_COUPLING_VALUES:
        return

    if not any(marker in normalized for marker in NON_INDEPENDENT_COUPLING_MARKERS):
        errors.append(
            f"Issue {issue_id} has non-canonical Verification Coupling value: {coupling}"
        )

    if not any(marker in normalized for marker in SAFE_STRATEGY_MARKERS):
        errors.append(
            f"Issue {issue_id} Verification Coupling is missing a safe execution strategy: {coupling}"
        )

    if not any(marker in normalized for marker in VERIFICATION_POINT_MARKERS):
        errors.append(
            f"Issue {issue_id} Verification Coupling is missing the first trustworthy verification point: {coupling}"
        )

    references = extract_issue_references(coupling)
    unknown = []
    for reference in references:
        normalized_reference = normalize_issue_reference(reference)
        if normalized_reference is None:
            continue
        if normalized_reference not in known_issue_numbers:
            unknown.append(reference)

    if unknown:
        errors.append(
            f"Issue {issue_id} Verification Coupling references unknown issue IDs: {', '.join(unknown)}"
        )


def validate_issue_rows(
    rows: list[dict[str, str]],
    task_dir: Path,
    errors: list[str],
    result: dict,
) -> None:
    known_issue_numbers = {
        normalized
        for normalized in (normalize_issue_reference(row.get("ID", "")) for row in rows)
        if normalized is not None
    }

    checked_issue_files = []
    for row in rows:
        issue_id = row.get("ID", "").strip()
        issue_file_value = row.get("File", "").strip().strip("`")
        state = row.get("State", "").strip()
        depends_on = row.get("Depends On", "").strip()
        coupling = row.get("Verification Coupling", "").strip()
        execution_type = row.get("Execution Type", "").strip()
        security = row.get("Security", "").strip().lower()

        for column in REQUIRED_ISSUE_COLUMNS:
            if not row.get(column, "").strip():
                errors.append(f"Issue row is missing a value for required column: {column}")

        if issue_id and state and state not in ALLOWED_ISSUE_STATES:
            errors.append(
                f"Issue {issue_id} has non-canonical State={state} "
                f"(allowed: {', '.join(sorted(ALLOWED_ISSUE_STATES))})"
            )

        if issue_id and execution_type and execution_type not in ALLOWED_EXECUTION_TYPES:
            errors.append(
                f"Issue {issue_id} has non-canonical Execution Type={execution_type} "
                f"(allowed: {', '.join(sorted(ALLOWED_EXECUTION_TYPES))})"
            )

        if issue_id and security and security not in ALLOWED_SECURITY_VALUES:
            errors.append(
                f"Issue {issue_id} has non-canonical Security={security} "
                f"(allowed: {', '.join(sorted(ALLOWED_SECURITY_VALUES))})"
            )

        if issue_id and depends_on:
            validate_dependency_references(issue_id, depends_on, known_issue_numbers, errors)

        if issue_id and coupling:
            validate_verification_coupling(issue_id, coupling, known_issue_numbers, errors)

        if not issue_id:
            continue
        if not issue_file_value:
            continue

        issue_path = task_dir / issue_file_value
        checked_issue_files.append(issue_file_value)

        if Path(issue_file_value).stem != issue_id:
            errors.append(
                f"Issue index/file mismatch: row ID={issue_id} but File={issue_file_value}"
            )

        if not issue_path.exists():
            errors.append(f"Referenced issue file does not exist: {issue_path}")
            continue

        validate_issue_file(issue_path, issue_id, errors)

    result["checked_issue_files"] = checked_issue_files


def validate_issues_section(lines: list[str], task_dir: Path, errors: list[str], result: dict) -> None:
    issues_section = extract_section(lines, "## issues")
    issues_text = "\n".join(issues_section)

    for pattern in EMBEDDED_ISSUE_PATTERNS:
        if re.search(pattern, issues_text, re.MULTILINE):
            errors.append(
                "Detected embedded issue-body content under ## issues; plan.md must use a compact Execution Index only"
            )
            break

    table_lines = extract_table(issues_section)
    headers, rows = parse_markdown_table(table_lines)
    result["issue_rows_checked"] = len(rows)

    if not headers:
        errors.append("Unable to parse ## issues Execution Index table")
        return

    missing_columns = [column for column in REQUIRED_ISSUE_COLUMNS if column not in headers]
    if missing_columns:
        errors.append(
            "## issues Execution Index is missing required columns: "
            + ", ".join(missing_columns)
        )

    if not rows:
        errors.append("## issues Execution Index has no issue rows")
        return

    validate_issue_rows(rows, task_dir, errors, result)


def validate_workflow_semantics(workflow_text: str, errors: list[str]) -> None:
    for requirement_name, phrase in WORKFLOW_SEMANTIC_REQUIREMENTS.items():
        if phrase not in workflow_text:
            errors.append(
                f"Workflow handoff is missing semantic requirement '{requirement_name}': {phrase}"
            )


def validate_workflow_handoff(workflow_handoff_path: Path, errors: list[str]) -> None:
    try:
        workflow_text = read_text(workflow_handoff_path)
    except OSError as exc:
        errors.append(f"Failed to read workflow handoff {workflow_handoff_path}: {exc}")
        return

    workflow_lines = workflow_text.splitlines()
    for heading in REQUIRED_WORKFLOW_HEADINGS:
        if heading not in workflow_lines:
            errors.append(
                f"Workflow handoff {workflow_handoff_path} is missing required heading: {heading}"
            )

    validate_workflow_semantics(workflow_text, errors)


def validate_plan_artifacts(plan_path: str, workflow_handoff_path: str | None = None) -> dict:
    plan = Path(plan_path)
    if not plan.exists():
        return {
            "valid": False,
            "errors": [f"Plan file not found: {plan_path}"],
            "warnings": [],
        }

    try:
        plan_text = read_text(plan)
    except OSError as exc:
        return {
            "valid": False,
            "errors": [f"Failed to read plan file {plan_path}: {exc}"],
            "warnings": [],
        }

    errors = []
    warnings = []
    result = {
        "plan_path": str(plan),
        "workflow_handoff_checked": None,
        "checked_issue_files": [],
        "issue_rows_checked": 0,
        "plan_route": None,
        "plan_gate_verdict": None,
        "exec_allowed": None,
    }

    plan_lines = plan_text.splitlines()
    task_dir = plan.parent

    validate_required_plan_headings(plan_text, errors)
    validate_plan_gate_and_route(plan_lines, errors, result)
    validate_issues_section(plan_lines, task_dir, errors, result)

    workflow_path = Path(workflow_handoff_path) if workflow_handoff_path else task_dir / "workflow-handoff.md"
    if workflow_handoff_path or workflow_path.exists():
        result["workflow_handoff_checked"] = str(workflow_path)
        if not workflow_path.exists():
            errors.append(f"Workflow handoff file not found: {workflow_path}")
        else:
            validate_workflow_handoff(workflow_path, errors)
    else:
        warnings.append("No workflow-handoff.md found next to plan.md; workflow handoff invariants not checked")

    result.update(
        {
            "valid": len(errors) == 0,
            "errors": errors,
            "warnings": warnings,
        }
    )
    return result


def main() -> None:
    if len(sys.argv) not in {2, 3}:
        print(
            "Usage: validate-pge-plan-artifacts.py <plan.md> [workflow-handoff.md]",
            file=sys.stderr,
        )
        sys.exit(1)

    plan_path = sys.argv[1]
    workflow_handoff_path = sys.argv[2] if len(sys.argv) == 3 else None
    result = validate_plan_artifacts(plan_path, workflow_handoff_path)

    print(json.dumps(result, indent=2))
    sys.exit(0 if result["valid"] else 1)


if __name__ == "__main__":
    main()
