# Research: <title>

This is a minimum contract scaffold, not a fixed prose template. Keep it short when the task is simple. Add optional sections only when they reduce uncertainty or preserve material decisions for planning.

## Metadata
- research_id: <YYYYMMDD-HHMM-slug>
- date: <ISO date>
- research_route: READY_FOR_PLAN | NEEDS_INFO | BLOCKED

## Contract
- intent_spec: <the user's real goal, success criteria, non-goals, and "plan would be wrong if...">
- clarify_status: <can plan proceed without inventing intent? yes/no; questions asked or self-resolved>
- plan_delta: <what planning must include, avoid, verify, or escalate because research ran>
- blockers: <unresolved goal/scope/acceptance/safety gaps, or "none">
- evidence: <repo/user/upstream facts that support the contract>

## Intent
- The Problem: <why the current state is insufficient, broken, costly, confusing, or risky>
- The Goal: <the target value or capability the user wants>
- Position in Larger Plan: <broader migration/product/cleanup sequence, or "standalone">
- Why This Step / Why Now: <why this scope is the right next move instead of a broader/narrower one>
- What Success Looks Like: <observable completion state planning/execution can verify>
- Explicitly Out of Scope: <what not to do, and why>

## Intent Lock
- Explicit ask: <what the user/upstream literally asked for>
- Interpreted goal: <confirmed or clearly marked inference>
- Success shape: <observable state proving the goal was met>
- Non-goals: <scope that must not be included>
- Plan-changing ambiguity: <unresolved interpretation that would change the plan, or "none">

## Synthesis Summary
- Stated: <explicit user/upstream decisions, goals, constraints, and exclusions>
- Inferred: <agent inferences needed to connect gaps; must not be presented as fact>
- Out: <rejected, deferred, or explicitly excluded scope, with why>

## Findings
- <finding> — basis: direct | external | reasoned — source: <file:line | docs | user | named reference>

## Assumptions
- <assumption> — reason: <why it is reasonable> — validation: <how planning/execution can validate or why it is safe not to>

## Plan Delta
- Plan should include: <target areas, constraints, acceptance seeds, or issue boundaries created by research>
- Plan should avoid: <wrong scope, rejected approach, unsafe assumption>
- Plan must verify: <evidence/commands/behavior checks seeded by research>
- Plan blockers: <blocking questions or "none">

## Optional When Useful

### Brainstorm
Use only when multiple interpretations, approaches, or success shapes could change the plan.

| Interpretation / approach | Assumed intent | Evidence needed | Why chosen/rejected |
|---------------------------|----------------|-----------------|---------------------|
| B1 | <possible reading> | <what would distinguish it> | chosen/rejected because <reason> |

### Clarify / Grill-With-Me Log
Use when intent was challenged, clarified with the user, or self-resolved from evidence.

| Round | Current interpretation | Ambiguity challenged | Question asked | User answer / resolution | Plan impact |
|-------|------------------------|----------------------|----------------|--------------------------|-------------|
| C1 | <one-sentence interpretation> | <what would change the plan> | <question or "self-resolved from evidence"> | <answer/resolution> | <how plan changes> |

### Intent Spec
- Problem: <confirmed problem statement>
- Goal: <confirmed target outcome>
- Scope: <what planning should include>
- Non-goals: <what planning must not include>
- Success criteria: <observable criteria planning/execution can verify>
- Acceptance seeds: <initial acceptance checks for pge-plan to formalize>
- Plan would be wrong if: <conditions that would make the plan miss user intent>

### Intent Spec Challenge
| Check | Status | Evidence / repair |
|-------|--------|-------------------|
| Preserves explicit user/upstream words | pass/fail/n/a | <evidence or repair> |
| Does not replace intent with repo-shaped convenience | pass/fail/n/a | <evidence or repair> |
| Problem, goal, scope, non-goals, and success are explicit | pass/fail/n/a | <evidence or repair> |
| Plan-wrong conditions are named | pass/fail/n/a | <evidence or repair> |
| Inferred parts are marked or confirmed | pass/fail/n/a | <evidence or repair> |

### Zoom-Out Map
- Entrypoints / surfaces: <where the behavior starts>
- Relevant modules / files: <smallest set planning must know>
- Data/control flow: <how the current behavior moves through the system>
- Boundaries / ownership: <what owns what; risky seams>
- Terminology mapping: <user words -> code terms>
- Verification hotspots: <where exec/review should prove correctness>

### Upstream Input
- source: <path, issue, handoff, pasted doc, conversation, or "none">
- type: handoff | exec-plan | design-doc | issue | prior-research | conversation | none
- authority: user-source-of-truth | prior-artifact | reference-only | stale-or-uncertain | none
- digest: <short summary preserving problem/goal/larger-plan position/why-now>

#### Upstream Requirement Ledger
| ID | Upstream item | Kind | Source | Must preserve? |
|----|---------------|------|--------|----------------|
| U1 | <requirement, phase, constraint, acceptance criterion, component, or non-goal> | requirement | <path:line or conversation> | yes/no |

### Affected Areas
- <file or module> — reason: <why it may be touched>

### Constraints
- <constraint>

### Decision Log
| ID | Decision | Rationale | Alternatives considered | Basis | Downstream impact |
|----|----------|-----------|-------------------------|-------|-------------------|
| D1 | <what is settled for planning> | <why this follows from evidence/intent> | <what was rejected and why> | direct | <what pge-plan should preserve> |

### Options

#### Option A: <name>
- Approach: <what to do>
- Basis: direct | external | reasoned
- Evidence: <why it works, source>
- Tradeoff: <what you give up>
- Could fail if: <premortem specific to this repo>
- Effort: S | M | L

### Recommendation
- Pick: Option <X>
- Why: <one line>

### Research Value Proof
- Direct auto-plan would likely assume: <what planning from the prompt alone would probably do or miss>
- Research changed that by: <confirmed/rejected/refined intent, scope, code reality, or acceptance>
- Evidence for the delta: <file:line, upstream item, or user statement>
- Question avoided or made explicit: <what no longer needs asking, or what must still be asked>

### Spec Coverage
- coverage: complete | partial | none
- scope_change: none | narrowed | expanded | deferred
- user_confirmation_required: yes | no

| Upstream ID | Brief location | Status | Notes |
|-------------|----------------|--------|-------|
| U1 | <Intent/Finding/Constraint/Option/Open Question/Scope Decision> | covered | <why enough for planning> |

### Research Quality Gates

#### Upstream Preservation Review
| Check | Status | Evidence / gap |
|-------|--------|----------------|
| Upstream sources are listed and authority is classified | pass/fail/n/a | <evidence> |
| Material upstream items are captured in the ledger | pass/fail/n/a | <evidence> |
| Each item is covered, narrowed, deferred, contradicted, or missing | pass/fail/n/a | <evidence> |
| Narrowed/deferred scope has a reason and confirmation status | pass/fail/n/a | <evidence> |

#### Grill Review
| Check | Status | Evidence / gap |
|-------|--------|----------------|
| Brainstorm considered plan-changing interpretations | pass/fail/n/a | <evidence> |
| Terminology matches code | pass/fail/n/a | <evidence> |
| Findings have evidence and basis | pass/fail/n/a | <evidence> |
| Assumptions are stress-tested and have validation | pass/fail/n/a | <evidence> |
| Scope drift is explicit | pass/fail/n/a | <evidence> |

#### Final Readiness
| Check | Status | Evidence / gap |
|-------|--------|----------------|
| Intent alignment is explicit and auditable | pass/fail/n/a | <evidence> |
| Clarify status proves planning can proceed without invented intent | pass/fail/n/a | <evidence> |
| Plan Delta is non-empty or trivial early-exit is justified | pass/fail/n/a | <evidence> |
| Evidence supports the contract | pass/fail/n/a | <evidence> |
| Route is justified as `READY_FOR_PLAN`, `NEEDS_INFO`, or `BLOCKED` | pass/fail/n/a | <evidence> |

## Open Questions
- <question> — blocks_plan: yes | no — type: NEEDS CLARIFICATION | non-blocking

## Next
- next_skill: pge-plan
- task_dir: .pge/tasks-<slug>/
