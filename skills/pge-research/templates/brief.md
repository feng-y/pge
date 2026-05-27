# Research: <title>

This is a minimum contract scaffold, not a fixed prose template. Scale depth to task complexity. Add optional sections only when they reduce uncertainty or preserve material decisions for planning.

## schema_version: research.v2

## research_mode

- modes: early_exit | superpowers_brainstorming | upstream_preservation | design_surface | standard
- trigger_basis: <why each selected mode applies>

## intent_framings

Capture the user's goal from multiple angles before locking intent.

- Original goal A: <the user/upstream outcome before any implementation path was inferred>
- Explicit ask: <what the user/upstream literally asked for>
- Interpreted goal: <confirmed or clearly marked inference>
- Implementation hypothesis B: <possible path/system framing, or "none yet">
- A/B drift check: <why B still serves A, or what would prove B is the wrong frame>
- Problem statement: <why the current state is insufficient, broken, costly, confusing, or risky>
- Position in larger plan: <broader migration/product/cleanup sequence, or "standalone">
- Why this step / why now: <why this scope is the right next move>

## confirmed_intent

Lock intent only after framings are reconciled. Mark inferences explicitly.

- Original goal preserved: <goal A in the user's/outside artifact's terms>
- Confirmed goal: <the target value or capability the user wants>
- Confirmation basis: <user statement / upstream doc / self-resolved from evidence>
- Implementation hypothesis status: none | candidate_only | scope_decision | user_confirmed_goal_change
- Inferred parts: <list any inferences not yet confirmed, or "none">

## scope_contract

- In scope: <what planning should include>
- Out of scope: <what planning must not include, with rationale>
- Scope change from upstream: none | narrowed | expanded | deferred — reason: <why>

## success_shape

- Observable completion state: <what must be true when done>
- Plan would be wrong if: <conditions that would make the plan miss user intent>

## experience_scope

- experience_scope: none | user-facing | artifact-facing | visual | interaction | workflow | documentation | cli_or_prompt
- skip_reason: <required when experience_scope is none; e.g., "internal refactor, no human-facing change">

## design_surface_context

Required when `experience_scope` is not `none`. Omit only when `experience_scope` is `none`.

- product_or_surface: <what human-facing surface is being shaped>
- audience: <who encounters this surface and in what context>
- artifact_purpose: <what the artifact or surface does for the audience>
- usage_context: <where/when/how the audience uses it>
- experience_success_shape: <what "good" feels like from the audience perspective>
- what_would_disappoint: <ways the result could be technically correct but experientially wrong>
- design_system_sources: <existing component, layout, prompt, report, doc, or CLI conventions>
- design_system_status: explicit | inferred | absent
- category_baseline: <outside or local references that define expected quality, when relevant>
- expected_conventions: <table-stakes conventions users likely expect, when relevant>
- generic_risks: <category patterns that would feel generic, misleading, or off-position>
- safe_tradeoffs: <tradeoffs planning may consider without violating intent>
- risky_tradeoffs: <tradeoffs that would likely disappoint or narrow intent>
- experience_framings: <2-3 possible experience framings and why one is preferred, when non-trivial>
- design_dimension_gaps: <information still missing across hierarchy, density, flow, states, tone, or evidence>
- visual_evidence_sources: <screenshots, rendered pages, artifacts, or "not_available: reason">
- rendered_evidence_limits: <what was or was not inspected visually, when relevant>
- anti_slop_risks: <generic, overdesigned, under-specified, or misleading patterns to avoid>

## upstream_contract

- source: <path, issue, handoff, pasted doc, conversation, or "none">
- type: handoff | exec-plan | design-doc | issue | prior-research | conversation | none
- authority: user-source-of-truth | prior-artifact | reference-only | stale-or-uncertain | none
- digest: <short summary preserving problem/goal/larger-plan position/why-now>

## evidence

Findings that support the contract. Each must have basis and source.

- <finding> — basis: direct | external | reasoned — source: <file:line | docs | user | named reference>

## reality_alignment_proof

Check human/RD claims about current code reality that could affect planning. Use one `not_applicable` row with a reason when no such claim exists.

| ID | Claim | Source | Check | Result | Planning impact | Handoff refs |
|----|-------|--------|-------|--------|-----------------|--------------|
| RAP-1 | <human/RD claim about existing code, behavior, artifacts, schema, affected area, or constraint> | <user/upstream/RD source> | <repo evidence checked, e.g. file:line or command> | checked | <why planning can rely on it, or why it is non-blocking> | <planning_handoff section refs> |

- ready_for_plan_basis: <RAP row IDs that are checked, or not_applicable with reason>
- plan_blocking_gaps: <none, or RAP row IDs with contradicted/unverified planning impact>

## ambiguities

- <ambiguity> — type: requirement_gap | design_choice | implementation_detail — status: resolved | open — resolution: <how resolved, or "blocks plan">

## interactive_alignment

- questions_asked: <0-3>
- opening_focus: original_goal | implementation_hypothesis | no_user_interaction — rationale: <why the opening did or did not start from A>
- original_goal_question: <question used to recover/confirm A before discussing B, or "not needed: reason">
- user_answers_incorporated: <answer summary, or "none">
- user_confirmed_fields: <goal/scope/success/non-goals confirmed by user, or "none">
- inferred_fields_left_for_planning: <fields still inferred but non-blocking, or "none">
- no_question_rationale: <required when questions_asked is 0; include authority basis>

## planning_handoff

What planning must know because research ran.

### facts_plan_must_preserve
- <fact from evidence, confirmed intent, or RAP-# that plan must not contradict>

### constraints_plan_must_not_violate
- <hard constraint from user, upstream, repo reality, or RAP-#>

### known_invalid_directions
- <direction, scope, or constraint violation that evidence or RAP-# shows is wrong>

### likely_affected_areas
- <file or module> — reason: <why it may be touched; cite RAP-# when based on a checked code-reality claim>

### verification_risks
- <what could silently pass review but be wrong; cite RAP-# when based on a checked or contradicted claim>

### design_experience_constraints
- <required when experience_scope is not none; otherwise "none">

### unresolved_blockers
- <blocking question or "none"> — type: NEEDS_CLARIFICATION | NEEDS_INFO | BLOCKED; cite RAP-# when blocker status depends on a checked, contradicted, or unverified code-reality claim

## route

<READY_FOR_PLAN | NEEDS_INFO | BLOCKED>

Justification: <one line explaining why this route is correct>

## Metadata

- research_id: <YYYYMMDD-HHMM-slug>
- date: <ISO date>
- task_dir: .pge/tasks-<slug>/

## Optional When Useful

### Brainstorm

Use only when multiple interpretations, scope readings, or success shapes could change the plan.

| Interpretation / direction | Assumed intent | Evidence needed | Why chosen/rejected |
|----------------------------|----------------|-----------------|---------------------|
| B1 | <possible reading> | <what would distinguish it> | chosen/rejected because <reason> |

### Clarify / Grill Log

Use when intent was challenged, clarified with the user, or self-resolved from evidence.

| Round | Current interpretation | Ambiguity challenged | Question asked | Resolution | Plan impact |
|-------|------------------------|----------------------|----------------|------------|-------------|
| C1 | <one-sentence interpretation> | <what would change the plan> | <question or "self-resolved from evidence"> | <answer/resolution> | <how plan changes> |

### Upstream Requirement Ledger

| ID | Upstream item | Kind | Source | Must preserve? |
|----|---------------|------|--------|----------------|
| U1 | <requirement, phase, constraint, acceptance criterion, or non-goal> | requirement | <path:line or conversation> | yes/no |

### Decision Log

| ID | Decision | Rationale | Alternatives considered | Basis | Downstream impact |
|----|----------|-----------|-------------------------|-------|-------------------|
| D1 | <what is settled for planning> | <why this follows from evidence/intent> | <what was rejected and why> | direct | <what pge-plan should preserve> |

### Zoom-Out Map

- Entrypoints / surfaces: <where the behavior starts>
- Relevant modules / files: <smallest set planning must know>
- Data/control flow: <how the current behavior moves through the system>
- Boundaries / ownership: <what owns what; risky seams>
- Terminology mapping: <user words -> code terms>

### Research Value Proof

- Direct auto-plan would likely assume: <what planning from the prompt alone would probably do or miss>
- Research changed that by: <confirmed/rejected/refined intent, scope, code reality, or acceptance>
- Evidence for the delta: <file:line, upstream item, or user statement>

## Next

- next_skill: pge-plan
- task_dir: .pge/tasks-<slug>/
