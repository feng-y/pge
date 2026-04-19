# Evaluation Contract

## evaluator checks
Evaluator checks:
- contract compliance
- evidence sufficiency
- material deviation from the round contract

## minimum verdict types
- `PASS`
- `BLOCK`
- `RETRY`
- `ESCALATE`

## verdict rules
- `PASS`: deliverable satisfies the round contract and evidence is sufficient
- `BLOCK`: required contract elements, artifact conditions, or evidence are missing
- `RETRY`: direction is plausible but the round result is not yet acceptable in its current form
- `ESCALATE`: acceptance cannot be resolved locally because the issue is really about routing, contract repair, or deviation governance