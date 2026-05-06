# CURRENT_MAINLINE

## Current mainline

Converge the `0.5A / 0.5B` runtime lane so `pge-execute` uses a real P/G/E team with messaging-first coordination, durable phase artifacts, and lighter closure for simple deterministic tasks. The immediate sub-lane is Planner stabilization before Generator stabilization.

## Why this is the mainline

Repo evidence supports the runtime-team architecture, but the active mismatch is now architectural, not packaging:
- the repo already has stable `planner / generator / evaluator` agent surfaces
- the current runtime still assumes file-backed handoff everywhere
- smoke tasks still pay the full heavy workflow cost
- the new design lane requires Agent Teams messaging for normal coordination and mode-aware closure for simple tasks
- Planner currently has the right fields but must reliably produce evidence-backed bounded contracts before Generator responsibilities can be tightened

## Active stage

Stage 0.5 — Adaptive execution + Agent Teams communication closure + resident Planner/Generator responsibility split

## Current blocker

The design intent for `0.5A / 0.5B` is now clear. The active blocker is operational closure in real repos: Planner must not silently skip parallel repo research when the task scale warrants it, `main` must not turn missing messages into noisy foreground polling, and Generator handoff gaps must be repaired before selecting a blocked route.

The current step is to enforce a visible Planner `multi_agent_research_decision` with a scale threshold before broad repo research, keep artifact-gated recovery as an exception path, run a bounded evaluator-to-generator repair loop for retryable failures, and keep progress observation concise and structured.

## What this round is optimizing for

- keep `main` as the orchestration shell, not a peer agent
- keep `planner`, `generator`, and `evaluator` as the only decision-bearing runtime roles
- move normal coordination to `SendMessage`
- reserve files for durable phase outputs and recovery state
- introduce lighter closure paths for deterministic tasks without giving Planner fast-finish authority
- make Planner run research pass + thin counter-research + architecture pass before freezing the round
- make Planner record whether the helper scale threshold was met, which helper lanes were used, or why helpers were intentionally skipped
- keep Planner resident as the post-plan research / architecture support lane for `main` and Generator
- keep Generator local-first; only escalate to Planner for broad repo archaeology, architecture interpretation, contract-scope ambiguity, or multi-file pattern discovery
- treat a visible Generator deliverable plus missing `generator.md` / `generator_completion` as a recoverable handoff gap before route selection
- loop Evaluator feedback back to Generator while the same Planner contract remains fair, with repeated-failure snapshotting and main decision points
- keep the current lane bounded to single-run execution; do not silently claim Phase 2/5 behavior

## Explicit non-goals

- multi-round automation beyond what is needed to define forward-compatible seams
- checkpoint/resume execution claims beyond design/start-of-lane alignment
- new agents or role proliferation
- non-team direct-execution runtime as the default architecture

## Next single action

Validate that a nontrivial repo run records Planner `multi_agent_research_decision` before broad repo research, loops Evaluator retry feedback back to Generator, snapshots repeated same failures for main decision, and keeps `main` progress quiet while waiting/recovering.

## Stage exit criteria

This stage is done when:
- Planner / Generator / Evaluator authority is consistent across design and runtime docs
- Planner emits evidence-backed contracts with source/fact/confidence/verification path
- Planner records helper scale-threshold decisions before non-test contracts
- Planner records thin rejected-cut reasoning when the round cut is not obvious
- preflight is messaging-first rather than file-only
- durable artifact boundaries are explicit and mode-aware
- simple deterministic tasks no longer require the full heavy artifact set by default
