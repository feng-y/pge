# Evaluator Hard Thresholds

Evaluator default scope is final run-level verification. It validates the composed diff against the canonical plan, including goal, non-goals, issue acceptance, evidence coverage, verification, and implementation logic. Targeted checks may focus on one issue or risk, but they are explicit exceptions and must not become a mandatory per-issue serial gate.

## Automatic Verdicts

These conditions produce automatic verdicts without judgment:

| Condition | Verdict | Reason |
|-----------|---------|--------|
| Any generated deliverable file doesn't exist | BLOCK | "deliverable not produced: <issue_id/path>" |
| Required Evidence missing entirely | RETRY | "required evidence not provided: <which>" |
| Verification Hint, stop condition, integration, or regression command fails (non-zero exit) | RETRY | "verification failed: <command> → <output>" |
| Files modified outside all approved Target Areas (unjustified) | BLOCK | "scope drift: <files> not in target areas" |
| Generator self-reported BLOCKED | — | Do not evaluate. Main handles. |

When a Verification Hint fails, attribute the failure before writing the verdict:
- `issue_under_review`: failure is in the issue's own Target Areas or deliverable.
- `sibling_issue`: failure stack points to another issue's Target Areas or sibling lane changes.
- `newly_added_run_file`: failure stack points to files added elsewhere in the same run.
- `environment_or_manual`: command/tooling/manual prerequisite is unavailable.

For `sibling_issue` or `newly_added_run_file`, return RETRY with the attribution and implicated files. Main must route shared-tree contamination, hold affected issues, repair the source first, and retry verification after the tree is buildable.

## Plan Alignment Check

For final run-level verification:
- Check that the composed diff still satisfies the plan goal.
- Check that non-goals remain untouched.
- Check every generated issue against its Action and Acceptance Criteria.
- Check that cross-issue behavior composes cleanly instead of merely passing isolated checks.
- Check that the implementation logic matches the plan's intended behavior, not only that files changed.

Any plan-changing deviation in goal, scope, target areas, acceptance, verification, or non-goals is BLOCK unless the canonical plan already authorizes it.

## Acceptance Criteria Check

For each criterion in each generated issue's Acceptance Criteria:
- Check independently (read files, run commands, inspect state)
- If ANY single criterion is unmet → RETRY with the specific unmet criterion

Do not batch multiple failures into one RETRY. Report the most critical one first.

## Evidence Quality

Required Evidence must be:
- Present (not "will be added later")
- Concrete (actual output, not "tests pass" without showing which)
- Verifiable (you can reproduce or inspect it)

If evidence is present but weak (e.g., "I ran the tests" without output): RETRY with "provide actual test output as evidence"

## Scope Drift Detection

Compare composed `changed_files` from all Generator candidates against all generated issues' `Target Areas`:
- Files in Target Areas (Create or Modify): expected ✓
- Files NOT in Target Areas but changed: scope drift
- **Justified drift**: Generator recorded it in deviations AND it's clearly necessary for the Action → verdict is RETRY (ask Generator to add the file to a deviation justification or confirm necessity), NOT BLOCK
- **Unjustified drift**: no deviation recorded, or deviation is clearly unrelated to Action → BLOCK

## RETRY Feedback Quality

When issuing RETRY, the `required_fixes` field must be:

**Good:**
- "File src/auth.ts:42 — missing null check on `user.token` before comparison"
- "Test for error path missing: what happens when API returns 500?"
- "Verification command `npm test` exits with code 1: TypeError at line 23"
- "Shared-tree contamination: verification for issue 1 fails in issue 2 file src/search.ts; restore buildability there before retrying issue 1"

**Bad:**
- "Add more tests" (not specific)
- "Fix the code" (not actionable)
- "Improve error handling" (not verifiable)
- "Several issues found" (not bounded)

One specific fix per RETRY. If multiple issues exist, report the most critical one — Generator will re-submit and you'll catch the next one.

Exception: when `failure_attribution` is `sibling_issue` or `newly_added_run_file`, `required_fixes` is a main-orchestrator routing instruction, not necessarily a current-issue Generator patch request. Name the implicated source files and the buildability condition to restore.

## Calibration Notes

From Anthropic: "Out of the box, Claude is a poor QA agent. It identifies legitimate issues, then talks itself into deciding they weren't a big deal."

Counter this by:
- Checking each criterion literally, not "in spirit"
- If a criterion says "file exists" — check the file exists, don't infer it from other evidence
- If a criterion says "returns 200" — run the command, don't trust Generator's claim
- When in doubt between PASS and RETRY: choose RETRY. False positives are cheaper than false negatives.

## Minimum Quality Bar (whole run)

Regardless of depth classification, these are auto-RETRY:
- Unhandled promise rejections or empty catch blocks in new code
- TODO/FIXME/HACK comments in new code (not pre-existing)
- Console.log/print debugging statements left in production code
- Hardcoded secrets or credentials
- Missing return types on public functions (in typed languages)

These are code-smell signals that the implementation is incomplete, not just imperfect.

## Simplification Pressure

Check whether the implementation is disproportionately complex for what it does. Only flag patterns in NEW code from this run — pre-existing complexity is out of scope (Chesterton's Fence).

### Overcomplexity (existing rules)

- If a single function exceeds 50 lines for a task that could be done in 15 → RETRY with "implementation overcomplicated — simplify <function> to essential logic"
- If new abstractions (classes, interfaces, config layers) were introduced that serve only one call site → RETRY with "unnecessary abstraction: <name> has single use, inline it"
- If the implementation introduces a pattern not present elsewhere in the codebase when a simpler existing pattern would work → RETRY with "use existing pattern from <file:line> instead of introducing <new pattern>"

### Structural Complexity Signals

| Signal | Threshold | RETRY message |
|--------|-----------|---------------|
| Deep nesting | 3+ levels in new code | "Flatten <function> — extract guard clauses or helper" |
| Nested ternaries | 2+ chained | "Replace nested ternary at <file:line> with if/else or lookup" |
| Boolean parameter flags | `fn(true, false, true)` pattern | "Replace boolean flags with options object or separate functions" |
| Repeated conditionals | Same check in 3+ places in new code | "Extract repeated condition to named predicate" |

### Naming Signals

| Signal | Threshold | RETRY message |
|--------|-----------|---------------|
| Generic names in new code | `data`, `result`, `temp`, `item`, `val` as variable names | "Use descriptive name for <var> at <file:line> — what does it contain?" |
| Misleading names | Function named `get*` that mutates state | "Rename <function> — name implies read-only but it mutates" |

### Dead Code Signals

| Signal | Threshold | RETRY message |
|--------|-----------|---------------|
| Unused imports introduced | Any | "Remove unused import <name> at <file:line>" |
| Unreachable branches | Code after unconditional return/throw | "Remove unreachable code at <file:line>" |
| Commented-out code blocks | Any in new code | "Remove commented-out code at <file:line> — use version control" |

### LLM-Specific Bloat Signals

| Signal | Threshold | RETRY message |
|--------|-----------|---------------|
| Config layer for one value | Options object with single key ever used | "Inline config value — single-key options object is unnecessary indirection" |
| Abstract base with one impl | Interface with exactly one concrete class | "Remove abstraction — single implementation doesn't justify interface" |
| Defensive null checks on non-nullable | `if (x != null)` where x is guaranteed by types/flow | "Remove unnecessary null check — <x> is guaranteed non-null by <reason>" |
| Unnecessary async wrapper | `async function f() { return await g(); }` | "Remove async/await wrapper — return promise directly" |

### Constraints

- Simplification RETRY must NOT change acceptance criteria outcome — the simpler version must still satisfy the same criteria
- If the "simpler" version would be harder to understand (e.g., removing a helper that names a concept), do not flag
- When in doubt between flagging and not flagging: do not flag. Only flag when the simpler version is obviously correct and sufficient.
- This is NOT about style preference. It's about catching the LLM tendency to bloat code with speculative flexibility.

## Diff-Based Verification

After checking acceptance criteria, review the actual composed diff against the plan issues' Actions:
- Every changed line should trace to an issue Action or a justified deviation
- If the diff includes changes that don't serve the Action (reformatting, comment edits, unrelated "improvements") → RETRY with "diff includes changes unrelated to Action: <specific lines>"
- If the diff is surprisingly large for a small Action, investigate whether the approach is overcomplicated

## Repair Re-evaluation

During repair re-evaluation (after RETRY → Generator fix → re-dispatch Evaluator):
- Diff only the repair-relevant changes against the prior submission
- If Generator's repair diff includes changes unrelated to `required_fixes`, flag as "scope expansion in repair" → RETRY with "repair introduced unrelated changes, revert non-fix modifications"
- Repair should be surgical: fix exactly what was asked, nothing more

## Review Severity Model

Use this severity model for run-level Evaluator findings and final review reports:

| Severity | Meaning | Route effect |
|----------|---------|--------------|
| Critical | Real bug, security risk, data loss risk, broken build/test, or stop-condition failure | Do not PASS/SUCCESS |
| Important | Likely reviewer-blocking issue, missing required regression test, or maintainability issue that will affect this plan's behavior | RETRY/REPAIR if bounded; otherwise PARTIAL |
| Advisory | Style, naming, cleanup, or future improvement that does not affect the current plan outcome | Record only; do not block |

Do not inflate Advisory findings into Important findings. Review cost is justified only when it prevents real regressions, not when it enforces taste.

## Evaluation Depth (scales with plan/run depth)

For **LIGHT** runs (1-2 changed files): single-pass evaluation covering all plan criteria.

For **DEEP** runs (8+ changed files, cross-module, or shared behavior): two-pass evaluation:
1. **Spec compliance pass**: Does the deliverable satisfy the Action, Acceptance Criteria, and Required Evidence? (functional correctness)
2. **Code quality pass**: Is the implementation clean? Proper error handling? Consistent with repo patterns? No obvious tech debt introduced?

If spec compliance fails → RETRY immediately (don't waste time on quality review).
If spec passes but quality fails → RETRY with quality-specific required_fixes.

Depth is inferred from composed changed files and plan risk: ≤3 files = single-pass unless risk triggers apply; >3 files, cross-module work, or shared behavior = two-pass.

## Security-Sensitive Issues

When any generated issue has `Security: yes`:
- **Mandatory checks** (in addition to normal thresholds):
  - No secrets/credentials in committed code (grep for API keys, tokens, passwords)
  - Auth/permission checks present for new endpoints or data access paths
  - Input validation on user-facing parameters
  - No permission downgrade without explicit justification in deviations
- **Stricter threshold**: any security check failure → BLOCK (not RETRY). Security issues don't get repair attempts — they need plan-level rethinking.
- **Adversarial pass** (mandatory for Security: yes): after spec compliance, actively construct failure scenarios (see Adversarial Mode below).

## Adversarial Mode (Security + DEEP issues)

Triggered for: `Security: yes` issues OR DEEP runs (>3 files, cross-module, or shared behavior).

Instead of only checking "does it meet criteria?", actively construct scenarios that break the implementation. Think like a chaos engineer, not a checklist auditor.

**Techniques (from CE adversarial-reviewer):**

1. **Assumption violation** — identify assumptions the code makes and construct inputs that violate them:
   - Data shape: what if the API returns null? What if the list is empty?
   - Timing: what if the operation times out? What if the resource doesn't exist yet?
   - Value range: what if the ID is negative? What if the string is 10MB?

2. **Composition failures** — trace interactions across boundaries:
   - Contract mismatch: caller passes X, callee expects Y
   - Shared state: two paths read/write same state without coordination
   - Error contract divergence: throws type X, catches type Y

3. **Cascade construction** (DEEP only) — build multi-step failure chains:
   - "If A fails → B retries → creates more load on A → A fails more"
   - "Partial write → reader sees incomplete data → makes bad decision"

**Output:** For each adversarial finding, report:
- Scenario: the constructed failure (trigger → path → outcome)
- Confidence: 100 (mechanical from code) / 75 (traceable path) / 50 (depends on unconfirmed conditions)
- Suppress findings below confidence 50 (speculative)

**Adversarial findings → verdict:**
- Confidence 75-100 finding with security impact → BLOCK
- Confidence 75-100 finding without security impact → RETRY
- Confidence 50 findings → record as risk, do not change verdict

## What Evaluator Does NOT Check

Explicit exclusions (these belong to other pipeline stages or future reviewers):

- **Style/naming** — not Evaluator's job. If code works and meets criteria, naming is irrelevant.
- **Architecture decisions** — plan already made these. Evaluator checks execution, not design.
- **Performance optimization** — unless Acceptance Criteria explicitly mentions performance.
- **Test coverage completeness** — Evaluator checks Test Expectation is met, not that coverage is 100%.
- **Documentation quality** — unless the issue Action explicitly includes docs.
- **Alternative implementations** — "could be done better with X" is not a RETRY reason.

## Evaluator vs Final Review Gate

Evaluator is the final run-level verification gate: it checks plan goal/non-goal alignment, generated issue Actions, Target Areas, Acceptance Criteria, Required Evidence, Verification Hints, composed implementation logic, and obvious quality defects that affect the plan outcome. Targeted checks are allowed only when main explicitly dispatches a bounded risk question.

The Final Review Gate is a separate read-only whole-diff review surface: it checks reviewability, blocking code-review findings, simplification opportunities, and whether any security/test specialist pass is needed after Evaluator verification. It does not replace Evaluator's plan-alignment authority.

## Structured Verdict Output

Evaluator verdict must be parseable. Use this exact format in the `evaluator_verdict` message:

```
type: evaluator_verdict
evaluation_scope: final_run | targeted_check
issue_ids: <list>
verdict: PASS | RETRY | BLOCK
confidence: <50-100>
reason: <one sentence>
required_fixes: <specific fix if RETRY, "none" if PASS>
evidence_checked:
  - <what was independently verified>
  - <command run and result>
scope_check: clean | drift_detected | drift_justified
failure_attribution: issue_under_review | sibling_issue | newly_added_run_file | environment_or_manual | not_applicable
implicated_files: <files involved in failed verification, or "none">
plan_alignment: passed | <which goal/non-goal/acceptance/evidence check failed>
adversarial_findings: <count or "not_applicable">
quality_bar: passed | <which check failed>
```

This structured format enables orchestrator to machine-parse verdicts without interpreting prose.

## Confidence Anchors (from CE calibration model)

| Score | Meaning | Evidence Required |
|-------|---------|-------------------|
| 100 | Mechanically certain | Verifiable from code alone, zero interpretation needed |
| 75 | Traceable path | Can construct full execution path from input to outcome |
| 50 | Conditional | Depends on conditions visible but not fully confirmable |
| Below 50 | Suppress | Do not report — speculative |

Apply to both acceptance criteria checks and adversarial findings. A verdict of PASS requires all checked criteria at confidence ≥75.

### Example 1: RETRY — final run behavior does not satisfy plan

```
Evaluation Scope: final_run
Plan Issue 1: "Add rate limiter middleware"
Plan Issue 2: "Wire middleware to /api/users"
Acceptance Criteria: "GET /api/users returns 429 after 50 requests"
Generator Evidence: "Issue 1 created rate-limit.ts; Issue 2 updated routes; tests pass"
Evaluator Action: Run `curl -s -o /dev/null -w "%{http_code}" localhost:3000/api/users` 51 times
Result: Always returns 200 (rate limiter not wired to route)
Verdict: RETRY
Required Fixes: "Rate limiter created but not applied to /api/users route — wire middleware in src/routes/users.ts"
```

### Example 2: PASS — composed run independently verified

```
Evaluation Scope: final_run
Plan Issue 1: "Add --verbose flag to build command"
Acceptance Criteria: "build --verbose produces detailed output"
Generator Evidence: "Flag added to flags.ts, build.ts reads it, test output attached"
Evaluator Action: Run `node cli.js build --verbose`
Result: Output includes "[verbose] Loading config..." lines not present without flag
Verdict: PASS
```

### Example 3: BLOCK — final run scope drift with no justification

```
Evaluation Scope: final_run
Plan Issue 1: "Fix login validation"
Target Areas: "Modify: src/auth/login.ts"
Composed Changed Files: "src/auth/login.ts, src/auth/session.ts, src/db/users.ts"
Candidate Deviations: "none"
Evaluator Action: Compare composed changed_files vs all generated issue Target Areas
Result: 2 files modified outside Target Areas with no recorded deviation
Verdict: BLOCK
Reason: "Scope drift — src/auth/session.ts and src/db/users.ts modified without justification or deviation record"
```

### Example 4: RETRY — final verification command fails

```
Evaluation Scope: final_run
Plan Issue 1: "Add user search endpoint"
Verification Hint: "npm test -- --grep 'user search'"
Generator Evidence: "Endpoint created, tests written"
Evaluator Action: Run `npm test -- --grep 'user search'`
Result: Exit code 1 — "TypeError: Cannot read property 'query' of undefined at line 42"
Verdict: RETRY
Required Fixes: "Test fails with TypeError at search.test.ts:42 — req.query is undefined in test setup, add mock request object"
Failure Attribution: issue_under_review
Implicated Files: search.test.ts
```

### Example 5: RETRY — shared-tree contamination

```
Evaluation Scope: final_run
Plan Issue 1: "Add user search endpoint"
Plan Issue 2: "Add admin report"
Verification Hint: "npm test -- --grep 'user search'"
Generator Evidence: "Endpoint created, tests written"
Evaluator Action: Run `npm test -- --grep 'user search'`
Result: Exit code 1 — compile error in src/admin-report.ts added by issue 2
Verdict: RETRY
Required Fixes: "Shared-tree contamination: user search verification is blocked by src/admin-report.ts from issue 2; restore buildability there before rerunning final verification"
Failure Attribution: sibling_issue
Implicated Files: src/admin-report.ts
```
