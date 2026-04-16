---
name: pge
description: Use when repo-internal work spans multiple rounds and the main risks are scope drift, role mixing, weak review, stale execution state, unclear handoffs, or isolated skeletons. Best fit when a governing plan already exists and the work needs bounded delivery, independent acceptance, and explicit convergence across rounds.
---

# PGE

A lightweight execution skill for repo-internal multi-round work.

This skill keeps phase work small, real, and handoff-ready. It separates scheduling, planning, generation, and evaluation without turning the work into a heavy framework.

**Core principle:** treat the plan as the execution blueprint. Freeze only a plan-faithful task slice, execute without filling strategic gaps, evaluate against both the task slice and the blueprint, and let Main / Scheduler govern ambiguity, conflict, deviation, and completion decisions so each round advances high-quality work instead of just advancing the process.

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
- large workflow frameworks with many content roles or heavy standing ceremony.

## Team model

Use **3 working roles plus 1 orchestration layer**.

### Main / Scheduler (orchestration layer)
Own execution governance.
- receive the user request or the last confirmed state,
- interpret the plan as the governing blueprint for the current round,
- ask Planner to freeze a plan-faithful task slice,
- dispatch the current task contract,
- maintain `progress.md`,
- collect evaluation results,
- decide whether to continue, retry, shrink and retry, return to Planner for blueprint repair, or converge,
- decide whether any detected deviation from the blueprint is acceptable.

Main / Scheduler does **not**:
- write the phase contract itself,
- generate the deliverable,
- perform the independent evaluation,
- silently weaken the plan,
- absorb other roles when the process gets busy.

### Planner
Own the current blueprint-aligned phase and task contract.
- convert the plan into the current-round task slice,
- preserve plan-level quality and validation requirements in that slice,
- resolve ambiguity that Main / Scheduler routes back for blueprint repair before generation starts.

Planner does **not**:
- weaken blueprint quality requirements to make the task easier,
- leave key semantic or validation gaps for Generator to guess.

### Generator
Own strict execution of the assigned task contract.
- implement only what the current task slice clearly authorizes,
- stop and escalate when blueprint or task ambiguity blocks high-quality execution,
- return deliverable, validation evidence, and explicit unverified areas.

Generator does **not**:
- fill strategic gaps in the plan,
- reinterpret blueprint intent,
- use excessive comments or explanation-heavy output to compensate for unclear plan or task boundaries.

### Evaluator
Own independent review against both the task slice and the blueprint.
- verify task completion,
- check blueprint fidelity,
- inspect validation evidence,
- detect deviations, ambiguity, and quality shortfalls,
- escalate governance questions to Main / Scheduler.

Evaluator does **not**:
- resolve plan/task conflicts locally,
- pass work that satisfies the task slice but undermines the blueprint,
- become self-review.

### Optional: Evidence Reader
Use only when evidence retrieval is expensive or scattered.
This is a temporary support role, not a standing role.

## Execution loop

### Round 0 — Blueprint alignment
Planner freezes the current phase and task contract as a plan-faithful slice of the blueprint.
Main / Scheduler verifies that the slice preserves plan-level quality and validation expectations, then records the round state in `progress.md`.

If the plan is incomplete, ambiguous, or in conflict with high-quality execution, stop and return to Planner for blueprint repair instead of letting Generator guess.

### Round 1 — Strict execution
Generator executes the current task contract and returns the deliverable, explicit validation evidence, and explicit unverified areas.

If blueprint or task ambiguity blocks high-quality execution, Generator stops and escalates instead of filling the gap locally.

### Round 2 — Blueprint-aware evaluation
Evaluator reviews the deliverable against both the task contract and the blueprint.
Evaluation may take multiple rounds until the verdict is stable.

If the task slice conflicts with the plan, the implementation undermines blueprint intent, or a deviation cannot be judged locally, escalate to Main / Scheduler instead of resolving the conflict inside evaluation.

### Round 3 — Governance decision
Main / Scheduler updates `progress.md` and decides one of:
- continue,
- retry,
- shrink and retry,
- return to Planner for blueprint repair,
- converge and hand off to the next phase.

If another round is needed, the next round must be:
- smaller,
- clearer,
- easier to verify,
- closer to convergence,
- and still faithful to the blueprint.

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

If the Evaluator has not reviewed the current deliverable against both the current task contract and the blueprint, the task is not done.

A task is also not complete if:
- required validation evidence is missing,
- the deliverable conflicts with the blueprint,
- completion depends on unresolved blueprint ambiguity,
- or Main / Scheduler has not accepted a detected deviation.

## Output format

### Main / Scheduler output
- current progress,
- current worklist,
- no-touch boundary,
- blueprint governance decision,
- accepted or rejected deviations,
- `progress.md` update.

### Planner output
- current phase contract,
- current task contract,
- blueprint fidelity statement,
- key boundary choices,
- unresolved ambiguities,
- required validation for this slice,
- handoff seam.

### Generator output
- current task,
- boundary,
- deliverable,
- validation evidence actually produced,
- explicit unverified areas,
- explicit non-done items,
- ambiguity or escalation needs,
- seam status.

### Evaluator output
- scores,
- verdict,
- blocking issues,
- plan/task alignment check,
- validation evidence check,
- deviation report,
- overreach check,
- isolated-skeleton check,
- handoff quality judgment,
- escalation recommendation to Main / Scheduler when needed.

Keep outputs short, actionable, and reviewable.
