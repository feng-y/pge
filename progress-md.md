# progress.md

Use this file when maintaining state across multiple rounds.

`progress.md` is maintained by Main / Scheduler and should stay short.

## What `progress.md` should record

- current phase,
- current task,
- current boundary,
- latest deliverable,
- latest evaluation verdict,
- open blockers,
- next planned step.

## What `progress.md` should not become

Do **not** turn `progress.md` into:
- a diary,
- a design doc,
- a full transcript,
- a backlog dump,
- a pseudo-plan for future phases.

Its job is to preserve the current execution state across rounds.

## Update points

Main / Scheduler should update `progress.md` at these points:
1. after contract freeze,
2. after the Generator returns the current deliverable,
3. after each evaluation round,
4. after convergence decides continue / retry / shrink / handoff.

## Mandatory updates by role

### Generator (after completing task)

Generator MUST update `progress.md` after generating code:

1. Use Edit tool to update progress.md
2. Change task status from "⏳ in progress" to "✅ generated, awaiting evaluation"
3. Add timestamp and file list

Example:
```markdown
- [x] Task 2: FeatureTableMeta ✅ GENERATED (2026-04-16)
  - Files: model_server/ftable/feature_table_meta.h
  - Status: Awaiting evaluation
```

4. Notify Evaluator that task is ready for evaluation

**Do NOT skip this step.** Progress tracking depends on it.

### Evaluator (after completing evaluation)

Evaluator MUST update `progress.md` after evaluation:

1. Use Edit tool to update progress.md
2. Change task status to include score and verdict
3. Add evaluation summary

Example for PASS:
```markdown
- [x] Task 2: FeatureTableMeta ✅ PASS (10/10)
  - All acceptance criteria met
  - Contract compliance verified
  - Ready for next task
```

Example for BLOCK:
```markdown
- [ ] Task 2: FeatureTableMeta ❌ BLOCK (0/10)
  - Missing: dataset_key field (required by contract)
  - Action: Generator must fix before proceeding
```

4. Notify Main / Scheduler of evaluation results

**Do NOT skip this step.** Main / Scheduler needs this to make decisions.

### Main / Scheduler (periodic check)

After receiving task completion or evaluation notifications:

1. Read progress.md to verify it reflects current state
2. If progress.md is stale (doesn't match code reality):
   - Update it yourself
   - Remind the responsible agent to update next time

**Why this matters:**
progress.md is the source of truth for multi-session collaboration.
Stale progress causes confusion and duplicate work.

## Why this matters

Without `progress.md`, state leaks back into conversational memory and each round risks reopening settled context.

A good `progress.md` lets the next round start from confirmed state instead of re-inflated discussion.
