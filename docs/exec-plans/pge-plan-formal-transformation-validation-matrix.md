# PGE Plan Formal Transformation Validation Matrix

## Purpose

This document is the prerequisite validation bundle for executing `docs/exec-plans/pge-plan-formal-transformation-plan.md` honestly.

It does **not** replace the canonical `pge-plan` contract and it does **not** introduce a second plan surface. Its job is to make later transformation slices reproducible by pinning:

- the prompt set for trigger and before/after checks
- the artifact assertions for canonical `plan.md`, `issues/Ixxx.md`, and `workflow-handoff.md`
- the downstream-consumer checks that protect `pge-exec` and Dynamic Workflow boundaries
- the regression checks for quality-bearing mechanisms that must not be silently weakened
- the evidence bundle required before the transformation can be called validated

## Rule Sources To Reuse

These files remain authoritative. This matrix references them; it does not restate their full semantics.

- `docs/exec-plans/pge-plan-formal-transformation-plan.md:395-575`
- `skills/pge-plan/templates/plan.md:5-181`
- `skills/pge-plan/templates/issue.md:1-41`
- `skills/pge-plan/templates/workflow-handoff.md:1-184`
- `skills/pge-plan/references/plan-gate.md:39-220`
- `skills/pge-plan/references/final-plan-gate.md:14-110`
- `skills/pge-plan/references/engineering-review.md:58-131`
- `skills/pge-plan/references/self-review.md:1-56`
- `skills/pge-exec/SKILL.md:246-294`
- `docs/adr/0001-pge-contract-authority-and-planning.md:41-85`
- `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md:48-264`

## Validation Layers

| Layer | Goal | Minimum evidence |
|---|---|---|
| Trigger / entry | `pge-plan` is easier to invoke for planning and harder to invoke for research-only or execution-only work | prompt ID, expected route/ownership, observed result |
| Before / after comparison | the revised skill visibly strengthens the 1-5 flow without reducing execution usability | before notes, after notes, delta summary |
| Artifact assertions | transformed output changes behavior and artifacts, not just wording | validator result + manual notes for non-mechanical checks |
| Downstream consumer | `pge-exec` and Dynamic Workflow can still consume the result without guesswork | consumer checklist with evidence pointers |
| Quality regression | preserved quality mechanisms remain explicit where still needed | per-mechanism pass/fail notes with evidence |

## Prompt Coverage Matrix

Use the existing eval corpus first. Add transformation-local prompts here before changing shared eval fixtures.

| Prompt ID | Validation layer(s) | Source | Prompt family / scenario | Expected result |
|---|---|---|---|---|
| T1 | Trigger, Before/after | `skills/pge-plan/evals/evals.json` id `1` | `research.v3` ready handoff -> executable planning | `pge-plan` triggers, runs Source Contract Check, forms an executable draft, and stays in plan ownership |
| T2 | Trigger, Before/after | `skills/pge-plan/evals/evals.json` ids `2`, `18` | direct prompt with mild ambiguity that still belongs in Plan | `pge-plan` asks only the minimum clarifications needed for goal/scope/acceptance/safety/authority |
| T3 | Trigger, Before/after, Regression | `skills/pge-plan/evals/evals.json` ids `7`, `15`, `19` | fast-adopt of an external plan/spec or `docs/exec-plans/` note | source semantics are preserved, contradictions are logged, and the result is rewritten into canonical plan artifacts |
| T4 | Trigger, Before/after, Regression | `skills/pge-plan/evals/evals.json` ids `8`, `21`, `22`; `skills/pge-plan/evals/joint-evals.json` `joint-6` | high-risk contract / protocol / workflow-boundary change | producer / consumer / validator coherence is explicit; route/schema/vocabulary remain canonical |
| T5 | Trigger, Before/after | `skills/pge-plan/evals/evals.json` ids `11`, `13`, `17`, `20` | execution-usable plan output with issue-file plan shape and verification coupling | the transformed skill still emits execution-usable contracts, not cleaner-but-weaker prose |
| T6 | Trigger | `skills/pge-plan/evals/evals.json` id `6`; `skills/pge-plan/evals/joint-evals.json` rows for blocked research handoff | research blocker or research-owned ambiguity | `pge-plan` refuses to absorb unresolved research-only discovery work |
| T7 | Trigger (supplemental) | local to this matrix | explicit execution-ready request such as “execute @.pge/tasks-<slug>/plan.md” | should route to `pge-exec`, not `pge-plan` |
| T8 | Trigger (supplemental) | local to this matrix | problem-discovery request such as “help me figure out the real problem/scope before planning” | should stay in `pge-research`, not `pge-plan` |
| T9 | Before/after, Regression | `skills/pge-plan/evals/evals.json` ids `9`, `10` | experience-context relevant vs internal-only plan | experience context is preserved when relevant and skipped when not applicable |
| T10 | Before/after, Regression | `skills/pge-plan/evals/joint-evals.json` `joint-7` | repo contradiction requiring explicit override logging | `Plan Grill Log` and `Decision Overrides` remain explicit and bounded |

### Current prompt-coverage decision

No shared eval fixture update is required in this prerequisite pass.

Reason:
- the current eval corpus already covers the main planning, fast-adopt, protocol, issue-file, and regression families
- the only uncovered cases are the two trigger-only should-not-trigger prompts (`T7`, `T8`)
- those two prompts are transformation-specific entry checks and can live in this validation bundle until there is a runnable prompt-comparison harness that benefits from promoting them into `skills/pge-plan/evals/*.json`

If later automation needs these cases in the shared eval harness, promote `T7` and `T8` into `skills/pge-plan/evals/evals.json` at that time.

## Artifact Assertion Matrix

Run the mechanical validator first against emitted task artifacts, then add manual notes only where semantics exceed mechanical checks. The validator is not a direct pass/fail check for raw templates with unresolved placeholders; use the template contract smoke test for raw checked-in scaffolds.

| Check ID | Artifact | Assertion | Source of truth | Evidence |
|---|---|---|---|---|
| A0 | raw checked-in templates | canonical scaffold headings and adapter-boundary phrases remain present on the checked-in templates themselves | `skills/pge-plan/templates/plan.md:5-181`; `skills/pge-plan/templates/issue.md:1-41`; `skills/pge-plan/templates/workflow-handoff.md:1-184` | template smoke test |
| A1 | emitted `plan.md` | canonical `plan.v2` headings are present | `skills/pge-plan/templates/plan.md:5-181`; `skills/pge-plan/references/plan-gate.md:136-149,216-220` | validator result |
| A2 | emitted `plan.md` | `plan_route`, `plan_gate` verdict, and `Exec Allowed` use canonical vocabulary and obey ready-route rules | `skills/pge-plan/references/plan-gate.md:28-37,206-214`; `skills/pge-plan/SKILL.md:496-507` | validator result |
| A3 | emitted `plan.md` | `## issues` is an Execution Index with required fields, not embedded full issue bodies | `skills/pge-plan/templates/plan.md:48-64`; `skills/pge-plan/references/plan-gate.md:60-65` | validator result |
| A4 | emitted `issues/Ixxx.md` | every referenced issue file exists and has required default sections | `skills/pge-plan/templates/issue.md:1-41`; `skills/pge-plan/references/plan-gate.md:61-65` | validator result |
| A5 | emitted `plan.md` + issue files | issue index / file linkage is consistent, dependencies resolve, and non-independent verification coupling carries referenced issues plus safe verification semantics | `skills/pge-plan/templates/plan.md:52-64`; `skills/pge-plan/references/plan-gate.md:124-149`; `skills/pge-exec/SKILL.md:252-257` | validator result |
| A6 | emitted `workflow-handoff.md` | handoff remains adapter-only, points back to canonical `plan.md`, and preserves issue-order / dependency / verification-coupling semantics without becoming a scheduler spec | `skills/pge-plan/templates/workflow-handoff.md:9-59,125-184` | validator result + manual spot-check |
| A7 | `plan.md` | explicit repo-aware draft state is visible before hardening | `docs/exec-plans/pge-plan-formal-transformation-plan.md:475-485` | manual artifact notes |
| A8 | `plan.md` | `plan-eng-review` visibly changes approach, slicing, verification, or contradictions | `docs/exec-plans/pge-plan-formal-transformation-plan.md:478-480`; `skills/pge-plan/references/engineering-review.md:69-131` | manual comparison notes |
| A9 | `plan.md` + `workflow-handoff.md` | backend-agnostic execution-contract wording does not erase current consumer needs | `docs/exec-plans/pge-plan-formal-transformation-plan.md:480-483`; `docs/adr/0001-pge-contract-authority-and-planning.md:43-76` | manual comparison notes |

## Downstream Consumer Checklist

| Check ID | Consumer | Question | Source of truth | Evidence |
|---|---|---|---|---|
| D1 | `pge-exec` | does the plan still expose `plan_route`, `plan_gate`, issue-file shape, stop conditions, target areas, and forbidden areas in the form `pge-exec` validates before lane creation? | `skills/pge-exec/SKILL.md:246-267` | checklist notes + validator output |
| D2 | `pge-exec` | can `pge-exec` still build `plan_context_packet` from the canonical plan without guessing? | `skills/pge-exec/SKILL.md:269-294` | checklist notes |
| D3 | Dynamic Workflow | does `workflow-handoff.md` still preserve issue numbering, `Depends On`, and `Verification Coupling` as execution hints rather than a fixed DAG? | `skills/pge-plan/templates/workflow-handoff.md:27-59` | checklist notes + validator output |
| D4 | Dynamic Workflow | does the handoff still force `plan.md` to remain the canonical alignment source and `workflow-result.md` to remain evidence backflow only? | `skills/pge-plan/templates/workflow-handoff.md:125-184`; `docs/adr/0001-pge-contract-authority-and-planning.md:63-85` | checklist notes |
| D5 | contract authority | does the transformed result avoid moving orchestration into the plan or creating a second canonical artifact? | `docs/adr/0001-pge-contract-authority-and-planning.md:54-60` | manual review notes |

## Quality Regression Matrix

Use the existing preservation review as the baseline inventory; do not build a second one.

| Mechanism | Why it matters | Source | Evidence required |
|---|---|---|---|
| authority / confirmation handling | prevents silent scope/authority drift | `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md:91-106`; `skills/pge-plan/SKILL.md:575-586` | before/after notes showing preserved behavior |
| `Plan Grill Log` | keeps contradictions and repairs explicit | `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md:225-230`; `skills/pge-plan/references/engineering-review.md:111-131` | artifact note showing when and how it appears |
| `Decision Overrides` | records bounded scope exceptions or authoritative overrides | `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md:232-235`; `skills/pge-plan/SKILL.md:477-482,514-515` | artifact note showing preserved field/section |
| `Self-Evaluation` | keeps decision classification and escalation boundaries visible | `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md:237-241`; `skills/pge-plan/references/self-review.md:1-56` | before/after notes |
| fast-adopt semantic fidelity | prevents silent replanning of adopted sources | `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md:130-145`; `skills/pge-plan/evals/evals.json:67-75` | fast-adopt comparison note |
| acceptance / verification trace | keeps execution proof tied to source semantics | `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md:221-222`; `skills/pge-plan/templates/plan.md:70-85` | artifact note showing trace survives |
| verification coupling / parallel safety | protects downstream execution safety | `docs/exec-plans/pge-plan-quality-preservation-alignment-review.md:149-165`; `skills/pge-plan/SKILL.md:537-565` | artifact note + downstream checklist |

## Evidence Bundle Required Before Declaring Success

Capture this bundle for each later transformation slice:

1. **Prompt set used**
   - prompt IDs from this matrix
   - exact prompts or stable prompt references

2. **Before / after comparison**
   - current-skill output notes
   - revised-skill output notes
   - short delta summary per prompt family

3. **Artifact assertions**
   - validator JSON output
   - any manual assertion notes for non-mechanical checks

4. **Downstream-consumer observations**
   - `pge-exec` consumption notes
   - workflow-handoff adapter-boundary notes

5. **Regression disposition**
   - regressions found
   - whether they were repaired immediately or consciously accepted with rationale

Recommended local entrypoint for this bundle:
- `bin/test-pge-plan-validation-suite.sh`

If any of those five evidence groups are missing, the transformation remains a proposal rather than a validated contract change.

## Execution Notes For The Prerequisite Pass

- Keep the validator mechanical and bounded.
- Prefer this matrix plus one validator/test pair over a broader prerequisite framework.
- Do not treat sampled historical `.pge/tasks-*` artifacts as positive fixtures unless they are first confirmed against the current `plan.v2` contract.
- Use `bin/fixtures/pge-plan-artifacts/current-plan-v2/` as the checked-in current-contract emitted fixture for validator smoke checks; historical `.pge/tasks-*` directories remain legacy samples unless explicitly migrated.
- Revisit shared eval updates only after a runnable prompt-comparison harness exists or the supplemental trigger cases prove stable enough to promote.