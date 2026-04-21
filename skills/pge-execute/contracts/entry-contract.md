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

## examples

### Accepted upstream input

```yaml
goal: Add validation helper to contracts/round-contract.md
boundary: Only modify contracts/round-contract.md
deliverable: Updated contracts/round-contract.md with validation section
verification_path: Check file contains new validation section with 3+ checks
run_stop_condition: single_round
```

This is accepted because:
- Goal is concrete and executable
- Boundary is clear (one file)
- Deliverable is named
- Verification path is specific
- Stop condition is explicit

### Rejected upstream input

```yaml
goal: Improve the contract system
boundary: Whatever makes sense
deliverable: Better contracts
verification_path: Check if it's better
run_stop_condition: when done
```

This is rejected because:
- Goal is too vague ("improve" is clarify-first)
- Boundary is ambiguous ("whatever makes sense")
- Deliverable is not concrete ("better contracts")
- Verification path is subjective ("if it's better")
- Stop condition is not explicit ("when done")