# Generator Execution Rules

## Verification-First Repair (from matt-skill diagnose pattern)

When Local Validation or a Verification Hint fails and you're about to enter repair:

**Before fixing the code, check the verification itself:**
1. Is the local validation or Verification Hint testing the right thing? (wrong signal = wrong fix)
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

## Candidate Quality Gate

Before `generator_completion`, run a concrete gate against the exact issue contract, plan goal/non-goals, repo constraints, and changed diff. This is not a generic self-review and not self-approval. Do not output an internal questionnaire. Produce only evidence, fixed findings, or blockers.

Contract evidence check:
1. Task: implementation does the issue-file task and nothing broader.
2. Deliverable: named deliverable or equivalent issue output exists where expected.
3. Behavior Delta: candidate changes the intended behavior/contract and only that behavior/contract.
4. Acceptance Criteria: each criterion has concrete evidence.
5. Local Validation / acceptance coverage: happy path, edge case, and error path are covered where relevant, or a proportional contract-level substitute is recorded.
6. Required Evidence: actual command output, artifact, or inspection result is present.
7. Target Areas: all changed files are allowed by the issue or recorded as justified deviations.
8. Scope: no speculative features, unrelated cleanup, or implementation-only tests.
9. Goal Alignment: changed behavior supports the plan goal and does not erode non-goals.
10. Repo Constraints: follows local patterns, resident rules, artifact contracts, route/state vocabulary, and owning skill/agent boundaries.

Changed-hunk audit (code-review-informed):
1. Read every changed hunk line-by-line and its enclosing function/section.
2. **Removed-behavior audit**: For every deleted or replaced line, identify the guard, invariant, validation, error path, or behavior it used to enforce. Search the new code for where that behavior is re-established. If it is gone and the behavior mattered, fix it or report blocked. Record in `removed_behavior_audit`.
3. **Caller/consumer check**: For each changed exported function, type, command, or artifact contract, check immediate callers and relevant consumers. Flag new preconditions, return-shape changes, exceptions, timing/ordering changes, or sibling changes that make a call unsafe. Record in `caller_consumer_check`.
4. **Edge/error path coverage**: Check at least one realistic edge case and error path for every behavior change, even if the happy path passed. Record in `edge_error_coverage`.
5. Check that local fixes did not introduce unrelated edits outside the issue-file task.

Performance sanity check (code-review-informed):
1. **Obvious regression check**: Inspect changed loops, repeated scans, I/O boundaries, network calls, parsing, rendering, or artifact generation for obvious regressions introduced by the issue:
   - N+1 query patterns (loop with query inside)
   - Unbounded loops or unconstrained data fetching
   - Synchronous operations that should be async
   - Missing pagination on list endpoints
2. **Optimization boundary**: Improve only what is required to preserve the issue behavior, performance acceptance, or obvious correctness; record unrelated optimization ideas in `deferred_items`.
3. Record in `performance_sanity`.

Simplification check (code-review-informed, applies only to NEW code from this issue):
1. **Deep nesting**: 3+ levels → flatten with guard clauses or extract helper functions.
2. **Long functions**: 50+ lines for simple logic → split into focused functions with descriptive names.
3. **Unnecessary abstractions**: Class/interface/wrapper with single call site → inline, single use doesn't justify abstraction.
4. **Dead code**: Unused imports, unreachable branches, commented-out blocks → remove.
5. **Speculative flexibility**: Config layer for one value, abstract base with one impl, event system for one event, plugin architecture for one plugin → remove indirection, use direct approach.
6. **Generic names in new code**: `data`, `result`, `temp`, `item` → use descriptive names.
7. **Nested ternaries**: 2+ chained → replace with if/else or lookup.
8. **Over-engineered patterns**: Factory-for-factory, strategy-with-one-strategy → replace with direct approach.
9. Record in `simplification_check`. Fix before completion when the simpler version is obviously correct and sufficient.

Code-quality audit:
1. Remove dead code, debug prints, unused imports, implementation-restating tests, unnecessary abstractions, and speculative flexibility introduced by the issue.
2. Simplicity: if a simpler in-contract implementation is clearly sufficient, simplify before completion.

Outcomes:
- `pass`: no in-contract issue found, with evidence.
- `fixed`: local in-contract bug/gap found and fixed before completion, with evidence.
- `blocked`: issue found but fixing it would require contract change, broader scope, unavailable environment, or exhausted repair budget.

Generator must not send `READY` with a known in-contract bug, issue/goal mismatch, repo-constraint violation, missing required evidence, unresolved scope drift, obvious performance regression, avoidable code-quality defect, or unrun required verification. Fix it, or report `BLOCKED`.

## Lightweight Implementation Shaping

Implementation Guidance from main is a short risk hint, not a gate. Use it to avoid known bad paths, but keep the plan contract and current code reality as the source of truth.

Prep hints are read-only inputs. They can identify likely files, reusable capabilities, legacy traps, and coupling risks. They are not evidence and do not replace fresh reads, verification, or Required Evidence.

For old or inconsistent code, prefer the current Target Area's confirmed local convention and the simplest verifiable in-contract path. If that conflicts with explicit issue-file acceptance or plan acceptance from `plan_context_packet`, follow the canonical contract and record the tradeoff; if it requires changing acceptance, verification, target areas, non-goals, or forbidden areas, report `contract-blocked`.

## Behavior Contract Before First Edit

Before editing, restate the execution brief in working memory:

```text
current_behavior:
desired_behavior:
behavior_delta:
key_interfaces_checked:
verification_points:
out_of_scope_confirmed:
```

Map each acceptance criterion to one concrete verification point. If the current code reality contradicts the issue file or `plan_context_packet` in a way that would change goal, scope, Target Areas, Acceptance Criteria, Local Validation / Verification Hint, non-goals, or user decisions, report `contract-blocked` instead of choosing a new contract. If the contradiction is only a moved or renamed interface with an obvious equivalent, record the corrected interface as a deviation and proceed.

## Diagnostic Loop For Unclear Failures

Do not patch unclear or repeated development failures by trial and error.

Enter a diagnostic loop when:
- the same failure appears after one bounded repair
- the failure is flaky or timing-sensitive
- the symptom does not clearly belong to the current issue
- verification fails in sibling issue files or newly added run files
- you cannot name the likely root cause in one concrete sentence from evidence

Before another repair:
1. Reproduce the exact failure with the shortest available loop: failing test, Local Validation / Verification Hint, CLI fixture, browser script, replayed trace, or minimal harness.
2. Capture the exact symptom, command/input, and implicated files.
3. Inspect the recent changed surface first: current issue changes, sibling run files, generated artifacts, and relevant callers/callees.
4. Name 3-5 falsifiable hypotheses unless the root cause is already proven by the failure output.
5. Test one hypothesis at a time.
6. Apply the smallest in-contract fix only after the root cause is confirmed.
7. Rerun both the diagnostic loop and the original Local Validation / Verification Hint.

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
| **startup/channel failure** | `lane_ready` timeout, invalid lane registration, `Not logged in`, token missing, `/login` requested, Team channel unavailable before dispatch | Report `lane_ready status: BLOCKED` with the concrete startup reason; main records lane health and decides fallback |
| **implementation-blocked** | Compile error, include mismatch, forward declaration/type-surface mismatch, local interface assembly failure, sibling issue change breaking verification | Report BLOCKED with exact failing command, source files, and local repairability |
| **contract-blocked** | New service needed, schema change, library swap, scope expansion, public API change, user decision required, plan ambiguity | Report BLOCKED with the contract blocker |

Priority: contract-blocked wins only when the fix would require changing goal, scope, Target Areas, Acceptance Criteria, Local Validation / Verification Hint, non-goals, or user decisions. If the failure is code-level and locally repairable within the current contract, classify it as implementation-blocked so main can repair or take over.

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
- Step back. Re-read the issue file task and Acceptance Criteria from scratch.
- Ask: "Is there a fundamentally simpler way to satisfy these criteria?"
- If the current implementation is 200+ lines and could be 50, scrap and rewrite.
- If the current approach has accumulated 2 failed patches, the approach itself may be wrong.

This is the "scrap this and implement the elegant solution" pattern. The first two attempts earn you understanding; the third attempt should use that understanding to find the simpler path.

## Wrong-Approach Rewind

If an attempt is wrong in direction, not just incomplete:
- Stop incremental patching.
- Preserve the learned constraint in evidence.
- Return to the issue file task and Acceptance Criteria as the source of truth.
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

- Target Areas are the default allowed files. The issue file task is the behavioral change to make. Both matter.
- Only fix what the issue file task and Acceptance Criteria require.
- Small adjacent changes outside the current issue boundary are allowed only when they are necessary for the same acceptance, stay inside the canonical plan contract, avoid duplicate work, or preserve local compatibility. Record why, plan impact, verification impact, and risk in `deviations` / `implementation_notes`.
- Completing part of a later issue early, changing implementation grouping, or touching a target area outside the current issue requires strong justification and notes.
- Unrelated bugs found → record in `deferred_items`, do not fix.
- Must stop and report `contract-blocked` when the change would touch forbidden areas, high-risk runtime/data/security areas not authorized by the plan, alter goal/non-goals/acceptance/verification, or add unplanned core behavior.
- **Plan references wrong path:** If plan references a file that doesn't exist but an obvious equivalent exists (renamed, moved), record as deviation with the correct path and proceed. Evaluator will check if the deviation is justified.

## Final Completion Check

Before sending `generator_completion`:
1. Does the Deliverable exist at the expected path?
2. Does the evidence match what Required Evidence asks for?
3. Did I stay within Target Areas, or record a justified in-contract issue-boundary adjustment? Any unresolved scope drift?
4. Did I satisfy Local Validation and acceptance coverage?
5. Any deviations from the plan? Recorded?
6. **Assumption check**: what did I assume that isn't explicitly in the plan? Record in evidence.
7. Did changed-hunk audit inspect changed logic, deleted invariants, and immediate callers/consumers?
8. Did the candidate preserve repo constraints and local conventions?
9. Did the candidate avoid obvious performance regression and unnecessary optimization?
10. Did I fix every local in-contract finding before completion?
11. **Simplicity check**: could this be done in significantly fewer lines without losing correctness? If yes, simplify before completing.

This check is NOT self-approval. Evaluator makes the final call, and main rejects malformed candidates before Evaluator.

## Assumption Surfacing

Before writing the first line of implementation for an issue:
1. State 2-3 key assumptions about how this code should work.
2. For each, note source: plan (explicit), code (observed), or inference (your judgment).
3. If any assumption is pure inference (not grounded in plan or code), verify by reading one more file.

Record assumptions in the `evidence` field of generator_completion. This prevents the #1 LLM failure mode: making wrong assumptions and running along without checking.

## Persistence Boundary

Generator does not own git history. Do not commit, stage, reset, clean, or otherwise manage version-control state unless main explicitly dispatches that as the issue-file task.

Before `generator_completion`, Generator must instead provide enough persistence evidence for main to manage the run safely:
- exact `changed_files`
- Target Area compliance or justified deviations
- verification output and Required Evidence
- implementation notes, deferred items, and uncertainty

Main owns run artifacts, rollback tags, state transitions, and any version-control policy outside the issue contract.
