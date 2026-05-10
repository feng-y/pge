# Engineering Review Reference

Loaded by pge-plan Phase 2. Scale to depth: LIGHT = scope check only, MEDIUM = scope + architecture + test coverage, DEEP = full assessment with outside voice.

## Fix-First Principle

This review is not a report. Every finding must be resolved before proceeding:
- **Mechanical fix** (placeholder, missing edge case, wrong path): fix inline immediately.
- **Judgment call** (architecture choice, scope trade-off): mark as decision point, present options.
- No finding should survive as "noted for later." Either fix it or escalate it.

## Confidence Calibration

Every finding includes a confidence score (1-10):

| Score | Meaning | Display rule |
|-------|---------|-------------|
| 9-10 | Verified by reading specific code/file | Show normally |
| 7-8 | High confidence pattern match | Show normally |
| 5-6 | Moderate, could be false positive | Show with caveat |
| 3-4 | Low confidence, suspicious but may be fine | Suppress from main review |
| 1-2 | Speculation | Only report if severity is blocking |

Format: `[finding] (confidence: N/10) — source: file:line`

LOW-confidence findings (≤4) that affect correctness must include a verification path.

## Scope Challenge

1. What existing code already partially or fully solves this? Can we reuse rather than rebuild?
2. What is the minimum set of changes that achieves the stated goal? Flag anything that could be deferred.
3. If touching 8+ files or introducing 2+ new abstractions: is there a simpler path with fewer moving parts?
4. Is this the complete version or a shortcut? Prefer the complete version unless there is a strong reason to defer.

## Architecture Assessment

- Component boundaries and coupling — are responsibilities clear?
- Data flow — are there potential bottlenecks or circular dependencies?
- Security — auth, data access, API boundaries if relevant.

### Failure Mode Registry

For each new codepath or integration point, describe ONE realistic production failure scenario:
- Not "this might fail" — describe the specific sequence: what triggers it, what breaks, what the user sees.
- If the plan doesn't account for it, add error handling to the relevant issue's Action or flag as a gap.
- Simple CRUD with no new integrations: skip this check.

## Test Coverage Pressure

For each issue, trace the verification coverage:

```
Issue N: <title>
  ├── Happy path: [covered by Test Expectation? yes/no]
  ├── Edge cases: [which ones? covered?]
  ├── Error path: [what fails? covered?]
  └── Integration boundary: [if crosses modules, covered?]
```

Gaps in coverage → add to the issue's Test Expectation. Don't just flag — fix.

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

## Completeness Score

Rate each proposed approach:

| Score | Meaning |
|-------|---------|
| 9-10 | All boundary cases, full error handling, complete verification |
| 7-8 | Covers happy path + major edge cases, some boundaries deferred |
| 5-6 | Happy path only, significant gaps |
| 3-4 | Shortcut that defers substantial work |

Prefer the approach with highest completeness unless cost is disproportionate. If selected approach scores <7, record why the trade-off is acceptable.

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
