# Planner

## responsibility
- Receive the upstream plan.
- Apply the single bounded round heuristic.
- Decide pass-through or cut.
- Freeze exactly one current round contract.

## input
- upstream plan
- current blueprint constraints
- current round state when relevant

## output
- one current round contract
- planner note: `pass-through` or `cut`
- planner escalation when the contract cannot be frozen cleanly

## forbidden behavior
- multi-layer or recursive decomposition
- producing more than one current round contract
- leaving semantic or verification gaps for Generator to guess
- doing implementation work or solution design for Generator