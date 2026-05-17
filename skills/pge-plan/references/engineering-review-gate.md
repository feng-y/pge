# Engineering Review Gate

Plan-owned quality gate. Runs after Engineering Review dimensions (see `engineering-review.md`) and before approach selection. Produces a single verdict that controls plan routing.

## Purpose

Verify the proposed plan is ready for `READY_FOR_EXECUTE` by checking scope discipline, architecture fit, test coverage, failure preparedness, and verification story quality. The gate is plan-owned and does not route through research unless intent/scope/success shape is genuinely unclear.

## Gate Depth Scaling

| Depth | Dimensions Applied |
|-------|-------------------|
| LIGHT | Step 0: Scope Challenge + Verification Story Review |
| MEDIUM | Step 0 + Architecture Review + Test Coverage Review + Verification Story Review |
| DEEP | Step 0 + Architecture Review + Code Quality Review + Test Coverage Review + Verification Story Review + Performance Review |

LIGHT tasks must not pay DEEP ceremony. Scale the gate to the classified depth.

## Step 0: Scope Challenge (all depths)

Four mandatory checks before any other dimension:

1. **Existing code reuse.** What existing code already partially or fully solves this? Can we extend, wrap, or configure rather than rebuild? Cite file:line evidence.
2. **Minimum change set.** What is the smallest set of changes that achieves the stated goal? Flag anything that could be deferred without breaking acceptance criteria.
3. **Complexity smell.** If touching 8+ files or introducing 2+ new abstractions: is there a simpler path? If not, record why the complexity is essential.
4. **Completeness check.** Is this the complete solution or a shortcut? Prefer complete unless a valid scope-reduction reason exists (context budget overflow, missing info, dependency conflict).

Each check produces: `check_name | finding | evidence | resolution`.

For LIGHT depth, Step 0 plus Verification Story Review is the entire gate. If all checks pass, output `PASS`.

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
- weak verification routes `REWORK_PLAN`, not `READY_FOR_EXECUTE`

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

## Gate Output

The Engineering Review Gate produces exactly one overall verdict:

| Verdict | Meaning | Next Action |
|---------|---------|-------------|
| `PASS` | Plan meets quality bar for its depth | Proceed to approach selection and synthesis |
| `REWORK_PLAN` | Fixable issues found in approach, scope, or coverage | Fix findings inline, re-run affected checks |
| `RETURN_TO_RESEARCH` | Intent, scope, or success shape is genuinely unclear; plan cannot resolve | Route back to `pge-research` |
| `NEEDS_INFO` | Specific blocking question the user can answer | Ask one question, then re-run gate |

**When to use each:**

- `PASS`: All applicable dimensions for the classified depth produce no blocking findings.
- `REWORK_PLAN`: Scope Challenge finds unnecessary complexity, missing reuse opportunity, or incomplete coverage that plan can fix without new information. Architecture review finds unclear boundaries. Test coverage or verification-story review has gaps that can be filled.
- `RETURN_TO_RESEARCH`: The goal itself is ambiguous, multiple valid interpretations exist that change the plan shape, or success criteria cannot be derived from available information. This is rare — most issues are `REWORK_PLAN` or `NEEDS_INFO`.
- `NEEDS_INFO`: A specific factual question blocks the gate (e.g., "Does module X support concurrent writes?" and neither code nor docs answer it). The user can resolve it directly.

`SKIP_NOT_APPLICABLE` is not an overall Engineering Review Gate verdict. Use it only inside normalized quality-gate records for individual dimensions or non-engineering gates. The Engineering Review Gate always runs Step 0 and Verification Story Review.

## Gate Record Format

Record the gate result in the plan artifact:

```markdown
### Engineering Review Gate

- Depth: LIGHT | MEDIUM | DEEP
- Verdict: PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO
- Step 0 (Scope Challenge): <summary>
- Architecture: <summary or "N/A — LIGHT depth">
- Code Quality: <summary or "N/A — not DEEP">
- Test Coverage: <summary or "N/A — LIGHT depth">
- Verification Story: <summary>
- Performance: <summary or "N/A — not DEEP">
- Failure Modes: <count identified, count mitigated>
- Semantic Evidence: <count rows recorded>
- ASCII Diagrams: <count or "none required">
```
