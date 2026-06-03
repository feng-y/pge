# Evaluator Hard Thresholds

Evaluator default scope is final run-level verification. It validates the composed diff against the canonical plan, including goal, non-goals, issue-file acceptance, evidence coverage, verification, and implementation logic. Targeted checks may focus on one issue or risk, but they are explicit exceptions and must not become a mandatory per-issue serial gate.

**Adaptive escalation for targeted checks**: Main dispatches targeted Evaluator checks only when a bounded, run-blocking risk question cannot be answered by a candidate whose evidence is already complete. Acceptable signals are plan/code reality conflict, cross-boundary risk on a complete candidate, and repair uncertainty after one bounded repair. Weak verification, missing evidence, failed local verification, and incomplete self-review are Candidate Gate failures, not Evaluator triggers. Main records the observed signal and routing reason when escalating. Escalation is signal-based, not a brittle trigger matrix. Escalation supplements Generator default quality; it does not replace it.

Evaluator is final pressure over composed evidence, not a routine cleanup crew and not a taste enforcer. It should catch correctness, scope, evidence, verification, and high-signal maintainability misses that threaten the current plan outcome. When defects repeatedly reach this lane, report execution-stage friction so dispatch shaping, Generator packets, or implementation notes can improve instead of broadening review ceremony.

## Automatic Verdicts

These conditions produce automatic verdicts without judgment:

| Condition | Verdict | Reason |
|-----------|---------|--------|
| Any generated deliverable file doesn't exist | BLOCK | "deliverable not produced: <issue_id/path>" |
| Required Evidence missing entirely | RETRY | "required evidence not provided: <which>" |
| Issue local validation, plan Verification Hint, stop condition, integration, or regression command fails (non-zero exit) | RETRY | "verification failed: <command> → <output>" |
| Files modified outside all approved Target Areas (unjustified) | BLOCK | "scope drift: <files> not in target areas" |
| Generator self-reported BLOCKED | — | Do not evaluate. Main handles. |

When a local validation or Verification Hint fails, attribute the failure before writing the verdict:
- `issue_under_review`: failure is in the issue's own Target Areas or deliverable.
- `sibling_issue`: failure stack points to another issue's Target Areas or sibling lane changes.
- `newly_added_run_file`: failure stack points to files added elsewhere in the same run.
- `environment_or_manual`: command/tooling/manual prerequisite is unavailable.

For `sibling_issue` or `newly_added_run_file`, return RETRY with the attribution and implicated files. Main must route shared-tree contamination, hold affected issues, repair the source first, and retry verification after the tree is buildable.

## Plan Alignment Check

For final run-level verification:
- Check that the composed diff still satisfies the plan goal.
- Check that non-goals remain untouched.
- Check every generated issue against its issue-file task and Acceptance Criteria.
- Check that cross-issue behavior composes cleanly instead of merely passing isolated checks.
- Check that the implementation logic matches the plan's intended behavior, not only that files changed.

Any plan-changing deviation in goal, scope, target areas, acceptance, verification, or non-goals is BLOCK unless the canonical plan already authorizes it.

## Repo Constraint Check

Evaluator must verify generated changes against the repo constraints that future reviewers would otherwise catch late:

- resident rules from `CLAUDE.md` / `AGENTS.md`
- local code patterns in touched Target Areas
- owning skill / agent boundaries
- artifact names, schemas, route/state/verdict vocabulary, and handoff contracts
- "do not promote durable knowledge" / "do not create docs" boundaries when execution did not ask for that

If a generated change violates a current repo constraint but can be repaired inside the plan contract, return RETRY with the smallest repair. If repairing it would change the plan contract, return BLOCK or route upstream through main.

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
- **Justified issue-boundary adjustment**: Generator recorded it in deviations / implementation notes AND it is clearly necessary for the same acceptance, inside the canonical plan contract, and does not alter goal, non-goals, verification, forbidden areas, or high-risk behavior → may PASS if evidence covers it.
- **Weakly justified drift**: the change appears probably necessary but the notes/evidence do not explain why → RETRY (ask Generator to add the missing justification or remove the drift), NOT BLOCK.
- **Unjustified drift**: no deviation recorded, or deviation is clearly unrelated to the issue-file task → BLOCK

Issue boundaries are progress units, not absolute hard boundaries. Forbidden areas, high-risk constraints, acceptance semantics, verification, non-goals, and target-area authority across the canonical plan remain hard boundaries.

## Implementation Quality Heuristics

Flag new complexity or speculative flexibility only when it threatens the current plan outcome and the simpler, better-contained repair is obvious, bounded, and preserves the plan contract. Otherwise record the risk as advisory context.

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

Every RETRY must also include:
- `finding_id`: stable within the evaluation attempt, such as `eval-final-001`
- `recheck_scope`: the exact criterion, command, behavior delta, or adversarial scenario to re-check after repair
- `implicated_files`: concrete files when the finding depends on code or artifacts
- `retry_contract_hint`: the narrowest suggested repair owner/scope, or `none` if main must infer ownership

Main uses these fields to materialize an Evaluator Repair Contract and re-enter the exec loop. Evaluator must not assume Generator sees the whole review narrative. Evaluator does not grant a fresh retry budget; main consumes the owning issue's remaining attempt budget.

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
| Misleading names that affect reviewability or behavior understanding | Function named `get*` that mutates state, or generic names where the value's role is needed to verify behavior | "Rename <symbol> at <file:line> — current name hides behavior or mutation" |

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

After checking acceptance criteria, review the actual composed diff against the issue-file tasks:
- Every changed line should trace to an issue-file task or a justified deviation
- If the diff includes changes that don't serve the issue-file task (reformatting, comment edits, unrelated "improvements") → RETRY with "diff includes changes unrelated to issue task: <specific lines>"
- If the diff is surprisingly large for a small issue-file task, investigate whether the approach is overcomplicated

## Performance And Optimization Boundary

Evaluator checks performance only where the run changed a relevant surface or the plan mentions performance. Look for new unbounded loops, repeated scans, unnecessary I/O, network calls in loops, repeated parsing/rendering/artifact generation, or loss of caching/batching introduced by the run.

- If performance behavior regresses in a way visible from code or verification, RETRY with a bounded repair.
- If the issue merely exposes an unrelated optimization idea, record it as risk/deferred context and do not change verdict.
- Do not ask Generator to optimize beyond the issue contract unless performance is part of acceptance or the generated code introduced the regression.

## Repair Re-evaluation

During repair re-evaluation (after RETRY → Generator fix → re-dispatch Evaluator):
- Diff only the repair-relevant changes against the prior submission
- If Generator's repair diff includes changes unrelated to `required_fixes`, flag as "scope expansion in repair" → RETRY with "repair introduced unrelated changes, revert non-fix modifications"
- Repair should be surgical: fix exactly what was asked, nothing more
- First re-check the prior `finding_id` and `recheck_scope`. For final-run verification, continue the full final verification after the prior finding passes, because the repair may have introduced a new regression.
- If the same finding fails again and the repair owner has no retry budget remaining, return BLOCK with the exhausted finding id instead of issuing another RETRY.

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
1. **Spec compliance pass**: Does the deliverable satisfy the issue-file task, Acceptance Criteria, and Required Evidence? (functional correctness)
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
- **Stricter threshold**: in-contract security omissions such as missing validation or missing auth wiring → RETRY with the smallest bounded repair. Plan-changing security model gaps, permission downgrades, secrets/credential exposure, or unclear trust-boundary changes → BLOCK and route upstream through main.
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

- **Style/naming** — not Evaluator's job unless a misleading new name hides mutation, trust-boundary behavior, or a plan-relevant data role needed for verification.
- **Architecture decisions** — plan already made these. Evaluator checks execution, not design.
- **Performance optimization** — unless Acceptance Criteria explicitly mentions performance.
- **Test coverage completeness** — Evaluator checks Local Validation and required acceptance coverage are met, not that coverage is 100%.
- **Documentation quality** — unless the issue-file task explicitly includes docs.
- **Alternative implementations** — "could be done better with X" is not a RETRY reason.

## Evaluator vs Exec QA Gate

Evaluator is the final run-level verification gate: it checks plan goal/non-goal alignment, generated issue-file tasks, Target Areas, Acceptance Criteria, Required Evidence, local validations / Verification Hints, composed implementation logic, and obvious quality defects that affect the plan outcome. Targeted checks are allowed only when main explicitly dispatches a bounded risk question.

The Exec QA Gate is a separate read-only whole-diff review surface: it checks reviewability, blocking code-review findings, simplification opportunities, and whether any security/test specialist pass is needed after Evaluator verification. It does not replace Evaluator's plan-alignment authority. Exec QA Gate is an execution-stage quality gate; it is not `pge-review` and does not make shipping decisions.

## Structured Verdict Output

Evaluator verdict must be parseable. Use this exact format in the `evaluator_verdict` message:

```
type: evaluator_verdict
evaluation_scope: final_run | targeted_check
issue_ids: <list>
verdict: PASS | RETRY | BLOCK
finding_id: <stable id for RETRY/BLOCK, "none" for PASS>
confidence: <50-100>
reason: <one sentence>
required_fixes: <specific fix if RETRY, "none" if PASS>
evidence_checked:
  - <what was independently verified>
  - <command run and result>
scope_check: clean | drift_detected | drift_justified
failure_attribution: issue_under_review | sibling_issue | newly_added_run_file | environment_or_manual | not_applicable
implicated_files: <files involved in failed verification, or "none">
recheck_scope: <exact criterion/command/scenario to re-check after repair, or "none">
retry_contract_hint: <suggested bounded repair owner/scope if RETRY, or "none">
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
type: evaluator_verdict
evaluation_scope: final_run
issue_ids: ["1", "2"]
verdict: RETRY
finding_id: eval-final-001
confidence: 100
reason: GET /api/users still returns 200 after 51 requests
required_fixes: Rate limiter created but not applied to /api/users route — wire middleware in src/routes/users.ts
evidence_checked:
  - ran curl 51 times; observed 200 every time
scope_check: clean
failure_attribution: issue_under_review
implicated_files: src/routes/users.ts
recheck_scope: GET /api/users returns 429 after 50 requests
retry_contract_hint: repair issue 2 route wiring only
plan_alignment: acceptance failed: GET /api/users returns 429 after 50 requests
adversarial_findings: not_applicable
quality_bar: passed
```

### Example 2: PASS — composed run independently verified

```
type: evaluator_verdict
evaluation_scope: final_run
issue_ids: ["1"]
verdict: PASS
finding_id: none
confidence: 100
reason: build --verbose produces detailed output and non-verbose output is unchanged
required_fixes: none
evidence_checked:
  - ran node cli.js build --verbose; output includes verbose loading lines
  - ran node cli.js build; verbose lines absent
scope_check: clean
failure_attribution: not_applicable
implicated_files: none
recheck_scope: none
retry_contract_hint: none
plan_alignment: passed
adversarial_findings: not_applicable
quality_bar: passed
```

### Example 3: BLOCK — final run scope drift with no justification

```
type: evaluator_verdict
evaluation_scope: final_run
issue_ids: ["1"]
verdict: BLOCK
finding_id: eval-final-002
confidence: 100
reason: scope drift: src/auth/session.ts and src/db/users.ts modified without justification
required_fixes: none
evidence_checked:
  - compared composed changed_files against issue Target Areas
scope_check: drift_detected
failure_attribution: not_applicable
implicated_files: src/auth/session.ts, src/db/users.ts
recheck_scope: none
retry_contract_hint: none
plan_alignment: scope drift outside Target Areas
adversarial_findings: not_applicable
quality_bar: not_applicable
```

### Example 4: RETRY — final verification command fails

```
type: evaluator_verdict
evaluation_scope: final_run
issue_ids: ["1"]
verdict: RETRY
finding_id: eval-final-003
confidence: 100
reason: user search verification command fails in search.test.ts
required_fixes: Test fails with TypeError at search.test.ts:42 — req.query is undefined in test setup, add mock request object
evidence_checked:
  - npm test -- --grep 'user search' exits 1 with TypeError at search.test.ts:42
scope_check: clean
failure_attribution: issue_under_review
implicated_files: search.test.ts
recheck_scope: npm test -- --grep 'user search'
retry_contract_hint: repair issue 1 test setup only
plan_alignment: required verification failed
adversarial_findings: not_applicable
quality_bar: not_applicable
```

### Example 5: RETRY — shared-tree contamination

```
type: evaluator_verdict
evaluation_scope: final_run
issue_ids: ["1", "2"]
verdict: RETRY
finding_id: eval-final-004
confidence: 100
reason: user search verification is blocked by sibling compile error
required_fixes: Shared-tree contamination: user search verification is blocked by src/admin-report.ts from issue 2; restore buildability there before rerunning final verification
evidence_checked:
  - npm test -- --grep 'user search' exits 1 with compile error in src/admin-report.ts
scope_check: clean
failure_attribution: sibling_issue
implicated_files: src/admin-report.ts
recheck_scope: restore buildability, then rerun npm test -- --grep 'user search'
retry_contract_hint: repair issue 2 buildability before rechecking issue 1 verification
plan_alignment: required verification blocked by sibling issue
adversarial_findings: not_applicable
quality_bar: not_applicable
```
