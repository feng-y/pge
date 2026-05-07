# ISSUES_LEDGER

Keep this file lightweight. Record only items that help the current mainline move.

## P0 / Blocker

- **Persistent runtime-team architecture is not yet operationally closed**
  - Impact: High (the target architecture is settled, but the runtime still needs authoritative orchestration closure before persistent team lifecycle can be claimed as implemented)
  - Next: validate Planner research-decision messages, single `current_round_slice` handoff, bounded `generator <-> evaluator` repair, quiet recovery observation, and teardown acknowledgement in a nontrivial repo run

- **Planner can silently skip parallel repo research on large/unfamiliar repos**
  - Impact: High (Generator may receive an under-researched contract and `main` cannot distinguish a justified local research pass from an accidental non-use of helpers)
  - Next: prove in a nontrivial repo run that Planner sends `planner_research_decision` before broad repo research and repeats the final field-complete `multi_agent_research_decision` in `planner_note`

- **`main` recovery observation can become noisy foreground polling**
  - Impact: Medium to High (raw listener scripts and verbose verification output harm reading experience without improving canonical communication)
  - Next: keep `SendMessage` as the primary wait path; use artifact-gated recovery only after repair/timeout, with quiet structured progress events

- **Generator handoff gaps can be routed as final BLOCK too early**
  - Impact: High (a real deliverable can exist while missing `generator.md` / `generator_completion`; direct route blocking loses recoverable work)
  - Next: require `main` to ask resident Generator to complete the durable handoff or send canonical BLOCKED before blocked route selection

- **Evaluator retry feedback must be a real Generator/Evaluator loop**
  - Impact: High (deliverable failures such as repeated exit 139 could stop as route output instead of feeding required fixes back to Generator)
  - Next: prove in a nontrivial repo run that `main` sends `generator_repair_request`, gates fresh `generator_completion`, sends `evaluator_recheck_request`, and snapshots repeated `failure_signature` failures before deciding whether to continue

- **Shutdown acknowledgement target is underspecified**
  - Impact: Medium (runtime can reject teardown with `shutdown_response must be sent to "team-lead"`)
  - Next: require each teammate to send `shutdown_response` to `team-lead`, while `main` only sends `shutdown_request` and calls `TeamDelete`

## P1 / Follow-up

- **Helper report runtime use is not yet proven end-to-end**
  - Impact: Medium (helper report naming and minimum fields are now defined, but runtime evidence still needs to prove threshold-triggered helper use, concrete skip reasons, and phase-owner references to helper reports)
  - Next: prove in a nontrivial repo run that Planner/Generator/Evaluator either use helper lanes with run-scoped helper report refs or record concrete reasons for not using them when trigger conditions are met

- **Artifact-chain validation before final routing must be implemented in runtime behavior**
  - Impact: Medium to High (the control-plane gates are now explicit, but the runtime surface must still enforce planner/generator/evaluator artifact usability before final routing)
  - Next: make `skills/pge-execute/SKILL.md` and runtime behavior stop on explicit artifact-gate failure states instead of routing from partial artifacts

- **Legacy root contract references can mislead runtime work**
  - Impact: Medium (top-level `contracts/*` can be mistaken for install-time authority even though plugin install depends on `skills/pge-execute/contracts/*`)
  - Next: migrate runtime-facing references to skill-local contract paths and avoid reintroducing root-level authority claims

- **Checkpoint-driven recovery is defined but not yet enacted end-to-end**
  - Impact: Medium (recovery entry points and checkpoint schema are now explicit, but the runtime still needs to write and consume checkpoints consistently)
  - Next: add checkpoint writes at the defined control points and use them as the recovery source of truth

- **Marketplace install path still unverified**
  - Impact: Medium (catalog shape is present, but the real Claude Code marketplace flow must still be exercised end-to-end)
  - Next: test `/plugin marketplace add feng-y/pge` and `/plugin install pge@pge`

- **Legacy runtime state file still present on disk**
  - Impact: Low (stale artifact can confuse inspection, but recent runs are writing isolated per-run state files)
  - Next: optionally remove the stale legacy file and update ignore/documentation references so only per-run state remains visible

- **Runtime shell guardrails are now codified but still need runtime enforcement**
  - Impact: Medium (FSM states, checkpoint-driven recovery, scoped delegation, and append-only evidence expectations are now explicit, but the executable runtime path must still enforce them consistently)
  - Next: implement the codified guardrails in the next runtime round instead of expanding the control-plane docs again

## P2 / Park

- Full multi-round execution support beyond the current bounded implementation round.
- Full autonomous retry loop support beyond the bounded same-contract `generator <-> evaluator` repair loop.
- Broad external task support.
- Generalized production-grade long-running recovery semantics.
- Additional workflow/process machinery beyond what the execution-layer target currently needs.

## Resolved

- **Retry-loop source-of-truth wording was inconsistent** — Fixed in runtime communication closure round
  - Symptom: some runtime source files still implied `retry` was unsupported or future work even though the current mainline requires bounded same-contract repair
  - Root cause: one-way `planner -> generator -> evaluator` wording survived after the bounded repair loop became current scope
  - Impact: High (Evaluator failures could be treated as terminal route output instead of Generator repair input)
  - Fix: aligned runtime truth around `main`-driven `generator_repair_request` / `evaluator_recheck_request`, 10 total Generator attempts, and 3 consecutive same-`failure_signature` checkpoint behavior
- **Planner research decision was only artifact-visible** — Fixed in runtime communication closure round
  - Symptom: Planner could do broad serial repo research before deciding whether helper research was warranted
  - Root cause: `multi_agent_research_decision` was required in `planner_note`, but no pre-research support message made the decision observable to `main`
  - Impact: High for large/unfamiliar repos (Planner could silently skip parallel repo understanding)
  - Fix: added `planner_research_decision` as a support message before broad repo research, plus final field-complete `multi_agent_research_decision` gate in Planner artifact
- **Current-round slice metadata missing** — Fixed in runtime communication closure round
  - Symptom: Planner had scope-cut language but no concrete single-slice metadata that Generator and Evaluator could share
  - Root cause: the fixed Planner sections lacked a lightweight slice compiler field that did not imply a backlog or new runtime stage
  - Impact: Medium to High for larger tasks (Generator/Evaluator could disagree on the bounded unit of work)
  - Fix: required exactly one `handoff_seam.current_round_slice` with readiness, dependency, blocker, verification, and handoff refs
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
- **Phase 6 team-need evaluation** — Superseded by Round 011 runtime-team architecture decision
  - Symptom: after the direct dispatch path was proven, it was still unclear whether the next step should be heavy team orchestration or staying on the simpler mainline
  - Root cause: earlier strategy material discussed multi-round and team-oriented futures, but the current proven runtime path had not yet been used to make an explicit go/no-go decision on teams
  - Impact at the time: Medium (without an explicit decision, scope could expand into unnecessary orchestration machinery)
  - Evidence at the time: converged run `run-1776865379794` proved the installed direct dispatch path could complete the bounded round with planner, generator, evaluator, route, and summary
  - Original conclusion: do not implement heavy teams yet; keep direct installed-agent dispatch as the mainline until a demonstrated team-only blocker appears
  - Superseded by: `docs/exec-plans/PGE_EXECUTION_LAYER_PLAN.md`, `docs/exec-plans/CURRENT_MAINLINE.md`, and `docs/exec-plans/ROUND_011_RUNTIME_TEAM_ORCHESTRATION_PLAN.md`, which now make runtime teams the target architecture and move the blocker to orchestration closure rather than team necessity
  - Current meaning: keep this item only as historical context; do not use it as live architecture guidance
- **Phase 5 canonical interface alignment** — Fixed in Phase 5 alignment round
  - Symptom: the converged proving packet exposed a semantic gap around what counts as evaluator evidence during evaluation versus what is only written after routing
  - Root cause: contracts and orchestration instructions did not explicitly lock `required_evidence`, `latest_evidence_ref`, and summary timing to the same canonical semantics
  - Impact: Medium to High (single-round proving could drift again even after one successful converged run)
  - Evidence: canonical run `run-1776865379794` now serves as the reference packet; contracts and `skills/pge-execute/SKILL.md` were aligned so summary is post-route and evaluator evidence is limited to artifacts available by evaluation time
  - Fix: tightened round/evaluation/runtime-state semantics in both canonical contracts and skill-owned contract copies, and aligned `skills/pge-execute/SKILL.md` to the same evidence timing model
- **Phase 4 canonical smoke proving** — Fixed in Phase 4 proving round
  - Symptom: a bounded round could execute and create the correct deliverable, but the first proving packet blocked because the upstream frame treated post-route control-plane artifacts as pre-PASS acceptance requirements
  - Root cause: the proving packet semantics were too loose about which control-plane artifacts are required during evaluation versus written after routing/convergence
  - Impact: High for proving clarity; execution looked broken even though the deliverable path already worked
  - Evidence: corrected proving run `run-1776865379794` converged with `PASS` and `converged`, and wrote planner, generator, evaluator, runtime-state, and summary artifacts for one fresh deliverable `/code/b/pge/.pge-artifacts/pge-smoke-phase4c-1776865294410.txt`
  - Fix: reran Phase 4 with an upstream plan that kept the repo deliverable acceptance frame narrow while treating round summary as a post-route artifact instead of a pre-PASS prerequisite
- **Per-run runtime state isolation** — Fixed in Phase 3 validation round
  - Symptom: runtime state was persisted as one shared repo-global file, so consecutive runs could overwrite one another
  - Root cause: `skills/pge-execute/SKILL.md` used a fixed `.pge-runtime-state.json` path instead of a per-run path keyed by `run_id`
  - Impact: High for proving correctness across consecutive runs
  - Evidence: consecutive smoke runs `run-1776859767170` and `run-1776860124096` each wrote distinct runtime state files under `.pge-artifacts/`; the legacy repo-global file has an older timestamp and was not updated by those runs
  - Fix: changed the skill to persist runtime state at `.pge-artifacts/{run_id}-runtime-state.json` and validated two consecutive runs against the installed runtime
- **`pge-execute` imperative dispatch path** — Fixed in Phase 2 smoke round
  - Symptom: the installed skill loaded but behaved like descriptive documentation instead of a runnable orchestration surface
  - Root cause: `skills/pge-execute/SKILL.md` did not instruct the main session to parse input, initialize runtime state, dispatch agents, and persist artifacts concretely; generator dispatch also lacked `acceptEdits` mode for bounded repo writes
  - Impact: High (real runtime path stopped before generator/evaluator completion)
  - Evidence: smoke run `run-1776857676` produced planner, generator, evaluator, and summary artifacts; evaluator verdict `PASS`; route `converged`
  - Fix: rewrote `skills/pge-execute/SKILL.md` as an imperative single-round orchestrator and required `mode: acceptEdits` on generator dispatch
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
