# pge-research Tuning Log

## Round 1

### Goal
Establish whether `pge-research` behaves differently from baseline on three input classes:
- simple repo-grounded intent
- ambiguous intent needing clarification
- over-scoped intent needing narrowing

### Findings
- **eval1 simple**: with-skill improved artifact shape and explicit route (`NEEDS_INFO`), but baseline already reasoned correctly about missing UI/theming surface.
- **eval2 ambiguous**: both baseline and with-skill moved too quickly into solutioning. The skill did not reliably trigger intent-sharpening before recommending direction.
- **eval3 over-scoped**: with-skill clearly outperformed baseline on stage behavior by producing a structured artifact with `research_route: BLOCKED`.

### Conclusion
Round 1 was a **partial pass**:
- structure / route / artifact discipline: improved
- scope mismatch handling: improved
- ambiguous-intent questioning: insufficient

## Round 2

### Goal
Fix the `eval2` failure mode: when the user explicitly signals uncertainty, the skill should treat that as intent ambiguity and prefer one goal-sharpening question before comparing directions.

### Modifications
1. In `Understanding the intent`, added an explicit trigger: when prompts contain cues like `not sure`, `messy`, `rethink`, or a contrast like `full replacement or refinement`, treat that as intent ambiguity.
2. In `Asking questions`, tightened the rule so explicit user uncertainty is treated as a trigger, not a footnote.
3. Updated `TODO.md` so later learning reviews specifically check for missed intent-sharpening triggers in ambiguous prompts.

### Validation result
- Re-ran the ambiguous-intent case (`eval2`) with the updated skill.
- The updated skill treated the user’s explicit uncertainty as intent ambiguity.
- It asked one goal-sharpening question before locking direction.
- The resulting brief moved to `research_route: NEEDS_INFO` instead of silently choosing a direction and returning `READY_FOR_PLAN`.

### Conclusion
Round 2 fixed the main Round 1 failure. The skill now behaves more like a research stage in ambiguous-intent situations: it sharpens the goal first, then constrains the recommendation.

### Validation result
- Re-ran the remaining with-skill cases to check for ambiguity-trigger overfire.
- `eval1` (simple repo-grounded intent) still asked 0 questions and returned `NEEDS_INFO` based on missing owned UI/theming surface.
- `eval3` (over-scoped repo-mismatch intent) still asked 0 questions and returned `BLOCKED`.
- The new ambiguity trigger improved `eval2` without creating extra unnecessary questions in the other two cases.

### Conclusion
Round 3 suggests the ambiguity trigger is healthy: it fires on explicit goal uncertainty, but not on simple repo-grounded or over-scoped repo-mismatch prompts.

### Next validation
- If we want another round, focus on wording polish rather than behavior fixes.
- Inspect whether the current prose is still too explanatory compared with `brainstorming` / `grill-with-docs` now that the behavior is correct.

## Round 4: Core Friction Confirmation + Authority classification refinement

### Goal
Fix case-study failure: pge-research self-decided core frictions (ACK semantics, reclaim thresholds, trigger/admission predicates) that CC native plan-mode caught through interactive clarification. User emphasized "pge 意图确认还不够" and "一些核心摩擦没有确认，就自行决策."

### Root cause
- Observed reliability mechanisms (ACK ordering, lease recovery, redelivery contracts) were silently promoted to preservation constraints without authority qualification.
- Core frictions affecting safety/correctness/scope (trigger predicates, admission predicates, coverage boundary preconditions) were not consistently surfaced for confirmation.
- Authority enum allowed `observed_behavior` to become a D-constraint without requiring user confirmation, reintroducing the exact failure mode pge-research was designed to prevent.

### Changes (P0+P1, latency-neutral)
**P0:**
1. Added explicit `observed_behavior` rule: observed repo facts are NOT preservation constraints until user confirms intent. Must tag with `observed_behavior` or `repo_evidence / needs_confirmation`, never auto-upgrade to a D-constraint.
2. Added NEW step 7 "Core Friction Confirmation": classify material frictions into **core** (safety/correctness/scope — ACK semantics, reclaim thresholds, trigger predicates, admission predicates, coverage boundary preconditions, observed reliability mechanisms) vs **self-decidable** (reversible impl choices, cosmetic conventions). Core friction → `needs_confirmation` Authority Notes tag + `non_blocking_questions` entry (mandatory, not OR), or route `NEEDS_USER` if genuinely blocking.
3. Expanded Authority Notes enum to include `observed_behavior | repo_evidence / needs_confirmation | inferred_by_research / needs_confirmation` to preserve the confirmation flag across the research→plan handoff.
4. Added P0 checks to step 8 Self-review for core friction confirmation and observed-behavior authority.

**P1 (conditional, only for reliability/recovery/conditional features):**
1. Added "Coverage boundary for recovery/compensation features" to step 5 Context: state the structural precondition the mechanism depends on (e.g., Redis anchor exists, event normalized) and which failure classes fall outside coverage.
2. **Safety amplifier**: design choices with failure mode = data corruption / double-publish / stealing in-flight work / irreversibility auto-upgrade from Taste to Core Friction.
3. Added P1 behavioral-invariant guidance to brief template `relevant_repo_or_architecture_context`: for reliability/recovery features, surface candidate behavioral invariants but tag with authority — observed behavior is `observed_behavior` or `repo_evidence / needs_confirmation`, NOT a confirmed constraint until user confirms.

**Latency control (to address "research 非常的慢，明显感觉比 cc plan 要慢一倍以上"):**
- Tightened step 3 "Collect only task-relevant context" with explicit Agent delegation triggers: reach for Explore only when 6+ files AND 200+ lines AND only-need-conclusion. Keeps inline reads for small/medium context loads to avoid orchestration overhead.
- P1 additions are **conditional gates** (fire only for reliability/recovery/conditional features), not default checks for every task.

### Validation
- Codex review of skill changes identified 5 critical gaps in the cross-stage protocol (authority enum closure, core-friction tagging enforcement, predicate validation); those were fixed in pge-plan side + exec handoffs (see pge-plan Round 9).
- Case study (backfill-fallback-recovery) re-run pending.

### Conclusion
Round 4 addresses the core-friction self-decision failure without adding latency to simple tasks. The P0 authority discipline prevents silent promotion of observed behavior to constraints. The P1 conditional gates catch safety/recovery contract gaps only when relevant. Agent delegation is now gated on concrete thresholds to reduce unnecessary orchestration overhead.
