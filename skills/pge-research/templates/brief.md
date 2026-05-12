# Research: <title>

## Metadata
- research_id: <YYYYMMDD-HHMM-slug>
- date: <ISO date>
- research_route: READY_FOR_PLAN | NEEDS_INFO | BLOCKED

## Intent
- The Problem: <why the current state is insufficient, broken, costly, confusing, or risky>
- The Goal: <the target value or capability the user wants>
- Position in Larger Plan: <how this fits a broader migration, product goal, cleanup, or execution sequence; "standalone" if truly standalone>
- Why This Step / Why Now: <why this scope is the right next move instead of a broader/narrower one>
- What Success Looks Like: <observable completion state planning/execution can verify>
- Explicitly Out of Scope: <what not to do, and why>

## Synthesis Summary
- Stated: <explicit user/upstream decisions, goals, constraints, and exclusions>
- Inferred: <agent inferences needed to connect gaps; must not be presented as fact and should be easy for planning/review to audit>
- Out: <rejected, deferred, or explicitly excluded scope, with why>

## Upstream Input
- source: <path, issue, handoff, pasted doc, conversation, or "none">
- type: handoff | exec-plan | design-doc | issue | prior-research | conversation | none
- authority: user-source-of-truth | prior-artifact | reference-only | stale-or-uncertain | none
- digest: <short summary preserving problem/goal/larger-plan position/why-now>

### Upstream Requirement Ledger
| ID | Upstream item | Kind | Source | Must preserve? |
|----|---------------|------|--------|----------------|
| U1 | <requirement, phase, constraint, acceptance criterion, component, or non-goal> | requirement | <path:line or conversation> | yes/no |

## Findings
- <finding> — basis: direct | external | reasoned — source: <file:line | docs | user | named reference>

## Affected Areas
- <file or module> — reason: <why it will be touched>

## Constraints
- <constraint>

## Assumptions
- <assumption> — reason: <why it is reasonable> — validation: <how planning/execution can validate or why it is safe not to>

## Decision Log
| ID | Decision | Rationale | Alternatives considered | Basis | Downstream impact |
|----|----------|-----------|-------------------------|-------|-------------------|
| D1 | <what is settled for planning> | <why this follows from evidence/intent> | <what was rejected and why> | direct | <what pge-plan should preserve> |

## Options

### Option A: <name>
- Approach: <what to do>
- Basis: direct | external | reasoned
- Evidence: <why it works, source>
- Tradeoff: <what you give up>
- Could fail if: <premortem specific to this repo>
- Effort: S | M | L

### Option B: <name>
...

## Recommendation
- Pick: Option <X>
- Why: <one line>

## Spec Coverage
- coverage: complete | partial | none
- scope_change: none | narrowed | expanded | deferred
- user_confirmation_required: yes | no

| Upstream ID | Brief location | Status | Notes |
|-------------|----------------|--------|-------|
| U1 | <Intent/Finding/Constraint/Option/Open Question/Scope Decision> | covered | <why enough for planning> |

Missing or deferred material upstream items must appear in Open Questions or as explicit scope decisions. `READY_FOR_PLAN` requires no silent missing items.

## Research Quality Gates

### Upstream Preservation Review
| Check | Status | Evidence / gap |
|-------|--------|----------------|
| Upstream sources are listed and authority is classified | pass/fail/n/a | <evidence> |
| Material upstream items are captured in the ledger | pass/fail/n/a | <evidence> |
| Each item is covered, narrowed, deferred, contradicted, or missing | pass/fail/n/a | <evidence> |
| Narrowed/deferred scope has a reason and confirmation status | pass/fail/n/a | <evidence> |
| Authoritative decisions are not re-litigated | pass/fail/n/a | <evidence> |

### Grill Review
| Check | Status | Evidence / gap |
|-------|--------|----------------|
| Terminology matches code | pass/fail/n/a | <evidence> |
| Findings have evidence and basis | pass/fail/n/a | <evidence> |
| Assumptions are stress-tested and have validation | pass/fail/n/a | <evidence> |
| Options have repo-specific failure modes | pass/fail/n/a | <evidence> |
| Scope drift is explicit | pass/fail/n/a | <evidence> |
| pge-plan can proceed without re-reading upstream docs | pass/fail/n/a | <evidence> |

### Final Readiness
| Check | Status | Evidence / gap |
|-------|--------|----------------|
| Intent is complete | pass/fail/n/a | <evidence> |
| Stated/Inferred/Out are separated | pass/fail/n/a | <evidence> |
| Decision Log captures material decisions | pass/fail/n/a | <evidence> |
| Spec coverage is complete or blockers are explicit | pass/fail/n/a | <evidence> |
| Blocking NEEDS CLARIFICATION questions are limited to three or fewer | pass/fail/n/a | <evidence> |
| Open questions are marked blocking/non-blocking | pass/fail/n/a | <evidence> |
| Route is justified as `READY_FOR_PLAN`, `NEEDS_INFO`, or `BLOCKED` | pass/fail/n/a | <evidence> |

## Open Questions
- <question> — blocks_plan: yes | no — type: NEEDS CLARIFICATION | non-blocking

Blocking `NEEDS CLARIFICATION` questions must be limited to three or fewer. More than three means the brief should group uncertainties, resolve non-blockers as assumptions, or route `BLOCKED`.

## Next
- next_skill: pge-plan
- task_dir: .pge/tasks-<slug>/
