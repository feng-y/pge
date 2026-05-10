# PGE Pipeline Progress

Updated: 2026-05-10

## Pipeline Architecture

```
pge-setup (optional warmup) → pge-research → pge-plan → pge-exec
                                    ↓              ↓           ↓
                              .pge/tasks-<slug>/research.md  plan.md  runs/<id>/
```

All artifacts for one task live under `.pge/tasks-<slug>/`.

## Current Versions

| Skill | Version | Lines (entrypoint) | Status |
|-------|---------|-------------------|--------|
| pge-setup | 0.1.0 | ~100 | Stable, minimal |
| pge-research | 0.1.0 | ~200 | Stable, tuned |
| pge-plan | 0.5.0 | 265 | Stable, 13 eval rounds |
| pge-exec | 1.0.0 | 235 | Redesigned, 6 eval rounds |
| pge-execute (legacy) | 0.4.0 | 255 | Preserved for raw Anthropic PGE mode |

## Design Sources

17 patterns integrated from 11 best-practice frameworks:
- GSD: Coverage Audit, Scope Reduction Prohibition, Context Budget, Authority Limits, Goal-backward, Interface-first, Analysis Paralysis Guard, Deviation Classification
- gstack: Confidence Calibration, Decision Classification, Outside Voice
- CE: Depth Classification, Multi-agent Research, Flow Analysis
- Superpowers: Self-Review, No Placeholders, Dot Flow, No-change Guard
- Matt Pocock: HITL/AFK, Vertical Slices
- HumanLayer: Automated/Manual Verification Split
- BMAD: Traceability
- Spec-Kit: Constitution as Input
- RPI: Confidence Scoring
- Anthropic PGE: G+E Separation, Hard Evaluator Thresholds, Bounded Repair Loop

## Evaluation Summary

| Skill | Rounds | Cases | Score |
|-------|--------|-------|-------|
| pge-plan | 13 | 39 | 8.8/10 |
| pge-exec | 6 | 18 | — (newly redesigned) |
| Full pipeline | 6 | 10 | All pass |

## Friction Log

| # | Friction | Where | Impact | Status |
|---|---------|-------|--------|--------|
| 1 | No real-repo runtime validation | pge-exec | Cannot prove G+E team actually works | OPEN — needs smoke test |
| 2 | Evaluator calibration missing | pge-exec evaluator | May be too lenient or strict without few-shot examples | OPEN |
| 3 | pge-execute (legacy) and pge-exec coexist | skills/ | Confusion about which to use | OPEN — need migration path |
| 4 | Compound learnings → config feedback loop untested | pge-exec → pge-setup | Don't know if learnings actually improve future runs | OPEN |
| 5 | No atomic commits per issue | pge-exec generator | Harder to rollback individual issues | DEFERRED |
| 6 | Model escalation on failure not implemented | pge-exec | Stuck failures can't try more capable model | DEFERRED |
| 7 | Multi-round redispatch not implemented | pge-exec | Can't automatically return-to-plan or continue | DEFERRED |

## Paradigm Summary

### Core Principles (from Anthropic + 11 frameworks)

1. **Plan is frozen during execution** — exec never modifies the plan. If wrong, route back.
2. **Generator + Evaluator separation** — self-evaluation is unreliable; independent skeptical evaluation is tractable to tune.
3. **Per-issue execution with per-issue evaluation** — catch errors early, repair precisely.
4. **Bounded repair** — max 3 attempts per issue, no-change guard prevents infinite loops.
5. **Hard thresholds** — Evaluator has automatic verdicts (missing evidence → RETRY, scope drift → BLOCK).
6. **Minimize human-in-loop** — Decision Classification filters to only User Challenge decisions. Authority Limits allow only 3 valid escalation reasons.
7. **Confidence calibration** — every finding tagged HIGH/MEDIUM/LOW. LOW affecting correctness must be verified.
8. **Progressive disclosure** — SKILL.md is routing + dot flow. Details in references/.
9. **Compound accumulation** — every run records learnings that feed back into future research/planning.
10. **Task directory** — one directory per task lifecycle (research → plan → exec).

### Self-Evolution Mechanism

```
pge-exec compound phase
  → writes learnings.md (patterns, deviations, repair insights, verification gaps)
  → appends significant learnings to .pge/config/repo-profile.md
  → next pge-research reads updated config (knows more about the repo)
  → next pge-plan uses config as constitution (avoids past mistakes)
  → next pge-exec benefits from accumulated knowledge
```

Each run makes the next run smarter. This is CE's `/ce-compound` pattern applied to the full pipeline.

### What's NOT Implemented Yet

| Capability | Why deferred | When to add |
|-----------|-------------|-------------|
| Multi-round redispatch | Single round is stable first | After smoke test proves G+E team works |
| Return-to-planner loop | Needs proven single-round first | After multi-round |
| Evaluator few-shot calibration | Need real evaluation data first | After 5+ real runs |
| Model escalation | Current model handles most tasks | When repair loop consistently fails |
| Parallel issue execution | Sequential is simpler to debug | After sequential is proven stable |

## Next Tasks

1. **Smoke test pge-exec** — run `/pge-exec test` and verify G+E team actually works
2. **Real-repo validation** — run full pipeline on a real task (research → plan → exec)
3. **Evaluator calibration** — collect 5+ real evaluation results, tune thresholds
4. **Legacy migration** — decide fate of pge-execute vs pge-exec
5. **Memory sync** — update project memory with pipeline architecture decisions
