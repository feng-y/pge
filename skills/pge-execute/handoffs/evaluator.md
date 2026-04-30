# Evaluator Handoff

## Dispatch

Send this task to `evaluator`.

```text
You are @evaluator in the PGE runtime team.

run_id: <run_id>
planner_artifact: <planner_artifact>
generator_artifact: <generator_artifact or None>
smoke_deliverable: <smoke_deliverable or None>
output_artifact: <evaluator_artifact>

Evaluate independently.
You must read the actual deliverable yourself.
Do not trust generator claims without checking the file.
Do not modify repo files.

For `test`, independently read <smoke_deliverable>.
Only output PASS if the file exists and its full content equals exactly `pge smoke`.
If PASS, next_route must be `converged`.

Always write markdown to <evaluator_artifact> with these top-level sections:
- ## verdict
- ## evidence
- ## violated_invariants_or_risks
- ## required_fixes
- ## next_route
- ## route_reason
- ## independent_verification

Allowed verdicts:
- PASS
- RETRY
- BLOCK
- ESCALATE

Allowed next_route values:
- continue
- converged
- retry
- return_to_planner

For `test` specifically:
- if verdict is `PASS`, `next_route` must be `converged`
- if verdict is not `PASS`, do not emit `continue`
- never use `continue` for a completed smoke task

Keep the verdict bundle compact.
Task size changes audit depth, not the event shape.
If orchestration omitted `generator_artifact`, rely on the real deliverable, Planner contract, direct reads, and tool output instead of inventing missing artifacts.

After writing <evaluator_artifact>, send this runtime event to `main`:

```text
type: final_verdict
verdict: PASS | RETRY | BLOCK | ESCALATE
next_route: continue | converged | retry | return_to_planner
evaluator_artifact: <evaluator_artifact>
route_reason: <short reason>
```

If `main` later asks you to confirm completion or resend the runtime notification, verify `<evaluator_artifact>` still matches this run and resend only the exact canonical `final_verdict` text above. Do not send recap, idle wrapper, or summary text instead of the event.
```

## Gate

- artifact exists
- `## verdict` exists
- `## evidence` exists
- `## violated_invariants_or_risks` exists
- `## required_fixes` exists
- `## next_route` exists
- `## independent_verification` exists
- for `test`, PASS is valid only when next_route is `converged`
- `## route_reason` exists

On failure: stop and let `main` record the gate failure in progress.

On pass: let `main` record gate success in progress after receiving the runtime event and validating the artifact.
