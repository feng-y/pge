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