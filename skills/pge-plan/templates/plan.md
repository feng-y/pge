# Plan: <title>

## Metadata

- plan_id: <YYYYMMDD-HHMM-slug>
- created_at: <ISO date>
- upstream_input_ref: <path to research brief, plan mode output, or description>
- setup_config_refs: <paths or "none">
- plan_route: READY_FOR_EXECUTE | NEEDS_INFO | BLOCKED | NEEDS_HUMAN
- depth: LIGHT | MEDIUM | DEEP

## Input Priority

Current prompt is the highest-priority input. Every hard constraint from the current prompt must be reflected in this plan or explicitly overridden.

| Source | Role | Priority | Consumed As | Conflicts / Overrides |
|--------|------|----------|-------------|------------------------|
| <current prompt / trailing arguments> | hard constraint / latest override / selected scope | highest | <Intent / Non-goals / Target Areas / Verification / issue boundaries> | <none or override ID> |
| <original source-of-truth file or prompt, if any> | source of truth | high | <Plan Constraints / Coverage Audit / Phase Boundary> | <none or override ID> |
| <repo code/docs/config> | evidence | high | <Repo Context / Engineering Review> | <none or contradiction with source> |
| <research.md or derived summary, if any> | derived summary | medium | <Repo Context / Plan defaults / assumptions> | <none or original source reread needed> |

### Current Constraints

- <hard constraint from current prompt> — reflected in: <section / issue / non-goal / verification>

## Intent

- The Problem: <carry from research/upstream; what is wrong or costly>
- The Goal: <target value or capability>
- Position in Larger Plan: <broader migration/product/cleanup sequence, or "standalone">
- Why This Step / Why Now: <why this phase/scope is the right next move>
- What Success Looks Like: <observable outcome>
- Explicitly Out of Scope: <non-goals with rationale>

## Plan Constraints

Authoritative upstream decisions that planning must inherit. Do not re-litigate these unless explicitly overridden below.

| Decision ID | Decision | Source | Plan handling |
|-------------|----------|--------|---------------|
| D1 | <upstream spec decision> | <research.md section / upstream path> | inherited as <constraint / issue ref / verification ref> |

### Decision Overrides
| Upstream Decision ID | Override Decision | Rationale | Alternatives considered | User confirmation required? |
|----------------------|-------------------|-----------|-------------------------|-----------------------------|
| <none or D1> | <overridden decision> | <why repo evidence requires override> | <rejected alternatives> | yes/no |

## Phase Boundary

- upstream_phase_structure: <none or phase list from research/upstream>
- current_phase: <which phase this plan covers>
- deferred_phases: <what remains outside this plan and why>
- phase_boundary_source: <research.md section / upstream path / conversation>

## Coverage Audit

### Requirement Coverage
| Upstream ID | Requirement/Finding | Covered By | Status |
|-------------|---------------------|------------|--------|
| U1 | <requirement from upstream> | Issue N | covered |
| U2 | <requirement from upstream> | — | gap (reason) |

### Spec Decisions Coverage
| Upstream Decision | Covered By | Status |
|-------------------|------------|--------|
| D1 | Plan Constraint / Issue N / Verification | inherited |
| D2 | Decision Overrides | overridden (reason) |

## Engineering Review

### Scope Challenge
- Minimum change set: <what is the smallest set of changes that achieves the goal>
- Existing code that helps: <what already exists that can be reused>
- Complexity: <N files touched, N new abstractions introduced>
- Completeness decision: <complete version or phased — why>

### Architecture Assessment
- Boundaries: <component boundaries and coupling>
- Data flow: <key data flows, potential bottlenecks>
- Failure modes: <one realistic production failure per new codepath>
- Security: <auth, data access, API boundaries — or "not applicable">

### Confidence Summary
- HIGH: <findings verified in code/docs>
- MEDIUM: <findings inferred from patterns>
- LOW: <assumptions — list each with verification status>

### Approach Decision
| Decision | Rationale | Alternatives considered |
|----------|-----------|-------------------------|
| <selected implementation approach> | <why this follows from upstream + repo evidence> | <rejected approaches and why> |

## Self-Evaluation

### Question 1
- Question: <potential question>
- Classification: Mechanical | Taste | User Challenge
- Why it matters: <impact on plan>
- Can repo/docs/code answer it? <yes/no>
- Is it blocking execution? <yes/no>
- Can we make a safe assumption? <yes/no>
- If unanswered, what is the risk? <description>
- Decision: SELF_ANSWERED | ASK_USER | ASSUME_AND_RECORD | DEFER_TO_SLICE | BLOCK_PLAN

## Execution Problem Detail

<Optional code-level detail that clarifies the structured Intent. Do not rewrite or weaken Intent.>

## Non-goals

- <what this plan explicitly does NOT do>

## Assumptions

- <assumption> — confidence: HIGH|MEDIUM|LOW — reason: <why it is reasonable> — verification: <how to confirm if LOW>

## Repo Context

- <relevant finding> — source: <file:line or docs> — confidence: HIGH|MEDIUM|LOW

## Target Areas

- <file or module> — reason: <why it will be touched>

## Acceptance Criteria

- <criterion that must be true when execution is complete>

## Stop Condition

<Observable state that means "done". Concrete enough that exec can check without interpretation.>

## Slices

### Issue 1: <Title>

- ID: 1
- Title: <short title>
- Scope: <what this issue covers>
- upstream_decision_refs: <D1, D2, or "none">
- Action: <imperative — what to DO>
- Deliverable: <what must exist when done>
- Target Areas: <exact file paths — Create: path | Modify: path>
- Acceptance Criteria: <checkable conditions>
- Verification Hint: <command or check>
- Verification Type: AUTOMATED | MANUAL | MIXED
- Execution Type: AFK | HITL:verify | HITL:decision | HITL:action
- Test Expectation: <happy path + edge case to test, or "none — [reason]">
- Required Evidence: <what must be shown to prove done>
- State: READY_FOR_EXECUTE
- Dependencies: <issue IDs or "none">
- Risks: <what could go wrong>

### Issue 2: <Title>

...

## Verification

<How to verify the plan as a whole is complete after all issues execute>

## Risks / Open Questions

- <risk or open question> — impact: <what happens if unresolved> — confidence: <HIGH|MEDIUM|LOW>

## Handoff To Execute

- Process issues by number starting from Issue 1
- Eligible issues: <list>
- AFK issues (fully autonomous): <list>
- HITL issues (need human during execution): <list>
- Concurrency: decided by pge-exec at runtime
- Upstream decisions to preserve: <decision IDs and short labels>
- Assumptions to preserve: <list>
- Risks not to ignore: <list>

## Route

<READY_FOR_EXECUTE | NEEDS_INFO | BLOCKED | NEEDS_HUMAN>
