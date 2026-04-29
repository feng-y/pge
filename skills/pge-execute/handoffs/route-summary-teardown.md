# Route, Summary, Teardown

## Route

Read the evaluator artifact.

If:

- verdict = `PASS`
- next_route = `converged`

then:

- set `state = "converged"`
- set `verdict = "PASS"`
- set `route = "converged"`
- set `error_or_blocker = null`

Otherwise:

- set `state = "unsupported_route"` when next_route is `continue`, `retry`, or `return_to_planner`
- set `state = "stopped"` only when no canonical next_route can be read
- set `verdict` and `route` from evaluator verdict and next_route when present
- set `error_or_blocker` to evaluator `required_fixes` or `violated_invariants_or_risks`
- do not redispatch automatically in this version

Write state after route selection. Update progress only when progress is enabled for the current mode.

## Summary

Only write `summary_artifact` when the chosen mode requires it.

When written, include:

- run_id
- task input summary
- team name
- planner/preflight/generator/evaluator called flags
- verdict
- route
- artifact paths
- progress path when `progress_artifact` exists
- for `test`, smoke result and exact smoke file path
- blocker if any

Update progress after writing summary only when progress is enabled.

## Teardown

After route selection, perform teardown. Do not make summary a prerequisite for teardown in lighter modes.

```python
SendMessage(to="planner", message={"type": "shutdown_request"})
SendMessage(to="generator", message={"type": "shutdown_request"})
SendMessage(to="evaluator", message={"type": "shutdown_request"})
TeamDelete()
```

If teardown fails after route selection and artifacts are already written:

- keep the execution result
- mention teardown failure in final text
- do not rewrite PASS to failure solely because shutdown was noisy
- do not leave the run stuck in `evaluating` solely because shutdown is slow

Update progress after the teardown attempt only when progress is enabled.
