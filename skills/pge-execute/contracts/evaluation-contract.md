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
- required evidence is judged against artifacts available by evaluation time, not against post-route artifacts written only after convergence
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

## scoring dimensions

Six scoring dimensions, divided into core and supporting:

### core dimensions (hard threshold = 3)

| Dimension | Code | Weight | Evaluates | Hard Threshold |
|-----------|------|--------|-----------|----------------|
| Deliverable Alignment | `DA` | 0.25 | whether the actual deliverable matches the contract-approved `actual_deliverable` | 3 |
| Evidence Sufficiency | `ES` | 0.25 | whether evidence is sufficient, independent, and verifiable | 3 |
| Contract Compliance | `CC` | 0.20 | whether all `acceptance_criteria` and `design_constraints` are satisfied | 3 |

### supporting dimensions (hard threshold = 2)

| Dimension | Code | Weight | Evaluates | Hard Threshold |
|-----------|------|--------|-----------|----------------|
| Scope Discipline | `SD` | 0.10 | whether `in_scope`/`out_of_scope` boundaries are respected | 2 |
| Verification Integrity | `VI` | 0.10 | whether `verification_path` was executed and results are credible | 2 |
| Completeness | `CP` | 0.10 | whether `stop_condition` is met and `non_done_items` are acceptable | 2 |

### scale (1-5 per dimension)

| Score | Meaning | Quality |
|-------|---------|---------|
| 1 | missing or placeholder | deliverable absent, blank, or pure TODO/placeholder |
| 2 | present but unacceptable | has content but does not meet contract requirements, or pure narrative without substance |
| 3 | minimum acceptable | meets contract literal requirements, but quality is marginal and evidence is thin |
| 4 | good | meets contract requirements, evidence is sufficient, no obvious defects |
| 5 | excellent | exceeds contract requirements, evidence is complete and independently verifiable |

### per-dimension scoring criteria

#### Deliverable Alignment (DA)

| Score | Criteria |
|-------|----------|
| 1 | `deliverable_path` does not exist, or points to an empty file / pure placeholder |
| 2 | file exists but content does not match contract `actual_deliverable` (e.g. contract requires code, delivered a design doc) |
| 3 | content matches the required deliverable type, but coverage is incomplete or has obvious gaps |
| 4 | content fully matches contract requirements, `changed_files` reflects real work |
| 5 | fully matches and exceeds expectations, deliverable quality clearly above contract minimum |

#### Evidence Sufficiency (ES)

| Score | Criteria |
|-------|----------|
| 1 | no evidence, or evidence is only Generator self-report ("I checked, it's fine") |
| 2 | evidence exists but is not independent (only `local_verification` or `self_review`, no tool output) |
| 3 | independent evidence exists (tool output, file content check), but does not cover all `acceptance_criteria` |
| 4 | each `acceptance_criteria` has a corresponding independent evidence item |
| 5 | evidence is complete and includes negative verification (verified that things that should not happen did not happen) |

#### Contract Compliance (CC)

| Score | Criteria |
|-------|----------|
| 1 | multiple `acceptance_criteria` unmet, or undeclared major deviations exist |
| 2 | some `acceptance_criteria` met, but key clauses are missing |
| 3 | all `acceptance_criteria` literally met, `design_constraints` respected |
| 4 | contract fully satisfied, deviations (if any) are declared and reasonable |
| 5 | contract fully satisfied, no deviations, all constraints in `evidence_basis` verified |

#### Scope Discipline (SD)

| Score | Criteria |
|-------|----------|
| 1 | `changed_files` includes files explicitly forbidden in `out_of_scope` |
| 2 | minor scope creep but no forbidden areas touched |
| 3 | `changed_files` within `in_scope`, `out_of_scope` respected |
| 4 | scope strictly controlled, `handoff_seam` fully preserved |
| 5 | scope strictly controlled, and boundary-adjacent decisions are proactively justified |

#### Verification Integrity (VI)

| Score | Criteria |
|-------|----------|
| 1 | `verification_path` not executed, no verification record |
| 2 | verification executed but not the contract-specified `verification_path`, and deviation not declared |
| 3 | contract-specified `verification_path` executed, or a reasonable alternative declared |
| 4 | verification fully executed, results reproducible |
| 5 | verification fully executed, includes boundary cases and failure path verification |

#### Completeness (CP)

| Score | Criteria |
|-------|----------|
| 1 | `stop_condition` clearly unmet, many `non_done_items` |
| 2 | `stop_condition` partially met, `non_done_items` affect core functionality |
| 3 | `stop_condition` met, `non_done_items` do not affect current round acceptance |
| 4 | `stop_condition` met, `non_done_items` are only future-round extensions |
| 5 | fully met, no `non_done_items`, `handoff_seam` clearly defined |

### weighted score formula

```
weighted_score = DA × 0.25 + ES × 0.25 + CC × 0.20 + SD × 0.10 + VI × 0.10 + CP × 0.10
```

## hard threshold rules

### verdict determination

- **PASS**: all core dimensions (DA/ES/CC) >= 3 AND all supporting dimensions (SD/VI/CP) >= 2 AND weighted_score >= 3.5 (3.50 exactly is PASS) AND no blocking flags
- **RETRY**: (a) at least one dimension below its hard threshold, but all dimensions >= 2, and DA >= 3; OR (b) all dimensions >= hard threshold but weighted_score < 3.5
- **BLOCK**: any dimension = 1, OR any core dimension (DA/ES/CC) = 2 AND DA < 3, OR weighted_score < 3.0 with DA < 3, OR any blocking flag (BF_MISSING / BF_PLACEHOLDER / BF_NARRATIVE / BF_SCOPE_VIOLATION / BF_UNDECLARED_DEV)
- **ESCALATE**: contract coherence issues (the cause is contract ambiguity/conflict), OR BF_CONTRACT_REWRITE

### decision flowchart

```
start evaluation
  │
  ├─ check blocking flags
  │   ├─ BF_CONTRACT_REWRITE = true → ESCALATE
  │   ├─ BF_MISSING / BF_PLACEHOLDER / BF_NARRATIVE = true → BLOCK
  │   ├─ BF_NO_INDEPENDENT_EVIDENCE = true → RETRY
  │   └─ BF_SCOPE_VIOLATION / BF_UNDECLARED_DEV = true → BLOCK
  │
  ├─ compute dimension scores
  │   ├─ any core dimension (DA/ES/CC) = 1 → BLOCK
  │   ├─ any core dimension (DA/ES/CC) = 2 → RETRY (if DA >= 3) or BLOCK
  │   ├─ any supporting dimension (SD/VI/CP) = 1 → BLOCK
  │   └─ all dimensions >= hard threshold → continue
  │
  ├─ compute weighted score
  │   ├─ weighted_score < 3.0 → BLOCK
  │   ├─ weighted_score < 3.5 → RETRY
  │   └─ weighted_score >= 3.5 → PASS
  │
  └─ check contract coherence
      ├─ contract itself is ambiguous/conflicting → ESCALATE
      └─ contract is clear → maintain verdict from above
```

## blocking flags

Seven independent blocking flags. Any flag being true prevents verdict from being PASS, regardless of dimension scores.

| Flag | Code | Trigger Condition |
|------|------|-------------------|
| Missing Deliverable | `BF_MISSING` | `deliverable_path` does not exist or points to an empty file |
| Placeholder Only | `BF_PLACEHOLDER` | deliverable content is entirely TODO/placeholder/stub |
| Narrative Only | `BF_NARRATIVE` | Generator provided only narrative, no actual repo work |
| No Independent Evidence | `BF_NO_INDEPENDENT_EVIDENCE` | `evidence` field is empty or contains only self-report (E_SELF/E_NARR), no high-independence evidence |
| Scope Violation | `BF_SCOPE_VIOLATION` | `changed_files` includes files explicitly forbidden in `out_of_scope` |
| Undeclared Deviation | `BF_UNDECLARED_DEV` | major deviation exists that is not declared in `deviations_from_spec` |
| Contract Rewrite | `BF_CONTRACT_REWRITE` | Generator silently redefined `acceptance_criteria` or `actual_deliverable` |

### blocking flag to verdict mapping

```
if any BF_* is true:
  if BF_MISSING or BF_PLACEHOLDER or BF_NARRATIVE:
    verdict = BLOCK
    next_route = retry (if contract still valid) or return_to_planner
  if BF_CONTRACT_REWRITE:
    verdict = ESCALATE
    next_route = return_to_planner
  if BF_NO_INDEPENDENT_EVIDENCE:
    verdict = RETRY (evidence can be gathered without re-implementation)
  if BF_SCOPE_VIOLATION or BF_UNDECLARED_DEV:
    verdict = BLOCK
    next_route = retry
```

### blocking flag precedence

When multiple blocking flags fire simultaneously, apply the most severe verdict:
ESCALATE > BLOCK > RETRY.

## evidence classification

Six evidence types with independence levels:

| Evidence Type | Code | Description | Independence |
|---------------|------|-------------|--------------|
| Tool Output | `E_TOOL` | actual output from Bash/Read/Grep or other tools | high — Evaluator can independently reproduce |
| File Content | `E_FILE` | actual content snippet from `deliverable_path` | high — Evaluator can directly Read |
| Diff Evidence | `E_DIFF` | specific before/after differences | high — verifiable via git diff |
| Test Result | `E_TEST` | actual test run output (pass/fail + output) | high — Evaluator can re-run |
| Self Report | `E_SELF` | Generator self-report or `self_review` | low — cannot serve as sole evidence |
| Narrative | `E_NARR` | text description without tool backing | none — not accepted as evidence |

### sufficiency rules

Each `acceptance_criteria` item must be supported by at least one high-independence evidence item (`E_TOOL` / `E_FILE` / `E_DIFF` / `E_TEST`).

```
for each criterion in acceptance_criteria:
  supporting_evidence = evidence items mapped to this criterion
  high_independence = [e for e in supporting_evidence if e.type in (E_TOOL, E_FILE, E_DIFF, E_TEST)]

  if len(high_independence) == 0:
    criterion_met = false  → ES dimension score reduction
  if len(supporting_evidence) == 0:
    criterion_met = false  → BF_NO_INDEPENDENT_EVIDENCE if all criteria lack evidence
```

### independent verification requirements

Evaluator must not only check Generator-provided evidence but also perform independent verification:

1. **file existence verification**: Read `deliverable_path`, confirm file exists and is non-empty
2. **content substantiveness verification**: check deliverable content is real work (not placeholder / not pure narrative)
3. **change surface verification**: check `changed_files` reflects real changes
4. **at least one independent reproduction**: for at least one `acceptance_criteria`, Evaluator independently verifies using its own tools (not merely trusting Generator tool output)

## anti-slop detection

The following patterns in `verdict_reason` or `evidence` trigger automatic review flags:

| Pattern | Rule Code | Detection Criteria | Effect |
|---------|-----------|--------------------|--------|
| praise without substance | `praise_without_substance` | `verdict_reason` contains "excellent" / "impressive" / "well-crafted" or similar praise words without substantive content | slop_flag triggered |
| issue minimization | `issue_minimization` | evidence identifies a severity >= major issue but verdict is PASS | slop_flag triggered |
| existence as quality | `existence_as_quality` | evidence only references file paths / section titles, no actual content | slop_flag triggered |
| self-reference loop | `self_reference_loop` | evidence cites Generator's `self_review` as primary basis | slop_flag triggered |

### slop flag enforcement

```
rule: any slop_flag triggered → verdict cannot be PASS.
      Evaluator must re-examine the flagged evidence items,
      either provide stronger independent evidence, or downgrade verdict.

exception: issue_minimization only triggers when the identified issue
           has severity >= major. Identifying minor issues while giving
           PASS is a reasonable evaluation pattern, consistent with the
           "choose the narrowest verdict" principle.
```

## verdict bundle format

Evaluator output is a markdown artifact containing the following structured sections:

```markdown
## verdict
PASS | RETRY | BLOCK | ESCALATE

## scores
| Dimension | Score | Hard Threshold | Status |
|-----------|-------|----------------|--------|
| Deliverable Alignment (DA) | <1-5> | 3 | PASS/FAIL |
| Evidence Sufficiency (ES) | <1-5> | 3 | PASS/FAIL |
| Contract Compliance (CC) | <1-5> | 3 | PASS/FAIL |
| Scope Discipline (SD) | <1-5> | 2 | PASS/FAIL |
| Verification Integrity (VI) | <1-5> | 2 | PASS/FAIL |
| Completeness (CP) | <1-5> | 2 | PASS/FAIL |
| **Weighted Score** | **<x.xx>** | **3.50** | **PASS/FAIL** |

## blocking_flags
- BF_MISSING: true/false
- BF_PLACEHOLDER: true/false
- BF_NARRATIVE: true/false
- BF_NO_INDEPENDENT_EVIDENCE: true/false
- BF_SCOPE_VIOLATION: true/false
- BF_UNDECLARED_DEV: true/false
- BF_CONTRACT_REWRITE: true/false

## evidence
[structured evidence items, each containing type/source/content_summary/supports_criteria]

## violated_invariants_or_risks
[specific violations, each with severity and evidence_ref]

## required_fixes
[only for RETRY/BLOCK — specific fix requirements with contract_field and required_evidence]

## next_route
continue | converged | retry | return_to_planner

## route_reason
[rationale for routing choice]
```

## evaluator anti-regression mechanisms

### mechanism 1: forced independent verification

Evaluator must include an `independent_verification` section in the verdict bundle, recording at least one verification the Evaluator performed independently (not citing Generator verification results).

```
rule: if verdict bundle has no independent_verification section,
      or that section is empty, verdict automatically downgrades to RETRY.
```

### mechanism 2: evidence type distribution cap

```
rule: in the evidence list, E_SELF and E_NARR type entries
      must not exceed 30% of total evidence entries.
      if exceeded → ES dimension automatically capped at 2.
```

### mechanism 3: deliverable content sampling

Evaluator must Read `deliverable_path` and cite at least one segment of actual content (not file name, not section title) in evidence.

```
rule: if evidence does not cite actual deliverable content → DA dimension automatically capped at 2.
```

### mechanism 4: acceptance criteria per-item mapping

```
rule: verdict bundle evidence section must provide at least one evidence_ref
      mapping for each acceptance_criteria item.
      unmapped criteria are treated as unverified → CC dimension adjusted proportionally.

      CC_adjusted = CC_raw × (mapped_criteria / total_criteria)
      rounded down to nearest integer, minimum 1.

      example: total_criteria = 3, mapped_criteria = 2, CC_raw = 4
               CC_adjusted = floor(4 × 2/3) = floor(2.67) = 2
               This is below the core threshold of 3, triggering RETRY or BLOCK.
               The floor rounding is intentionally strict — partial criteria mapping
               significantly reduces the CC score to enforce complete evidence coverage.
```
