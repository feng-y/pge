# CURRENT_MAINLINE

## Current mainline

Converge the `0.5A / 0.5B` runtime lane so `pge-execute` is the runnable repo-coupled Agent Team surface: one Team, exactly `planner` / `generator` / `evaluator`, one bounded repo-local run, durable phase artifacts, one shared progress log, independent evaluation, and a bounded same-contract `generator <-> evaluator` repair loop.

The immediate sub-lane is restoring executable runtime behavior when TeamCreate / SendMessage capability visibility is uncertain: `/pge-execute` must attempt the real Team control-plane calls before it can report a Team substrate blocker, while preserving Planner research decisions, Generator handoff recovery, and Evaluator retry feedback.

## Why this is the mainline

Repo evidence supports the runtime-team architecture, but the active mismatch is now architectural, not packaging:
- the repo already has stable `planner / generator / evaluator` agent surfaces
- `main` is the orchestration shell / route owner / gate owner, not a fourth agent
- P/G/E are persistent runtime teammates and workflow phase owners
- normal coordination should use `SendMessage`
- Evaluator failure is not a terminal route by itself when the same Planner contract remains fair; it should feed required fixes back to Generator
- current blockers are operational closure in real repos, not broad architecture theory

## Active stage

Stage 0.5 — Agent Teams runtime closure + persistent Planner / Generator / Evaluator responsibility split

## Current blocker

The design intent for `0.5A / 0.5B` is now clear. The active blocker is operational closure in real repos. The current runtime must:

- create the actual Agent Team using the named `pge-planner` / `pge-generator` / `pge-evaluator` agent surfaces, or fail immediately with the concrete Team control-plane error
- Planner must not silently skip parallel repo research when the task scale warrants it
- `main` must not turn missing messages into noisy foreground polling
- Generator handoff gaps must be repaired before selecting a blocked route
- Evaluator retry feedback must loop back to Generator while the same Planner contract remains fair

The current step is to keep Team-only execution strict, then prove visible Planner `multi_agent_research_decision`, artifact-gated recovery as an exception path, the bounded same-contract `generator <-> evaluator` repair loop, and concise progress observation.

## What this round is optimizing for

- keep `main` as the orchestration shell, not a peer agent
- keep `planner`, `generator`, and `evaluator` as the only decision-bearing runtime roles
- move normal Agent Teams coordination to `SendMessage`
- reserve files for durable phase outputs and recovery state
- introduce lighter closure paths for deterministic tasks without giving Planner fast-finish authority
- make Planner run research pass + thin counter-research + architecture pass before freezing the round
- make Planner record whether the multi-agent research scale threshold was met, which helper lanes were used, or why helpers were intentionally skipped
- make Planner send `planner_research_decision` before broad repo research and freeze exactly one `handoff_seam.current_round_slice`
- keep Planner resident as the post-plan research / architecture support lane for `main` and Generator
- keep Generator local-first; only escalate to Planner for broad repo archaeology, architecture interpretation, contract-scope ambiguity, or multi-file pattern discovery
- treat a visible Generator deliverable plus missing `generator.md` / `generator_completion` as a recoverable handoff gap before route selection
- loop Evaluator feedback back to Generator while the same Planner contract remains fair
- cap the loop at 10 total Generator attempts, including the initial generation
- save a repair snapshot and require explicit `main` decision when the same `failure_signature` repeats on 3 consecutive evaluations
- keep the current lane bounded to single-run execution; do not silently claim Phase 2/5 behavior

## Explicit non-goals

- automatic multi-round redispatch
- full autonomous retry loops beyond the bounded same-contract `generator <-> evaluator` repair loop
- return-to-planner loop execution
- checkpoint/resume execution claims
- generic long-running agent OS behavior
- new agents or role proliferation
- non-team direct-execution runtime as the default architecture

## Next single action

Validate that `/pge-execute` can execute a bounded nontrivial repo run through the actual Team control plane using the named `pge-planner` / `pge-generator` / `pge-evaluator` agent surfaces, then records Planner `multi_agent_research_decision` before broad repo research, loops Evaluator retry feedback back to Generator when applicable, separates task outcome from teardown friction, and keeps `main` progress quiet while waiting/recovering.

## Stage exit criteria

This stage is done when:
- Planner / Generator / Evaluator authority is consistent across design and runtime docs
- `/pge-execute` either creates the required Agent Team and starts Planner, or fails immediately with the concrete Team control-plane error
- Planner emits evidence-backed contracts with source/fact/confidence/verification path
- Planner records multi-agent research scale-threshold decisions before non-test contracts
- Planner freezes exactly one ready `current_round_slice` or blocks before Generator dispatch
- Planner records thin rejected-cut reasoning when the round cut is not obvious
- Generator and Evaluator execute the bounded same-contract repair loop for retryable failures
- repeated same-failure snapshots and max-attempt stops are visible to `main`
- task status and teardown status are reported separately
- preflight and phase coordination are messaging-first rather than file-only
- durable artifact boundaries are explicit and mode-aware
- simple deterministic tasks no longer require the full heavy artifact set by default
