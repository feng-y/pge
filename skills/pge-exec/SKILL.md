---
name: pge-exec
description: >
  Execute canonical .pge/tasks-<slug>/plan.md issues using concurrent Generator workers
  and final Evaluator verification over the composed run. pge-exec owns dispatch,
  scheduling, state, evidence alignment, bounded repair, and the final execution route.
version: 1.0.2
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

Execute a canonical .pge/tasks-<slug>/plan.md produced by `pge-plan`. `pge-exec` is the execution control plane: it consumes only canonical `.pge/tasks-<slug>/plan.md` artifacts and owns concurrent scheduling, runtime state, evidence alignment, bounded repair, and the final execution route.

This is an orchestration skill. Generator owns implementation, local verification, self-review, and evidence production for assigned issue candidates. Evaluator owns final run-level verification: plan alignment, acceptance/evidence coverage, composed implementation logic, regression/integration risk, and any targeted risk checks main explicitly dispatches before final verification. The stage is expected to produce real code changes through Generator output, not chat-only summaries or ad-hoc pseudocode.

Exec is responsible for **evidence alignment**:

```text
my code changes = implementation of the plan contract
```

For every changed file and completed issue, exec must be able to say which issue it implements, which acceptance criteria it satisfies, what evidence proves it, and whether it deviated from the plan. Completing a task list is not enough if the evidence no longer points back to the user's goal through the plan.

Exec does not normalize external plans, promote durable knowledge, mutate the plan, or make shipping-stage review decisions. If a run exposes reusable knowledge, record the source evidence in manifest/review and route to `pge-learn` later.

## Critical Path

1. Resolve the selected canonical plan.
2. Ask once before activating non-canonical input; route to `pge-plan` if confirmed, stop if declined.
3. Validate route, stop condition, ready issues, target areas, acceptance, verification, and dependencies.
4. Select new run vs explicit resume before lane creation or issue dispatch.
5. Initialize run artifacts, including `implementation-notes.md`, before implementation work starts.
6. Build a dependency and Target Area schedule.
7. Create Generator worker lanes for ready independent work.
8. Require each active lane to emit `lane_ready`.
9. Dispatch independent issues concurrently when dependencies and Target Areas allow it.
10. Require `generator_completion` with self-review and evidence.
11. Keep Generator work moving until all dispatchable candidates are produced or blocked.
12. Dispatch Evaluator only for explicit targeted risk checks before final verification; do not require an Evaluator verdict after every issue.
13. Persist state and implementation notes after every transition that creates a decision, deviation, tradeoff, blocker, or verification gap.
14. Run final Evaluator verification over the composed run before route decisions.
15. Apply final Evaluator `PASS | RETRY | BLOCK` to bounded repair, blocked state, run route, or lane recovery.
16. Check stop condition, semantic alignment, regression, and integration.
17. Run Final Review Gate for every completed execution before `SUCCESS`.
18. Teardown using runtime truth, then write artifacts before the final response.

## Must Not

- Do not execute from conversation context or a non-canonical source.
- Do not normalize external plans inside exec.
- Do not read stale normalization references from exec.
- Do not modify the plan.
- Do not bottleneck all issues through a fixed Generator -> Evaluator serial pair.
- Do not require every Generator candidate to receive an issue-level Evaluator `PASS`.
- Do not claim run success from Generator completions alone; final Evaluator verification must validate composed plan alignment and implementation logic.
- Do not skip targeted Evaluator review when a risk trigger requires review before more generation can safely continue.
- Do not let Evaluator findings hang without repair, blocked state, run route, or lane recovery.
- Do not route a generator `BLOCKED` terminally until main classifies it as implementation-blocked or contract-blocked.
- Do not mark an issue failed when its verification is blocked by sibling issue changes or newly added files from the same run.
- Do not run compile-coupled issues in the same working tree with immediate verification.
- Do not retry more than 3 attempts per issue.
- Do not retry a repair with no code or artifact changes.
- Do not allow destructive git.
- Do not auto-retry failed package installs.
- Do not promote durable knowledge, append `.pge/config/repo-profile.md`, create ADRs, or require `learnings.md`.
- Do not use `implementation-notes.md` to change scope, rewrite acceptance, waive verification, or approve plan-changing deviations.
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

If `ARGUMENTS:` explicitly names a task slug or canonical `.pge/tasks-<slug>/plan.md`, treat that as the user's selected source and use it without asking again. `--run-id <run_id>` is the only explicit resume selector. If the prompt asks to repair review/challenge findings for a task, keep the task slug as the user-facing entrypoint and use the named task's canonical plan plus the matching task artifact under `.pge/tasks-<slug>/review.md` or `.pge/tasks-<slug>/challenge.md`. The provenance and backflow rules in Final Review govern whether those findings are consumable. If no task artifact or explicit current-context repair input is present, route `NEEDS_HUMAN` for the missing repair input instead of guessing. Otherwise, on a bare `pge-exec` invocation, discover `.pge/tasks-<slug>/plan.md` artifacts but do not silently select one. Ask the user to confirm a single discovered plan or choose among multiple plans.

Non-canonical inputs include Claude plan mode output, `docs/exec-plan/` documents, current conversation plan text, and foreign workflow plans. Ask once whether to activate the source through `pge-plan`:

```text
Non-canonical execution source. Activate through pge-plan <source>? (yes / no)
```

If confirmed, route to `pge-plan <source>` and resume after a canonical `.pge/tasks-<slug>/plan.md` exists. If declined or still ambiguous, stop before execution.

This route is not a guarantee that execution can continue. `pge-plan` may return `READY_FOR_EXECUTE`, `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`, `NEEDS_HUMAN`, or `BLOCKED`. Exec resumes only after a ready canonical plan exists.

Exec must consume relevant current context before dispatching work: latest user constraints, corrections made after the plan, observed failures, manual decisions, explicit "do not" or allowed-file restrictions, and task artifacts such as `.pge/tasks-<slug>/review.md` or `.pge/tasks-<slug>/challenge.md` when execution is rerunning from review/challenge feedback. Current context and task artifacts may narrow execution, pause it, or block it; they cannot silently expand the plan.

Exec is not the stage for major intent discovery, normalization, or plan-changing clarification. If current context raises unresolved questions about goal, scope, acceptance, target areas, or verification, route back to `pge-plan` or `pge-research`; the upstream contract was not ready. If context changes goal, scope, acceptance, target areas, or verification, stop and route back unless the plan already authorizes that adjustment.

Broken and ambiguous handoffs:
- If an explicit continuation target is named but the corresponding `.pge/tasks-<slug>/plan.md` is missing, report a broken handoff instead of silently pretending the plan artifact exists.
- If multiple plausible plan artifacts exist and no explicit selector is given, ask the user which task to continue instead of guessing.

Task directory resolution:

```bash
mkdir -p .pge/tasks-<slug>/runs/<run_id>/
```

All run output goes to `.pge/tasks-<slug>/runs/<run_id>/`. Review/challenge rerun input stays task-level and comes from `.pge/tasks-<slug>/review.md`, `.pge/tasks-<slug>/challenge.md`, and any explicit current-context repair packet. Notes or summaries outside `.pge/` are non-authoritative and must not replace required run artifacts or task-artifact repair input.

`implementation-notes.md` is a required run artifact for execution-relevant notes that are not already explicit in the plan. Initialize it when creating a new run. On resume, append to the existing file and preserve prior entries as historical run context.

## Plan Validation

Validate before lane creation:
- `plan_route` is `READY_FOR_EXECUTE` or `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`.
- `plan_gate` exists with `Verdict: PASS` and `Exec Allowed: yes`. If absent, failing, or ambiguous, route upstream to `pge-plan` for fast-adopt / contract upgrade; do not treat an engineering review alone as execution authorization.
- If route is `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`, assumptions are explicit in the canonical plan.
- At least one issue under canonical `## issues` has `State: READY_FOR_EXECUTE`. Legacy `## Slices` is accepted only as a compatibility alias; do not require both headings.
- `## stop_conditions` is present and checkable. Legacy `Stop Condition` wording is accepted as a compatibility alias.
- Each ready issue has Action, Deliverable, Target Areas, Acceptance Criteria, Verification Hint, Verification Type, Test Expectation, Required Evidence, Dependencies, Risks, and Security.
- Forbidden areas are present and specific enough for scope drift checks.
- Terminal conditions are present. Any condition with `Exec Allowed: no` or an unresolved trigger blocks execution and routes upstream; do not waive it in `implementation-notes.md`.
- Newly produced plans should include Verification Coupling. If a legacy or external canonical plan omits it, main must classify verification coupling before dispatch and treat the missing field as `unknown` until that check resolves it to `none`, `compile-coupled`, `shared verification`, `isolated worktree required`, or `serial verification required`.
- Dependencies reference known issue IDs.
- Target Areas are concrete enough for scope drift checks.

Exec may consume assumptions already in the canonical plan. It must not invent new assumptions. If assumptions are missing, unclear, or plan-changing, route upstream.

Extract issues from `## issues` (`## Slices` legacy alias accepted). Dispatch only issues with `State: READY_FOR_EXECUTE`, in issue-ID order. Issues with `NEEDS_INFO`, `BLOCKED`, or `NEEDS_HUMAN` are skipped and recorded in manifest. If all issues are non-ready, route `BLOCKED`.

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
| `evaluator` | `agent-skills:code-reviewer` | verify the composed run against the plan, plus targeted risk checks when explicitly dispatched |

If project-specific `generator` or `evaluator` subagent types exist and are available in the current runtime, they may be used. Otherwise use the default `general-purpose` / `agent-skills:code-reviewer` lane types while preserving PGE lane names `generator` and `evaluator`. If neither default is available, route `BLOCKED` instead of silently substituting a main-thread fallback.

Generator and Evaluator are complementary peer lanes under main coordination. Main owns routing, concurrent scheduling, state, health monitoring, bounded repair scheduling, completion transitions, and the final execution route. Generator owns implementation quality before handoff. Evaluator owns independent final verification and explicitly dispatched targeted risk checks. A `generator_completion READY` means candidate implementation is produced with evidence, not that the issue or run is finally verified.

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
- If `evaluator` remains unavailable, route `BLOCKED` for final verification or any explicitly dispatched targeted check; do not silently downgrade final plan alignment to Generator-only review.
- A replacement lane is not usable until it sends valid `lane_ready`.
- Non-Team fallback is not a valid `pge-exec` execution mode. If native Team lanes cannot run, route `BLOCKED` or use a separately documented execution path outside this skill.

Adaptive scaling:
- Add `generator-2` when READY issue count is at least 6 and independent issues exist.
- At 12+ independent issues, add `generator-3`.
- Cap at 3 generator lanes.
- Scale only when assigned issues have no dependencies and no Target Area overlap.
- Before dispatching parallel generators, check verification coupling. Issues that enter the same build graph, compile unit, shared generated artifact set, or common verification command are compile-coupled even if their Target Areas do not overlap.
- Compile-coupled issues must not use same-working-tree parallel generation plus immediate verification. Use isolated worktrees per generator, or allow parallel authoring only if main serializes integration verification on a clean tree in issue-ID order.
- Documentation-only issues, pure text edits, and independent scripts that do not participate in a common build or verification graph may run concurrently in the same working tree when their Target Areas do not overlap.
- If a generator needs a file outside assigned Target Areas, it reports `BLOCKED` with reason `cross-assignment deviation needed: <file>`.
- Integrate Generator candidates in dependency and issue-ID order unless Target Area or verification coupling requires a stricter order.

Read these authoritative handoff contracts:
- `skills/pge-exec/handoffs/generator.md`
- `skills/pge-exec/handoffs/evaluator.md`

## Issue Loop

Default execution is generator-first with concurrent scheduling. Generator produces issue candidates with local verification and evidence. Evaluator is an independent final verification lane over the composed run, with optional targeted risk checks before final verification only when main explicitly dispatches them. Do not force a fixed Generator -> Evaluator serial hop after every issue.

Targeted Evaluator checks are exceptional. Main may dispatch one only when a bounded, run-blocking risk question cannot be answered by Generator self-review or main's Candidate Gate, for example a shared interface/protocol change whose correctness affects multiple pending issues, security/destructive work that must be independently checked before more generation continues, or an explicit user request for independent mid-run review.

Candidate malformed states are not targeted Evaluator triggers. Missing evidence, weak evidence, failed local verification, Target Area drift, absent deviation records, or incomplete self-review are Generator contract failures. Main must reject the candidate and send a bounded repair request, classify the issue blocker, or route upstream; it must not hand the failed self-review to Evaluator as a per-issue approval gate.

For each ready issue:

1. Dependency check: if the issue depends on a `BLOCKED` issue, mark it `BLOCKED` with dependency reason.
2. Build execution pack: include only this issue's Action, Deliverable, Target Areas, Acceptance Criteria, Test Expectation, Required Evidence, Verification Hint, Verification Coupling, relevant assumptions, dependencies, directly needed repo context, plan `goal`, relevant `non_goals`, and upstream decision refs needed for semantic alignment.
3. Dispatch Generator using `skills/pge-exec/handoffs/generator.md`.
4. Require exactly one terminal `generator_completion` packet for that attempt.
5. Candidate Gate: validate Generator's own completion contract before any integration:
   - deliverable exists for `READY`
   - evidence is present and matches Required Evidence
   - status is `READY` or `BLOCKED`
   - changed files are listed
   - every changed file is inside Target Areas or explicitly recorded as a justified deviation
   - deviations and implementation notes are recorded
   - self-review covers correctness, scope drift, maintainability, test adequacy, and obvious regressions
   - any `BLOCKED` packet includes blocker classification, source files, and repairability
6. If Generator reports `BLOCKED`, skip Evaluator and classify the blocker before changing the issue route:
   - `implementation-blocked`: compile errors, include-surface mismatch, forward-declaration or type-surface problems, sibling issue contamination, local interface assembly errors, or other code-level failures that do not require user decisions or plan contract changes.
   - `contract-blocked`: unclear plan, insufficient scope, user decision required, target area/scope boundary would need to change, acceptance/verification/non-goal conflict, external environment or package-install blocker, or any fix that would mutate the plan contract.
   - Implementation-blocked must not terminally end the run. Hold dependent or contaminated issues, schedule bounded repair on the blocker source issue or main-thread takeover, restore a buildable tree, then retry affected verification.
   - Contract-blocked may record issue `BLOCKED` and continue only with independent issues.
7. If Candidate Gate fails, do not dispatch Evaluator. Send one bounded repair request to Generator when the failure is locally repairable; otherwise classify it as implementation-blocked or contract-blocked.
8. If Candidate Gate passes, mark the issue `GENERATED`, record candidate evidence, and continue dispatching independent Generator work when dependencies and Target Areas allow it.
9. If an exceptional targeted Evaluator check is required before safe continuation, dispatch Evaluator with the bounded question, affected issue criteria, affected changed files, and Generator evidence using `skills/pge-exec/handoffs/evaluator.md`.
10. Require exactly one terminal `evaluator_verdict` for each targeted check sent to Evaluator.
11. Apply targeted verdict:
    - `PASS`: keep the candidate `GENERATED` and continue.
    - `RETRY` with `failure_attribution: sibling_issue | newly_added_run_file`: route `shared_tree_contamination`; set affected issues to `HELD`, promote the implicated source issue/file to priority repair or main-thread takeover, recover the tree, then rerun affected verification.
    - other `RETRY`: main sends bounded `repair_request` to Generator, up to 3 total attempts.
    - `BLOCK` with reason `manual verification pending`: route `NEEDS_HUMAN` instead of issue `BLOCKED`.
    - other `BLOCK`: record blocker; continue only with independent issues.
12. No-change guard: repair with zero file or artifact changes is same-failure. Do not re-evaluate.
13. Update `implementation-notes.md` when the issue created an unplanned-but-in-scope implementation decision, tradeoff, deviation, blocker, learned constraint, follow-up, or verification gap.
14. After each `GENERATED`, `HELD`, or `BLOCKED` issue state, record issue alignment evidence.

Generator `READY` is sufficient to mark an issue `GENERATED`, not `PASS`. `PASS` is assigned only after final Evaluator verification confirms that the composed run satisfies the plan contract. Main may reject malformed or incomplete Generator candidates before final verification, but it must not convert Generator-only evidence into final acceptance.

Pipeline activation requires all of:
- next issue has no dependency on current issue
- next issue's Target Areas do not overlap with current issue's Target Areas
- current issue's Generator completed with candidate `READY`, not `BLOCKED`
- Candidate Gate passed for the current issue
- no exceptional targeted Evaluator check blocks safe continuation

When pipeline is active:
- If no targeted Evaluator check is needed for N, continue normally.
- If targeted E(N) returns `PASS`, continue normally.
- If targeted E(N) returns `RETRY` with `failure_attribution: sibling_issue | newly_added_run_file`, hold affected issues, repair the implicated source first, re-run affected verification after the tree is buildable, then resume generation.
- If targeted E(N) returns any other `RETRY`, let independent Generator work finish, hold dependent or overlapping candidates, repair N through main, re-evaluate the targeted check, then resume generation.
- If targeted E(N) returns `BLOCK`, let independent Generator work finish. Release later candidates only if they remain independent.
- If verification for issue A fails in files owned by issue B, files newly added by the same run, or a sibling lane's changed surface, treat it as `shared_tree_contamination`, not issue A failure. Set A to `HELD`, promote the contaminating issue or file owner to priority repair, recover the whole tree to a buildable state, then rerun A's verification.

Main-thread takeover is mandatory when a blocker is locally repairable, code-level, inside the current task scope, does not require a user decision, and does not require changing the plan. Takeover means main:
1. reads the blocker file and immediate type/include/caller surface,
2. decides whether a local patch can restore compilation or verification,
3. applies the smallest in-scope fix or sends one bounded repair request,
4. reruns the failed build/verification command,
5. restores the original issue verification chain after the tree is buildable.

Code that can be locally repaired is not terminally blocked. Only plan changes, user decisions, true scope escape, unrecoverable environment/tooling failure, or exhausted bounded repair may end the run as `BLOCKED`.

Communication consistency:
- Idle/startup messages, partial reasoning, and prose summaries are non-terminal.
- If a lane cannot proceed because dispatch is unclear or setup is invalid, it returns the terminal packet with a blocking reason.
- Main sends at most one clarification/nudge for missing or malformed packets, then rebuilds/replaces the lane or routes `BLOCKED`.
- Evaluator failures feed back to main. Evaluator does not patch. Main schedules Generator repair using `required_fixes` for targeted or final-verification failures; sibling/new-run-file attribution routes through shared-tree contamination first.
- Communication failures are orchestration failures, recorded separately from implementation failures.

After each `GENERATED` candidate, record:

```text
issue_id:
changed_files:
candidate_plan_contract_fields:
candidate_acceptance_claim:
candidate_verification_result:
required_evidence:
deviation_from_plan: none | <what changed and why>
```

Any deviation that changes goal, scope, target areas, acceptance, verification, or non-goals must stop execution and route back to `pge-plan` unless the plan already authorized that deviation.

Implementation notes are audit notes, not a parallel plan. Record only facts that help review or continuation:

```md
## Implementation Notes

### <timestamp or issue id>
- type: decision | tradeoff | deviation | blocker | follow_up | verification_gap
- issue: <issue id or run-level>
- note: <what happened>
- rationale: <why this was acceptable or why execution stopped>
- plan_impact: none | in_scope | route_upstream_required
- evidence: <file path, command, artifact, or reviewer packet>
```

Use `route_upstream_required` for anything that would change goal, scope, target areas, acceptance, verification, or non-goals, then stop and route to `pge-plan` or `pge-research`. Use `follow_up` only for work that should not expand the current run.

Rewind-style retry: if a Generator attempt used the wrong approach, record the learned constraint, return to the clean issue execution pack, and redispatch a fresh attempt with what the failed attempt proved, what path must not be repeated, unchanged Action/Acceptance Criteria, and the smallest allowed repair direction. This consumes the next normal retry attempt and never resets the per-issue max of 3 attempts.

Generator rules summary:
- Read `skills/pge-exec/references/generator-rules.md`.
- 5+ reads without edit means act or report `BLOCKED`.
- Never retry with no changes.
- Wrong approach means fresh execution pack with learned constraint.
- Destructive git is prohibited.
- Failed package install means `BLOCKED`, not auto-retry.
- Only fix what the issue Action specifies.

Evaluator rules summary for final or explicitly targeted checks:
- Read `skills/pge-exec/references/evaluator-thresholds.md`.
- Required Evidence missing means `RETRY`.
- Verification Hint fails means `RETRY` with `failure_attribution`; sibling/new-run-file attribution routes through shared-tree contamination, not automatically to the issue being checked.
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
- A resumed run writes to the same run directory and preserves previous `PASS`, `BLOCKED`, evidence records, and `implementation-notes.md` entries.

Resumable states:
- `IN_PROGRESS`
- `PARTIAL`
- recoverable `BLOCKED` after the blocking input or environment issue has changed
- `NEEDS_HUMAN` only after the required human input has been supplied, including confirmation, decision, or manual action completion

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
    "1": {"status": "GENERATED", "attempts": 1, "generator": "generator"},
    "2": {"status": "HELD", "attempts": 1, "generator": "generator", "reason": "waiting for shared-tree repair"},
    "3": {"status": "GENERATING", "attempts": 0, "generator": "generator"},
    "4": {"status": "PENDING", "attempts": 0},
    "5": {"status": "BLOCKED", "reason": "...", "attempts": 2}
  },
  "final_verification": {"status": "PENDING | RUNNING | PASS | RETRY | BLOCKED"},
  "route": "IN_PROGRESS"
}
```

Issue status values: `PENDING`, `GENERATING`, `GENERATED`, `BLOCKED`, `HELD`, `PASS`.

Write `state.json` after every state transition, not batched at the end. On resume, skip issues already marked `PASS`. Treat in-flight issues (`GENERATING`, `HELD`) as `PENDING` and re-execute them from scratch. Treat `GENERATED` issues as reusable candidates only when the rollback tag, changed files, run artifacts, and plan identity still match; otherwise re-execute them from scratch. `PASS` is assigned after final Evaluator verification, not after Generator completion.

Session hygiene:
- Normal: keep active session below roughly 30-40% context when possible.
- Warning: around 50%, finish the current issue, persist state, and avoid starting a new issue in the same context.
- Stop: around 60% or visible degradation, write state/handoff, include a compact restart hint, and resume from artifacts in a fresh session.

Global exception closure: any failure in source routing, plan validation, run selection, team creation, lane preflight, generator execution, evaluator execution, state persistence, implementation-note persistence, artifact writing, final review, HITL handling, or teardown must become explicit state, evidence, route, and next allowed action. No exception may leave the run in an unowned `unknown` state.

Minimum exception routing:

| Failure surface | Required handling |
|---|---|
| non-canonical source | ask once whether to activate through `pge-plan`; stop if declined or ambiguous |
| `pge-plan` returns `NEEDS_HUMAN` or `BLOCKED` | do not bypass; resume exec only after a ready canonical plan exists |
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
| generator `BLOCKED` from compile/include/type/local interface failure | classify as implementation-blocked; hold dependent or contaminated issues; schedule bounded repair or main takeover; retry verification after the tree is buildable |
| generator `BLOCKED` from sibling issue or newly added file breaking verification | route `shared_tree_contamination`; issue under verification becomes `HELD`; contaminating source becomes priority repair; rerun held verification after recovery |
| generator `BLOCKED` from plan/scope/user-decision dependency | classify as contract-blocked; record issue `BLOCKED`; continue only with independent issues |
| missing or malformed `generator_completion` | nudge once, then lane recovery or issue `BLOCKED` |
| Candidate Gate failure from missing evidence, weak evidence, failed local verification, unrecorded Target Area drift, missing self-review, or malformed `READY` packet | do not dispatch Evaluator; send bounded Generator repair if locally repairable, otherwise classify blocker |
| targeted/final evaluator `RETRY` with `failure_attribution: sibling_issue | newly_added_run_file` | route `shared_tree_contamination`; hold affected issues; repair implicated source first; rerun affected verification after recovery |
| other targeted/final evaluator `RETRY` | send bounded `repair_request` through main |
| evaluator `BLOCK` with `manual verification pending` | route `NEEDS_HUMAN`; do not downgrade missing human verification into issue `BLOCKED` |
| other targeted evaluator `BLOCK` | record affected issue `BLOCKED`; continue only if independent |
| final evaluator `BLOCK` | route run `BLOCKED` or `PARTIAL` according to completed candidates and repairability |
| missing or malformed `evaluator_verdict` | nudge once, then lane recovery or run `BLOCKED` |
| no-change repair | stop retry loop and route issue `BLOCKED` if no new approach |
| dependency blocked | dependent issue becomes `BLOCKED` with dependency reason |
| Target Area drift | route issue `BLOCKED` or route upstream if plan boundary changed |
| HITL confirmation, decision, or action required | route `NEEDS_HUMAN`; do not auto-approve or choose defaults in headless mode |
| verification command fails from compile/include/type/local interface error | implementation-blocked; repair or takeover before terminal routing |
| verification command fails in sibling issue or newly added file | route `shared_tree_contamination`; hold affected issue and repair source first |
| verification command unavailable or requires external/manual input | Evaluator returns `RETRY`, `BLOCK`, or `NEEDS_HUMAN` with evidence according to subtype |
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

Headless mode must not turn missing human confirmation into approval, missing human choice into a decision, or missing human action completion into a completed action. If a future plan explicitly allows a headless substitute, the run must record it as a substitute with evidence and confidence, not as human verification, human decision, or manual action completion.

## Final Review

Evaluator validates the composed run against the canonical plan before route decisions. It checks plan alignment, acceptance/evidence coverage, implementation logic, stop condition, integration, and regression risk. Final Review Gate is the separate whole-diff / cross-issue code review after final Evaluator verification.

Run Final Review Gate for every completed execution before routing `SUCCESS`. There is no LIGHT skip. Small, low-risk runs use a compact review shape, but they still must produce a final-review verdict and write `.pge/tasks-<slug>/runs/<run_id>/review.md`. The simplification is review depth and report size, not whether review happens.

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
- For compact reviews, keep the reviewer prompt and synthesized report short: changed files, plan alignment, verification evidence, and blocking/advisory findings only.

Finding handling:
- `Critical`: do not route `SUCCESS`. Repair if in scope and retry budget remains; otherwise route `PARTIAL` or `BLOCKED`.
- `Important`: repair if bounded and in scope; otherwise route `PARTIAL` with follow-up evidence.
- `Advisory`: do not block `SUCCESS`; record in `review.md`.

When `pge-exec` is rerun after `pge-review`, `pge-challenge`, or external review, read the matching task artifact under `.pge/tasks-<slug>/review.md` or `.pge/tasks-<slug>/challenge.md` plus any explicit review/challenge output in current context, but consume task-artifact findings only after provenance validation passes. That validation must confirm the provenance block is present, `source_run_id` resolves to an existing run for the same task, that run still matches the current canonical plan identity, and the current repo repair target still matches `reviewed_head`, `reviewed_diff_fingerprint`, and `reviewed_base_ref` or a resolved equivalent base commit. If the artifact is stale, mismatched, or provenance-missing, reject it as non-consumable and route to rerun the matching review/challenge instead of bounded repair. Once validation passes, in-contract review/challenge findings default back into `pge-exec` bounded repair. A finding routes upstream to `pge-plan` only when resolving it would require changing the plan contract itself: goal, scope, acceptance, target areas, verification, or non-goals.

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
- fails but generated candidates exist means `PARTIAL`
- fails with no usable generated candidates means `BLOCKED`

Semantic alignment check: before `SUCCESS`, verify the composed diff still satisfies plan `goal`, preserves `non_goals`, covers all generated issues, and has no unapproved scope drift. If the code is plausible but no longer proves the original plan contract, route `PARTIAL` and record the gap.

Integration verification: if the plan touches 3+ files across 2+ modules, run an integration-level check beyond individual issue verification: full test suite, app startup, or plan-specified integration command. Record result in manifest.

Regression check: after all dispatchable Generator candidates are `GENERATED`, re-run relevant Verification Hints against the composed tree. If any regressed, route bounded repair, `PARTIAL`, or `BLOCKED` with regression evidence according to repairability.

After final Evaluator verification, Stop Condition, integration verification, and regression checks pass, run Final Review Gate. `SUCCESS` requires final Evaluator verification to pass and the Final Review Gate to return `PASS` / `ADVISORY_ONLY`. `REPAIR_REQUIRED` must either be repaired inside the current bounded plan or route `PARTIAL`. `BLOCKED` prevents `SUCCESS`. Do not auto-invoke `pge-review` or `pge-challenge`; those are explicit next-stage skills after `pge-exec` completes.

Final response `next` is the next explicit stage recommendation, not an automatic invocation. For a normal execution `SUCCESS`, default to `pge-review <task-slug>`. Use `pge-challenge <task-slug>` only when final-review state and current context already make challenge the next legal Review-stage action. Use `pge-plan` for upstream contract blockers and `user decision` for HITL. Do not output `next: done` for a normal post-plan execution success; exec success means the Execute stage is complete, not that Review/Challenge/Ship are complete.

Route values:
- `SUCCESS`: all dispatchable ready issues are finally verified as `PASS`, Stop Condition passes, final Evaluator verification passes, and final review returns `PASS`/`ADVISORY_ONLY`
- `PARTIAL`: some progress, some blocked, regression/integration gap, or unresolved bounded final-review finding
- `BLOCKED`: no issues could complete, or a blocking run-level failure prevents trustworthy continuation
- `NEEDS_HUMAN`: HITL verification, decision, or action required

## Artifacts

Write runtime facts only:

```text
.pge/tasks-<slug>/runs/<run_id>/
├── manifest.md
├── state.json
├── implementation-notes.md
├── evidence/
├── deliverables/
└── review.md      # required for completed executions before SUCCESS
```

Manifest should include run metadata, plan id, plan path, run selection, rollback tag, skipped issues, issue results, implementation-notes path plus note count by type, verification summary, final route, exception records, and reusable knowledge candidates with evidence references.

`implementation-notes.md` should stay concise and append-only within a run. It records decisions the plan did not spell out, in-scope deviations and their rationale, tradeoffs made to preserve scope or simplicity, blocked decisions that routed upstream, follow-ups intentionally parked outside the current run, and verification gaps or uncertainty that remain. If there are no notes, write a single line: `No execution-time decisions, deviations, tradeoffs, follow-ups, or verification gaps recorded.`

Do not require `learnings.md`. Do not append repo profile. Do not create ADRs or domain docs. Durable promotion belongs to `pge-learn`.

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

1. Run artifacts have been written under `.pge/tasks-<slug>/runs/<run_id>/`, including manifest, state, evidence, deliverables, and review for completed executions before `SUCCESS`.
   Include `implementation-notes.md` even when it records that no execution-time notes were needed.
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
- final_review: pass | advisory_only | repair_required | blocked
- artifacts: .pge/tasks-<slug>/runs/<run_id>/
- implementation_notes: .pge/tasks-<slug>/runs/<run_id>/implementation-notes.md
- next: pge-review <task-slug> | pge-challenge <task-slug> (prove-it gate inside Review stage) | pge-plan (if blocked) | user decision (if HITL)
```
