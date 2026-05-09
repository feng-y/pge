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
