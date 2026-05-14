---
name: pge-exec
description: >
  Execute pge-plan issues using peer Generator + Evaluator lanes.
  Consumes .pge/tasks-<slug>/plan.md,
  dispatches per-issue execution, validates with an independent Evaluator, bounded repair loop, accumulates learnings.
version: 1.0.0
argument-hint: "<task-slug> | test"
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

Execute a plan produced by `pge-plan`. Coordinates peer Generator and Evaluator lanes per issue.

This is an orchestration skill. It executes the plan by coordinating Generator implementation/self-review and Evaluator independent verification. The stage is expected to produce real code changes through Generator output, not chat-only summaries or ad-hoc pseudocode.

Exec is responsible for **evidence alignment**:

```text
my code changes = implementation of the plan contract
```

For every changed file and every completed issue, exec must be able to say which issue it implements, which acceptance criteria it satisfies, what evidence proves it, and whether it deviated from the plan. Completing a task list is not enough if the evidence no longer points back to the user's goal through the plan.

## External Dependencies

This skill references agent definitions outside its own directory:
- `agents/pge-code-reviewer.md` — spawned by Final Review Gate
- `agents/pge-code-simplifier.md` — spawned by Final Review Gate (conditional)

These files must be present at the repo root for the Final Review Gate to function. If missing, skip the review gate and log "reviewer agent spec not found."

## Execution Flow

```dot
digraph pge_exec {
  rankdir=TB;
  node [shape=box, style=rounded];

  load_plan [label="Load Plan"];
  validate [label="Validate\n(READY_FOR_EXECUTE?)"];
  group [label="Analyze Dependencies\n+ Target Areas"];
  create_team [label="Create Team\n(generator(s) + evaluator)"];
  preflight_team [label="Team Runtime Preflight"];

  subgraph cluster_loop {
    label="Per-Issue Loop (with pipeline)";
    style=dashed;
    dispatch_gen [label="Dispatch Generator\n(handoffs/generator.md)"];
    gen_done [label="Generator?", shape=diamond];
    dispatch_eval [label="Dispatch Evaluator\n(handoffs/evaluator.md)"];
    pipeline_check [label="Next independent?", shape=diamond];
    verdict [label="Verdict?", shape=diamond];
    repair [label="Repair\n(required_fixes)"];
    pass [label="Issue PASS"];
    blocked [label="Issue BLOCKED"];
  }

  plan_verify [label="Stop Condition Check"];
  review_gate [label="Final Review Gate\n(triggered only)"];
  compound [label="Compound\n(accumulate learnings)"];
  route [label="Route + Teardown", shape=doublecircle];

  load_plan -> validate -> group -> create_team -> preflight_team -> dispatch_gen;
  dispatch_gen -> gen_done;
  gen_done -> dispatch_eval [label="READY"];
  gen_done -> blocked [label="BLOCKED"];
  dispatch_eval -> pipeline_check;
  pipeline_check -> dispatch_gen [label="yes: start next\n(overlap E+G)"];
  pipeline_check -> verdict [label="no: wait"];
  dispatch_eval -> verdict;
  verdict -> pass [label="PASS"];
  verdict -> repair [label="RETRY (< 3)"];
  verdict -> blocked [label="BLOCK / max"];
  repair -> dispatch_eval;
  pass -> dispatch_gen [label="next issue"];
  pass -> plan_verify [label="all done"];
  blocked -> dispatch_gen [label="non-blocking"];
  blocked -> route [label="blocking"];
  plan_verify -> review_gate -> compound -> route;
}
```

## Anti-Patterns

- **"Replan While Executing"** — Plan is frozen. If wrong, route back to pge-plan.
- **"Fix Everything I See"** — Stay inside issue scope. Unrelated bugs → deferred items.
- **"Repair Forever"** — Max 3 attempts per issue. Then BLOCKED.
- **"Skip Evaluator"** — Every issue gets independent verification. No exceptions.

---

## Phase 1: Load & Validate

If `ARGUMENTS:` explicitly names a task slug, plan path, or other execution target, treat that as the user's selected source and use it without asking again. Otherwise, on a bare `pge-exec` invocation, discover `.pge/tasks-<slug>/plan.md` but do not silently select one. Ask the user to confirm a single discovered plan, choose among multiple plans, or choose between a discovered plan and current conversation context. Only fall back to conversation context when no plan artifact exists and the context already contains an executable plan contract. If argument is `test`, use an inline smoke plan bound to a dedicated task directory.

Exec must also consume relevant current context before dispatching work: latest user constraints, corrections made after the plan, observed failures, manual decisions, and any explicit "do not" or allowed-file restriction. Current user constraints can narrow execution or block it; they cannot silently expand the plan.

Exec is not the stage for major intent discovery or plan-changing clarification. If current context raises many unresolved questions about goal, scope, acceptance, target areas, or verification, route back to `pge-plan` or `pge-research`; the upstream contract was not ready. If context changes goal, scope, acceptance, target areas, or verification, stop and route back unless the plan already authorizes that adjustment.

### Plan Completeness Gate

First, before canonical-format validation and before any normalization, decide whether the selected plan is clear and complete enough to execute. This is the hard precondition for accepting Claude plan mode output, `docs/exec-plans/`, or foreign workflow plans.

A plan is execution-complete only when all of these are clear from the selected source plus current user constraints:
- goal and observable stop condition
- current phase or bounded scope
- ordered issues, slices, implementation sections, or equivalent executable work units
- target areas or unambiguous ownership boundaries for the plan, with enough source structure to assign them mechanically to work units
- acceptance criteria for the plan, with enough source structure to assign them mechanically to work units
- verification expectation or evidence requirement for the plan, with enough source structure to assign it mechanically to work units
- explicit non-goals or scope exclusions when the source narrows scope
- dependencies or ordering constraints when work units interact

If all fields are present but names differ from PGE terminology, normalize them. If any field is missing but mechanically inferable from the same source without changing scope, record the inference in the canonical plan. Mechanical inference may include deriving issue boundaries from source headings, implementation components, rollout phases, or explicitly listed core changes, as long as each derived issue traces one-to-one to source content.

Clear and complete does not mean perfect PGE formatting. It means the source contains the core constraints: goal, scope/phase boundary, semantic ownership, non-goals, target ownership or areas, intended implementation direction, and verification/evidence checkpoints. An evaluator must be able to tell, from the source plus normalized plan, whether the implementation stayed within scope and satisfied the intended checks. If that is not true, the plan is not executable.

If a missing field requires choosing scope, adding design decisions, inventing target areas, inventing acceptance criteria, changing verification strategy, changing phase boundaries, or resolving semantic ownership, stop before implementation and route `NEEDS_HUMAN`, `BLOCKED`, or back to `pge-plan`.

If the approach is explicit and the checkpoints are complete, execute-normalize directly. "Complete checkpoints" means the source gives enough acceptance, verification, compare, rollout, or evidence criteria for Evaluator and Final Review to judge correctness without inventing new success criteria. Do not reject a plan only because it lacks PGE field names or pre-numbered PGE issues.

This gate applies equally to canonical `.pge/tasks-<slug>/plan.md`, Claude Code plan mode output, `docs/exec-plans/` documents, foreign workflow plans, and current-conversation plan text.

### Non-Canonical Plan Intake

Some selected inputs, especially Claude Code plan mode output, `docs/exec-plans/` documents, and plans produced by other workflows, may be semantically complete plans but not yet in the canonical `.pge/tasks-<slug>/plan.md` execution format. Treat this as a format-normalization problem, not as permission to execute directly in the orchestrator.

When evaluating or normalizing a non-canonical source, read `references/external-plan-normalization.md`. It defines the domain-neutral source shape, field mapping, anonymization rules for resident docs, and stop conditions.

If the selected source is not a canonical `.pge/tasks-<slug>/plan.md`, choose exactly one route before any implementation work:
- **Normalize in exec:** when the source already contains goal, phase/scope boundary, source work structure, target areas or ownership boundaries, acceptance criteria, verification expectations, and stop condition, convert it into `.pge/tasks-<slug>/plan.md` with `plan_route: READY_FOR_EXECUTE`, `State: READY_FOR_EXECUTE` issues, and a Stop Condition. This conversion may mechanically extract PGE issues from source headings, implementation components, rollout phases, or explicitly listed core changes. Preserve the source document's phase/scope decisions and semantic ownership; do not invent new helpers, flags, cleanup, abstractions, target areas, acceptance criteria, or verification beyond what the source authorizes. Record `source_plan: <path or current conversation plan mode output>`, `source_kind: claude_plan_mode | docs_exec_plan | foreign_workflow_plan | other_structured_plan`, and `normalization_only: true` in the plan.
- **Stop:** when any required execution field is missing or ambiguous, route `BLOCKED` or `NEEDS_HUMAN` and report the exact missing fields. Do not write implementation code.

Prefer exec normalization over routing back to `pge-plan` when the only problem is format. `pge-plan` should not be required just to rewrap a complete Claude plan mode plan, structured execution document, or foreign workflow plan. If the approach is clear and the checkpoints are complete enough for independent evaluation, `pge-exec` should normalize and execute directly. If `pge-plan` could convert the source without changing decisions, then `pge-exec` can do the same conversion before executing. Route back to `pge-plan` only when the source is not execution-complete or when normalization would require planning judgment.

Normalization is allowed inside `pge-exec` only as a lossless adapter from a complete plan into the canonical execution contract. It is not replanning. If conversion requires changing scope, splitting phases differently, adding acceptance criteria, choosing target files not named or implied by the source, or resolving semantic ownership ambiguity, stop and route back to `pge-plan`.

After normalization, restart Phase 1 validation against the generated canonical plan and continue only if it passes. The run directory, rollback tag, Generator/Evaluator dispatch, state persistence, Final Review Gate, learnings, manifest, and Final Response block remain mandatory.

Normalization adopts the source into repo management. Once `.pge/tasks-<slug>/plan.md` exists, it is the runtime contract for `pge-exec`; the original foreign plan remains source evidence referenced by `source_plan`, not a second contract to execute independently. Any later correction must update or regenerate the canonical plan before execution continues.

**Task directory resolution:** All run output goes to `.pge/tasks-<slug>/runs/<run_id>/`. This keeps the full pipeline (research → plan → exec) under one task directory. These `.pge/` paths are canonical. Notes or summaries outside `.pge/` are non-authoritative and must not replace the required run artifacts. pge-exec creates the task directory only for the dedicated smoke test or when it is normalizing a semantically complete non-canonical plan into `.pge/tasks-<slug>/plan.md`. Otherwise it expects pge-research or pge-plan to have created the task directory. Before writing run output, create only the run parent explicitly:

```bash
mkdir -p .pge/tasks-<slug>/runs/<run_id>/
```

Validate:
- `plan_route` = `READY_FOR_EXECUTE`
- ≥1 issue with `State: READY_FOR_EXECUTE`
- Stop Condition present
- Bare invocation source selection follows the confirmation rules above before execution starts
- If both a discovered plan artifact and the current conversation look like valid upstream sources, ask the user whether to execute the plan artifact or continue from the current context
- If an explicit continuation target is named but the corresponding `.pge/tasks-<slug>/plan.md` is missing, report a broken handoff instead of silently pretending the plan artifact exists
- If multiple plausible plan artifacts exist and no explicit selector is given, ask the user which task to continue instead of guessing

**Rollback point:** Before execution starts, create a git tag `pge-exec-pre-<run_id>`. If exec routes BLOCKED or PARTIAL after modifying files, the user can rollback with `git reset --hard pge-exec-pre-<run_id>`. Record the tag in state.json and manifest.

If invalid: route BLOCKED, report what's missing.

Extract issues from `## Slices`. Filter READY_FOR_EXECUTE. Order by ID.

Issues with state NEEDS_INFO, BLOCKED, or NEEDS_HUMAN are skipped — they are not dispatched to Generator. Record skipped issues and their states in the run manifest. If ALL issues are non-READY, route BLOCKED immediately.

**Resume support:** If `runs/<run_id>/state.json` exists for this plan, read it. Skip issues already marked PASS. Resume from the first non-PASS issue. This enables recovery from context overflow or session loss.

---

## Phase 2: Execute

### Create Team

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
# wait for protocol-level shutdown approval or teammate termination from active lanes, then delete the current team context
TeamDelete()
```

Agent resolution:

| PGE lane | Default subagent_type | Responsibility |
|---|---|---|
| `generator` | `general-purpose` | develop, run UT/verification, self-review, return candidate |
| `evaluator` | `agent-skills:code-reviewer` | independently verify candidate, return PASS/RETRY/BLOCK |

If project-specific `generator` or `evaluator` subagent types exist and are available in the current Claude Code runtime, they may be used. Otherwise use the default `general-purpose` / `agent-skills:code-reviewer` lane types while preserving PGE lane names `generator` and `evaluator`. If neither default is available in the current runtime, route `BLOCKED` rather than silently substituting a main-thread fallback.

Default team composition:
- `generator` — develops the issue, runs UT/verification, performs self-review, and returns a candidate result (read `handoffs/generator.md` for dispatch protocol)
- `evaluator` — independently verifies the candidate result and is the only lane that can mark a subtask PASS (read `handoffs/evaluator.md` for review protocol)

Generator and Evaluator are complementary peer lanes under main coordination. Main owns routing, state, health monitoring, and repair scheduling. Generator owns implementation quality before handoff. Evaluator owns independent completion judgment. A `generator_completion READY` means "candidate ready for evaluation", not "issue complete".

**Adaptive scaling** (when READY issue count ≥ 6 AND independent issues exist):
- Add `generator-2` (same protocol as generator, independent context)
- At 12+ independent issues: add `generator-3`
- Cap: max 3 generator lanes. Each generator claims issues from the plan; main assigns non-overlapping issue sets at dispatch time.
- Only scale when issues have no dependency AND no Target Areas overlap between assigned sets.
- If scaling conditions are not met: stay with 1 generator lane (default behavior).
- **Deviation under scaling**: if a generator needs to touch a file outside its assigned Target Areas, it must report BLOCKED with reason "cross-assignment deviation needed: <file>" rather than proceeding. Main reassigns the issue to the generator that owns that file's Target Areas, or queues it for serial execution after the current wave.
- **Evaluation ordering**: evaluate in issue-ID order regardless of generator completion order. This keeps the evaluation sequence deterministic and debuggable.

No Planner. The plan IS the frozen contract.

### Team Runtime Preflight

After creating the team and before dispatching any issue, verify that lanes are native, reachable, and protocol-capable.

Preflight checks:
- `TeamCreate` succeeded and returned/registered a team name.
- Required lanes exist by team name: `generator`, `evaluator`.
- Each lane was created through `Agent(..., team_name=team_name, name=<lane>)`, not through a shell process.
- Each lane's configured `subagent_type` is available in the current runtime.
- Each lane responds to a short `SendMessage` preflight with structured readiness:

```text
type: lane_ready
lane: generator | evaluator
status: READY | BLOCKED
reason: <none or one sentence>
```

Invalid lane states:
- OS process exists but lane is not registered in the Team system.
- Lane shows `Not logged in`, cannot receive `SendMessage`, or cannot reply through the Team channel.
- Lane replies only with idle/startup text and no structured readiness after one nudge.
- Lane does not send a valid `lane_ready` packet.
- Lane requires a separate CLI login or external initialization.

Recovery:
- If `TeamCreate` or one lane spawn fails, cleanup the current team context and retry once with the same team name.
- If the retry still fails, route `BLOCKED` immediately.
- If `generator` remains unavailable, route `BLOCKED` with `team_runtime_unavailable: generator`.
- If `evaluator` remains unavailable, route `BLOCKED`; no issue may PASS without Evaluator.
- A replacement lane is not usable until it sends a valid `lane_ready` packet.
- Do not silently fall back to main-thread Generator/Evaluator simulation.
- If the user explicitly authorizes a non-team fallback, label it as a separate execution mode in state/manifest/final response; do not claim the normal PGE team protocol ran.

Record preflight result in `state.json` and `manifest.md`.

### Pipeline Parallelism

Default execution is serial: dispatch Generator, wait for candidate completion, dispatch Evaluator, wait for verdict, then next issue. Pipeline parallelism overlaps evaluation with the next generation when safe.

**Activation conditions** (ALL must be true for the next issue):
- Next issue has NO dependency on current issue
- Next issue's Target Areas do NOT overlap with current issue's Target Areas
- Current issue's Generator completed successfully with candidate status READY, not BLOCKED

**When activated:**
- After Generator produces a READY candidate for issue N, dispatch Evaluator for N and simultaneously dispatch Generator for N+1.
- This overlaps E(N) with G(N+1) — Evaluator checks N while Generator works on N+1.
- Generator does NOT need to be paused. If E(N) returns PASS: continue normally. If E(N) returns RETRY: let G(N+1) finish naturally, hold its result, send the required fixes for N back through main to Generator, re-evaluate N, then evaluate N+1's held result.
- If E(N) returns BLOCK: let G(N+1) finish. If N+1 does not depend on N, evaluate N+1 normally. If N+1 depends on N, mark N+1 BLOCKED.

**When NOT activated:**
- Next issue depends on current issue → wait for E(N) PASS before dispatching G(N+1)
- Next issue's Target Areas overlap with current issue → wait (file safety)
- Current issue BLOCKED → skip to next eligible issue

This eliminates evaluator wait time (~30-60s per issue) for independent issues without requiring pause/interrupt semantics.

### State Persistence

After each issue verdict (PASS or BLOCKED), write/update `runs/<run_id>/state.json`:

```json
{
  "run_id": "<run_id>",
  "plan_id": "<plan_id>",
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

Status values: `PENDING`, `GENERATING`, `EVALUATING`, `PASS`, `BLOCKED`, `HELD` (pipelined, waiting for prior issue verdict).

This is written after EVERY state transition — not batched at the end. If the session dies, the next invocation reads this file. In-flight issues (`GENERATING`, `EVALUATING`, `HELD`) are treated as `PENDING` on resume (work is re-executed from scratch — safe but costs one re-run).

### Session Hygiene

Context budget defaults are operational guidance, not model facts. Use them to protect judgment on intelligence-sensitive work:
- **Normal:** keep the active session below roughly 30-40% context when possible.
- **Warning:** if the session is around 50%, finish the current issue, persist state, and avoid starting a new issue in the same context.
- **Stop:** if the session is around 60% or shows degradation, write state/handoff, include a compact restart hint, and resume from artifacts in a fresh session.

Treat these symptoms as degradation even if exact token use is unknown: repeated rereads of already-summarized files, forgotten Stop Condition, P1/P2 work leaking into the current issue, contradictory facts, no-change repair loops, or evaluator misses of explicit Acceptance Criteria.

When checkpointing, preserve only durable facts: current issue, plan path, state.json path, changed files, unresolved blockers, user decisions not yet in artifacts, and next command. Drop raw greps, dead-end hypotheses, and failed attempts already superseded by the latest evidence.

### Per-Issue Protocol

For each issue in order:

1. **Dependency check**: if depends on BLOCKED issue → skip, mark BLOCKED.
2. **Build execution pack**: include only this issue's Action, Deliverable, Target Areas, Acceptance Criteria, Test Expectation, Required Evidence, relevant assumptions, dependencies, and directly needed repo context. Include the plan `goal`, relevant `non_goals`, and any upstream decision refs needed to preserve semantic alignment. Do not send whole research logs or unrelated prior issue evidence.
3. **Dispatch Generator**: send the execution pack. Wait for `generator_completion`.
4. **Candidate gate**: Deliverable exists? Evidence produced? If Generator reports BLOCKED → mark issue BLOCKED or continue to independent issues. READY is only candidate-ready, never PASS.
5. **Dispatch Evaluator + Pipeline check**: dispatch Evaluator with issue criteria + Generator evidence. If pipeline conditions are met for the next issue (no dependency, no Target Areas overlap): dispatch Generator for next issue simultaneously. Otherwise: wait for `evaluator_verdict` before proceeding.
6. **Verdict**:
   - PASS → mark issue complete. Only Evaluator can produce this transition. If next issue already generating (pipelined): continue to its evaluation when ready. Otherwise: dispatch next issue.
   - RETRY → main sends `required_fixes` to Generator (max 3 per issue), then re-dispatches Evaluator after Generator returns a new candidate. If next issue was pipelined: let it finish, hold its result until current issue resolves.
   - BLOCK → mark BLOCKED, record reason. If pipelined next issue does not depend on this: evaluate it normally when ready. If it depends: mark BLOCKED.
7. **No-change guard**: repair with zero file changes = same-failure. Do not re-evaluate.

### Team Communication Consistency

Keep communication lightweight and symmetric:
- Every dispatched issue expects structured packets: Generator returns `generator_completion` for candidate readiness or BLOCKED; Evaluator returns `evaluator_verdict` for PASS, RETRY, or BLOCK.
- Idle/startup messages, partial reasoning, and prose summaries are non-terminal. They do not advance state and are not failures by themselves.
- If a lane cannot proceed because the dispatch is unclear, companion rules are missing, or setup is invalid, it returns the same terminal packet with a blocking reason instead of waiting silently.
- Main monitors missing packets, sends at most one clarification/nudge, then rebuilds or replaces the lane if needed.
- A rebuilt or replaced lane must send `lane_ready` before it can receive new work.
- Evaluator failures are fed back to main, not directly patched by Evaluator. Main schedules Generator repair using `required_fixes`. The loop exists to complete the task, not merely report failure.
- Communication failures are orchestration failures, recorded separately from implementation failures.

The issue may continue after lane recovery only if the replacement lane passed preflight, the plan contract is still intact, and Target Areas are not conflicted.

After each PASS, record an issue alignment entry in run evidence or manifest:

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

### Rewind-Style Retry

If a Generator attempt used the wrong approach, do not keep correcting through a long polluted thread. Record the learned constraint, return to the clean issue execution pack, and redispatch a fresh attempt with:
- what the failed attempt proved
- what path must not be repeated
- the unchanged Action and Acceptance Criteria
- the smallest allowed repair direction

This consumes the next normal retry attempt. It never resets or expands the per-issue max of 3 attempts.

Failed raw attempts belong in run evidence. Only confirmed root cause, final repair insight, or a dead end worth avoiding belongs in `learnings.md`.

### HITL Issues

Handle by subtype:
- `HITL:verify` → after Generator completes, ask user to confirm visual/functional correctness. In headless mode: auto-approve (assume correct).
- `HITL:decision` → after Generator completes, present options to user, wait for choice. In headless mode: pick first option, record as LOW-confidence assumption.
- `HITL:action` → pause execution, tell user what manual action is needed (e.g., 2FA, external service config). Cannot auto-approve even in headless mode.

Legacy `HITL` (no subtype) → treat as `HITL:decision`.

### Generator Rules (summary — full in `references/generator-rules.md`)

- Analysis paralysis guard: 5+ reads without edit → act or BLOCKED
- Context quarantine: consider helpers only for broad read-only exploration when they reduce main-context noise
- Deviation classification: auto-fix-local / auto-fix-critical / stop-for-architectural
- Never retry with no changes
- Wrong approach → fresh execution pack with learned constraint, not incremental correction drift
- Destructive git prohibition
- Package install safety (slopsquat protection)
- Scope boundary: only fix what the issue Action specifies

### Evaluator Rules (summary — full in `references/evaluator-thresholds.md`)

- Required Evidence missing → RETRY
- Verification Hint fails → RETRY
- Any Acceptance Criterion unmet → RETRY with specific feedback
- Deliverable doesn't exist → BLOCK
- Scope drift (files outside Target Areas) → BLOCK
- Hard threshold: if Generator self-reports BLOCKED, Evaluator must not override to PASS
- Adversarial mode: for Security + DEEP issues, actively construct failure scenarios
- Simplification pressure: deep nesting, generic names, dead code, unnecessary abstractions in new code → RETRY
- Structured verdict output: machine-parseable format with confidence score
- Confidence anchors: 100 (mechanical) / 75 (traceable) / 50 (conditional) / below 50 (suppress)

### Final Review Gate (triggered)

Evaluator validates each issue against its acceptance criteria. The final review gate reviews the whole diff and cross-issue integration after all issue Evaluator verdicts pass.

Run the final review gate when any trigger is true:
- Plan has 3+ issues
- The run changes 4+ files or 2+ modules
- Any issue touches shared/public interfaces, schemas, build config, CI, auth, permissions, data access, or secrets
- Any issue has `Security: yes`
- The user explicitly requested review

Skip the gate for LIGHT runs when all are true: 1-2 files changed, no shared interface, no security-sensitive surface, automated verification passed, and no justified drift.

Review shape:
- Default: spawn `pge-code-reviewer` (read `agents/pge-code-reviewer.md`) over the final diff, run artifacts, and plan stop condition.
- For runs with 4+ files changed or any issue touching complex logic: spawn `pge-code-simplifier` (read `agents/pge-code-simplifier.md`) in parallel with the code reviewer.
- For security-sensitive or test-heavy DEEP runs, main MAY additionally fan out to at most one specialist read-only reviewer (`security` or `test`) only when its report can run in parallel and be synthesized compactly.
- Do not run broad multi-agent review for simple diffs; review overhead must buy real risk reduction.
- Maximum 3 review agents total per run. Typical: 1-2.

Review axes:
- Correctness: behavior still satisfies the plan after all issues compose.
- Test adequacy: required happy/edge/error paths were verified; bug fixes have regression coverage when applicable.
- Scope and reviewability: diff is explainable, bounded, and free of unrelated churn.
- Maintainability: implementation follows existing repo patterns without speculative abstractions.
- Security: only when the change touches trust boundaries, data access, secrets, auth, permissions, or external input.
- Performance/reliability: only when the plan or changed surface makes it relevant.

Finding handling:
- **Critical:** real bug, security risk, data loss risk, broken build/test, or stop-condition failure. Do not route SUCCESS. If repair is inside the same plan and retry budget remains, send a bounded repair request; otherwise route PARTIAL/BLOCKED with evidence.
- **Important:** likely reviewer-blocking issue or missing required regression test. Repair if it is inside the same plan and bounded; otherwise route PARTIAL with a follow-up.
- **Advisory:** improvement, naming, style, or future cleanup. Do not block SUCCESS; record in `learnings.md`.

Write the synthesized review to `.pge/tasks-<slug>/runs/<run_id>/review.md` when the gate runs. The report should include trigger, files reviewed, verdict (`PASS | REPAIR_REQUIRED | ADVISORY_ONLY | BLOCKED`), findings by severity, and exact file/line evidence.

---

## Phase 3: Verify & Route

### Stop Condition

After all issues processed, check plan's Stop Condition:
- Passes → SUCCESS
- Fails but all issues passed → PARTIAL (integration gap)
- Not all issues passed → PARTIAL or BLOCKED

**Semantic alignment check:** Before SUCCESS, verify the composed diff still satisfies the plan `goal`, preserves `non_goals`, covers all ready issues, and has no unapproved scope drift. If the code is plausible but no longer proves the original plan contract, route PARTIAL and record the gap.

**Integration verification:** If the plan touches 3+ files across 2+ modules, run an integration-level check beyond individual issue verification (full test suite, app startup, or plan-specified integration command). Record result in manifest.

**Regression check:** After all per-issue evaluations pass, re-run Verification Hints from prior PASS issues to confirm they still pass. If any regressed (a later issue broke an earlier issue's deliverable), route PARTIAL with the regression evidence. This catches cross-issue side effects that per-issue evaluation misses.

### Final Review

After Stop Condition, integration verification, and regression checks pass, run the Final Review Gate if triggered. `SUCCESS` requires the gate to be skipped or to return PASS / ADVISORY_ONLY. REPAIR_REQUIRED must either be repaired inside the current bounded plan or route PARTIAL. BLOCKED prevents SUCCESS. Do not auto-invoke `pge-review` or `pge-challenge`; those are explicit next-stage skills for the user to run after `pge-exec` completes.

### Compound (Accumulate Learnings)

After execution completes (any route), record what was learned. This is mandatory — even trivial runs record "No significant learnings — execution matched plan expectations." Empty learnings.md is a protocol violation.

Write to task directory: `.pge/tasks-<slug>/runs/<run_id>/learnings.md`

```markdown
# Learnings: <run_id>

## Patterns Discovered
- <pattern> — source: <file:line> — confidence: HIGH|MEDIUM

## Deviations from Plan
- <what differed> — why: <root cause> — impact: <what it means for future>

## Repair Insights
- <what failed> → <what fixed it> — generalizable: yes|no

## Verification Gaps
- <what the plan's Verification Hint missed> — suggest: <better verification>

## Conventions Confirmed
- <convention the plan assumed correctly> — now verified in code

## Feedback to Config
- <learning significant enough to add to repo-profile.md>
```

**Feedback loop:**
1. If any learning under "Feedback to Config" exists AND `.pge/config/repo-profile.md` exists: append it.
2. If `.pge/config/repo-profile.md` doesn't exist but learnings are significant: create it with the learnings as seed content.
3. Tag each appended learning with `[from: <run_id>, date: <ISO>]` so future runs know the source.
4. **Confidence decay:** learnings older than 30 days should be treated as "verify before relying on" by downstream skills. pge-research should re-check old learnings against current code before using them as facts.
5. **Inline doc updates** (matt-skill grill-with-docs pattern): if execution discovered a domain term mismatch, naming convention, or architectural decision not captured in project docs — update `CONTEXT.md` or create an ADR in `docs/adr/` immediately. Don't batch these; capture as they happen.

### Route

- `SUCCESS`: all issues PASS + Stop Condition passes + final review skipped/PASS/ADVISORY_ONLY
- `PARTIAL`: some progress, some blocked, or final review found bounded unresolved issues
- `BLOCKED`: no issues could complete
- `NEEDS_HUMAN`: HITL decision required

### Completion gate

Do NOT declare execution complete, summarize completion, or change routes until BOTH are true:

1. The run artifacts have been written under `.pge/tasks-<slug>/runs/<run_id>/`, including manifest and learnings
2. You are about to output the Final Response block exactly once

If the user redirects the work mid-run, or the session needs to stop early, persist the current run state and artifacts first, then route as `PARTIAL`, `BLOCKED`, or `NEEDS_HUMAN` instead of silently exiting.

### Teardown

Request shutdown from active lanes, require each lane to approve the shutdown through the team runtime protocol using the request ID from `shutdown_request`, wait for runtime-level shutdown approval or teammate termination, delete the current team context, then write the manifest. A plain-text `shutdown_response` message is only a lane-level acknowledgement; it does not prove the teammate actually exited. If a lane does not acknowledge shutdown through the protocol or does not terminate, record the teardown failure and route `BLOCKED` rather than silently continuing.

---

## Smoke Test

Argument `test` uses an inline smoke plan bound to a dedicated task directory:
```
Task directory: .pge/tasks-smoke-test/
Issue 1: Write smoke file
- Action: Create .pge/tasks-smoke-test/runs/<run_id>/deliverables/smoke.txt with content "pge smoke"
- Deliverable: smoke.txt
- Target Areas: Create: .pge/tasks-smoke-test/runs/<run_id>/deliverables/smoke.txt
- Acceptance Criteria: file exists, content = "pge smoke"
- Verification Type: AUTOMATED
- Verification Hint: cat .pge/tasks-smoke-test/runs/<run_id>/deliverables/smoke.txt
- Test Expectation: none (smoke test)
- Required Evidence: file content output
- Execution Type: AFK
- Stop Condition: smoke.txt exists with correct content
```

For test: minimal dispatch, no handoff file reads. Create `.pge/tasks-smoke-test/` and write all artifacts under that task directory. Rollback tag is skipped for smoke.

---

## Output

```text
.pge/tasks-<slug>/
├── research.md                 (from pge-research)
├── plan.md                     (from pge-plan)
└── runs/
    └── <run_id>/
        ├── manifest.md         — run metadata + issue results
        ├── evidence/           — per-issue evidence
        ├── deliverables/       — actual deliverables
        ├── review.md           — final review report when review gate runs
        └── learnings.md        — compound learnings
```

## Final Response

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
- learnings_recorded: yes | no
- artifacts: .pge/tasks-<slug>/runs/<run_id>/
- next: done | pge-review <task-slug> | pge-challenge <task-slug> | pge-plan (if blocked) | user decision (if HITL)
```

## Guardrails

Do not:
- Modify the plan
- Write business code in orchestrator instead of dispatching Generator
- Use chat-only implementation summaries or pseudocode as a stand-in for generator output and run artifacts
- Skip Evaluator
- Retry > 3 per issue
- Retry with no code changes
- Allow destructive git
- Auto-retry failed package installs
- Simulate Generator/Evaluator in main
- Output PASS/MERGED/SHIPPED as route
- Advance from idle_notification
