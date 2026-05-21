#!/usr/bin/env python3
"""Lightweight complexity hotspot scanner for pge-complexity.

This script is intentionally heuristic. It produces leads for human/agent review,
not proof of performance problems. Nesting detection is indentation-oriented and
best for Python or consistently formatted code; treat brace-language findings as
lower-confidence leads unless confirmed by reading the code.
"""

from __future__ import annotations

import argparse
import os
import re
from dataclasses import dataclass
from pathlib import Path


SKIP_DIRS = {
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
    "target",
    ".venv",
    "venv",
    "__pycache__",
    "coverage",
}

CODE_EXTS = {
    ".py",
    ".js",
    ".jsx",
    ".ts",
    ".tsx",
    ".go",
    ".java",
    ".kt",
    ".rs",
    ".rb",
    ".php",
    ".c",
    ".cc",
    ".cpp",
    ".h",
    ".hpp",
    ".cs",
    ".swift",
}

FUNC_PATTERNS = [
    re.compile(r"^\s*def\s+([A-Za-z_][\w]*)\s*\("),
    re.compile(r"^\s*async\s+def\s+([A-Za-z_][\w]*)\s*\("),
    re.compile(r"^\s*function\s+([A-Za-z_$][\w$]*)\s*\("),
    re.compile(r"^\s*(?:export\s+)?(?:async\s+)?(?:function\s+)?([A-Za-z_$][\w$]*)\s*=\s*(?:async\s*)?\("),
    re.compile(r"^\s*(?:public|private|protected|static|\s)+[\w<>\[\], ?]+\s+([A-Za-z_][\w]*)\s*\("),
]

LOOP_RE = re.compile(r"\b(for|while|forEach)\b|(?:\.|\b)(?:map|filter|reduce)\s*\(")
BRANCH_RE = re.compile(r"\b(if|elif|else if|switch|case|catch|except)\b")
EXPENSIVE_RE = re.compile(r"\b(sort|sorted|groupby|distinct|join|query|fetch|request|readFile|writeFile)\b")


@dataclass
class Finding:
    severity: str
    path: Path
    line: int
    signal: str
    data_size_driver: str
    current_complexity: str
    proposed_complexity: str
    amplification_point: str
    expensive_boundary: str
    state_complexity: str
    correctness_invariant: str
    recommendation: str
    tests_needed: str


def iter_files(root: Path):
    if root.is_file():
        if root.suffix in CODE_EXTS:
            yield root
        return
    for dirpath, dirnames, filenames in os.walk(root):
        dirnames[:] = [d for d in dirnames if d not in SKIP_DIRS]
        for name in filenames:
            path = Path(dirpath) / name
            if path.suffix in CODE_EXTS:
                yield path


def indentation(line: str) -> int:
    return len(line) - len(line.lstrip(" "))


def function_name(line: str) -> str | None:
    for pattern in FUNC_PATTERNS:
        match = pattern.match(line)
        if match:
            return match.group(1)
    return None


def scan_file(path: Path, root: Path) -> list[Finding]:
    try:
        text = path.read_text(encoding="utf-8", errors="replace")
    except OSError:
        return []

    lines = text.splitlines()
    findings: list[Finding] = []
    rel = path.relative_to(root) if path.is_relative_to(root) else path

    if len(lines) > 800:
        findings.append(
            Finding(
                "P1",
                rel,
                1,
                f"large file ({len(lines)} lines)",
                "lines / responsibilities",
                "navigation and review complexity grows with file size",
                "same runtime complexity; lower navigation and change risk if split by cohesive boundary",
                "mixed responsibilities across one file",
                "none from static scan",
                "module ownership and navigation complexity",
                "public behavior and module ownership remain unchanged",
                "split by domain boundary or extract named helpers only where it reduces navigation cost",
                "review module ownership and run existing tests",
            )
        )

    stack: list[tuple[int, int]] = []
    current_func: tuple[str, int, int] | None = None
    loop_stack: list[tuple[int, int]] = []

    for idx, line in enumerate(lines, start=1):
        stripped = line.strip()
        if not stripped or stripped.startswith(("#", "//", "*")):
            continue

        name = function_name(line)
        if name:
            if current_func:
                func_name, start, _ = current_func
                length = idx - start
                if length > 80:
                    findings.append(
                        Finding(
                            "P1" if length > 140 else "P2",
                            rel,
                            start,
                            f"long function `{func_name}` ({length} lines)",
                            "branches / statements in one function",
                            "branch and state complexity grows with function length",
                            "same runtime complexity unless repeated work is removed; lower control-flow risk",
                            "large single-function control surface",
                            "none from static scan",
                            "long function with mixed phases",
                            "same outputs, side effects, ordering, and error handling for the function's callers",
                            "extract cohesive phases or name intermediate concepts; keep behavior unchanged",
                            "unit or integration test covering the function's call path",
                        )
                    )
            current_func = (name, idx, indentation(line))

        indent = indentation(line)
        while stack and indent <= stack[-1][0]:
            stack.pop()
        while loop_stack and indent <= loop_stack[-1][1]:
            loop_stack.pop()

        if BRANCH_RE.search(stripped) or LOOP_RE.search(stripped):
            stack.append((indent, idx))
            if len(stack) >= 5:
                findings.append(
                    Finding(
                        "P1",
                        rel,
                        idx,
                        f"deep control nesting (depth {len(stack)})",
                        "branch combinations",
                        "cyclomatic/control-flow complexity is high",
                        "same Big-O; lower branch complexity with guard clauses or phase extraction",
                        "nested branch/loop stack",
                        "none from static scan",
                        "deep branch nesting",
                        "same branch behavior, edge-case handling, and side effects",
                        "reduce nesting with guard clauses, smaller phases, or data-driven dispatch",
                        "tests for each branch that remains behaviorally relevant",
                    )
                )

        if LOOP_RE.search(stripped):
            if loop_stack:
                findings.append(
                    Finding(
                        "P0",
                        rel,
                        idx,
                        "nested loop or collection pass may be O(n*m)",
                        "outer input size * inner input size",
                        "possibly O(n*m) or worse depending on input sizes",
                        "often O(n+m) with indexing/pre-grouping, if semantics allow",
                        "nested iteration / repeated scan",
                        "none from static scan",
                        "loop body state depends on surrounding code",
                        "same matching, ordering, deduplication, grouping, and missing-value behavior",
                        "check whether an index, set/map lookup, pre-grouping, or single-pass accumulation can replace repeated scans",
                        "benchmark or fixture with input sizes that exercise the nested path",
                    )
                )
            loop_stack.append((idx, indent))

        if EXPENSIVE_RE.search(stripped) and loop_stack:
            findings.append(
                Finding(
                    "P1",
                    rel,
                    idx,
                    "potential expensive operation inside loop",
                    "loop count * expensive operation cost",
                    "loop cost multiplied by expensive operation cost",
                    "same or lower Big-O depending on batching/caching; lower constant factor at minimum",
                    "per-item expensive work",
                    "sort/query/fetch/request/file operation inside loop",
                    "loop body side effects may constrain batching",
                    "same I/O, caching, retry, ordering, and error semantics",
                    "move invariant work out of the loop, cache results, or batch the operation if behavior allows",
                    "measurement around the loop or benchmark with representative input",
                )
            )

    if current_func:
        func_name, start, _ = current_func
        length = len(lines) + 1 - start
        if length > 80:
            findings.append(
                Finding(
                    "P1" if length > 140 else "P2",
                    rel,
                    start,
                    f"long function `{func_name}` ({length} lines)",
                    "branches / statements in one function",
                    "branch and state complexity grows with function length",
                    "same runtime complexity unless repeated work is removed; lower control-flow risk",
                    "large single-function control surface",
                    "none from static scan",
                    "long function with mixed phases",
                    "same outputs, side effects, ordering, and error handling for the function's callers",
                    "extract cohesive phases or name intermediate concepts; keep behavior unchanged",
                    "unit or integration test covering the function's call path",
                )
            )

    return dedupe(findings)


def dedupe(findings: list[Finding]) -> list[Finding]:
    seen = set()
    result = []
    for finding in findings:
        key = (finding.severity, finding.path, finding.line, finding.signal)
        if key in seen:
            continue
        seen.add(key)
        result.append(finding)
    return result


def main() -> int:
    parser = argparse.ArgumentParser(description="Heuristic complexity hotspot scanner.")
    parser.add_argument("path", nargs="?", default=".", help="file or directory to scan")
    parser.add_argument("--limit", type=int, default=40, help="maximum findings to print")
    args = parser.parse_args()

    root = Path(args.path).resolve()
    scan_root = root if root.is_dir() else root.parent
    files = list(iter_files(root))

    findings: list[Finding] = []
    for file_path in files:
        findings.extend(scan_file(file_path.resolve(), scan_root))

    order = {"P0": 0, "P1": 1, "P2": 2}
    findings.sort(key=lambda f: (order.get(f.severity, 9), str(f.path), f.line))

    print("# Complexity Scan")
    print()
    print(f"- scope: {root}")
    print(f"- files_scanned: {len(files)}")
    print(f"- findings: {len(findings)}")
    print("- mode: heuristic leads, not proof")
    print("- limitation: indentation-oriented nesting; confirm brace-language findings by reading code")
    print()

    if not findings:
        print("No obvious static complexity hotspots found.")
        return 0

    print("## Findings")
    for idx, finding in enumerate(findings[: args.limit], start=1):
        print(f"{idx}. **{finding.severity}** `{finding.path}:{finding.line}` — {finding.signal}")
        print(f"   - data-size driver: {finding.data_size_driver}")
        print(f"   - current complexity: {finding.current_complexity}")
        print(f"   - proposed complexity: {finding.proposed_complexity}")
        print(f"   - amplification point: {finding.amplification_point}")
        print(f"   - expensive boundary: {finding.expensive_boundary}")
        print(f"   - state complexity: {finding.state_complexity}")
        print("   - attribution: not_applicable")
        print(f"   - correctness invariant: {finding.correctness_invariant}")
        print(f"   - recommendation: {finding.recommendation}")
        print(f"   - tests needed: {finding.tests_needed}")
    if len(findings) > args.limit:
        print()
        print(f"... {len(findings) - args.limit} more findings omitted by --limit.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
