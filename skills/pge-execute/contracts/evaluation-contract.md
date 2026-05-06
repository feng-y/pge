# Evaluation Contract

## evaluator role

Evaluator exists to close the loop, not to write an audit essay.

Evaluator owns only three responsibilities:
- independent acceptance
- routing judgment
- independent verification depth judgment for the current task

Evaluator does not own:
- replanning the task
- repairing the implementation
- selecting execution mode or adding a preflight gate
- defaulting to heavyweight score matrices or long audit prose

## evaluator checks

Evaluator checks:
- contract compliance
- evidence sufficiency and independence
- material deviation from the current round contract
- whether the observed result can still be resolved locally within the current round

Start from the real deliverable, not from Generator narrative and not from artifact existence alone.

## current-stage evaluation surface

All current executable runs use the same `planner -> generator -> evaluator` skeleton.
Task size changes audit depth, not the required verdict section shape.

Use the lightest honest evaluation surface that can independently judge the current task:
- read the actual deliverable
- verify content against the Planner contract
- check evidence sufficiency and independence
- record `verification_helper_decision` in `## independent_verification`
- issue a verdict and route

For deterministic tasks, exact-match or deterministic verification can be the primary evidence.
For larger normal tasks, add compact scoring only when it materially clarifies the verdict.

Do not require by default:
- weighted score
- large scorecard
- blocking-flag matrix
- confidence matrix
- separate preflight or mode-decision output

## compact scoring rules

Scoring is optional in the current executable lane.
Use compact scores only when they materially improve verdict clarity for a non-trivial normal task.

Use a 1-5 scale only:

| Score | Meaning |
|-------|---------|
| 1 | missing or clearly unacceptable |
| 2 | present but still below acceptance |
| 3 | minimum acceptable |
| 4 | solid and independently supported |
| 5 | clearly above contract minimum |

When compact scores are used, PASS requires every reported core dimension to be `>= 3`.
No weighted total is used.

Supported dimensions:

| Dimension | Meaning |
|-----------|---------|
| `correctness` | the delivered result does the required job |
| `deliverable_alignment` | the actual deliverable matches the contract-approved deliverable |
| `contract_compliance` | acceptance criteria and constraints are satisfied |
| `evidence_sufficiency` | evidence is concrete, independent, and adequate |

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

Typical routing effect:
- `continue`
- `converged`

### `RETRY`

Meaning:
- the round direction is still valid
- the current result is not yet acceptable
- the issue can still be repaired locally without changing the round contract

Typical routing effect:
- `retry`

### `BLOCK`

Meaning:
- acceptance cannot be granted because a required condition is missing or violated
- the current result is not acceptable in its present form

Typical routing effect:
- usually `retry`
- sometimes `return_to_planner` if the missing basis shows the round contract is no longer workable

### `ESCALATE`

Meaning:
- the problem is not just a weak local result
- the current contract is no longer a fair or coherent frame for evaluation

Typical routing effect:
- usually `return_to_planner`

## verdict selection rule

Choose the narrowest verdict that explains the failure correctly.

- use `RETRY` when the round remains valid and local repair is enough
- use `BLOCK` when a required basis for acceptance is missing or violated
- use `ESCALATE` when the current round is no longer the right repair frame

## independent evidence rules

Do not accept as sufficient evidence:
- Generator self-assessment alone
- vague claims such as "looks good" or "should work"
- artifact existence without checking the delivered content
- local verification summary without at least one independently checkable basis

Each material acceptance criterion should have at least one concrete evidence basis of one of these kinds:
- tool output
- file content
- diff evidence
- test result

## independent verification requirements

Evaluator must perform at least one independent verification step appropriate to the current task.

Minimum expectations:
1. read the real deliverable
2. confirm the content is substantive, not placeholder-only
3. confirm at least one acceptance claim with independent evidence

For deterministic tasks, the deterministic check may be the primary evidence basis, but Evaluator must still read the deliverable when one exists.

## anti-slop rules

The following patterns are disallowed because they create false convergence:

| Rule | Trigger | Effect |
|------|---------|--------|
| `praise_without_substance` | verdict language is positive but evidence has no concrete content, tool output, or deliverable excerpt | verdict cannot be `PASS` |
| `existence_as_quality` | evidence only proves files or sections exist, not that the deliverable satisfies the contract | verdict cannot be `PASS` |
| `self_report_as_primary_evidence` | Generator self-report is treated as the main basis for acceptance | verdict cannot be `PASS` |
| `issue_minimization` | material risk or unmet criterion is described, but verdict still claims `PASS` without direct rebuttal evidence | verdict must downgrade to `RETRY`, `BLOCK`, or `ESCALATE` |

## compact verdict bundle

All current executable runs must produce these sections:

```markdown
## verdict
PASS | RETRY | BLOCK | ESCALATE

## evidence
[concise concrete evidence]

## violated_invariants_or_risks
[only real risks or failures]

## required_fixes
[observable missing behavior or missing evidence]

## next_route
continue | converged | retry | return_to_planner

## route_reason
[short routing rationale]

## independent_verification
[what Evaluator checked independently]
```

For non-trivial normal tasks, optionally add:

```markdown
## compact_scores
- correctness|deliverable_alignment: <1-5>
- contract_compliance: <1-5>
- evidence_sufficiency: <1-5>
```
