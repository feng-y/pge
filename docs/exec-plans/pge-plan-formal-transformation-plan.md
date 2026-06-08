# PGE Plan Formal Transformation Plan

## Goal

Transform `pge-plan` so its high-level structure, contract surface, and emitted artifacts match the agreed model:

1. consume `research` or other valid planning source
2. understand intent / requirements and clarify if necessary
3. bind the request to repo reality and produce an executable draft approach
4. use `plan-eng-review` to harden that draft into a real executable plan
5. emit issues / handoff shape so an execution backend can consume it

This plan assumes the following decisions are locked:

| Question | Selected answer |
|---|---|
| `pge-plan` high-level identity | executable solution-design stage |
| main sequence | source -> understand/clarify -> repo-aware draft -> plan-eng-review hardening -> emit issues/handoff |
| plan clarification scope | one normalized round of minimal plan-level clarification (may include the minimum coupled question set when one question is insufficient) |
| clarification boundary | only for approach / acceptance / verification / issue slicing questions |
| draft stage | explicit, not implicit |
| `plan-eng-review` role | center-stage hardening pass, not optional polish |
| execution contract target | backend-agnostic shared execution contract |
| `pge-exec` role | self-orchestrated workflow backend |
| Dynamic Workflow role | execution backend candidate that can replace `pge-exec` when cost/fit is right |
| `workflow-handoff.md` | launch adapter, not second plan |
| debt handling | harmful / wrong / consumerless debt should be corrected in the current slice; shared/high-risk weakening still requires validator-aware discipline |

## Non-Goals

- Do not collapse `pge-research`, `pge-plan`, and execution backends into one skill.
- Do not turn `workflow-handoff.md` into a second canonical plan.
- Do not weaken planning quality, source fidelity, verification coupling, or authorization just to reduce file size.
- Do not start by optimizing for `pge-exec`-specific consumption if the same semantics can be expressed as shared backend contract.
- Do not postpone clearly harmful historical debt merely because it is old.

## Primary Diagnosis

The current `pge-plan` is not weak on capability. Its main problems are structural:

1. **Main process visibility is misweighted**
   - source adaptation and output/handoff surfaces are more visible than plan formation and hardening.

2. **`plan-eng-review` is under-positioned conceptually**
   - it already functions like the plan hardening center, but it can still be read as a late review layer.

3. **The contract is conceptually dual-backend, but still phrased too `pge-exec`-first**
   - ADR already treats `pge-exec` and Dynamic Workflow as execution backends.
   - `pge-plan` still contains wording and output framing that feel more like "first satisfy `pge-exec`, then adapt to workflow".

4. **Presentation and doctrine are mixed into owner-flow**
   - core functions, references, review semantics, gate detail, and output ceremony are too interleaved.

5. **Historical debt must be classified, not blindly preserved**
   - some sections may be quality-bearing and must stay.
   - some may be output ceremony or owner-confusing debt and should be removed or demoted now.

## Target High-Level Model

After transformation, `pge-plan` should read like this:

### Stage identity

`pge-plan` converts a stable problem contract into a stable execution contract.

### Internal progression

```text
validated source
-> intent/scope/acceptance clarification
-> repo-aware executable draft
-> plan-eng-review hardening
-> backend-agnostic plan contract
-> backend adapter(s) when needed
```

### Output model

- `plan.md` is the canonical shared execution contract
- `issues/Ixxx.md` are issue-local execution contracts
- `workflow-handoff.md` is an adapter for Dynamic Workflow, not a second planning surface
- `pge-exec` consumes the same contract as a heavyweight self-orchestrated workflow backend

## Current Strict State

This section locks down what is already strict in the current contract, so the transformation does not confuse "reframing" with "rewriting reality."

### 1. Current role and stage boundary

Today, `pge-plan` already strictly owns:

- conversion from inherited/current intent to executable logic
- approach selection
- issue slicing
- verification topology
- evidence requirements consumable by execution backends

It does **not** own:

- broad problem rediscovery when Research is still unstable
- implementation/runtime orchestration
- runtime repair loops
- second-plan generation

Evidence:
- `docs/adr/0001-pge-contract-authority-and-planning.md:41-61`
- `skills/pge-plan/SKILL.md:24-38`

### 2. Current PER vs Final Plan Gate relationship

Today, the relationship is already strict:

- `Plan Engineering Review` = decision-hardening layer
- `Final Plan Gate` = execution authorization validator

PER is mandatory for MEDIUM/DEEP and optional for LIGHT, but it is **not** the execution gate.
Ready routes still require `Verdict: PASS` and `Exec Allowed: yes`.

Evidence:
- `skills/pge-plan/SKILL.md:468-495`

### 3. Current execution-backend model

Today, ADR already defines:

- `pge-exec` and Dynamic Workflow are execution backends
- `pge-plan` must produce evidence requirements that both can satisfy without guessing

So the transformation is not inventing a new backend-agnostic direction from zero; it is clarifying and strengthening a direction that already exists.

Evidence:
- `docs/adr/0001-pge-contract-authority-and-planning.md:52-53, 63-85`

### 4. Current output and handoff strictness

Today, these are already strict and contract-bearing:

- canonical `plan.md`
- canonical issue-file execution contracts under `issues/Ixxx.md`
- `## issues` as Execution Index, not embedded issue bodies
- verification coupling and execution-order semantics
- `workflow-handoff.md` as launch adapter only, not second plan

Evidence:
- `skills/pge-plan/SKILL.md:64-66, 646-714, 744-774`
- `skills/pge-plan/templates/plan.md:48-181`
- `skills/pge-plan/templates/workflow-handoff.md:3-41`

### 5. Current output visibility is not merely cosmetic

The current output surface is already partly an execution-safety surface.
So when this plan says output/handoff is "too visible," it does **not** mean those fields are low-value. It means their visibility currently distorts the perceived center of gravity of the skill.

That distinction is strict and must be preserved.

## Immediate Debt Removal Criteria

This plan explicitly allows fixing or removing harmful debt in the current slice, but only when the debt meets at least one of these criteria and does not violate a stronger active consumer:

1. **Consumerless**
   - no active downstream skill, template, eval, or documented review surface depends on it

2. **Owner-confusing**
   - it makes `pge-plan` look like it owns Research or execution responsibilities it should not own

3. **Redundant with stronger canonical structure**
   - the same function is already carried more clearly and more authoritatively elsewhere

4. **Quality-negative**
   - it increases drift, ambiguity, or false confidence rather than preventing it

5. **Replacement path is explicit**
   - removal/demotion is paired with a clear stronger replacement in the same slice

If these are not true, and the field/section still has shared or high-risk consumers, use validator-aware discipline before weakening.

## Field Classification Preview

This is not the final field migration table. It is a preview to prevent the plan from staying too abstract.

### A. Likely shared execution contract fields

These appear likely to remain core for any execution backend:

- `goal`
- `non_goals`
- `target_areas`
- `forbidden_areas`
- `acceptance`
- `verification`
- `evidence_required`
- `issues`
- issue-local `goal/change/target_areas/recommended_approach/forbidden/validation`
- `Depends On`
- `Verification Coupling`
- `stop_conditions`
- `terminal_conditions`
- `plan_gate`

### B. Likely `pge-exec`-historical-shape-biased fields or phrasings

These likely need review for whether they are truly shared contract or just current `pge-exec` consumption shape:

- explicit "lets `pge-exec` implement without guessing" style wording
- some `Handoff To Execute` phrasing and summary fields
- some execution-type and scheduling phrasing that may be too bound to current `pge-exec` control-plane expectations

### C. Likely workflow-adapter-only fields

These should remain adapter/backend specific rather than being promoted into canonical plan contract:

- workflow launch prompt wording
- workflow-specific result/report expectations beyond shared evidence semantics
- workflow runtime autonomy guidance
- workflow-specific provenance/result formatting beyond what shared downstream evidence actually requires

## Transformation Principles

### 1. Re-center around process, not output

The skill should first explain:
- what understanding work happens
- what draft formation happens
- what hardening happens

Only after that should it explain:
- artifact structure
- issue emission
- workflow handoff

### 2. Make `plan-eng-review` the conceptual center

`plan-eng-review` should be described as:
- the stage that closes the gap between intended solution and repo/architecture reality
- the stage that hardens issue slicing and verification topology
- the stage that turns an executable draft into a plan the backend can trust

It should not be framed as a mere add-on review step.

### 3. Separate shared execution contract from backend-specific adapters

The transformation must classify plan output fields into three buckets:

| Bucket | Meaning |
|---|---|
| Shared execution contract | needed by any execution backend |
| `pge-exec` historical shape | primarily driven by `pge-exec`'s current consumer structure |
| workflow adapter-only | only needed to launch or report Dynamic Workflow |

The plan should progressively move toward bucket 1 being primary.

### 4. Preserve strict boundaries

- `pge-plan` may do one round of minimal plan-level clarification.
- It must not re-open broad problem discovery that belongs to Research.
- It must not absorb execution orchestration or runtime repair behavior that belongs to execution backends.

### 5. Remove harmful debt now when evidence is clear

If a section/field is shown to be:
- owner-confusing
- consumerless
- redundant with stronger canonical structure
- quality-negative

then the current slice should correct or remove it.

Do not hide behind "fix later" when the debt is already understood.

## Planned Transformation Phases

## Phase 1 — Reframe the skill around the real 1-5 process

### Objective
Make the high-level narrative and section order match the agreed planning sequence.

### Target areas
- `skills/pge-plan/SKILL.md`
- supporting summary text in `templates/plan.md` if needed

### Work
- Reorder the high-level reading flow so the first thing a reader sees is the planning process, not the artifact schema.
- Introduce an explicit distinction between:
  - source intake
  - minimal clarification
  - executable draft formation
  - `plan-eng-review` hardening
  - output emission
- Demote output/handoff explanation so it follows the planning core.

### Acceptance
- A maintainer reading the first screens of `SKILL.md` can explain the 1-5 flow without first talking about issue tables or handoff files.
- `plan-eng-review` is visibly central.
- Artifact emission appears as the result of planning, not the definition of planning.

## Phase 2 — Make the draft stage explicit

### Objective
Expose the repo-aware executable draft as a real internal stage.

### Target areas
- `skills/pge-plan/SKILL.md`
- possibly `references/engineering-review.md`
- possibly `templates/plan.md` if an explicit draft-to-final trace is useful

### Work
- Name the transition from input understanding to executable draft explicitly.
- Clarify what the draft must already contain before `plan-eng-review` begins:
  - initial approach
  - repo-grounded scope
  - early slicing intuition
  - preliminary verification story
- Clarify that `plan-eng-review` hardens this draft rather than inventing a plan from nothing.

### Acceptance
- The plan process distinguishes "draft created" from "plan hardened".
- Readers can tell why `plan-eng-review` exists and what it is hardening.

## Phase 3 — Reposition `plan-eng-review` as the plan center of gravity

### Objective
Make `plan-eng-review` clearly own gap-closing and hardening.

### Target areas
- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/references/engineering-review.md`
- `skills/pge-plan/references/engineering-review-gate.md`

### Work
- Rewrite the high-level description of PER so it is centered on:
  - closing intended-solution vs repo/architecture gap
  - hardening slicing
  - hardening verification topology
  - exposing plan drift before authorization
- Ensure LIGHT / MEDIUM / DEEP scaling remains, but without making LIGHT look like PER does not matter.
- Reduce any wording that makes PER feel like an afterthought compared with source handling or artifact output.

### Acceptance
- PER is no longer easy to misread as "late polish".
- MEDIUM/DEEP still require full PER.
- LIGHT retains a proportional but conceptually real PER path.

## Phase 4 — Reclassify the output contract as backend-agnostic

### Objective
Shift `pge-plan` from `pge-exec`-first wording toward shared backend contract wording.

### Target areas
- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/templates/plan.md`
- `skills/pge-plan/templates/workflow-handoff.md`
- `skills/pge-exec/SKILL.md` only if consumer alignment forces same-slice updates

### Work
- Audit plan fields into:
  - shared execution contract
  - `pge-exec` historical shape
  - workflow adapter-only shape
- Rewrite top-level plan wording so the canonical contract is described for execution backends generally, not just `pge-exec`.
- Keep `workflow-handoff.md` adapter-only.
- Preserve compatibility for `pge-exec` while reducing unnecessary `exec`-first framing.

### Acceptance
- The plan contract reads as execution-backend agnostic.
- `pge-exec` remains a valid backend consumer.
- Dynamic Workflow remains an adapter-based backend, not a second plan surface.

## Phase 5 — Clarify what is core, what is structure, what is debt

### Objective
Classify sections so future simplification is evidence-based.

### Target areas
- `skills/pge-plan/SKILL.md`
- `templates/plan.md`
- references / docs where duplication exists

### Work
- Split surfaces into:
  - primary core
  - supporting core
  - presentation/structure layer
  - debt candidates
- For debt candidates, decide whether they are:
  - actively consumed
  - quality-bearing
  - mere ceremony
  - harmful confusion
- Remove or demote obviously harmful/consumerless items now if evidence is sufficient.

### Acceptance
- Future refactors can distinguish between deleting a function and moving its presentation.
- Known-bad debt is not artificially preserved.

## Phase 6 — Add validators for shared/high-risk weakening decisions

### Objective
Protect shared/high-risk contract changes with mechanical checks.

### Target areas
- validator location under `bin/` or equivalent
- `templates/plan.md`
- `templates/workflow-handoff.md`
- cross-surface contract docs if needed

### Work
- Add or design validators for:
  - canonical plan headings / gate invariants
  - issue-file linkage
  - workflow-handoff invariants
  - route/vocabulary/doctrine consistency where practical
- Use these validators before weakening shared or high-risk surfaces.
- Do not wait on validators to remove debt that is already clearly wrong and consumerless.

### Acceptance
- Shared/high-risk simplification no longer depends on guesswork.
- Validator coverage protects backend-agnostic contract evolution.

## Validation And Test Plan

This transformation is not considered complete based on document edits alone. Each material change to `pge-plan` must be validated against the current skill, not only described as an intended improvement.

### Validation principle

For this transformation, "done" means:

1. the contract change is written
2. the changed skill behavior is exercised on representative prompts
3. downstream plan artifacts are checked for the intended semantics
4. regressions against existing quality mechanisms are explicitly checked

No phase closes on "the wording looks better" alone.

### Validation layers

#### 1. Trigger and entry validation

Validate that the revised skill is easier to invoke at the right time and harder to invoke at the wrong time.

Use a small should-trigger / should-not-trigger set covering at least:
- `research.v3` handoff that is ready for executable planning
- direct prompt that needs plan-level clarification but not Research rediscovery
- explicit external plan/spec suitable for fast-adopt
- `docs/exec-plans/` sourced planning note that should become canonical `.pge/tasks-<slug>/plan.md`
- execution-ready request that should go to `pge-exec`, not `pge-plan`
- problem-discovery request that should stay in `pge-research`, not `pge-plan`

Validation target:
- `pge-plan` triggers for plan formation tasks
- does not absorb Research-only discovery work
- does not absorb execution-only implementation work

#### 2. Before/after skill comparison

For each major slice, compare the current `pge-plan` skill against the revised version on the same prompt set.

Representative prompt families must include at least:
- `research.v3` source -> executable plan
- direct prompt with mild requirement ambiguity
- fast-adopt of an external plan/spec
- `docs/exec-plans/` source adoption
- high-risk contract / protocol / workflow-boundary change
- trivial LIGHT task

Validation target:
- the revised skill expresses the 1-5 process more clearly
- repo-aware draft formation is explicit
- `plan-eng-review` visibly hardens the draft
- the output is still execution-usable, not merely more elegant prose

#### 3. Artifact-level contract assertions

Inspect produced plan artifacts and verify that they show the intended contract changes.

At minimum, check that produced artifacts make these visible:
- source intake and inherited requirement boundaries
- minimal clarification only when goal/scope/acceptance/safety/authority require it
- explicit repo-aware executable draft state before hardening
- `plan-eng-review` impact on selected approach, slicing, verification, or contradictions
- canonical `plan.md` + issue-file execution contracts
- backend-agnostic execution-contract wording
- `workflow-handoff.md` remains adapter-only rather than becoming a second plan

Validation target:
- the transformed skill changes behavior and artifacts, not just explanation text

#### 4. Downstream consumer validation

Validate that the resulting plan is easier for execution backends to consume without guessing.

Check at least:
- `pge-exec` can consume the produced `plan.md` / issue files without needing major plan-gap recovery
- Dynamic Workflow consumption still depends on canonical `plan.md`, with `workflow-handoff.md` as launch adapter only
- issue ordering, dependency semantics, and verification coupling remain usable by downstream execution

Validation target:
- the plan is genuinely more execution-consumable, not merely more backend-agnostic in wording

#### 5. Quality-regression validation

Explicitly check that the transformation does not silently remove existing quality mechanisms that still carry value.

At minimum, regression-check:
- authority / confirmation handling
- `Plan Grill Log`
- `Decision Overrides`
- `Self-Evaluation`
- Experience / acceptance / verification trace when relevant
- fast-adopt semantic fidelity
- verification coupling / parallel safety semantics

Validation target:
- quality-preserving reorganization, not hidden weakening

### Validation evidence required before calling the transformation successful

Before this plan is considered delivered, capture evidence for:
- the prompt set used for trigger / comparison testing
- before/after outputs or equivalent comparison notes
- artifact checks against the contract assertions above
- downstream-consumer observations for `pge-exec` and workflow handoff
- any regressions found and how they were repaired or accepted

If this evidence is missing, the work remains a proposal, not a validated transformation.

## Current Open Architectural Question

This transformation plan deliberately leaves one question open for a later pass, because it depends on consumer audit and contract classification:

> Which current `plan.md` fields are truly shared execution contract, and which are historical `pge-exec` shape that should be reduced or adapted?

This question should be answered during Phase 4, not before.

## Risks

- Over-correcting toward backend-agnostic language could accidentally underspecify what current consumers need.
- Re-centering PER could make source-intake constraints harder to find if ingress sections are pushed too far down.
- Debt removal done too aggressively could erase human-audit or eval-bearing surfaces that still matter.
- Validator work could lag behind contract changes, creating a temporary gray zone.

## Success Criteria

- The first read of `pge-plan` clearly reflects the 1-5 process.
- `plan-eng-review` is visibly the center of plan hardening.
- The current strict state is explicit enough that the transformation does not rewrite reality while trying to improve presentation.
- The canonical plan contract is described as shared execution contract first.
- `workflow-handoff.md` remains adapter-only.
- Clearly harmful/consumerless debt is corrected in the current transformation, not postponed indefinitely.
- Future weakening/removal discussions are structured by core/supporting/structure/debt classification and validator-aware discipline.
- The document contains at least a preview of field-level shared-contract vs backend-shaped distinctions, so execution planning is not forced to start from pure abstraction.
- The transformation is backed by explicit trigger, before/after, artifact, downstream-consumer, and regression validation evidence rather than intent statements alone.

## Recommended Next Step

This document is now intended to be a consistent formal transformation-plan note under `docs/exec-plans`. It is still not yet the canonical `.pge` execution plan, but it should be stable enough to seed one.

Recommended follow-up path:

1. adopt this plan through `pge-plan`
2. materialize a canonical `.pge/tasks-<slug>/plan.md`
3. execute the first slices in this order:
   - reframe the 1-5 high-level flow
   - make the draft stage explicit
   - reposition `plan-eng-review`
   - classify shared contract vs backend-specific adapter layers
   - remove proven harmful debt where evidence is sufficient
   - add validator scaffolding for shared/high-risk weakening decisions
4. after each material slice, run the validation layers above instead of treating the edit itself as proof:
   - trigger / entry check
   - before/after skill comparison
   - artifact-level contract assertion check
   - downstream-consumer check
   - regression check for preserved quality mechanisms

At that point, the implementation plan should be concrete enough to decide exact field migrations and section-level restructuring without falling back into broad abstract debate.
