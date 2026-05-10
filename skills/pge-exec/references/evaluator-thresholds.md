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
