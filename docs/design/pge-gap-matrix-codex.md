# PGE Gap Matrix

## Purpose

This document is gap analysis only.

- This document does not implement fixes.
- This document does not modify runtime prompts.
- This document does not decide the final improvement plan.
- This document does not introduce new agents or stages.
- This document does not require README / CLAUDE / AGENTS precision editing.
- This document does not copy external practices directly into PGE.

The goal is to compare the current PGE target with the current runtime truth and identify evidence-backed gaps that affect execution success, stability, efficiency, and repo AI-operability.

## Inputs Read

### Runtime Truth Inputs

- `README.md`
- `CLAUDE.md`
- `AGENTS.md`
- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `skills/pge-execute/contracts/entry-contract.md`
- `skills/pge-execute/contracts/evaluation-contract.md`
- `skills/pge-execute/contracts/round-contract.md`
- `skills/pge-execute/contracts/routing-contract.md`
- `skills/pge-execute/contracts/runtime-event-contract.md`
- `skills/pge-execute/contracts/runtime-state-contract.md`
- `agents/pge-planner.md`
- `agents/pge-generator.md`
- `agents/pge-evaluator.md`
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`
- `docs/proving/README.md`
- `bin/pge-local-install.sh`
- `.claude-plugin/plugin.json`
- `.claude-plugin/marketplace.json`

### Existing Research Baseline Inputs

- `docs/design/research/ref-anthropic.md`
- `docs/design/research/ref-superpowers.md`
- `docs/design/research/ref-gsd.md`
- `docs/design/research/ref-gstack.md`
- `docs/design/research/ref-file-contracts.md`
- `docs/design/research/ref-openspec.md`
- `docs/design/research/ref-best-practice.md`
- `docs/design/research/ref-ai-agent-team-first-hires.md`
- `docs/design/research/repo-analysis.md`

### New Targeted Reference Inputs

- `docs/design/research/ref-heavyskill.md` - present
- `docs/design/research/ref-oh-my-openagent.md` - present
- `docs/design/research/ref-matt-skills.md` - present

### Missing Inputs

- None among the required inputs for this gap pass.

## Current Target Summary

- PGE is currently framed as a repo-coupled agentic engineering harness for evolving this repo toward AI-native development, not as a generic chatbot or roleplay prompt set. Evidence: `README.md`, `CLAUDE.md`.
- The runnable surface is `skills/pge-execute/SKILL.md`, with `main` as the skill-internal orchestration shell and exactly three runtime teammates: `planner`, `generator`, and `evaluator`. Evidence: `README.md`, `SKILL.md`, `ORCHESTRATION.md`.
- `main` owns route, state, gates, progress/friction logging, repair routing, and teardown. It must not implement deliverables, simulate P/G/E, or become a fourth agent. Evidence: `SKILL.md`, `ORCHESTRATION.md`, `CLAUDE.md`, `AGENTS.md`.
- Planner owns the evidence-backed current-round contract and stays resident for bounded research / architecture support after `planner_contract_ready`. Evidence: `agents/pge-planner.md`, `ORCHESTRATION.md`.
- Generator owns real repo work, local verification, integration, evidence packaging, helper integration, and bounded repair work under the frozen contract. Evidence: `agents/pge-generator.md`, `SKILL.md`.
- Evaluator owns independent validation, verdict, route signal, and bounded read-only verification helpers. It does not fix deliverables. Evidence: `agents/pge-evaluator.md`, `evaluation-contract.md`.
- The current lane is one bounded run with message-first coordination, durable phase artifacts, one shared progress log, artifact gates, independent evaluation, and a bounded same-contract `generator <-> evaluator` repair loop. Evidence: `README.md`, `CURRENT_MAINLINE.md`, `SKILL.md`, `routing-contract.md`, `runtime-event-contract.md`.
- The current lane explicitly does not support automatic multi-round redispatch, return-to-planner loop execution, checkpoint/resume execution, generic long-running agent OS behavior, or resident role proliferation. Evidence: `README.md`, `SKILL.md`, `CURRENT_MAINLINE.md`, `ISSUES_LEDGER.md`.

## Research Baseline Summary

| Source | Existing Judgment | Current Relevance | Do Not Re-open |
|---|---|---|---|
| `ref-anthropic.md` | P/G/E separation is valuable because Generator self-evaluation is unreliable; evaluator-optimizer loops work when criteria are measurable; multi-agent research is useful but expensive. | Supports PGE's Planner / Generator / Evaluator split, bounded retry loop, message-first coordination, and independent evaluator gate. | Do not copy Anthropic's SDK file-based communication or full long-running app harness; PGE runs in Claude Code Agent Teams. |
| `ref-superpowers.md` | Design-before-code, scope challenge, option comparison, self-review, and hard gates reduce premature implementation. | Supports Planner contract freeze, rejected cuts, one focused question, and anti-placeholder contract self-check. | Do not import full user-approved spec workflow or high-friction interactive design process as the default PGE path. |
| `ref-gsd.md` | Structured context files, mandatory reads, handoff artifacts, fresh contexts, and blocking constraints preserve continuity. | Supports runtime source-of-truth hierarchy, progress/friction logs, failure ledger, and future checkpoint thinking. | Do not copy GSD's command ecosystem, roadmap machine, or wave execution as current PGE runtime. |
| `ref-gstack.md` | Review pressure should be concrete: named failure modes, evidence, confidence, and fix-first orientation. | Supports Evaluator anti-slop rules, specific `required_fixes`, failure ownership, and confidence-bearing evidence. | Do not import broad CEO/design/security review matrices into PGE's current bounded runtime. |
| `ref-file-contracts.md` | Effective systems separate what/how/steps, use folder-scoped work units, maintain state in files, and distinguish source truth from change proposals. | Supports PGE's runtime contracts, run-scoped artifacts, and current-source vs reference-doc distinction. | Do not overbuild OpenSpec/GSD-style artifact DAGs before current execution stability is proven. |
| `ref-openspec.md` | Specs should describe observable behavior, use delta changes for brownfield work, and apply progressive rigor. | Supports behavior-focused acceptance criteria and lighter deterministic closure paths. | Do not directly adopt OpenSpec's human-driven propose/apply/archive lifecycle or text-delta merge model. |
| `ref-best-practice.md` | Strong Claude Code workflows converge on Research -> Plan -> Execute -> Review, verification-first, small vertical slices, context hygiene, and static artifacts. | Supports vertical slice thinking, explicit verification paths, bounded contracts, and phase-local subagents for context isolation. | Do not copy CRISPY, PR workflow, issue tracking, or broad plugin distribution mechanics into PGE. |
| `ref-ai-agent-team-first-hires.md` | Useful agents are role + tools + knowledge base + workflow + quality gates + shared memory, not prompt personas. | Supports resident P/G/E as workflow actors, helper-decision triggers, and run-scoped shared memory as evidence. | Do not import business-agent roles or treat shared memory as a progression trigger. |
| `repo-analysis.md` | Earlier repo analysis identified PGE's markdown-runtime nature, runtime files, P/G/E roles, and lack of deterministic code runtime. | Useful as historical baseline for architecture and limitations. Several facts are stale against runtime truth, including plugin version, local install target, preflight status, and bounded retry support. | Do not let stale baseline override current runtime truth. Re-check local files before plan work. |

## Gap Summary

Priority definition:

- P0: blocks current execution success, route correctness, or causes unstable real runs.
- P1: limits stability, efficiency, or future iteration.
- P2: useful later, but not current blocker.

| ID | Gap | Current Evidence | Impact | Priority | Notes |
|---|---|---|---|---|---|
| G1 | Entry/runtime identity mostly aligned; stale one-way runtime wording has been corrected in the active runtime truth. | `SKILL.md`, `ORCHESTRATION.md`, `evaluation-contract.md`, and `runtime-event-contract.md` now describe resident P/G/E progression plus bounded same-contract repair. Historical/reference exec-plan docs may still mention older one-way wording. | Active runtime interpretation risk is reduced; stale historical references remain a doc-hygiene caution. | P2 | Runtime-source consistency is addressed for active seams; do not reopen entry-doc polish. |
| G2 | Workflow authority is mostly explicit, but helper report ownership and gating are not normalized. | `CLAUDE.md` and `AGENTS.md` say subagents are phase-local helpers; P/G/E prompts forbid helper authority over route/verdict/contract; `ISSUES_LEDGER.md` lists helper report naming/minimum fields as P1. | Helper outputs may be hard to audit or may fail to appear in durable artifacts even when used. | P1 | P/G/E authority itself is largely covered. |
| G3 | Planner research-decision activation is now protocol-visible, but still needs real nontrivial repo proof. | `planner_research_decision` support message is defined; Planner artifact gate requires field-complete `multi_agent_research_decision`; `ISSUES_LEDGER.md` now points to proving. | Under-researched contracts should be easier for `main` to observe and gate; remaining risk is whether Planner actually follows it in real runs. | P0 | This is now an operational proving gap, not a missing protocol gap. |
| G4 | Minimal current-round slice compiler metadata now exists for the current lane. | Planner must freeze one `handoff_seam.current_round_slice`; Generator must stay inside it; Evaluator must inspect it; `runtime-state-contract.md` maps `active_slice_ref` to that slice id. | Larger tasks now have a shared bounded unit of work; full backlog/AFK/HITL issue management remains out of scope. | P1 | Current-lane slice metadata is addressed; future richer issue compilation remains later work. |
| G5 | Phase-local subagent concurrency exists in prompts, but trigger enforcement and durable helper reports are incomplete. | Planner, Generator, and Evaluator each define helper decisions; `ISSUES_LEDGER.md` still tracks helper report naming/minimum fields; current mainline asks to validate helper decisions in real repos. | Parallel evidence/review may be skipped silently or become non-auditable, reducing stability and speed. | P1 | Planner skip on large repos is captured separately as G3/P0. |
| G6 | Repo AI-operability surfaces exist, but there is no stable repo architecture/domain bootstrap surface for PGE to read every time. | Runtime truth hierarchy exists in `README.md`/`CLAUDE.md`; current state and issues exist in exec-plan docs; research exists under `docs/design/research`; stale facts remain in `repo-analysis.md`; no dedicated current architecture/domain/context bootstrap artifact was found. | Planner may rediscover repo facts repeatedly and may be exposed to stale design/reference material without a freshness signal. | P1 | This is not a call to polish README again. |
| G7 | Runtime stability gaps remain, but the retry-loop communication gap is now implemented in active runtime truth. | `runtime-event-contract.md` defines `generator_repair_request` and `evaluator_recheck_request`; `ORCHESTRATION.md` makes `main` the loop driver; `ISSUES_LEDGER.md` now asks for proving. | Real run success still depends on nontrivial-run validation, handoff recovery, quiet observation, and teardown acknowledgement behavior. | P0 | Strongest remaining execution-success gap is proving the protocol under real run friction. |
| G8 | Execution friction remains high for simple or deterministic tasks. | `CURRENT_MAINLINE.md` says deterministic tasks need lighter closure; `ORCHESTRATION.md` says smoke is lighter but same skeleton; `SKILL.md` has a compact `test` path only. | Increases latency and token cost, and can encourage agents to bypass protocols on small tasks. | P1 | Not a reason to remove P/G/E or add a separate runtime stage. |
| G9 | External-practice readiness is partial: PGE can absorb phase-local helper ideas, but lacks prerequisites for safe adoption of HeavySkill/OMO/Matt patterns. | New references map HeavySkill to bounded parallel reasoning, OMO to workflow authority and recovery discipline, Matt to slice/readiness and context bootstrap; current runtime forbids new resident roles and lacks full slice compiler/helper report conventions. | Useful practices could be misapplied as agent proliferation or heavy default reasoning if prerequisites are skipped. | P1 | External practices are references only, not runtime authority. |

# Detailed Gaps

## G1. Identity / Goal Gap

### Current State

The top-level identity is now mostly consistent. PGE is a repo-coupled agentic engineering harness with `main` plus persistent Planner / Generator / Evaluator workflow teammates. Runtime truth and current mainline agree that the system is bounded and not a generic agent OS.

### Evidence

- `README.md` defines PGE as a repo-coupled agentic engineering harness.
- `CLAUDE.md` says PGE and the repo co-evolve through bounded verified repo improvements or missing AI-operability surfaces.
- `AGENTS.md` defers resident rules to `CLAUDE.md` and names runtime files.
- `SKILL.md` says it is an orchestration shell only and not a fourth agent.
- `CURRENT_MAINLINE.md` defines one Team, exactly P/G/E, message-first coordination, durable artifacts, and bounded `generator <-> evaluator` repair.

### Gap

The active runtime wording drift is addressed: active runtime truth now describes resident P/G/E progression plus bounded same-contract Generator repair / Evaluator re-check. Historical/reference exec-plan docs may still contain older one-way phrasing, but they should not override the active runtime seams.

### Impact

The main remaining risk is stale-reference drift: future work could accidentally consult historical exec-plan prose instead of active runtime truth.

### Priority

P2.

### Not a Gap / Already Covered

README / CLAUDE / AGENTS are sufficient as entry maps for this stage. Do not keep precision-editing entry docs as the active gap work.

## G2. Workflow Authority Gap

### Current State

P/G/E are consistently defined as workflow phase owners. `main` is route/state/gate/teardown owner. Subagents are phase-local helpers and are repeatedly forbidden from owning verdict, route, contract, final approval, or runtime events.

### Evidence

- `CLAUDE.md` and `AGENTS.md` say P/G/E are workflow nodes, `main` owns route/state/gates, and subagents are not workflow authorities.
- `ORCHESTRATION.md` says `main` owns dispatch, correction/repair routing, exception handling, run-level progress, and quality-governance gates.
- `agents/pge-planner.md` forbids delegating final plan ownership or contract freeze authority to helpers.
- `agents/pge-generator.md` says coder workers and reviewer helpers cannot modify the Planner contract, approve work, or send PGE runtime events.
- `agents/pge-evaluator.md` says helpers cannot approve deliverables, choose the verdict/route, or send runtime events.

### Gap

Helper outputs are not yet normalized as durable report artifacts with minimum fields and names. The authority boundary exists, but auditability of helper use is not fully standardized.

### Impact

When helpers are used, `main` and Evaluator may have weak evidence about what was delegated, what facts came back, and how the phase owner integrated or rejected those facts.

### Priority

P1.

### Not a Gap / Already Covered

The basic authority split is already strong. Do not add new permanent agents or let helpers bypass P/G/E.

## G3. Planner Contract Gap

### Current State

Planner has a strong contract surface: evidence basis, design constraints, scope, deliverable, acceptance criteria, verification path, required evidence, stop condition, handoff seam, open questions, planner note, and escalation. Planner also has explicit multi-agent research decision rules.

### Evidence

- `agents/pge-planner.md` requires evidence with source / fact / confidence / verification path.
- `round-contract.md` defines the minimum handoff fields and Planner `multi_agent_research_decision`.
- `agents/pge-planner.md` now requires `planner_research_decision` before broad repo research after only small intake.
- `runtime-event-contract.md` defines `planner_research_decision` as support traffic, not phase completion.
- `CURRENT_MAINLINE.md` says the next action is to validate that nontrivial repo runs record the decision before broad research.
- `ISSUES_LEDGER.md` lists silent skipping of parallel repo research as P0.

### Gap

The protocol and gates now exist, but real-run activation is not yet proven. The current concern is whether Planner follows the early support-message decision and field-complete artifact gate in large or unfamiliar repos.

### Impact

Planner may freeze an under-researched contract. Generator then absorbs broad repo archaeology, asks Planner too late, or implements against weak acceptance criteria. This directly affects execution success and route correctness.

### Priority

P0.

### Not a Gap / Already Covered

Planner already owns researcher + architect responsibilities. Do not split Planner into separate resident researcher/architect agents.

## G4. Slice / Issue Compiler Gap

### Current State

PGE supports one bounded current-round task. Planner can choose a cut, record rejected cuts, and now freeze exactly one `handoff_seam.current_round_slice` for the current lane. It still does not emit a backlog or a set of independently executable future slices.

### Evidence

- `agents/pge-planner.md` says Planner defines the slice boundary, prefers the simplest deliverable-first slice, and records one `current_round_slice`.
- `CLAUDE.md` says prefer bounded, verifiable slices.
- `runtime-state-contract.md` maps current-lane `active_slice_ref` to `handoff_seam.current_round_slice.slice_id`.
- `round-contract.md` defines the current-round slice shape with readiness, dependency, blocker, verification, and handoff refs.

### Gap

Planner now has current-lane single-slice metadata, but not a multi-slice issue compiler. It cannot yet turn a larger input into a durable set of future vertical slices with AFK/HITL readiness or backlog semantics.

### Impact

Large tasks now get a clearer active-slice seam, but future iteration still lacks a durable multi-slice queue. This limits broader repo AI-operability, not the current single-run lane.

### Priority

P2 for the full issue compiler; current-lane slice metadata is addressed.

### Not a Gap / Already Covered

Current PGE intentionally does not support multi-round redispatch. Lack of full backlog execution is not P0 by itself.

## G5. Subagent Concurrency Gap

### Current State

All three phase owners define bounded helper usage:

- Planner: read-only research/challenge helpers.
- Generator: coder workers and reviewer helpers.
- Evaluator: read-only verification helpers.

Each phase owner remains responsible for synthesis and canonical completion.

### Evidence

- `agents/pge-planner.md` defines `multi_agent_research_decision`, helper thresholds, helper count limits, and read-only helper boundaries.
- `agents/pge-generator.md` defines `helper_decision`, coder worker limits, reviewer helper limits, and Generator integration ownership.
- `agents/pge-evaluator.md` defines `verification_helper_decision`, helper limits, and verdict ownership.
- `ISSUES_LEDGER.md` says helper report artifact naming and minimum fields are not normalized.

### Gap

Concurrency is defined as prompt behavior, but its durable evidence shape is incomplete. It is not yet clear how helper reports are named, where they live, which minimum fields they must carry, and how gates confirm that helper decisions were not skipped when triggers fired.

### Impact

Phase owners may silently skip helpful parallelism, or use helpers in ways that cannot be reviewed later. This limits both speed and confidence, especially on larger repo tasks.

### Priority

P1.

### Not a Gap / Already Covered

Helper authority boundaries are already well covered. The gap is evidence and enforcement, not permission to create more agents.

## G6. Repo AI-operability Surface Gap

### Current State

PGE has several AI-operability surfaces: runtime contracts, P/G/E prompts, current mainline, issue ledger, proving guide, research references, plugin manifests, and local install scripts.

### Evidence

- `README.md` lists runtime source of truth and reference/design docs separately.
- `CLAUDE.md` defines first reads and truth hierarchy.
- `CURRENT_MAINLINE.md` and `ISSUES_LEDGER.md` provide current stage and blocker state.
- `docs/proving/README.md` defines proving/development run discipline.
- `repo-analysis.md` exists but contains stale facts relative to current runtime truth, such as plugin version `0.1.3`, old local install target, preflight assumptions, and old retry support status.

### Gap

The repo lacks a compact, current, runtime-authoritative architecture/domain/bootstrap surface that PGE can read to avoid rediscovering repo facts every run. It also lacks an explicit freshness signal that tells agents which research/reference docs are stale versus current.

### Impact

Planner can spend too much time rediscovering stable repo facts or accidentally consume stale baseline material. This reduces efficiency and can weaken evidence quality.

### Priority

P1.

### Not a Gap / Already Covered

The current truth hierarchy is enough to prevent reference docs from overriding runtime truth. This is not a reason to edit README again.

## G7. Runtime Stability Gap

### Current State

The current runtime contains detailed rules for message-first progression, artifact gates, degraded recovery, Generator handoff repair, retry loops, repeated-failure snapshots, and teardown separation. The issue ledger still classifies operational closure as not yet complete.

### Evidence

- `runtime-event-contract.md` says `main` must not advance from artifact existence, progress logs, shell polling, task state, or prose summaries.
- `runtime-event-contract.md` defines one protocol repair request and degraded artifact-gated recovery only when gates pass.
- `SKILL.md` defines Generator handoff gap repair before blocked routing.
- `SKILL.md`, `ORCHESTRATION.md`, and `routing-contract.md` define bounded retry with 10 Generator attempts and a 3-consecutive same-failure checkpoint.
- `ISSUES_LEDGER.md` lists P0s for proving Planner decision messages, Generator handoff gaps, Evaluator repair/recheck loop behavior, quiet recovery observation, and shutdown acknowledgement target.

### Gap

The stability rules are specified, and the retry-loop communication protocol is now present in active runtime truth. The current weak points are proving message repair behavior, Generator handoff repair, repair/recheck loop behavior, repeated-failure snapshotting, and teardown acknowledgement routing in real runs.

### Impact

This can cause real runs to hang, stop too early, lose recoverable work, misreport task failure as teardown failure, or route from incomplete artifacts.

### Priority

P0.

### Not a Gap / Already Covered

Task outcome and teardown outcome are already semantically separated in `SKILL.md` and `ORCHESTRATION.md`. The gap is execution reliability and consistency, not the conceptual distinction.

## G8. Efficiency / Friction Gap

### Current State

PGE keeps one skeleton for all tasks, with a lighter smoke/test path. Current mainline still calls out lighter closure for deterministic tasks and quiet progress observation.

### Evidence

- `ORCHESTRATION.md` says all tasks use the same skeleton and task scale changes depth, not stage count.
- `SKILL.md` has a special compact `test` path.
- `CURRENT_MAINLINE.md` says deterministic tasks need lighter closure and progress observation must stay concise.
- `ISSUES_LEDGER.md` lists noisy foreground polling as P0/M-H impact.

### Gap

Outside the fixed `test` path, PGE does not yet have a well-proven light path / depth profile for simple deterministic repo work. It also still treats quiet observation as an active blocker rather than a closed invariant.

### Impact

Simple work can pay the cost of full durable artifacts and heavy waiting behavior. This increases latency and encourages protocol shortcuts.

### Priority

P1.

### Not a Gap / Already Covered

Lighter closure should not remove P/G/E or create new runtime stages. The research baseline warns that complexity should scale only when it improves results.

## G9. External Practice Readiness Gap

### Current State

The new targeted references are useful, but PGE is only partially ready to absorb them:

- HeavySkill maps to phase-local bounded parallel reasoning and deliberation.
- Oh My OpenAgent maps to workflow authority, orchestration/worker separation, context hygiene, and recovery discipline.
- Matt skills map to repo context bootstrap, vertical slices, ready-for-agent readiness, and question classification.

### Evidence

- `ref-heavyskill.md` warns against default heavy thinking and high K parallelism.
- `ref-oh-my-openagent.md` warns against 9+ specialist role proliferation and unbounded loops.
- `ref-matt-skills.md` warns that grilling can over-question without state and highlights vertical slices plus context vocabulary.
- `CLAUDE.md` forbids default heavy thinking, generic agent OS expansion, and new resident agents unless current mainline requires it.
- Current runtime has helper boundaries but lacks slice compiler and helper report conventions.

### Gap

PGE needs prerequisite concepts before safely adopting external practices: bounded trigger rules, helper reports, slice readiness, and repo bootstrap. Without those, external practices can be misapplied as default heavy reasoning, resident role proliferation, or GitHub-style issue workflows.

### Impact

External research could increase complexity without improving current run stability. It can also blur P/G/E authority if adopted literally.

### Priority

P1.

### Not a Gap / Already Covered

External references already agree with PGE's current direction: keep P/G/E as phase owners, use helpers locally, and preserve `main` as orchestrator. Do not reopen the basic three-role architecture.

# Highest Priority Gaps

## G7: Runtime Stability Gap

### Why it matters now

It directly affects whether real runs complete, repair, or stop correctly. Recent failures involved missing handoff artifacts/events, foreground polling noise, teardown acknowledgement problems, and Evaluator failures not flowing back to Generator.

### Evidence

- `ISSUES_LEDGER.md` P0 blocker list.
- `runtime-event-contract.md` repair and progression rules.
- `SKILL.md` Evaluator loop and final result mapping.
- `ORCHESTRATION.md` route behavior and failure ownership matrix.

### What not to fix yet

Do not add checkpoint/resume execution, multi-round redispatch, or new runtime stages as part of this gap.

## G3: Planner Contract Gap

### Why it matters now

Generator can only stay implementation-focused if Planner produces an evidence-backed contract and uses helper research when repo understanding crosses the scale threshold. Otherwise Generator becomes researcher + architect + coder, which is the failure mode the current mainline is trying to avoid.

### Evidence

- `agents/pge-planner.md` multi-agent research decision rules.
- `round-contract.md` Planner note shape.
- `CURRENT_MAINLINE.md` next single action.
- `ISSUES_LEDGER.md` P0 on Planner silently skipping parallel repo research.

### What not to fix yet

Do not split Planner into new resident researcher/architect agents. Do not make Planner implement. Do not build a multi-round planner/backlog system.

## G5: Subagent Concurrency Gap

### Why it matters now

P/G/E helper usage is bounded and authority-safe on paper, but helper reports and trigger evidence still need normalization/proving. Without durable helper evidence, parallel work can become invisible, skipped silently, or hard for Evaluator to audit.

### Evidence

- `agents/pge-planner.md`, `agents/pge-generator.md`, and `agents/pge-evaluator.md` define phase-local helper decisions.
- `ISSUES_LEDGER.md` still lists helper report artifact naming and minimum fields as P1.
- `CURRENT_MAINLINE.md` still requires proving helper decisions in real repos.

### What not to fix yet

Do not add new resident agents, recursive delegation, or a heavy default reasoning mode.

# Explicit Non-gaps

- README / CLAUDE / AGENTS are good enough for current entry alignment. Do not keep polishing them in the active gap lane.
- P/G/E authority is already substantially clear. `main` is not a fourth agent, and helpers are not workflow authorities.
- Evaluator anti-slop semantics are already strong: it must inspect the actual deliverable, validate contract compliance, and avoid accepting Generator self-report or artifact existence alone.
- Generator's real-deliverable and local-verification expectations are already strong. Do not redesign Generator from scratch.
- Marketplace/plugin packaging is not a current P0. The marketplace path is still unverified, but local install and manifest truth are clear enough for proving.
- External research docs are references, not runtime authority. HeavySkill, Oh My OpenAgent, and Matt skills should not override current PGE contracts.
- New resident agents are not justified by the current evidence. Phase-local helpers are the correct current seam.
- Generic long-running agent OS behavior is explicitly out of scope.

# Open Questions for Plan Step

- Should the next plan attack runtime stability first, Planner research-decision activation first, or slice compiler shape first?
- Which gaps can be fixed by aligning runtime-source wording, and which require changing phase prompts or gates?
- What concrete run evidence is needed to prove Planner `multi_agent_research_decision` is triggered before broad repo research?
- What is the minimum slice compiler vocabulary that improves Planner output without becoming a backlog system?
- What helper report fields are needed for Planner, Generator, and Evaluator without making every helper output heavy?
- Should repo bootstrap be a compact current-state artifact, an update to existing `repo-analysis.md`, or a new runtime-authoritative surface?
- How should PGE distinguish a requirement gap from a design choice or implementation detail during Planner intake without adding grill-style friction?

# Non-goals

- This document does not implement fixes.
- This document does not modify runtime prompts.
- This document does not decide the final improvement plan.
- This document does not introduce new agents or stages.
- This document does not require README / CLAUDE / AGENTS precision editing.
- This document does not copy external practices directly into PGE.
