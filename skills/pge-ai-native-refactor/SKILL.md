---
name: pge-ai-native-refactor
description: >
  Shape one human-selected repo evolution direction into a bounded AI-native
  refactor plan that can later be executed by PGE. Use when a repo area creates
  stable AI friction around entry, containment, verification, structural
  toxicity, or missing mechanical invariants.
version: 0.1.0
argument-hint: "<human-selected repo evolution direction>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---

# PGE AI-Native Refactor

Shape one human-selected repo evolution direction into a bounded AI-native refactor plan that can later be executed by PGE.

This skill does not execute implementation, run PGE, or perform broad architecture modernization. The goal is not architectural elegance. The goal is to reduce one concrete form of AI friction in a real task chain.

## Position In PGE

This skill exists before PGE execution.

```text
human-selected direction
→ pge-ai-native-refactor shaping
→ PLAN_READY | INTERACTION_REQUIRED | BLOCKED
→ pge-plan / pge-exec downstream
```

It shapes work. PGE executes work.

## Core Frame

AI-native repo evolution optimizes for agents being able to:
- enter the system quickly
- understand the correct task chain
- make bounded modifications
- avoid scope explosion
- independently verify correctness
- recover from failures locally
- follow stable domain vocabulary
- operate under predictable structural constraints

Do not start from modules, capability checklists, broad architecture programs, or abstract modernization goals. Start from a real workflow, recurring bugfix path, high-friction task chain, repeatedly failing modification area, or strong human intuition about likely leverage.

## Matt Architecture Vocabulary

When the primary lens is `Cannot Contain`, use Matt Pocock's `improve-codebase-architecture` vocabulary as the architecture sub-lens. Reference: `https://github.com/mattpocock/skills/blob/main/skills/engineering/improve-codebase-architecture/SKILL.md`.

- **Module** — anything with an interface and an implementation.
- **Interface** — everything a caller must know to use the module: types, invariants, error modes, ordering, and config.
- **Implementation** — the code inside.
- **Depth** — leverage at the interface: a lot of behavior behind a small interface.
- **Seam** — where an interface lives; a place behavior can be altered without editing in place.
- **Adapter** — a concrete thing satisfying an interface at a seam.
- **Leverage** — what callers get from depth.
- **Locality** — what maintainers get from depth: change, bugs, and knowledge concentrated in one place.

Use these principles inside the containment diagnosis:
- **Deletion test**: if deleting a module makes complexity vanish, it was pass-through; if complexity reappears across callers, it was earning its keep.
- **The interface is the test surface.**
- **One adapter = hypothetical seam. Two adapters = real seam.**

Do not let this vocabulary dominate every direction. It is most useful for containment. Entry, verification, toxicity, and invariants may need other corrections.

## Failure Lenses

Choose exactly one primary lens for this round:

| Lens | Meaning | Signals |
|---|---|---|
| Cannot Enter | Agent cannot establish a stable entry into the system. | unclear entrypoints, hidden runtime flow, unstable vocabulary, implicit state/config, context explosion |
| Cannot Contain | Agent cannot keep modifications bounded. | many-file change radius, boundary leaks, duplicated variants, shallow modules, false seams, low locality |
| Cannot Verify | Agent cannot independently prove correctness. | unclear validation path, missing evidence, late verification, evaluator-unfriendly flow, hard-to-replay changes |
| Structural Toxicity | Area feels dangerous because history and active logic are tangled. | branch pollution, misleading names, compatibility layers mixed with active logic, hidden invariants |
| Missing Invariant | Repeated failure should be mechanically prevented. | recurring forbidden imports, dependency drift, duplicate paths, missing evidence hooks, weak structural checks |

Do not pursue multiple primary lenses simultaneously. Record secondary observations as risks or follow-ups.

## Workflow

### 1. Direction Intake

Accept one human-selected direction. Classify it under one primary lens. If the direction is too broad, narrow it to one task chain or return `INTERACTION_REQUIRED` with one question.

### 2. Local Zoom-Out

Explore only the relevant local area. Build a cognition map:
- entrypoints
- runtime flow
- callers/callees
- domain concepts and vocabulary
- state/config surfaces
- seams and adapters, using Matt's Module / Interface / Depth / Seam / Adapter / Leverage / Locality vocabulary when containment is the primary lens
- duplicated paths or historical branches
- existing verification surface
- docs, ADRs, and repo rules affecting the area

Use project vocabulary. Do not map the whole repo.

### 3. Toxicity Diagnosis

Identify the dominant friction without reducing everything to generic architecture purity. Useful diagnoses include:
- entrypoint ambiguity
- call-chain opacity
- vocabulary drift
- hidden runtime state
- abstraction-layer inversion
- duplicated code variants
- historical compatibility pollution
- shallow modules
- false seams
- low locality or leverage
- evaluator-unfriendly flow
- missing structural invariant

For `Cannot Contain`, explicitly run the deletion test on suspicious modules and distinguish false seams from real seams. Do not propose a new interface unless the seam has a real adapter need or the plan includes a disposable prototype to test the design assumption.

### 4. First-Round Focus

Choose exactly one first-round focus:
- clarify entry
- tighten boundary
- improve verification
- isolate toxicity
- collapse duplicated variants
- correct one abstraction layer
- define one seam
- add one invariant
- remove one misleading path

The first round should be the smallest meaningful convergence step.

### 5. Plan Shaping

Shape a bounded refactor plan that is local, reversible, independently verifiable, compatible with the existing repo, and low blast radius.

Do not redesign the repo, build a platform, perform broad cleanup, unify unrelated systems, or introduce speculative abstractions.

### 6. Prototype / Spike Decision

Include a prototype slice only when a key design assumption cannot be validated from code/docs alone. A prototype answers one question, remains disposable, avoids production integration, and produces a concrete decision. Prototype code is not the artifact; the decision is.

### 7. Mechanical Invariant Decision

If the same structural failure is likely to recur, propose one mechanical invariant such as:
- dependency linter
- structure test
- forbidden import rule
- canonical entrypoint check
- mandatory boundary validation
- required evidence output
- duplicate path guard

Do not introduce governance overhead without recurring evidence.

## Output Rules

Terminate with exactly one result: `PLAN_READY`, `INTERACTION_REQUIRED`, or `BLOCKED`.

Write the result as a shaping artifact in the current conversation. Do not create `.pge/` artifacts and do not invoke `pge-plan` automatically.

## PLAN_READY Output

Use this when a bounded PGE-ready execution plan exists.

```md
## PGE AI-Native Refactor Result
- route: PLAN_READY
- title: <bounded refactor title>
- direction: <human-selected direction>
- dominant_friction: Cannot Enter | Cannot Contain | Cannot Verify | Structural Toxicity | Missing Invariant
- first_round_goal: <one convergence step>
- downstream: pge-plan <title/slug> or pge-plan from this artifact

## Local Cognition Map
- entrypoints:
- runtime flow:
- domain vocabulary:
- state/config:
- seams:
- duplicated/toxic paths:
- verification surface:

## Diagnosis
<dominant friction and evidence. Separate observation from inference.>

## Non-Goals
- <what this round explicitly does not solve>

## Proposed Structural Correction
<smallest structural correction that reduces the dominant AI friction>

## Execution Slices
### Slice 1: <title>
- scope:
- target areas:
- acceptance criteria:
- verification:
- expected evidence:
- rollback:

## Optional Prototype Slice
<none, or one disposable question-answering spike>

## Optional Mechanical Invariant
<none, or one invariant with recurrence evidence>

## Risks
- <risk and mitigation>

## Open Questions
- <non-blocking question, or none>
```

## INTERACTION_REQUIRED Output

Use this only when one load-bearing human decision blocks fair shaping.

```md
## PGE AI-Native Refactor Result
- route: INTERACTION_REQUIRED
- blocking_question: <one question>
- why_it_matters: <how it changes the shaped plan>
- recommended_answer: <default>
- plan_if_accepted: <what plan would result>
```

Ask exactly one question.

## BLOCKED Output

Use this when no safe bounded plan can currently be formed.

```md
## PGE AI-Native Refactor Result
- route: BLOCKED
- why_shaping_failed: <reason>
- missing_evidence: <what is missing>
- smallest_unblocking_investigation: <next read/test/spike>
```

## Guardrails

- One direction, one primary lens, one first-round focus.
- Prefer autonomous shaping over excessive questioning.
- Use repo evidence before asking.
- Treat structural toxicity explicitly.
- Favor mechanical invariants only when they protect against recurring friction.
- Keep broad architecture review, style cleanup, and implementation out of scope.
