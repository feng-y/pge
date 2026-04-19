# Routing Contract

## main reads
Main routes based on:
- planner output
- generator output
- evaluator verdict
- current round state

## routing semantics
- `continue`: current round is complete and the next bounded round may start
- `retry`: the current round should run again without reopening upstream planning
- `return_to_planner`: the round contract is too ambiguous, too large, conflicting, or needs repair before execution can continue
- `converged`: the accepted work satisfies the intended stopping point for this PGE run

## default verdict-to-route mapping
- `PASS` routes to `continue` when the accepted round leaves more bounded work under the same run
- `PASS` routes to `converged` when the accepted round reaches the intended stopping point
- `RETRY` routes to `retry`
- `BLOCK` routes to `retry` by default when the current round remains the correct repair frame
- `BLOCK` routes to `return_to_planner` when the missing or violated condition shows the current round is no longer the correct repair frame
- `ESCALATE` routes to `return_to_planner` by default

## default route-to-state effect
- `continue` normally advances from `routing` to `planning_round` for the next bounded round under the same run
- `retry` normally advances from `routing` to `generating` for the same bounded round
- `return_to_planner` normally advances from `routing` to `planning_round`
- `converged` advances from `routing` to `converged`

## mapping rule
- Main must not invent a route that contradicts the current evaluator verdict and runtime state
- if Main cannot explain the selected route from verdict plus current state, routing is invalid and must stop for repair