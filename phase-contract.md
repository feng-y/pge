# Phase Contract

Use this file when freezing the current phase and shaping the current task.

## Phase contract

Freeze the current phase in terms of:
- goal,
- boundary,
- non-goals,
- completion criteria,
- handoff seam,
- anti-overreach rule,
- anti-isolated-skeleton rule.

A good phase contract defines what this phase must settle now and what it must leave for later.

## Task contract

Each task must include:
1. **Task name**
2. **Why this belongs to the current phase**
3. **Boundary**
4. **Deliverable**
5. **Minimal verification**
6. **Non-goals**
7. **Handoff / seam**
8. **Blockers / needs confirmation**

## Unacceptable task shapes

Reject tasks like:
- “set up the overall skeleton first”
- “build a minimal version first”
- “fill in the related structure”
- “make a first pass and refine later”
- “just get something working”
- “prepare for future extensibility”

These are too vague, too expansion-prone, or too detached from verification.

## Acceptable task shapes

Prefer tasks like:
- freeze one semantic contract needed in this phase,
- add one boundary guard,
- introduce one compat layer with minimal verification,
- define one canonical invariant,
- produce one handoff-ready artifact with an explicit seam.

A good task is **small enough to verify** but **not so fragmented that it becomes bookkeeping**.

## Boundary rules

### Anti-overreach
Do not pull implementation detail, API design, class structure, exception flow, data layout, or future extensibility into the current phase unless the current phase explicitly owns it.

### Anti-isolated-skeleton
Do not leave only names, folders, placeholders, or abstract shells. The current phase must stand on its own **and** show where the next phase attaches.
