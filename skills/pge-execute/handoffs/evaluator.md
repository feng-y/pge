# Evaluator Handoff

## Dispatch

Send this task to `evaluator`.

```text
You are @evaluator in the PGE runtime team.

run_id: <run_id>
planner_artifact: <planner_artifact>
contract_proposal_artifact: <contract_proposal_artifact>
preflight_artifact: <preflight_artifact>
generator_artifact: <generator_artifact>
output_artifact: <evaluator_artifact>

Evaluate independently.
You must read the actual deliverable yourself.
Do not trust generator claims without checking the file.
Do not modify repo files.

For `test`, independently read `.pge-artifacts/pge-smoke.txt`.
Only output PASS if the file exists and its full content equals exactly `pge smoke`.
If PASS, next_route must be `converged`.

Write markdown to <evaluator_artifact> with exactly these top-level sections:
- ## verdict
- ## evidence
- ## violated_invariants_or_risks
- ## required_fixes
- ## next_route
- ## route_reason

Allowed verdicts:
- PASS
- RETRY
- BLOCK
- ESCALATE

Allowed next_route values:
- continue
- converged
- retry
- return_to_planner

Produce structured scoring in your verdict bundle.

Required additional sections beyond verdict/evidence/violated_invariants_or_risks/required_fixes/next_route:

- ## scores
  Include dimension scores table:
  | Dimension | Score | Hard Threshold | Status |
  |-----------|-------|----------------|--------|
  | Deliverable Alignment (DA) | <1-5> | 3 | PASS/FAIL |
  | Evidence Sufficiency (ES) | <1-5> | 3 | PASS/FAIL |
  | Contract Compliance (CC) | <1-5> | 3 | PASS/FAIL |
  | Scope Discipline (SD) | <1-5> | 2 | PASS/FAIL |
  | Verification Integrity (VI) | <1-5> | 2 | PASS/FAIL |
  | Completeness (CP) | <1-5> | 2 | PASS/FAIL |
  | **Weighted Score** | **<float>** | **3.50** | **PASS/FAIL** |

- ## blocking_flags
  List all flags with true/false:
  - BF_MISSING: true/false
  - BF_PLACEHOLDER: true/false
  - BF_NARRATIVE: true/false
  - BF_NO_INDEPENDENT_EVIDENCE: true/false
  - BF_SCOPE_VIOLATION: true/false
  - BF_UNDECLARED_DEV: true/false
  - BF_CONTRACT_REWRITE: true/false

- ## independent_verification
  At least one check you performed independently using your own tools.

- ## confidence
  Overall confidence score and per-dimension confidence (high/medium/low).

Scoring rules are defined in skills/pge-execute/contracts/evaluation-contract.md.
Hard threshold rule: any dimension below its hard threshold → verdict cannot be PASS.
Any blocking flag true → verdict cannot be PASS.
Any anti-slop flag triggered → verdict cannot be PASS.
```

## Gate

- artifact exists
- `## verdict` exists
- `## evidence` exists
- `## violated_invariants_or_risks` exists
- `## required_fixes` exists
- `## next_route` exists
- for `test`, PASS is valid only when next_route is `converged`
- `## scores` exists
- `## blocking_flags` exists
- `## independent_verification` exists
- dimension scores are present in scores table
- `## confidence` exists
- `## route_reason` exists

On failure: set `state = "failed"`, mark planner/preflight/generator/evaluator called, record blocker, write state, update progress, stop.

On pass: set `evaluator_called = true`, persist evaluator ref, write state, update progress.
