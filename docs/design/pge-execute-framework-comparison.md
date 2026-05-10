# pge-execute vs Execution Frameworks Comparison

## Architecture Comparison

| Dimension | Superpowers (subagent-driven) | GSD Executor | pge-execute |
|-----------|------------------------------|--------------|-------------|
| Worker model | Fresh subagent per task | Single executor (fresh across checkpoints) | 3 resident agents (planner/generator/evaluator) |
| Orchestrator | Controller stays in memory | Orchestrator spawns executor | `main` orchestration shell |
| Parallelism | Forbidden across implementers | Wave-based (depends_on) | Generator may use bounded coder workers |
| Review | Two-stage: spec compliance → code quality (separate subagents) | Per-task verify + plan-end self-check | Generator self-review → Evaluator independent verdict |
| Repair | Same implementer fixes; reviewer re-reviews | Rule-based auto-fix (3 attempts) | Bounded generator repair loop (max 10 attempts) |
| Escalation | BLOCKED → 4 sub-cases → human | Checkpoint return (human-verify/decision/human-action) | BLOCKED/ESCALATE → unsupported_route → stop |
| Progress | TodoWrite list | Git commits + SUMMARY.md + STATE.md | progress.jsonl (append-only, best-effort) |
| Termination | All tasks done → final reviewer | PLAN COMPLETE / CHECKPOINT REACHED | verdict=PASS + route=converged |

## Gap Analysis (what pge-execute could learn)

### From Superpowers subagent-driven:

| Pattern | Superpowers | pge-execute current | Gap? | Impact |
|---------|-------------|--------------------|----|--------|
| Two-stage review (spec THEN quality) | Mandatory: spec compliance first, code quality second | Single Evaluator does both | Partial | Evaluator already checks both but not as separate passes |
| Model escalation on failure | "needs more reasoning → re-dispatch with more capable model" | Not present | Missing | Could improve repair success rate |
| Fresh context per task | Each implementer gets clean context | Generator is resident (accumulates context) | Different | Resident model is intentional (repair needs prior context) |
| Final code reviewer over entire implementation | After all tasks, one reviewer checks everything | Evaluator checks per-round | Different | pge-execute is single-round; not applicable |
| Red flags list | Explicit list of anti-patterns to watch for | Anti-patterns in Forbidden Behavior | OK | Already covered |
| "Never retry same model with no changes" | Explicit rule | Not explicit | Missing | Prevents infinite same-failure loops |

### From GSD Executor:

| Pattern | GSD | pge-execute current | Gap? | Impact |
|---------|-----|--------------------|----|--------|
| Deviation rules (4 categories) | Auto-fix bugs / Auto-add critical / Auto-fix blocking / Stop for architectural | Generator handles all as "repair" | Missing | Structured deviation classification improves repair decisions |
| Fix-attempt limit per task (3) | After 3 attempts → defer, continue | Max 10 total + same-failure checkpoint at 3 | Partial | pge-execute has checkpoint but at higher threshold |
| Analysis paralysis guard | 5+ Read/Grep without Edit → STOP | Not present | Missing | Prevents Generator from spinning on research |
| Self-check (assert files/commits exist) | Mandatory post-execution assertion | Generator local_verification | OK | Already covered |
| Slopsquat protection | Package installs are NOT auto-fixable | Not present | Missing | Security concern for auto-repair |
| Checkpoint subtypes | human-verify / decision / human-action | BLOCKED / NEEDS_HUMAN (from plan) | Partial | pge-execute routes to user less granularly |
| Worktree safety guards | Absolute-path containment, protected-ref check | Not present | Missing | Safety for multi-worktree execution |
| Destructive git prohibition | Never git clean/reset --hard/push --force | Not explicit in Generator | Missing | Safety guardrail |
| Atomic commits per task | Strict commit-type taxonomy | Not specified | Missing | Traceability |

### From Superpowers executing-plans:

| Pattern | Superpowers | pge-execute current | Gap? | Impact |
|---------|-------------|--------------------|----|--------|
| "Stop when blocked, don't guess" | Core principle | Generator stops on blocker | OK | Already covered |
| Plan is assumed bite-sized | Each step is 2-5 min | Issues are vertical slices (larger) | Different | Intentional |
| Return to Step 1 if approach changes | Explicit re-plan path | unsupported_route for return_to_planner | Partial | Not yet implemented |

## Prioritized Improvements

### HIGH (稳定执行)

| # | Pattern | Source | What to add |
|---|---------|--------|-------------|
| 1 | "Never retry same model with no changes" | Superpowers | Explicit rule: repair must change something; same input → same output |
| 2 | Analysis paralysis guard | GSD | Generator: N consecutive reads without edit → must act or report blocked |
| 3 | Deviation classification | GSD | Generator repair categories: auto-fix-local / auto-fix-critical / stop-for-architectural |
| 4 | Destructive git prohibition | GSD | Generator guardrail: never force-push, reset --hard, clean -f |

### MEDIUM (安全 + 可追溯)

| # | Pattern | Source | What to add |
|---|---------|--------|-------------|
| 5 | Slopsquat protection | GSD | Generator: failed package install → BLOCKED, not auto-retry |
| 6 | Atomic commits per task | GSD | Generator: commit after each verified work unit |
| 7 | Worktree safety | GSD | Generator: absolute-path containment, protected-ref check |

### LOW (future multi-round)

| # | Pattern | Source | What to add |
|---|---------|--------|-------------|
| 8 | Model escalation on failure | Superpowers | Future: retry with more capable model |
| 9 | Return-to-planner loop | Superpowers/GSD | Already documented as unsupported_route |
