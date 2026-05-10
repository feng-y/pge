---
name: pge-exec
description: >
  Execute pge-plan issues using Generator + Evaluator agents.
  Consumes .pge/plans/<plan_id>.md, dispatches per-issue execution,
  validates with independent Evaluator, bounded repair loop, accumulates learnings.
version: 1.0.0
argument-hint: "<plan_id> | test"
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

Execute a plan produced by `pge-plan`. Orchestrates Generator and Evaluator agents per issue.

This is an orchestration skill. It does not implement code itself.

## Execution Flow

```dot
digraph pge_exec {
  rankdir=TB;
  node [shape=box, style=rounded];

  load_plan [label="Load Plan"];
  validate [label="Validate\n(READY_FOR_EXECUTE?)"];
  create_team [label="Create Team\n(generator + evaluator)"];

  subgraph cluster_loop {
    label="Per-Issue Loop";
    style=dashed;
    dispatch_gen [label="Dispatch Generator\n(handoffs/generator.md)"];
    gen_done [label="Generator?", shape=diamond];
    dispatch_eval [label="Dispatch Evaluator\n(handoffs/evaluator.md)"];
    verdict [label="Verdict?", shape=diamond];
    repair [label="Repair\n(required_fixes)"];
    pass [label="Issue PASS"];
    blocked [label="Issue BLOCKED"];
  }

  plan_verify [label="Stop Condition Check"];
  compound [label="Compound\n(accumulate learnings)"];
  route [label="Route + Teardown", shape=doublecircle];

  load_plan -> validate -> create_team -> dispatch_gen;
  dispatch_gen -> gen_done;
  gen_done -> dispatch_eval [label="READY"];
  gen_done -> blocked [label="BLOCKED"];
  dispatch_eval -> verdict;
  verdict -> pass [label="PASS"];
  verdict -> repair [label="RETRY (< 3)"];
  verdict -> blocked [label="BLOCK / max"];
  repair -> dispatch_eval;
  pass -> dispatch_gen [label="next issue"];
  pass -> plan_verify [label="all done"];
  blocked -> dispatch_gen [label="non-blocking"];
  blocked -> route [label="blocking"];
  plan_verify -> compound -> route;
}
```

## Anti-Patterns

- **"Replan While Executing"** — Plan is frozen. If wrong, route back to pge-plan.
- **"Fix Everything I See"** — Stay inside issue scope. Unrelated bugs → deferred items.
- **"Repair Forever"** — Max 3 attempts per issue. Then BLOCKED.
- **"Skip Evaluator"** — Every issue gets independent evaluation. No exceptions.

---

## Phase 1: Load & Validate

Read plan from `.pge/tasks-<slug>/plan.md` (preferred) or `.pge/plans/<plan_id>.md` (legacy). If argument is `test`, use inline smoke plan.

**Task directory resolution:** If plan is at `.pge/tasks-<slug>/plan.md`, all run output goes to `.pge/tasks-<slug>/runs/<run_id>/`. This keeps the full pipeline (research → plan → exec) under one task directory.

Validate:
- `plan_route` = `READY_FOR_EXECUTE`
- ≥1 issue with `State: READY_FOR_EXECUTE`
- Stop Condition present

If invalid: route BLOCKED, report what's missing.

Extract issues from `## Slices`. Filter READY_FOR_EXECUTE. Order by ID.

---

## Phase 2: Execute (Per-Issue Loop)

### Create Team

Two teammates only:
- `generator` — implements issues (read `handoffs/generator.md` for dispatch protocol)
- `evaluator` — validates independently (read `handoffs/evaluator.md` for dispatch protocol)

No Planner. The plan IS the frozen contract.

### Per-Issue Protocol

For each issue in order:

1. **Dependency check**: if depends on BLOCKED issue → skip, mark BLOCKED.
2. **Dispatch Generator**: issue context (Action, Deliverable, Target Areas, Test Expectation, Required Evidence, Repo Context). Wait for `generator_completion`.
3. **Gate**: Deliverable exists? Evidence produced? BLOCKED → mark and continue.
4. **Dispatch Evaluator**: issue criteria (Acceptance Criteria, Required Evidence, Verification Hint, Verification Type) + Generator evidence. Wait for `evaluator_verdict`.
5. **Verdict**:
   - PASS → mark done, next issue
   - RETRY → send `required_fixes` to Generator (max 3 per issue), re-evaluate
   - BLOCK → mark BLOCKED, record reason
6. **No-change guard**: repair with zero file changes = same-failure. Do not re-evaluate.

### HITL Issues

`Execution Type: HITL` → after Generator completes, pause and ask user the decision. Resume with answer as context.

### Generator Rules (summary — full in `references/generator-rules.md`)

- Analysis paralysis guard: 5+ reads without edit → act or BLOCKED
- Deviation classification: auto-fix-local / auto-fix-critical / stop-for-architectural
- Never retry with no changes
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

---

## Phase 3: Verify & Route

### Stop Condition

After all issues processed, check plan's Stop Condition:
- Passes → SUCCESS
- Fails but all issues passed → PARTIAL (integration gap)
- Not all issues passed → PARTIAL or BLOCKED

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

### Route

- `SUCCESS`: all issues PASS + Stop Condition passes
- `PARTIAL`: some progress, some blocked
- `BLOCKED`: no issues could complete
- `NEEDS_HUMAN`: HITL decision required

### Teardown

Request shutdown → delete team → write manifest.

---

## Smoke Test

Argument `test` uses inline plan:
```
Issue 1: Write smoke file
- Action: Create .pge/runs/<run_id>/deliverables/smoke.txt with content "pge smoke"
- Deliverable: smoke.txt
- Acceptance Criteria: file exists, content = "pge smoke"
- Verification Type: AUTOMATED
- Execution Type: AFK
- Required Evidence: file content output
- Stop Condition: smoke.txt exists with correct content
```

For test: minimal dispatch, no handoff file reads.

---

## Output

```text
.pge/tasks-<slug>/              (preferred — full pipeline in one directory)
├── research.md                 (from pge-research)
├── plan.md                     (from pge-plan)
└── runs/
    └── <run_id>/
        ├── manifest.md         — run metadata + issue results
        ├── evidence/           — per-issue evidence
        ├── deliverables/       — actual deliverables
        └── learnings.md        — compound learnings

Legacy fallback: .pge/runs/<run_id>/ (when plan is at .pge/plans/)
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
- learnings_recorded: yes | no
- artifacts: .pge/runs/<run_id>/
- next: done | pge-plan (if blocked) | user decision (if HITL)
```

## Guardrails

Do not:
- Modify the plan
- Write business code in orchestrator
- Skip Evaluator
- Retry > 3 per issue
- Retry with no code changes
- Allow destructive git
- Auto-retry failed package installs
- Simulate Generator/Evaluator in main
- Output PASS/MERGED/SHIPPED as route
- Advance from idle_notification
