# Routing Contract

## main reads
Main routes based on:
- planner output
- generator output
- evaluator verdict
- current round state
- run_stop_condition

## routing semantics
- `continue`: current round is complete, accepted, and `run_stop_condition` is not yet satisfied
- `retry`: the current round should run again without reopening upstream planning
- `return_to_planner`: the round contract is too ambiguous, too large, conflicting, or needs repair before execution can continue
- `converged`: the accepted round satisfies `run_stop_condition`

## default verdict-to-route mapping
- `PASS` routes to `continue` when the accepted round does not satisfy `run_stop_condition`
- `PASS` routes to `converged` when the accepted round satisfies `run_stop_condition`
- `RETRY` routes to `retry`
- `BLOCK` routes to `retry` by default when the current round remains the correct repair frame
- `BLOCK` routes to `return_to_planner` when the missing or violated condition shows the current round is no longer the correct repair frame
- `ESCALATE` routes to `return_to_planner` by default

## continue vs converged decision rule
Router decides `continue` vs `converged` by checking `run_stop_condition` against current round state:
- if `run_stop_condition` is `single_round` and current round passed, route to `converged`
- if `run_stop_condition` is `slice_complete` and current slice is finished, route to `converged`
- if `run_stop_condition` is `goal_satisfied` and the stated goal is met, route to `converged`
- if `run_stop_condition` is `deliverable_count:N` and N deliverables are complete, route to `converged`
- otherwise route to `continue`

This removes ad-hoc interpretation from the routing decision.

## default route-to-state effect
- `continue` canonically points toward the next bounded round under the same run, but in the current stage it must stop at `unsupported_route` unless that loop is truly implemented
- `retry` canonically points toward rerunning the same bounded round, but in the current stage it must stop at `unsupported_route` unless that loop is truly implemented
- `return_to_planner` canonically points toward planning repair, but in the current stage it must stop at `unsupported_route` unless that loop is truly implemented
- `converged` advances from `routing` to `converged`

## mapping rule
- Main must not invent a route that contradicts the current evaluator verdict and runtime state
- if Main cannot explain the selected route from verdict plus current state, routing is invalid and must stop for repair
- if Main selects `continue`, `retry`, or `return_to_planner` in the current stage, it must preserve that canonical route in runtime state, write a recovery checkpoint, transition to `unsupported_route`, and stop without redispatch