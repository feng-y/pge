---
name: pge-plan
description: Produce a bounded, docs-aware PGE plan under `.pge/plans/<plan_id>.md` by combining lightweight brainstorming, grill-with-docs self-evaluation, PRD-like synthesis, and executable vertical slices.
version: 0.1.0
argument-hint: "<task intent or planning notes>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# PGE Plan

Produce one bounded, executable PGE plan artifact:

```text
.pge/plans/<plan_id>.md
```

`pge-plan` is a planning skill. It does not execute code, edit implementation files, publish GitHub issues, or invoke `pge-exec`.

## Positioning

`pge-plan` learns from two chains:

1. Superpowers:
   - brainstorming
   - writing-plans
2. Matt skills:
   - grill-with-docs
   - to-prd
   - to-issues

Final positioning:

```text
pge-plan = bounded brainstorming / grill-with-docs
         + PRD-like synthesis
         + executable vertical slices
```

Use Superpowers' forced pause before implementation, option comparison, and plan quality pressure. Use Matt's docs-aware grilling, PRD synthesis, and tracer-bullet vertical slices. Keep PGE lighter than both:

- do not turn planning into an infinite grill
- do not force long brainstorming every time
- do not make a PRD a required large document
- do not bind to GitHub Issues
- do not execute code

## Workflow

### 1. Resolve Input

Read the user's planning intent from `ARGUMENTS:` or the current conversation.

If input is missing or too vague to identify a goal, run Planning Self-Evaluation and ask only if the missing detail is blocking.

### 2. Read Setup Config When Available

Read `.pge/config/*` when present, especially:

- `.pge/config/repo-profile.md`
- `.pge/config/backlog-policy.md`
- `.pge/config/docs-policy.md`
- `.pge/config/artifact-layout.md`
- `.pge/config/verification.md`
- `.pge/config/route-policy.md`
- `.pge/config/open-gaps.md`

If setup config is missing:

- continue in degraded mode for simple planning tasks
- recommend running `pge-setup` first for complex or repo-wide work
- record the missing setup config under `## Risks / Open Questions`

### 3. Explore Repo / Docs / Code

Explore only enough to plan fairly.

Prefer this order:

1. explicit user instruction
2. `.pge/config/*`
3. `CLAUDE.md`
4. `AGENTS.md`
5. `README.md`
6. active skill / contract files under `skills/`
7. `docs/exec-plans/`
8. `docs/design/`
9. code/config/tests relevant to the requested task

If repo/docs/code can answer a question, inspect them instead of asking the user.

### 4. Bounded Brainstorm / Grill

Apply a lightweight design pause:

- clarify purpose, constraints, and success criteria
- compare 2-3 approaches only when multiple viable approaches exist
- recommend one approach with trade-offs
- scale discussion to task size

For tiny, obvious tasks, the brainstorm may be a short paragraph in the final plan. For larger or ambiguous tasks, use a deeper comparison.

### 5. Planning Self-Evaluation

Every potential question must be self-evaluated before asking the user.

For each potential question, record:

- `Question:`
- `Why it matters:`
- `Can repo/docs/code answer it?`
- `Is it blocking execution?`
- `Can we make a safe assumption?`
- `If unanswered, what is the risk?`
- `Decision:`

Allowed decisions:

- `SELF_ANSWERED`
- `ASK_USER`
- `ASSUME_AND_RECORD`
- `DEFER_TO_SLICE`
- `BLOCK_PLAN`

Only blocker questions may use `ASK_USER`.

A question is a blocker only when all of these are true:

- it affects goal boundary, acceptance criteria, or likely implementation correctness
- repo/docs/code cannot answer it
- no safe assumption is available
- continuing would make the plan unfair or guess-driven

All other uncertainty must go into one of:

- `## Assumptions`
- `## Risks / Open Questions`
- a slice with state `NEEDS_INFO`
- a slice with state `NEEDS_HUMAN`

### 6. Synthesize PRD-Like Intent

Synthesize enough product/problem context for execution, but do not create a large PRD by default.

Include:

- intent
- problem
- non-goals
- repo context
- target areas
- acceptance criteria

Avoid:

- exhaustive user-story lists unless the user requested product PRD depth
- broad market/product prose
- stale implementation details that will age quickly

### 7. Create Numbered Executable Issues

Break the plan into thin, executable numbered issues. These issues are local plan units, not GitHub Issues.

Each issue should be independently understandable and verifiable. Prefer a small number of high-signal vertical slices over a long task checklist.

Numbering rules:

- use `Issue 1`, `Issue 2`, `Issue 3`, and so on
- do not skip numbers
- order issues by dependency and safest execution sequence
- do not mark issues as parallelizable
- do not precompute execution batches
- `pge-exec` owns runtime concurrency decisions

Each issue must include:

- `ID`
- `Title`
- `Scope`
- `Target Areas`
- `Acceptance Criteria`
- `Verification Hint`
- `State`
- `Dependencies`
- `Risks`

Allowed initial slice states:

- `NEEDS_TRIAGE`
- `NEEDS_INFO`
- `READY_FOR_EXECUTE`
- `BLOCKED`
- `NEEDS_HUMAN`

Forbidden initial slice states:

- `IN_PROGRESS`
- `DONE_NEEDS_REVIEW`
- `RETRY_REQUIRED`
- `PASS`
- `MERGED`
- `SHIPPED`

### 8. Write Plan Artifact

Create `.pge/plans/` if needed.

Write exactly one plan artifact:

```text
.pge/plans/<plan_id>.md
```

Use a stable `plan_id`, preferably:

```text
YYYYMMDD-HHMM-<short-slug>
```

Do not write `.pge/runs/<run_id>/*`.

### 9. Route

Set the plan route based on slice readiness:

- `READY_FOR_EXECUTE`: at least one slice is `READY_FOR_EXECUTE` and no global blocker prevents execution.
- `NEEDS_INFO`: planning can proceed only after specific missing information is supplied.
- `BLOCKED`: the plan cannot be made fair from current input and repo evidence.
- `NEEDS_HUMAN`: a human decision is needed before execution, but the plan can still record useful context.

Do not use execution or delivery routes.

## Plan Artifact Template

Every plan must use this shape:

```markdown
# Plan: <title>

## Metadata

- plan_id:
- created_at:
- source_input:
- setup_config_refs:
- plan_route:

## Intent

## Planning Self-Evaluation

### Question 1

- Question:
- Why it matters:
- Can repo/docs/code answer it?
- Is it blocking execution?
- Can we make a safe assumption?
- If unanswered, what is the risk?
- Decision: SELF_ANSWERED | ASK_USER | ASSUME_AND_RECORD | DEFER_TO_SLICE | BLOCK_PLAN

## Problem

## Non-goals

## Assumptions

## Repo Context

## Target Areas

## Acceptance Criteria

## Slices

### Issue <N>: <Title>

- ID: <N>
- Title:
- Scope:
- Target Areas:
- Acceptance Criteria:
- Verification Hint:
- State: NEEDS_TRIAGE | NEEDS_INFO | READY_FOR_EXECUTE | BLOCKED | NEEDS_HUMAN
- Dependencies:
- Risks:

## Verification

## Risks / Open Questions

## Handoff To Execute

## Route
```

## Handoff To Execute

`pge-exec` must read:

- the full `.pge/plans/<plan_id>.md`
- `.pge/config/*` if present

The handoff must tell `pge-exec`:

- that issues must be processed by number, starting from the smallest unfinished issue
- which numbered issues are eligible for execution
- which target areas may be touched
- what acceptance criteria apply
- what verification hints exist
- what assumptions must be preserved
- what risks or open questions must not be silently ignored
- that concurrency is decided by `pge-exec` at runtime, not by the plan

If no issue is `READY_FOR_EXECUTE`, say so explicitly in `## Handoff To Execute`.

## Guardrails

Do not:

- write business code
- edit implementation files
- execute the plan
- invoke `pge-exec`
- create `.pge/runs/<run_id>/*`
- require a long brainstorming process for every task
- ask non-blocking questions
- ask multiple questions at once
- make a full PRD mandatory
- publish or require GitHub Issues
- call `TeamCreate`
- dispatch `pge-planner`, `pge-generator`, or `pge-evaluator`
- restore a Planner / Generator / Evaluator Claude Code agent orchestrator
- implement or invoke an SDK runner
- use forbidden slice states: `IN_PROGRESS`, `DONE_NEEDS_REVIEW`, `RETRY_REQUIRED`, `PASS`, `MERGED`, `SHIPPED`

## Final Response

After writing the plan, return:

```md
## PGE Plan Result
- plan_path: <absolute path to .pge/plans/<plan_id>.md>
- plan_route: <READY_FOR_EXECUTE | NEEDS_INFO | BLOCKED | NEEDS_HUMAN>
- ready_issues: <issue ids or None>
- blocked_issues: <issue ids or None>
- asked_user: <yes | no>
- assumptions_recorded: <yes | no>
- next_skill: pge-exec when at least one issue is READY_FOR_EXECUTE; otherwise pge-plan after clarification
```

If the plan is blocked because a true blocker question must be answered, ask exactly one question and do not write a fake-ready plan.
