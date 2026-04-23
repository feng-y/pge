# PGE_EXECUTE_ORCHESTRATION

## Purpose

This file is the skill-owned operational seam for `main` inside `skills/pge-execute/`.

It defines the run-level orchestration behavior used by `/pge-execute` for the current stage:
- upstream plan intake
- run initialization
- runtime state ownership
- Planner / Generator / Evaluator dispatch and handoff behavior
- route / stop / recovery behavior
- unsupported-route fail-fast
- artifact-chain gates and checkpoint expectations for one bounded round

`main` is skill-internal orchestration logic only. It is not an agent and it is not a peer runtime role alongside Planner / Generator / Evaluator.

## Relationship to nearby seams

- `skills/pge-execute/SKILL.md` is the entrypoint and dispatcher.
- `skills/pge-execute/contracts/*` are the runtime-facing contracts used by the skill.
- `docs/exec-plans/PGE_ORCHESTRATION_CONTRACT.md` records the architectural ownership split.
- `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md` records the current-stage control-plane policy that this file operationalizes.

If the skill behavior changes, update this file and then align the exec-plan docs in the same change.

## Role split

- `main` = skill-internal orchestration shell / run-level scheduler / runtime-state owner
- Planner = slice scheduler / boundary owner
- Generator = deliverable owner
- Evaluator = validation gate / route-signal producer

The persistent runtime team is Planner / Generator / Evaluator only.

## Runtime ownership

`main` owns:
- resolving the effective upstream plan
- creating per-run artifact locations
- initializing and updating runtime state
- planner preflight before generation
- generator/evaluator artifact gates before routing
- canonical route selection from evaluator verdict plus stop condition
- stop / recovery records
- fail-fast handling when the selected canonical route is unsupported in the current stage

`main` must not:
- invent Planner, Generator, or Evaluator content
- absorb slice-shaping work from Planner
- absorb deliverable work from Generator
- absorb acceptance work from Evaluator
- silently redispatch unsupported routes

## Minimal runtime team lifecycle for Stage 2

Stage 2 defines one minimal lifecycle only:
- `bootstrap`
- `dispatch`
- `handoff`
- `teardown`

This lifecycle is the current implementation target for `/pge-execute`.
It is intentionally smaller than full multi-round orchestration.

### `bootstrap`

`main`:
- resolves the effective upstream plan
- creates per-run artifact locations
- initializes per-run runtime state
- validates entry before the runtime team starts work

Bootstrap ends only when the run is ready for Planner dispatch without ambiguity.

### `dispatch`

`main` dispatches the persistent runtime teammates in bounded order:
- `pge-planner`
- `pge-generator`
- `pge-evaluator`

Dispatch must keep inputs scoped to each role.
`main` remains the orchestration shell and does not become a fourth teammate.

### `handoff`

Every teammate handoff must be file-backed and gateable:
- Planner handoff is the frozen round contract
- Generator handoff is the implementation bundle plus evidence
- Evaluator handoff is the verdict bundle plus canonical route signal

A handoff is not complete until the receiving step has the required artifact and the artifact passes the structural gate for that seam.

### `teardown`

`main` owns teardown after route selection.
Teardown means:
- persist the final route decision into runtime state
- write the required checkpoint or summary artifact for the terminal outcome reached in this stage
- stop the bounded run without hidden transcript-only state

For the current stage, both `converged` and `unsupported_route` are teardown exits.

## Runtime files

Use the runtime file locations declared in `skills/pge-execute/SKILL.md`:
- `artifact_dir`
- `planner_artifact`
- `generator_artifact`
- `evaluator_artifact`
- `summary_artifact`
- `runtime_state`
- `checkpoint_artifact`

All state is per-run and keyed by `run_id`.

## Bounded execution flow

Execute this flow in order for one bounded round.

### `bootstrap`

1. Resolve the effective upstream plan from `SKILL.md` argument handling.
2. Create `artifact_dir` if needed.
3. Initialize `runtime_state` using `skills/pge-execute/contracts/runtime-state-contract.md` with the bounded single-round defaults.
4. Validate the effective upstream plan against `skills/pge-execute/contracts/entry-contract.md`.
   - If entry fails, set `state: failed_upstream`, report the missing required fields, and stop.
5. Set runtime state to `planning_round`.

### `dispatch`

6. Dispatch `pge-planner` with:
   - the effective upstream plan
   - a short runtime-state summary
   - the required planner artifact section list from `skills/pge-execute/contracts/round-contract.md`
7. Persist the returned planner artifact.
8. Set runtime state to `preflight_pending`.
9. Preflight the planner artifact.
   - It must exist.
   - It must satisfy the round-contract sections.
   - If preflight fails, set `state: preflight_failed`, report the missing fields, and stop.
   - If preflight passes, set `latest_preflight_result: pass`, set `state: ready_to_generate`, and write `checkpoint_artifact` with `recovery_entry_point: resume_generation`.
10. Set runtime state to `generating`.
11. Dispatch `pge-generator` in `acceptEdits` mode with:
   - the full planner artifact
   - only the minimum repo context needed for the declared deliverable and verification path
   - the required generator artifact section list
12. Persist the returned generator artifact.
13. Set runtime state to `awaiting_evaluation`.
14. Set runtime state to `evaluating`.
15. Dispatch `pge-evaluator` with:
   - the full planner artifact
   - the full generator artifact
   - a short current runtime-state summary
   - the required evaluator artifact section list from `skills/pge-execute/contracts/evaluation-contract.md`
16. Persist the returned evaluator artifact.
17. Set runtime state to `routing`.

### `handoff`

18. Gate the planner, generator, and evaluator artifacts at each seam before route exit.
   - Planner handoff must remain structurally usable for execution.
   - Generator handoff must expose resolvable deliverable and evidence refs.
   - Evaluator handoff must be structurally complete and route-usable.
   - If any gate fails, set `state: artifact_gate_failed`, report the blocker, and stop.
19. Fill `latest_deliverable_ref` and `latest_evidence_ref` when explicit, and write `checkpoint_artifact` with the current recovery entry point before leaving a successful handoff seam.

### `teardown`

20. Select the canonical route using `skills/pge-execute/contracts/routing-contract.md`.
21. Persist the final verdict, final route, and route reason into `runtime_state`.
22. If the canonical route is `continue`, `retry`, or `return_to_planner`, write `checkpoint_artifact` with `recovery_entry_point: resume_from_route_decision`, set `state: unsupported_route`, report the unsupported-route stop, and stop without redispatch.
23. If the canonical route is `converged`, write `summary_artifact` with run id, artifact refs, final verdict, final route, and one short round summary.
24. Report the run result with `run_id`, verdict, route, and artifact paths.

## Artifact-chain gates

Before final route exit:
- planner artifact must be structurally usable for execution
- generator artifact must name resolvable deliverable and evidence
- evaluator artifact must be structurally complete and route-usable
- the step must leave an append-only route record via `checkpoint_artifact` or final `runtime_state` + `summary_artifact`

If any gate fails, stop with `artifact_gate_failed` instead of inventing a route.

## Route and stop behavior

Canonical route vocabulary:
- `continue`
- `retry`
- `return_to_planner`
- `converged`

Current-stage execution support:
- `converged` is supported
- `continue`, `retry`, and `return_to_planner` are not automatically redispatched in the current stage

When an unsupported canonical route is selected, `main` must:
1. preserve the canonical route in runtime state
2. set `state: unsupported_route`
3. write the checkpoint before stopping
4. report that the route is valid vocabulary but unsupported for automatic execution in the current stage
5. stop without silently redispatching Planner / Generator / Evaluator

## Recovery expectations

Recovery is checkpoint-driven, not transcript-driven.

Required checkpoint fields and entry points remain aligned with:
- `skills/pge-execute/contracts/runtime-state-contract.md`
- `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md`

Current-stage recovery entry points:
- `resume_generation`
- `resume_evaluation`
- `resume_from_route_decision`

## Guardrails

- Keep the run bounded to one round.
- Keep file-based handoff as the execution backbone.
- Stop and report malformed or missing artifacts instead of repairing by guesswork.
- Do not broaden scope beyond the accepted upstream plan.
- Do not model `main` as a fourth agent in any skill or doc surface.
