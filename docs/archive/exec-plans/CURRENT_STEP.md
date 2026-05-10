# CURRENT_STEP

## Active stage

Stage 0.5C — Planner stabilization

## Current step

Complete the new Planner design implementation plan and keep the runtime Planner surface aligned with it.

## Why this step matters now

Planner must freeze the current-round task boundary, DoD, evidence basis, and failure modes before Generator and Evaluator can be tightened. If Planner remains vague, later agents will continue to fill in missing semantics.

## Done when

- `docs/exec-plans/ROUND_012_PLANNER_STABILIZATION.md` exists
- Planner agent, handoff, round contract, and validator agree on the new Planner output surface
- Planner owns current-round task split and DoD
- Planner does not own full-project backlog scheduling
- Static contract validation passes

## Inputs to read

1. `docs/exec-plans/CURRENT_MAINLINE.md`
2. `docs/exec-plans/ROUND_012_PLANNER_STABILIZATION.md`
3. `docs/exec-plans/CURRENT_STEP.md`
4. `agents/pge-planner.md`
5. `skills/pge-execute/handoffs/planner.md`
6. `skills/pge-execute/contracts/round-contract.md`
7. `skills/pge-execute/contracts/runtime-event-contract.md`
8. `bin/pge-validate-contracts.sh`

## Non-goals

- redesigning Generator
- redesigning Evaluator
- adding new agents
- splitting Planner into researcher / architect agents
- implementing multi-round backlog scheduling
- running proving before the static Planner surface is stable

## Evidence to collect

- New Planner stabilization plan
- Updated Planner runtime surface
- Static validator result

## Blockers

- none currently known

## Next step after completion

Start Generator stabilization.
