# Entry Contract

## accepted upstream input
An upstream plan may enter PGE only if the accepted run input provides:
- a concrete execution goal
- a boundary that can be preserved in execution
- a named deliverable or a clear deliverable target
- a verification path that can ground acceptance
- an explicit `run_stop_condition`

## reject conditions
Reject entry when the upstream plan is:
- clarify-first instead of execute-first
- missing a concrete goal
- missing execution boundary
- missing deliverable shape
- missing any plausible verification path
- missing an explicit `run_stop_condition`
- so ambiguous that Planner cannot freeze one bounded current round contract