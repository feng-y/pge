# Evaluation Contract

## evaluator checks
Evaluator checks:
- contract compliance
- evidence sufficiency
- material deviation from the current round contract
- whether the observed result can still be resolved locally within the current round

## minimum verdict types
- `PASS`
- `RETRY`
- `BLOCK`
- `ESCALATE`

## verdict meanings

### `PASS`
Meaning:
- the deliverable satisfies the current round contract
- the evidence is sufficient for acceptance
- no unresolved deviation remains that would change routing

Triggered when:
- contract compliance is satisfied
- evidence is sufficient
- any deviation is either absent or already accepted within this round

Local or escalated:
- local to the current round

Typical routing effect:
- `continue` or `converged`

### `RETRY`
Meaning:
- the round direction is still valid
- the current result is not yet acceptable
- the issue can still be repaired locally without changing the round contract

Triggered when:
- the artifact is incomplete, weak, or under-verified
- evidence is insufficient but can still be gathered within the same round
- execution quality is recoverable without reopening planning

Local or escalated:
- local to the current round

Typical routing effect:
- `retry`

### `BLOCK`
Meaning:
- acceptance cannot be granted because a required condition is missing or violated
- the current result is not acceptable in its present form

Triggered when:
- required contract elements are missing
- required artifact conditions are missing
- required evidence is missing
- a hard contract violation is present

Local or escalated:
- may still be local if the missing condition can be repaired within the same round
- does not by itself imply planning repair

Typical routing effect:
- usually `retry`
- may escalate later if repeated blocking reveals a planning problem

### `ESCALATE`
Meaning:
- the acceptance problem is not just a weak result inside the current round
- the issue is really about contract mismatch, slice mismatch, route mismatch, or deviation governance

Triggered when:
- the current round contract is no longer the right acceptance frame
- the implementation semantics and contract semantics diverge materially
- the result cannot be judged fairly without replanning or explicit route repair
- the problem is not solvable by simply regenerating the same round output

Local or escalated:
- not local to the current round
- requires routing escalation

Typical routing effect:
- usually `return_to_planner`
- only routes elsewhere if the router has a stronger explicit reason to do so

## verdict rules
- `PASS` means the current round may be accepted
- `RETRY` means the round stays open and should be rerun locally
- `BLOCK` means acceptance is denied because a required condition is missing or violated
- `ESCALATE` means the problem is not a simple local failure of the current round

## verdict selection rule
Choose the narrowest verdict that explains the failure correctly.

- use `RETRY` when the current round remains valid and local repair is enough
- use `BLOCK` when a required condition is missing or violated, but the current round still remains the right repair frame
- use `ESCALATE` when the current round is no longer the right repair frame

## why `ESCALATE` is not the same as `BLOCK`
- `BLOCK` says the current output is not acceptable yet
- `ESCALATE` says the current round is no longer the right place to resolve the issue

A blocked result may still be repairable by retrying the same round.
An escalated result usually means retry would only repeat the same mismatch.

## why `ESCALATE` usually routes to `return_to_planner`
Because escalation usually means:
- the bounded slice is wrong
- the contract is wrong
- the acceptance frame is wrong
- or the route cannot be justified from the current round alone

In those cases, simple retry increases churn but does not reduce ambiguity.
The default repair path is therefore `return_to_planner`, unless the router has a stronger explicit reason.
