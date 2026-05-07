# Route, Summary, Teardown

## Route

Read the evaluator artifact.

Route/status mapping in the current executable lane:
- `status = SUCCESS` is valid only when `verdict = PASS` and `route = converged`
- any other route must not be reported as `SUCCESS`
- for `test`, `PASS + continue` is invalid and must be treated as a blocker or contract failure, not a successful closeout
- route selection happens after the supported bounded `generator <-> evaluator` repair loop has either converged, hit a non-retryable route, exhausted its attempt budget, or stopped at a repair checkpoint
- do not convert `retry` to `unsupported_route`; preserve `retry` when the bounded repair loop stops without convergence

If:

- verdict = `PASS`
- next_route = `converged`

then:
- record `verdict = "PASS"`
- record `route = "converged"`

Otherwise:

- record `route = "retry"` when next_route is `retry` and the bounded repair loop has stopped because max attempts were exhausted, a same-failure checkpoint stopped, or `main` chose to stop
- record `route = "unsupported_route"` when next_route is `continue` or `return_to_planner`
- record `route = "blocked"` only when no canonical next_route can be read
- record `verdict` and `route` from evaluator verdict and next_route when present
- record the blocker from evaluator `required_fixes` or `violated_invariants_or_risks`
- do not redispatch from the route/teardown phase; supported `retry` redispatch belongs to the Evaluator phase loop before final route selection

Append a best-effort progress log entry after route selection.
Use the canonical progress fields:
- `ts`
- `run_id`
- `actor = "main"`
- `phase = "route"`
- `event`
- `status`
- `artifact`
- `detail`
- `blocker`
- optional: `latency_ms`, `bytes`, `command`

Emit this runtime event after route selection:

```text
type: route_selected
verdict: <verdict>
route: <route>
reason: <short reason>
```

## Summary

Only write `summary_artifact` when the run actually needs a human-readable closeout.

When written, include:

- run_id
- task input summary
- team name
- verdict
- route
- artifact paths
- progress log path when `progress_artifact` exists
- for `test`, smoke result and exact smoke file path
- blocker if any

Append a best-effort progress log entry after writing summary.

## Teardown

After route selection, perform teardown. Do not make summary a prerequisite for teardown.

```python
SendMessage(to="planner", message="type: shutdown_request")
SendMessage(to="generator", message="type: shutdown_request")
SendMessage(to="evaluator", message="type: shutdown_request")
Wait boundedly for shutdown_response messages to team-lead from planner, generator, and evaluator
TeamDelete()
```

Each teammate must answer shutdown with `SendMessage(to="team-lead", message="<plain-string shutdown_response>")`.
Do not synthesize shutdown responses from `main`; only teammates send their own `shutdown_response`.
Do not call `TeamDelete` until the bounded shutdown_response wait has completed.
Missing shutdown_response messages after the bounded wait are teardown friction, not a reason to rewrite the already selected route.
`TeamDelete` must be called with no parameters.
Do not attach logging commands, descriptions, or any extra fields to `TeamDelete`.
If you need to log route/teardown, do that through the progress log separately before or after the call.

If teardown fails after route selection and artifacts are already written:

- keep the execution result
- mention teardown failure in final text
- do not rewrite PASS to failure solely because shutdown was noisy
- do not leave the run stuck in `evaluating` solely because shutdown is slow

Append a best-effort progress log entry after the teardown attempt.
Use `actor = "main"` and `phase = "teardown"` for teardown log lines.

Final text artifact paths must be copied from the manifest/progress values as complete absolute paths.
Do not stream partial path fragments, concatenate adjacent list items, or include paths that fail a basic existence/readability check unless they are explicitly marked missing.
