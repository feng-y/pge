# Phase Contract

## Normalization status

For the current PGE execution-core proof, `agents/*.md` and `contracts/*.md` are the normative seam set.
This file is a supporting reference for stronger planning guidance and must not silently override the normalized entry, round, routing, or runtime-state seams.

Use this file when Planner operates across the continuous planning lane: when the incoming plan is too large, it first slices into the current phase/slice; then it freezes the current phase and shapes the current task as a bounded, plan-faithful execution slice.

## Phase contract

In `pge:plan`, produce the complete current phase plan for execution. In `pge:execute`, freeze that current phase in terms of:
- goal,
- boundary,
- non-goals,
- completion criteria,
- quality bar,
- validation expectations,
- handoff seam,
- anti-overreach rule,
- anti-isolated-skeleton rule.

A good phase contract defines what this phase must settle now, what quality level it must achieve now, and what it must leave for later.

## Entry distinction

In PGE v1, the external input is the upstream plan. The task contract is not the entry artifact.

The task contract is the internal current-round execution contract that Planner freezes after deciding whether the upstream plan can pass through directly or must first be sliced.

## Task contract

Each task must include:
1. **Task name**
2. **Why this belongs to the current phase**
3. **Boundary**
4. **Deliverable**
5. **Validation baseline**
6. **Non-goals**
7. **Handoff / seam**
8. **Blockers / needs confirmation**
9. **Plan fidelity**
10. **Quality bar**
11. **Required validation evidence**
12. **Ambiguity stop rule**

A task contract is not an independent mini-spec. It is the current-round slice of the blueprint that Planner freezes for Generator, and it must preserve the plan’s quality and validation requirements instead of weakening them.

A task contract should represent one single bounded round: one goal, one deliverable, and one primary verification path.

Planner must not create a smaller task contract when the upstream plan is already executable as one bounded round.

## Unacceptable task shapes

Reject tasks like:
- “set up the overall skeleton first”
- “build a minimal version first”
- “fill in the related structure”
- “make a first pass and refine later”
- “just get something working”
- “prepare for future extensibility”
- a slice that omits validation required by the plan
- a slice that weakens the plan’s quality bar to make the round easier
- a slice that expects Generator to resolve blueprint ambiguity
- a slice that can be functionally complete while still violating plan intent

These are too vague, too expansion-prone, too detached from verification, or too willing to shift blueprint decisions into generation.

## Acceptable task shapes

Prefer tasks like:
- freeze one semantic contract needed in this phase,
- add one boundary guard,
- introduce one compat layer with explicit validation evidence,
- define one canonical invariant,
- produce one handoff-ready artifact with an explicit seam.

A good task is **small enough to verify**, **not so fragmented that it becomes bookkeeping**, **explicit about the deliverable and minimum verification**, and **still faithful to the plan’s quality bar**.

## Boundary rules

### Anti-overreach
Do not pull implementation detail, API design, class structure, exception flow, data layout, or future extensibility into the current phase unless the current phase explicitly owns it.

### Anti-isolated-skeleton
Do not leave only names, folders, placeholders, or abstract shells. The current phase must stand on its own **and** show where the next phase attaches.

### Ambiguity stop rule
If high-quality execution depends on interpreting an incomplete, conflicting, or ambiguous blueprint decision, stop and return to Planner through Main / Scheduler instead of letting Generator guess.
