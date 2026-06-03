# Final Plan Gate Structured Inputs

This is the `pge-plan` reference for the Plan Gate v3 transition layer.

`references/plan-gate.md` remains the authoritative Final Plan Gate. This file defines the optional-to-required structured inputs that make the gate easier to audit and later automate.

For the longer rationale and future validator shape, see `docs/pge/plan-gate-v3.md`.

Use this reference when a plan is MEDIUM/DEEP, changes workflow contracts, changes artifact schemas, changes validation/evidence rules, introduces architecture deltas, or has meaningful forbidden zones.

Issue-file plan migrations are both `workflow_contract_change` and `artifact_schema_change`: include boundary checks for the `plan.md ## issues` index fields, referenced `issues/Ixxx.md` files, index/file consistency, and the rule that embedded executable issue bodies are non-canonical execution input.

## Required Section

For those plans, include `## plan_gate_inputs` before `## plan_gate` in the canonical plan.

LIGHT plans may omit this section when the ordinary gate checklist is sufficient and no workflow/schema/boundary risk exists.

## Shape

```markdown
## plan_gate_inputs

### Declared Change Types

- <change_type> - reason: <why this type applies> - target issues: <IDs>

### Required Claims

| Claim ID | Claim | Required By | Evidence Type | Required Shape | Provided Evidence | Status |
|---|---|---|---|---|---|---|
| C1 | <claim the gate must trust> | <change type / issue / acceptance criterion> | code_pointer_set / doc_pointer / command_output / artifact_field / user_statement / negative_boundary / manual_review | <specific shape> | <evidence reference> | satisfied / pending / not_applicable |

### Boundary Checks

| Check ID | Boundary | Rule | Evidence | Future Tool Check | Status |
|---|---|---|---|---|---|
| B1 | allowed_targets / forbidden_paths / forbidden_semantics / generated_artifacts / route_vocabulary / schema_fields | <rule> | <evidence reference> | changed_files_intersection / section_diff / route_vocab_scan / schema_field_scan / manual_review | pass / pending / not_applicable |

### Validation Reality

- Cheap feedback: <checks useful during implementation>
- Trust gates: <checks/evidence required before review can trust completion>
- Unavailable checks: <checks that cannot run now, with fallback evidence or terminal handling>
```

## Change Types

Use only the smallest honest set:

- `documentation_contract_change`
- `workflow_contract_change`
- `artifact_schema_change`
- `validation_contract_change`
- `runtime_path_change`
- `config_contract_change`
- `request_construction_change`
- `feature_semantics_change`
- `abstraction_introduction`
- `test_or_harness_change`

If none apply, omit the section for LIGHT plans or declare `none` with a short rationale for larger plans.

## Gate Rules

- Missing `plan_gate_inputs` is a Contract Completeness failure for MEDIUM/DEEP Architecture Delta Contracts, workflow-contract changes, artifact-schema changes, validation-contract changes, gate/tooling changes, or plans with material forbidden-zone risk.
- Each declared change type must have at least one required claim unless the type is explicitly marked `not_applicable` with rationale.
- Each required claim must have a concrete evidence type and required shape.
- `pending` claims prevent `plan_gate Verdict: PASS` unless a terminal condition routes the plan away from execution.
- Boundary checks must cover both `target_areas` and `forbidden_areas`.
- When route/status/verdict vocabulary changes or is referenced, include a `route_vocabulary` boundary check.
- When template/schema fields change, include a `schema_fields` boundary check.
- When issue-file plans are introduced or changed, include `schema_fields` for the index and issue-file required fields, plus `generated_artifacts` or equivalent evidence that referenced issue files exist.

## Evidence Types

| Evidence type | Use for | Minimum shape |
|---|---|---|
| `code_pointer_set` | Code facts, symbols, callers, consumers | file path plus symbol or line range |
| `doc_pointer` | Documentation or skill-contract facts | file path plus heading/section |
| `command_output` | Build/test/eval/tool facts | command plus expected signal |
| `artifact_field` | Canonical PGE artifact facts | artifact path plus field/heading |
| `user_statement` | User-authority decisions | current prompt quote or referenced statement |
| `negative_boundary` | What must not change | forbidden path/semantic rule plus audit method |
| `manual_review` | Non-mechanical judgment | reviewer dimension and reason automation is unavailable |

## Boundary Vocabulary

| Boundary | Meaning |
|---|---|
| `allowed_targets` | Paths/modules/artifacts execution may modify |
| `forbidden_paths` | Paths execution must not modify |
| `forbidden_semantics` | Behaviors, responsibilities, or contracts that must not change |
| `generated_artifacts` | Generated/rendered assets that must be updated or explicitly left alone |
| `route_vocabulary` | Fixed route/status/verdict words that downstream tools consume |
| `schema_fields` | Required headings, fields, or artifact shape |

## Relationship To `## plan_gate`

`plan_gate_inputs` does not authorize execution. It supplies structured material for the Final Plan Gate.

`## plan_gate` authorizes execution only when:

- `Verdict: PASS`
- `Exec Allowed: yes`
- all active gate layers pass
- every required `plan_gate_inputs` claim is satisfied or not applicable with rationale
- every required boundary check passes or is not applicable with rationale
