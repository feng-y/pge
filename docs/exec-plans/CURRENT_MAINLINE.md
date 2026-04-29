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

Stage 0.5 — Adaptive execution + Agent Teams communication closure + Planner stabilization

## Current blocker

The design intent for `0.5A / 0.5B` is now clear. The active blocker is now role precision: Planner must ground and freeze the round without leaving Generator or Evaluator to invent missing semantics.

The current step is to finish Planner stabilization and event-contract alignment so `main` advances from one runtime event contract instead of mixed artifact/mailbox heuristics, then move to Generator responsibility stabilization.

## What this round is optimizing for

- keep `main` as the orchestration shell, not a peer agent
- keep `planner`, `generator`, and `evaluator` as the only decision-bearing runtime roles
- move normal coordination to `SendMessage`
- reserve files for durable phase outputs and recovery state
- introduce lighter closure paths for deterministic tasks without giving Planner fast-finish authority
- make Planner run research pass + thin counter-research + architecture pass before freezing the round
- keep the current lane bounded to single-run execution; do not silently claim Phase 2/5 behavior

## Explicit non-goals

- multi-round automation beyond what is needed to define forward-compatible seams
- checkpoint/resume execution claims beyond design/start-of-lane alignment
- new agents or role proliferation
- non-team direct-execution runtime as the default architecture

## Next single action

Finish Planner stabilization, validate the updated contracts, then start Generator responsibility stabilization.

## Stage exit criteria

This stage is done when:
- Planner / Generator / Evaluator authority is consistent across design and runtime docs
- Planner emits evidence-backed contracts with source/fact/confidence/verification path
- Planner records thin rejected-cut reasoning when the round cut is not obvious
- preflight is messaging-first rather than file-only
- durable artifact boundaries are explicit and mode-aware
- simple deterministic tasks no longer require the full heavy artifact set by default
