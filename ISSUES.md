# PGE Pipeline Issues

Ordered by priority. Each issue is independently grabbable.

## Blocking (must fix before real use)

### Issue 1: Run pge-exec smoke test ✅ DONE

- Type: AFK
- Blocked by: none
- Scope: Run `/pge-exec test`, verify G+E team creates, Generator writes smoke file, Evaluator validates, route = SUCCESS
- Acceptance: smoke.txt exists with "pge smoke", evaluator_verdict = PASS, run manifest written
- Why: Entire exec design is unproven. Zero runtime evidence that G+E team works.
- Resolution: Smoke test passed. TeamCreate → Generator (wrote smoke.txt, 9 bytes exact) → Evaluator (independent verify) → TeamDelete. Manifest at .pge/runs/smoke-test-001/manifest.md.

### Issue 2: Clarify task directory ownership ✅ DONE

- Type: AFK
- Blocked by: none
- Scope: Decide and document: pge-research creates `.pge/tasks-<slug>/`, plan and exec reuse it. Update all 3 SKILL.md files to be explicit about who creates vs who reads.
- Acceptance: Each skill's SKILL.md states whether it creates or expects the task directory. No ambiguity.
- Why: Currently unclear who creates the directory. Research, plan, and exec all reference it but none explicitly owns creation.
- Resolution: research creates, plan writes into (or creates if no research), exec expects it exists (creates only runs/ subdir).

### Issue 3: Add resume-from-last-PASS capability to pge-exec ✅ DONE

- Type: AFK
- Blocked by: Issue 1
- Scope: After each issue PASS, write issue state to `runs/<run_id>/state.json`. On re-invocation with same plan, skip already-PASS issues and resume from first non-PASS.
- Acceptance: Can kill exec mid-run, re-invoke, and it continues from where it stopped.
- Why: Context overflow or session loss currently means re-executing all issues from scratch.
- Resolution: Added state.json persistence after every issue verdict + resume logic in Phase 1 Load & Validate.

### Issue 4: Add regression check to Evaluator (plan-level) ✅ DONE

- Type: AFK
- Blocked by: Issue 1
- Scope: After all per-issue evaluations pass, Evaluator runs one final check: do prior issues' deliverables still work? (re-run prior Verification Hints). If any regressed → RETRY on the issue that broke them.
- Acceptance: If Issue 3 breaks Issue 1's deliverable, Evaluator catches it before SUCCESS.
- Why: Per-issue evaluation doesn't catch cross-issue regressions. Superpowers has "final code reviewer over entire implementation" for this reason.
- Resolution: Added regression check to Stop Condition phase — re-runs prior Verification Hints, routes PARTIAL if any regressed.

## High Priority (improves stability)

### Issue 5: Add run-level rollback mechanism ✅ DONE

- Type: AFK
- Blocked by: Issue 1
- Scope: Before exec starts, create a git tag or stash point. If exec routes BLOCKED after partial changes, provide a `rollback` command that reverts to pre-exec state.
- Acceptance: After a BLOCKED exec, user can run one command to undo all changes.
- Why: Currently if exec fails mid-way, repo is in a half-modified state with no easy undo.
- Resolution: Added git tag `pge-exec-pre-<run_id>` before execution. Recorded in state.json and manifest.

### Issue 6: Implement multi-round redispatch (exec → plan → exec)

- Type: HITL (needs design decision on trigger conditions)
- Blocked by: Issue 1, Issue 3
- Scope: When exec routes BLOCKED with "plan is wrong" evidence, automatically invoke pge-plan with the failure context to produce a revised plan, then re-invoke pge-exec.
- Acceptance: A task that fails due to plan error can self-correct without human intervention.
- Why: Currently BLOCKED = stop. Human must manually re-plan. Anthropic PGE V2 handles this automatically.

### Issue 7: Add cross-task learnings search to pge-research ✅ DONE

- Type: AFK
- Blocked by: none
- Scope: In step 1 (Load accumulated knowledge), search ALL `.pge/tasks-*/runs/*/learnings.md` for patterns relevant to current intent, not just config. Use grep/glob to find matching keywords.
- Acceptance: Research on "add rate limiter" finds learnings from a prior "add auth middleware" task that mentions middleware patterns.
- Why: Currently compound only feeds back through config. Direct learnings search enables richer cross-task knowledge transfer (gstack cross-project learnings pattern).
- Resolution: Updated step 1 to grep all learnings.md files with keyword search + 30-day confidence decay check.

### Issue 8: Clarify pge-setup value proposition ✅ DONE

- Type: AFK
- Blocked by: none
- Scope: Update pge-setup SKILL.md to explicitly state: (1) what config enables that degraded mode doesn't, (2) when to recommend setup vs skip it, (3) how compound learnings eventually replace manual setup.
- Acceptance: A user reading pge-setup knows exactly when it's worth running vs skipping.
- Why: Currently all downstream skills say "config optional" which makes setup feel pointless.
- Resolution: Added "When Setup Is Worth Running" table with 5 scenarios + self-evolution explanation.

## Medium Priority (quality improvements)

### Issue 9: Add execution cost gate (skip Evaluator for trivial)

- Type: HITL (contradicts current anti-pattern "never skip Evaluator")
- Blocked by: Issue 1, Issue 4
- Scope: For LIGHT plan issues where Verification Type = AUTOMATED and Generator's verification already passed: allow orchestrator to skip Evaluator dispatch and auto-PASS. Record as "auto-verified, evaluator skipped".
- Acceptance: Trivial issues (config change, single-line fix) don't waste an Evaluator dispatch.
- Why: Anthropic says "evaluator is not a fixed yes-or-no decision — it is worth the cost when the task sits beyond what the current model does reliably solo." Current design always dispatches.

### Issue 10: Add checkpoint subtypes to HITL issues ✅ DONE

- Type: AFK
- Blocked by: none
- Resolution: HITL expanded to HITL:verify / HITL:decision / HITL:action. Exec handles each differently (verify auto-approves in headless, action never auto-approves).

### Issue 11: Add Generator clean-state check ✅ DONE

- Type: AFK
- Blocked by: none
- Resolution: Added clean-state check to generator-rules.md. Dirty Target Areas → BLOCKED. Dirty unrelated → proceed with deviation record.

### Issue 12: Add security-sensitive issue flag ✅ DONE

- Type: AFK
- Blocked by: none
- Resolution: Added `Security: yes|no` field to plan issues. Evaluator applies mandatory security checks (no secrets, auth present, input validation) + stricter threshold (BLOCK not RETRY) for security-flagged issues.

## Low Priority (future enhancements)

### Issue 13: Model escalation on repair failure

- Type: AFK
- Blocked by: Issue 6
- Scope: If Generator repair fails 3 times with same model, offer to retry with a more capable model (e.g., Opus instead of Sonnet for the repair attempt).
- Acceptance: Stuck repairs can escalate to stronger model before giving up.
- Why: Superpowers pattern. Currently max retries = hard stop.

### Issue 14: Parallel issue execution (wave-based)

- Type: AFK
- Blocked by: Issue 1, Issue 3, Issue 4
- Scope: Issues with no mutual dependencies can execute in parallel (spawn multiple Generator agents). Evaluator validates each independently. Regression check catches conflicts.
- Acceptance: 3 independent issues execute in ~1x time instead of ~3x.
- Why: GSD wave-based execution. Currently always sequential.

### Issue 15: Confidence decay pruning

- Type: AFK
- Blocked by: Issue 7
- Scope: Add a periodic check (or on-demand command) that scans `.pge/config/repo-profile.md` for learnings older than 30 days, verifies them against current code, and removes stale ones.
- Acceptance: Running the prune command removes learnings that no longer match code reality.
- Why: Without pruning, config accumulates stale knowledge that misleads future runs.
