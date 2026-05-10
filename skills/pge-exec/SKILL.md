---
name: pge-exec
description: Main-led, plan-driven execution workflow for numbered PGE issues from `.pge/plans/<plan_id>.md`, with bounded worker dispatch, local repair, lightweight gates, and next-route output under `.pge/runs/<run_id>/`.
version: 0.1.0
argument-hint: "<plan path or plan_id> [optional issue id]"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---

# pge-exec

## Purpose

`pge-exec` is a main-led, plan-driven execution workflow for numbered issues.

It reads repo-local PGE configuration, reads one plan artifact, advances from the smallest unfinished numbered issue, optionally executes a narrow adjacent issue window with bounded workers, gathers evidence, applies lightweight gates, and writes the next route.

## Anti-Pattern: "Let Me Replan While Executing"

Execution is not planning. If you discover the plan is wrong, route to `NEEDS_MAIN_DECISION` with evidence. Do not silently change direction, expand scope, or rewrite the approach mid-issue.

## Anti-Pattern: "Let Me Fix Everything I See"

Stay inside the assigned issue's scope and target areas. Nearby code may have problems, but fixing them is scope creep. Record observations in the self-review if they matter for future work.

## Anti-Pattern: "Repair Forever"

Two repair attempts is the default budget. If the fix isn't working after two tries, the problem is likely architectural, not a typo. Route to `RETRY_RECOMMENDED` and let a human or re-plan decide.

TDD is only one possible execution mode when the plan and issue shape justify it.

## When to use

Use `pge-exec` when:

- `.pge/config/*` exists
- `.pge/plans/<plan_id>.md` exists
- the plan contains numbered issues such as `Issue 1`, `Issue 2`, `Issue 3`
- at least one issue is not complete
- the user wants to advance implementation from the plan

Do not use `pge-exec` to create setup config, create a plan, evaluate final acceptance, merge, tag, or ship.

## Inputs

Required inputs:

- `.pge/config/route-policy.md`
- `.pge/config/artifact-layout.md`
- `.pge/config/verification.md`
- `.pge/config/docs-policy.md`
- `.pge/plans/<plan_id>.md`
- current git status
- current repo state

Plan issue fields required by `pge-exec`:

- numbered issue id, such as `Issue 1`
- issue state
- issue scope
- target areas
- acceptance criteria
- verification hint
- dependencies
- risks / open questions
- handoff to exec

If required config or plan inputs are missing, stop before editing and route to `NEEDS_INFO` or `BLOCKED`.

## Workflow

### 1. Load Context

Load:

- `.pge/config/*`
- `.pge/plans/<plan_id>.md`
- `.pge/tasks-<slug>/research.md` if referenced by the plan's `research_brief_ref`
- `git status --short`
- current repo files relevant to the next issue

Use docs-policy to decide what to read. Keep context proportional to the current execution window. The research brief is reference context only — do not re-derive the plan from it.

### 2. Preflight

Check:

- required config exists
- plan exists
- plan has a numbered issue list
- issue fields are present
- current git status has no unsafe dirty changes
- verification entrypoints are known or explicitly unavailable

Dirty worktree rule:

- If dirty changes are unrelated and safe to preserve, continue carefully.
- If dirty changes overlap target areas or make ownership unclear, stop with `NEEDS_HUMAN` before editing.
- Never revert user changes unless explicitly requested.

### 3. Numbered Issue Progression

Find the smallest unfinished issue.

Rules:

- start from the smallest unfinished issue
- do not freely choose tasks
- do not skip issue numbers
- the current smallest unfinished issue must enter the execution window
- inspect only subsequent adjacent issues for safe concurrency
- default to serial execution
- run adjacent issues concurrently only when they are obviously independent
- if uncertain, execute serially

Concurrency is decided by main / the `pge-exec` controller at runtime.

Concurrency is not decided by:

- `pge-plan`
- a worker
- a subagent

### 4. Sprint Contract

Write `.pge/runs/<run_id>/sprint-contract.md` before implementation.

The sprint contract must include:

- selected issue ids
- why the execution window is serial or concurrent
- each issue's scope
- non-goals
- target areas
- acceptance criteria
- verification
- max repair attempts

Default:

```text
MAX_REPAIR_ATTEMPTS = 2
```

### 5. Dispatch

Serial path:

- main may execute the current issue directly, or dispatch one bounded worker
- only the smallest unfinished issue is assigned

Concurrent path:

- main dispatches multiple bounded workers only for adjacent independent issues
- each worker receives exactly one assigned issue
- each worker has a disjoint or safely compatible target area

### 6. Worker Execution

Each worker:

- implements only the assigned issue
- runs focused verification
- repairs ordinary development failures within the assigned issue
- writes evidence, changed files, self-review, and route recommendation

Worker outputs are advisory to main. Workers do not decide final route.

### 7. Main Integration

Main collects worker outputs and checks:

- changed files
- issue scope
- target area boundaries
- cross-issue conflicts
- plan direction drift
- verification results

Main runs integration verification if available and proportionate.

### 8. Lightweight Gates

Apply these gates:

- Contract Gate: implemented work maps to assigned issue scope and acceptance criteria.
- Scope Gate: changed files stay inside allowed target areas or are justified by the issue.
- Verification Gate: focused and integration verification ran, or gaps are recorded.
- Evidence Gate: changed files, evidence, and self-review are sufficient for human or future evaluator review.

These gates do not output `PASS`.

### 9. Repair / Decision Handling

Ordinary development failures are repaired locally.

If execution reveals a plan or architecture decision, do bounded research and route to `NEEDS_MAIN_DECISION`.

### 10. Route

Write `.pge/runs/<run_id>/next-route.md`.

Allowed routes:

- `DONE_NEEDS_REVIEW`
- `RETRY_RECOMMENDED`
- `NEEDS_INFO`
- `BLOCKED`
- `NEEDS_HUMAN`
- `NEEDS_MAIN_DECISION`

Forbidden routes:

- `PASS`
- `MERGED`
- `SHIPPED`

`DONE_NEEDS_REVIEW` means candidate completion with evidence and self-review, waiting for human review, a future evaluator, or a future SDK runner. It is not final approval.

## Artifact Contract

Every run writes:

```text
.pge/runs/<run_id>/
```

Required run artifacts:

- `input.md`
- `batch-plan.md`
- `sprint-contract.md`
- `execution-log.md`
- `changed-files.md`
- `evidence.md`
- `self-review.md`
- `conflict-check.md`
- `evidence-summary.md`
- `next-route.md`
- `run-state.json`

Decision artifacts, only when route is `NEEDS_MAIN_DECISION`:

- `decision-research.md`
- `decision-request.md`

If workers run concurrently, create one directory per assigned issue:

```text
.pge/runs/<run_id>/workers/issue-001/
.pge/runs/<run_id>/workers/issue-002/
```

Each worker directory contains:

- `sprint-contract.md`
- `execution-log.md`
- `changed-files.md`
- `evidence.md`
- `self-review.md`
- `route.md`

`run-state.json` minimum fields:

```json
{
  "run_id": "<run_id>",
  "plan_id": "<plan_id>",
  "selected_issues": [],
  "execution_mode": "serial|concurrent",
  "state": "INITIALIZED|PREFLIGHT|EXECUTING|INTEGRATING|ROUTED|BLOCKED",
  "next_route": "DONE_NEEDS_REVIEW|RETRY_RECOMMENDED|NEEDS_INFO|BLOCKED|NEEDS_HUMAN|NEEDS_MAIN_DECISION",
  "max_repair_attempts": 2
}
```

## Handoff Contract

`pge-exec` consumes:

- `.pge/config/route-policy.md`
- `.pge/config/artifact-layout.md`
- `.pge/config/verification.md`
- `.pge/config/docs-policy.md`
- `.pge/plans/<plan_id>.md`

`pge-exec` produces:

- `.pge/runs/<run_id>/next-route.md`
- `.pge/runs/<run_id>/run-state.json`
- `.pge/runs/<run_id>/evidence-summary.md`
- all supporting run artifacts

Downstream consumers should read `next-route.md` and `evidence-summary.md` first.

No downstream consumer may treat `DONE_NEEDS_REVIEW` as final PASS authority.

## State / Route Contract

Allowed run states:

- `INITIALIZED`
- `PREFLIGHT`
- `BATCH_SELECTED`
- `EXECUTING`
- `REPAIRING`
- `INTEGRATING`
- `DECISION_NEEDED`
- `ROUTED`
- `BLOCKED`

Allowed routes:

- `DONE_NEEDS_REVIEW`
- `RETRY_RECOMMENDED`
- `NEEDS_INFO`
- `BLOCKED`
- `NEEDS_HUMAN`
- `NEEDS_MAIN_DECISION`

Forbidden routes and result claims:

- `PASS`
- `MERGED`
- `SHIPPED`

Route meanings:

- `DONE_NEEDS_REVIEW`: candidate completion with evidence and self-review; needs human / future evaluator / future SDK runner judgment.
- `RETRY_RECOMMENDED`: ordinary repair budget exhausted, but another bounded attempt may be useful.
- `NEEDS_INFO`: missing information prevents fair execution.
- `BLOCKED`: execution cannot continue due to repo, dependency, verification, or plan blocker.
- `NEEDS_HUMAN`: human action or ownership decision is required.
- `NEEDS_MAIN_DECISION`: execution found a plan/design fork that main must decide before continuing.

## Worker Model

Workers are bounded implementation helpers for independent numbered issues.

Workers are not:

- a Planner / Generator / Evaluator split inside one issue
- schedulers
- plan owners
- final evaluators
- PASS authorities

Worker input:

- assigned issue id
- issue scope
- target areas
- acceptance criteria
- verification hint
- sprint contract
- allowed boundaries

Worker output:

- changed files
- implementation notes
- verification result
- evidence
- self-review
- route recommendation

Worker prohibitions:

- do not skip issue numbers
- do not expand scope
- do not modify scheduling strategy
- do not change plan direction
- do not output `PASS`
- do not merge, tag, or ship
- do not decide concurrency
- do not modify another worker's assigned issue

## Repair Policy

Ordinary development failures must be self-repaired by main or the assigned worker. Do not immediately hand them to a human.

Development failures include:

- test failed
- compile failed
- build failed
- lint failed
- type error
- TDD red/green/refactor check failed
- missing import
- wrong function signature
- broken assertion
- format check failed
- local integration error
- artifact missing required fields

Repair loop:

```text
failure
  -> inspect error
  -> classify as development failure vs plan gap
  -> repair locally if within assigned issue
  -> rerun verification
  -> repeat within max attempts
```

Default:

```text
MAX_REPAIR_ATTEMPTS = 2
```

After max attempts, route:

```text
RETRY_RECOMMENDED
```

Do not repair indefinitely.

## Decision Handling

When execution reveals that the plan needs a direction change, do not silently change direction.

Triggers:

- original plan does not fit code reality
- multiple reasonable implementation options appear
- public contract needs to change
- state machine needs to change
- artifact layout needs to change
- issue boundary needs to change
- continuing would affect later issues

Handling:

1. run a bounded research pass
2. output options
3. write `.pge/runs/<run_id>/decision-research.md`
4. write `.pge/runs/<run_id>/decision-request.md`
5. set route to `NEEDS_MAIN_DECISION`

## Guardrails

Do not:

- auto merge, auto tag, or auto ship
- output `PASS`, `MERGED`, or `SHIPPED`
- freely choose issues out of order
- skip the smallest unfinished issue
- let workers decide concurrency or change the plan
- treat `DONE_NEEDS_REVIEW` as final approval
- overwrite unrelated dirty changes
- revert user work without explicit permission

## Stop Conditions

Stop when one of these is true:

- route is written to `next-route.md`
- no numbered issue can be safely selected
- preflight detects missing config or plan
- dirty changes make safe execution impossible
- verification entrypoint is required but unavailable
- max repair attempts are exhausted
- decision handling routes to `NEEDS_MAIN_DECISION`
- human information or action is required

## Next Suggested Action

After route:

- `DONE_NEEDS_REVIEW`: suggest human review or a future evaluator; do not claim final PASS.
- `RETRY_RECOMMENDED`: suggest another bounded `pge-exec` attempt after reviewing evidence.
- `NEEDS_INFO`: suggest updating the plan issue or providing missing information.
- `BLOCKED`: suggest resolving the blocker before rerunning.
- `NEEDS_HUMAN`: suggest the required human action.
- `NEEDS_MAIN_DECISION`: suggest answering `decision-request.md`, then rerunning `pge-exec`.

Final response should include:

```md
## PGE Exec Result
- run_id: <run_id>
- plan_id: <plan_id>
- selected_issues: <ids>
- execution_mode: <serial | concurrent>
- next_route: <DONE_NEEDS_REVIEW | RETRY_RECOMMENDED | NEEDS_INFO | BLOCKED | NEEDS_HUMAN | NEEDS_MAIN_DECISION>
- artifacts:
  - <absolute paths to key run artifacts>
- changed_files: <list or None>
- repair_attempts: <number>
- blockers: <None or short list>
```
