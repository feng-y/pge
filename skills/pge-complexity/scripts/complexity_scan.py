#!/usr/bin/env python3
"""Heuristic complexity hotspot scanner for pge-complexity.

This script produces leads for human/agent review, not proof of performance
problems. Python files use AST analysis for common loop patterns; other
languages use textual heuristics. Confirm important findings by reading code.
"""

from __future__ import annotations

import argparse
import ast
import json
import os
import re
from dataclasses import asdict, dataclass
from pathlib import Path
from typing import Iterable


DEFAULT_EXCLUDES = {
    ".git",
    ".hg",
    ".svn",
    ".pge",
    ".claude",
    ".omx",
    "node_modules",
    "vendor",
    "dist",
    "build",
    ".next",
    ".nuxt",
    "coverage",
    "__pycache__",
    ".venv",
    "venv",
    "target",
    ".turbo",
}

TEXT_EXTENSIONS = {
    ".py",
    ".js",
    ".jsx",
    ".ts",
    ".tsx",
    ".mjs",
    ".cjs",
    ".java",
    ".go",
    ".rb",
    ".php",
    ".cs",
    ".cpp",
    ".cc",
    ".c",
    ".h",
    ".hpp",
    ".swift",
}

LOOP_RE = re.compile(r"\b(for|while|forEach)\b|(?:\.|\b)(?:map|filter|reduce|some|every)\s*\(")
MEMBERSHIP_RE = re.compile(r"(\.includes\s*\(|\.indexOf\s*\(|\.find\s*\(|\.findIndex\s*\(|\bin_array\s*\(|\bcontains\s*\()")
SORT_RE = re.compile(r"(\.sort\s*\(|\bsorted\s*\(|\bsort\s*\()")
QUERY_IN_LOOP_RE = re.compile(
    r"\b(fetch|axios\.|request\s*\(|query\s*\(|execute\s*\(|findMany\s*\(|findOne\s*\(|findUnique\s*\(|select\s*\(|where\s*\()\b",
    re.IGNORECASE,
)
RENDER_HINT_RE = re.compile(r"\b(function\s+[A-Z][A-Za-z0-9_]*|const\s+[A-Z][A-Za-z0-9_]*\s*=|export\s+default\s+function\s+[A-Z])")


@dataclass
class Finding:
    path: str
    line: int
    severity: str
    kind: str
    signal: str
    data_size_driver: str
    current_complexity: str
    proposed_complexity: str
    amplification_point: str
    expensive_boundary: str
    state_complexity: str
    attribution: str
    correctness_invariant: str
    recommendation: str
    expected_impact: str
    risk: str
    tests_needed: str
    decision: str


def finding(
    *,
    path: Path,
    root: Path,
    line: int,
    severity: str,
    kind: str,
    signal: str,
    data_size_driver: str,
    current_complexity: str,
    proposed_complexity: str,
    amplification_point: str,
    expensive_boundary: str,
    state_complexity: str,
    correctness_invariant: str,
    recommendation: str,
    expected_impact: str,
    risk: str,
    tests_needed: str,
    decision: str,
) -> Finding:
    return Finding(
        path=rel(path, root),
        line=line,
        severity=severity,
        kind=kind,
        signal=signal,
        data_size_driver=data_size_driver,
        current_complexity=current_complexity,
        proposed_complexity=proposed_complexity,
        amplification_point=amplification_point,
        expensive_boundary=expensive_boundary,
        state_complexity=state_complexity,
        attribution="not_applicable",
        correctness_invariant=correctness_invariant,
        recommendation=recommendation,
        expected_impact=expected_impact,
        risk=risk,
        tests_needed=tests_needed,
        decision=decision,
    )


def iter_files(root: Path, excludes: set[str]) -> Iterable[Path]:
    if root.is_file():
        if root.suffix in TEXT_EXTENSIONS:
            yield root
        return
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in excludes]
        for filename in filenames:
            path = Path(dirpath) / filename
            if path.suffix in TEXT_EXTENSIONS:
                yield path


def read_text(path: Path) -> str | None:
    try:
        return path.read_text(encoding="utf-8")
    except UnicodeDecodeError:
        try:
            return path.read_text(encoding="latin-1")
        except OSError:
            return None
    except OSError:
        return None


def rel(path: Path, root: Path) -> str:
    try:
        return str(path.relative_to(root))
    except ValueError:
        return str(path)


class PythonVisitor(ast.NodeVisitor):
    def __init__(self, path: Path, root: Path) -> None:
        self.path = path
        self.root = root
        self.loop_depth = 0
        self.findings: list[Finding] = []

    def add_loop_finding(self, node: ast.AST) -> None:
        self.findings.append(
            finding(
                path=self.path,
                root=self.root,
                line=getattr(node, "lineno", 1),
                severity="high",
                kind="nested-loop",
                signal="Nested loop may create O(n*m) or worse behavior.",
                data_size_driver="outer input size * inner input size",
                current_complexity="possibly O(n*m) or worse depending on input sizes",
                proposed_complexity="often O(n+m) with indexing/pre-grouping, if semantics allow",
                amplification_point="nested iteration / repeated scan",
                expensive_boundary="none from AST scan",
                state_complexity="loop body state depends on surrounding code",
                correctness_invariant="same matching, ordering, deduplication, grouping, and missing-value behavior",
                recommendation="Check whether a map/set index, grouping, batching, or a single-pass algorithm can replace the inner scan.",
                expected_impact="May remove multiplicative growth on large inputs.",
                risk="medium",
                tests_needed="fixture or benchmark with input sizes that exercise the nested path",
                decision="needs measurement",
            )
        )

    def visit_For(self, node: ast.For) -> None:
        self._visit_loop(node)

    def visit_While(self, node: ast.While) -> None:
        self._visit_loop(node)

    def _visit_loop(self, node: ast.AST) -> None:
        if self.loop_depth >= 1:
            self.add_loop_finding(node)
        self.loop_depth += 1
        self.generic_visit(node)
        self.loop_depth -= 1

    def visit_Compare(self, node: ast.Compare) -> None:
        if self.loop_depth and any(isinstance(op, (ast.In, ast.NotIn)) for op in node.ops):
            self.findings.append(
                finding(
                    path=self.path,
                    root=self.root,
                    line=getattr(node, "lineno", 1),
                    severity="medium",
                    kind="membership-in-loop",
                    signal="Membership check inside a loop can become O(n*m) when the right side is a list or computed sequence.",
                    data_size_driver="loop count * membership collection size",
                    current_complexity="possibly O(n*m)",
                    proposed_complexity="often O(n+m) with a set/dict, if equality semantics allow",
                    amplification_point="repeated membership scan",
                    expensive_boundary="none from AST scan",
                    state_complexity="equality/hashability semantics may constrain replacement",
                    correctness_invariant="same equality, normalization, duplicate, and missing-value semantics",
                    recommendation="Build a set or dict once before the loop when membership equality is stable.",
                    expected_impact="Can remove repeated linear membership scans.",
                    risk="medium",
                    tests_needed="fixture covering duplicates, missing values, and equality edge cases",
                    decision="needs measurement",
                )
            )
        self.generic_visit(node)

    def visit_Call(self, node: ast.Call) -> None:
        name = call_name(node.func)
        lowered = name.lower()
        if self.loop_depth and name in {"sorted", "sort"}:
            self.findings.append(
                finding(
                    path=self.path,
                    root=self.root,
                    line=getattr(node, "lineno", 1),
                    severity="high",
                    kind="sort-in-loop",
                    signal="Sorting inside a loop is often avoidable repeated O(n log n) work.",
                    data_size_driver="loop count * sorted collection size",
                    current_complexity="often O(k*n log n) or worse",
                    proposed_complexity="often O(n log n) or O(k log n) with heap/binary insertion, if semantics allow",
                    amplification_point="repeated sorting",
                    expensive_boundary="sort",
                    state_complexity="comparator or intermediate sorted state may be semantic",
                    correctness_invariant="same ordering, stability, comparator behavior, and intermediate visibility",
                    recommendation="Sort once outside the loop, maintain a heap, or use binary search/insertion if intermediate order is required.",
                    expected_impact="Can remove repeated sort cost.",
                    risk="medium",
                    tests_needed="fixture covering ordering ties and intermediate-state expectations",
                    decision="needs measurement",
                )
            )
        if self.loop_depth and name in {"filter", "map"}:
            self.findings.append(
                finding(
                    path=self.path,
                    root=self.root,
                    line=getattr(node, "lineno", 1),
                    severity="medium",
                    kind="repeated-scan",
                    signal=f"{name}() inside a loop may repeatedly scan a collection.",
                    data_size_driver="loop count * transformed collection size",
                    current_complexity="possibly O(n*m)",
                    proposed_complexity="often O(n+m) with precomputed grouping or combined pass",
                    amplification_point="repeated collection transform",
                    expensive_boundary="none from AST scan",
                    state_complexity="transform side effects or laziness may constrain refactor",
                    correctness_invariant="same transform output, ordering, side effects, and laziness/eagerness semantics",
                    recommendation="Consider precomputing an index/grouping or combining passes.",
                    expected_impact="Can reduce repeated scans and allocations.",
                    risk="medium",
                    tests_needed="fixture covering ordering and side-effect expectations",
                    decision="needs measurement",
                )
            )
        if self.loop_depth and lowered in {"fetch", "request", "query", "execute", "find", "find_one", "find_many", "select", "where"}:
            self.findings.append(
                finding(
                    path=self.path,
                    root=self.root,
                    line=getattr(node, "lineno", 1),
                    severity="high",
                    kind="io-or-query-in-loop",
                    signal="Potential database/API/file operation inside a loop.",
                    data_size_driver="loop count * I/O/query cost",
                    current_complexity="N+1 style behavior or repeated I/O",
                    proposed_complexity="batch/preload/cache if authorization and filtering semantics allow",
                    amplification_point="per-item I/O",
                    expensive_boundary="database/API/file operation",
                    state_complexity="authorization, filtering, ordering, retry, and error behavior constrain batching",
                    correctness_invariant="same auth, filters, tenancy, ordering, pagination, retry, and error semantics",
                    recommendation="Look for N+1 behavior; batch or preload while preserving auth, filters, ordering, and error handling.",
                    expected_impact="Can reduce round trips and tail latency.",
                    risk="high",
                    tests_needed="integration fixture or query/API trace proving identical records and ordering",
                    decision="needs measurement",
                )
            )
        self.generic_visit(node)


def call_name(func: ast.AST) -> str:
    if isinstance(func, ast.Name):
        return func.id
    if isinstance(func, ast.Attribute):
        return func.attr
    return ""


def scan_python(path: Path, root: Path, text: str) -> list[Finding]:
    try:
        tree = ast.parse(text)
    except SyntaxError:
        return scan_text(path, root, text)
    visitor = PythonVisitor(path, root)
    visitor.visit(tree)
    return visitor.findings


def scan_text(path: Path, root: Path, text: str) -> list[Finding]:
    findings: list[Finding] = []
    lines = text.splitlines()
    loop_stack: list[tuple[int, int]] = []
    render_lines = component_ranges(lines) if path.suffix in {".jsx", ".tsx", ".js", ".ts"} else set()

    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith(("//", "#", "*")):
            continue
        indent = len(line) - len(line.lstrip(" "))
        loop_stack = [(level, lno) for level, lno in loop_stack if level < indent + 4]

        if LOOP_RE.search(stripped):
            if loop_stack:
                findings.append(
                    finding(
                        path=path,
                        root=root,
                        line=idx,
                        severity="high",
                        kind="nested-or-callback-loop",
                        signal="Loop or array iteration appears inside another loop/callback.",
                        data_size_driver="outer input size * inner input size",
                        current_complexity="possibly O(n*m)",
                        proposed_complexity="often O(n+m) with indexing/grouping/batching, if semantics allow",
                        amplification_point="nested iteration / callback iteration",
                        expensive_boundary="none from textual scan",
                        state_complexity="callback captures and side effects may constrain refactor",
                        correctness_invariant="same ordering, grouping, deduplication, side effects, and missing-value behavior",
                        recommendation="Check whether indexing, grouping, batching, or a single-pass algorithm can remove repeated scans.",
                        expected_impact="May remove multiplicative growth on large inputs.",
                        risk="medium",
                        tests_needed="fixture or benchmark with large representative collections",
                        decision="needs measurement",
                    )
                )
            loop_stack.append((indent, idx))

        if loop_stack and MEMBERSHIP_RE.search(stripped):
            findings.append(
                finding(
                    path=path,
                    root=root,
                    line=idx,
                    severity="medium",
                    kind="membership-in-loop",
                    signal="Membership/search operation appears inside iterative code.",
                    data_size_driver="loop count * searched collection size",
                    current_complexity="possibly O(n*m)",
                    proposed_complexity="often O(n+m) with Set/Map/precomputed lookup",
                    amplification_point="repeated membership/search scan",
                    expensive_boundary="none from textual scan",
                    state_complexity="equality and object identity may constrain replacement",
                    correctness_invariant="same equality, normalization, duplicate, and ordering behavior",
                    recommendation="Consider a Set/Map or precomputed lookup if equality and ordering semantics allow it.",
                    expected_impact="Can remove repeated linear search.",
                    risk="medium",
                    tests_needed="fixture covering object identity, duplicates, and missing values",
                    decision="needs measurement",
                )
            )

        if loop_stack and SORT_RE.search(stripped):
            findings.append(
                finding(
                    path=path,
                    root=root,
                    line=idx,
                    severity="high",
                    kind="sort-in-loop",
                    signal="Sort appears inside iterative code.",
                    data_size_driver="loop count * sorted collection size",
                    current_complexity="often O(k*n log n)",
                    proposed_complexity="often O(n log n) if sort can move out of loop",
                    amplification_point="repeated sorting",
                    expensive_boundary="sort",
                    state_complexity="comparator or intermediate sorted state may be semantic",
                    correctness_invariant="same ordering, stable sort behavior, and comparator semantics",
                    recommendation="Move sorting out of the loop or use a heap/binary-search strategy if intermediate order is needed.",
                    expected_impact="Can remove repeated sort cost.",
                    risk="medium",
                    tests_needed="fixture covering ties, ordering stability, and intermediate state",
                    decision="needs measurement",
                )
            )

        if loop_stack and QUERY_IN_LOOP_RE.search(stripped):
            findings.append(
                finding(
                    path=path,
                    root=root,
                    line=idx,
                    severity="high",
                    kind="io-or-query-in-loop",
                    signal="Potential database/API/file operation inside a loop.",
                    data_size_driver="loop count * I/O/query cost",
                    current_complexity="N+1 style behavior or repeated I/O",
                    proposed_complexity="batch/preload/cache if semantics allow",
                    amplification_point="per-item I/O",
                    expensive_boundary="database/API/file operation",
                    state_complexity="auth/filter/order/retry/error behavior may constrain batching",
                    correctness_invariant="same auth, filters, tenancy, ordering, pagination, retry, and error behavior",
                    recommendation="Look for N+1 behavior; batch or preload while preserving auth, filters, ordering, and error handling.",
                    expected_impact="Can reduce round trips and tail latency.",
                    risk="high",
                    tests_needed="integration fixture or trace proving identical records and ordering",
                    decision="needs measurement",
                )
            )

        if idx in render_lines and any(token in stripped for token in [".filter(", ".map(", ".sort(", ".reduce("]):
            findings.append(
                finding(
                    path=path,
                    root=root,
                    line=idx,
                    severity="medium",
                    kind="render-derived-work",
                    signal="Collection transform appears in a likely UI component render path.",
                    data_size_driver="render frequency * collection size",
                    current_complexity="recomputed derived data on render",
                    proposed_complexity="same Big-O per derivation, lower repeated render cost with memoization/selectors/virtualization",
                    amplification_point="render churn",
                    expensive_boundary="UI render path",
                    state_complexity="dependency arrays and mutable inputs may constrain memoization",
                    correctness_invariant="same rendered output and update behavior for every semantic input",
                    recommendation="For large collections, consider memoized selectors, server-side derivation, or virtualization.",
                    expected_impact="Can reduce repeated render work for large lists.",
                    risk="medium",
                    tests_needed="UI fixture/profiler check covering data updates and dependency changes",
                    decision="needs measurement",
                )
            )

    return findings


def component_ranges(lines: list[str]) -> set[int]:
    active_until = 0
    interesting: set[int] = set()
    brace_balance = 0
    in_component = False

    for idx, line in enumerate(lines, start=1):
        if RENDER_HINT_RE.search(line):
            in_component = True
            active_until = idx + 120
            brace_balance = 0
        if in_component:
            interesting.add(idx)
            brace_balance += line.count("{") - line.count("}")
            if idx > active_until or (idx > active_until - 110 and brace_balance <= 0 and "}" in line):
                in_component = False
    return interesting


def dedupe(findings: list[Finding]) -> list[Finding]:
    seen: set[tuple[str, int, str]] = set()
    result: list[Finding] = []
    for item in findings:
        key = (item.path, item.line, item.kind)
        if key not in seen:
            seen.add(key)
            result.append(item)
    return result


def severity_rank(item: Finding) -> tuple[int, str, int]:
    order = {"high": 0, "medium": 1, "info": 2}
    return (order.get(item.severity, 3), item.path, item.line)


def render_markdown(findings: list[Finding]) -> str:
    if not findings:
        return "No obvious complexity hotspots found by heuristic scanning.\n"
    lines = ["# Complexity Hotspots", ""]
    for item in findings:
        lines.extend(
            [
                f"## {item.severity.upper()} {item.kind}",
                f"- Location: `{item.path}:{item.line}`",
                f"- Finding: {item.signal}",
                f"- Data-size driver: {item.data_size_driver}",
                f"- Current complexity: {item.current_complexity}",
                f"- Proposed complexity: {item.proposed_complexity}",
                f"- Correctness invariant: {item.correctness_invariant}",
                f"- Recommendation: {item.recommendation}",
                f"- Expected impact: {item.expected_impact}",
                f"- Risk: {item.risk}",
                f"- Tests needed: {item.tests_needed}",
                "",
            ]
        )
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser(description="Scan a repository for likely complexity hotspots.")
    parser.add_argument("root", nargs="?", default=".", help="Repository, directory, or file to scan.")
    parser.add_argument("--format", choices=["markdown", "json"], default="markdown")
    parser.add_argument("--exclude", action="append", default=[], help="Additional directory name to exclude.")
    parser.add_argument("--max-findings", "--limit", dest="max_findings", type=int, default=80)
    args = parser.parse_args()

    root = Path(args.root).resolve()
    excludes = DEFAULT_EXCLUDES | set(args.exclude)
    findings: list[Finding] = []
    files = list(iter_files(root, excludes))

    for path in files:
        text = read_text(path)
        if text is None:
            continue
        if path.suffix == ".py":
            findings.extend(scan_python(path, root, text))
        else:
            findings.extend(scan_text(path, root, text))

    findings = sorted(dedupe(findings), key=severity_rank)[: args.max_findings]
    if args.format == "json":
        print(json.dumps([asdict(item) for item in findings], indent=2))
    else:
        print(render_markdown(findings))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
