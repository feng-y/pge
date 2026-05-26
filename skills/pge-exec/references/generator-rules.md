# Generator Execution Rules

## Verification-First Repair (from matt-skill diagnose pattern)

When a Verification Hint fails and you're about to enter repair:

**Before fixing the code, check the verification itself:**
1. Is the Verification Hint testing the right thing? (wrong signal = wrong fix)
2. Is it deterministic? (flaky verification = infinite repair loop)
3. Is it fast enough? (30-second verification = slow feedback)

If the verification is broken/flaky/wrong:
- Fix the verification FIRST (improve the test, fix the assertion, make it deterministic)
- Then fix the code
- Record in deviations: "improved verification before repair"

A good feedback loop makes the bug 90% fixed. A bad feedback loop makes repair impossible.

## TDD Evidence Quality

Use TDD as a behavior feedback loop, not as ceremony for producing red-green-refactor evidence.

- TDD depth must be proportional to the issue contract. Complex behavior changes need a real red-green loop; schema/config/docs/mechanical contract changes may use the plan's explicit verification command or contract-level check instead.
- Tests must verify issue behavior through the public or plan-relevant interface.
- Do not add tests that simply restate the implementation, assert private structure, mirror the code path, or check only that a mocked collaborator was called. These provide zero confidence.
- If a test would keep passing after the intended behavior is broken, it is not valid evidence for the issue.
- Prefer one focused behavior test, or the plan's explicit verification command for schema/config/doc tasks, over a pile of shallow tests.
- If no meaningful RED test is possible for the issue type, record why and use the strongest contract-level verification available instead of inventing a low-value test.
- Do not expand scope to make something testable. If meaningful verification needs a broader interface, harness, fixture, or dependency than the plan allows, report the verification gap or blocker instead of adding infrastructure.

## Issue-Contract Self-Review

Before `generator_completion`, review the candidate against the exact issue contract, not a generic checklist:

1. Action: did the implementation do the issue's requested action and nothing broader?
2. Deliverable: does the named deliverable exist at the expected path?
3. Acceptance Criteria: does each criterion have concrete evidence?
4. Test Expectation: are happy path, edge case, and error path covered as requested, or is a proportional substitute recorded?
5. Required Evidence: is the actual command output, artifact, or inspection result present?
6. Target Areas: are all changed files allowed by the issue or recorded as justified deviations?
7. Scope: did the work avoid speculative features, unrelated cleanup, and implementation-only tests?
8. Uncertainty: what remains unverified, if anything?

## Diagnostic Loop For Unclear Failures

Do not patch unclear or repeated development failures by trial and error.

Enter a diagnostic loop when:
- the same failure appears after one bounded repair
- the failure is flaky or timing-sensitive
- the symptom does not clearly belong to the current issue
- verification fails in sibling issue files or newly added run files
- you cannot name the likely root cause in one concrete sentence from evidence

Before another repair:
1. Reproduce the exact failure with the shortest available loop: failing test, Verification Hint, CLI fixture, browser script, replayed trace, or minimal harness.
2. Capture the exact symptom, command/input, and implicated files.
3. Inspect the recent changed surface first: current issue changes, sibling run files, generated artifacts, and relevant callers/callees.
4. Name 3-5 falsifiable hypotheses unless the root cause is already proven by the failure output.
5. Test one hypothesis at a time.
6. Apply the smallest in-contract fix only after the root cause is confirmed.
7. Rerun both the diagnostic loop and the original Verification Hint.

If you cannot build a loop, report `BLOCKED` with what you tried and what artifact or access would unblock diagnosis. Include the result in `diagnostic_record`.

## Analysis Paralysis Guard

If Generator performs 5+ consecutive Read/Grep/Glob operations without an Edit/Write/Bash that modifies a file:
- STOP immediately
- Either write code OR report BLOCKED with what's preventing progress
- Open-ended investigation without action is Generator drift

## Progress Watchdog Responses

If main sends `status_request`, do not answer with a vague status.

Respond with exactly one of:
- `generator_completion` with `READY`
- `generator_completion` with `BLOCKED`
- `progress_update` that names concrete files, commands, artifacts, or hypotheses changed since the last update

If no new concrete progress exists, report `BLOCKED` with the reason. Repeating "still working" without evidence is a stall and main will recover or replace the lane.

## Context Quarantine

Before broad exploration, ask: "Will I need this raw tool output again, or just the conclusion?"

Consider a bounded helper only when the task needs broad reads/greps, multiple discarded hypotheses, or cross-module lookup and the implementation only needs the answer. Prefer direct exploration for narrow local work. The helper report should contain:
- conclusion
- evidence paths
- confidence
- dead ends not to repeat

Do not paste bulk helper output into `generator_completion`. Keep only the conclusion needed to implement or explain a blocker.

## Deviation Classification

When encountering issues during execution:

| Category | Examples | Action |
|----------|----------|--------|
| **auto-fix-local** | Broken test, wrong import, typo, missing null check, format error | Fix silently, no permission needed |
| **auto-fix-critical** | Missing error handling, validation gap, auth check, missing index | Fix + record in deviations |
| **implementation-blocked** | Compile error, include mismatch, forward declaration/type-surface mismatch, local interface assembly failure, sibling issue change breaking verification | Report BLOCKED with exact failing command, source files, and local repairability |
| **contract-blocked** | New service needed, schema change, library swap, scope expansion, public API change, user decision required, plan ambiguity | Report BLOCKED with the contract blocker |

Priority: contract-blocked wins only when the fix would require changing goal, scope, Target Areas, Acceptance Criteria, Verification Hint, non-goals, or user decisions. If the failure is code-level and locally repairable within the current contract, classify it as implementation-blocked so main can repair or take over.

Implementation-blocked is not a license to stop the run. It is a signal to main that code can still be repaired inside the current contract. Include enough evidence for main to act without rediscovering the failure:
- failing command and shortest relevant output
- implicated file paths
- whether the failure appears caused by this issue, a sibling issue, or newly added files in the same run
- whether a local fix seems possible

## No-Change Guard

Each repair attempt MUST change at least one file. If the same input would produce the same output:
- Do not retry
- Report BLOCKED with "same approach exhausted, need different strategy"
- Same failure signature + no code change = infinite loop

## Fresh-Approach Rule (repair attempt 3)

On the final repair attempt (attempt 3 of 3), do NOT incrementally patch the same approach:
- Step back. Re-read the issue Action and Acceptance Criteria from scratch.
- Ask: "Is there a fundamentally simpler way to satisfy these criteria?"
- If the current implementation is 200+ lines and could be 50, scrap and rewrite.
- If the current approach has accumulated 2 failed patches, the approach itself may be wrong.

This is the "scrap this and implement the elegant solution" pattern. The first two attempts earn you understanding; the third attempt should use that understanding to find the simpler path.

## Wrong-Approach Rewind

If an attempt is wrong in direction, not just incomplete:
- Stop incremental patching.
- Preserve the learned constraint in evidence.
- Return to the issue Action and Acceptance Criteria as the source of truth.
- Start a fresh implementation path that explicitly avoids the failed approach.

This consumes the next normal repair attempt. It never resets or expands the per-issue max of 3 attempts.

Do not let failed attempts and corrections become the active specification.

## Destructive Git Prohibition

NEVER run:
- `git reset --hard`
- `git clean -f` or `git clean -fd`
- `git push --force`
- `git checkout -- .` (blanket restore)
- `git update-ref` on protected branches (main/master/develop)

If clean state needed: create a new commit that reverts specific changes.

## Package Install Safety

If a package install fails (`npm install`, `pip install`, `cargo add`, `go get`, etc.):
- Do NOT auto-retry with a different package name
- Do NOT guess alternative package names
- Report BLOCKED with the exact error message
- Reason: typosquatting/slopsquat protection

## Clean-State Check (before each issue)

Before starting implementation on any issue:
1. Run `git status` on Target Areas files
2. If any Target Area file has uncommitted changes → report BLOCKED ("dirty working tree overlaps Target Areas: <files>")
3. If dirty files exist but are unrelated to Target Areas → proceed, record in deviations ("unrelated dirty files present: <files>")

This prevents silently overwriting user's uncommitted work.

## Read Before Write

Before adding code to any file:
1. Read the file's exports and the immediate caller(s) that use them.
2. Check for shared utilities nearby that already do what you're about to write.
3. If two patterns exist in the codebase for the same thing (e.g., async/await vs callbacks, class vs hooks), pick the one used in the Target Area files — don't blend both.

"Looks orthogonal to me" is the most dangerous assumption. If you don't understand why existing code is structured a certain way, read one more file before adding to it.

## Match Codebase Conventions

Conformance > taste inside the codebase:
- If the codebase uses snake_case, use snake_case — even if you'd prefer camelCase.
- If the codebase has a specific error-handling pattern, follow it — even if you know a "better" one.
- If two conventions conflict, pick the one used in the Target Area files (most local wins).

Introducing a second pattern is worse than either pattern alone. If you genuinely think a convention is harmful, record it in `deferred_items` — don't fork it silently during execution.

## Scope Boundary

- Only modify files listed in the issue's Target Areas
- Only fix what the issue's Action specifies
- **Target Areas = which files you may touch. Action = what you do in those files. Both must be satisfied.** Modifying a Target Area file for a purpose not described in Action = scope drift.
- Unrelated bugs found → record in `deferred_items`, do not fix
- If the Action requires touching a file not in Target Areas: record as deviation, proceed only if clearly necessary for the Action
- **Plan references wrong path:** If plan references a file that doesn't exist but an obvious equivalent exists (renamed, moved), record as deviation with the correct path and proceed. Evaluator will check if the deviation is justified.

## Self-Review (before completion)

Before sending `generator_completion`:
1. Does the Deliverable exist at the expected path?
2. Does the evidence match what Required Evidence asks for?
3. Did I stay within Target Areas? Any scope drift?
4. Did I satisfy the Test Expectation?
5. Any deviations from the plan? Recorded?
6. **Assumption check**: what did I assume that isn't explicitly in the plan? Record in evidence.
7. **Simplicity check**: could this be done in significantly fewer lines without losing correctness? If yes, simplify before completing.

Self-review is NOT self-approval. Evaluator makes the final call.

## Assumption Surfacing

Before writing the first line of implementation for an issue:
1. State 2-3 key assumptions about how this code should work.
2. For each, note source: plan (explicit), code (observed), or inference (your judgment).
3. If any assumption is pure inference (not grounded in plan or code), verify by reading one more file.

Record assumptions in the `evidence` field of generator_completion. This prevents the #1 LLM failure mode: making wrong assumptions and running along without checking.

## Persistence Boundary

Generator does not own git history. Do not commit, stage, reset, clean, or otherwise manage version-control state unless main explicitly dispatches that as the issue Action.

Before `generator_completion`, Generator must instead provide enough persistence evidence for main to manage the run safely:
- exact `changed_files`
- Target Area compliance or justified deviations
- verification output and Required Evidence
- implementation notes, deferred items, and uncertainty

Main owns run artifacts, rollback tags, state transitions, and any version-control policy outside the issue contract.
