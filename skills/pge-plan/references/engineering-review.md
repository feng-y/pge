# Plan Engineering Review Reference

Loaded by pge-plan Phase 2. Scale to depth: LIGHT = compact scope/reuse/verification sanity, MEDIUM = approach tradeoffs + slicing + architecture + test coverage, DEEP = full execution-topology/protocol/migration assessment with optional outside voice.

## Fix-First Principle

This review is not a report. Every finding must be resolved before proceeding:
- **Mechanical fix** (placeholder, missing edge case, wrong path): fix inline immediately.
- **Judgment call** (architecture choice, scope trade-off): mark as decision point, present options.
- No finding should survive as "noted for later." Either fix it or escalate it.

## Confidence Calibration

Findings should separate evidence strength from decision authority. Use `confidence: high | medium | low` only when the distinction helps decide whether to repair, verify, clarify, or require an upstream source decision.

- `high`: verified by specific code, config, artifact, command, or user/source statement
- `medium`: supported by pattern or nearby evidence but still needs bounded verification
- `low`: plausible but not enough to drive a blocking decision without more evidence

Low-confidence findings that affect correctness must include a verification path or become a recorded assumption/risk. Do not add numeric ratings by default.

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
- If the plan doesn't account for it, add error handling to the relevant issue-file change/validation or flag as a gap.
- Simple CRUD with no new integrations: skip this check.

## Test Coverage Pressure

For each issue, trace the verification coverage:

```
Issue N: <title>
  ├── Happy path: [covered by validation? yes/no]
  ├── Edge cases: [which ones? covered?]
  ├── Error path: [what fails? covered?]
  └── Integration boundary: [if crosses modules, covered?]
```

Gaps in coverage → add to the issue file's validation. Don't just flag — fix.

## Issue File Contract Pressure

For issue-file plans, check progressive disclosure before Final Plan Gate:

- `plan.md ## issues` is schedulable as an index: ID, file path, state, dependencies, verification coupling, execution type, and enough title/summary.
- Each ready `issues/Ixxx.md` can be executed from the issue file plus shared plan context.
- Issue files do not redefine the plan goal, non-goals, forbidden areas, or global verification strategy.
- Hidden coupling is explicit: shared files, runtime paths, fixtures, generated artifacts, or trust-gate commands appear in dependencies or verification coupling.
- Oversized issues are split or marked with serial/shared verification; over-thin issues are merged into adjacent executable slices.
- Embedded full issue bodies under `plan.md ## issues` are repaired by moving them into issue files.

### Closed-Loop Slice Review

For MEDIUM/DEEP plans, record one compact row per ready issue before Final Plan Gate:

| Issue | Issue-local goal | Change | Validation closure | Independent? | Coupling / first trustworthy verification | Review action |
|---|---|---|---|---|---|---|
| I001 | <goal> | <bounded change> | expected + check + evidence present? | yes/no | <none or explicit coupling> | keep / split / merge / rework |

Pass only when each ready issue is an execution unit that can be started without guessing and can prove its own result, or when its non-independent verification coupling and safe strategy are explicit. If an issue is only a setup fragment, placeholder, field addition, broad cleanup bucket, or unverifiable checklist item, merge it into a vertical slice or rework the issue before Final Plan Gate.

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

## Completeness Check

For each viable approach, ask whether it covers the inherited success shape, non-goals, execution boundary, failure modes, and verification evidence. Prefer the approach that satisfies the contract with the smallest blast radius and clearest proof.

If the selected approach knowingly defers part of the requested success shape, the plan must route `NEEDS_INFO` / `NEEDS_HUMAN` / `RETURN_TO_RESEARCH` or mark the deferred part as an explicit non-goal authorized by the source. Do not hide incompleteness behind numeric scores.

## Outside Voice (MEDIUM + DEEP)

Spawn an independent challenge Agent. It receives: selected approach, target areas, acceptance criteria.
It returns: one strongest objection, one missed risk, one simpler alternative (if any).
Integrate valid challenges into the approach decision.

An independent agent reviewing the plan catches blind spots that self-review cannot — the same context window that produced the plan cannot objectively challenge it. Only LIGHT tasks (1-3 files, single module, obvious path) skip this step.

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
