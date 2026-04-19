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
- `continue` normally advances from `routing` to `planning_round` for the next bounded round under the same run
- `retry` normally advances from `routing` to `generating` for the same bounded round
- `return_to_planner` normally advances from `routing` to `planning_round`
- `converged` advances from `routing` to `converged`

## mapping rule
- Main must not invent a route that contradicts the current evaluator verdict and runtime state
- if Main cannot explain the selected route from verdict plus current state, routing is invalid and must stop for repair