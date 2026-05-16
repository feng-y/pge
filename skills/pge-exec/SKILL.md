---
name: pge-exec
description: >
  Execute pge-plan issues using concurrent Generator workers and concentrated Evaluator review.
  Consumes .pge/tasks-<slug>/plan.md,
  dispatches bounded execution, requires Generator self-review, invokes independent Evaluator review when risk or batching triggers it, and runs a bounded repair loop.
version: 1.0.0
argument-hint: "<task-slug> [--run-id <run_id>] | .pge/tasks-<slug>/plan.md [--run-id <run_id>] | repair review findings for <task-slug>"
allowed-tools:
  - TeamCreate
  - TeamDelete
  - Agent
  - SendMessage
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# pge-exec

## Purpose

Execute a canonical plan produced by `pge-plan` or `pge-plan-normalize`. `pge-exec` consumes only canonical `.pge/tasks-<slug>/plan.md` artifacts and coordinates concurrent Generator workers plus concentrated Evaluator review.

This is an orchestration skill. It executes the plan by coordinating Generator implementation, verification, and self-review. Evaluator is an independent review lane for concentrated or risk-triggered checks, not a mandatory serial step after every issue. The stage is expected to produce real code changes through Generator output, not chat-only summaries or ad-hoc pseudocode.

Exec is responsible for **evidence alignment**:

```text
my code changes = implementation of the plan contract
```

For every changed file and completed issue, exec must be able to say which issue it implements, which acceptance criteria it satisfies, what evidence proves it, and whether it deviated from the plan. Completing a task list is not enough if the evidence no longer points back to the user's goal through the plan.

Exec does not normalize external plans, promote durable knowledge, mutate the plan, or make shipping-stage review decisions. If a run exposes reusable knowledge, record the source evidence in manifest/review and route to `pge-knowledge` later.

## Critical Path

1. Resolve the selected canonical plan.
2. Reject non-canonical input and route to `pge-plan-normalize`.
3. Validate route, stop condition, ready issues, target areas, acceptance, verification, and dependencies.
4. Select new run vs explicit resume before lane creation or issue dispatch.
5. Build a dependency and Target Area schedule.
6. Create Generator worker lanes for ready independent work.
7. Require each active lane to emit `lane_ready`.
8. Dispatch independent issues concurrently when dependencies and Target Areas allow it.
9. Require `generator_completion` with self-review and evidence.
10. Decide whether concentrated Evaluator review is triggered.
11. If triggered, require Evaluator `PASS | RETRY | BLOCK`; otherwise complete from Generator evidence plus main acceptance checks.
12. Convert every failure into repair, blocked state, run route, or lane recovery.
13. Persist state after every transition.
14. Check stop condition, semantic alignment, regression, and integration.
15. Run Final Review Gate only when whole-diff risk triggers it.
16. Teardown using runtime truth, then write artifacts before the final response.

## Must Not

- Do not execute from conversation context or a non-canonical source.
- Do not normalize external plans inside exec.
- Do not read `references/external-plan-normalization.md` from exec.
- Do not modify the plan.
- Do not bottleneck all issues through a fixed Generator -> Evaluator serial pair.
- Do not claim a Generator issue is complete without self-review, evidence, and main acceptance checks.
- Do not skip concentrated Evaluator review when a risk trigger fires.
- Do not let Evaluator findings hang without repair, blocked state, run route, or lane recovery.
- Do not retry more than 3 attempts per issue.
- Do not retry a repair with no code or artifact changes.
- Do not allow destructive git.
- Do not auto-retry failed package installs.
- Do not promote durable knowledge, append `.pge/config/repo-profile.md`, create ADRs, or require `learnings.md`.
- Do not output `PASS`, `MERGED`, `SHIPPED`, or `READY_TO_SHIP` as the exec route.
- Do not advance state from idle notifications, startup prose, or partial summaries.
- Do not leave any runtime exception in an unknown or unowned state.

## Source Routing

Invocation grammar:

```text
pge-exec <task-slug>
pge-exec <task-slug> --run-id <run_id>
pge-exec .pge/tasks-<slug>/plan.md
pge-exec .pge/tasks-<slug>/plan.md --run-id <run_id>
pge-exec repair review findings for <task-slug>
pge-exec repair challenge findings for <task-slug>
```

If `ARGUMENTS:` explicitly names a task slug or canonical `.pge/tasks-<slug>/plan.md`, treat that as the user's selected source and use it without asking again. `--run-id <run_id>` is the only explicit resume selector. If the prompt asks to repair review/challenge findings for a task, keep the task slug as the user-facing entrypoint: use the named task's canonical plan plus the matching task artifact under `.pge/tasks-<slug>/review.md` or `.pge/tasks-<slug>/challenge.md`, then validate that artifact's provenance before consuming any `in-contract` findings. Validation is mandatory: read the provenance block, verify `source_run_id` resolves to an existing run under the same task, verify that referenced run still matches the current canonical plan identity, and verify the current repo repair target still matches `reviewed_head` plus `reviewed_diff_fingerprint` and `reviewed_base_ref` or a resolved equivalent base commit. If provenance is missing, ambiguous, stale, or mismatched, reject the artifact and route to rerun the matching review/challenge instead of silently repairing. Consume explicit current-context review/challenge output only as additional bounded repair input, not as a substitute for a failed task artifact. If no task artifact or explicit current-context repair input is present, route `NEEDS_HUMAN` for the missing repair input instead of guessing. Otherwise, on a bare `pge-exec` invocation, discover `.pge/tasks-<slug>/plan.md` artifacts but do not silently select one. Ask the user to confirm a single discovered plan or choose among multiple plans.

Non-canonical inputs include Claude plan mode output, `docs/exec-plan/` documents, current conversation plan text, and foreign workflow plans. Stop before implementation and report:

```text
Non-canonical execution source. Run pge-plan-normalize <source> to create .pge/tasks-<slug>/plan.md, then rerun pge-exec <task-slug>.
```

This route is not a guarantee that execution can continue. `pge-plan-normalize` may return `READY_FOR_EXECUTE`, `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`, `NEEDS_HUMAN`, or `BLOCKED`. Exec resumes only after normalize returns a ready canonical plan.

Exec must consume relevant current context before dispatching work: latest user constraints, corrections made after the plan, observed failures, manual decisions, explicit "do not" or allowed-file restrictions, and task artifacts such as `.pge/tasks-<slug>/review.md` or `.pge/tasks-<slug>/challenge.md` when execution is rerunning from review/challenge feedback. Current context and task artifacts may narrow execution, pause it, or block it; they cannot silently expand the plan.

Exec is not the stage for major intent discovery, normalization, or plan-changing clarification. If current context raises unresolved questions about goal, scope, acceptance, target areas, or verification, route back to `pge-plan` or `pge-research`; the upstream contract was not ready. If context changes goal, scope, acceptance, target areas, or verification, stop and route back unless the plan already authorizes that adjustment.

Broken and ambiguous handoffs:
- If an explicit continuation target is named but the corresponding `.pge/tasks-<slug>/plan.md` is missing, report a broken handoff instead of silently pretending the plan artifact exists.
- If multiple plausible plan artifacts exist and no explicit selector is given, ask the user which task to continue instead of guessing.

Task directory resolution:

```bash
mkdir -p .pge/tasks-<slug>/runs/<run_id>/
```

All run output goes to `.pge/tasks-<slug>/runs/<run_id>/`. Review/challenge rerun input stays task-level and comes from `.pge/tasks-<slug>/review.md`, `.pge/tasks-<slug>/challenge.md`, and any explicit current-context repair packet. These `.pge/` paths are canonical, but task artifacts are consumable only after provenance validation. Before bounded repair, exec must verify: the artifact belongs to the selected task, the provenance block is present, `source_run_id` exists and is readable, the referenced run resolves to the same canonical plan identity, and the current repo repair target still matches `reviewed_head`, `reviewed_diff_fingerprint`, and `reviewed_base_ref` or a resolved equivalent base commit. Any missing, stale, or mismatched provenance makes the artifact non-consumable and routes to rerun the matching review/challenge. Notes or summaries outside `.pge/` are non-authoritative and must not replace required run artifacts or task-artifact repair input.

## Plan Validation

Validate before lane creation:
- `plan_route` is `READY_FOR_EXECUTE` or `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`.
- If route is `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`, assumptions are explicit in the canonical plan.
- At least one issue under `## Slices` has `State: READY_FOR_EXECUTE`.
- Stop Condition is present and checkable.
- Each ready issue has Action, Deliverable, Target Areas, Acceptance Criteria, Verification Hint, Verification Type, Test Expectation, Required Evidence, Dependencies, Risks, and Security.
- Dependencies reference known issue IDs.
- Target Areas are concrete enough for scope drift checks.

Exec may consume assumptions already in the canonical plan. It must not invent new assumptions. If assumptions are missing, unclear, or plan-changing, route upstream.

Extract issues from `## Slices`. Dispatch only issues with `State: READY_FOR_EXECUTE`, in issue-ID order. Issues with `NEEDS_INFO`, `BLOCKED`, or `NEEDS_HUMAN` are skipped and recorded in manifest. If all issues are non-ready, route `BLOCKED`.

Rollback point: before execution starts, create a git tag `pge-exec-pre-<run_id>`. If exec routes `BLOCKED` or `PARTIAL` after modifying files, the user can roll back with `git reset --hard pge-exec-pre-<run_id>`. Record the tag in `state.json` and manifest.

## Team Protocol

Use Claude Code native Agent Teams only. Do not spawn external `claude`, `claude.exe`, shell background workers, or separate login-bound CLI processes as execution lanes. A process existing in the OS process table is not a valid PGE lane.

Team lifecycle:

```python
team_name = "pge-<run_id>"

TeamCreate(team_name=team_name)

Agent(subagent_type="<generator_subagent_type>", team_name=team_name, name="generator")
Agent(subagent_type="<evaluator_subagent_type>", team_name=team_name, name="evaluator")

# Optional scaling only after dependency / Target Area checks:
Agent(subagent_type="<generator_subagent_type>", team_name=team_name, name="generator-2")

SendMessage(message={"type": "shutdown_request"}, to="generator")
SendMessage(message={"type": "shutdown_request"}, to="evaluator")
# wait for protocol-level shutdown approval or teammate termination from active lanes,
# then delete the current team context
TeamDelete()
```

Agent resolution:

| PGE lane | Default subagent_type | Responsibility |
|---|---|---|
| `generator` | `general-purpose` | develop, run UT/verification, self-review, return candidate |
| `evaluator` | `agent-skills:code-reviewer` | independently verify candidate, return `PASS`, `RETRY`, or `BLOCK` |

If project-specific `generator` or `evaluator` subagent types exist and are available in the current runtime, they may be used. Otherwise use the default `general-purpose` / `agent-skills:code-reviewer` lane types while preserving PGE lane names `generator` and `evaluator`. If neither default is available, route `BLOCKED` instead of silently substituting a main-thread fallback.

Generator and Evaluator are complementary peer lanes under main coordination. Main owns routing, state, health monitoring, and repair scheduling. Generator owns implementation quality before handoff. Evaluator owns independent completion judgment. A `generator_completion READY` means candidate-ready for evaluation, not issue complete.

Required lane preflight:

```text
type: lane_ready
lane: generator | evaluator
status: READY | BLOCKED
reason: <none or one sentence>
```

Preflight checks:
- `TeamCreate` succeeded and returned/registered a team name.
- Required lanes exist by team name: `generator`, `evaluator`.
- Each lane was created through `Agent(..., team_name=team_name, name=<lane>)`, not through a shell process.
- Each lane's configured `subagent_type` is available in the current runtime.
- Each lane sends valid `lane_ready`.

Invalid lane states:
- OS process exists but lane is not registered in the Team system.
- Lane shows `Not logged in`, cannot receive `SendMessage`, or cannot reply through the Team channel.
- Lane replies only with idle/startup text and no structured readiness after one nudge.
- Lane requires a separate CLI login or external initialization.

Recovery:
- If `TeamCreate` or one lane spawn fails, cleanup the current team context and retry once with the same team name.
- If retry still fails, route `BLOCKED`.
- If `generator` remains unavailable, route `BLOCKED` with `team_runtime_unavailable: generator`.
- If `evaluator` remains unavailable, route `BLOCKED`; no issue may pass without Evaluator.
- A replacement lane is not usable until it sends valid `lane_ready`.
- Non-Team fallback is not a valid `pge-exec` execution mode. If native Team lanes cannot run, route `BLOCKED` or use a separately documented execution path outside this skill.

Adaptive scaling:
- Add `generator-2` when READY issue count is at least 6 and independent issues exist.
- At 12+ independent issues, add `generator-3`.
- Cap at 3 generator lanes.
- Scale only when assigned issues have no dependencies and no Target Area overlap.
- If a generator needs a file outside assigned Target Areas, it reports `BLOCKED` with reason `cross-assignment deviation needed: <file>`.
- Evaluate in issue-ID order regardless of generator completion order.

Read these authoritative handoff contracts:
- `skills/pge-exec/handoffs/generator.md`
- `skills/pge-exec/handoffs/evaluator.md`

## Issue Loop

Default execution is serial: dispatch Generator, wait for candidate completion, dispatch Evaluator, wait for verdict, then move to the next issue. Pipeline parallelism overlaps evaluation with next generation only when safe.

For each ready issue:

1. Dependency check: if the issue depends on a `BLOCKED` issue, mark it `BLOCKED` with dependency reason.
2. Build execution pack: include only this issue's Action, Deliverable, Target Areas, Acceptance Criteria, Test Expectation, Required Evidence, Verification Hint, relevant assumptions, dependencies, directly needed repo context, plan `goal`, relevant `non_goals`, and upstream decision refs needed for semantic alignment.
3. Dispatch Generator using `skills/pge-exec/handoffs/generator.md`.
4. Require exactly one terminal `generator_completion` packet for that attempt.
5. Candidate gate: deliverable exists, evidence is present, status is `READY` or `BLOCKED`, changed files are listed, and deviations are recorded.
6. If Generator reports `BLOCKED`, skip Evaluator and record issue `BLOCKED`.
7. Dispatch Evaluator with issue criteria and Generator evidence using `skills/pge-exec/handoffs/evaluator.md`.
8. If pipeline conditions are met for the next issue, dispatch Generator for the next issue while Evaluator checks the current issue.
9. Require exactly one terminal `evaluator_verdict`.
10. Apply verdict:
    - `PASS`: mark issue complete. Only Evaluator can produce this transition.
    - `RETRY`: main sends bounded `repair_request` to Generator, up to 3 total attempts.
    - `BLOCK`: record blocker; continue only with independent issues.
11. No-change guard: repair with zero file or artifact changes is same-failure. Do not re-evaluate.
12. After each terminal issue state, record issue alignment evidence.

Pipeline activation requires all of:
- next issue has no dependency on current issue
- next issue's Target Areas do not overlap with current issue's Target Areas
- current issue's Generator completed with candidate `READY`, not `BLOCKED`

When pipeline is active:
- If E(N) returns `PASS`, continue normally.
- If E(N) returns `RETRY`, let G(N+1) finish, hold its result, repair N through main, re-evaluate N, then evaluate held N+1.
- If E(N) returns `BLOCK`, let G(N+1) finish. Evaluate N+1 only if it is independent; otherwise mark it `BLOCKED`.

Communication consistency:
- Idle/startup messages, partial reasoning, and prose summaries are non-terminal.
- If a lane cannot proceed because dispatch is unclear or setup is invalid, it returns the terminal packet with a blocking reason.
- Main sends at most one clarification/nudge for missing or malformed packets, then rebuilds/replaces the lane or routes `BLOCKED`.
- Evaluator failures feed back to main. Evaluator does not patch. Main schedules Generator repair using `required_fixes`.
- Communication failures are orchestration failures, recorded separately from implementation failures.

After each `PASS`, record:

```text
issue_id:
changed_files:
plan_contract_fields_satisfied:
acceptance_result:
verification_result:
required_evidence:
deviation_from_plan: none | <what changed and why>
```

Any deviation that changes goal, scope, target areas, acceptance, verification, or non-goals must stop execution and route back to `pge-plan` unless the plan already authorized that deviation.

Rewind-style retry: if a Generator attempt used the wrong approach, record the learned constraint, return to the clean issue execution pack, and redispatch a fresh attempt with what the failed attempt proved, what path must not be repeated, unchanged Action/Acceptance Criteria, and the smallest allowed repair direction. This consumes the next normal retry attempt and never resets the per-issue max of 3 attempts.

Generator rules summary:
- Read `skills/pge-exec/references/generator-rules.md`.
- 5+ reads without edit means act or report `BLOCKED`.
- Never retry with no changes.
- Wrong approach means fresh execution pack with learned constraint.
- Destructive git is prohibited.
- Failed package install means `BLOCKED`, not auto-retry.
- Only fix what the issue Action specifies.

Evaluator rules summary:
- Read `skills/pge-exec/references/evaluator-thresholds.md`.
- Required Evidence missing means `RETRY`.
- Verification Hint fails means `RETRY`.
- Any Acceptance Criterion unmet means `RETRY` with specific feedback.
- Deliverable missing means `BLOCK`.
- Scope drift outside Target Areas means `BLOCK`.
- Generator self-reported `BLOCKED` must not be overridden to `PASS`.
- For Security + DEEP issues, actively construct failure scenarios.
- Verdict output must be structured and machine-parseable.

## State & Recovery

`pge-exec` must decide new run vs resume before lane creation, issue dispatch, or artifact writes.

Run selection rules:
- Explicit `--run-id <run_id>` means load that run's `state.json` and continue only if the state is resumable.
- Task slug or canonical plan path without `run_id` means create a new `run_id`.
- A single existing resumable run may be offered as a resume option, but it must not be resumed silently unless invocation explicitly asked to resume.
- Multiple existing resumable runs require user selection before execution continues.
- An already completed `SUCCESS` run is not resumed by default; a later invocation starts a new run unless the user explicitly asks to inspect, repair, or rerun that run.
- missing, unreadable, or corrupt selected `state.json` routes the selected run `BLOCKED`; do not reuse partial artifacts as current truth.
- A new run must never overwrite an existing run directory.
- A resumed run writes to the same run directory and preserves previous `PASS`, `BLOCKED`, and evidence records.

Resumable states:
- `IN_PROGRESS`
- `PARTIAL`
- recoverable `BLOCKED` after the blocking input or environment issue has changed
- `NEEDS_HUMAN` only after the required human decision has been supplied

Non-resumable by default:
- `SUCCESS`
- non-recoverable `BLOCKED`
- missing or corrupt state
- plan id or plan hash mismatch, unless the user explicitly chooses rerun under a new `run_id`

Manifest must record `run_selection`, selected `run_id`, selection reason, prior run id when relevant, and whether resume was explicit or user-confirmed.

State file shape:

```json
{
  "run_id": "<run_id>",
  "plan_id": "<plan_id>",
  "run_selection": "new | resume",
  "generators": ["generator"],
  "issues": {
    "1": {"status": "PASS", "attempts": 1},
    "2": {"status": "EVALUATING", "attempts": 1, "generator": "generator"},
    "3": {"status": "GENERATING", "attempts": 0, "generator": "generator"},
    "4": {"status": "PENDING", "attempts": 0},
    "5": {"status": "BLOCKED", "reason": "...", "attempts": 2}
  },
  "route": "IN_PROGRESS"
}
```

Issue status values: `PENDING`, `GENERATING`, `EVALUATING`, `PASS`, `BLOCKED`, `HELD`.

Write `state.json` after every state transition, not batched at the end. On resume, skip issues already marked `PASS`. Treat in-flight issues (`GENERATING`, `EVALUATING`, `HELD`) as `PENDING` and re-execute them from scratch.

Session hygiene:
- Normal: keep active session below roughly 30-40% context when possible.
- Warning: around 50%, finish the current issue, persist state, and avoid starting a new issue in the same context.
- Stop: around 60% or visible degradation, write state/handoff, include a compact restart hint, and resume from artifacts in a fresh session.

Global exception closure: any failure in source routing, plan validation, run selection, team creation, lane preflight, generator execution, evaluator execution, state persistence, artifact writing, final review, HITL handling, or teardown must become explicit state, evidence, route, and next allowed action. No exception may leave the run in an unowned `unknown` state.

Minimum exception routing:

| Failure surface | Required handling |
|---|---|
| non-canonical source | stop and route to `pge-plan-normalize` before implementation |
| normalize returns `NEEDS_HUMAN` or `BLOCKED` | do not bypass; resume exec only after a ready canonical plan exists |
| missing canonical plan | `BLOCKED` with broken handoff reason |
| invalid plan route / missing stop condition / no ready issues | `BLOCKED` before execution |
| post-plan user correction expands scope | route upstream to `pge-plan` or `NEEDS_HUMAN` |
| ambiguous run selection | stop before lane creation and require explicit resume/new-run decision |
| selected run has missing/corrupt `state.json` | route selected run `BLOCKED`; do not reuse partial artifacts |
| repair artifact provenance missing / unreadable / ambiguous | route run `BLOCKED`, reject the artifact, recommend rerunning the matching review/challenge, and do not start bounded repair |
| repair artifact run reference missing or unreadable | route run `BLOCKED`, reject the artifact, recommend rerunning the matching review/challenge, and do not reuse the artifact as repair truth |
| repair artifact plan identity mismatch | route run `BLOCKED`, reject the artifact as stale, recommend rerunning the matching review/challenge, and do not consume `in-contract` findings |
| repair artifact reviewed head / base / diff fingerprint mismatch | route run `BLOCKED`, reject the artifact as stale, recommend rerunning the matching review/challenge, and do not consume `in-contract` findings |
| TeamCreate or lane spawn failure | cleanup, retry once, then `BLOCKED` |
| missing `lane_ready` | retry/rebuild once, then `BLOCKED` |
| generator `BLOCKED` | record issue `BLOCKED`; continue only with independent issues |
| missing or malformed `generator_completion` | nudge once, then lane recovery or issue `BLOCKED` |
| evaluator `RETRY` | send bounded `repair_request` through main |
| evaluator `BLOCK` | record issue `BLOCKED`; continue only if independent |
| missing or malformed `evaluator_verdict` | nudge once, then lane recovery or issue/run `BLOCKED` |
| no-change repair | stop retry loop and route issue `BLOCKED` if no new approach |
| dependency blocked | dependent issue becomes `BLOCKED` with dependency reason |
| Target Area drift | route issue `BLOCKED` or route upstream if plan boundary changed |
| HITL confirmation, decision, or action required | route `NEEDS_HUMAN`; do not auto-approve or choose defaults in headless mode |
| verification command unavailable/fails | Evaluator returns `RETRY` or `BLOCK` with evidence |
| state write failure | stop execution and route run `BLOCKED`; do not continue without recoverable state |
| artifact write failure | route `BLOCKED`; do not claim completion |
| final review `REPAIR_REQUIRED` | repair if bounded, otherwise `PARTIAL` |
| final review `BLOCKED` | run route `BLOCKED` |
| teardown failure | record teardown failure and route `BLOCKED` |

Every exception record must include failure surface, issue id or run-level marker, current route, evidence or observed error, and next allowed action.

## HITL

Handle by subtype:
- `HITL:verify`: after Generator completes, ask user to confirm visual/functional correctness. Without human confirmation or an explicit plan-provided automated substitute, route `NEEDS_HUMAN`; do not record the issue as verified.
- `HITL:decision`: present options to the user and wait for a choice. Without a user decision, route `NEEDS_HUMAN`; do not pick the first option or invent a default.
- `HITL:action`: pause execution, tell user what manual action is needed, and route `NEEDS_HUMAN`.
- Legacy `HITL` without subtype: treat as `HITL:decision`.

Headless mode must not turn missing human confirmation into approval or missing human choice into a decision. If a future plan explicitly allows a headless substitute, the run must record it as a substitute with evidence and confidence, not as human verification or human decision.

## Final Review

Evaluator validates each issue against its acceptance criteria. Final Review Gate is a thin whole-diff / cross-issue risk gate after issue evaluation, stop condition, integration verification, and regression checks.

Trigger when any condition is true:
- multiple issues changed shared behavior or must compose correctly
- public API, CLI, skill contract, handoff schema, or artifact layout changed
- stateful behavior, persistence, migration, or recovery semantics changed
- auth, safety, destructive action, sensitive-data handling, data access, or secrets changed
- any issue has `Security: yes`
- Generator/Evaluator needed retries, disagreed materially, or left residual risk
- changed files cross ownership boundaries enough that issue-level acceptance may miss whole-diff risk
- user explicitly requested review

Skip for LIGHT runs only when all are true: 1-2 files changed, no shared interface, no security-sensitive surface, automated verification passed, and no justified drift.

External dependencies:
- `agents/pge-code-reviewer.md` is the default read-only reviewer.
- `agents/pge-code-simplifier.md` is conditional for broad or complex changes.
- If a reviewer spec is missing, skip that reviewer and log `reviewer agent spec not found`.

Review shape:
- Spawn `pge-code-reviewer` over the final diff, run artifacts, and plan stop condition.
- Spawn `pge-code-simplifier` when 4+ files changed or complex logic changed.
- For security-sensitive or test-heavy DEEP runs, main may add at most one specialist read-only reviewer only when it can run in parallel and synthesize compactly.
- Maximum 3 review agents total.
- Use `skills/pge-exec/handoffs/reviewer.md`.

Finding handling:
- `Critical`: do not route `SUCCESS`. Repair if in scope and retry budget remains; otherwise route `PARTIAL` or `BLOCKED`.
- `Important`: repair if bounded and in scope; otherwise route `PARTIAL` with follow-up evidence.
- `Advisory`: do not block `SUCCESS`; record in `review.md`.

When `pge-exec` is rerun after `pge-review`, `pge-challenge`, or external review, read the matching task artifact under `.pge/tasks-<slug>/review.md` or `.pge/tasks-<slug>/challenge.md` plus any explicit review/challenge output in current context, but consume task-artifact findings only after provenance validation passes. That validation must confirm the provenance block is present, `source_run_id` resolves to an existing run for the same task, that run still matches the current canonical plan identity, and the current repo repair target still matches `reviewed_head`, `reviewed_diff_fingerprint`, and `reviewed_base_ref` or a resolved equivalent base commit. If the artifact is stale, mismatched, or provenance-missing, reject it as non-consumable and route to rerun the matching review/challenge instead of bounded repair. The source of the finding does not change the default repair path once validation passes. A finding routes upstream to `pge-plan` only when resolving it would require changing the plan contract itself: goal, scope, acceptance, target areas, verification, or non-goals.

Exec final review verdicts are internal to `pge-exec`. They are not the same vocabulary as the later `pge-review` stage routes:

| Exec final review verdict | Meaning inside `pge-exec` | Closest review-stage route if handed to `pge-review` |
|---|---|---|
| `PASS` | Whole-diff risk gate passed; execution may route `SUCCESS` if other checks passed | `READY_FOR_CHALLENGE` |
| `ADVISORY_ONLY` | Non-blocking findings only; execution may route `SUCCESS` and record findings in `review.md` | `READY_FOR_CHALLENGE` |
| `REPAIR_REQUIRED` | Bounded issue should be fixed inside current execution if in scope; otherwise execution routes `PARTIAL` | `NEEDS_FIX` |
| `BLOCKED` | Execution cannot route `SUCCESS` because review found a blocking whole-diff risk | `BLOCK_SHIP` |

`READY_TO_SHIP` is not produced by `pge-exec` final review. It belongs to the later `pge-review` / `pge-challenge` shipping-readiness path and requires explicit review-stage conditions. The default post-exec path remains `pge-review` then `pge-challenge`, but `pge-exec` may hand off directly to `pge-challenge` as a prove-it gate inside the Review stage when final-review state and current context already make challenge the next legal review action.

Write synthesized review to `.pge/tasks-<slug>/runs/<run_id>/review.md` when the gate runs. Include trigger, files reviewed, verdict (`PASS | REPAIR_REQUIRED | ADVISORY_ONLY | BLOCKED`), findings by severity, and exact file/line evidence.

## Verification & Route

Stop Condition:
- passes means candidate `SUCCESS`
- fails but all issues passed means `PARTIAL`
- not all issues passed means `PARTIAL` or `BLOCKED`

Semantic alignment check: before `SUCCESS`, verify the composed diff still satisfies plan `goal`, preserves `non_goals`, covers all ready issues, and has no unapproved scope drift. If the code is plausible but no longer proves the original plan contract, route `PARTIAL` and record the gap.

Integration verification: if the plan touches 3+ files across 2+ modules, run an integration-level check beyond individual issue verification: full test suite, app startup, or plan-specified integration command. Record result in manifest.

Regression check: after all per-issue evaluations pass, re-run Verification Hints from prior `PASS` issues. If any regressed, route `PARTIAL` with regression evidence.

After Stop Condition, integration verification, and regression checks pass, run Final Review Gate if triggered. `SUCCESS` requires the gate to be skipped or to return `PASS` / `ADVISORY_ONLY`. `REPAIR_REQUIRED` must either be repaired inside the current bounded plan or route `PARTIAL`. `BLOCKED` prevents `SUCCESS`. Do not auto-invoke `pge-review` or `pge-challenge`; those are explicit next-stage skills after `pge-exec` completes.

Route values:
- `SUCCESS`: all issues `PASS`, Stop Condition passes, final review skipped/`PASS`/`ADVISORY_ONLY`
- `PARTIAL`: some progress, some blocked, regression/integration gap, or unresolved bounded final-review finding
- `BLOCKED`: no issues could complete, or a blocking run-level failure prevents trustworthy continuation
- `NEEDS_HUMAN`: HITL decision/action required

## Artifacts

Write runtime facts only:

```text
.pge/tasks-<slug>/runs/<run_id>/
├── manifest.md
├── state.json
├── evidence/
├── deliverables/
└── review.md      # only when Final Review Gate runs
```

Manifest should include run metadata, plan id, plan path, run selection, rollback tag, skipped issues, issue results, verification summary, final route, exception records, and reusable knowledge candidates with evidence references.

Do not require `learnings.md`. Do not append repo profile. Do not create ADRs or domain docs. Durable promotion belongs to `pge-knowledge`.

## Teardown

Request shutdown from active lanes:

```text
type: shutdown_request
request_id: <id>
```

Each lane should acknowledge for human tracing with `shutdown_response`, but plain text `shutdown_response` is only a lane-level acknowledgement. Teardown completes only after the team runtime records shutdown approval using the request ID or teammate termination for every active lane.

After runtime shutdown approval or teammate termination, delete the current team context with `TeamDelete()`, then write final manifest. If a lane does not acknowledge shutdown through the protocol or does not terminate, record teardown failure and route `BLOCKED`.

## Completion

Completion gate: do not declare execution complete, summarize completion, or change routes until both are true:

1. Run artifacts have been written under `.pge/tasks-<slug>/runs/<run_id>/`, including manifest, state, evidence, deliverables, and review when triggered.
2. You are about to output the Final Response block exactly once.

If the user redirects the work mid-run, or the session needs to stop early, persist current run state and artifacts first, then route as `PARTIAL`, `BLOCKED`, or `NEEDS_HUMAN` instead of silently exiting.

Final response:

```md
## PGE Exec Result
- status: SUCCESS | PARTIAL | BLOCKED | NEEDS_HUMAN
- run_id: <run_id>
- plan_id: <plan_id>
- issues_passed: N
- issues_blocked: N
- issues_total: N
- stop_condition: passed | failed | not_checked
- final_review: skipped | pass | advisory_only | repair_required | blocked
- artifacts: .pge/tasks-<slug>/runs/<run_id>/
- next: done | pge-review <task-slug> | pge-challenge <task-slug> (prove-it gate inside Review stage) | pge-plan (if blocked) | user decision (if HITL)
```
