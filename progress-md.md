# progress.md

Use this file when maintaining state across multiple rounds.

`progress.md` is the canonical state file for Main / Scheduler. Keep it short. Generator and Evaluator append execution and evaluation state when they produce new results.

## What `progress.md` should record

- current phase,
- current task,
- current boundary,
- current blueprint fidelity status,
- latest deliverable,
- latest evaluation verdict,
- validation evidence status,
- unresolved plan/task conflicts,
- open blockers,
- latest routing decision by Main / Scheduler,
- next planned step.

## What `progress.md` should not become

Do **not** turn `progress.md` into:
- a diary,
- a design doc,
- a full transcript,
- a backlog dump,
- a pseudo-plan for future phases.

Its job is to preserve the current execution and routing state across rounds.

## Update points

Main / Scheduler should update `progress.md` at these points:
1. after blueprint alignment,
2. after the Generator returns the current deliverable,
3. after each evaluation round,
4. after Main / Scheduler routes continue / retry / shrink / return to Planner / handoff.

## Mandatory updates by role

### Generator (after completing task)

Generator MUST update `progress.md` after generation:

1. Use Edit tool to update progress.md
2. Change task status from "⏳ in progress" to "✅ generated, awaiting evaluation"
3. Add timestamp and file list
4. Record:
   - verification commands run,
   - evidence produced,
   - what remains unverified,
   - whether ambiguity blocked full execution.

Example:
```markdown
- [x] Task 2: FeatureTableMeta ✅ GENERATED (2026-04-16)
  - Files: model_server/ftable/feature_table_meta.h
  - Verification: bazel test //model_server/ftable:feature_table_meta_test
  - Evidence: test target failed as expected before implementation, now passes
  - Unverified: duplicate compat mapping path not yet covered
  - Status: Awaiting evaluation
```

5. Notify Evaluator that task is ready for evaluation

**Do NOT skip this step.** Progress tracking depends on it.

### Evaluator (after completing evaluation)

Evaluator MUST update `progress.md` after evaluation:

1. Use Edit tool to update progress.md
2. Change task status to include score and verdict
3. Add evaluation summary recording:
   - whether the task slice was satisfied,
   - whether plan fidelity was preserved,
   - whether evidence was sufficient,
   - whether escalation to Main / Scheduler is required.

Example for PASS:
```markdown
- [x] Task 2: FeatureTableMeta ✅ PASS (5/5)
  - Task slice satisfied: yes
  - Blueprint fidelity preserved: yes
  - Evidence sufficient: yes
  - Ready for next task
```

Example for BLOCK:
```markdown
- [ ] Task 2: FeatureTableMeta ❌ BLOCK (0/5)
  - Task slice satisfied: partial
  - Blueprint fidelity preserved: no
  - Evidence sufficient: no
  - Action: Generator must fix missing validation evidence before proceeding
```

Example for ESCALATE:
```markdown
- [ ] Task 2: FeatureTableMeta ⚠️ ESCALATE TO MAIN
  - Task slice satisfied: yes
  - Blueprint fidelity preserved: unclear
  - Evidence sufficient: yes
  - Conflict: task wording and plan intent point in different directions
```

4. Notify Main / Scheduler of evaluation results

**Do NOT skip this step.** Main / Scheduler needs this to make decisions.

### Main / Scheduler (after routing decision)

After receiving task completion or evaluation notifications:

1. Read `progress.md` to verify it reflects current state
2. If `progress.md` is stale (doesn't match execution reality):
   - Update it yourself
   - Remind the responsible agent to update next time
3. After making a routing decision, record:
   - continue / retry / shrink / return to Planner / converge,
   - reason for the decision,
   - whether any deviation was accepted or rejected.

Example:
```markdown
- Routing: RETURN TO PLANNER
  - Reason: current task slice weakens plan-level validation requirement
  - Deviation accepted: no
```

**Why this matters:**
`progress.md` is the source of truth for multi-session collaboration and routing state.
Stale progress causes confusion, duplicate work, and blueprint drift.

## Why this matters

Without `progress.md`, state leaks back into conversational memory and each round risks reopening settled context.

A good `progress.md` lets the next round start from confirmed execution state, evidence state, and routing state instead of re-inflated discussion.
