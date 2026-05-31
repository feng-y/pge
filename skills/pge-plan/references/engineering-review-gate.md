# Plan Engineering Review

Plan-owned decision-hardening mechanism. Runs during solution design after candidate approaches and bounded repo/runtime evidence exist. It improves selected approach, issue slicing, acceptance, verification, evidence, and risk handling before the Final Plan Gate.

## Purpose

Reduce `pge-exec` friction by checking scope discipline, existing-code reuse, selected-approach rationale, issue slicing, architecture fit when applicable, test/verification topology, failure preparedness, and execution ergonomics. It is not an independent execution authorization gate; the Final Plan Gate remains the hard validator for `READY_FOR_EXECUTE`.

## Trigger Conditions

Plan Engineering Review is:
- **Mandatory** for MEDIUM/DEEP plans (multi-issue, architecture changes, protocol surfaces, migration, rollout sequencing)
- **Optional** for LIGHT plans (single-issue, low-risk, existing patterns) — may be omitted entirely if the plan is trivial
- **Findings must be consumed** into selected approach, issues, acceptance, verification, and risks before Final Plan Gate validation

## Routing Authority

Plan Engineering Review does not produce routes directly. It produces findings that Plan consumes. Only Source Contract Check and Final Plan Gate have routing authority. If Plan Engineering Review discovers that the Research contract is unexecutable, unsafe, or requires goal/scope changes, Plan must surface this as a Final Plan Gate rejection with route to `RETURN_TO_RESEARCH`, `NEEDS_INFO`, or `NEEDS_HUMAN`.

## Depth Scaling

| Depth | Dimensions Applied |
|-------|-------------------|
| LIGHT | Compact scope/reuse check + selected approach rationale + verification sanity |
| MEDIUM | LIGHT dimensions + issue slicing, boundaries, failure modes, rollout shape, verification topology |
| DEEP | MEDIUM dimensions + protocol coherence, migration safety, parallel execution safety, data-flow constraints, performance risk when relevant |

LIGHT tasks must not pay DEEP ceremony. Scale the review to implementation risk.

## Step 0: Scope Challenge (all depths)

Four mandatory checks before any other dimension:

1. **Existing code reuse.** What existing code already partially or fully solves this? Can we extend, wrap, or configure rather than rebuild? Cite file:line evidence.
2. **Minimum change set.** What is the smallest set of changes that achieves the stated goal? Flag anything that could be deferred without breaking acceptance criteria.
3. **Complexity smell.** If touching 8+ files or introducing 2+ new abstractions: is there a simpler path? If not, record why the complexity is essential.
4. **Completeness check.** Is this the complete solution or a shortcut? Prefer complete unless a valid scope-reduction reason exists (context budget overflow, missing info, dependency conflict).

Each check produces: `check_name | finding | evidence | resolution`.

For LIGHT depth, Step 0 plus selected-approach rationale and Verification Story Review is the entire review. A short paragraph or compact bullet list is enough when it removes execution ambiguity. For trivial LIGHT plans, the review may be omitted entirely.

## Architecture Review (MEDIUM + DEEP)

- Component boundaries: are responsibilities clear and non-overlapping?
- Data flow: trace input → processing → output. Flag bottlenecks, circular deps, or unclear ownership.
- Dependency graph: new dependencies justified? Existing ones reused?
- Security surface: auth, data access, API boundaries (when relevant).

**ASCII diagram requirement:** For any non-trivial state machine, data flow, dependency graph, or processing pipeline introduced or modified by the plan, include an ASCII diagram. "Non-trivial" means 3+ components/states with conditional transitions or 2+ modules with bidirectional data flow.

Example format:
```
[Input] --> [Parser] --> [Validator] --ok--> [Store]
                              |
                              +--fail--> [Error Handler] --> [Response]
```

## Code Quality Review (DEEP only)

- Naming and abstraction level consistency with surrounding code.
- Single-responsibility adherence per new module/function.
- Error handling completeness (not just happy path).
- Logging/observability for new codepaths.

## Test Coverage Review (MEDIUM + DEEP)

For each issue, verify the test expectation covers:
- Happy path: primary success scenario
- Edge cases: boundary values, empty inputs, concurrent access (where relevant)
- Error path: what fails and how it is reported
- Integration boundary: if crossing modules, is the seam tested?

Gaps found here must be added to the issue's `Test Expectation` field before the gate can pass.

## Verification Story Review (all depths)

Verify the plan explains how completion will be proven, not just what will be changed.

Check:
- acceptance criteria point to concrete verification or required evidence
- verification commands, review checks, or manual proof are specific enough for `pge-exec`
- grep/manual checks include semantic evidence rows instead of bare command output
- weak verification repairs the plan via `REWORK_PLAN`; `READY_FOR_EXECUTE` still depends on Final Plan Gate `PASS`

For LIGHT plans, a short verification story is enough when the prompt and acceptance criteria are obvious. The gate still must record why the verification is sufficient.

## Performance Review (DEEP only)

- Hot path analysis: does the change sit on a latency-critical path?
- Resource scaling: memory, CPU, I/O growth characteristics under load.
- Regression risk: could this change degrade existing performance?
- Measurement: is there a way to verify performance claim post-implementation?

Skip when the change is purely structural (contracts, docs, config) with no runtime path.

## Failure Mode Requirement

For every new or changed codepath introduced by the plan (MEDIUM + DEEP):

Describe at least one realistic failure scenario per issue:
- **Trigger:** what causes the failure (bad input, network partition, race condition, config error)
- **Impact:** what breaks and what the user/system sees
- **Mitigation:** how the plan accounts for it (error handling, retry, fallback, validation)

If the plan does not account for a discovered failure mode, add mitigation to the relevant issue's Action or flag as a gap that blocks `PASS`.

Simple CRUD with no new integrations or state transitions: skip this requirement.

## Semantic Evidence Rows

When the gate uses grep, manual file inspection, or cross-reference checks to verify claims, record findings as semantic evidence rows:

| Term/Pattern | File:Line | Context | Proof/Disproof |
|---|---|---|---|
| `<searched term>` | `<file>:<line>` | `<surrounding context>` | `<what this proves or disproves>` |

This requirement applies whenever:
- Verifying that existing code handles a case the plan claims is missing
- Confirming a pattern exists or does not exist in the codebase
- Checking that a rename, removal, or migration is complete
- Validating that a referenced API, function, or config key exists

Do not claim "grep confirms X" without showing the evidence row.

## Review Output

Plan Engineering Review records exactly one overall result:

| Result | Meaning | Next Action |
|---------|---------|-------------|
| `PASS` | Selected approach, slicing, verification, and risk handling are strong enough for synthesis | Proceed to synthesis and Final Plan Gate |
| `REWORK_PLAN` | Fixable issues found in approach, scope, slicing, acceptance, verification, or coverage | Fix findings inline, re-run affected checks |
| `RETURN_TO_RESEARCH` | The inherited problem contract must change or cannot be operationalized safely | Route back to `pge-research` |
| `NEEDS_INFO` | Specific user-authority decision blocks fair planning | Ask one question, then re-run affected checks |

**When to use each:**

- `PASS`: Applicable dimensions for the classified depth produce no unresolved execution-risk findings.
- `REWORK_PLAN`: Scope Challenge finds unnecessary complexity, missing reuse opportunity, unclear boundaries, weak issue slicing, missing coverage, or weak verification that Plan can fix without changing the problem contract.
- `RETURN_TO_RESEARCH`: The goal, scope, success shape, `required_plan_adjustment`, or `first_plannable_objective` is wrong, stale, unsafe, or not executable without changing Research/user intent.
- `NEEDS_INFO`: A specific user-authority question blocks the review and cannot be resolved from repo evidence or current source text.

`SKIP_NOT_APPLICABLE` is not an overall Plan Engineering Review result. Use it only inside optional per-dimension records. Findings normally repair the plan inline; they do not authorize execution.

## Record Format

Record the review in the plan artifact when it helps execution or review detect drift. LIGHT plans may use a compact paragraph or short bullet list, or omit the review entirely if trivial.

Evidence gathered during Plan exploration (runtime paths, protocol surfaces, coupling hotspots, verification constraints, migration blockers) should be embedded in the Plan Engineering Review section or approach rationale. Evidence is ephemeral unless it directly informs a decision that must be traceable.

```markdown
### Plan Engineering Review

- Depth: LIGHT | MEDIUM | DEEP
- Result: PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO
- Selected Approach: <approach and why it satisfies the inherited problem contract>
- Rejected Approaches: <approaches rejected and why>
- Complexity / Risk Reduction: <how the plan reduces implementation friction and blast radius>
- Scope Drift Check: <why goal/scope/non-goals/constraints are preserved>
- Verification Strategy: <first trustworthy verification point and final evidence>
- Issue Slicing / Coupling: <execution order, dependencies, coupling, or "N/A — LIGHT">
- Protocol Coherence: <producer/consumer/validator/evidence check when relevant, or "N/A">
- Remaining Findings: <none, or bounded issue fixed before Final Plan Gate>
```

New `plan.v2` artifacts use `### Plan Engineering Review`. Do not preserve older heading aliases as part of the active contract.
