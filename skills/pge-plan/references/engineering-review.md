# Engineering Review Reference

Loaded by pge-plan Phase 2. Scale to depth: LIGHT = scope check only, MEDIUM = scope + architecture, DEEP = full assessment.

## Confidence Calibration

For each finding, assign: HIGH (verified in code/docs), MEDIUM (inferred from patterns), LOW (assumption).
LOW-confidence findings that affect correctness must include a verification path and must be verified before finalization.

## Scope Challenge

1. What existing code already partially or fully solves this? Can we reuse rather than rebuild?
2. What is the minimum set of changes that achieves the stated goal? Flag anything that could be deferred.
3. If touching 8+ files or introducing 2+ new abstractions: is there a simpler path with fewer moving parts?
4. Is this the complete version or a shortcut? Prefer the complete version unless there is a strong reason to defer.

## Architecture Assessment

- Component boundaries and coupling — are responsibilities clear?
- Data flow — are there potential bottlenecks or circular dependencies?
- Failure modes — for each new codepath, one realistic production failure scenario.
- Security — auth, data access, API boundaries if relevant.

## Existing Solutions Check

For each pattern or component the approach introduces:
- Does the framework or runtime have a built-in that does this?
- Is there prior art in this codebase that already solves a similar problem?
- If rolling custom where built-in or prior art exists, flag as scope reduction opportunity.

## Complexity Gate

If 8+ files touched OR 2+ new classes/services/abstractions:
- Challenge whether the same goal can be achieved with fewer moving parts.
- If genuinely too large for a single plan, propose phased delivery.
- Record the challenge and resolution explicitly.
- Not a hard block — complex tasks legitimately need complex changes.

## Outside Voice (DEEP only)

Spawn an independent challenge Agent. It receives: selected approach, target areas, acceptance criteria.
It returns: one strongest objection, one missed risk, one simpler alternative (if any).
Integrate valid challenges into the approach decision.

## Scope Reduction Prohibition

Prohibited words/phrases (signal scope reduction drift):
- "simplified", "basic version", "minimal", "v1", "for now"
- "placeholder", "hardcoded for now", "skip for now"
- "future enhancement", "will be wired later", "dynamic in future phase"
- "out of scope" (unless explicitly in Non-goals with rationale)

Only 3 valid reasons to reduce scope:
1. Context budget would overflow executor
2. Missing information that cannot be resolved
3. Dependency conflict that blocks execution
