---
name: pge
description: Use when work spans multiple rounds and needs a clear phase contract, small verifiable task contracts, explicit progress tracking, separated planning/generation/evaluation, and a clean seam into the next phase. Use when the main risks are scope drift, role mixing, weak review, stale context across rounds, or building an isolated skeleton instead of a handoff-ready increment.
---

# PGE

A lightweight execution skill for repo-internal multi-round work.

This skill keeps phase work small, real, and handoff-ready. It separates scheduling, planning, generation, and evaluation without turning the work into a heavy framework.

**Core principle:** freeze the current phase contract, generate only bounded work, evaluate independently, and keep `progress.md` current so the next round starts from evidence instead of memory.

## What this skill is for

Use this skill when:
- the task spans multiple rounds,
- the current phase must stay bounded,
- each task must be independently verifiable,
- planning, generation, and evaluation should stay separate,
- the current phase must leave a usable seam for the next phase,
- context would otherwise sprawl across rounds,
- the user wants review and convergence without heavy ceremony.

Do **not** use this skill for:
- one-shot trivial edits,
- pure ideation before any phase boundary exists,
- web/app/browser harness flows,
- project-specific SOPs,
- large workflow frameworks with many standing roles.

## Team model

Use at most **4 standing roles**.

### Main / Scheduler
Own orchestration only.
- receive the user request or the last confirmed state,
- ask Planner to freeze the current phase contract,
- dispatch the current task contract,
- maintain `progress.md`,
- collect evaluation results,
- decide whether to continue, retry, shrink, or converge.

Main / Scheduler does **not**:
- write the phase contract itself,
- generate the deliverable,
- perform the independent evaluation,
- absorb other roles when the process gets busy.

### Planner
Own the current **phase contract**.

### Generator
Own delivery for the assigned task contract.

### Evaluator
Own independent acceptance.

### Optional: Evidence Reader
Use only when evidence retrieval is expensive or scattered.
This is a temporary support role, not a standing role.

## Execution loop

### Round 0 — Contract freeze
Planner freezes the current phase and task contract.
Main / Scheduler records the round state in `progress.md`.

### Round 1 — Generate
Generator executes the current task contract and returns the deliverable plus minimal verification evidence.

### Round 2 — Independent evaluation
Evaluator reviews the deliverable against the task contract.
Evaluation may take multiple rounds until the verdict is stable.

### Round 3 — Convergence
Main / Scheduler updates `progress.md` and decides one of:
- continue,
- retry,
- shrink and retry,
- converge and hand off to the next phase.

If another round is needed, the next round must be:
- smaller,
- clearer,
- easier to verify,
- closer to convergence.

## Supporting files

Read the supporting files based on what you need:

- [phase-contract.md](./phase-contract.md) — phase contract, task contract, acceptable vs unacceptable task shapes, anti-overreach, anti-isolated-skeleton rules
- [evaluation-gate.md](./evaluation-gate.md) — independent evaluation, multi-round evaluation, scoring, verdicts, and evaluation anti-patterns
- [progress-md.md](./progress-md.md) — what `progress.md` should record, what it must not become, and when Main / Scheduler updates it

## Guardrails

Reject or correct these patterns:
- Main doing production work
- Planner over-fragmenting the work
- Generator expanding the task
- Evaluator becoming self-review
- Smuggling in the next phase
- Building an isolated skeleton
- Abstracting for appearance
- Writing plans as pseudo-implementation
- Replacing progress with chat history
- Repeating dev-cycle heaviness

## Completion gate

**No task is complete without independent evaluation evidence.**

If the Evaluator has not reviewed the current deliverable against the current task contract, the task is not done.

## Output format

### Main / Scheduler output
- current progress,
- current worklist,
- no-touch boundary,
- convergence decision,
- `progress.md` update.

### Planner output
- current phase contract,
- current task contract,
- key boundary choices,
- handoff seam.

### Generator output
- current task,
- boundary,
- deliverable,
- minimal verification result,
- explicit non-done items,
- seam status.

### Evaluator output
- scores,
- verdict,
- blocking issues,
- overreach check,
- isolated-skeleton check,
- handoff quality judgment.

Keep outputs short, actionable, and reviewable.
