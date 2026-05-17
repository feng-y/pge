# PGE Review Depth Gate Design

## Status

Design note.

This document analyzes why `pge-review` can be much slower than focused ad-hoc review, and proposes a lightweight depth gate so review cost scales with risk.

Current implementation note: `skills/pge-review/SKILL.md` already has a trigger-based Coherence Pass. This design does not propose reimplementing that pass. The new work is the Review Depth Gate, conditional sub-agent axis selection, and a `Review Depth` output block.

## Problem

`pge-review` currently behaves like a heavy default workflow:

```text
any review
  -> resolve fixed point
  -> find alignment source
  -> find standards sources
  -> read plan/research/context/diff
  -> run Standards / Semantic Alignment / Simplicity agents
  -> main Verification Story
  -> main Cross-Contract / Coherence checks
  -> aggregate
  -> write review artifact
```

This is appropriate for high-risk work, but expensive for small or obvious changes. The cost comes from fixed setup, repeated context reads, sub-agent startup, and broad default review scope.

The recent coherence miss shows that review needs more whole-contract awareness, but adding that awareness as an always-on broad scan will make the speed problem worse.

## Diagnosis

### 1. Fixed Cost Is Too High

Even small diffs pay for source discovery, standards discovery, multiple review axes, aggregation, and artifact formatting.

### 2. No Risk-Based Entry Gate

Review currently lacks a front-loaded decision like:

```text
what changed?
what risk surface did it touch?
how deep should review go?
```

Without this gate, low-risk diffs can run through the same shape as route/state/schema or cross-module changes.

### 3. Sub-Agents Are Not Free

Parallel agents reduce wall-clock time only when their independent analysis adds enough value. For tiny diffs, agent startup and repeated reading can cost more than the review itself.

### 4. Coherence Checks Need Triggers

Producer / consumer / validator coherence is valuable for semantic contracts, public APIs, schemas, manifests, configs, route/state vocabularies, handoffs, and shared behavior. It should not become a whole-repo scan for every typo or local edit.

## Design Goal

Make `pge-review` scale review depth with risk:

```text
diff
  -> Review Depth Gate
  -> selected axes only
  -> triggered coherence only
  -> same route vocabulary
```

The goal is faster low-risk review without weakening high-risk review.

## Proposed Review Depth Gate

Add a Step 0 after the fixed point is known and before expensive source expansion or sub-agent spawning.

Ordering:

```text
1. Resolve fixed point.
   - If no fixed point is provided and one is needed, keep the existing ask-once behavior.
2. Inspect changed files and a lightweight diff summary.
3. Run Review Depth Gate.
4. Resolve only the alignment / standards sources needed by the selected depth and axes.
```

The gate should not require reading every alignment source up front. It can use file paths, diff shape, and obvious risk triggers first, then upgrade if later source discovery reveals higher risk.

```text
Step 0: Review Depth Gate

Inputs:
- changed files
- diff size
- changed surface type
- task/plan availability
- risk triggers

Outputs:
- review_depth: FAST | STANDARD | DEEP
- triggered_axes
- skipped_axes with reasons
- coherence_required: yes | no
```

## Depth Levels

Depth selection is priority ordered and conservative:

```text
if any DEEP trigger appears -> DEEP
else if any STANDARD trigger appears -> STANDARD
else if all FAST conditions hold -> FAST
else -> STANDARD
```

If the risk level is unclear, upgrade rather than downgrade:

```text
uncertain FAST vs STANDARD -> STANDARD
uncertain STANDARD vs DEEP -> DEEP
```

File count is only a weak hint. A one-file route/state/schema/API/manifest/skill-contract change is still DEEP.

### FAST

Use only when all are true:

- small diff, roughly 1-3 files
- no public API, route/state/verdict, schema, manifest/config, artifact layout, security, persistence, or cross-module behavior
- no meaningful downstream consumers
- no explicit user request for deep review
- no uncertainty about downstream consumers or contract impact
- no plan/spec/contract source that needs semantic alignment review

Behavior:

- main-thread review only
- no sub-agent axes
- still pin fixed point
- still inspect the diff
- still produce a Review Gate route
- run Verification Story
- if a Coherence trigger surface is touched, this is not FAST; upgrade to DEEP

### STANDARD

Use for normal bounded work that is not FAST and does not hit a DEEP trigger:

- multi-file but bounded change
- plan/spec exists or semantic alignment matters, but the diff does not hit a DEEP trigger
- one or two risk surfaces
- no security or broad cross-module coupling
- no route/state/schema/artifact-layout/public-API/manifest/handoff high-risk trigger

Behavior:

- run only relevant axes
- Standards axis if standards-sensitive files changed
- Semantic Alignment axis if behavior/contract/spec alignment matters
- Simplicity axis if implementation code changed
- Coherence Pass if triggered

If there is any live plan/spec/contract source and the diff is not clearly trivial, prefer STANDARD over FAST unless the change is purely mechanical and carries no meaningful semantic alignment risk.

If Coherence Pass is triggered by a high-risk semantic surface, upgrade to DEEP. STANDARD may still run a small coherence-style check for low-risk shared behavior when producer/consumer/validator are obvious and local.

### DEEP

Use when any high-risk trigger appears:

- route/state/verdict vocabulary
- schema or artifact layout
- public API or CLI behavior
- manifest/config consumed by tooling
- handoff or skill contract
- security/auth/data access/secrets/destructive behavior
- persistence/migration/recovery semantics
- cross-module shared behavior
- large diff or unclear ownership

Behavior:

- full axes
- Coherence Pass required
- stronger Verification Story
- explicit producer / consumer / validator / evidence mapping
- artifact output required when task directory exists

## Axis Selection

Axes should be conditional, not automatic.

| Axis | Trigger |
|---|---|
| Standards | Standards-sensitive files, resident rules, config, manifest, style/convention surfaces |
| Semantic Alignment | Plan/spec/contract exists, behavior changed, acceptance/evidence changed, user intent could drift |
| Simplicity | Implementation code changed |
| Verification Story | Always |
| Coherence Pass | Contract/API/route/state/schema/manifest/config/handoff/artifact/shared behavior changed |

Skipped axes must be recorded with a short reason.

FAST has no sub-agent axes. If review needs a sub-agent axis, the selected depth is at least STANDARD.

## Coherence Trigger

Existing state: `pge-review` already contains a trigger-based Coherence Pass. Keep that behavior.

Coherence Pass runs only when the diff changes a semantic surface:

- skill contracts
- handoff schemas
- artifact layouts
- route/state/verdict vocabulary
- public APIs or CLI interfaces
- schemas
- manifests or config consumed by tooling
- shared helpers or behavior with downstream consumers

When triggered, review identifies:

```text
producer: what writes or defines the value / behavior
consumer: what reads, executes, or depends on it
validator: what accepts, rejects, or gates it
evidence: proof that the post-change system is coherent
```

Grep can support evidence but cannot be the only proof for semantic correctness.

## Output Contract Addition

Add this as the first section of `pge-review` output, before `## Standards` / `## Semantic Alignment` / `## Simplicity` / `## Verification Story`:

```md
## Review Depth
- review_depth: FAST | STANDARD | DEEP
- reason: <why this depth was selected>
- triggered_axes: <standards / semantic_alignment / simplicity / verification / coherence>
- skipped_axes: <axis + reason>
- coherence_required: yes | no
```

This keeps faster review auditable. A skipped axis is acceptable only when the reason is explicit.

## Expected Impact

FAST reviews should become much cheaper because they avoid sub-agent startup and broad source expansion.

STANDARD reviews remain close to today's behavior but avoid irrelevant axes.

DEEP reviews remain intentionally expensive because they protect high-risk contracts and cross-module behavior.

## Acceptance Criteria For Future Skill Update

1. `pge-review` starts with a Review Depth Gate.
2. The gate outputs `FAST | STANDARD | DEEP`.
3. Sub-agent axes are selected by trigger, not always-on.
4. The design preserves the existing trigger-based Coherence Pass instead of duplicating it.
5. Uncertain risk upgrades depth rather than downgrading it.
6. FAST / STANDARD / DEEP selection is priority ordered and mutually clear.
7. Verification Story remains always required.
8. Output records selected depth, triggered axes, skipped axes, and coherence requirement as the first output section.
9. Existing Review Gate routes remain unchanged.

## Validation Fixtures

| Fixture | Expected Review Shape |
|---|---|
| one-line typo in docs | FAST, main review only, no coherence unless contract semantics changed |
| small local code refactor with no API change and no downstream uncertainty | FAST, main review + Verification |
| small local code refactor with unclear downstream consumers | STANDARD, selected axes + Verification |
| skill route vocabulary change | DEEP, Semantic Alignment + Coherence + Verification |
| manifest/plugin skill list change | DEEP, Standards + Coherence + Verification |
| one-file schema or route change | DEEP despite file count |
| public API behavior change | DEEP, Semantic Alignment + Coherence + Verification |
| multi-module behavior change | DEEP, selected axes plus integration evidence |

## Non-goals

- Do not remove review rigor for high-risk changes.
- Do not make `pge-review` skip route decisions.
- Do not require whole-repo inspection for every diff.
- Do not add a new review skill.
