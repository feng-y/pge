# PGE Plan Responsibility Realignment Plan

## Goal

Rework `pge-plan` to match the updated Research contract. Research is already updated and is the current truth, so this plan does not preserve old Research compatibility paths.

The intended stage boundary is:

```text
Research: stabilize what problem is being solved.
Plan: design the AI-stable execution path.
Exec: perform bounded evidence-driven implementation.
Review/Challenge: validate correctness, drift, and robustness.
```

Plan's job is to decide how to implement, how to slice, how to verify, and how to reduce Exec friction inside the Research problem contract.

This plan updates the Plan contract surface and protocol-adjacent documentation only. It should not change implementation code outside the PGE workflow contracts unless protocol consistency requires it.

## Plan Core Responsibility

`pge-plan` is responsible for executable solution design, not renewed problem discovery and not code implementation.

Plan must produce an executable, incrementally verifiable implementation contract for `pge-exec`.

Plan owns:

- implementation-path decisions
- approach selection
- architecture-friction reduction
- issue slicing as execution graph design
- execution ordering
- verification topology
- migration or rollout sequencing when relevant
- blast-radius minimization
- protocol coherence strategy
- execution ergonomics

Plan must:

- create executable contracts for `pge-exec`
- define bounded vertical slices
- minimize implementation complexity, risk, and blast radius
- derive acceptance and verification from inherited success shape
- preserve decision traceability from Research/user intent to issues and evidence
- enable incremental execution or rollout when the task has migration, product, protocol, or architecture risk
- make implementation direction, ordering, verification coupling, and proof requirements explicit enough that Exec does not invent scope

Plan must not:

- reopen Research problem discovery
- redefine Research goal, scope, success shape, non-goals, or constraints
- perform open-ended architecture redesign
- optimize for ideal architecture over the requested bounded outcome
- redesign unrelated systems
- introduce speculative abstractions, helpers, flags, frameworks, or cleanup work without source authorization
- write implementation code or line-level implementation instructions unless required by a public/protocol contract
- hide implementation uncertainty behind vague issue text

## Implementation Path Explicitness

Plan specifies implementation path at the contract level, not at the coding level.

Plan must make explicit:

- selected approach and why it satisfies the inherited problem contract
- rejected approaches and why they are worse for this slice
- target areas and ownership boundaries
- forbidden areas and out-of-scope behavior
- issue order, dependencies, and verification coupling
- migration, rollout, rollback, or compatibility strategy when relevant
- first trustworthy verification point when issue-by-issue verification is not possible
- evidence `pge-exec` must produce to prove completion

Plan must not specify:

- exact code edits unless the public/protocol contract requires a named symbol, file, field, or command
- speculative helper functions, abstractions, flags, or cleanup work
- implementation details that can be safely resolved by repo convention during execution
- test internals beyond verification intent and required evidence

Rule of thumb:

```text
Plan must remove ambiguity about direction, scope, ordering, and proof.
Plan must not pre-write the implementation.
```

## Research Contract Override Rule

When Research has `route: READY_FOR_PLAN`, Plan inherits the Research problem contract as authoritative.

Plan may challenge and change:

- `simplest_direction`
- selected implementation approach
- issue slicing
- migration shape
- rollout safety
- execution topology
- verification strategy

Plan may operationalize Research conclusions into executable acceptance, target areas, issue boundaries, and verification as long as it does not change their semantic meaning.

Plan must not silently override:

- `goal`
- `success_shape`
- `scope`
- `non_goals`
- `constraints`
- `Implementation Friction.required_plan_adjustment`
- `Progressive Feasibility.first_plannable_objective`

If Plan finds evidence that a Research conclusion is wrong, stale, unsafe, or not executable, it must record the conflict and route to `NEEDS_INFO`, `NEEDS_HUMAN`, or `RETURN_TO_RESEARCH`. It must not produce `READY_FOR_EXECUTE` until the problem-contract change is confirmed.

Research blocking questions must not become Plan assumptions.

## Reality Extraction Boundary

Do not add a separate persisted Reality Extraction artifact in this slice unless a future plan explicitly creates a new stage. Fold bounded repository/runtime truth extraction into Plan's exploration responsibilities.

Plan should gather only the repository/runtime truth needed for execution-path design:

- actual runtime paths
- protocol producer/consumer/validator surfaces
- coupling hotspots
- verification constraints
- migration blockers
- rollout or rollback constraints
- ownership boundaries
- dependency and execution-risk shape

This evidence supports Plan decisions. It must not become open-ended architecture research.

## Plan Engineering Review

Rename and reposition the old engineering-review gate as `Plan Engineering Review`.

`Plan Engineering Review` is not another hard gate. It is Plan's decision-hardening mechanism for reducing Exec friction by clarifying and improving the implementation plan after the goal is aligned.

### Trigger Conditions

Plan Engineering Review is:

- **Mandatory** for MEDIUM/DEEP plans (multi-issue, architecture changes, protocol surfaces, migration, rollout sequencing)
- **Optional** for LIGHT plans (single-issue, low-risk, existing patterns)
- **Findings must be consumed** into selected approach, issues, acceptance, verification, and risks before Final Plan Gate validation

Inputs:

- current Research problem contract
- candidate approaches
- repo/runtime evidence
- implementation friction
- progressive feasibility notes
- current user constraints

Outputs:

- selected approach
- rejected approaches
- required plan adjustments
- issue slicing strategy
- acceptance refinements
- verification and evidence refinements
- rollout, rollback, migration, or stop-condition notes

Evidence gathered during Plan exploration (runtime paths, protocol surfaces, coupling hotspots, verification constraints, migration blockers) should be embedded in the Plan Engineering Review section or approach rationale. Evidence is ephemeral unless it directly informs a decision that must be traceable.

It should absorb:

- Superpowers: reason backward from the real goal instead of producing checklist plans.
- GSD: every slice has action, done state, and verification.
- Compound Engineering: identify producer, consumer, validator, and evidence for protocol surfaces.
- Matt-style execution contracts: issues are behavior contracts, not micro-task lists.
- gstack `plan-eng-review`: reuse existing code, reduce complexity, clarify boundaries, find failure modes, and strengthen test strategy.
- Grill: challenge selected approach for scope drift, hidden assumptions, weak verification, and missing evidence.

### Depth Scaling

- LIGHT: compact check for existing-code reuse, minimum scope, selected approach rationale, and verification sanity.
- MEDIUM: approach tradeoffs, issue slicing, boundaries, failure modes, rollout shape, and verification topology.
- DEEP: architecture transition, protocol coherence, migration safety, parallel execution safety, rollout sequencing, data-flow constraints, and verification coupling.

Findings normally repair Plan inline. Upstream routing happens only when the Research problem contract must change or user authority is required.

### Routing Authority

Plan Engineering Review does not produce routes directly. It produces findings that Plan consumes. Only Source Contract Check and Final Plan Gate have routing authority. If Plan Engineering Review discovers that the Research contract is unexecutable, unsafe, or requires goal/scope changes, Plan must surface this as a Final Plan Gate rejection with route to `RETURN_TO_RESEARCH`, `NEEDS_INFO`, or `NEEDS_HUMAN`.

### Minimum Shape

For LIGHT plans, `Plan Engineering Review` may be a compact paragraph or short bullet list, or omitted entirely if the plan is trivial.

For MEDIUM/DEEP plans, it should explicitly record:

- depth
- selected approach
- rejected approaches
- complexity/risk reduction
- verification strategy
- scope drift check
- result: `PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO`

`Plan Engineering Review` must not become a new mandatory long template. Its size should scale with implementation risk.

## Issue Slicing And Verification Topology

Issue slicing is execution graph design, not task breakdown.

Good issue slices are:

- bounded
- locally verifiable when possible
- low coupling
- rollback-safe where relevant
- execution-order aware
- migration-aware when relevant
- evidence-producible
- context-local

Each ready issue must define:

- behavior delta
- target areas
- forbidden or out-of-scope areas
- acceptance criteria
- verification hint
- required evidence
- dependencies
- verification coupling (see below)
- AFK/HITL classification
- risks
- state

### Verification Coupling

Verification coupling classifies how issues can be verified:

- **independent**: issue can be verified in isolation (tests pass, behavior observable)
- **coupled**: multiple issues must complete before verification is trustworthy
- **serial**: issues must be verified in order (later issues depend on earlier verification)
- **integration-only**: no meaningful verification until final integration point

For coupled or integration-only verification, Plan must identify the first trustworthy verification point.

Plan must classify:

- independently verifiable work
- coupled verification groups
- serial execution requirements
- isolated-worktree requirements
- parallel-safe execution groups
- first trustworthy verification point
- final integration verification point

Plan must not imply independent execution when verification is shared.

## Gate Simplification

Reduce gate-stack friction while preserving execution authorization.

Hard route/authorization points:

1. `source_contract_check`: input is plan-ready or not.
2. Final `plan_gate`: `pge-exec` may run or not.

Intermediate mechanisms should repair or harden Plan, not act as independent route authorities:

- Plan Engineering Review
- Coverage Audit
- Experience Context Check
- Inconsistency Grill
- Self-Review / sanity pass

`plan_gate` remains mandatory:

- `Verdict: PASS`
- `Exec Allowed: yes`
- evidence that issue contracts, acceptance, verification, target areas, forbidden areas, terminal conditions, and route are executable

No plan may route `READY_FOR_EXECUTE` only because Plan Engineering Review passed. Final Plan Gate remains the execution authorization validator.

## Template Burden Controls

The Plan template should get lighter by default, not merely rename old gate ceremony.

Default generated plans should avoid:

- numeric quality ratings
- `10/10` bars
- always-visible deep gate tables
- fixed DOT-style state-machine ceremony
- repeated route decisions from multiple intermediate gates
- mandatory design or experience sections when irrelevant

Default generated plans should keep:

- source readiness decision
- selected approach and rejected approaches
- issue contracts
- acceptance and verification
- evidence requirements
- risks and terminal conditions
- final `plan_gate`
- handoff-to-execute metadata

Optional sections should appear only when they reduce execution ambiguity, preserve a material decision, or expose a meaningful risk.

## Preserve Plan/Exec Contract

Keep these current Plan outputs unchanged unless a later schema migration is explicitly planned:

- `.pge/tasks-<slug>/plan.md`
- `schema_version: plan.v2`
- `plan_route`
- `plan_gate`
- `## issues`
- ready issue states
- behavior contracts / behavior delta
- target areas
- forbidden areas
- acceptance criteria
- verification hints
- verification type
- verification coupling
- evidence required
- dependencies
- risks
- terminal conditions
- handoff-to-execute metadata

`pge-exec` must still validate `plan_gate PASS + Exec Allowed yes` before execution.

If the template removes visual ceremony, it must preserve these semantic fields. If implementation discovers `pge-exec` directly parses an old heading that Plan wants to rename, either preserve that heading as an alias or update Exec in the same protocol-consistency slice.

## No Research Compatibility Work

Because Research has already been updated, do not preserve old Research adapters as part of this plan.

Remove or downgrade old Plan text that treats these as current Research contract surfaces:

- `research.v2`
- `planning_handoff`
- `Plan Delta` / `plan_delta`
- old `confirmed_intent` / `scope_contract` wording when presented as current

If old names remain anywhere, they should be marked as obsolete historical references or removed, not maintained as active compatibility behavior.

## Engineering Review Naming

Use `Plan Engineering Review` as the current semantic name.

Do not preserve `Engineering Review Gate` as a new output requirement. If existing Plan/Exec/Review text references it, update the references to the new term and ensure `plan_gate` remains the actual execution validator.

## Responsibility Alignment Matrix

| Existing Plan Mechanism | Decision | New Positioning | Reason |
|---|---|---|---|
| Source Contract Check | Keep and clarify | Only decides whether input is plan-ready | Preserves Research/Plan boundary without redoing Research. |
| `research.v3` adapter | Strengthen | Stable consumer of goal, success shape, scope, constraints, friction, and first plannable objective | Research is already updated; Plan must reliably consume the current contract. |
| Research legacy adapters | Remove or mark obsolete | Not active compatibility work | User explicitly does not want Research compatibility retained. |
| Plan owns approach selection | Strengthen | Core Plan responsibility | Plan is a decision stage, not a mechanical translator. |
| Engineering Review Gate | Rename and reposition | `Plan Engineering Review` decision-hardening pass | gstack review should reduce implementation friction, not add another hard route gate. |
| Inconsistency Grill Gate | Merge/soften | Selected-approach alignment check inside Plan Engineering Review or final sanity pass | Useful for catching drift, but should repair Plan before routing upstream. |
| Final Plan Gate / `plan_gate` | Keep as hard gate | Only authorization for `pge-exec` | `pge-exec` depends on `plan_gate PASS + Exec Allowed yes`. |
| Architecture Delta Contract | Keep conditionally | MEDIUM/DEEP, architecture, workflow-contract, protocol, or migration plans | Too heavy for simple tasks, essential for high-risk contract changes. |
| Fast Lane | Keep | Low-friction LIGHT path | Prevents simple plans from paying deep-process overhead. |
| Fast Adopt | Keep and clarify | Convert complete external plans into canonical `.pge` plans | Practical entry point; must not become silent replanning. |
| Input Priority Interpretation | Keep | Current user constraints outrank artifacts | Prevents stale artifacts from overriding latest intent. |
| Coverage Audit | Keep but scale | Check input constraints, Research friction, scope, and issue coverage | Should not become a full requirements audit for every task. |
| Experience Context Gate | Remove from mandatory flow | Optional context check for human/artifact-facing features | Only relevant when experience quality directly affects acceptance criteria; should not block plans for internal/protocol work. |
| Self-Review Loop | Merge/soften | Final sanity pass before `plan_gate` | Keep goal-backward, coverage, verification, and exec-readiness checks; remove ceremony. |
| Quality Gate ratings | Delete or make rare | Optional failure/debug record only | Ratings and 10/10 bars create template work without helping Exec. |
| Exact DOT flow | Delete or soften | Recommended workflow, not mandatory state machine | Fixed flow conflicts with reduced friction and depth scaling. |
| Multiple route-producing gates | Remove/merge | Only Source readiness and Final Plan Gate control routes | Intermediate checks should harden Plan, not produce gate-stack friction. |
| `NEEDS_INFO` / `NEEDS_HUMAN` from many places | Clarify | Only for user-authority goal/scope/acceptance/safety decisions | Avoids escalating normal implementation choices. |
| Verification Coupling / Parallel Safety | Strengthen | Required execution-safety field | Directly reduces `pge-exec` verification and scheduling friction. |
| Coherence Verification | Strengthen | Required for protocol/schema/route/API changes | This repo depends on producer/consumer/validator contract consistency. |

## Protocol Consistency Requirements

Maintain these producer/consumer/validator relationships:

| Surface | Required Alignment |
|---|---|
| Producer | `pge-plan` still writes `.pge/tasks-<slug>/plan.md` with `schema_version: plan.v2`. |
| Consumer | `pge-exec` still consumes `plan_route`, `plan_gate`, `## issues`, ready issue fields, target/forbidden areas, acceptance, verification, evidence, dependencies, and terminal conditions. |
| Validator | Final `plan_gate` remains the execution authorization validator. It should validate Plan Engineering Review consumption, not depend on the old multi-gate control flow. |
| Reviewer | `pge-review` should read Plan Engineering Review as current semantics when judging selected approach, non-goals, evidence, and verification coupling. |
| Template | `templates/plan.md` should preserve exec-required fields while reducing default gate checklist weight. |
| Evals | Evals should cover Research override protection, automatic approach selection, Plan Engineering Review hardening, incremental verification, no Research legacy compatibility, and protocol coherence. |
| Docs | `README.md`, `README-CN.md`, and `CLAUDE.md` should describe Research as problem-contract discovery and Plan as executable solution design. |

Rules:

- Current semantic name: `Plan Engineering Review`.
- `Engineering Review Gate` should not remain a current output requirement.
- `plan_gate` must not be renamed.
- `schema_version: plan.v2` must not be renamed in this slice.
- `pge-exec` should not need changes unless it directly parses an old heading that cannot safely remain as an alias.

## Proposed Implementation Steps

1. Update `skills/pge-plan/SKILL.md`:
   - replace fixed gate-stack positioning with executable solution design positioning
   - remove current Research compatibility adapters
   - add Research Contract Override Rule and operationalization boundary
   - add implementation path explicitness rules
   - add auto-selection boundary for Plan Engineering Review
   - reposition Engineering Review Gate as Plan Engineering Review
   - clarify that intermediate checks repair Plan before routing upstream
   - preserve Final Plan Gate as the only execution authorization gate

2. Update `skills/pge-plan/references/engineering-review-gate.md`:
   - reframe as Plan Engineering Review
   - focus on selected approach clarity, issue slicing, complexity/risk reduction, acceptance quality, verification strength, and execution ergonomics
   - keep depth scaling
   - make LIGHT review compact and prevent the new review from becoming a renamed heavy template
   - remove hard-gate language that makes this an independent authorization layer

3. Update `skills/pge-plan/references/plan-gate.md`:
   - keep `PASS | REVISE | ESCALATE | REJECT`
   - keep `Exec Allowed: yes/no`
   - validate that Plan Engineering Review, if applicable, has been consumed into selected approach, issues, acceptance, verification, and risks
   - validate executable and incrementally verifiable issue contracts
   - validate protocol coherence for contract-surface changes
   - reject plans that lack exec-required fields

4. Update `skills/pge-plan/templates/plan.md`:
   - preserve all fields required by `pge-exec`
   - remove default quality ratings and `10/10` bars
   - reduce always-visible gate checklist ceremony
   - strengthen behavior delta, verification coupling, evidence, AFK/HITL, and forbidden-area fields
   - include scaled Plan Engineering Review section only when useful

5. Update `skills/pge-plan/evals/*.json`:
   - Research `READY_FOR_PLAN` is inherited without being re-litigated
   - `simplest_direction` can be rejected by Plan with rationale
   - Research blocking questions cannot become assumptions
   - Plan may operationalize but not override Research problem-contract fields
   - Plan Engineering Review improves approach, slicing, acceptance, verification, and risk handling
   - LIGHT plans stay compact
   - plans are incrementally verifiable or explicitly coupled
   - obsolete Research compatibility paths are not treated as active contracts
   - protocol/schema/route changes include producer/consumer/validator/reviewer coherence

6. Update review and docs compatibility:
   - update `skills/pge-review/SKILL.md` only enough to recognize Plan Engineering Review as current semantics
   - update `README.md`, `README-CN.md`, and `CLAUDE.md` where they describe Plan as gate-stack driven or reference obsolete Research compatibility
   - avoid changing `pge-exec` unless protocol review proves it depends on removed Plan wording

7. Run protocol consistency review:
   - compare `CLAUDE.md`, `README.md`, `README-CN.md`, `pge-plan`, `pge-exec`, `pge-review`, templates, references, and evals
   - confirm route/status/verdict vocabulary remains consistent
   - confirm `pge-exec` can still consume new `plan.v2` artifacts
   - confirm obsolete Research compatibility paths are not treated as active contracts

## Test Plan

- Static protocol search:
  - Search for `research.v2`, `planning_handoff`, `plan_delta`, `confirmed_intent`, `scope_contract`, `Engineering Review Gate`, `Plan Engineering Review`, `plan_gate`, and `READY_FOR_EXECUTE`.
  - Confirm obsolete Research compatibility language is removed or explicitly historical.
  - Confirm `plan_gate` vocabulary remains unchanged.

- Contract consistency checks:
  - Verify `pge-plan` output fields match `pge-exec` Plan Validation requirements.
  - Verify `pge-review` can identify selected approach, issue contracts, verification coupling, and evidence expectations.
  - Verify route/status/verdict vocabulary is consistent across touched files.

- Eval scenarios:
  - Auto approach selection inside `READY_FOR_PLAN`.
  - Plan rejects `simplest_direction` without changing Research goal/scope.
  - Research `NEEDS_USER` blocks Plan from assuming an answer.
  - Implementation Friction maps into constraints/issues/rejected approaches/verification.
  - Progressive Feasibility scopes Plan to `first_plannable_objective`.
  - Coupled verification identifies first trustworthy verification point.
  - Protocol-surface changes include producer/consumer/validator evidence.

- Manual fixture review:
  - LIGHT plan remains compact.
  - MEDIUM/DEEP plan shows Plan Engineering Review improving approach, issue slicing, verification topology, and evidence.
  - Plan artifact still satisfies `pge-exec` required fields.

## Success Criteria

- Plan's documented role is implementation decision and executable contract synthesis, not renewed problem discovery.
- Plan Engineering Review is a first-class Plan mechanism for producing higher-quality plans with less Exec friction.
- Plan can automatically select implementation approaches without overriding Research conclusions.
- Research conclusions that would be changed by Plan require user confirmation or return to Research.
- Research legacy compatibility paths are removed or clearly marked obsolete, not maintained as active behavior.
- Implementation path is explicit at the contract level but does not pre-write code.
- Final Plan Gate remains the hard authorization for `pge-exec`.
- LIGHT plans stay compact and do not inherit a renamed heavy template.
- New plans remain compatible with `pge-exec` validation requirements.
- Ready plans are clear enough for issue-by-issue execution and honest about incremental verification limits.
- Protocol changes are consistent across producer, consumer, validator, reviewer, template, docs, and evals.

## Migration and Rollback

### Existing Plans

Existing `.pge/tasks-*/plan.md` files created under the old contract are grandfathered. `pge-exec` should continue to accept them as long as they have `schema_version: plan.v2` and required fields (plan_gate, issues, acceptance, verification, evidence).

New plans created after this change should follow the updated contract.

### Rollback Strategy

If this change creates execution friction instead of reducing it, rollback by:

1. Reverting `skills/pge-plan/SKILL.md`, references, and templates to previous versions
2. Keeping `schema_version: plan.v2` unchanged ensures `pge-exec` compatibility during rollback

Detection signals for rollback consideration:

- Plans consistently route to `NEEDS_INFO` or `NEEDS_HUMAN` for normal implementation choices
- `pge-exec` frequently rejects plans for missing required fields
- Plan Engineering Review becomes a bottleneck (takes longer than execution)
- User feedback indicates increased friction rather than reduced friction

### Fast Adopt Clarification

Fast Adopt converts complete external plans into canonical `.pge/tasks-<slug>/plan.md` format. After this change:

- Fast Adopt must validate that the external plan includes goal, scope, approach, issues with acceptance/verification, and evidence requirements
- If the external plan lacks these, Fast Adopt should supplement them (not silently assume)
- Fast Adopt should trigger Plan Engineering Review for MEDIUM/DEEP plans
- Fast Adopt must not silently replan; it should preserve the external plan's approach and only add missing execution-required fields

## Assumptions

- Updated Research is the only active Research contract; no old Research compatibility is required in this plan.
- This plan does not introduce a separate persisted Reality Extraction artifact; bounded repo/runtime evidence gathering stays inside Plan, embedded in Plan Engineering Review or approach rationale.
- `schema_version: plan.v2` remains unchanged.
- `plan_gate` remains the only hard execution authorization consumed by `pge-exec`.
- Plan Engineering Review is a semantic repositioning and quality mechanism, not a heavier default template.
