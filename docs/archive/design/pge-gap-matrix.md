# PGE Gap Matrix

## Purpose

This document is gap analysis only. It compares PGE's current stated target with the current runtime and repo support surfaces.

It is not an implementation plan, not an exec plan, not a task breakdown, and not a runtime prompt change.

## Inputs Read

Source state:
- Branch observed: `main`
- This matrix reflects the current working tree files read during this pass.
- Several required runtime files had uncommitted local modifications at read time; those working tree contents are treated as the current local evidence for this matrix.

Required inputs:
- `README.md`
- `CLAUDE.md`
- `AGENTS.md`
- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `agents/pge-planner.md`
- `agents/pge-generator.md`
- `agents/pge-evaluator.md`
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`

Optional inputs:
- `docs/design/research/ref-heavyskill.md`
- `docs/design/research/ref-oh-my-openagent.md`
- `docs/design/research/ref-matt-skills.md`
- `docs/proving/README.md`

Additional contract and handoff inputs read because the requested dimensions require them:
- `skills/pge-execute/contracts/round-contract.md`
- `skills/pge-execute/contracts/runtime-event-contract.md`
- `skills/pge-execute/contracts/helper-report-contract.md`
- `skills/pge-execute/contracts/evaluation-contract.md`
- `skills/pge-execute/handoffs/planner.md`
- `skills/pge-execute/handoffs/generator.md`
- `skills/pge-execute/handoffs/evaluator.md`

Missing inputs:
- None. All requested optional inputs were available in the current repo.

## Current Target Summary

- PGE is a repo-coupled agentic engineering harness for evolving this repo toward AI-native development.
- PGE runs bounded repo-local engineering work through one `main` orchestration shell plus exactly three resident teammates: Planner, Generator, and Evaluator.
- PGE is not a generic agent OS and does not currently claim automatic multi-round redispatch, return-to-planner loop execution, checkpoint/resume execution, or unlimited autonomous retry.
- `main` owns input resolution, team lifecycle, dispatch, route/state/gate decisions, progress/friction logging, failure classification, and teardown; it is not a fourth agent.
- Planner, Generator, and Evaluator are workflow phase owners, not roleplay prompts or one-shot personas.
- Phase-local helpers may be used for bounded research, implementation, review, or verification, but helper outputs are advisory and must return through the owning phase.
- Current executable behavior is one bounded run with messaging-first coordination, durable phase artifacts, one shared progress log, independent evaluation, and a bounded same-contract Generator/Evaluator repair loop.
- Each useful run should either produce a bounded verified repo improvement or expose a concrete missing AI-operability surface.

## Gap Summary

| ID | Gap | Current Evidence | Impact | Priority | Notes |
|---|---|---|---|---|---|
| G1 | No material identity/goal mismatch found | README and CLAUDE.md use the same repo-coupled harness identity; SKILL.md and CURRENT_MAINLINE describe the same one-team P/G/E executable lane | Low | P2 | Treat as explicit non-gap; do not keep refining entry docs |
| G2 | Workflow authority is mostly closed; remaining risk is operational proof, not wording | SKILL.md says `main` is orchestration shell only; ORCHESTRATION.md says `main` is not a fourth agent; agent prompts prohibit helpers from owning route/verdict/contract authority | Low | P2 | Authority model is clear in docs |
| G3 | Planner contract is specified, but nontrivial run proof remains a current blocker | Planner prompt, planner handoff, and round contract require evidence basis, current_round_slice, readiness, stop condition, and research decision; ISSUES_LEDGER still lists silent skip of parallel repo research as P0 | Planner remains a success bottleneck until proven in a real repo run | P0 | Contract shape exists; gap is reliability evidence |
| G4 | Slice compiler exists only as single current-round slice metadata, not as a multi-slice issue compiler | Planner must freeze exactly one `handoff_seam.current_round_slice`; Generator and Evaluator must inspect it; multi-round/backlog scheduling is explicitly out of scope | Limits larger-task decomposition, but does not block current one-run lane | P2 | Do not turn this into GitHub issue workflow yet |
| G5 | Subagent concurrency rules exist, but utilization is not yet proven end-to-end | Planner, Generator, Evaluator prompts define helper budgets and boundaries; helper-report contract forbids recursive delegation and authority transfer | May limit speed/evidence quality and allow accidental serial heavy work | P1 | Planner research-decision proof overlaps with G3 |
| G6 | AI-operability surfaces are present but stale-doc and architecture-discovery surfaces are weak | README/CLAUDE define truth hierarchy; CURRENT_MAINLINE and ISSUES_LEDGER define current lane; validation commands exist; docs/design/research/repo-analysis is already stale by version evidence | PGE can run, but agents may rediscover repo structure or be confused by stale reference docs | P1 | Needs evidence for exact stale-doc failure before P0 |
| G7 | Runtime stability is not operationally closed in real repo runs | CURRENT_MAINLINE names operational closure as active blocker; ISSUES_LEDGER lists P0s for Planner research decisions, quiet recovery, Generator handoff repair, Evaluator retry loop, and shutdown acknowledgement | Directly affects current execution success and route correctness | P0 | Main current blocker |
| G8 | Efficiency friction remains for simple non-test work | SKILL.md has a special `test` light path; ORCHESTRATION and CURRENT_MAINLINE still say simple deterministic tasks should get lighter closure, while normal non-test runs still require full artifacts | Adds latency and user-visible friction, especially for deterministic repo-local tasks | P1 | Not a reason to add new stages |
| G9 | External-practice readiness is partial | HeavySkill, OmO, and Matt research docs exist and map mostly to phase-local helpers, bounded workers, and current-round slice concepts; missing prerequisite is proven runtime closure | Useful later, but should not block stabilization | P2 | Do not import new resident agents or generic OS machinery |

## Detailed Gaps

### G1. Identity / Goal Gap

- Current state: README, CLAUDE.md, AGENTS.md, SKILL.md, ORCHESTRATION.md, and CURRENT_MAINLINE now describe the same PGE direction.
- Evidence:
  - README: "repo-coupled agentic engineering harness for evolving this repo toward AI-native development."
  - CLAUDE.md: same repo identity and co-evolution goal.
  - AGENTS.md: points to CLAUDE.md and lists P/G/E workflow invariants.
  - SKILL.md: "Run one bounded PGE execution using a real Claude Code Agent Team."
  - CURRENT_MAINLINE: one Team, exactly Planner/Generator/Evaluator, one bounded repo-local run, messaging-first coordination, durable phase artifacts, and bounded repair loop.
- Gap: No material identity gap found in current files.
- Impact: Low. The risk is now runtime execution proof, not entry-document alignment.
- Priority: P2.
- Not a gap / already covered:
  - README is enough as a project map.
  - CLAUDE.md has resident rules and truth hierarchy.
  - AGENTS.md is intentionally thin and should not become a separate resident rule source.

### G2. Workflow Authority Gap

- Current state: The authority split is consistently expressed.
- Evidence:
  - SKILL.md says `main` is the orchestration shell only and not a fourth agent.
  - ORCHESTRATION.md says `main` owns dispatch, correction/repair routing, exception handling, run-level progress, and quality gates, but not research, implementation, or final independent quality judgment.
  - Planner prompt says Planner is Round Contract Owner and does not own implementation, final acceptance, or route decisions.
  - Generator prompt says Generator is implementation lead, integrator, and evidence packager, but does not own final approval or route decisions.
  - Evaluator prompt says Evaluator owns independent validation and verdict/next_route signal, while `main` remains final route owner.
  - Helper-report contract says helpers must not send PGE runtime events, freeze contracts, approve deliverables, choose verdict/routes, mutate another phase owner's artifact, or delegate recursively.
- Gap: No material wording gap. The remaining gap is whether the runtime actually follows the authority model under failure and retry conditions.
- Impact: Low as a document gap; high only when connected to G7 runtime proof.
- Priority: P2.
- Not a gap / already covered:
  - `main` is not reasonably ambiguous as a fourth agent in current docs.
  - P/G/E canonical events are defined as phase completion sources.
  - Helper/subagent authority boundaries are explicit.

### G3. Planner Contract Gap

- Current state: Planner has a detailed current-round contract surface.
- Evidence:
  - Planner prompt requires exactly one current-task plan with `goal`, `evidence_basis`, `design_constraints`, `actual_deliverable`, `acceptance_criteria`, `verification_path`, `required_evidence`, `stop_condition`, `handoff_seam`, `planner_note`, and `planner_escalation`.
  - Round contract defines evidence items as `source`, `fact`, `confidence`, and `verification_path`.
  - Planner handoff gate requires `multi_agent_research_decision`, current_round_slice fields, confidence markers, acceptance criteria, verification path, required evidence, stop condition, and planner escalation.
  - Planner prompt says default to not asking questions, research first, ask only when continuing would make the contract unfair or guess-driven, and record low-risk assumptions instead of blocking.
  - CLAUDE.md separately classifies missing information as requirement gap, design choice, or implementation detail.
  - CURRENT_MAINLINE and ISSUES_LEDGER still say Planner must prove `planner_research_decision` before broad repo research and must not silently skip parallel repo research on large/unfamiliar repos.
- Gap: The Planner contract is structurally strong, but current files still identify real-run proof as missing. The most important gap is not a missing section; it is whether Planner reliably follows the compile gate in nontrivial repo work.
- Impact: High. If Planner skips research decision, under-researches the repo, or freezes an unfair contract, Generator and Evaluator inherit wrong scope and `main` may route from a bad frame.
- Priority: P0.
- Not a gap / already covered:
  - Evidence basis shape is defined.
  - Acceptance and verification are required.
  - Stop condition is required.
  - Contract compile gate exists in planner handoff.
  - Implementation details should not automatically become blocking questions, based on CLAUDE.md and Planner question escalation rules.

### G4. Slice / Issue Compiler Gap

- Current state: PGE now has a single current-round slice concept.
- Evidence:
  - Planner prompt says to record exactly one `current_round_slice` in `handoff_seam`.
  - Round contract defines `slice_id`, `ready_for_generator`, `dependency_refs`, `blocked_by`, `parallelizable`, `verification_path`, and `handoff_refs`.
  - Planner handoff gate requires these fields and requires `ready_for_generation: false` when `current_round_slice.ready_for_generator` is false.
  - Generator handoff says to read `handoff_seam.current_round_slice`, stop if it is not ready, and keep implementation inside the named slice.
  - Evaluator handoff says to inspect `handoff_seam.current_round_slice` and verify the deliverable matches the slice.
- Gap: This is current-round slice metadata, not a general issue compiler. There is no multi-slice, multi-round, backlog, GitHub issue, or independent per-slice route system.
- Impact: Medium for future scaling, low for the current one-run lane. Larger tasks must still be reduced to one bounded current slice before Generator dispatch.
- Priority: P2.
- Not a gap / already covered:
  - The current lane intentionally freezes exactly one active slice.
  - AFK/HITL-style readiness is represented by `ready_for_generator` and `blocked_by`.
  - Dependencies and parallelizability are represented inside the single slice.
  - Full issue/backlog scheduling is explicitly out of scope until multi-round runtime exists.

### G5. Subagent Concurrency Gap

- Current state: Bounded phase-local helper concurrency is specified across Planner, Generator, Evaluator, and helper contracts.
- Evidence:
  - Planner supports 0-2 default helpers, normal max 3, hard max 4, with a scale threshold and required `planner_research_decision` before broad repo research.
  - Generator supports coder workers and reviewer helpers with explicit counts, parallel unit criteria, and `helper_decision`.
  - Evaluator supports 0-1 default verification helpers, hard max 2, and requires `verification_helper_decision`.
  - Helper-report contract forbids helper authority over runtime events, contract freeze, approval, verdicts/routes, mutation of phase-owner artifacts, and recursive delegation.
  - ORCHESTRATION.md says helper reports are advisory evidence and owning phase artifacts must reference them.
- Gap: The concurrency policy is present, but current mainline/ledger still need runtime evidence that helpers are used when thresholds are met and skipped only with concrete reasons.
- Impact: Medium. Without proof, nontrivial planning/evaluation may remain serial and slow, or helper non-use may be indistinguishable from accidental under-research.
- Priority: P1, with Planner-specific proof elevated to P0 under G3/G7.
- Not a gap / already covered:
  - Budgets exist.
  - Recursive delegation is forbidden.
  - Helper outputs must return to the owning phase.
  - Helpers cannot own verdict, route, contract, or completion authority.

### G6. Repo AI-operability Surface Gap

- Current state: The repo has several AI-operability surfaces, but not all are equally strong.
- Evidence:
  - README defines runtime source of truth and separates reference/design docs from execution authority.
  - CLAUDE.md defines first reads, truth hierarchy, work discipline, validation commands, and current non-goals.
  - CURRENT_MAINLINE states the active lane, blocker, next single action, and exit criteria.
  - ISSUES_LEDGER records P0/P1/P2 issues and resolved history.
  - Runtime contracts define round, event, evaluation, routing, state, helper report, and related semantics.
  - docs/proving/README.md defines proving run discipline and local install proving sequence.
  - Research docs exist under `docs/design/research/`, but README says they are reference inputs, not runtime authority.
- Gap: PGE has truth hierarchy and current-mainline surfaces, but architecture discovery and stale-doc detection remain weak. There is no single current repo architecture surface comparable to a live CONTEXT/architecture map, and stale reference docs are handled mainly by truth hierarchy rather than explicit freshness metadata.
- Impact: Medium. Planner can still work by reading targeted files, but nontrivial runs may spend time rediscovering repo shape or need to defend against stale reference material repeatedly.
- Priority: P1.
- Not a gap / already covered:
  - Current mainline is discoverable.
  - Validation commands are listed.
  - Failure ledger exists.
  - Runtime truth vs reference docs is explicitly separated.

### G7. Runtime Stability Gap

- Current state: Runtime stability is the active mainline blocker.
- Evidence:
  - CURRENT_MAINLINE says the active blocker is operational closure in real repos.
  - CURRENT_MAINLINE next action is to validate Planner research decisions, Generator/Evaluator retry loop, repeated-failure snapshots, task/teardown separation, and quiet progress observation in a nontrivial repo run.
  - ISSUES_LEDGER P0s include persistent runtime-team architecture not operationally closed, Planner silently skipping parallel repo research, noisy foreground polling, Generator handoff gaps routed as final BLOCK too early, Evaluator retry feedback needing a real loop, and underspecified shutdown acknowledgement target.
  - SKILL.md and ORCHESTRATION.md define missing canonical event repair, degraded artifact-gated recovery, Generator handoff-gap repair, and bounded retry loop, but the ledger still requires proof.
- Gap: The runtime behavior is specified but not yet proven stable end-to-end in real nontrivial repo execution.
- Impact: High. These gaps can directly cause wrong route selection, false blocking, noisy user experience, failed retry convergence, or inability to claim persistent runtime-team operation.
- Priority: P0.
- Not a gap / already covered:
  - Artifact recovery is explicitly degraded/exception path, not normal progression.
  - Missing canonical messages have a one-repair path.
  - Evaluator retry loop is bounded by 10 total Generator attempts and a 3-consecutive same-failure checkpoint.
  - Task outcome and teardown outcome are separated in current docs.

### G8. Efficiency / Friction Gap

- Current state: PGE has a light smoke path but not a generalized low-friction path for simple deterministic non-test tasks.
- Evidence:
  - SKILL.md gives `/pge-execute test` a special minimal protocol, omits normal Generator artifact, keeps wait/recovery observation quiet, and prevents redispatch on idle notification.
  - ORCHESTRATION.md says smoke is a lighter verification lane, not a different orchestration skeleton.
  - CURRENT_MAINLINE says the stage should introduce lighter closure paths for deterministic tasks and stage exit criteria include simple deterministic tasks no longer requiring the full heavy artifact set by default.
  - Generator handoff says normal non-test runs require a durable Generator artifact.
  - ISSUES_LEDGER says noisy foreground polling remains P0 under current operational closure.
- Gap: Deterministic non-test tasks may still pay the full Planner/Generator/Evaluator artifact and handoff cost. The existing light path is scoped to smoke/test behavior.
- Impact: Medium. It increases latency and friction for simple repo-local work and can make PGE feel heavier than the task demands.
- Priority: P1.
- Not a gap / already covered:
  - The smoke/test lane has a clear light protocol.
  - Task scale changes role depth, not stage count, which preserves the architecture.
  - This does not justify adding a fast-finish authority to Planner.

### G9. External Practice Readiness Gap

- Current state: The external research docs are present and mostly map cleanly to PGE's current direction, but they should remain reference inputs.
- Evidence:
  - HeavySkill research maps parallel reasoning and deliberation to bounded phase-internal helpers, not new runtime authorities.
  - Oh My OpenAgent research warns against importing 9+ specialist agents, infinite loops, model-routing complexity, or generic OS behavior; relevant ideas are bounded workers, discipline, context hygiene, and recovery.
  - Matt skills research maps vertical slice thinking to current-round slice structure and warns against over-grilling, repeated questions, and GitHub issue workflow assumptions.
  - README and CLAUDE.md say research/reference docs may inform future changes but must not override runtime truth.
- Gap: PGE is partially ready to absorb these practices because helper boundaries and current-round slice metadata exist. The missing prerequisite is not more research; it is runtime proof that the current lane works before importing additional practice patterns.
- Impact: Low for current execution. Premature adoption could expand PGE into a generic agent OS or create resident-agent proliferation.
- Priority: P2.
- Not a gap / already covered:
  - HeavySkill can map to phase-local helper/deliberation.
  - OmO can map to bounded workers/recovery discipline, not agent expansion.
  - Matt skills can map to current-round slice and missing-detail discipline, not mandatory GitHub issue workflow.

## Highest Priority Gaps

1. Runtime-team operational closure is not proven in a nontrivial repo run.
   - why it matters now: This is the active mainline blocker and directly affects whether PGE can claim the current one-team P/G/E runtime lane works.
   - what evidence supports it: CURRENT_MAINLINE names operational closure as the current blocker; ISSUES_LEDGER keeps persistent runtime-team architecture closure as P0.
   - what not to fix yet: Do not rewrite README/CLAUDE/AGENTS, add new agents, add multi-round redispatch, or broaden into a generic agent OS.

2. Planner research-decision and current-round contract reliability need real-run proof.
   - why it matters now: A weak or under-researched Planner contract makes Generator execution and Evaluator routing unfair before the run starts.
   - what evidence supports it: Planner prompt and handoff define `planner_research_decision`, `multi_agent_research_decision`, and `current_round_slice`; ISSUES_LEDGER still lists silent Planner skip of parallel repo research as P0.
   - what not to fix yet: Do not create a full issue compiler, backlog system, or broad grilling workflow as the next step.

3. Generator handoff recovery and Evaluator retry loop need end-to-end proof.
   - why it matters now: A real deliverable can be misrouted as BLOCK if handoff repair is skipped, and retryable failures can stop too early if Evaluator feedback does not loop back to Generator.
   - what evidence supports it: ISSUES_LEDGER lists Generator handoff gaps and Evaluator retry feedback loop as P0; SKILL.md and ORCHESTRATION.md define the intended repair loop but CURRENT_MAINLINE still asks to validate it.
   - what not to fix yet: Do not implement return-to-planner loop execution, checkpoint/resume claims, or unbounded retry behavior.

## Explicit Non-gaps

- README is already enough as a project map and should not receive another precision-editing round for this work.
- CLAUDE.md and AGENTS.md already define the resident rule entrypoint and workflow invariants clearly enough for the current stage.
- P/G/E identity as workflow phase owners is covered across runtime and agent files.
- `main` is clearly defined as orchestration shell, route/state/gate owner, and not a fourth agent.
- Subagents/helpers are already bounded as phase-local advisory helpers rather than new authorities.
- Marketplace/install work is not a current P0 unless a proving run specifically exposes it as blocking current execution.
- Research docs are available and useful, but they are reference material and should not block runtime stabilization.
- A full multi-slice issue compiler is not required for the current one-bounded-run lane.

## Open Questions for Plan Step

- What nontrivial repo run should be used to prove Planner emits `planner_research_decision` before broad repo research?
- What concrete evidence should show that `handoff_seam.current_round_slice` was consumed by Generator and Evaluator?
- What proving artifact should demonstrate Generator handoff-gap recovery before blocked route selection?
- What proving artifact should demonstrate Evaluator retry feedback looping back to Generator under the same fair contract?
- What evidence should count as sufficient proof that repeated same-failure snapshots and explicit `main` decisions work?
- Should lighter deterministic non-test closure be addressed in the next stabilization plan, or deferred until P0 runtime closure is proven?
- What minimal stale-doc or architecture-discovery surface would reduce repeated repo discovery without creating a new planning framework?

## Non-goals

- This document does not implement fixes.
- This document does not modify runtime prompts.
- This document does not decide the final improvement plan.
- This document does not introduce new agents or stages.
- This document does not require README/CLAUDE/AGENTS precision editing.
