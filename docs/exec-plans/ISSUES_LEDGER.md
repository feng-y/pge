# ISSUES_LEDGER

Keep this file lightweight. Record only items that help the current mainline move.

## P0 / Blocker

None.

## P1 / Follow-up

- **Marketplace publication still external**: This source repo now defines the installable plugin, but the marketplace catalog entry must live in a separate marketplace repo
  - Impact: Medium (plugin packaging is done, but marketplace publication is not represented inside this repo by design)
  - Next: add a `pge` entry in the external marketplace repo and test install/update through that catalog

- **Runtime contract proving still needed**: Latest interface alignment is doc-level until exercised through a real `/pge` run
  - Planner / Generator / Evaluator / skill now share current-task vocabulary on paper
  - Need to verify real runtime consumes the aligned fields without fallback to older wording
  - Impact: Medium (could hide stale runtime assumptions)
  - Next: Test via actual `/pge` skill invocation on a small repo-internal task
- **Runtime integration gap**: Validation was manual simulation, not actual skill runtime execution
  - Current `skills/pge-execute/skill.sh` has stub implementations embedded
  - Need to verify runtime properly invokes agent .md files
  - Impact: Medium (runtime may not use new agent definitions)
  - Next: Test via actual `/pge` skill invocation
- **Agent invocation mechanism unclear**: Agent .md files are definitions, but how does runtime execute them?
  - Are they loaded as prompts to spawned agents?
  - Are they referenced by the runtime?
  - Impact: Medium (affects whether agents are actually used)
  - Next: Clarify agent invocation model
- Refine supporting governance docs only if a real proving run exposes contradiction or driveability pain.
- Add richer runtime/progress formalization only if the first proving runs show the current control plane is insufficient.

## P2 / Park

- Broader harness strategy expansion.
- Naming and terminology polish that does not unblock proving.
- Additional workflow/process machinery beyond the current minimal support layer.

## Resolved

- **Plugin packaging layer missing** — Fixed in plugin packaging / marketplace round
  - Symptom: normal usage depended on repo-local `.claude/` projection instead of the Claude Code plugin marketplace/install flow
  - Root cause: the source repo had no formal plugin manifest, no explicit versioned plugin identity, and no documented installed runtime layout
  - Impact: High for distribution and upgrade clarity
  - Evidence: repo inspection showed only source seams plus dev-time `.claude/` symlink projection, with no `.claude-plugin/plugin.json`; `claude plugin validate /code/b/pge` now passes; `claude -p --plugin-dir /code/b/pge "/pge-execute test"` successfully loads the packaged skill surface
  - Fix: added `.claude-plugin/plugin.json`, documented installed plugin layout and update path, and treated contracts as `pge-execute` supporting files under `skills/pge-execute/contracts/` rather than top-level `.claude/contracts/`
- **P/G/E current-task vocabulary drift** — Fixed in interface alignment round
  - Symptom: Planner, Generator, Evaluator, and skill used overlapping but mismatched handoff language
  - Root cause: Planner moved to current-task semantics while Generator/Evaluator/skill still carried older round-contract wording
  - Impact: Medium (semantic/interface drift across handoffs)
  - Evidence: Cross-file review showed mixed use of `boundary`/`deliverable` vs `in_scope`/`out_of_scope`/`actual_deliverable`, plus unclear local verification vs final approval wording
  - Fix: Locked shared current-task semantics, clarified Generator local verification vs Evaluator final approval, and minimally aligned `skills/pge-execute/SKILL.md`
- **Evaluator allows false-positive PASS** — Fixed in Evaluator redesign round (commit 77c30d9)
  - Symptom: Evaluator could PASS based on artifact existence alone without validating content or evidence
  - Root cause: Weak PASS semantics, no evidence independence check, no deliverable content validation
  - Impact: False-positive PASS undermines validation gate, allows placeholder work to pass
  - Evidence: Multi-round team review identified 6 categories of PASS loopholes
  - Fix: Implemented acceptance criteria validation matrix, evidence independence check, deliverable content check, sharpened verdict boundaries, made interface fields explicit
- **Generator and Evaluator agents are stubs that do not execute real work** — Fixed in agent hardening round (commit e10588d)
  - Symptom: Skill converges with PASS but actual deliverable is never created
  - Root cause: Agents produce meta-artifacts instead of reading upstream plan and executing it
  - Impact: Skill appears to work but produces no real value
  - Evidence: Post-MVP proving round 004
  - Fix: Implemented real Generator with semantic guardrails against placeholder artifacts, real Evaluator with hard PASS conditions preventing artifact-exists-only approval
- The support-layer setup round has landed.
- The first proving task is fixed as `run-001`.
- `commands/start-round.md` and `commands/close-round.md` now provide the executable round entry/closure path.
- `docs/proving/runs/run-002/upstream-plan.md` now provides the first verified execute-first upstream packet for real proving intake.
- `docs/proving/runs/run-003/runtime-intake-state.md` now provides the first verified runtime intake/state artifact for real proving runtime entry.
- `docs/proving/runs/run-004/` now closes the first real bounded proving/development round through explicit contract, deliverable, verdict, and routing artifacts.
- No proving task is fixed yet.
- Preflight is now represented consistently enough across loop / state / skill for proving.
- `continue` vs `converged` is now driven by explicit `run_stop_condition` rather than prose-only judgment.
- Repo-level harness support surface has been added for future Claude Code sessions.
- `docs/exec-plans/MVP_EXECUTION_PLAN.md` now defines the MVP scope and next 3 bounded rounds.
- MVP Round 1 complete: `skills/pge-execute/skill.sh` runtime wired, entry contract checked, Planner agent reached successfully.
- MVP Round 2 complete: full planner → generator → evaluator cycle implemented, all three role artifacts produced and verified.
- MVP Round 3 complete: convergence loop closed, final round summary produced, skill stops cleanly after PASS + single_round.
- Post-MVP proving round 004 complete: skill executed on real repo task, exposed P0 blocker (stub agents), runtime orchestration validated.
- Validation round 005 complete: Generator and Evaluator validated with real bounded task, both agents performed correctly, verdict is USABLE.

## Important decisions

- Current mainline is proving-first, not design-first.
- Only P0 should be worked in the active round.
- P1 is recorded but not expanded during the active round.
- P2 is parked without further discussion.
- Normalized seams under `agents/`, `contracts/`, and `skills/` are authoritative for proving runs.
