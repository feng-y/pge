---
name: pge-exec
description: >
  Execute canonical .pge/tasks-<slug>/plan.md issues with lightweight coordination,
  compact bounded Generator lanes, staged verification, and final Evaluator pressure
  over the composed run. pge-exec owns dispatch, scheduling, state, evidence
  alignment, bounded repair, and the final execution route.
version: 1.0.5
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

This is an orchestration skill, but it must stay a light execution coordinator rather than a second planning stage or a heavy process engine. `pge-exec` trusts the canonical plan by default, lets execution choose an implementation path inside the plan contract, records meaningful implementation interpretation in `implementation-notes.md`, and uses staged verification plus final review pressure to prevent drift. Issue slices are progress units, not absolute boundaries; forbidden areas, acceptance semantics, verification gates, non-goals, and high-risk constraints are the hard boundaries.

Generator lanes own implementation, TDD or proportional local verification, issue-contract self-review, and evidence production for assigned issue, issue-group, target-area cluster, or repair-window candidates. Evaluator owns final run-level verification: plan alignment, acceptance/evidence coverage, composed implementation logic, regression/integration risk, and any targeted risk checks main explicitly dispatches before final verification. Evaluator is the independent QA / alignment lane for the composed run, not the serial checker for every Generator issue. The stage is expected to produce real code changes through Generator output, not chat-only summaries or ad-hoc pseudocode.

`pge-exec` must prevent common implementation defects before `pge-review`. Final review is an independent audit, not the first place that routine issue/goal alignment, repo-constraint, changed-hunk, performance, code-quality, or evidence failures are discovered. If high-frequency fixable findings regularly escape to `pge-review`, treat that as an execution-stage quality gate failure and strengthen Generator/Evaluator gates rather than making review broader.

Exec is responsible for **evidence alignment**:

```text
my code changes = implementation of the plan contract
```

For every changed file and completed issue, exec must be able to say which issue it implements, which acceptance criteria it satisfies, what evidence proves it, and whether it deviated from the plan. Completing a task list is not enough if the evidence no longer points back to the user's goal through the plan.

Exec does not normalize external plans, promote durable knowledge, mutate the plan, or make shipping-stage review decisions. If a run exposes reusable knowledge, record the source evidence in manifest/review and route to `pge-learn` later.

## Execution Philosophy

`pge-exec` optimizes for fast, high-quality delivery of the canonical plan. It is not a second `pge-plan`, a fixed per-issue Generator -> Evaluator -> Reviewer chain, one whole-task Generator owner, or a heavy checklist engine.

Main owns durable route, state, scheduling, evidence map, implementation-note persistence, and upstream decisions. Generator lanes are bounded helpers; prep lanes are optional read-only hint producers; Evaluator and final reviewers provide pressure over composed evidence.

Exec may adapt implementation details inside the plan contract, including local design decisions, simpler implementation paths, small adjacent changes needed for the same acceptance, and issue grouping/order changes. Record meaningful decisions, deviations, tradeoffs, open questions, verification gaps, and learned constraints in `implementation-notes.md`.

Route upstream instead of writing a note when execution would change goal, scope, acceptance, verification, non-goals, forbidden areas, high-risk behavior, required core behavior, or safety/data/security/production/irreversible authority. Small adjacent file changes outside the current issue Target Areas may stay in-contract only when later scope-boundary rules explicitly allow them and the canonical plan contract is unchanged.

### Quality-First Functional Parity Baseline

Optimization means stronger default Generator quality plus lower duplicated orchestration, not weaker gates or reduced evidence usefulness.

**Functional parity baseline** (frozen):
- Canonical plan execution with plan validation and authorization gates
- Issue-based progress with dependency, Target Area, and verification-coupling scheduling
- Complete evidence artifacts: manifest, state, implementation-notes, deliverables, verification results
- Bounded repair with retry budget and Evaluator Repair Contracts
- Startup fallback for team/lane auth/channel failures only
- Final Evaluator verification over the composed run
- Final Review Gate with code-review and simplification pressure before SUCCESS
- Durable run artifacts under `.pge/tasks-<slug>/runs/<run_id>/`
- HITL routing for verification/decision/action requirements
- Diagnostic Recovery for unclear or recurring development errors
- Route discipline: SUCCESS, PARTIAL, BLOCKED, NEEDS_HUMAN
- State persistence and resumability

**Quality-first non-regression rule**: Efficiency improvements must not be obtained by:
- Reducing Generator quality requirements (TDD/proportional verification, issue-contract self-review, behavior contract, changed-hunk audit, quality axes, complete evidence)
- Weakening Candidate Gate or Evaluator thresholds
- Replacing useful evidence with under-specified minimal packets
- Skipping final Evaluator verification or Final Review Gate
- Lowering protocol consistency between lanes and main

Generator quality should improve through better default checks, not lower through lighter process. Evidence must remain complete and useful for review, resume, and repair. Final review must remain an executable PGE gate with verified reviewer output and structured verdicts.

### Native Capability Invocation with Re-entry Gates

When delegating to native Claude Code capabilities (Agent Teams, code-review agents, thinking modes), `pge-exec` must define:

**Context**: What the capability receives (plan contract, issue brief, changed files, verification results, prior findings).

**Boundary**: What the capability may decide (implementation path, local design, verification approach) vs. what remains under main control (route, state, retry budget, plan contract).

**Expected Return**: Required packet shape (generator_completion, evaluator_verdict, reviewer findings) with evidence, status, and self-review.

**Re-entry Gate**: Validation main applies before integrating the result (Candidate Gate for Generator, verdict structure for Evaluator, finding severity/actionability for reviewers).

Native capability invocation is not permission for free-form execution, weak evidence, or skipped quality checks. The capability must satisfy the same contract as if main executed the work directly. Re-entry gates enforce that contract before the result affects run state or route decisions.

## Critical Path

1. Resolve the selected canonical plan.
2. Ask once before activating non-canonical input; route to `pge-plan` if confirmed, stop if declined.
3. Validate route, stop condition, ready issues, target areas, acceptance, verification, and dependencies.
4. Select new run vs explicit resume before lane creation or issue dispatch.
5. Initialize run artifacts, including `implementation-notes.md`, before implementation work starts.
6. Build a dependency, Target Area, and verification-coupling schedule.
7. Choose LIGHT / MEDIUM / DEEP execution shape from plan size, coupling, risk, and verification cost.
8. Start read-only prep lanes only when they can reduce upcoming dispatch uncertainty without becoming evidence.
9. Create bounded Generator lanes for ready independent work, issue groups, target-area clusters, or repair windows.
10. Require each active lane to emit `lane_ready`.
11. Dispatch independent issues concurrently when dependencies, Target Areas, and verification coupling allow it; group coupled issues instead of forcing unsafe parallelism.
12. Start Progress Watchdog for every dispatched lane: record expected next packet, last meaningful progress, and recovery budget.
13. Require `generator_completion` with self-review and evidence.
14. Keep Generator work moving until all dispatchable candidates are produced or blocked.
15. Dispatch Evaluator only for explicit targeted risk checks before final verification; do not require an Evaluator verdict after every issue.
16. Persist state and implementation notes after every transition that creates a decision, deviation, tradeoff, blocker, verification gap, issue-boundary adjustment, or stalled-lane recovery.
17. Run final Evaluator verification over the composed run before route decisions.
18. Apply final Evaluator `PASS | RETRY | BLOCK` to bounded repair, blocked state, run route, or lane recovery.
19. Check stop condition, semantic alignment, regression, and integration.
20. Activate Diagnostic Recovery when a development error has unclear root cause, repeats after repair, is flaky, or produces a symptom that does not match the issue contract.
21. Run Final Review Gate for every completed execution before `SUCCESS`.
22. Teardown using runtime truth, then write artifacts before the final response.

## Must Not

- Do not execute from conversation context or a non-canonical source.
- Do not normalize external plans inside exec.
- Do not read stale normalization references from exec.
- Do not modify the plan.
- Do not re-run the Final Plan Gate or rebuild plan authorization inside exec.
- Do not bottleneck all issues through a fixed Generator -> Evaluator serial pair.
- Do not create a mandatory implementer/spec-reviewer/code-reviewer chain per issue.
- Do not use one long-lived Generator as the default owner for the whole development task.
- Do not turn implementation preflight into a mandatory analysis table or checklist.
- Do not send huge dispatch packets when a compact issue contract is enough.
- Do not treat issue boundaries as harder than forbidden areas, acceptance, verification, non-goals, and high-risk constraints.
- Do not use Evaluator as Generator's serial reviewer, per-issue approver, or replacement for Generator's own verification and self-review.
- Do not require every Generator candidate to receive an issue-level Evaluator `PASS`.
- Do not claim run success from Generator completions alone; final Evaluator verification must validate composed plan alignment and implementation logic.
- Do not defer routine bug finding, issue alignment, goal alignment, repo constraints, performance sanity, code quality, or evidence gaps to `pge-review`.
- Do not skip targeted Evaluator review when a risk trigger requires review before more generation can safely continue.
- Do not let Evaluator findings hang without repair, blocked state, run route, or lane recovery.
- Do not route a generator `BLOCKED` terminally until main classifies it as implementation-blocked or contract-blocked.
- Do not mark an issue failed when its verification is blocked by sibling issue changes or newly added files from the same run.
- Do not run compile-coupled issues in the same working tree with immediate verification.
- Do not retry more than 3 attempts per issue.
- Do not retry a repair with no code or artifact changes.
- Do not trial-and-error unclear development failures. If the cause is not locally obvious, enter Diagnostic Recovery before another repair attempt.
- Do not allow destructive git.
- Do not auto-retry failed package installs.
- Do not promote durable knowledge, append `.pge/config/repo-profile.md`, create ADRs, or require `learnings.md`.
- Do not use `implementation-notes.md` to change scope, rewrite acceptance, waive verification, or approve plan-changing deviations.
- Do not output `PASS`, `MERGED`, `SHIPPED`, or `READY_TO_SHIP` as the exec route.
- Do not advance state from idle notifications, startup prose, or partial summaries.
- Do not proceed with agent dispatch if `lane_ready` indicates auth, startup, channel, or registration failure.
- Do not silently ignore agent startup errors. Record them and use startup fallback when allowed.
- Do not wait indefinitely for a lane. If no meaningful progress is visible, run Progress Watchdog recovery.
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
- `plan_gate` exists with `Verdict: PASS` and `Exec Allowed: yes`. If absent, failing, or ambiguous, route upstream to `pge-plan` for fast-adopt / contract upgrade; do not treat Plan Engineering Review alone as execution authorization.
- If route is `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`, assumptions are explicit in the canonical plan.
- At least one issue under canonical `## issues` has `State: READY_FOR_EXECUTE`.
- `## stop_conditions` is present and checkable.
- Each ready issue has Action, Deliverable, Behavior Contract, Target Areas, Acceptance Criteria, Verification Hint, Verification Type, Test Expectation, Required Evidence, Dependencies, Risks, and Security.
- Forbidden areas are present and specific enough for scope drift checks.
- Terminal conditions are present. Any condition with `Exec Allowed: no` or an unresolved trigger blocks execution and routes upstream; do not waive it in `implementation-notes.md`.
- Each ready issue includes Verification Coupling. If it is missing, route upstream to `pge-plan` for contract repair before dispatch.
- Dependencies reference known issue IDs.
- Target Areas are concrete enough for scope drift checks.

Exec may consume assumptions already in the canonical plan. It must not invent new assumptions. If assumptions are missing, unclear, or plan-changing, route upstream.

Extract issues from canonical `## issues`. Dispatch only issues with `State: READY_FOR_EXECUTE`, in issue-ID order. Issues with `NEEDS_INFO`, `BLOCKED`, or `NEEDS_HUMAN` are skipped and recorded in manifest. If all issues are non-ready, route `BLOCKED`.

Rollback point: before execution starts, create a git tag `pge-exec-pre-<run_id>`. If exec routes `BLOCKED` or `PARTIAL` after modifying files, the user can roll back with `git reset --hard pge-exec-pre-<run_id>`. Record the tag in `state.json` and manifest.

## Team Protocol

Use Claude Code native Agent Teams only. Do not spawn external `claude`, `claude.exe`, shell background workers, or separate login-bound CLI processes as execution lanes. A process existing in the OS process table is not a valid PGE lane.

Team lifecycle:

```python
team_name = "pge-<run_id>"

TeamCreate(team_name=team_name)

# Defaults. Project-specific/custom subagent types may replace these only when
# explicitly available and they satisfy the same lane protocol below.
Agent(subagent_type="general-purpose", team_name=team_name, name="generator-1")
Agent(subagent_type="agent-skills:code-reviewer", team_name=team_name, name="evaluator")

# Optional bounded lanes only after dependency / Target Area / verification-coupling checks:
Agent(subagent_type="general-purpose", team_name=team_name, name="generator-2")
Agent(subagent_type="general-purpose", team_name=team_name, name="prep-1")

# After spawn, verify runtime registration and lane_ready before any dispatch.
# After terminal route, request shutdown from every active lane that was actually started:
SendMessage(message={"type": "shutdown_request"}, to="generator-1")
SendMessage(message={"type": "shutdown_request"}, to="generator-2")
SendMessage(message={"type": "shutdown_request"}, to="prep-1")
SendMessage(message={"type": "shutdown_request"}, to="evaluator")
# skip lanes that were never started; otherwise wait for protocol-level shutdown approval
# or teammate termination from every active lane, then delete the current team context
TeamDelete()
```

Agent resolution:

| PGE lane | Default subagent_type | Responsibility |
|---|---|---|
| `generator-*` | `general-purpose` | bounded implementation for an issue, issue group, target-area cluster, or repair window; run UT/verification, self-review, return candidate |
| `prep-*` | `general-purpose` | optional read-only exploration for upcoming work; return hints, risks, and likely surfaces only |
| `evaluator` | `agent-skills:code-reviewer` | verify the composed run against the plan, plus targeted risk checks when explicitly dispatched |

If project-specific `generator`, `prep`, or `evaluator` subagent types exist and are explicitly available in the current runtime, they may be used. Otherwise use the default `general-purpose` / `agent-skills:code-reviewer` lane types while preserving PGE lane-name prefixes `generator-*`, `prep-*`, and `evaluator`. Custom lanes must still register as native Team members, inherit the parent session's authentication/runtime state, expose non-null `agentType` matching the selected subagent type, use `backendType: in-process`, and implement the same `lane_ready`, dispatch, progress, terminal packet, and shutdown protocol. If neither default nor configured custom lane can pass startup verification, use the Fallback Protocol below for startup/channel failures only.

Generator and Evaluator are complementary bounded lanes under main coordination. Main owns routing, concurrent scheduling, state, health monitoring, bounded repair scheduling, completion transitions, and the final execution route. Generator lanes own implementation quality before handoff for their assigned bounded scope only. Prep lanes own read-only hints and never write evidence. Evaluator owns independent final verification and explicitly dispatched targeted risk checks. A `generator_completion READY` means candidate implementation is produced with evidence, not that the issue or run is finally verified.

Required lane preflight:

```text
type: lane_ready
lane: generator-* | prep-* | evaluator
status: READY | BLOCKED
reason: <none or one sentence>
```

Agent Startup Verification happens after `Agent(...)` spawn and before any execution or evaluation dispatch:
- Wait up to 30 seconds for the lane's structured `lane_ready` packet.
- Verify the lane is registered in the Team runtime with the expected lane name, non-null `agentType` matching the selected subagent type, `backendType: in-process`, and current task `cwd`.
- Treat `Not logged in`, token missing, separate `/login` request, external initialization request, inability to receive `SendMessage`, or inability to reply through the Team channel as startup/auth failure, not as an implementation blocker.
- Record startup verification in `state.json` `lane_health` before dispatch.

Preflight checks:
- `TeamCreate` succeeded and returned/registered a team name.
- Required lanes for the selected execution shape exist by team name: at least one `generator-*` lane for implementation and `evaluator` for final verification. `prep-*` lanes are optional.
- Each lane was created through `Agent(subagent_type=<selected_type>, team_name=team_name, name=<lane>)`, not through a shell process.
- Each lane's selected `subagent_type` is available in the current runtime and appears as the lane's non-null `agentType`.
- Each lane sends valid `lane_ready` within the startup timeout.

Invalid lane states:
- OS process exists but lane is not registered in the Team system.
- Lane `agentType` is missing, null, or does not match the selected default/custom subagent type.
- Lane `backendType` is not `in-process`.
- Lane shows `Not logged in`, token missing, cannot receive `SendMessage`, or cannot reply through the Team channel.
- Lane replies only with idle/startup text and no structured readiness after one nudge.
- Lane requires a separate CLI login or external initialization.

Recovery:
- If `TeamCreate` fails before any lane exists, cleanup and retry once.
- If lane spawn fails before registration, cleanup and retry once with the same selected default/custom `subagent_type`.
- If a lane registers but fails Agent Startup Verification because of auth/startup/channel readiness, do not retry spawn; record the failure and use the Fallback Protocol for the affected issue or evaluation scope.
- If retry still cannot create a usable team or startup fallback cannot produce required evidence, route `BLOCKED`.
- If no required `generator-*` lane remains available for normal lane execution, either use startup-only fallback for affected issues or route `BLOCKED` with `team_runtime_unavailable: generator` when fallback is not allowed.
- If `evaluator` remains unavailable for final verification or targeted checks, use main-thread fallback verification only when startup/auth/channel failure is recorded; otherwise route `BLOCKED`.
- A replacement lane is not usable until it sends valid `lane_ready` and passes Agent Startup Verification.

### Fallback Protocol

Fallback is a startup/channel recovery path, not a general execution mode.

Use `main_thread_fallback` only when `TeamCreate`, lane spawn, runtime registration, `lane_ready`, or startup/auth/channel verification fails before execution work begins. Examples: spawn failure, invalid lane registration, `lane_ready` timeout, `Not logged in`, token missing, separate `/login` request, or inability to communicate through the Team channel.

When startup fallback is activated:
1. Record the failure in `state.json` `lane_health` with `startup_status: FAILED`, `startup_failure_surface: team_auth_failure | lane_ready_timeout | invalid_lane_registration | spawn_failure | channel_unavailable`, selected `agent_type`, observed `backend_type`, and `execution_mode: main_thread_fallback` for the affected issue or evaluation scope.
2. Main thread executes the issue directly from the same execution brief and emits the same evidence shape required of `generator_completion`.
3. Main thread performs evaluator-equivalent checks for final or targeted evaluation scopes when evaluator startup/channel readiness fails, using the same criteria as `evaluator_verdict`.
4. Candidate Gate, evidence requirements, implementation notes, Diagnostic Recovery, final review, manifest writing, and route rules still apply.
5. Do not use fallback for ordinary implementation, verification, Candidate Gate, Evaluator `RETRY`, or code-quality failures after a lane has passed startup verification. Those remain Generator repair, Evaluator repair, Diagnostic Recovery, `NEEDS_HUMAN`, `PARTIAL`, or `BLOCKED` according to the normal issue loop.

Do not silently ignore startup errors. A fallback run must be visible in `state.json`, `manifest.md`, and `implementation-notes.md` when the fallback changes execution ownership.

Progress Watchdog:
- On every dispatch, record `lane`, `issue_id` or evaluation scope, `expected_next_packet`, `last_meaningful_progress`, `status_requests_sent`, and `recovery_attempts` in `state.json`.
- Meaningful progress is one of: a valid terminal packet, a valid `progress_update` that names concrete files/commands/artifacts touched since the last update, a state transition, an artifact write, or a verification command result.
- Idle text, startup prose, "still working", repeated reasoning, or a packet that names no new evidence is not meaningful progress.
- Reset `status_requests_sent` to 0 whenever meaningful progress occurs; keep `recovery_attempts` for the current dispatch until the expected terminal packet arrives.
- If the lane produces no meaningful progress when main next checks the run, send exactly one `status_request` with the expected packet and current issue/scope.
- A valid response to `status_request` must be either the expected terminal packet, a `progress_update` with concrete new evidence and next action, or a terminal blocked packet with a blocking reason.
- If the response is missing, malformed, idle-only, or repeats the same no-evidence progress, recover the lane once: rebuild/replace the lane if possible, set any in-flight issue to `PENDING`, and re-dispatch from the last persisted state.
- If recovery also stalls, route the issue or run `BLOCKED` with `failure_surface: progress_watchdog_stall`, record evidence in `implementation-notes.md`, and do not leave the run `IN_PROGRESS`.
- A recovered lane must send fresh `lane_ready` before receiving work. A replaced lane must not reuse unpersisted assumptions from the stalled lane.

Adaptive scaling (existing safe concurrency):
- LIGHT: one bounded `generator-1`, no prep lane, cheap checks plus final verification/review.
- MEDIUM: bounded Generator lanes by issue or issue group, optional read-only prep for the next issue, staged verification, final Evaluator.
- DEEP: explicit issue/coupling graph, issue-group or target-area-cluster Generator lanes, optional prep lanes, final composed Evaluator, targeted review.
- Add `generator-2` only when independent ready work exists and the added lane improves throughput more than it increases coordination cost.
- At 12+ independent issues, consider `generator-3`.
- Cap at 3 generator lanes.
- Scale only when assigned issues have no dependencies, no Target Area overlap, and no shared verification surface that would make parallel implementation unsafe.
- Before dispatching parallel generators, check verification coupling. Issues that enter the same build graph, compile unit, shared generated artifact set, or common verification command are compile-coupled even if their Target Areas do not overlap.
- Compile-coupled issues must not use same-working-tree parallel generation plus immediate verification. Use isolated worktrees per generator, or allow parallel authoring only if main serializes integration verification on a clean tree in issue-ID order.
- Documentation-only issues, pure text edits, and independent scripts that do not participate in a common build or verification graph may run concurrently in the same working tree when their Target Areas do not overlap.
- If a generator needs a file outside assigned Target Areas, it records the smallest justified deviation when the change is inside the plan contract and needed for the same acceptance; it reports `BLOCKED` only when the file touches forbidden/high-risk areas, changes acceptance/verification/non-goals, or requires a plan-changing boundary decision.
- Integrate Generator candidates in dependency and issue-ID order unless Target Area or verification coupling requires a stricter order.

**Concurrency eligibility** (existing safe boundaries):
- Independent Generators require: no dependency overlap, no Target Area overlap, no unsafe shared verification surface (compile-coupled work uses isolated worktrees or serialized integration verification).
- Parallel final reviewers: reviewer agents may run concurrently after final Evaluator verification, with main synthesizing one `review.md` from their findings.
- Quality gates remain unchanged: existing concurrency must not bypass Candidate Gate, final Evaluator, Final Review, or required evidence.

**Shared-context mechanics** are explicitly excluded from this execution model. Future designs for cross-lane context sharing, persistent lane state, or inter-issue learning artifacts require separate contracts with defined lifecycle, staleness handling, and evidence boundaries. Do not implement shared-context persistence, new state schemas, or cross-lane scheduling artifacts in the current `pge-exec` contract.

Opportunistic prep (existing read-only native lane):
- Start `prep-*` only when the next issue or issue group has real uncertainty that can be resolved read-only while implementation proceeds.
- Prep may inspect likely target surfaces, existing capabilities, coupling risks, legacy traps, verification cost, and stop-if conditions.
- Prep output is `preflight_hint`: likely target surface, possible reuse, risks, stop-if, confidence, and evidence paths.
- Prep must not modify files, alter the plan, claim completion, replace verification, or provide acceptance evidence.
- Main may use prep hints to shape a compact Generator dispatch packet, but must re-check current code reality before relying on them.
- Prep lanes are bounded read-only helpers that run ahead of implementation; they do not persist state, share context across issues, or replace Generator's own fresh reads.

Read these authoritative handoff contracts:
- `skills/pge-exec/handoffs/prep.md`
- `skills/pge-exec/handoffs/generator.md`
- `skills/pge-exec/handoffs/evaluator.md`
- `skills/pge-exec/handoffs/reviewer.md`

## Issue Loop

Default execution is generator-first with concurrent scheduling. Generator produces issue candidates with TDD or proportional local verification, issue-contract self-review, and evidence. Evaluator is an independent final verification lane over the composed run, with optional targeted risk checks before final verification only when main explicitly dispatches them. Do not force a fixed Generator -> Evaluator serial hop after every issue, and do not treat Evaluator as Generator's reviewer.

**Targeted Evaluator checks** (adaptive escalation, not default quality guarantee): Main may dispatch one only when a bounded, run-blocking risk question cannot be answered by Generator self-review or main's Candidate Gate. Examples: shared interface/protocol change whose correctness affects multiple pending issues, security/destructive work that must be independently checked before more generation continues, cross-issue composition risk, or an explicit user request for independent mid-run review. A targeted check must include a concrete `targeted_question`; "verify this candidate" is not a valid targeted question.

**Adaptive escalation signals** (when main cannot confidently route from a candidate whose evidence is already complete):
- Plan/code reality conflict appears (acceptance claims don't match observed behavior)
- Changed surface has cross-boundary risk (shared protocol, security surface, data migration, cross-issue composition)
- Evidence is complete but exposes an unresolved cross-boundary risk that cannot be answered inside the issue contract
- Repair uncertainty remains after one bounded repair attempt
- Main observes a concrete signal that warrants independent verification before safe continuation

Evidence completeness is a precondition for escalation, not a trigger for it. Missing evidence, weak evidence, failed local verification, unrecorded scope drift, or incomplete self-review are Generator/Candidate Gate failures, not targeted Evaluator triggers; main must reject the candidate and send bounded Generator repair, classify the blocker, or route upstream instead of dispatching Evaluator over a malformed candidate.

Main must record the observed signal and routing reason whenever it escalates to targeted Evaluator or declines escalation. Adaptive escalation is signal-based, not a brittle trigger matrix. Escalation supplements Generator default quality; it does not replace it. Strong default Generator quality (from Issue 2 code-review-informed checks) handles routine defects before targeted checks are needed.

Candidate malformed states are not targeted Evaluator triggers. Missing evidence, weak evidence, failed local verification, unrecorded or weakly justified Target Area drift, absent deviation records, or incomplete self-review are Generator contract failures. Main must reject the candidate and send a bounded repair request, classify the issue blocker, or route upstream; it must not hand the failed self-review to Evaluator as a per-issue approval gate.

For each ready issue:

1. Dependency check: if the issue depends on a `BLOCKED` issue, mark it `BLOCKED` with dependency reason.
2. Build a compact issue execution brief. The brief is the authoritative per-issue Generator input derived from the canonical plan; surrounding conversation and the full plan are context only. Include only this issue's Action, Deliverable, Target Areas, Acceptance Criteria, Test Expectation, Required Evidence, Verification Hint, Verification Coupling, relevant assumptions, dependencies, directly needed repo context, plan `goal`, relevant `non_goals`, upstream decision refs needed for semantic alignment, and a `behavior_contract`:
   - `current_behavior`: current behavior or current repo state the issue changes, from the issue and fresh code read
   - `desired_behavior`: behavior or contract that must be true after the issue
   - `behavior_delta`: the smallest behavior/contract change Generator must deliver
   - `key_interfaces`: types, functions, commands, config shapes, or artifact contracts Generator should inspect without relying on stale line numbers
   - `out_of_scope_confirmed`: adjacent work, non-goals, and forbidden changes that must not be touched
   - `what_not_to_infer`: assumptions Generator must not invent from surrounding context
   Target Areas remain scope boundaries, not procedural instructions to make arbitrary edits in those files. Do not paste full plan text or generic anti-pattern catalogs into the brief.
   Main may add `implementation_guidance` only when a concrete issue-specific risk is visible. Keep it to 1-3 bullets, such as "keep this local to <surface>", "reuse <existing capability>", or "stop if this requires <forbidden/high-risk area>". Guidance is shaping, not a gate and not a checklist.
   Main may include `prep_hint` conclusions when a read-only prep lane produced them, clearly labeled as hints rather than evidence.
3. Dispatch Generator using `skills/pge-exec/handoffs/generator.md` only after the target lane has passed Agent Startup Verification. Send the execution brief through the Team channel:

   ```text
   SendMessage(to="<generator-lane>", message="---BEGIN EXECUTION BRIEF DATA---\n...\n---END EXECUTION BRIEF DATA---")
   ```

   If Generator startup/channel readiness failed before dispatch and fallback is active, main consumes the same execution brief directly and records `execution_mode: main_thread_fallback`.
4. Require exactly one terminal `generator_completion` packet for that attempt, or the same packet-shaped evidence from main when startup fallback owns the attempt.
5. Candidate Gate: validate Generator's own completion contract before any integration:
   - deliverable exists for `READY`
   - evidence is present and matches Required Evidence
   - status is `READY` or `BLOCKED`
   - changed files are listed
   - every changed file is inside Target Areas or explicitly recorded as a justified deviation
   - deviations and implementation notes are recorded
   - `behavior_contract` is present and maps current behavior, desired behavior, behavior delta, key interfaces checked, verification points, and out-of-scope items
   - `changed_hunk_audit` is present for changed files and covers issue/goal alignment, repo constraints, deleted invariants, caller/callee/consumer impact, edge/error paths, performance, code quality, scope, and evidence
   - `removed_behavior_audit` is present when lines were deleted or replaced, confirming guards/invariants/validations are preserved or intentionally removed
   - `caller_consumer_check` is present when exported contracts changed, confirming immediate callers/consumers remain compatible
   - `edge_error_coverage` confirms at least one realistic edge case and error path was checked for behavior changes
   - `performance_sanity` confirms no obvious regressions (N+1 queries, unbounded loops, missing pagination, sync-for-async) in changed code
   - `simplification_check` confirms new code avoids deep nesting (3+ levels), long functions (50+ lines for simple logic), unnecessary abstractions, dead code, and speculative flexibility
   - `quality_axes` reports issue_alignment, goal_alignment, repo_constraints, verification, performance, and code_quality as passed / not_applicable where relevant
   - contract self-review covers Action, Deliverable, behavior delta, Acceptance Criteria, Test Expectation, Required Evidence, Target Areas, scope drift, maintainability, and obvious regressions
   - TDD / verification evidence is proportional to the issue: meaningful behavior RED/GREEN where applicable, or the strongest plan-authorized contract-level verification when a RED test would be artificial
   - Generator must not send `READY` with known in-contract bugs, weak evidence, unresolved scope drift, obvious performance regression, or avoidable code-quality defects
   - any `BLOCKED` packet includes blocker classification, source files, and repairability
6. If Generator reports `BLOCKED`, skip Evaluator and classify the blocker before changing the issue route:
   - `implementation-blocked`: compile errors, include-surface mismatch, forward-declaration or type-surface problems, sibling issue contamination, local interface assembly errors, or other code-level failures that do not require user decisions or plan contract changes.
   - `contract-blocked`: unclear plan, insufficient scope, user decision required, target area/scope boundary would need to change, acceptance/verification/non-goal conflict, external environment or package-install blocker, or any fix that would mutate the plan contract.
   - Implementation-blocked must not terminally end the run. Hold dependent or contaminated issues, schedule bounded repair on the blocker source issue or main-thread takeover, restore a buildable tree, then retry affected verification.
   - Contract-blocked may record issue `BLOCKED` and continue only with independent issues.
7. If Candidate Gate fails, do not dispatch Evaluator. Send one bounded repair request to Generator when the failure is locally repairable; otherwise classify it as implementation-blocked or contract-blocked.
8. If Candidate Gate passes, mark the issue `GENERATED`, record candidate evidence, and continue dispatching independent Generator work when dependencies and Target Areas allow it.
9. If an exceptional targeted Evaluator check is required before safe continuation, dispatch Evaluator with the bounded question, affected issue criteria, affected changed files, and Generator evidence using `skills/pge-exec/handoffs/evaluator.md` only after evaluator startup verification passes. Send evaluation data through the Team channel:

   ```text
   SendMessage(to="evaluator", message="---BEGIN EVALUATION DATA---\n...\n---END EVALUATION DATA---")
   ```

   If Evaluator startup/channel readiness failed before dispatch and fallback is active, main performs the same bounded check directly and records `execution_mode: main_thread_fallback` for the evaluation scope.
10. Require exactly one terminal `evaluator_verdict` for each targeted check sent to Evaluator, or the same verdict-shaped evidence from main when startup fallback owns the check.
11. Apply targeted verdict:
    - `PASS`: keep the candidate `GENERATED` and continue.
    - `RETRY` with `failure_attribution: sibling_issue | newly_added_run_file`: route `shared_tree_contamination`; set affected issues to `HELD`, promote the implicated source issue/file to priority repair or main-thread takeover, recover the tree, then rerun affected verification.
    - other `RETRY`: main turns the Evaluator finding into an Evaluator Repair Contract, maps it to the owning issue/source files, sends bounded `repair_request` to Generator using the issue's remaining retry budget, then re-dispatches Evaluator after Candidate Gate passes.
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

### Diagnostic Recovery

Use Diagnostic Recovery for development errors where ordinary bounded repair would be guesswork.

Triggers:
- the same verification failure appears after one bounded repair
- the failing symptom does not clearly map to the issue being executed
- compile/runtime/test failure crosses issue boundaries or newly added run files
- a flaky or timing-sensitive failure appears
- Generator reports `implementation-blocked` with `blocker_repairability: needs_main_takeover`
- main cannot name the likely root cause in one concrete sentence from code, logs, or verification output

Diagnostic Recovery is still inside `pge-exec`; it is not permission to expand scope. It may use the `pge-diagnose` discipline, but the output belongs in the current run artifacts.

Required steps:
1. Build or identify a feedback loop that reproduces the exact user/plan-relevant failure: failing test, verification command, CLI fixture, browser script, replayed trace, or minimal harness.
2. Record the exact symptom, command, input, and affected files in `implementation-notes.md` with `type: blocker`.
3. Inspect the recent changed surface before proposing fixes: issue changes, sibling run files, generated artifacts, and directly relevant callers/callees.
4. Produce 3-5 ranked falsifiable hypotheses unless the root cause is already proven by the failure output.
5. Test one hypothesis at a time with a targeted probe or local patch.
6. When the root cause is confirmed, apply the smallest in-contract fix and rerun both the diagnostic loop and the original issue verification.
7. If no correct regression seam exists, record `type: verification_gap` with the reason and route according to repairability.

Do not mark Diagnostic Recovery complete from a passing unrelated check. Completion requires evidence that the original failure no longer reproduces, or a documented `BLOCKED` / `NEEDS_HUMAN` route explaining why the loop cannot be built.

Communication consistency:
- Idle/startup messages, partial reasoning, and prose summaries are non-terminal.
- If a lane cannot proceed because dispatch is unclear or setup is invalid, it returns the terminal packet with a blocking reason.
- Main sends at most one clarification/nudge for missing or malformed packets, then rebuilds/replaces the lane or routes `BLOCKED`.
- Main sends at most one `status_request` for no-progress stalls before lane recovery. Repeated "still working" responses without concrete new evidence are stalls, not progress.
- Evaluator failures feed back to main. Evaluator does not patch. Main schedules Generator repair using `required_fixes` for targeted or final-verification failures; sibling/new-run-file attribution routes through shared-tree contamination first.
- Communication failures are orchestration failures, recorded separately from implementation failures.

### Evaluator Repair Contract

An Evaluator `RETRY` is a contract to re-enter `pge-exec`, not an advisory note and not an ad-hoc main-thread patch. The contract is bounded by the owning issue's retry budget.

Evaluator findings re-enter execution only through main. Evaluator never patches files and Generator never self-dispatches from an Evaluator finding.

When Evaluator returns `RETRY` for a targeted or final check:

1. Main validates the `evaluator_verdict`: `finding_id`, `required_fixes`, `failure_attribution`, `implicated_files`, `recheck_scope`, and confidence are present, specific, and bounded.
2. Main materializes an Evaluator Repair Contract in `state.json` and `implementation-notes.md` with `finding_id`, `evaluation_scope`, `issue_ids`, `required_fixes`, `failure_attribution`, `implicated_files`, `evidence_checked`, `recheck_scope`, `repair_owner`, `attempt`, and `retry_budget_remaining`.
3. Main maps the finding to a repair owner:
   - `issue_under_review`: repair the owning issue's Generator candidate.
   - `sibling_issue` or `newly_added_run_file`: route `shared_tree_contamination`, hold affected issues, repair the implicated source first, then rerun held verification.
   - `environment_or_manual`: route `NEEDS_HUMAN`, `BLOCKED`, or verification-gap handling according to subtype.
   - `not_applicable` on final verification: repair the smallest generated issue whose Action/Target Areas own the implicated behavior; if no owner exists, route `PARTIAL` or upstream instead of inventing a new issue.
4. If `retry_budget_remaining` is 0, main does not dispatch Generator. Route `PARTIAL` or `BLOCKED` according to completed work and repairability.
5. Main sends `repair_request` to Generator using the original issue execution brief plus the Evaluator Repair Contract. The issue Action, Behavior Contract, Acceptance Criteria, Target Areas, Verification Hint, and non-goals remain unchanged unless the finding explicitly routes upstream.
6. Generator fixes only `required_fixes`, reruns the issue Verification Hint, and returns a fresh `generator_completion`.
7. Main runs Candidate Gate on the repaired completion. If it fails, main sends bounded Generator repair or classifies the blocker; it does not ask Evaluator to compensate for a malformed repair.
8. After Candidate Gate passes, main re-dispatches Evaluator:
   - For `targeted_check`, re-run the same `targeted_question` with the repaired candidate and prior finding as `recheck_scope`.
   - For `final_run`, first re-check the prior finding, then continue full final verification over the composed run because a repair can introduce regressions.
9. If Evaluator returns `PASS`, main clears the active repair contract and resumes the issue loop or final route checks.
10. If Evaluator returns another bounded `RETRY`, main creates the next Evaluator Repair Contract for the same owner and decrements that owner's remaining retry budget. If the same failure recurs after repair, enter Diagnostic Recovery before another patch.
11. If Evaluator returns `BLOCK`, main routes `BLOCKED`, `PARTIAL`, `NEEDS_HUMAN`, or upstream according to repairability and whether the fix would change the plan contract.

Retry budget rule: an Evaluator Repair Contract does not reset attempts. It consumes the same per-issue budget used for normal Generator repair: maximum 3 total attempts per issue (initial attempt + 2 repairs), unless the plan explicitly sets a stricter budget. Final-run findings that map to multiple issues must choose one repair owner per contract; do not spend multiple issue budgets on one vague finding.

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
- Fix only what the issue Action and Acceptance Criteria require; adjacent in-contract issue-boundary adjustments require notes.

Evaluator rules summary for final or explicitly targeted checks:
- Read `skills/pge-exec/references/evaluator-thresholds.md`.
- Required Evidence missing means `RETRY`.
- Verification Hint fails means `RETRY` with `failure_attribution`; sibling/new-run-file attribution routes through shared-tree contamination, not automatically to the issue being checked.
- Any Acceptance Criterion unmet means `RETRY` with specific feedback.
- Deliverable missing means `BLOCK`.
- Unjustified scope drift outside Target Areas means `BLOCK`; weakly justified but plausibly in-contract issue-boundary adjustments should be repaired with clearer notes/evidence or removal.
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
  "execution_shape": "LIGHT | MEDIUM | DEEP",
  "generators": ["generator-1"],
  "prep_lanes": [],
  "lane_health": {
    "generator-1": {
      "agent_type": "general-purpose",
      "backend_type": "in-process",
      "startup_status": "READY | FAILED | NOT_STARTED",
      "startup_failure_surface": "none | team_auth_failure | lane_ready_timeout | invalid_lane_registration | spawn_failure | channel_unavailable",
      "execution_mode": "agent | main_thread_fallback",
      "issue_id": "3",
      "expected_next_packet": "generator_completion",
      "last_meaningful_progress": "<timestamp or state transition id>",
      "status_requests_sent": 0,
      "recovery_attempts": 0
    },
    "evaluator": {
      "agent_type": "agent-skills:code-reviewer",
      "backend_type": "in-process",
      "startup_status": "READY | FAILED | NOT_STARTED",
      "startup_failure_surface": "none | team_auth_failure | lane_ready_timeout | invalid_lane_registration | spawn_failure | channel_unavailable",
      "execution_mode": "agent | main_thread_fallback",
      "evaluation_scope": "final_run",
      "expected_next_packet": "evaluator_verdict",
      "last_meaningful_progress": "<timestamp or state transition id>",
      "status_requests_sent": 0,
      "recovery_attempts": 0
    }
  },
  "issues": {
    "1": {"status": "GENERATED", "attempts": 1, "generator": "generator-1", "execution_mode": "agent"},
    "2": {"status": "HELD", "attempts": 1, "generator": "generator-2", "execution_mode": "agent", "reason": "waiting for shared-tree repair"},
    "3": {"status": "GENERATING", "attempts": 0, "generator": "generator-1", "execution_mode": "agent | main_thread_fallback"},
    "4": {"status": "PENDING", "attempts": 0},
    "5": {"status": "BLOCKED", "reason": "...", "attempts": 2}
  },
  "active_repair_contract": {
    "finding_id": "eval-final-001",
    "evaluation_scope": "final_run",
    "issue_ids": ["1"],
    "required_fixes": "wire middleware in src/routes/users.ts",
    "failure_attribution": "issue_under_review",
    "implicated_files": ["src/routes/users.ts"],
    "evidence_checked": ["curl returned 200 after 51 requests"],
    "recheck_scope": "GET /api/users returns 429 after 50 requests",
    "repair_owner": "1",
    "attempt": 2,
    "retry_budget_remaining": 1,
    "status": "PENDING | DISPATCHED | CANDIDATE_READY | RECHECKING | CLEARED | EXHAUSTED | BLOCKED"
  },
  "final_verification": {"status": "PENDING | RUNNING | PASS | RETRY | BLOCKED"},
  "route": "IN_PROGRESS"
}
```

Issue status values: `PENDING`, `GENERATING`, `GENERATED`, `BLOCKED`, `HELD`, `PASS`.

`active_repair_contract` is optional and present only while an Evaluator Repair Contract is unresolved. On resume, if it exists with status `PENDING`, `DISPATCHED`, `CANDIDATE_READY`, or `RECHECKING`, main must reload the contract, recompute the owning issue's remaining retry budget from `issues[repair_owner].attempts`, and continue from the last persisted boundary: dispatch repair if pending, rerun Candidate Gate if candidate-ready, or re-dispatch Evaluator if rechecking. If the owning issue, plan identity, rollback tag, or implicated files no longer match, route the repair contract `BLOCKED` instead of guessing.

Write `state.json` after every state transition, not batched at the end. On resume, skip issues already marked `PASS`. Treat in-flight issues (`GENERATING`, `HELD`) as `PENDING` and re-execute them from scratch unless a matching `active_repair_contract` explicitly owns their recovery. Treat `GENERATED` issues as reusable candidates only when the rollback tag, changed files, run artifacts, and plan identity still match; otherwise re-execute them from scratch. `PASS` is assigned after final Evaluator verification, not after Generator completion.

`execution_mode: main_thread_fallback` is valid only when paired with a recorded pre-dispatch startup/channel failure in `lane_health`. It must not appear as a generic repair shortcut after a lane has passed Agent Startup Verification.

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
| TeamCreate failure before lane registration | cleanup, retry once; if still unavailable, record `startup_failure_surface: spawn_failure` and route `BLOCKED` unless startup fallback can produce required evidence for the affected scope |
| lane spawn failure before dispatch | cleanup, retry once with the same selected default/custom `subagent_type`; if still unavailable, record `startup_failure_surface: spawn_failure` and use startup fallback for the affected issue or evaluation scope when allowed |
| invalid lane registration (`agentType` missing/null/mismatch, wrong lane name, wrong backend, wrong cwd) | do not dispatch; record `startup_failure_surface: invalid_lane_registration`; use startup fallback when allowed, otherwise `BLOCKED` |
| `lane_ready` timeout or malformed readiness after one nudge | do not dispatch; record `startup_failure_surface: lane_ready_timeout`; use startup fallback when allowed, otherwise `BLOCKED` |
| `lane_ready` or startup text reports auth/channel failure (`Not logged in`, token missing, `/login`, cannot receive/reply) | do not dispatch and do not retry spawn; record `startup_failure_surface: team_auth_failure | channel_unavailable`; use startup fallback when allowed |
| startup fallback selected but required generator/evaluator-shaped evidence is missing | route `BLOCKED`; do not claim fallback completion |
| generator `BLOCKED` from compile/include/type/local interface failure | classify as implementation-blocked; hold dependent or contaminated issues; schedule bounded repair or main takeover; retry verification after the tree is buildable |
| generator `BLOCKED` from sibling issue or newly added file breaking verification | route `shared_tree_contamination`; issue under verification becomes `HELD`; contaminating source becomes priority repair; rerun held verification after recovery |
| generator `BLOCKED` from plan/scope/user-decision dependency | classify as contract-blocked; record issue `BLOCKED`; continue only with independent issues |
| missing or malformed `generator_completion` | nudge once, then lane recovery or issue `BLOCKED` |
| no meaningful lane progress after dispatch | send one `status_request`; if no concrete progress or terminal packet follows, recover lane once; if recovery stalls, route `BLOCKED` with `progress_watchdog_stall` |
| Candidate Gate failure from missing evidence, weak evidence, failed local verification, unrecorded Target Area drift, missing behavior contract, missing changed-hunk audit, failed quality axis, missing contract self-review, artificial/implementation-restating tests, or malformed `READY` packet | do not dispatch Evaluator; send bounded Generator repair if locally repairable, otherwise classify blocker |
| repeated or unclear development error | enter Diagnostic Recovery; do not spend another repair attempt until a reproducible loop, symptom record, and root-cause hypothesis exist |
| targeted/final evaluator `RETRY` with `failure_attribution: sibling_issue | newly_added_run_file` | route `shared_tree_contamination`; hold affected issues; repair implicated source first; rerun affected verification after recovery |
| other targeted/final evaluator `RETRY` | materialize an Evaluator Repair Contract with `finding_id`, `recheck_scope`, repair owner, and remaining retry budget; dispatch bounded Generator repair through main; re-dispatch Evaluator after Candidate Gate passes |
| evaluator `BLOCK` with `manual verification pending` | route `NEEDS_HUMAN`; do not downgrade missing human verification into issue `BLOCKED` |
| other targeted evaluator `BLOCK` | record affected issue `BLOCKED`; continue only if independent |
| final evaluator `BLOCK` | route run `BLOCKED` or `PARTIAL` according to completed candidates and repairability |
| missing or malformed `evaluator_verdict` | nudge once, then lane recovery or run `BLOCKED` |
| no-change repair | stop retry loop and route issue `BLOCKED` if no new approach |
| dependency blocked | dependent issue becomes `BLOCKED` with dependency reason |
| Target Area drift | accept only when justified as an in-contract issue-boundary adjustment with evidence; otherwise send bounded repair, route issue `BLOCKED`, or route upstream if the plan boundary changed |
| HITL confirmation, decision, or action required | route `NEEDS_HUMAN`; do not auto-approve or choose defaults in headless mode |
| verification command fails from compile/include/type/local interface error | implementation-blocked; repair or takeover before terminal routing |
| verification command fails in sibling issue or newly added file | route `shared_tree_contamination`; hold affected issue and repair source first |
| verification command unavailable or requires external/manual input | Evaluator returns `RETRY` or `BLOCK` with evidence according to subtype; main routes `NEEDS_HUMAN` when human input is required |
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

**Final Evaluator verification** (always required): Uses `skills/pge-exec/handoffs/evaluator.md` and must follow the same startup-gated dispatch path as targeted checks: evaluator passes Agent Startup Verification, main sends `SendMessage(to="evaluator", message="---BEGIN EVALUATION DATA---\n...\n---END EVALUATION DATA---")`, and main waits for exactly one terminal `evaluator_verdict`. If evaluator startup/channel readiness failed before dispatch and startup fallback is active, main performs evaluator-equivalent final verification directly and records `execution_mode: main_thread_fallback` for `evaluation_scope: final_run`.

**Final Review Gate** (always required): Run Final Review Gate for every completed execution before routing `SUCCESS`. There is no LIGHT skip. Small, low-risk runs use a compact review shape, but they still must produce a final-review verdict and write `.pge/tasks-<slug>/runs/<run_id>/review.md`. The simplification is review depth and report size, not whether review happens.

**Review capability resolution** (PGE reviewer default with optional native code-review cross-validation):
- **Default executable path**: `agents/pge-code-reviewer.md` is the guaranteed default read-only reviewer. `agents/pge-code-simplifier.md` is conditional for broad or complex changes. These PGE reviewer agents provide the stable final review gate.
- **Optional native code-review cross-validation**: Claude Code `/code-review` or equivalent native capability may be used as optional cross-validation only when main can verify the capability exists, invoke it, and map its result to the required structured verdict (`PASS | ADVISORY_ONLY | REPAIR_REQUIRED | BLOCKED`). If native code-review is unavailable, returns unmappable output, or cannot be verified, the run continues through the PGE reviewer path without blocking.
- **Final synthesized review**: The final `review.md` records which review capability was used (PGE reviewers, optional native code-review, or both), whether optional native code-review was available or skipped, and how PGE invariant checks were applied before the final verdict.
- If a PGE reviewer spec is missing, skip that reviewer and log `reviewer agent spec not found`. If all PGE reviewer specs are missing and native code-review is unavailable, route `BLOCKED` with `final_review_unavailable`.

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

`READY_TO_SHIP` is not produced by `pge-exec` final review. It belongs to the later `pge-review` / `pge-challenge` shipping-readiness path and requires explicit review-stage conditions. The default post-exec path is `pge-review`; `pge-review` owns the route to `pge-challenge`.

Write synthesized review to `.pge/tasks-<slug>/runs/<run_id>/review.md` when the gate runs. Include trigger, files reviewed, verdict (`PASS | REPAIR_REQUIRED | ADVISORY_ONLY | BLOCKED`), findings by severity, and exact file/line evidence.

## Verification & Route

stop_conditions check:
- passes means candidate `SUCCESS`
- fails but generated candidates exist means `PARTIAL`
- fails with no usable generated candidates means `BLOCKED`

Semantic alignment check: before `SUCCESS`, verify the composed diff still satisfies plan `goal`, preserves `non_goals`, covers all generated issues, and has no unapproved scope drift. If the code is plausible but no longer proves the original plan contract, route `PARTIAL` and record the gap.

Integration verification: if the plan touches 3+ files across 2+ modules, run an integration-level check beyond individual issue verification: full test suite, app startup, or plan-specified integration command. Record result in manifest.

Regression check: after all dispatchable Generator candidates are `GENERATED`, re-run relevant Verification Hints against the composed tree. If any regressed, route bounded repair, `PARTIAL`, or `BLOCKED` with regression evidence according to repairability.

After final Evaluator verification, the `stop_conditions` check, integration verification, and regression checks pass, run Final Review Gate. `SUCCESS` requires final Evaluator verification to pass and the Final Review Gate to return `PASS` / `ADVISORY_ONLY`. `REPAIR_REQUIRED` must either be repaired inside the current bounded plan or route `PARTIAL`. `BLOCKED` prevents `SUCCESS`. Do not auto-invoke `pge-review` or `pge-challenge`; those are explicit next-stage skills after `pge-exec` completes.

Final response `next` is the next explicit stage recommendation, not an automatic invocation. For a normal execution `SUCCESS`, default to `pge-review <task-slug>`. Use `pge-plan` for upstream contract blockers and `user decision` for HITL. Do not output `next: done`, `pge-challenge`, or `ship` for a normal post-plan execution success; exec success means the Execute stage is complete, not that Review/Challenge/Ship are complete.

Route values:
- `SUCCESS`: all dispatchable ready issues are finally verified as `PASS`, the `stop_conditions` check passes, final Evaluator verification passes, and final review returns `PASS`/`ADVISORY_ONLY`
- `PARTIAL`: some progress, some blocked, regression/integration gap, or unresolved bounded final-review finding
- `BLOCKED`: no issues could complete, or a blocking run-level failure prevents trustworthy continuation
- `NEEDS_HUMAN`: HITL verification, decision, or action required

## Artifacts

Write runtime facts only. Keep artifacts minimal and run-scoped; do not create per-issue files or extra report layers unless they carry evidence or repair state that cannot be represented compactly in the required artifacts.

```text
.pge/tasks-<slug>/runs/<run_id>/
├── manifest.md
├── state.json
├── implementation-notes.md
├── evidence/
├── deliverables/
└── review.md      # required for completed executions before SUCCESS
```

Manifest should include run metadata, plan id, plan path, run selection, execution shape, rollback tag, skipped issues, issue results, implementation-notes path plus note count by type, verification summary, lane startup summary, prep hints used, fallback count and affected issues/evaluation scopes, final route, exception records, and reusable knowledge candidates with evidence references.

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
- final_review: PASS | ADVISORY_ONLY | REPAIR_REQUIRED | BLOCKED
- artifacts: .pge/tasks-<slug>/runs/<run_id>/
- implementation_notes: .pge/tasks-<slug>/runs/<run_id>/implementation-notes.md
- next: pge-review <task-slug> | pge-plan (if blocked) | user decision (if HITL)
```
