---
name: pge-spark
description: >
  Local wrapper around Superpowers brainstorming for fuzzy, broad,
  value-laden, or solution-first prompts where the goal must be recovered
  before planning. Ask one question at a time, compare 2-3 framings or
  approaches, write a user-approved spec, and stop before implementation. The
  PGE-specific adaptations are intentionally narrow: write the spec to
  .pge/tasks-<slug>/spark.md and keep the result consumable by later PGE stages
  without importing the broader Superpowers suite.
version: 0.1.0
argument-hint: "<goal, problem, vague direction, or proposed solution>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

# PGE Spark

This is Superpowers brainstorming as a local PGE skill. Use it when the prompt is fuzzy, broad, value-laden, or prematurely narrowed to an implementation path and the real goal still needs to be recovered before planning. Its job is to turn that conversation into a user-approved spec.

Do not treat this as a reduced baseline. Do not turn it into PGE research. Do not add repo-evidence gates, authority ledgers, PGE `planning_handoff` fields, issue plans, or implementation work. Those belong to `pge-research` / `pge-plan`.

The PGE adaptations are intentionally narrow:

- write the spec to `.pge/tasks-<slug>/spark.md`
- use `templates/spec.md` for a research-comparable artifact shape
- keep the output consumable as brainstorming/spec input for later PGE stages, typically via `pge-plan`
- final response uses a `PGE Spark Result` block matching `pge-research` result style

## Core Rule

Start from the user's desired outcome, not from implementation.

The common failure this skill prevents is: user starts with original goal A, the engineer infers implementation path B, and the conversation silently becomes about B. Spark must recover and preserve A before comparing possible paths.

## Hard Boundary

Do not implement. Do not write code. Do not create issues. Do not produce an implementation plan. Do not invoke `pge-research`, `pge-plan`, `pge-exec`, or any implementation skill.

Spark ends when `.pge/tasks-<slug>/spark.md` exists, has been self-reviewed, and the user has approved the written spec or the route is `NEEDS_INFO` / `BLOCKED`.

## Workflow

Follow this workflow exactly.

1. **Explore project context**
   - Read enough of the project to understand relevant vocabulary, constraints, and existing shape.
   - Do not over-research. Context supports brainstorming; it is not the deliverable.

2. **Offer a visual companion when useful**
   - If a diagram, sketch, mockup, or visual would help the user reason, offer it.
   - Do not make visual work mandatory for non-visual problems.

3. **Ask clarifying questions one at a time**
   - Ask only one question per turn.
   - The first blocking question should recover or confirm original goal A, not ask the user to choose implementation path B.
   - Do not open with implementation choices, code paths, libraries, file edits, or B variants before A is explicit.
   - Prefer multiple choice when it makes answering easier.

4. **Propose 2-3 approaches**
   - Compare 2-3 approaches or framings.
   - Each option must say which original goal A it serves.
   - These can include implementation hypotheses, but do not let an implementation hypothesis replace the goal.
   - Recommend one direction and explain why.

5. **Present the design**
   - Present the proposed design/spec in clear sections.
   - After each major section, ask whether it looks right so far.
   - Revise when the user corrects intent, scope, or tradeoffs.

6. **Write the spec**
   - Create `.pge/tasks-<slug>/spark.md`.
   - Use `templates/spec.md`.
   - Preserve the conversation decisions, final direction, alternatives, constraints, and open questions.

7. **Self-review the spec**
   - Re-read the written spec.
   - Fix placeholders, ambiguity, contradictions, missing original-goal-A preservation, missing non-goals, weak success shape, and accidental implementation planning.
   - Do not ask the user about purely editorial fixes.

8. **User reviews written spec**
   - Ask the user to review `.pge/tasks-<slug>/spark.md`.
   - If the user requests changes, update the spec, self-review again, and ask for review again.
   - Do not proceed past spark until the user approves or the route is `NEEDS_INFO` / `BLOCKED`.

9. **Deliver and stop**
   - Report the spec path and route.
   - Stop. Do not start planning or implementation inside this skill.

## Artifact Contract

The artifact should use the same broad output style as `pge-research`: stable sections, explicit route, and next-step metadata. It is still a brainstorming spec, not a research brief.

Required semantics:

- `schema_version: spark.v1`
- `original_goal_A`
- `implementation_hypothesis_B`
- `questions`
- `approaches`
- `selected_design`
- `spec`
- `success_shape`
- `non_goals`
- `open_questions`
- `self_review`
- `user_review`
- `route`

## Route

Use one of:

- `READY_FOR_PLAN` — the user approved the written spark spec
- `NEEDS_INFO` — user input is required before the spec can fairly settle
- `BLOCKED` — the skill cannot write or validate the spec

## Final Response

```md
## PGE Spark Result
- task_dir: .pge/tasks-<slug>/
- spark_path: .pge/tasks-<slug>/spark.md
- schema_version: spark.v1
- route: READY_FOR_PLAN | NEEDS_INFO | BLOCKED
- questions_asked: <n>
- user_review_status: approved | changes_requested | pending
- next_skill: pge-plan .pge/tasks-<slug>/spark.md
```
