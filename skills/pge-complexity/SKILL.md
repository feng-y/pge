---
name: pge-complexity
version: 0.1.0
description: >
  Report-first complexity and performance-hotspot analysis for Claude Code.
  Finds likely algorithmic, nesting, function-size, and file-size hotspots;
  modifies code only when the user explicitly asks to apply an optimization.
argument-hint: "[path | staged | commit <sha> | diff <base..head> | symbol <name> | chain <entrypoint>] [--apply only when explicitly requested]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Grep
  - Glob
# inspired by: https://github.com/Kappaemme-git/codex-complexity-optimizer
---

# PGE Complexity

Analyze code complexity and likely performance hotspots. Default mode is **report-only**.

This is a utility surface, not a PGE pipeline stage. Use it when the user asks about complexity, performance hotspots, slow code, optimization candidates, nested loops, cyclomatic complexity, staged changes, a specific commit/diff, a feature under development, one runtime chain, or "what should we optimize first?"

## Core Rule

Optimization must preserve correctness. A faster implementation that changes observable behavior, data semantics, ordering guarantees, error handling, security boundaries, or public contracts is not an optimization; it is a behavior change and must be routed as a normal feature/fix with explicit acceptance.

Do not edit code unless the user explicitly asks to implement, apply, optimize, or fix a specific finding.

The default output is a ranked report:

- location: file and approximate line
- signal: why this may be complex or slow
- current complexity: Big-O, structural estimate, or "unknown from static review"
- proposed complexity: expected Big-O / structural shape after the recommended change, or "same Big-O, lower constant / lower memory / clearer control flow"
- recommended change: smallest credible improvement
- expected impact: what should improve and why
- risk: low / medium / high
- correctness invariant: behavior that must remain identical
- tests needed: correctness test, regression fixture, benchmark, profiler, trace replay, query plan, or production metric required before claiming improvement

Scanner output is leads, not proof. Confirm important findings by reading the code and, for performance claims, by measuring when practical.

## Workflow

### 1. Target

Resolve the target before analysis. This is a skill workflow, not a Python command wrapper. Use `git`, `rg`, and code reading to build the analysis context; the local scanner is optional and only provides leads.

Supported target modes:

| Target | Use when | Required context |
|---|---|---|
| path/module | user names a file, dir, package, or module | relevant files, nearby callers, tests |
| staged/index | user asks about staged changes | `git diff --cached --stat`, `git diff --cached`, changed files |
| commit | user asks about one commit | `git show --stat <sha>`, `git show --name-only <sha>`, relevant hunks |
| diff range | user names a range | `git diff --stat <range>`, `git diff --name-only <range>`, relevant hunks |
| development feature | user describes work in progress | dirty diff, touched files, active plan or prompt context |
| symbol | user names a function/class/feature term | `rg <symbol>`, definition, callers, hot loop or allocation sites |
| runtime chain | user names a flow such as request -> parser -> model | entrypoint, transformation steps, terminal consumer, data-size drivers |

For changed-code modes, report against the changed files and emphasize new or touched hotspots. Do not review the whole repo unless the user asks.

Optional helper:

```bash
python3 <this-skill-dir>/scripts/complexity_scan.py <path>
```

Use the helper only after target context is clear. Do not ask the user to use `--staged`, `--ref`, or other script flags; those are not the skill interface. If installed plugin paths differ, locate this skill directory first. The helper is strongest for simple path-level static leads; if it misses the target shape, ignore it and continue from code evidence.

### 2. Universal Analysis Pass

Run this pass for every target mode before target-specific attribution.

For each relevant file, function, module, changed hunk, symbol, or chain step, identify:

| Dimension | Question | Common signals |
|---|---|---|
| **Data-size driver** | What input size controls cost? | `n`, rows, items, groups, requests, files, tokens, candidates, graph edges |
| **Growth shape** | How does cost grow? | `O(1)`, `O(n)`, `O(n log n)`, `O(n*m)`, `O(n^2)`, unknown |
| **Amplification point** | Where does data expand or repeat? | nested loops, fan-out, Cartesian joins, repeated scans, recursion, retries, per-item work |
| **Expensive boundary** | What makes each step costly? | I/O, network, DB query, serialization, sorting, regex, allocation, model/API call |
| **State complexity** | What makes behavior hard to reason about? | mutable shared state, deep branching, long function, mixed responsibilities, hidden cache |
| **Correctness invariant** | What must remain identical? | output, ordering, deduplication, grouping, null/empty behavior, errors, side effects, security |
| **Proof path** | How would we prove a change safe and useful? | unit fixture, regression test, benchmark, trace replay, profiler, query plan, production metric |

Do not recommend an optimization until the data-size driver and correctness invariant are explicit. If growth shape is unknown, say `unknown from static review` rather than guessing.

### 3. Triage

Group findings by risk and likely payoff:

- **P0**: likely quadratic or worse on unbounded input, or repeated expensive work in hot paths
- **P1**: high nesting, long functions, large files, repeated scans, avoidable allocation, or unclear data-flow
- **P2**: readability complexity with unclear performance impact

Prefer concrete code evidence over scanner scores.

Before recommending or applying any optimization, state the correctness invariant:

- same outputs for the same inputs
- same ordering / deduplication / grouping semantics
- same error and edge-case behavior
- same persistence, network, cache, and security side effects
- same public API or wire contract

If the invariant is unknown, report the candidate but do not apply it.

Then add target-specific attribution.

For commit/staged/diff analysis:

- changed files and range
- change attribution: `new`, `touched`, `pre-existing nearby`, or `outside scope`
- whether the change increases complexity risk
- the smallest review comment or fix suggestion

Attribution rules:

- **new**: hotspot is introduced by added lines or a newly added function/file.
- **touched**: hotspot existed, but the diff changed the surrounding loop, branch, allocation, query, data structure, or call path.
- **pre-existing nearby**: hotspot is near the diff but not changed; mention only if it affects review risk.
- **outside scope**: unrelated hotspot found by broad scan; omit unless the user asked for repo-wide analysis.

Attribution procedure:

1. Read the changed files and hunks with `git diff -U0 <range>` or `git diff --cached -U0` for staged work.
2. Map added and modified line ranges per file from hunk headers.
3. If the hotspot line is newly added or inside an added range, mark `new`.
4. If the hotspot predates the diff but the hunk changes the same function, loop, branch, query, allocation, or data-structure operation, mark `touched`.
5. If the hotspot is only near the diff and relevant to review risk, mark `pre-existing nearby`.
6. Otherwise omit it from changed-code reports as `outside scope`.

For symbol analysis:

- definition and direct callers
- whether the symbol is on a hot path or only a utility path
- complexity of the symbol itself and complexity induced in callers
- nearest tests or fixtures

For a runtime chain:

- entrypoint, transformation steps, and terminal consumer
- data size driver at each step (`n`, `groups`, `items`, `rows`, requests, etc.)
- repeated scans, nested expansion, fan-out, allocation, I/O, or query boundary
- the exact step where complexity changes
- proof path: unit fixture, benchmark, trace replay, query plan, profiler, or production metric

Runtime chain output must use this shape:

```md
## Chain Complexity Report
- chain: <entrypoint -> ... -> consumer>
- data-size driver: <n / groups / items / rows / requests / unknown>
- mode: report-only

### Flow
1. <step> — <what happens> — size driver: <...>

### Hotspots
1. <file:line> — <signal>
   - current complexity: <...>
   - proposed complexity: <...>
   - attribution: <new|touched|pre-existing nearby|outside scope>
   - correctness invariant: <what must not change>
   - recommendation: <smallest useful change>
   - tests needed: <proof path>

### Proof Plan
- <benchmark/test/trace/profiler/query plan>
```

### 4. Report

Write the report in the final response unless the user asks for a file artifact.

Recommended shape:

```md
## Complexity Report
- scope: <path | staged | commit | diff | symbol | chain>
- mode: report-only
- scanner: <ran | skipped + reason>

### Best Opportunities
1. <file:line> — <short title>
   - decision: recommended now | needs measurement | defer | do not optimize
   - why this ranks here: <impact/confidence/safety/proof-cost/blast-radius summary>
   - expected gain: <complexity/runtime/memory/readability improvement>
   - implementation checkpoint: <first safe implementation step>
   - correctness gate: <invariant + test that must pass before benchmark>
   - rollback signal: <metric/test/symptom that means revert>
   - files likely touched: <paths>

### Findings
1. <severity> <file:line> — <signal>
   - data-size driver: <n/rows/items/groups/requests/unknown>
   - current complexity: <Big-O/structural estimate/unknown>
   - proposed complexity: <expected shape after change>
   - amplification point: <where cost grows/repeats>
   - expensive boundary: <I/O/query/sort/alloc/etc or none>
   - state complexity: <branching/mutation/mixed responsibilities/etc>
   - attribution: <new|touched|pre-existing nearby|outside scope|not_applicable>
   - correctness invariant: <what must not change>
   - recommendation: <smallest useful change>
   - expected impact: <why it helps>
   - tests needed: <test/benchmark/profile>

### Not Changing
- <areas intentionally left alone>
```

Ranking rubric for Best Opportunities:

- **Impact**: hot path likelihood and data-size driver.
- **Confidence**: code evidence, tests, metrics, profiler, or trace support.
- **Safety**: correctness invariant is clear and behavior surface is narrow.
- **Implementation size**: smallest credible patch is local and reviewable.
- **Proof cost**: correctness and performance can be verified without heavy setup.
- **Blast radius**: public API, persistence, network, cache, security, and ordering risk.

Every finding must explain and evaluate itself. Use `decision` explicitly:

- `recommended now`: low risk, meaningful likely payoff, clear correctness gate.
- `needs measurement`: plausible payoff but requires benchmark/profiler/query plan first.
- `defer`: broad change, unclear payoff, or poor proof path.
- `do not optimize`: likely to hurt correctness/readability, not a hot path, or behavior would change.

### 5. Apply Only On Request

When the user explicitly asks to apply an optimization:

1. Pick one bounded finding unless the user selected several.
2. State the correctness invariant before editing.
3. Build or identify a correctness signal first.
4. Preserve behavior before optimizing structure.
5. Keep the patch local to the hotspot.
6. Run relevant tests before benchmark claims.
7. Run benchmark/profiling only after correctness passes.
8. Report what correctness was verified, what performance was measured, and what remains unverified.

Do not batch speculative optimizations. Do not claim runtime improvement without measurement or a clearly defensible complexity reduction.

## Safety

- Avoid changing public behavior to improve speed.
- If correctness and speed conflict, correctness wins.
- Do not change ordering, grouping, deduplication, null/empty handling, error behavior, retries, persistence, caching, authorization, or security semantics unless the user explicitly asked for that behavior change.
- Avoid replacing straightforward code with clever code unless the complexity win is real and tested.
- Treat algorithmic changes as higher risk than local memoization or avoiding repeated work.
- For database or network hotspots, prefer query/profile evidence over static guesses.
- If no reliable proof path exists, report the optimization candidate but do not apply it by default.
- For staged/commit review, do not rewrite unrelated pre-existing hotspots. Flag them as nearby/pre-existing unless the user explicitly expands scope.
