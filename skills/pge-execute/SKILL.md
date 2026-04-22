---
name: pge-execute
description: Use this skill when bounded repo-internal work needs one explicit Planner → Generator → Evaluator execution round with clear acceptance gates.
version: 0.1.1
argument-hint: "<upstream-plan | path | test>"
allowed-tools:
  - Agent
  - Read
  - Write
  - Bash
  - Glob
  - Grep
---

<objective>
Run one real PGE orchestration round by dispatching the installed `pge-planner`, `pge-generator`, and `pge-evaluator` agents. The main session owns orchestration only: runtime state, artifact persistence, preflight, and routing. The main session must not do planner, generator, or evaluator role work itself.
</objective>

<scope>
- Single repo-internal round only.
- No external tasks.
- No multi-round support.
- No heavy teams.
- Use the installed runtime-facing agent names exactly: `pge-planner`, `pge-generator`, `pge-evaluator`.
- Runtime state must be isolated per run and keyed by `run_id`.
</scope>

<argument_handling>
Use the final `ARGUMENTS:` block attached to this skill invocation.

Accepted forms:
1. `test`
2. a readable file path containing an upstream plan
3. inline upstream plan text that already includes the required entry fields

If the argument is `test`, use this fixed upstream plan exactly:

```yaml
goal: Create `.pge-artifacts/pge-smoke.txt` containing exactly `pge smoke`
boundary: Only create `.pge-artifacts/pge-smoke.txt`
deliverable: `.pge-artifacts/pge-smoke.txt` with exact content `pge smoke`
verification_path: Verify the file exists and its full contents equal `pge smoke`
run_stop_condition: single_round
```

If the input is not `test` and does not provide a concrete goal, boundary, deliverable, verification path, and explicit `run_stop_condition`, stop and ask for an execute-first upstream plan instead of guessing.
</argument_handling>

<runtime_files>
Use the current working directory as `repo_root`.

Create and use:
- `artifact_dir = {repo_root}/.pge-artifacts`
- `run_id = run-<unix-timestamp-ms>`
- `round_id = round-1`
- `planner_artifact = {artifact_dir}/{run_id}-planner-output.md`
- `generator_artifact = {artifact_dir}/{run_id}-generator-output.md`
- `evaluator_artifact = {artifact_dir}/{run_id}-evaluator-verdict.md`
- `summary_artifact = {artifact_dir}/{run_id}-round-summary.md`
- `runtime_state = {artifact_dir}/{run_id}-runtime-state.json`
</runtime_files>

<process>
Execute the following steps in order.

1. Resolve the effective upstream plan from the argument-handling rules.
2. Create `artifact_dir` if needed.
3. Initialize `runtime_state` using the fields from `contracts/runtime-state-contract.md` with:
   - `run_id`
   - `round_id: round-1`
   - `state: intake_pending`
   - `upstream_plan_ref`
   - `active_slice_ref: ""`
   - `active_round_contract_ref: ""`
   - `latest_preflight_result: ""`
   - `run_stop_condition`
   - `latest_deliverable_ref: ""`
   - `latest_evidence_ref: ""`
   - `latest_evaluation_verdict: ""`
   - `latest_route: ""`
   - `unverified_areas: []`
   - `accepted_deviations: []`
   - `route_reason: ""`
   - `convergence_reason: ""`
4. Validate the effective upstream plan against `contracts/entry-contract.md`.
   - If entry fails, update `runtime_state` to `failed_upstream`, tell the user exactly which required entry fields are missing, and stop.
5. Update `runtime_state` to `planning_round`.
6. Dispatch the installed `pge-planner` agent with the Agent tool.
   - Give it the effective upstream plan.
   - Give it a short runtime-state summary.
   - Tell it to return only a markdown artifact with these exact top-level sections:
     - `## goal`
     - `## in_scope`
     - `## out_of_scope`
     - `## actual_deliverable`
     - `## acceptance_criteria`
     - `## verification_path`
     - `## stop_condition`
     - `## required_evidence`
     - `## handoff_seam`
     - `## open_questions`
     - `## planner_note`
     - `## planner_escalation`
7. Write the returned planner artifact verbatim to `planner_artifact`.
8. Preflight the planner artifact.
   - It must exist.
   - It must contain all required round-contract fields from `contracts/round-contract.md`.
   - If preflight fails, update `runtime_state` to `preflight_failed`, report the missing fields, and stop.
   - If preflight passes, update `latest_preflight_result` to `pass` and update `runtime_state` to `ready_to_generate`.
9. Dispatch the installed `pge-generator` agent with the Agent tool in `acceptEdits` mode.
   - Use `mode: acceptEdits` so the installed generator can perform the bounded repo write it owns in this phase.
   - Give it the full planner artifact content.
   - Give it only the minimum repo context directly relevant to the declared deliverable and verification path.
   - Tell it to return only a markdown artifact with these exact top-level sections:
     - `## current_task`
     - `## boundary`
     - `## actual_deliverable`
     - `## deliverable_path`
     - `## changed_files`
     - `## local_verification`
     - `## evidence`
     - `## known_limits`
     - `## non_done_items`
     - `## deviations_from_spec`
     - `## handoff_status`
10. Write the returned generator artifact verbatim to `generator_artifact`.
11. Update `runtime_state` to `awaiting_evaluation` and fill `latest_deliverable_ref` plus `latest_evidence_ref` when those values are explicit in the generator artifact.
   - `latest_evidence_ref` should point to the generator evidence bundle inside `generator_artifact`; prefer a fragment reference into that artifact rather than inventing a separate evidence file.
12. Dispatch the installed `pge-evaluator` agent with the Agent tool.
   - Evaluate only against evidence that exists by evaluation time.
   - Do not require `summary_artifact` for PASS, because `summary_artifact` is written only after routing to `converged`.
   - Give it the full planner artifact content.
   - Give it the full generator artifact content.
   - Give it a short current runtime-state summary.
   - Tell it to return only a markdown artifact with these exact top-level sections:
     - `## verdict`
     - `## evidence`
     - `## violated_invariants_or_risks`
     - `## required_fixes`
     - `## next_route`
13. Write the returned evaluator artifact verbatim to `evaluator_artifact`.
14. Route using `contracts/routing-contract.md`.
   - `PASS` + `single_round` => `converged`
   - `PASS` + non-`single_round` => `continue`
   - `RETRY` => `retry`
   - `BLOCK` => `retry` unless the verdict shows the current contract is no longer the right repair frame, then `return_to_planner`
   - `ESCALATE` => `return_to_planner`
15. Update `runtime_state` with the final verdict, final route, and route reason.
16. If routed to `converged`, write `summary_artifact` containing:
   - `summary_artifact` is a post-route artifact. It is not part of the pre-PASS evaluator evidence set.
   - `run_id`
   - `planner_artifact`
   - `generator_artifact`
   - `evaluator_artifact`
   - `final_verdict`
   - `final_route`
   - one short round summary
17. Report the run result to the user by naming the `run_id`, verdict, route, and artifact paths.
</process>

<constraints>
- Main must orchestrate and persist artifacts, but must not invent Planner, Generator, or Evaluator content.
- Use the installed agents directly through the Agent tool. Do not read `agents/*.md` and simulate them.
- Keep the run bounded to one round.
- Do not broaden scope beyond the accepted upstream plan.
- If a required artifact or tool result is missing or malformed, stop and report the blocker instead of repairing it by guesswork.
- Do not write repo-global runtime state for this flow; each run must persist its own runtime state file under `.pge-artifacts/` keyed by `run_id`.
- Planner and Evaluator are read-only agents in this repo. Persist their returned markdown artifacts from the main session.
</constraints>
