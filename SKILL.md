---
name: pge
description: Use when repo-internal work spans multiple rounds and the main risks are scope drift, role mixing, weak review, stale execution state, unclear handoffs, or isolated skeletons. Best fit when a governing plan already exists and the work needs bounded delivery, independent acceptance, and explicit convergence across rounds.
---

# PGE

A lightweight execution skill for repo-internal multi-round work.

This skill keeps phase work small, real, and handoff-ready. It separates scheduling, planning, generation, and evaluation without turning the work into a heavy framework.

PGE is not the plan host. It consumes an upstream plan, blueprint, or exec-plan, freezes the current scope into execution contracts, and runs the current-round execution loop.

**Core principle:** treat the current phase contract as the execution blueprint for this round. Planner freezes the current phase and task contract as a bounded, plan-faithful slice; Generator builds only that slice with a concrete deliverable and minimum required verification; Evaluator independently accepts or blocks against the contract and evidence; Main / Scheduler only orchestrates routing, progress, and convergence so the loop stays aligned without turning orchestration into hidden architecture or review.

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

Upstream planning stays outside PGE. Inside PGE, these roles own only the current-scope execution loop.

### Main / Scheduler (orchestration layer)
Own orchestration only.
- receive the user request or the last confirmed state,
- route the current round to Planner, Generator, or Evaluator,
- dispatch the current task contract,
- maintain `progress.md`,
- collect evaluation results,
- route whether to continue, retry, shrink and retry, return to Planner for contract repair, or converge,
- route unresolved ambiguity, conflict, or deviation to the right lane.

Main / Scheduler does **not**:
- author the phase contract,
- author the task contract,
- generate the deliverable,
- perform the independent acceptance,
- act as the default planner, architect, reviewer, or content owner,
- silently weaken the contract when the process gets busy.

### Planner
Own the current phase contract and task contract.
- freeze the current phase contract,
- shape the current task contract as a bounded execution slice,
- preserve the handoff seam for the next task or phase,
- enforce anti-overreach before generation starts,
- avoid over-fragmentation that turns execution into bookkeeping,
- return ambiguity to Main / Scheduler when the current contract cannot be frozen cleanly.

Planner does **not**:
- implement the deliverable,
- expand into a full architecture role,
- write low-level implementation design that the current phase does not need,
- weaken contract quality or validation requirements to make the task easier,
- leave key semantic or validation gaps for Generator to guess.

### Generator
Own bounded execution of the assigned task contract.
- execute only tasks that are already defined and verifiable,
- produce the deliverable named in the current task contract,
- produce the minimum required verification for that deliverable,
- stop and escalate when contract ambiguity blocks high-quality execution,
- return deliverable, validation evidence, and explicit unverified areas.

Generator does **not**:
- expand the task,
- upgrade the phase goal,
- implement the next phase opportunistically,
- turn the current task back into a design exercise,
- reinterpret contract intent,
- use excessive comments or explanation-heavy output to compensate for unclear boundaries.

### Evaluator
Own independent acceptance against the task contract and phase contract.
- evaluate the deliverable against the contract and evidence, not the Generator’s self-report,
- verify task completion,
- check contract fidelity,
- inspect validation evidence,
- detect deviations, ambiguity, and quality shortfalls,
- apply blocking pressure until the acceptance verdict is stable,
- escalate unresolved plan/task questions to Main / Scheduler.

Evaluator does **not**:
- resolve plan/task conflicts locally,
- pass work with blocking issues,
- accept work based on Generator narrative instead of the artifact and evidence,
- become self-review.

### Optional: Evidence Reader
Use only when evidence retrieval is expensive or scattered.
This is a temporary support role, not a standing role.

## Execution loop

### Round 0 — Contract freeze
Planner freezes the current phase and task contract as a bounded, plan-faithful slice of the upstream blueprint.
Main / Scheduler records the agreed round state in `progress.md`, dispatches the slice, and routes unresolved ambiguity back to Planner instead of judging contract content itself.

If the upstream plan is incomplete, ambiguous, or in conflict with high-quality execution for the current round, stop and return to Planner for contract repair instead of letting Generator guess.

### Round 1 — Bounded execution
Generator executes the current task contract and returns the named deliverable, minimum required validation evidence, and explicit unverified areas.

If contract ambiguity blocks high-quality execution, Generator stops and escalates instead of filling the gap locally or reopening design.

### Round 2 — Independent acceptance
Evaluator reviews the deliverable against both the task contract and the blueprint.
Evaluation may take multiple rounds until the verdict is stable.

If the task slice conflicts with the plan, the implementation undermines blueprint intent, or a deviation cannot be judged locally, escalate to Main / Scheduler instead of resolving the conflict inside evaluation.

### Round 3 — Convergence routing
Main / Scheduler updates `progress.md` and routes one of:
- continue,
- retry,
- shrink and retry,
- return to Planner for contract repair,
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
- [evaluation-gate.md](./evaluation-gate.md) — independent acceptance, multi-round evaluation, scoring, verdicts, and evaluation anti-patterns
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
- convergence routing outcome,
- accepted deviations or escalation outcome,
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
