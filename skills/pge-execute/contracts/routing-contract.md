# Routing Contract

## main reads
Main routes based on:
- planner output
- generator output
- evaluator verdict
- current run facts from validated artifacts and runtime events
- Planner `stop_condition`

## routing semantics
- `continue`: current round is complete, accepted, and Planner `stop_condition` is not yet satisfied
- `retry`: the current round should run again without reopening upstream planning
- `return_to_planner`: the round contract is too ambiguous, too large, conflicting, or needs repair before execution can continue
- `converged`: the accepted round satisfies Planner `stop_condition`

## default verdict-to-route mapping
- `PASS` routes to `continue` when the accepted round does not satisfy Planner `stop_condition`
- `PASS` routes to `converged` when the accepted round satisfies Planner `stop_condition`
- `RETRY` routes to `retry`
- `BLOCK` routes to `retry` by default when the current round remains the correct repair frame
- `BLOCK` routes to `return_to_planner` when the missing or violated condition shows the current round is no longer the correct repair frame
- `ESCALATE` routes to `return_to_planner` by default

## continue vs converged decision rule
Router decides `continue` vs `converged` by checking Planner `stop_condition` against the accepted deliverable and evaluator verdict:
- if `stop_condition` is `single_round` and current round passed, route to `converged`
- if `stop_condition` is `slice_complete` and current slice is finished, route to `converged`
- if `stop_condition` is `goal_satisfied` and the stated goal is met, route to `converged`
- if `stop_condition` is `deliverable_count:N` and N deliverables are complete, route to `converged`
- otherwise route to `continue`

This removes ad-hoc interpretation from the routing decision.

## current-stage route effect
- `converged` is the only successful terminal route in the current executable lane
- `retry` is a supported bounded repair loop only when the current contract remains fair, the required fixes are local to Generator, max generator attempts have not been exhausted, and no repair checkpoint decision has stopped the loop
- `continue` and `return_to_planner` are canonical route tokens, but the current lane must stop cleanly without redispatch
- when an unsupported non-terminal route appears, `main` records the canonical route, classifies the blocker/friction, reports `unsupported_route`, and tears down the team
- max generator attempts per round: 10 total attempts, including the initial generation
- repeated same failure threshold: same `failure_signature` on 3 consecutive evaluations requires a saved repair snapshot and explicit main decision before continuing

## teardown rule for the current executable lane
Routing ends in teardown for the current stage:
- `converged` tears down the bounded run through route/progress logging and optional summary output
- `retry` tears down only after the bounded Generator repair loop reaches PASS, a non-retryable route, max attempts exhausted, or main decides to stop at a repair checkpoint
- `continue` and `return_to_planner` tear down the bounded run through route/progress logging, `unsupported_route`, and explicit stop

This keeps teardown explicit without implying that open-ended redispatch is implemented.

## mapping rule
- Main must not invent a route that contradicts the current evaluator verdict and validated current-run facts
- if Main cannot explain the selected route from verdict plus validated current-run facts, routing is invalid and must stop for repair
- if Main selects `retry` in the current stage, it must either continue the supported bounded Generator repair loop or record why the repair preconditions were not met
- if Main selects `continue` or `return_to_planner` in the current stage, it must preserve that canonical route in progress/summary output, report `unsupported_route`, and stop without redispatch
