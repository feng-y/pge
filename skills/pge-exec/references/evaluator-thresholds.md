# Evaluator Hard Thresholds

## Automatic Verdicts

These conditions produce automatic verdicts without judgment:

| Condition | Verdict | Reason |
|-----------|---------|--------|
| Deliverable file doesn't exist | BLOCK | "deliverable not produced" |
| Required Evidence missing entirely | RETRY | "required evidence not provided: <which>" |
| Verification Hint command fails (non-zero exit) | RETRY | "verification failed: <command> → <output>" |
| Files modified outside Target Areas (unjustified) | BLOCK | "scope drift: <files> not in target areas" |
| Generator self-reported BLOCKED | — | Do not evaluate. Main handles. |

## Acceptance Criteria Check

For each criterion in the issue's Acceptance Criteria:
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

Compare `changed_files` from Generator against `Target Areas` from the plan issue:
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

**Bad:**
- "Add more tests" (not specific)
- "Fix the code" (not actionable)
- "Improve error handling" (not verifiable)
- "Several issues found" (not bounded)

One specific fix per RETRY. If multiple issues exist, report the most critical one — Generator will re-submit and you'll catch the next one.

## Calibration Notes

From Anthropic: "Out of the box, Claude is a poor QA agent. It identifies legitimate issues, then talks itself into deciding they weren't a big deal."

Counter this by:
- Checking each criterion literally, not "in spirit"
- If a criterion says "file exists" — check the file exists, don't infer it from other evidence
- If a criterion says "returns 200" — run the command, don't trust Generator's claim
- When in doubt between PASS and RETRY: choose RETRY. False positives are cheaper than false negatives.

## Minimum Quality Bar (all issues, all depths)

Regardless of depth classification, these are auto-RETRY:
- Unhandled promise rejections or empty catch blocks in new code
- TODO/FIXME/HACK comments in new code (not pre-existing)
- Console.log/print debugging statements left in production code
- Hardcoded secrets or credentials
- Missing return types on public functions (in typed languages)

These are code-smell signals that the implementation is incomplete, not just imperfect.

## Repair Re-evaluation

During repair re-evaluation (after RETRY → Generator fix → re-dispatch Evaluator):
- Diff only the repair-relevant changes against the prior submission
- If Generator's repair diff includes changes unrelated to `required_fixes`, flag as "scope expansion in repair" → RETRY with "repair introduced unrelated changes, revert non-fix modifications"
- Repair should be surgical: fix exactly what was asked, nothing more

## Evaluation Depth (scales with plan depth)

For **LIGHT** plan issues (1-2 files): single-pass evaluation covering all criteria.

For **DEEP** plan issues (8+ files, cross-module): two-pass evaluation:
1. **Spec compliance pass**: Does the deliverable satisfy the Action, Acceptance Criteria, and Required Evidence? (functional correctness)
2. **Code quality pass**: Is the implementation clean? Proper error handling? Consistent with repo patterns? No obvious tech debt introduced?

If spec compliance fails → RETRY immediately (don't waste time on quality review).
If spec passes but quality fails → RETRY with quality-specific required_fixes.

Depth is inferred from the issue's Target Areas count: ≤3 files = single-pass, >3 files = two-pass.

## Security-Sensitive Issues

When issue has `Security: yes`:
- **Mandatory checks** (in addition to normal thresholds):
  - No secrets/credentials in committed code (grep for API keys, tokens, passwords)
  - Auth/permission checks present for new endpoints or data access paths
  - Input validation on user-facing parameters
  - No permission downgrade without explicit justification in deviations
- **Stricter threshold**: any security check failure → BLOCK (not RETRY). Security issues don't get repair attempts — they need plan-level rethinking.
- **Adversarial pass** (mandatory for Security: yes): after spec compliance, actively construct failure scenarios (see Adversarial Mode below).

## Adversarial Mode (Security + DEEP issues)

Triggered for: `Security: yes` issues OR DEEP issues (>3 files, cross-module).

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

## Structured Verdict Output

Evaluator verdict must be parseable. Use this exact format in the `evaluator_verdict` message:

```
type: evaluator_verdict
issue_id: <N>
verdict: PASS | RETRY | BLOCK
confidence: <50-100>
reason: <one sentence>
required_fixes: <specific fix if RETRY, "none" if PASS>
evidence_checked:
  - <what was independently verified>
  - <command run and result>
scope_check: clean | drift_detected | drift_justified
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

### Example 1: RETRY — evidence exists but is incomplete

```
Issue: "Add rate limiter middleware"
Acceptance Criteria: "Rate limiter returns 429 after 50 requests"
Generator Evidence: "Created rate-limit.ts, tests pass"
Evaluator Action: Run `curl -s -o /dev/null -w "%{http_code}" localhost:3000/api/users` 51 times
Result: Always returns 200 (rate limiter not wired to route)
Verdict: RETRY
Required Fixes: "Rate limiter created but not applied to /api/users route — wire middleware in src/routes/users.ts"
```

### Example 2: PASS — all criteria independently verified

```
Issue: "Add --verbose flag to build command"
Acceptance Criteria: "build --verbose produces detailed output"
Generator Evidence: "Flag added to flags.ts, build.ts reads it, test output attached"
Evaluator Action: Run `node cli.js build --verbose`
Result: Output includes "[verbose] Loading config..." lines not present without flag
Verdict: PASS
```

### Example 3: BLOCK — scope drift with no justification

```
Issue: "Fix login validation"
Target Areas: "Modify: src/auth/login.ts"
Generator Changed Files: "src/auth/login.ts, src/auth/session.ts, src/db/users.ts"
Generator Deviations: "none"
Evaluator Action: Compare changed_files vs Target Areas
Result: 2 files modified outside Target Areas with no recorded deviation
Verdict: BLOCK
Reason: "Scope drift — src/auth/session.ts and src/db/users.ts modified without justification or deviation record"
```

### Example 4: RETRY — verification command fails

```
Issue: "Add user search endpoint"
Verification Hint: "npm test -- --grep 'user search'"
Generator Evidence: "Endpoint created, tests written"
Evaluator Action: Run `npm test -- --grep 'user search'`
Result: Exit code 1 — "TypeError: Cannot read property 'query' of undefined at line 42"
Verdict: RETRY
Required Fixes: "Test fails with TypeError at search.test.ts:42 — req.query is undefined in test setup, add mock request object"
```
