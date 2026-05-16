# Research: <title>

This is a minimum contract scaffold, not a fixed prose template. Scale depth to task complexity. Add optional sections only when they reduce uncertainty or preserve material decisions for planning.

## schema_version: research.v2

## intent_framings

Capture the user's goal from multiple angles before locking intent.

- Explicit ask: <what the user/upstream literally asked for>
- Interpreted goal: <confirmed or clearly marked inference>
- Problem statement: <why the current state is insufficient, broken, costly, confusing, or risky>
- Position in larger plan: <broader migration/product/cleanup sequence, or "standalone">
- Why this step / why now: <why this scope is the right next move>

## confirmed_intent

Lock intent only after framings are reconciled. Mark inferences explicitly.

- Confirmed goal: <the target value or capability the user wants>
- Confirmation basis: <user statement / upstream doc / self-resolved from evidence>
- Inferred parts: <list any inferences not yet confirmed, or "none">

## scope_contract

- In scope: <what planning should include>
- Out of scope: <what planning must not include, with rationale>
- Scope change from upstream: none | narrowed | expanded | deferred — reason: <why>

## success_shape

- Observable completion state: <what must be true when done>
- Plan would be wrong if: <conditions that would make the plan miss user intent>

## upstream_contract

- source: <path, issue, handoff, pasted doc, conversation, or "none">
- type: handoff | exec-plan | design-doc | issue | prior-research | conversation | none
- authority: user-source-of-truth | prior-artifact | reference-only | stale-or-uncertain | none
- digest: <short summary preserving problem/goal/larger-plan position/why-now>

## evidence

Findings that support the contract. Each must have basis and source.

- <finding> — basis: direct | external | reasoned — source: <file:line | docs | user | named reference>

## ambiguities

- <ambiguity> — type: requirement_gap | design_choice | implementation_detail — status: resolved | open — resolution: <how resolved, or "blocks plan">

## planning_handoff

What planning must know because research ran.

### facts_plan_must_preserve
- <fact from evidence or confirmed intent that plan must not contradict>

### constraints_plan_must_not_violate
- <hard constraint from user, upstream, or repo reality>

### known_invalid_directions
- <approach or scope that evidence shows is wrong>

### likely_affected_areas
- <file or module> — reason: <why it may be touched>

### verification_risks
- <what could silently pass review but be wrong>

### unresolved_blockers
- <blocking question or "none"> — type: NEEDS_CLARIFICATION | NEEDS_INFO | BLOCKED

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
