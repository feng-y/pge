# Final Plan Gate

Plan-owned execution-contract gate. Runs after the draft `plan.md`, issue index, referenced issue files, acceptance, verification, evidence requirements, and final sanity pass are written.

Plan Engineering Review is a gstack-style decision-hardening layer inside `pge-plan`. It catches selected-approach, issue-slicing, architecture, data-flow, edge-case, test-coverage, performance, and implementation-friction weaknesses before the plan is frozen. The Final Plan Gate is the hard authorization validator: it decides whether the plan is executable, verifiable, repo-grounded, and safe to hand to `pge-exec`.

No `PASS`, no `pge-exec`.

For MEDIUM/DEEP Architecture Delta Contracts, workflow-contract changes, artifact-schema changes, validation-contract changes, gate/tooling changes, or plans with material forbidden-zone risk, first consume `## plan_gate_inputs` as defined in `references/final-plan-gate.md`. This structured section does not authorize execution by itself; it gives the gate declared change types, required claims, evidence schemas, boundary checks, and validation reality to audit before writing the final verdict.

## Stability Protocol

Run this gate deterministically:

1. Read the current draft `plan.md` once from top to bottom.
2. Check layers in order: Contract Completeness, Source Fidelity, Plan Engineering Review, Repo Reality, Execution Readiness, Skill Execution Stability.
3. When `## plan_gate_inputs` is required or present, check it before Layer 1 and carry failures into the relevant layer.
4. Stop at the first failing layer unless later evidence is already present in the plan and directly repairs that failure.
5. Apply at most one inline repair pass per failed layer, then rerun only the failed layer and any downstream layer it affects.
6. If the same layer fails twice, stop with `REVISE`, `ESCALATE`, or `REJECT`; do not loop.
7. Use exactly the verdict vocabulary in this file. Do not invent near-synonyms such as `READY`, `APPROVED`, `WARN`, or `CONCERNS`.
8. Write `Exec Allowed: yes` only when `Verdict: PASS`; otherwise write `Exec Allowed: no`.
9. Preserve `.pge/tasks-<slug>/plan.md` as the stable canonical plan artifact and `.pge/tasks-<slug>/issues/Ixxx.md` as canonical issue-local execution contracts referenced by that plan.

This protocol is meant to keep skill execution stable. The gate must return a boring, parseable result even when the plan is messy.

## Verdicts

| Verdict | Meaning | Route effect |
|---|---|---|
| `PASS` | Plan is a complete execution contract | May route `READY_FOR_EXECUTE` or `READY_FOR_EXECUTE_WITH_ASSUMPTIONS` |
| `REVISE` | Direction is valid, but contract is incomplete or under-evidenced | Repair plan and rerun failed layers before ready route |
| `ESCALATE` | Human/challenge decision is required before a fair plan exists | Route `NEEDS_HUMAN` or `NEEDS_INFO`; exec not allowed |
| `REJECT` | Plan is wrong, unsafe, or not executable | Route `BLOCKED` or `RETURN_TO_RESEARCH`; exec not allowed |

`PASS` requires all active layers below to pass. A failed layer must record `failed_criterion`, `evidence`, `required_repair`, and `exec_allowed: no`.

## Layer 1: Contract Completeness Gate

Required fields:

- goal
- non_goals
- necessary context
- target_areas
- forbidden_areas
- vertical slices in the `## issues` Execution Index
- referenced issue files with goal, semantic plan context, change, target areas, recommended approach, forbidden boundaries, and validation
- acceptance criteria
- verification path
- evidence requirements
- stop condition
- terminal conditions / abort cases

Structured gate inputs are required here when the plan is MEDIUM/DEEP, changes workflow contracts, changes artifact schemas, changes validation contracts, changes gate/tooling behavior, or has material forbidden-zone risk. If required `plan_gate_inputs` are missing, incomplete, or contain `pending` claims without terminal handling, this layer fails with `REVISE`.

Checks:

- `## issues` is a compact Execution Index, not embedded full issue body storage.
- Every ready index row has `ID`, `File`, `Title`, `State`, `Depends On`, `Verification Coupling`, `Execution Type`, and `Security`.
- Every ready index row references an existing readable issue file under the same task directory, normally `issues/Ixxx.md`.
- Every ready issue file has the default execution fields: goal, plan_context, change, target_areas, recommended_approach, forbidden, and validation.
- Embedded full issue bodies under `plan.md ## issues` fail this layer with `REVISE`; `pge-plan` must upgrade them into issue files before execution.
- Optional fields such as source refs, risk notes, key interfaces, trigger/output predicates, caller checks, performance checks, or simplification checks are required only when the issue's risk surface makes them necessary for fair execution or verification.
- Every major acceptance criterion traces to user intent, research success shape, upstream constraint, current prompt, or necessary technical support.
- Each acceptance criterion has verification or required evidence. "Run tests" alone is insufficient unless the specific test scope proves the criterion.
- Non-goals and forbidden areas define what exec must not touch.
- Stop condition is observable enough that exec can check it without interpretation.
- Terminal conditions identify known cases where planning or execution must stop, revise, escalate, clarify, or require a human decision.
- Declared change types, required claims, evidence schemas, boundary checks, and validation reality are present when required by `references/final-plan-gate.md`.
- Each declared change type has at least one required claim or a clear `not_applicable` rationale.
- Each required claim has a concrete evidence type, required shape, provided evidence, and status.

## Layer 2: Source Fidelity Gate

This layer is mandatory when `fast_adopt: true` or when the selected source is an external plan, Claude plan-mode output, docs execution plan, or mixed source. It is `SKIP_NOT_APPLICABLE` for ordinary direct-prompt plans with no external source to preserve.

Checks:

- Source semantics are traceable into canonical fields: goal, non-goals, target areas, forbidden areas, acceptance, verification, evidence, issue behavior, and stop condition.
- Goal, success or stop condition, scope, phase boundary, semantic ownership, non-goals, and exclusions are preserved unless an explicit user-confirmed override or upstream route is recorded.
- Source implementation decisions are preserved; issue slicing may split, merge, or operationalize them but must not re-decide architecture, rollout, ownership, or phase boundaries.
- Target areas and new content are derived from source semantics, current user constraints, repo evidence, or necessary mechanical execution support. Unreferenced helpers, flags, cleanup, abstractions, validation layers, or frameworks fail this layer.
- Verification and evidence burden are not weakened. Strengthening is allowed only when it proves the same acceptance without expanding scope.
- Every ready issue has source refs sufficient to audit semantic alignment, or a compact Source Semantics Ledger covers all material source items.
- Every material source item affecting goal, scope, phase, ownership, non-goals, verification, evidence, or issue behavior is covered, explicitly omitted with reason, or escalated.
- Research problem-contract fields are preserved when present. Research blocking questions must not become Plan assumptions.

Any `no` result blocks `READY_FOR_EXECUTE`. If the failure is repairable from source text or repo evidence, repair the plan and rerun this layer. If it needs a source-scope or research-contract decision, route `NEEDS_INFO`, `NEEDS_HUMAN`, or `RETURN_TO_RESEARCH`.

## Layer 3: Plan Engineering Review

Checks:

- `### Plan Engineering Review` exists when the plan risk/depth needs an explicit record; LIGHT plans may use a compact review paragraph, short bullet list, or omit it entirely if trivial.
- Plan Engineering Review result is `PASS`, or all `REWORK_PLAN` findings have been repaired and rerun before Final Plan Gate.
- When Plan Engineering Review was performed (mandatory for MEDIUM/DEEP, optional for LIGHT), the selected approach, rejected approaches, issue slicing strategy, acceptance refinements, verification/evidence refinements, and risk handling reflect the review findings.
- For MEDIUM/DEEP issue-file plans, Plan Engineering Review includes a closed-loop issue slicing review or equivalent compact record showing each ready issue is `keep`, `split`, `merge`, or `rework`, and all `split` / `merge` / `rework` actions are resolved before this gate.
- Architecture, data flow, edge cases, test coverage, performance, failure modes, and protocol coherence were applied according to depth and relevance.
- Plan Engineering Review findings have been consumed into the plan before Final Plan Gate validation. Plan Engineering Review does not produce routes directly; only Final Plan Gate has execution authorization.
- If an external gstack `/plan-eng-review` or equivalent review was provided in current context, its findings are consumed as pressure input, but PGE still owns the final authorization verdict.
- New plan output must use `### Plan Engineering Review`.

## Layer 4: Repo Reality Gate

Checks:

- Target files/modules exist or are explicitly marked `Create`.
- Entry paths, callers, consumers, validators, config keys, registration paths, and dynamic/runtime hooks are confirmed when relevant.
- Existing code semantics are cited before the plan claims what code does or does not do.
- Legacy assumptions are labeled as assumptions, not facts.
- Hidden runtime behavior is considered for dynamic config, reflection, plugin registries, generated artifacts, feature systems, or loader paths.
- Forbidden areas are specific enough to prevent accidental scope expansion.
- Boundary checks cover allowed targets and forbidden areas when `plan_gate_inputs` are required or present.
- `negative_boundary` evidence identifies what must remain untouched or semantically unchanged when forbidden zones matter.

Repo evidence must be concrete: file paths, `file:line`, commands, config references, prior artifact evidence, or current user statements. If evidence is absent, the gate must say so.

## Layer 5: Execution Readiness Gate

Checks:

- Slices are small enough for bounded worker execution.
- The issue index is schedulable without opening every issue file.
- Selected issue files are complete enough for `pge-exec` to build a Generator brief from the issue file plus shared plan context.
- Each ready slice has a closed loop: issue-local goal, bounded change, concrete validation, and either independent verification or explicit verification coupling with a safe strategy.
- Retry/block/escalate routing is clear for likely mismatch types.
- HITL work is explicit: `HITL:verify`, `HITL:decision`, or `HITL:action`.
- Exec context pack is sufficient: issue order, eligible issues, goal, semantic plan context, change, target areas, recommended approach, forbidden boundaries, and validation.
- Parallel safety is explicit: same working tree allowed, isolated worktrees required, or serial verification required.
- Validation reality distinguishes cheap implementation feedback from final trust gates when `plan_gate_inputs` are required or present.

## Layer 6: Skill Execution Stability Gate

Checks:

- The plan uses canonical headings and fields: `## issues`, `## forbidden_areas`, `## plan_gate`, `## stop_conditions`, and `## route` with `plan_route:`.
- `## issues` uses issue-file index shape. It must not contain embedded executable issue-body fields or repeated issue-local contract blocks.
- The plan uses only fixed route/status/verdict vocabulary defined by `pge-plan`, `plan_gate`, and `pge-exec`.
- Downstream consumer expectations are satisfied: `pge-exec` can locate ready issues, blocked issues, issue file paths, goal, semantic plan context, change, target areas, recommended approach, forbidden boundaries, validation, optional risk-triggered checks, and handoff fields without interpreting prose.
- Repair loops are bounded: retry, revise, block, escalate, and human-decision paths are explicit where likely.
- Non-canonical sources are rewritten to canonical shape before execution; `pge-exec` must not interpret alias headings or missing contract fields.
- Clarification and stop paths are stable for missing evidence, ambiguous selectors, stale artifacts, plan-changing context, terminal conditions, and unavailable checks.
- The final response can report `plan_route`, `plan_gate`, `exec_allowed`, ready issues, blocked issues, assumptions, and next skill without inventing fields.
- Route/status/verdict vocabulary and schema field boundary checks pass when workflow or artifact-schema contracts are changed.

## Clarification And Terminal Handling

Planning does not treat unresolved conditions as runtime exceptions. They are confirmation, clarification, or stop triggers. Resolve them in this order:

1. Self-resolve from repo evidence, upstream artifacts, or current user text when the answer is mechanical.
2. If the answer changes goal, scope, acceptance, safety, or human judgment, clarify until the execution target is clear enough to plan fairly. Prefer the smallest question set that restores clarity, but do not artificially limit clarification to one question when multiple coupled facts are required.
3. If the condition cannot be resolved in this planning turn, map it to one gate verdict plus one plan route and record it in `## terminal_conditions`.

| Condition / terminal item | Gate Verdict | Plan Route | Exec Allowed | Handling |
|---|---|---|---|---|
| Missing required plan field that can be repaired from existing evidence | `REVISE` | no final route until repaired; `BLOCKED` if not repaired this turn | no | Repair once, rerun affected layers |
| Missing required evidence and no source can provide it | `ESCALATE` | `NEEDS_INFO` or `NEEDS_HUMAN` | no | Clarify the missing evidence or require human decision |
| Ambiguous goal, scope, or success shape | `ESCALATE` or `REJECT` | `NEEDS_INFO` or `RETURN_TO_RESEARCH` | no | Clarify until the target is clear enough, or record why upstream discovery must resume |
| Repo reality contradiction invalidates the approach | `REJECT` | `BLOCKED` or `RETURN_TO_RESEARCH` | no | Record contradiction and required upstream repair |
| Unsafe or unauthorized scope expansion is required | `ESCALATE` or `REJECT` | `NEEDS_HUMAN` or `BLOCKED` | no | Do not smuggle expansion into issues |
| Required tool/check unavailable, but alternative evidence exists | `REVISE` | no final route until plan records alternative evidence | no | Add fallback verification/evidence |
| Required tool/check unavailable and no alternative evidence exists | `ESCALATE` | `NEEDS_HUMAN` or `BLOCKED` | no | Stop before execution |
| Human-only decision remains unresolved | `ESCALATE` | `NEEDS_HUMAN` | no | Mark affected issues `NEEDS_HUMAN` |
| Selected source lacks `plan_gate`, `forbidden_areas`, or canonical headings | `REVISE` | contract upgrade through `pge-plan` | no | Fast-adopt / rewrite into canonical shape |
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
- Failed Gate: Contract Completeness | Source Fidelity | Plan Engineering Review | Repo Reality | Execution Readiness | Skill Execution Stability | none
- Failed Criterion: <criterion or "none">
- Evidence: <file:line / artifact / command / user statement / "none">
- Required Repair: <specific repair or "none">
- Rationale: <one sentence>

### Gate Checklist

| Gate | Status | Evidence | Required Repair |
|---|---|---|---|
| Contract Completeness | PASS / REVISE / ESCALATE / REJECT | <evidence> | <repair or none> |
| Source Fidelity | PASS / REVISE / ESCALATE / REJECT / SKIP_NOT_APPLICABLE | <evidence> | <repair or none> |
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

Do not create a separate `canonical-plan.md`. The stable canonical plan is `.pge/tasks-<slug>/plan.md` only after the Final Plan Gate passes; issue-local canonical execution contracts are the referenced `.pge/tasks-<slug>/issues/Ixxx.md` files.

## Canonical Shape Rules

New `plan.v2` artifacts use `## issues` as an Execution Index plus `## forbidden_areas`, `## terminal_conditions`, `## plan_gate`, `## stop_conditions`, and `## route` with a `plan_route:` value. Full issue bodies live in referenced issue files, not inside `plan.md`.

If a selected source or prior artifact is not already in canonical shape, `pge-plan` must rewrite it before execution authorization. Missing `plan_gate`, missing `forbidden_areas`, or non-canonical headings are execution-blocking contract failures until the plan is upgraded.
