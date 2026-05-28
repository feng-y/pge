# Final Plan Gate

Plan-owned execution-contract gate. Runs after the draft plan, issue contracts, acceptance, verification, evidence requirements, and self-review are written.

Plan Engineering Review is a gstack-style decision-hardening layer inside `pge-plan`. It catches selected-approach, issue-slicing, architecture, data-flow, edge-case, test-coverage, performance, and implementation-friction weaknesses before the plan is frozen. The Final Plan Gate is the hard authorization validator: it decides whether the plan is executable, verifiable, repo-grounded, and safe to hand to `pge-exec`.

No `PASS`, no `pge-exec`.

## Stability Protocol

Run this gate deterministically:

1. Read the current draft `plan.md` once from top to bottom.
2. Check layers in order: Contract Completeness, Plan Engineering Review, Repo Reality, Execution Readiness, Skill Execution Stability.
3. Stop at the first failing layer unless later evidence is already present in the plan and directly repairs that failure.
4. Apply at most one inline repair pass per failed layer, then rerun only the failed layer and any downstream layer it affects.
5. If the same layer fails twice, stop with `REVISE`, `ESCALATE`, or `REJECT`; do not loop.
6. Use exactly the verdict vocabulary in this file. Do not invent near-synonyms such as `READY`, `APPROVED`, `WARN`, or `CONCERNS`.
7. Write `Exec Allowed: yes` only when `Verdict: PASS`; otherwise write `Exec Allowed: no`.
8. Preserve `.pge/tasks-<slug>/plan.md` as the only canonical plan artifact.

This protocol is meant to keep skill execution stable. The gate must return a boring, parseable result even when the plan is messy.

## Verdicts

| Verdict | Meaning | Route effect |
|---|---|---|
| `PASS` | Plan is a complete execution contract | May route `READY_FOR_EXECUTE` or `READY_FOR_EXECUTE_WITH_ASSUMPTIONS` |
| `REVISE` | Direction is valid, but contract is incomplete or under-evidenced | Repair plan and rerun failed layers before ready route |
| `ESCALATE` | Human/challenge decision is required before a fair plan exists | Route `NEEDS_HUMAN` or `NEEDS_INFO`; exec not allowed |
| `REJECT` | Plan is wrong, unsafe, or not executable | Route `BLOCKED` or `RETURN_TO_RESEARCH`; exec not allowed |

`PASS` requires all five layers below to pass. A failed layer must record `failed_criterion`, `evidence`, `required_repair`, and `exec_allowed: no`.

## Layer 1: Contract Completeness Gate

Required fields:

- goal
- non_goals
- repo facts / source evidence
- target_areas
- forbidden_areas
- vertical slices
- behavior contracts
- acceptance criteria
- verification path
- evidence requirements
- stop condition
- risks / unknowns
- terminal conditions / abort cases

Checks:

- Every issue has a bounded action, deliverable, behavior contract, target areas, acceptance criteria, verification hint, verification type, test expectation, required evidence, dependencies, risks, security classification, and execution state.
- Every behavior contract names current behavior or current repo state, desired behavior, the behavior delta, key interfaces, out-of-scope items, and assumptions Generator must not infer.
- Every major acceptance criterion traces to user intent, research success shape, upstream constraint, current prompt, or necessary technical support.
- Each acceptance criterion has verification or required evidence. "Run tests" alone is insufficient unless the specific test scope proves the criterion.
- Non-goals and forbidden areas define what exec must not touch.
- Stop condition is observable enough that exec can check it without interpretation.
- Terminal conditions identify known cases where planning or execution must stop, revise, escalate, or route upstream.

## Layer 2: Plan Engineering Review

Checks:

- `### Plan Engineering Review` exists when the plan risk/depth needs an explicit record; LIGHT plans may use a compact review paragraph or short bullet list.
- Plan Engineering Review result is `PASS`, or all `REWORK_PLAN` findings have been repaired and rerun before Final Plan Gate.
- The selected approach, rejected approaches, issue slicing strategy, acceptance refinements, verification/evidence refinements, and risk handling reflect the review.
- Architecture, data flow, edge cases, test coverage, performance, failure modes, and protocol coherence were applied according to depth and relevance.
- If an external gstack `/plan-eng-review` or equivalent review was provided in current context, its findings are consumed as pressure input, but PGE still owns the final authorization verdict.
- Legacy `### Engineering Review Gate` may be read as an alias for older artifacts; new plan output should use `### Plan Engineering Review`.

## Layer 3: Repo Reality Gate

Checks:

- Target files/modules exist or are explicitly marked `Create`.
- Entry paths, callers, consumers, validators, config keys, registration paths, and dynamic/runtime hooks are confirmed when relevant.
- Existing code semantics are cited before the plan claims what code does or does not do.
- Legacy assumptions are labeled as assumptions, not facts.
- Hidden runtime behavior is considered for dynamic config, reflection, plugin registries, generated artifacts, feature systems, or loader paths.
- Forbidden areas are specific enough to prevent accidental scope expansion.

Repo evidence must be concrete: file paths, `file:line`, commands, config references, prior artifact evidence, or current user statements. If evidence is absent, the gate must say so.

## Layer 4: Execution Readiness Gate

Checks:

- Slices are small enough for bounded worker execution.
- Each ready slice can be independently verified, or the plan explicitly records verification coupling and safe strategy.
- Retry/block/escalate routing is clear for likely mismatch types.
- HITL work is explicit: `HITL:verify`, `HITL:decision`, or `HITL:action`.
- Exec context pack is sufficient: issue order, eligible issues, behavior contracts, target areas, acceptance, required evidence, assumptions, upstream decisions, risks, and forbidden areas.
- Parallel safety is explicit: same working tree allowed, isolated worktrees required, or serial verification required.

## Layer 5: Skill Execution Stability Gate

Checks:

- The plan uses canonical headings and fields: `## issues`, `## forbidden_areas`, `## plan_gate`, `## stop_conditions`, and `## route` with `plan_route:`.
- The plan uses only fixed route/status/verdict vocabulary defined by `pge-plan`, `plan_gate`, and `pge-exec`.
- Downstream consumer expectations are satisfied: `pge-exec` can locate ready issues, blocked issues, behavior contracts, target areas, forbidden areas, acceptance, verification, evidence, assumptions, and handoff fields without interpreting prose.
- Repair loops are bounded: retry, revise, block, escalate, and human-decision paths are explicit where likely.
- Legacy compatibility is explicit when adopting older artifacts: aliases are read only during adoption, and new output is rewritten to canonical shape.
- Clarification and stop paths are stable for missing evidence, ambiguous selectors, stale artifacts, plan-changing context, terminal conditions, and unavailable checks.
- The final response can report `plan_route`, `plan_gate`, `exec_allowed`, ready issues, blocked issues, assumptions, and next skill without inventing fields.

## Clarification And Terminal Handling

Planning does not treat unresolved conditions as runtime exceptions. They are confirmation, clarification, or stop triggers. Resolve them in this order:

1. Self-resolve from repo evidence, upstream artifacts, or current user text when the answer is mechanical.
2. If the answer changes goal, scope, acceptance, safety, or human judgment, ask at most one concrete question using the normal `pge-plan` ask path.
3. If the condition cannot be resolved in this planning turn, map it to one gate verdict plus one plan route and record it in `## terminal_conditions`.

| Condition / terminal item | Gate Verdict | Plan Route | Exec Allowed | Handling |
|---|---|---|---|---|
| Missing required plan field that can be repaired from existing evidence | `REVISE` | no final route until repaired; `BLOCKED` if not repaired this turn | no | Repair once, rerun affected layers |
| Missing required evidence and no source can provide it | `ESCALATE` | `NEEDS_INFO` or `NEEDS_HUMAN` | no | Ask one concrete question or require human decision |
| Ambiguous goal, scope, or success shape | `ESCALATE` or `REJECT` | `NEEDS_INFO` or `RETURN_TO_RESEARCH` | no | Ask once if the user can resolve it; otherwise route upstream |
| Repo reality contradiction invalidates the approach | `REJECT` | `BLOCKED` or `RETURN_TO_RESEARCH` | no | Record contradiction and required upstream repair |
| Unsafe or unauthorized scope expansion is required | `ESCALATE` or `REJECT` | `NEEDS_HUMAN` or `BLOCKED` | no | Do not smuggle expansion into issues |
| Required tool/check unavailable, but alternative evidence exists | `REVISE` | no final route until plan records alternative evidence | no | Add fallback verification/evidence |
| Required tool/check unavailable and no alternative evidence exists | `ESCALATE` | `NEEDS_HUMAN` or `BLOCKED` | no | Stop before execution |
| Human-only decision remains unresolved | `ESCALATE` | `NEEDS_HUMAN` | no | Mark affected issues `NEEDS_HUMAN` |
| Legacy artifact lacks `plan_gate` or forbidden areas | `REVISE` | contract upgrade through `pge-plan` | no | Fast-adopt / rewrite into canonical shape |
| Stale artifact or provenance mismatch | `REJECT` | `BLOCKED` | no | Refuse to execute stale contract |

Never use `PASS` with warnings for terminal conditions. A terminal condition is either confirmed/resolved and recorded inside the plan, or it prevents exec.

If no terminal conditions exist, record exactly one none row:

```markdown
| none | PASS | READY_FOR_EXECUTE | yes | No terminal conditions identified. |
```

## Record Format

Record under `## plan_gate` in `.pge/tasks-<slug>/plan.md`:

```markdown
## plan_gate

- Verdict: PASS | REVISE | ESCALATE | REJECT
- Exec Allowed: yes | no
- Failed Gate: Contract Completeness | Plan Engineering Review | Repo Reality | Execution Readiness | Skill Execution Stability | none
- Failed Criterion: <criterion or "none">
- Evidence: <file:line / artifact / command / user statement / "none">
- Required Repair: <specific repair or "none">
- Rationale: <one sentence>

### Gate Checklist

| Gate | Status | Evidence | Required Repair |
|---|---|---|---|
| Contract Completeness | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
| Plan Engineering Review | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
| Repo Reality | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
| Execution Readiness | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
| Skill Execution Stability | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
```

## Route Rules

- `plan_route: READY_FOR_EXECUTE` requires `plan_gate Verdict: PASS` and `Exec Allowed: yes`.
- `plan_route: READY_FOR_EXECUTE_WITH_ASSUMPTIONS` requires `plan_gate Verdict: PASS`, `Exec Allowed: yes`, and explicit non-scope-changing assumptions.
- `REVISE` should be repaired inline when practical. If repair cannot complete in the planning turn, final route is `BLOCKED`.
- `ESCALATE` routes to `NEEDS_HUMAN` or `NEEDS_INFO`.
- `REJECT` routes to `BLOCKED` unless the problem contract itself is invalid, in which case route `RETURN_TO_RESEARCH`.

Do not create a separate `canonical-plan.md`. The canonical plan is `.pge/tasks-<slug>/plan.md` only after the Final Plan Gate passes.

## Compatibility Rules

New `plan.v2` artifacts use `## issues`, `## forbidden_areas`, `## terminal_conditions`, `## plan_gate`, `## stop_conditions`, and `## route` with a `plan_route:` value.

For older artifacts:

- `## Slices` is a legacy alias for `## issues`.
- `Stop Condition` is a legacy alias for `## stop_conditions`.
- Missing `plan_gate` means the plan is not execution-ready under this contract; route through `pge-plan` fast-adopt / contract upgrade before `pge-exec`.
- Missing `forbidden_areas` must fail Contract Completeness unless the plan explicitly proves that no forbidden areas exist.
