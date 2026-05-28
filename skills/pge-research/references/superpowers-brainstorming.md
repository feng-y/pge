# Superpowers Brainstorming Calibration

Use this reference when `pge-research` faces fuzzy, broad, value-laden, or solution-first input. It calibrates behavior; it does not add mandatory output fields beyond `research.v3`.

Superpowers-style brainstorming is valuable because it prevents confident guessing:

- expand before narrowing
- recover original goal A before discussing implementation hypothesis B
- ask one focused question when user authority is required
- turn soft wishes into observable success or failure shape
- write a reviewable artifact and stop before planning or implementation

## Stable execution rules

1. Start from the desired outcome, pain, or success shape.
2. Treat proposed implementation paths as hypotheses until the goal is explicit.
3. Explore only the context that can change goal, scope, success shape, constraints, or route.
4. Compare plausible interpretations when the prompt can mean more than one thing.
5. Ask one question at a time when user authority is required.
6. Write the `research.v3` artifact before claiming completion.
7. Deliver the route and stop.

## Research moves

### 1. Explore context

Read local sources that can change planning: README/CLAUDE contracts, relevant skill/code surfaces, existing artifacts, or current user-provided specs. Do not perform a generic repo survey.

Write useful context into v3 fields:

- `Context.relevant_repo_or_architecture_context`
- `Context.assumptions`
- `Optional: Evidence Notes` when citations matter

If context cannot be inspected enough to avoid guessing, route `NEEDS_REPO_EVIDENCE` or `BLOCKED`, not `READY_FOR_PLAN`.

### 2. Recover A before B

When the prompt names a solution, tool, field, component, or migration path but not the underlying goal, first separate:

- A: original goal / pain / desired outcome
- B: implementation hypothesis / proposed path

If A is unclear and changes planning, ask one goal-recovery question or route `NEEDS_USER`.

### 3. Compare framings when needed

When multiple readings remain plausible, compare 2-3 problem framings, scope interpretations, or success shapes. These are not implementation approaches.

Write the chosen and rejected readings into:

- `Spec Discovery.goal`
- `Spec Discovery.scope`
- `Spec Discovery.non_goals`
- `Direction.rejected_directions`
- `Open Questions`

### 4. Ask targeted questions

Ask only when the answer requires user authority and changes Plan. Good questions include:

```text
What I found: <one sentence>
Why it matters: <how this changes planning>
Recommendation: <default when evidence supports one>
Question: <one focused question>
```

Do not ask implementation trivia that Plan can decide. Do not bundle questionnaires.

### 5. Write the artifact

The artifact is a `research.v3` brief with:

- goal, success shape, scope, non-goals, constraints
- relevant user/repo/architecture context and assumptions
- simplest direction and rejected directions
- blocking and non-blocking questions
- route and route reason
- conditional Implementation Friction or Progressive Feasibility only when triggered

### 6. Self-review and stop

Before routing `READY_FOR_PLAN`, verify:

- A did not become B silently
- success shape is observable enough for Plan
- scope and non-goals prevent silent expansion
- assumptions are labeled
- blocking questions are empty
- conditional gates contain the fields Plan must consume

Route vocabulary is:

```text
READY_FOR_PLAN | NEEDS_USER | NEEDS_REPO_EVIDENCE | BLOCKED
```

After writing the brief, stop. Do not invoke `pge-plan`, create issues, or draft implementation.

## PGE enhancements over plain brainstorming

| Enhancement | Why it exists |
|---|---|
| Repo grounding | Prevents attractive framings from ignoring actual code, docs, config, or workflow contracts. |
| Authority labels | Separates user intent, upstream claims, repo facts, architecture intent, and inference. |
| Conditional friction gates | Prevents Plan from inheriting false system models or unsafe direct goals. |
| Route gate | Ends with an explicit next-stage state instead of implicit approval. |

These enhancements preserve brainstorming behavior. They do not authorize Research to become Plan.
