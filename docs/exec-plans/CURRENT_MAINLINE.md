# CURRENT_MAINLINE

## Current mainline

Converge the `0.5A / 0.5B` runtime lane so `pge-execute` uses a real P/G/E team with messaging-first coordination, durable phase artifacts, and lighter closure for simple deterministic tasks.

## Why this is the mainline

Repo evidence supports the runtime-team architecture, but the active mismatch is now architectural, not packaging:
- the repo already has stable `planner / generator / evaluator` agent surfaces
- the current runtime still assumes file-backed handoff everywhere
- smoke tasks still pay the full heavy workflow cost
- the new design lane requires Agent Teams messaging for normal coordination and mode-aware closure for simple tasks

## Active stage

Stage 0.5 — Adaptive execution + Agent Teams communication closure

## Current blocker

The design intent for `0.5A / 0.5B` is now clear, but the runtime authority surfaces still partially encode the old file-only, one-heavy-path model.

The current step is to align design docs, runtime authority docs, and preflight/runtime state seams so later proving runs exercise one coherent architecture.

## What this round is optimizing for

- keep `main` as the orchestration shell, not a peer agent
- keep `planner`, `generator`, and `evaluator` as the only decision-bearing runtime roles
- move normal coordination to `SendMessage`
- reserve files for durable phase outputs and recovery state
- introduce lighter closure paths for deterministic tasks without giving Planner fast-finish authority
- keep the current lane bounded to single-run execution; do not silently claim Phase 2/5 behavior

## Explicit non-goals

- multi-round automation beyond what is needed to define forward-compatible seams
- checkpoint/resume execution claims beyond design/start-of-lane alignment
- new agents or role proliferation
- non-team direct-execution runtime as the default architecture

## Next single action

Converge `0.5A / 0.5B` authority and runtime surfaces, then validate the updated lane with static checks before further proving.

## Stage exit criteria

This stage is done when:
- Planner / Generator / Evaluator authority is consistent across design and runtime docs
- preflight is messaging-first rather than file-only
- durable artifact boundaries are explicit and mode-aware
- simple deterministic tasks no longer require the full heavy artifact set by default
