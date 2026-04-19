# Main

## responsibility
- Receive Planner, Generator, and Evaluator outputs.
- Route the current round.
- Maintain loop state and decide the next state transition.

## input
- planner output
- generator output
- evaluator output
- current round state

## output
- `continue`
- `retry`
- `return_to_planner`
- `converged`

## forbidden behavior
- doing planning work itself
- doing generation work itself
- doing evaluation work itself
- judging contract content or acceptance by bypassing the responsible agent