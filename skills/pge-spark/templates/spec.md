# Spark: <title>

This is a Superpowers-style brainstorming spec. It is formatted like a PGE stage artifact for comparison, but it is not a `pge-research` brief.

## schema_version: spark.v1

## original_goal_A

- Goal: <desired outcome in the user's words>
- Why it matters: <pain, value, or context>
- Success shape: <what would feel successful>

## implementation_hypothesis_B

- Current hypothesis: <possible path/system framing, or "none yet">
- Status: none | candidate_only | user_confirmed_goal_change
- A/B drift check: <why B still serves A, or what would prove B is wrong>

## questions

- Questions asked: <n>
- First goal question: <question used to recover/confirm A, or "not needed: reason">
- Answers incorporated: <summary>

## approaches

| Approach | What it optimizes for | Tradeoff | Serves goal A by | Risk if wrong |
|---|---|---|---|---|
| A1 | <goal/success emphasis> | <cost/tradeoff> | <connection to original goal A> | <failure mode> |
| A2 | <goal/success emphasis> | <cost/tradeoff> | <connection to original goal A> | <failure mode> |
| A3 | <optional> | <optional> | <optional> | <optional> |

## selected_design

- Recommendation: <selected approach/framing>
- Why this direction: <rationale>
- Why not the others: <short rationale>

## spec

- User / audience: <who this is for>
- Problem: <what is wrong or missing today>
- Desired behavior / artifact: <what should exist after this>
- Scope: <what is included>
- Constraints: <must preserve / must avoid>
- Non-goals: <what is out of scope>

## success_shape

- Observable completion state: <what must be true>
- Would disappoint if: <what would make the result miss the goal>

## non_goals

- <non-goal>

## open_questions

- <question or "none">

## self_review

- Original goal A preserved separately from implementation hypothesis B: yes | no
- Did not open by asking about implementation choices: yes | no | not_applicable
- 2-3 approaches compared before narrowing: yes | no | not_applicable
- Spec stops before planning/implementation: yes | no
- Gaps fixed before user review: <summary>

## user_review

- status: approved | changes_requested | pending
- changes_requested: <summary or "none">

## route

READY_FOR_PLAN | NEEDS_INFO | BLOCKED

Justification: <one line explaining why this route is correct>

## Next

- next_skill: pge-plan
- task_dir: .pge/tasks-<slug>/
