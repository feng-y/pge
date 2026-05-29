# Plan Gate v3 Transition

This document defines the lightweight transition from a semantic Final Plan Gate to a structured claim/evidence/boundary gate.

It is a contract sketch, not a full validator implementation. `skills/pge-plan/references/plan-gate.md` remains the authoritative runtime gate for `plan.v2` artifacts.

## Purpose

Plan Gate v3 makes the final gate less dependent on planner self-assessment by requiring structured inputs that can later be checked by tools:

- declared change types
- required claims derived from those change types
- evidence schemas for each claim
- boundary checks for target and forbidden areas

The immediate goal is to make `.pge/tasks-<slug>/plan.md` easier for `pge-exec`, `pge-review`, and future validators to audit without changing the canonical plan artifact or forcing every light task through heavy ceremony.

## Compatibility

- Current canonical plan schema stays `plan.v2`.
- `## plan_gate` remains the execution authorization result.
- `## plan_gate_inputs` is a structured input section consumed by the Final Plan Gate.
- `plan_gate_inputs` is required for MEDIUM/DEEP Architecture Delta Contracts, workflow-contract changes, artifact-schema changes, validation-contract changes, gate/tooling changes, and any plan where forbidden-zone or evidence mistakes could produce a correct-looking but wrong execution.
- LIGHT plans may omit `plan_gate_inputs` when the ordinary `plan_gate` checklist is sufficient.

## Change Type Registry

Use the smallest set that honestly describes the authorized delta.

| Change type | When to declare | Required claim families |
|---|---|---|
| `documentation_contract_change` | Skill docs, README, templates, or handoff contracts change | source fidelity, downstream consumer, boundary |
| `workflow_contract_change` | Stage routing, gates, verdicts, status vocabulary, or execution authority change | route authority, vocabulary, downstream consumer, boundary |
| `artifact_schema_change` | Canonical artifact fields, headings, templates, or parsing expectations change | schema shape, compatibility, downstream consumer |
| `validation_contract_change` | Verification, evidence, review, challenge, or gate proof requirements change | evidence burden, validation reality, terminal behavior |
| `runtime_path_change` | Runtime code paths, command behavior, plugin loading, or dispatch changes | entry path, caller/consumer, regression verification |
| `config_contract_change` | Config files, keys, defaults, or generated config semantics change | config source, compatibility, fallback behavior |
| `request_construction_change` | API/request payload, prompt, command, or agent handoff construction changes | input mapping, output contract, failure mode |
| `feature_semantics_change` | User-visible behavior or product semantics change | current behavior, desired behavior, acceptance proof |
| `abstraction_introduction` | New shared helper, framework, layer, registry, or generalized mechanism appears | reuse need, call sites, blast radius, simpler alternative |
| `test_or_harness_change` | Test harness, fixtures, mocks, evals, CI, or validation scripts change | signal validity, failure meaning, maintenance boundary |

If the implementation later touches a path or symbol implying an undeclared change type, execution should stop and route back to `pge-plan` unless the plan explicitly allowed that expansion.

## Required Claims

Each declared change type produces claims the plan must make before `plan_gate` can pass.

At minimum, every non-LIGHT plan should state:

- `current_reality`: what exists now and where the evidence is
- `authorized_delta`: what this plan changes
- `forbidden_boundary`: what it must not change
- `downstream_consumer`: who or what consumes the changed contract
- `validation_reality`: which checks are cheap feedback and which checks are trust gates
- `terminal_behavior`: what condition stops execution or routes upstream

Add change-type-specific claims only when relevant. Do not create vague claims that cannot be proven.

## Evidence Schema

Evidence entries should be structured enough for a future validator to check basic freshness and shape.

```text
claim_id: <stable id>
claim: <short factual or contract claim>
evidence_type: code_pointer_set | doc_pointer | command_output | artifact_field | user_statement | negative_boundary | manual_review
required_shape: <file_path + line_range + symbol / command + expected signal / artifact section / explicit user quote>
provided_evidence: <current evidence reference or pending>
validation: file_exists | symbol_occurs | command_runs | section_exists | reviewer_confirms | not_applicable
status: satisfied | pending | not_applicable
```

Evidence rules:

- `code_pointer_set` should name files and symbols or line ranges when available.
- `doc_pointer` should name the document and section.
- `command_output` should name the command and expected signal, not paste large logs.
- `negative_boundary` should define what must remain untouched or semantically unchanged.
- `manual_review` is allowed only when the claim cannot be mechanically checked yet.

## Boundary Checks

Boundary checks turn allowed and forbidden areas into audit targets.

```text
check_id: <stable id>
boundary: allowed_targets | forbidden_paths | forbidden_semantics | generated_artifacts | route_vocabulary | schema_fields
rule: <plain-language rule>
evidence: <path/section/command/manual review>
future_tool_check: changed_files_intersection | section_diff | route_vocab_scan | schema_field_scan | manual_review
status: pass | pending | not_applicable
```

Minimum expected checks for MEDIUM/DEEP Architecture Delta Contracts:

- changed files must stay within `target_areas`, unless an issue records a specific exception
- changed files must not intersect `forbidden_areas`
- route/status/verdict vocabulary must stay canonical when workflow contracts are touched
- schema/template field changes must preserve downstream consumer expectations
- generated or rendered artifacts must be named as either target areas or non-goals

## Final Gate Consumption

The Final Plan Gate should consume `plan_gate_inputs` before writing `## plan_gate`:

1. Check declared change types against target areas, issue behavior contracts, and verification scope.
2. Check required claims are present for the declared change types.
3. Check each claim has an evidence schema with status `satisfied` or an explicit terminal condition.
4. Check boundary checks cover both allowed changes and forbidden zones.
5. If these structured inputs are missing for a plan that requires them, fail Contract Completeness with `REVISE`.
6. If the inputs expose an unresolved human or upstream decision, use `ESCALATE` or `REJECT` according to the existing Final Plan Gate route rules.

This transition does not make the gate fully mechanical yet. It gives the gate machine-checkable handles without overstating what current tooling proves.
