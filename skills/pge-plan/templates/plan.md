# Plan: <title>

## Metadata

- plan_id: <YYYYMMDD-HHMM-slug>
- created_at: <ISO date>
- upstream_input_ref: <path to research brief, plan mode output, or description>
- setup_config_refs: <paths or "none">
- plan_route: READY_FOR_EXECUTE | NEEDS_INFO | BLOCKED | NEEDS_HUMAN
- depth: LIGHT | MEDIUM | DEEP

## Intent

<One paragraph: what the user wants, why it matters, what success looks like>

## Coverage Audit

| Upstream Requirement/Finding | Covered By | Status |
|------------------------------|-----------|--------|
| <requirement from upstream> | Issue N | covered |
| <requirement from upstream> | — | gap (reason) |

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
- Selected: <approach name> — why: <rationale>
- Rejected: <approach name> — why: <reason from engineering review>

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

## Problem

<What is wrong or missing that this plan addresses>

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
- Action: <imperative — what to DO>
- Deliverable: <what must exist when done>
- Target Areas: <exact file paths — Create: path | Modify: path>
- Acceptance Criteria: <checkable conditions>
- Verification Hint: <command or check>
- Verification Type: AUTOMATED | MANUAL | MIXED
- Execution Type: AFK | HITL
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
- Assumptions to preserve: <list>
- Risks not to ignore: <list>

## Route

<READY_FOR_EXECUTE | NEEDS_INFO | BLOCKED | NEEDS_HUMAN>
