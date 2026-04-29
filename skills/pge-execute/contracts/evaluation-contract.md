# Evaluation Contract

## evaluator role

Evaluator exists to close the loop, not to write an audit essay.

Evaluator owns only three responsibilities:
- independent acceptance
- routing judgment
- execution cost gate / mode judgment during preflight

Evaluator does not own:
- replanning the task
- repairing the implementation
- defaulting to heavyweight score matrices or long audit prose

## evaluator checks

Evaluator checks:
- contract compliance
- evidence sufficiency and independence
- material deviation from the current round contract
- whether the observed result can still be resolved locally within the current round

Start from the real deliverable, not from Generator narrative and not from artifact existence alone.

## mode-aware evaluation surface

### `FAST_PATH`

Use the lightest honest evaluation surface:
- independent deliverable read
- deterministic or exact-match verification result
- scope sanity check
- verdict and route

Do not require:
- weighted score
- large scorecard
- blocking-flag matrix
- confidence matrix

### `LITE_PGE`

Use compact scoring only:
- correctness
- contract_compliance
- evidence_sufficiency

Keep the rationale short and avoid full-scorecard overhead.

### `FULL_PGE`

Use compact core scoring, not audit-grade scoring:
- deliverable_alignment
- evidence_sufficiency
- contract_compliance

Supporting concerns such as scope drift, weak verification, or incompleteness belong in risks/fixes, not in large default matrices.

### `LONG_RUNNING_PGE`

Keep the verdict routeable and concise.
Do not invent a separate audit language just because the task is longer-running.

## compact scoring rules

Scoring is optional for `FAST_PATH`.
Scoring is compact and expected for `LITE_PGE` and `FULL_PGE`.

Use a 1-5 scale only:

| Score | Meaning |
|-------|---------|
| 1 | missing or clearly unacceptable |
| 2 | present but still below acceptance |
| 3 | minimum acceptable |
| 4 | solid and independently supported |
| 5 | clearly above contract minimum |

PASS requires every reported core dimension to be `>= 3`.
No weighted total is used.

### `LITE_PGE` dimensions

| Dimension | Meaning |
|-----------|---------|
| `correctness` | the delivered result does the required job |
| `contract_compliance` | the current contract and boundaries were respected |
| `evidence_sufficiency` | evidence is concrete and independently checkable |

### `FULL_PGE` dimensions

| Dimension | Meaning |
|-----------|---------|
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

Evaluator must perform at least one independent verification step appropriate to the mode.

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

All modes must produce these sections:

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

For `LITE_PGE` and `FULL_PGE`, add:

```markdown
## compact_scores
- correctness|deliverable_alignment: <1-5>
- contract_compliance: <1-5>
- evidence_sufficiency: <1-5>
```

## preflight note

During preflight, Evaluator uses the same philosophy:
- message-first negotiation
- compact, routeable judgment
- no default heavyweight audit output

Structured preflight repair fields belong to the preflight lane and can be expanded in Phase 3 without changing the final-evaluation philosophy defined here.
