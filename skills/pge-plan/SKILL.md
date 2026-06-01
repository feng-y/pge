---
name: pge-plan
description: >
  Produce an executable solution-design contract under `.pge/tasks-<slug>/plan.md`.
  Supports fast-adopt for explicit external plans whose semantics are sufficient
  to materialize a canonical execution contract.
  Selects implementation approach, issue slicing, ordering, verification topology,
  and evidence requirements inside the inherited problem contract.
version: 0.6.0
argument-hint: "<task intent or planning notes>"
disable-model-invocation: true
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---

# PGE Plan

Produce one bounded, executable PGE plan artifact at `.pge/tasks-<slug>/plan.md`.

Run `pge-plan` in the current main reasoning context. Do not hand core planning, phase/scope interpretation, or semantic ownership decisions to an automatically selected lower-capability planning model. Agents may help with bounded evidence gathering or outside voice review, but main owns the plan contract and final decisions.

This is a planning skill. It does not execute code, edit implementation files, produce implementation pseudocode, publish GitHub issues, or invoke `pge-exec`.

Plan is responsible for **executable solution design**:

```text
my issues = executable implementation path for the inherited problem contract
```

Plan owns approach selection, architecture-friction reduction, issue slicing as an execution graph, execution ordering, verification topology, migration/rollout sequencing when relevant, blast-radius minimization, protocol coherence strategy, and execution ergonomics. It must not reopen Research problem discovery, redefine the inherited goal/scope/success shape/non-goals/constraints, or pre-write implementation code.

The artifact shape is flexible, but these semantic fields are mandatory:

```text
schema_version
source_contract_check
selected_approach
rejected_approaches
goal
non_goals
issues
target_areas
forbidden_areas
acceptance
verification
evidence_required
risks
terminal_conditions
plan_gate
stop_conditions
route
```

Do not write a long plan to satisfy a template. Write the smallest plan that lets `pge-exec` implement without guessing, while preserving the same semantic target from the user/research input.

Plan specifies implementation path at the contract level, not the coding level. Make direction, scope, ordering, verification coupling, and proof requirements explicit; do not specify exact code edits, helper functions, abstractions, flags, or test internals unless a public/protocol contract requires named symbols, fields, files, or commands.

`schema_version` is always `plan.v2` for plans produced under this contract.

## Architecture Delta Contract

For MEDIUM/DEEP work, workflow-contract changes, architecture changes, or any plan where a wrong assumption could be executed correctly but wrongly, `pge-plan` must treat the plan as an **Architecture Delta Contract**, not a TODO list.

The contract answers:

```text
current reality -> bounded delta -> target direction
```

Record the contract inside the canonical `.pge/tasks-<slug>/plan.md` using existing plan fields. Do not create a second canonical artifact for this first-class plan model.

The plan must make these dimensions explicit, scaled to task risk:

- **Current reality** — repo/code/runtime/config/artifact facts that the plan relies on, with evidence or source references.
- **Target direction** — the desired architecture, workflow, behavior, or artifact state the current slice moves toward.
- **This delta moves** — the bounded change this plan authorizes.
- **This delta does not move** — adjacent architecture, behavior, workflow, tooling, or validation surfaces deliberately left unchanged.
- **Allowed changes** — target areas and contract surfaces exec may modify.
- **Forbidden zones** — paths, behaviors, route/state/verdict vocabulary, artifact layouts, or responsibilities exec must not touch.
- **Claim/evidence expectations** — plan-relevant claims that need evidence, and what evidence is required for review to trust them.
- **Validation reality** — which checks are cheap execution feedback and which checks are final trust gates such as compile, replay, or equivalent evidence.
- **Stop conditions** — observable conditions that force revise, escalate, reject, or route upstream before execution continues.

Plan owns this synthesis. Research supplies intent, discrepancy, evidence, and constraints; plan selects the approach and turns them into an executable Architecture Delta Contract; exec consumes only the passed canonical plan. Do not move this synthesis into research or execution.

Depth scaling:
- LIGHT tasks may collapse this into short statements in `goal`, `non_goals`, `forbidden_areas`, `verification`, and issue behavior contracts.
- MEDIUM/DEEP and workflow-contract plans must expose the dimensions clearly enough that `pge-exec`, `pge-review`, and Final Plan Gate can detect scope drift, unsupported claims, and validation-reality confusion.
- MEDIUM/DEEP Architecture Delta Contracts, workflow-contract changes, artifact-schema changes, validation-contract changes, gate/tooling changes, and plans with material forbidden-zone risk must also include `## plan_gate_inputs` using `references/final-plan-gate.md`: declared change types, required claims, evidence schemas, boundary checks, and validation reality.
- If the current slice is only the lightweight Phase 1 of a larger gate/tooling direction, say what later registry/script/schema work is deliberately not moved by this delta.

**Field authority classification:**

Plan inherits authority classification from research and adds its own:

| Authority | Meaning | How exec should treat |
|---|---|---|
| `user_confirmed` | User explicitly stated or confirmed | Authoritative; do not deviate |
| `source_of_truth` | From authoritative upstream source, spec, or referenced document | Inherit as constraint; do not re-litigate |
| `repo_evidence` | Derived from code, docs, config with cited source | High confidence; cite source |
| `inherited_from_research` | Research conclusion with evidence | Inherit; do not re-litigate unless repo contradicts |
| `inferred_by_plan` | Plan inference or design choice | Auditable; exec may flag if implementation contradicts |

Plan must not upgrade `inherited_from_research` or `inferred_by_plan` claims to `user_confirmed` constraints. `RETURN_TO_RESEARCH` is the correct route when plan needs user-confirmed intent that research did not provide.

**Research Contract Override Rule:** When Research has `route: READY_FOR_PLAN`, Plan inherits the Research problem contract as authoritative. Plan may challenge and change `candidate_direction`, selected implementation approach, issue slicing, migration shape, rollout safety, execution topology, and verification strategy. Plan may operationalize Research conclusions into executable acceptance, target areas, issue boundaries, and verification as long as it does not change their semantic meaning.

Plan must not silently override `goal`, `success_shape`, `scope`, `non_goals`, `constraints`, `Implementation Friction.required_plan_adjustment`, or `Progressive Feasibility.first_plannable_objective`. If evidence shows a Research conclusion is wrong, stale, unsafe, or not executable, record the conflict and route to `NEEDS_INFO`, `NEEDS_HUMAN`, or `RETURN_TO_RESEARCH`; do not produce `READY_FOR_EXECUTE` until the problem-contract change is confirmed. Research blocking questions must not become Plan assumptions.

**Reality extraction boundary:** Do not create a separate persisted Reality Extraction artifact. Fold bounded repo/runtime truth extraction into Plan exploration only as needed to design execution path: runtime paths, producer/consumer/validator surfaces, coupling hotspots, verification constraints, migration blockers, rollout/rollback constraints, ownership boundaries, and execution-risk shape.

**Current research contract:** `research.v3` is the only active PGE research contract. If a selected source does not already provide current problem-contract semantics, do not reconstruct them from historical field names; use current source evidence or route `RETURN_TO_RESEARCH` / `NEEDS_INFO`.

## Execution Flow

This flow is the default planning path, not a fixed state-machine ceremony. Preserve the stage ownership and hard route/authorization points, but scale intermediate checks to task risk.

```dot
digraph pge_plan {
  rankdir=TB;
  node [shape=box, style=rounded];

  subgraph cluster_phase1 {
    label="Phase 1: Input Adaptation";
    style=dashed;
    resolve_input [label="Resolve Current Prompt\n(highest priority)"];
    classify_depth [label="Classify Depth\n(LIGHT|MEDIUM|DEEP)"];
    read_config [label="Read Setup Config"];
    consume_upstream [label="Consume Selected Source\n+Current Constraints"];
    gate_check [label="Gate Check", shape=diamond];
    resolve_input -> classify_depth -> read_config -> consume_upstream -> gate_check;
  }

  gate_stop [label="STOP\n(no artifact)", shape=doubleoctagon];
  gate_check -> gate_stop [label="incomplete/complex"];

  subgraph cluster_phase2 {
    label="Phase 2: Solution Design + Plan Engineering Review";
    style=dashed;
    coverage_audit [label="Coverage Audit\n(input constraints + phase/scope)"];
    explore [label="Bounded Repo/Runtime Truth\n(execution-path evidence)"];
    propose [label="Approach Candidates"];
    plan_eng_review [label="Plan Engineering Review\n(see references/)"];
    select_approach [label="Select Approach\n+Repair Findings Inline"];
    coverage_audit -> explore -> propose -> plan_eng_review -> select_approach;
    plan_eng_review -> propose [label="REWORK_PLAN", style=dashed];
  }

  eng_gate_research [label="RETURN_TO_RESEARCH", shape=doubleoctagon];
  eng_gate_info [label="NEEDS_INFO\n(ask 1 question)", shape=doubleoctagon];
  plan_eng_review -> eng_gate_research [label="problem contract must change"];
  plan_eng_review -> eng_gate_info [label="user-authority blocker"];

  gate_check -> coverage_audit [label="ready"];

  subgraph cluster_phase3 {
    label="Phase 3: Synthesis";
    style=dashed;
    self_eval [label="Self-Evaluation\n(Decision Classification\n+Authority Limits)"];
    synthesize [label="Synthesize Intent\n+Plan Constraints\n+Phase Boundary\n+stop_conditions"];
    self_eval -> synthesize;
  }

  authority_ask [label="ASK_USER\n(max 1)", shape=doubleoctagon];
  needs_human [label="NEEDS_HUMAN\n(write best available plan)", shape=doubleoctagon];
  self_eval -> authority_ask [label="User Challenge"];
  authority_ask -> self_eval [label="answered", style=dashed];
  authority_ask -> needs_human [label="unanswered / external decision"];

  select_approach -> self_eval;

  subgraph cluster_phase4 {
    label="Phase 4: Task Output";
    style=dashed;
    create_issues [label="Create Issues\n+decision refs\n(vertical slices)"];
    write_artifact [label="Write Artifact"];
    self_review [label="Final Sanity Pass\n(goal + coverage + verification + exec readiness)\n(see references/)", shape=box3d];
    plan_gate_final [label="Final Plan Gate\n(contract + repo reality\n+ exec readiness\n+ skill stability)", shape=diamond];
    route [label="Route", shape=note];
    create_issues -> write_artifact -> self_review -> plan_gate_final -> route;
    plan_gate_final -> create_issues [label="REVISE", style=dashed];
  }

  synthesize -> create_issues;
  needs_human -> write_artifact [label="close stage", style=dashed];
  self_review -> explore [label="confidence\nre-entry (max 1)", style=dashed];
}
```

## Anti-Patterns

- **"Let Me Brainstorm Everything First"** — Scale brainstorm to task. If the prompt is plan-ready, plan from it directly. If research already recommended, adopt it.
- **"I Should Ask To Be Safe"** — Questions are expensive. Self-evaluate first. Record assumptions instead.
- **"Let Me Plan The Whole System"** — Plan only what was asked. Respect upstream scope.
- **"Let Me Re-Decide The Spec"** — Authoritative upstream decisions are constraints, not fresh options. Plan decides implementation details; it does not re-litigate product behavior, rollout strategy, architecture direction, or scope already settled upstream.
- **"Selector Means Ignore The Rest"** — If arguments contain a selector plus extra text, the selector locates an artifact and the remaining text is current user constraint. Consume both.
- **"Issues Should Be Granular"** — Prefer few vertical slices over long micro-task checklists.
- **"Skip Plan Engineering Review"** — Even simple tasks get a compact scope/reuse/verification sanity check.

---

## Phase 1: Input Adaptation

### Resolve Input

Always parse the current prompt first. Current prompt content is the highest-priority input and must never be ignored, even when it also contains a task slug, research path, or other selector. If `ARGUMENTS:` explicitly names a task slug, research path, or other structured upstream input, treat that as the user's selected source and use it without asking again. If the arguments contain both a selector and additional text, treat the selector as the source location and the remaining text as binding current user constraints. Otherwise, on a bare `pge-plan` invocation, discover research artifacts under `.pge/tasks-<slug>/research.md` but do not silently select them. Ask the user to confirm a discovered artifact, choose among multiple artifacts, or choose between a discovered artifact and current conversation context.

Direct prompt planning is a first-class path. A user can invoke `pge-plan <clear intent>` without first running `pge-research`. The plan stage must decide whether that prompt is plan-ready, do the bounded repo exploration needed for planning, and produce `plan.md` when it can fairly define scope, constraints, acceptance, and verification. Route to `NEEDS_INFO` or suggest `pge-research` only when the prompt is too fuzzy, broad, or under-evidenced to plan responsibly.

### Context Intake and Clarification

Plan does not only consume formal research artifacts. It must also consume relevant current context: latest user corrections, interrupted prior attempts, observed failures, pasted logs, challenge/review findings, prior plan-mode notes, and fresh artifacts. Treat that context as input, not as background noise.

Before decomposing into issues, identify the current planning target:

- goal or fix target
- evidence that makes it real
- proposed scope
- explicit non-goals
- uncertainties that would change the plan

Plan may self-research from intent. If the prompt/context is plan-ready but lacks repo facts, do bounded exploration and produce the plan. If the prompt/context identifies a likely problem but the goal, scope, or acceptance is still ambiguous, ask one clarifying question before writing `plan.md`. The question should confirm the semantic target, not implementation trivia.

If the user confirms, continue planning. If unanswered and the ambiguity changes the plan, route `NEEDS_HUMAN` or `NEEDS_INFO` instead of inventing a broader fix.

### Classify Depth

- **LIGHT** (1-3 files, single module, clear path): Minimal review, 1-2 issues.
- **MEDIUM** (4-8 files, 2-3 modules): Standard review, 2-5 issues.
- **DEEP** (8+ files, cross-module, architectural): Full review, complexity gate, consider phased delivery.

### Fast Lane (LIGHT with clear intent)

When ALL of these are true:
- Depth = LIGHT (1-3 files, single module)
- No upstream research artifact exists (user came directly to plan)
- Intent is unambiguous (single clear action, not exploratory)
- No security surface

Then:
- Skip Outside Voice (already conditional on MEDIUM+)
- Use LIGHT final sanity pass from `references/self-review.md`: sanity areas 1, 3, and 4, plus area 2 when upstream decisions, non-goals, or source boundaries exist
- Skip pressure test
- Target: 1-2 issues maximum
- Keep the issue surface proportional: do not turn a verification carrier into a new feature, framework, flag, helper layer, or broad validation system unless the current constraints explicitly ask for it
- Expected plan time: under 2 minutes

Fast Lane is the smallest direct prompt path, not the only direct prompt path. MEDIUM and DEEP prompts may also be planned directly when the user gives enough intent, boundaries, and success criteria for Phase 2 exploration and Plan Engineering Review to close the remaining implementation-level gaps.

### Fast Adopt (explicit external plan → PGE contract)

Use this path when the selected source is already an explicit plan — including Claude Code plan mode output, `docs/exec-plans/` documents, gstack/Codex reviewed plans, design execution notes, or a structured design/execution plan — but it is not in canonical `.pge/tasks-<slug>/plan.md` format.

Fast Adopt is allowed for LIGHT, MEDIUM, or DEEP inputs. Depth controls issue count and verification strictness, not whether adoption is available.

The selected source is adoption-ready when its semantics are sufficient to derive the execution contract without inventing scope. The source does not need literal headings or fields; the relevant information may appear in prose, tables, issue lists, review comments, plan-mode output, or other structured notes.

Adoption readiness asks whether Plan can confirm:
- goal and observable success or stop condition
- bounded phase/scope
- implementation decisions and semantic ownership boundaries
- non-goals or exclusions when scope is narrowed
- allowed and forbidden target areas or unambiguous ownership areas
- verification expectations or evidence requirements
- enough ordered work structure to derive executable issues without adding new semantics

These are semantic requirements for input adoption, not required source headings or literal source fields.

When adoption-ready:
- Skip broad option generation and outside-voice approach selection.
- Do not re-decide architecture, rollout strategy, phase boundaries, target ownership, or semantic model.
- Preserve source goal, scope, approach, and reviewed decisions.
- Materialize the source semantics into the canonical plan template, including `forbidden_areas` and `plan_gate`.
- Use `plan_route: READY_FOR_EXECUTE` or `READY_FOR_EXECUTE_WITH_ASSUMPTIONS` only after the Final Plan Gate passes. Use `READY_FOR_EXECUTE_WITH_ASSUMPTIONS` only when assumptions are explicit, mechanical, and non-scope-changing.
- Materialize PGE execution contract fields: issue slices, target areas, acceptance, verification, dependencies, execution type, evidence required, and stop condition.
- Split into the smallest number of execution issues needed for `pge-exec`; issue slicing may decide order and grouping but must not add scope.
- Mark `fast_adopt: true` and record the source path or `claude_plan_mode` source in Metadata.
- Run Coverage Audit, Plan Engineering Review (mandatory for MEDIUM/DEEP plans), and Final Plan Gate against source fidelity: missing semantics, unauthorized expansion, issue traceability, acceptance/verification coverage, repo reality, and execution readiness.

**Fast Adopt validation:**

Fast Adopt must validate that the external plan semantically provides goal, bounded phase/scope, approach or fixed implementation decisions, issues or ordered work, acceptance/verification meaning, and evidence expectations. If the source lacks canonical headings or PGE fields, Fast Adopt may materialize them. If the source lacks required semantics, Fast Adopt must stop with `NEEDS_INFO` or leave Fast Adopt for normal planning when current user intent allows. It must not supplement missing semantics as assumptions. Fast Adopt must not silently replan; it should preserve the external plan's approach and only add missing execution-required fields.

If converting the source requires choosing new scope, adding helpers/flags/cleanup/abstractions, inventing target areas, inventing acceptance criteria, resolving undecided semantic ownership, or changing phase boundaries, Fast Adopt must stop with `NEEDS_INFO` or route to the normal pge-plan path. Do not silently turn adoption into replanning.

Input and output have different requirements: input only needs adoption-ready semantics; output must materialize those semantics into `.pge/tasks-<slug>/plan.md` as the canonical `plan.v2` execution contract.

### Read Setup Config

Read `.pge/config/*`. If `docs-policy.md` or `repo-profile.md` exists, treat as project constitution — plan must not contradict it without justification. Missing config: degraded mode for simple tasks.

### Consume Upstream Input

`pge-plan` consumes a selected source plus any current user constraints, then produces `plan.md`. The selected source can be a direct user prompt, research artifact, user-specified file/slug, structured notes, or clear intent.

If the user invoked `pge-plan <task-slug>` or `pge-plan .pge/tasks-<slug>/research.md`, that explicit selector is consent to consume the matching artifact. If the same invocation includes trailing instructions, those trailing instructions are not commentary; they are current user constraints and outrank derived summaries when they narrow scope, prohibit additions, define allowed files, or change verification expectations. If the user invoked `pge-plan <clear prompt>`, that explicit prompt is consent to plan from the prompt directly unless it conflicts with an explicitly selected artifact. If the user invoked bare `pge-plan`, artifact discovery is only a proposal: confirm before consuming a single discovered research artifact, ask the user to choose when multiple artifacts exist, and ask the user to choose when both a discovered artifact and current context look valid. Direct planning from intent remains supported when the current prompt/context is plan-ready.

### Input Priority Interpretation

Before Coverage Audit, build an internal input-priority interpretation. Use it to decide what must be inherited, what can be treated as evidence, and what must be overridden.

| Input Source | Role | Priority | Handling |
|---|---|---|---|
| Current user prompt / trailing arguments | hard constraint, latest override, or selected scope | highest | reflect in Intent, Non-goals, Target Areas, issue boundaries, and Verification; never ignore |
| `docs/exec-plans/` document explicitly selected or referenced | canonical planning source | high | preserve phase, scope, semantic ownership, non-goals, and success criteria; do not re-decide its authorized boundary |
| Original user-provided source, spec, issue, design doc, or referenced source-of-truth file | source of truth | high | read when referenced by the selected source or current user; preserve requirements, decisions, boundaries, phases, and success criteria |
| Repo code/docs/config | evidence | high | confirm feasibility and stale assumptions; may contradict upstream with cited evidence |
| `pge-research` brief or other summary artifact | derived summary | medium | consume as compressed understanding, but do not let it erase original source constraints or current user constraints |
| Prior notes, old plans, or non-authoritative summaries | context | low | use only when consistent with higher-priority inputs |

When planning from a `docs/exec-plans/` document, boundary fidelity is the primary quality bar. Preserve the document's phase/scope decisions and semantic ownership exactly unless the current user explicitly overrides them or repo evidence proves a contradiction. Do not add helpers, flags, cleanup, validation systems, broader refactors, or "nice" abstractions that the exec plan did not authorize. In domain-specific planning, treat correctness and semantic ownership as higher priority than generic task breakdown polish.

If a derived research artifact names or depends on an original source-of-truth artifact, and the current planning decision depends on scope, boundaries, rollout, verification, phase position, or "only allowed addition" constraints, read the original source too. Do not plan from a derivative summary alone when the summary is incomplete for those decisions.

If priorities conflict:
- Latest explicit user constraints win over older artifacts.
- The current prompt wins over selected artifacts, derived summaries, and prior plans.
- Repo evidence can override an artifact only with a cited contradiction.
- A derived summary cannot override its original source unless it records an explicit user-approved scope decision.
- Record every override in `Decision Overrides`.

**Primary protocol-aligned source:** `pge-research` brief.

**Other supported planning inputs when semantically sufficient:** direct prompt or current conversation context, approved `spark.v1` specs, Claude plan mode output, challenge/review findings, logs, failed attempts, other current-context evidence, structured docs with intent/findings/constraints, and bounded self-research inside `pge-plan` for plan-ready prompts.

An approved `spark.v1` spec is a planning source, not a peer research contract. Plan either translates it into canonical `plan.v2` or routes upstream when goal, scope, success shape, or constraints are still not fair to execute.

**Gate check:**
- Ready: consume.
- Incomplete: STOP. No artifact. Suggest resolving upstream.
- Prompt/context plan-ready + no selected artifact: plan directly. Use Phase 2 exploration to fill repo facts and implementation-level gaps.
- Prompt/context fuzzy or exploratory: STOP. Suggest `pge-research`.
- Missing + simple: use Fast Lane direct planning from clear intent.
- Missing + complex but plan-ready: plan directly with MEDIUM/DEEP review.
- Missing + complex and not plan-ready: STOP. Suggest `pge-research`.
- Bare `pge-plan` invocation with one discovered `.pge/tasks-<slug>/research.md`: ask the user to confirm before consuming it.
- Bare `pge-plan` invocation after research, but no `.pge/tasks-<slug>/research.md` can be discovered: plan directly only if current prompt/context is plan-ready; otherwise ask the user to run `pge-research` first.
- Explicit continuation requested for a prior research task, but `.pge/tasks-<slug>/research.md` is missing: STOP. Report broken handoff instead of silently pretending the research artifact exists.
- A discovered research artifact and the current conversation both look like valid upstream sources: ask the user which one to use instead of guessing.
- Multiple plausible research artifacts and no explicit selector: ask the user which task to continue instead of guessing.

**Source Contract Check:**

When consuming a research brief or structured upstream input, verify before proceeding to approach design:

| Check | Condition | Route |
|---|---|---|
| Intent confirmed | research.v3 `goal` is present and specific, or a non-Research external source has an equivalent current goal | CONTINUE_TO_PLAN |
| Scope explicit | research.v3 `scope`/`non_goals` names boundaries, or a non-Research external source has equivalent current boundaries | CONTINUE_TO_PLAN |
| Success shape usable | `success_shape` or equivalent is observable and plan-convertible | CONTINUE_TO_PLAN |
| Intent not confirmed | goal is still fuzzy, multiple unresolved framings | RETURN_TO_RESEARCH |
| Success shape missing or vague | cannot derive acceptance criteria from it | RETURN_TO_RESEARCH |
| Blocking ambiguity unresolved | ambiguities with `blocks_plan: yes` remain open | NEEDS_INFO |

Route `RETURN_TO_RESEARCH` when intent or success shape is not confirmed and plan cannot fairly produce executable issues without inventing user intent. Route `NEEDS_INFO` when a specific blocking question can be answered by the user directly. `CONTINUE_TO_PLAN` means the input is plan-ready.

**Consumption rules:**

| Upstream Content | How to consume | Trust |
|---|---|---|
| Direct prompt / current context | Intent + Coverage Audit baseline | latest user instruction authoritative |
| Selector plus trailing text | selector locates source; trailing text becomes Current Constraints | trailing text highest priority |
| Original source-of-truth referenced by selected source or current user | Input Priority + Plan Constraints + Coverage Audit | high authority |
| Derived summary of an original source | Repo Context + defaults for missing plan fields | medium; cannot erase original/current constraints |
| Intent / goal | Fill Intent | as-is |
| Findings / evidence | Repo Context | as-is |
| Affected areas | Target Areas | as-is |
| Constraints / non-goals | Non-goals | as-is |
| Structured intent / spec decisions | Intent + Plan Constraints + Decision Coverage | authoritative unless contradicted |
| Clarifying notes / open questions | Coverage Audit + Risks / Open Questions | blocking items stay blocking |
| Zoom-Out Map | Repo Context + Target Areas + Architecture Assessment | preferred compressed system map; do not redo unless insufficient or contradicted |
| Synthesis Summary: Stated / Inferred / Out | Intent, Assumptions, Non-goals | stated/out authoritative; inferred auditable |
| Upstream Requirement Ledger / Spec Coverage | Coverage Audit | authoritative trace input |
| Decision Log / upstream spec decisions | Plan Constraints + Decision Coverage | authoritative |
| Rollout strategy / compare mode / flags / gray rollout | Issue verification strategy + risks | authoritative |
| Monitoring metrics / success-fail counters | Required Evidence + Verification | authoritative |
| Multi-phase structure | Phase Boundary + issue selection | authoritative unless explicitly overridden |
| Upstream risk assessment | Issue-level Risks | inherit, do not reinvent |
| Options + recommendation | Approach candidates | advisory input only |
| Assumptions | Inherit | as-is |
| Open questions (non-blocking) | Risks / Open Questions | pass-through |
| Open questions (blocking) | BLOCK_PLAN | blocker |

**pge-research adaptation:**

When the selected source is a `pge-research` brief, identify `schema_version` and consume it through the matching adapter.

**research.v3 (current):**

1. **Route gate.** Continue only when `route: READY_FOR_PLAN`. If route is `NEEDS_USER`, stop with `NEEDS_INFO` and direct the user to answer the research blocking question, then rerun `pge-research`; do not produce a ready plan from a non-ready research artifact. If route is `NEEDS_REPO_EVIDENCE`, route `RETURN_TO_RESEARCH` unless the current user prompt explicitly overrides the selected research artifact and authorizes direct planning from current context. If route is `BLOCKED`, stop and do not produce a plan artifact.
2. **Source Contract Check.** Verify required v3 fields are present and usable, or explicitly `none` / `not_applicable`: `goal`, `success_shape`, `scope`, `non_goals`, `constraints`, relevant user/repo/architecture context, assumptions, `candidate_direction`, `rejected_framings`, blocking and non-blocking questions, route, and route reason. `blocking_questions` must be empty for `READY_FOR_PLAN`, and any conditional gate must have the field Plan must consume. Missing required v3 fields or a non-ready route must not be silently guessed.
3. **Field mapping.** Consume v3 fields as follows: `Spec Discovery.goal` → plan goal; `success_shape` → acceptance baseline; `scope` and `non_goals` → plan scope/non-goals; `constraints` → Plan Constraints/forbidden areas; `Context.assumptions` → assumptions; `relevant_repo_or_architecture_context` → repo context; `Direction.candidate_direction` → approach candidate only; `Direction.rejected_framings` → rejected approach/framing inputs; open questions → risks or blockers.
4. **Implementation Friction.** If present, cover `required_plan_adjustment` in constraints, issue scope, rejected approaches, or verification/evidence expectations.
5. **Progressive Feasibility.** If present, plan around `first_plannable_objective` as the current plan target, not the full `direct_goal`. Record `direct_goal` and `deferred_goal_parts` as context, non-goals, or phase boundary for this slice. The current plan must not target `direct_goal` when `first_plannable_objective` exists.
6. **Plan owns approach selection.** `candidate_direction` is not a selected approach. Plan selects the implementation approach through Plan Engineering Review.
7. **Source Authority Check.** When consuming research or upstream input, classify each material claim using the Field authority classification table above before using it as a plan constraint or decision basis. When Research supplies `Optional: Authority Notes`, consume them as the initial authority classification for those claims.

**Non-canonical selected sources:**

If the selected source is not `research.v3`, consume only the current semantics it actually provides: goal, success shape, scope, non-goals, constraints, decisions, risks, and evidence. Do not treat legacy Research-shaped docs or old handoff-style artifacts as supported Research contracts. If the source cannot stand on its own current semantics, route `RETURN_TO_RESEARCH` or `NEEDS_INFO` instead of reconstructing intent from obsolete Research field names.

**Current constraint extraction:**

Treat these phrases and equivalents as hard constraints:
- "only", "唯一", "just", "no other", "不要", "不加", "不做", "scope is", "must", "must not"
- file-limited instructions such as "X is the only addition point"
- verification-limited instructions such as "use this offline tool as validation"
- no-feature instructions such as "do not add flags/helpers/runtime gates/tests unless required"

For each hard constraint, map it to at least one of: `Plan Constraints`, `Non-goals`, `Target Areas`, `Acceptance Criteria`, `Verification`, or an issue `Scope`. If a hard constraint cannot be honored, route `NEEDS_HUMAN` or record a `Decision Override` with why user confirmation is required.

**Decision authority:**
- Spec-level decisions from upstream are authoritative: product behavior, scope boundary, rollout strategy, monitoring metrics, phase structure, architecture direction, explicit non-goals.
- Implementation-level choices are plan-owned: concrete file ordering, interface boundaries, issue slicing, test commands, local code patterns, and dependency sequencing.
- Override a spec-level decision only when repo evidence contradicts it or requirements conflict. Record the override as Decision / Rationale / Alternatives considered, and mark whether user confirmation is required.

---

## Phase 2: Solution Design + Plan Engineering Review

### Coverage Audit

Audit inputs against the goal in priority order. Mark each requirement or hard constraint: covered / gap to explore / out-of-scope. Also audit every upstream spec decision: inherited / overridden / missing. Do not proceed with silent drops.

Coverage Audit must include:
- current user constraints from prompt/trailing arguments
- `docs/exec-plans/` phase/scope decisions when that document is selected or referenced
- original source-of-truth requirements and boundaries when available
- research-derived requirements and assumptions
- current-source decisions
- repo evidence that confirms, contradicts, or narrows the above

If `docs/exec-plans/` is the canonical input, audit proposed issues against the source document before writing them. Any issue that introduces unrequested helpers, flags, cleanup, validation expansion, broad refactors, or abstraction work must either cite explicit authorization from the exec plan/current user or be removed.

Spec decisions coverage is mandatory when upstream contains a `Decision Log`, rollout strategy, monitoring metrics, phase structure, risk assessment, or equivalent spec-level decision. Every such decision must appear in `Plan Constraints`, a specific issue's `upstream_decision_refs`, `Verification`, or an explicit override record.

Do not revive obsolete Research compatibility fields during Coverage Audit. If a selected source depends on old Research-only field names instead of expressing current semantics directly, stop and route upstream rather than carrying those fields forward into the plan.

### Explore (fill gaps)

Only explore gaps not covered by upstream. Use repo/docs/code before asking user.

- **Multi-agent (DEEP):** Spawn parallel Agents per module gap. Synthesize yourself.
- **Flow analysis (MEDIUM/DEEP, 3+ modules):** Trace data flow end-to-end. Flag interruptions.
- **Context quarantine:** When a gap requires broad or cross-module search but planning only needs the answer, consider delegating the search to an Agent. Use direct exploration for narrow gaps where delegation overhead would exceed the context savings. Consume only the Agent's compact conclusion, evidence paths, confidence, and discarded dead ends.

### Propose Approaches

Treat upstream `candidate_direction`, recommendations, and foreign-plan options as candidates, not selected implementation. If one candidate clearly satisfies the inherited problem contract with lowest risk and no contradicting repo evidence, select it through Plan Engineering Review and record why. Otherwise compare 2-3 implementation-level approaches with tradeoffs.

Do not propose alternatives for authoritative problem-contract fields or spec-level decisions. Only propose alternatives for implementation-level choices or for upstream decisions contradicted by repo evidence.

### Plan Engineering Review

Read `references/engineering-review.md` and `references/engineering-review-gate.md` for full dimensions. Plan Engineering Review is Plan's decision-hardening mechanism for reducing Exec friction after the problem contract is aligned; it is not a separate hard authorization gate.

**Trigger conditions:**

Plan Engineering Review is:
- **Mandatory** for MEDIUM/DEEP plans (multi-issue, architecture changes, protocol surfaces, migration, rollout sequencing)
- **Optional** for LIGHT plans (single-issue, low-risk, existing patterns)
- **Findings must be consumed** into selected approach, issues, acceptance, verification, and risks before Final Plan Gate validation

Inputs:
- inherited Research/current-source problem contract
- candidate approaches
- repo/runtime evidence gathered during Plan exploration (runtime paths, protocol surfaces, coupling hotspots, verification constraints, migration blockers) — embedded in Plan Engineering Review section or approach rationale; evidence is ephemeral unless it directly informs a traceable decision
- implementation friction or progressive feasibility notes
- current user constraints

Outputs:
- selected approach and rejected approaches
- required plan adjustments
- issue slicing strategy
- acceptance, verification, evidence, rollout, rollback, migration, or stop-condition refinements

The review checks, scaled by depth:
- scope discipline, existing-code reuse, and minimum change set
- selected-approach rationale and rejected alternatives
- issue slicing, ordering, boundaries, and failure modes
- verification topology, first trustworthy verification point, and required evidence
- protocol coherence for contract-surface changes
- performance and migration risk only when applicable

Findings normally repair the plan inline. Route upstream only when the inherited problem contract must change or user authority is required.

**Routing authority:**

Plan Engineering Review does not produce routes directly. It produces findings that Plan consumes. Only Source Contract Check and Final Plan Gate have routing authority. If Plan Engineering Review discovers that the Research contract is unexecutable, unsafe, or requires goal/scope changes, Plan must surface this as a Final Plan Gate rejection with route to `RETURN_TO_RESEARCH`, `NEEDS_INFO`, or `NEEDS_HUMAN`.

**Plan Engineering Review result:** `PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO`

- `PASS` → selected approach, issue slicing, acceptance, verification, and risks are hard enough to synthesize.
- `REWORK_PLAN` → fix approach, scope, coverage, or verification findings inline, then re-run affected checks.
- `RETURN_TO_RESEARCH` → goal/scope/success shape or a Research-required adjustment is genuinely not executable without changing the problem contract.
- `NEEDS_INFO` → ask one user-authority blocking question, then re-run affected checks.

`SKIP_NOT_APPLICABLE` is valid only inside optional per-dimension records, not as the overall Plan Engineering Review result. Record the review under `### Plan Engineering Review`. New plan artifacts must use that heading.

For LIGHT plans, Plan Engineering Review may be a compact paragraph or short bullet list, or omitted entirely if the plan is trivial.

### Final Plan Gate

Read `references/plan-gate.md` for the authoritative final gate contract. This is the hard execution-contract gate for the whole plan after issues, acceptance, verification, and evidence are written.

Read `references/final-plan-gate.md` when the plan requires structured gate inputs: MEDIUM/DEEP Architecture Delta Contracts, workflow-contract changes, artifact-schema changes, validation-contract changes, gate/tooling changes, or material forbidden-zone risk. These inputs are not a second gate and do not authorize execution; they are structured material consumed by `references/plan-gate.md`.

The Final Plan Gate is the only execution authorization validator. Plan Engineering Review hardens the selected approach and repairs planning weaknesses, but Final Plan Gate owns the veto: it decides whether the hardened plan may enter `pge-exec`.

Stability rule: run the Final Plan Gate exactly in the order defined by `references/plan-gate.md`. Use the exact verdict and field vocabulary. Apply at most one inline repair pass per failed layer, rerun only the affected layer plus downstream layers, and stop instead of looping if the same layer fails twice.

The gate has six layers. Source Fidelity is mandatory for Fast Adopt and `SKIP_NOT_APPLICABLE` for ordinary direct-prompt plans with no external source to preserve:

1. **Contract Completeness Gate** — goal, non-goals, repo facts, target areas, forbidden areas, vertical slices, acceptance criteria, verification path, evidence requirements, stop condition, and risks/unknowns are present and usable.
2. **Source Fidelity Gate** — for Fast Adopt, source semantics are traceable into canonical fields without silent goal, scope, phase, ownership, non-goal, acceptance, verification, or issue-behavior drift.
3. **Plan Engineering Review** — confirms selected-approach hardening findings were consumed into the approach, issue slicing, acceptance, verification, evidence, and risks.
4. **Repo Reality Gate** — target files/modules, entry paths, existing semantics, dynamic/config-driven paths, hidden runtime behavior, and forbidden areas are grounded in repo evidence.
5. **Execution Readiness Gate** — slices are bounded, independently verifiable where claimed, retry/block/escalate routing is clear, exec context is sufficient, and human decisions are explicit.
6. **Skill Execution Stability Gate** — downstream skill execution is deterministic: canonical headings, fixed route/status vocabulary, bounded repair loops, clear clarification/terminal routes, and complete handoff fields.

**Final Plan Gate verdict:** `PASS | REVISE | ESCALATE | REJECT`

- `PASS` → `.pge/tasks-<slug>/plan.md` is frozen as the canonical execution contract and may route `READY_FOR_EXECUTE` or `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`.
- `REVISE` → direction is valid, but the execution contract is incomplete; repair the plan and rerun the failed gate layer before route.
- `ESCALATE` → human/challenge decision is needed because a key assumption, scope boundary, or repo reality question is unresolved; route `NEEDS_HUMAN` or `NEEDS_INFO`.
- `REJECT` → plan is wrong, unsafe, or not executable; route `BLOCKED` or `RETURN_TO_RESEARCH` depending on whether the problem contract itself is invalid.

No `PASS`, no `pge-exec`. A plan with Final Plan Gate `REVISE`, `ESCALATE`, or `REJECT` must not produce a ready execution route.

Record the result in the plan artifact under `## plan_gate`. Each failed verdict must name `failed_gate`, `failed_criterion`, `required_repair`, and `exec_allowed: no`.

### Review / Gate Result Normalization

All plan-stage reviews and gates use a unified result vocabulary to prevent downstream confusion:

| Surface | Result vocabulary |
|---|---|
| Plan Engineering Review | `PASS` &#124; `REWORK_PLAN` &#124; `RETURN_TO_RESEARCH` &#124; `NEEDS_INFO` |
| Final Plan Gate | `PASS` &#124; `REVISE` &#124; `ESCALATE` &#124; `REJECT` |
| Plan-level route | `READY_FOR_EXECUTE` &#124; `READY_FOR_EXECUTE_WITH_ASSUMPTIONS` &#124; `RETURN_TO_RESEARCH` &#124; `NEEDS_INFO` &#124; `BLOCKED` &#124; `NEEDS_HUMAN` |

Do not invent result values outside these vocabularies. Do not use exec-stage or review-stage vocabulary (`SUCCESS`, `PARTIAL`, `BLOCK_SHIP`, `NEEDS_FIX`, `READY_TO_SHIP`) in plan-stage results.

### Exec Readiness Check

Before routing `READY_FOR_EXECUTE`, verify the plan satisfies `pge-exec` Plan Validation requirements:

- `plan_gate` exists with `Verdict: PASS` and `Exec Allowed: yes`
- At least one issue has `State: READY_FOR_EXECUTE`
- Each ready issue has: Action, Deliverable, Behavior Contract, Target Areas, Acceptance Criteria, Verification Hint, Verification Type, Verification Coupling, Test Expectation, Required Evidence, Dependencies, Risks, and Security
- `## forbidden_areas` is present and specific enough for scope drift checks
- `## stop_conditions` is present and checkable
- `## terminal_conditions` is present
- Target Areas are concrete (paths, not vague module names)
- Verification Coupling is explicit for each ready issue
- Dependencies reference known issue IDs
- Assumptions are explicit and non-scope-changing

If any check fails, route `REVISE` and repair before producing a ready route.

### Quality Check Result Shape

Plan checks may use this compact shape when it helps downstream execution or review. Fill only fields that carry useful evidence for the current check; do not turn this into template bureaucracy.

```
check: <check name>
status: PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO | SKIP_NOT_APPLICABLE
reason: <one sentence explaining the result>
evidence: <file:line citations or semantic evidence rows>
required_plan_changes: <specific changes needed if REWORK_PLAN, or "none">
skip_reason: <required when status is SKIP_NOT_APPLICABLE>
audit_note: <optional; what was decided automatically and why>
```

**Field rules:**
- `status` may be `SKIP_NOT_APPLICABLE` for an individual dimension or non-engineering check. The overall Plan Engineering Review result still uses `PASS | REWORK_PLAN | RETURN_TO_RESEARCH | NEEDS_INFO`.
- `skip_reason` is mandatory when `status` is `SKIP_NOT_APPLICABLE`. Omit otherwise.
- `required_plan_changes` lists concrete fixes when `status` is `REWORK_PLAN`. Set to "none" for other statuses.
- Numeric quality ratings and `10/10` bars are not default plan output. Use them only in failure/debug notes when they reduce ambiguity.

### Experience Context Check (Optional)

This is an optional context check for human-facing or artifact-facing features, not a mandatory gate. Apply only when experience quality directly affects acceptance criteria.

`pge-plan` should explicitly consume problem-side experience context when the task is human-facing or artifact-facing and research supplied it. In `research.v3`, this usually appears as `Optional: Design / Experience Note` or concise Context/Direction bullets.

**Inputs when present:**
- surface or artifact being shaped
- audience
- experience success shape
- what would disappoint or mislead the audience
- existing conventions, rendered evidence, tone, or design-system constraints
- generic/slop risks or other experience constraints for Plan

**What this check validates:**
- whether the plan recognized that experience quality is part of success
- whether research supplied enough problem-side context for planning to preserve
- whether acceptance, verification, and evidence reflect that context instead of silently dropping it

**Check outcomes:**
- `PASS` — relevant experience context exists and the plan consumes it clearly in acceptance / verification / evidence
- `SKIP_NOT_APPLICABLE` — the task is purely internal/protocol work, or no human-visible experience context is relevant to planning
- `RETURN_TO_RESEARCH` — audience, experience success shape, or disappointment risk is unclear enough that the problem contract itself is not settled
- `REWORK_PLAN` — research context is clear, but the plan failed to consume it in acceptance / verification / evidence
- `NEEDS_INFO` — one specific human answer is still required and neither repo evidence nor research can resolve it

**Boundary rule:** unclear audience/success should route `RETURN_TO_RESEARCH` only when it changes the problem contract. If the problem contract is already clear and only the plan failed to reflect it, use `REWORK_PLAN`.

This check should not block plans for internal or protocol work where experience quality is not part of the acceptance criteria.

### Depth-Scaled Gate Selection

Which gates run depends on the classified depth:

| Depth | Gates Applied | Skip Policy |
|-------|--------------|-------------|
| LIGHT | Plan Engineering Review (optional; compact scope/reuse/verification sanity if applied) + Experience Context Check when applicable | Experience Context Check may `SKIP_NOT_APPLICABLE` for clearly internal/protocol tasks. |
| MEDIUM | Plan Engineering Review (mandatory; approach tradeoffs, slicing, boundaries, failure modes, verification topology) + Experience Context Check when applicable | Skipped non-engineering checks require `skip_reason`. |
| DEEP | Plan Engineering Review (mandatory) plus all applicable non-engineering checks | Non-engineering checks may `SKIP_NOT_APPLICABLE` only with explicit reason. |

LIGHT tasks must not pay DEEP ceremony. DEEP tasks must not skip gates without evidence that the dimension is irrelevant.

### Route Mapping

Gate verdicts map to plan routing. No gate may invent route vocabulary outside these values:

| Verdict | When to use | Route effect |
|---------|-------------|--------------|
| `PASS` | All applicable dimensions clear | Proceed to approach selection |
| `REWORK_PLAN` | Solution, verification, acceptance, or coverage is weak but problem is clear | Fix inline, re-run affected checks |
| `RETURN_TO_RESEARCH` | Problem contract (intent, scope, success shape) is unclear — not for weak solutions | Escalate to plan-level `RETURN_TO_RESEARCH` |
| `NEEDS_INFO` | Specific blocking question the user can answer | Ask one question, re-run gate |
| `SKIP_NOT_APPLICABLE` | Specific non-engineering gate or individual dimension does not fairly apply in the current context | Record `skip_reason`, run the remaining applicable review path |

**Boundary rule:** `RETURN_TO_RESEARCH` is reserved for unclear problem contracts. If the problem is clear but the solution/verification/acceptance is weak, the correct verdict is `REWORK_PLAN`. Gates must not conflate "hard to solve" with "unclear intent."

### Inconsistency Grill

As part of Plan Engineering Review or final sanity, actively grill the plan input against the emerging plan. This is not a separate route authority, generic brainstorming, or permission to re-decide upstream scope. Its job is to find contradictions early and repair the plan before Final Plan Gate.

Ask these checks in order:
- Does the proposed approach preserve every authoritative phase/scope decision, especially from `docs/exec-plans/`?
- Does any issue introduce helpers, flags, cleanup, validation expansion, broad refactors, or abstractions that the source did not authorize?
- Does the issue split move semantic ownership away from the module or phase named by the source?
- Do acceptance and verification prove the requested behavior, or only prove that tasks were completed?
- Is any inferred requirement being treated as stated fact?
- Is any current user constraint missing from `Plan Constraints`, `Non-goals`, `Target Areas`, issue scope, or `Verification`?

Resolve each inconsistency before synthesis:
- If code/docs answer it, self-answer with evidence.
- If it is only an implementation detail, choose the repo-conventional default and record the assumption.
- If it changes goal, phase, scope, semantic ownership, acceptance, or safety, ask the user one blocking question or route `NEEDS_INFO`.
- If the inconsistency comes from unrequested expansion, remove the expansion.

Record the result as `Plan Grill Log`: `check`, `finding`, `resolution`, and `source/evidence`. Empty logs are suspicious for MEDIUM/DEEP plans and for any plan sourced from `docs/exec-plans/`.

### Coherence Verification for High-Risk Surfaces

When a plan changes any of these surfaces, generated issues must include acceptance criteria or verification that checks producer / consumer / validator / evidence coherence:

- semantic contracts (skill contracts, handoff schemas, artifact layouts)
- route / state / verdict vocabulary
- public APIs or CLI interfaces
- schemas, manifests, or config that other components consume
- shared helpers or behavior with downstream consumers

For each affected surface, the issue's acceptance or verification must identify:
- **Producer**: what writes or defines the value/contract
- **Consumer**: what reads, executes, or depends on it
- **Validator**: what accepts or rejects it (gates, checks, tests)
- **Evidence**: proof that the post-change contract is internally consistent across all three

Grep can support coherence evidence but cannot be the sole proof for semantic-contract correctness. A grep hit confirms a string exists; it does not confirm that the producer's output, the consumer's expectation, and the validator's acceptance criteria still agree after the change.

This guidance does not require inspecting the entire repo. Scope the coherence check to the changed surface and its direct producers, consumers, and validators.

### Verification Coupling And Parallel Safety

Before writing issue dependencies, classify whether planned issues share a verification surface.

**Verification coupling** classifies how issues can be verified:

- **independent**: issue can be verified in isolation (tests pass, behavior observable)
- **coupled**: multiple issues must complete before verification is trustworthy
- **serial**: issues must be verified in order (later issues depend on earlier verification)
- **integration-only**: no meaningful verification until final integration point

For coupled or integration-only verification, Plan must identify the first trustworthy verification point.

**Coupling detection:**

- Same build graph, compile unit, generated artifact set, test suite, app startup, or integration command → compile-coupled / verification-coupled.
- Pure docs/text edits or independent scripts outside a shared build graph → not coupled unless their verification command is shared.

For coupled issues, the plan must prevent same-working-tree contamination by doing at least one of:
- add explicit issue dependencies so implementation and verification occur in a safe order,
- require serial integration verification in issue-ID order after each coupled issue,
- state that isolated worktrees are required for parallel authoring.

Do not rely on non-overlapping Target Areas alone as proof of parallel safety. If two issues can make the same verification command fail, record the coupling in the issue `Risks`, `Dependencies`, or `Verification Coupling` field and in `Handoff To Execute`.

### Select Approach

Commit to one. Record selected/rejected/scope reductions as Decision / Rationale / Alternatives considered. Override upstream only if Plan Engineering Review finds contradicting evidence or an explicit requirement conflict.

---

## Phase 3: Plan Synthesis

### Self-Evaluation

**Decision classification:**
- **Mechanical**: one correct answer from code/docs. Decide it. Never ask.
- **Taste**: multiple valid options. Choose, record rationale.
- **User Challenge**: affects goal boundary. ONLY category that may trigger ASK_USER.

**Authority limits** — 3 valid escalation reasons only:
1. Goal boundary ambiguous, code cannot resolve.
2. Missing info, no reasonable default.
3. Dependency conflict makes requirements mutually exclusive.

"Complex", "risky", "non-trivial" are NOT valid reasons.

**Headless mode:** When non-interactive (pipeline/spawned agent/`--headless`), auto-choose lowest-risk for User Challenge decisions, record in Assumptions with LOW confidence.

For each question: record Question, Why it matters, Can repo answer?, Blocking?, Safe assumption?, Risk if unanswered, Decision (SELF_ANSWERED | ASK_USER | ASSUME_AND_RECORD | DEFER_TO_SLICE | BLOCK_PLAN).

### Synthesize Intent

If the upstream source has current `research.v3` fields, carry `goal`, `success_shape`, `scope`, `non_goals`, `constraints`, relevant context, assumptions, open questions, and any conditional gate outputs through as the plan's intent baseline instead of rewriting a weaker intent. Add only execution-level detail: stop condition, code-level acceptance criteria, issue boundaries, and verification expectations.

Current `research.v3` is the only active PGE Research baseline. If the explicitly selected source is not `research.v3`, consume only the current semantics it actually provides and keep it as non-canonical source evidence unless `pge-plan` rewrites it into canonical `plan.v2`. Do not treat legacy Research artifacts or old handoff-style docs as active Research inputs.

Produce: structured intent, plan constraints, non-goals, repo context, acceptance criteria, assumptions, **stop condition** (observable "done" state).

### Success Shape → Acceptance + Verification Trace

Before writing major acceptance criteria, trace each to its source. This proves acceptance is derived from user intent, not invented, and that verification/evidence still points back to the same source.

| Acceptance Criterion | Source | Source Type | Acceptance Trace | Verification / Evidence Trace |
|---------------------|--------|-------------|------------------|-------------------------------|
| <criterion> | <research success_shape / upstream constraint / current prompt / technical approach> | success_shape / upstream / prompt / technical | <why this criterion follows> | <how verification/evidence proves this criterion> |

**Source types:**
- `success_shape`: derived from research `success_shape`, `experience_success_shape`, or `what_would_disappoint`
- `upstream`: derived from upstream contract, spec decision, or constraint
- `prompt`: derived directly from current user prompt when no research exists
- `technical`: added to support the selected approach (must not expand scope)

**Rules:**
- Every major acceptance criterion must trace to at least one source
- Every major acceptance criterion must also point to the verification/evidence that proves it
- Technical acceptance criteria are valid only when they support the selected approach — they must not introduce new features, expand scope, or add requirements the user did not ask for
- If success shape is missing or unusable (vague, contradictory, or cannot derive acceptance), route `RETURN_TO_RESEARCH` or `NEEDS_INFO` — do not silently invent acceptance criteria
- The trace supports both technical success (code works correctly) and human-facing/artifact-facing success (user intent is satisfied)

**Depth scaling:**
- LIGHT plans with 1-2 obvious criteria from a clear prompt: a single sentence trace is sufficient (e.g., "All criteria derive directly from the user prompt requesting X, and the verification/evidence section proves those criteria directly.")
- MEDIUM/DEEP plans: use the trace table for major criteria

**Context budget:** Plan + issues should fit comfortably inside the executor's useful context, with ~50% as an operational ceiling for normal work. >5 detailed issues or 15+ files → split into phased delivery. Prefer fewer vertical slices with complete acceptance criteria over one large plan that forces `pge-exec` to carry stale research, dead ends, and irrelevant raw output.

If upstream defines a multi-phase plan, inherit the phase structure. Produce issues only for the current phase unless the user explicitly asked to plan all phases. Record the phase boundary and what remains deferred.

### Scope Compression For Constrained Tasks

When current constraints specify a unique allowed addition point or prohibit extra machinery, treat that as a hard issue-boundary rule:
- Target Areas must include only the replacement area and the allowed addition point unless repo evidence proves another file is required.
- Non-goals must explicitly list prohibited additions such as new flags, helper files, runtime gates, broad abstractions, or unrelated tests.
- Verification must explain whether the allowed addition point is a verification carrier, not a new product feature.
- Any extra touched file requires a Decision Override with rationale and user confirmation if it changes scope.

---

## Phase 4: Task Output

### Create Numbered Issues

Vertical slices, not micro-tasks. Rules:
- Sequential numbering, no skips
- **Interface-first:** types/contracts before implementations
- **Vertical slices:** each issue cuts all relevant layers. Horizontal only for genuine shared dependencies.

Each issue includes:
- `ID`, `Title`, `Scope`, `Action` (imperative: what to DO)
- `upstream_decision_refs` (decision IDs or "none"; referenced decisions must not be changed by exec)
- `Deliverable` (what must exist when done)
- `Behavior Contract` with `Current Behavior`, `Desired Behavior`, `Behavior Delta`, `Key Interfaces`, `Out Of Scope Confirmed`, and `What Not To Infer`. This is the Matt-style execution brief core that `pge-exec` hands to Generator; it must be behavioral, not procedural. Target Areas can name paths, but the behavior contract should name interfaces, types, commands, config shapes, artifact contracts, and scope boundaries without relying on line numbers.
- `Target Areas` (exact paths: Create/Modify)
- `Acceptance Criteria`, `Verification Hint`
- `Verification Coupling`: none | compile-coupled with <issue IDs> | shared verification with <issue IDs> | isolated worktree required | serial verification required
- `Verification Type`: AUTOMATED | MANUAL | MIXED
- `Execution Type`: AFK | HITL:verify | HITL:decision | HITL:action
- `Test Expectation`: happy path + edge case + error path (+ integration if boundary)
- `Required Evidence`: what proves done
- `State`: READY_FOR_EXECUTE | NEEDS_INFO | BLOCKED | NEEDS_HUMAN
- `Dependencies`, `Risks`
- `Security`: yes | no (yes if issue touches auth, data access, API boundaries, secrets, or permissions. Triggers stricter Evaluator thresholds.)

When issues are compile-coupled or share a verification surface, `Dependencies`, `Risks`, and `Verification Coupling` must make the safe execution strategy explicit. If safe parallel execution requires isolated worktrees, say so; otherwise require serial verification. Do not leave this for `pge-exec` to infer from Target Areas alone.

### Write Plan Artifact

The plan artifact MUST be written only to `.pge/tasks-<slug>/plan.md`. This `.pge/` path is canonical. Notes outside `.pge/` are non-authoritative and must not replace the required pipeline artifact. ID format: `YYYYMMDD-HHMM-<slug>`.

Use `templates/plan.md` as a contract scaffold, not a fixed prose shape. Required semantics are binding; optional sections should appear only when they help `pge-exec` execute or help review detect scope drift.

**Task directory:** pge-research creates `.pge/tasks-<slug>/`. pge-plan writes into it. If research was skipped, pge-plan creates the task directory and then writes `plan.md` there:

```bash
mkdir -p .pge/tasks-<slug>/
```

### Final Sanity Pass

Read `references/self-review.md` for the focused sanity pass. Summary:
- Confirm goal-backward fit: the issues, acceptance, and stop condition still satisfy the inherited problem contract.
- Confirm coverage: current prompt constraints, upstream decisions, non-goals, target areas, and forbidden areas are not silently dropped.
- Confirm verification and evidence: every acceptance criterion has a proving check or required evidence, and weak proof is repaired before Final Plan Gate.
- Confirm exec readiness: issue contracts are concrete enough for `pge-exec` to start without guessing.

Fix failures inline once and rerun only the failed sanity area. If a failure would change goal, scope, success shape, or user authority, route `NEEDS_INFO` or `RETURN_TO_RESEARCH` instead of turning the sanity pass into another planning loop.

### Route

Plan-level routes (final plan output):

- `READY_FOR_EXECUTE`: ≥1 issue ready, no global blocker.
- `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`: used by `pge-plan` fast-adopt when a complete external plan requires explicit mechanical assumptions.
- `RETURN_TO_RESEARCH`: intent or success shape is not confirmed; plan cannot fairly produce executable issues without inventing user intent. Route back to `pge-research`.
- `NEEDS_INFO`: missing information that the user can answer directly.
- `BLOCKED`: cannot produce fair plan.
- `NEEDS_HUMAN`: human decision needed.

Ready routes require Final Plan Gate `PASS` and `exec_allowed: yes`. If the gate returns:

- `REVISE`: repair the plan inline and rerun failed gate layers before final route; if repair cannot complete in this planning turn, route `BLOCKED` with the required repair.
- `ESCALATE`: route `NEEDS_HUMAN` or `NEEDS_INFO` and mark `exec_allowed: no`.
- `REJECT`: route `BLOCKED` or `RETURN_TO_RESEARCH` and mark `exec_allowed: no`.

`.pge/tasks-<slug>/plan.md` is the frozen canonical execution contract only when `plan_gate.verdict: PASS` and `plan_route` is ready. Do not create a separate `canonical-plan.md`; separate draft/frozen plan files would create a second truth surface.

New plan artifacts use `## issues`, `## forbidden_areas`, `## plan_gate`, `## stop_conditions`, and `## route` with a `plan_route:` value. Non-canonical sources must be rewritten to these headings before `pge-exec`; exec should not interpret alias headings.

Plans must also include `## terminal_conditions` for known clarification or stop cases: missing evidence, ambiguous selector, stale artifact, plan-changing context, unsafe scope expansion, unverified repo reality, unavailable required checks, and human-only decisions. These are not runtime exceptions. Each condition must either be self-resolved from evidence, confirmed through the normal one-question ask path, or mapped to one gate verdict plus one plan route. If no terminal conditions exist, write the canonical `none | PASS | READY_FOR_EXECUTE | yes` row.

Plan Engineering Review results (Phase 2 internal decision-hardening):

- `PASS`: selected approach, slicing, verification, and risk handling are hard enough for synthesis.
- `REWORK_PLAN`: fixable solution, scope, coverage, or verification weakness found; fix inline and re-run affected checks.
- `RETURN_TO_RESEARCH`: goal/scope/success shape or a Research-required adjustment is genuinely not executable without changing the problem contract; escalates to plan-level `RETURN_TO_RESEARCH`.
- `NEEDS_INFO`: specific user-authority blocking question; escalates to plan-level `NEEDS_INFO` if user input is required.
- `SKIP_NOT_APPLICABLE`: available only inside per-dimension or non-engineering check records; it is not the overall Plan Engineering Review result.

### Completion gate

Do NOT declare the plan complete, summarize completion, or change routes until BOTH are true:

1. The plan artifact exists at `.pge/tasks-<slug>/plan.md` and satisfies the required plan contract semantics
2. You are about to output the Final Response block exactly once

If the user redirects to execution or implementation mid-run, close the stage first by writing the best available plan artifact with route `NEEDS_INFO`, `BLOCKED`, or `NEEDS_HUMAN` instead of silently exiting.

---

## Handoff To Execute

`pge-exec <task-slug>` or `pge-exec .pge/tasks-<slug>/plan.md` reads full plan + `.pge/config/*`, then builds a compact per-issue execution pack. Handoff tells exec: issue order, eligible issues, AFK vs HITL, target areas, acceptance criteria, upstream decisions to preserve, assumptions to preserve, risks not to ignore. Do not require exec to reread broad research logs when the plan already records the necessary conclusion and evidence.

## Guardrails

Do not: write business code, write implementation pseudocode or function bodies, execute the plan, invoke pge-exec, create run artifacts under `.pge/tasks-*/runs/`, ask non-blocking questions, ask multiple questions, publish GitHub Issues, use forbidden states.

## Final Response

```md
## PGE Plan Result
- plan_path: .pge/tasks-<slug>/plan.md
- plan_route: READY_FOR_EXECUTE | READY_FOR_EXECUTE_WITH_ASSUMPTIONS | RETURN_TO_RESEARCH | NEEDS_INFO | BLOCKED | NEEDS_HUMAN
- ready_issues: <ids or None>
- blocked_issues: <ids or None>
- asked_user: yes | no
- assumptions_recorded: yes | no
- plan_engineering_review: completed (result: PASS|REWORK_PLAN|RETURN_TO_RESEARCH|NEEDS_INFO) | compact | not_applicable — reason
- plan_gate: PASS | REVISE | ESCALATE | REJECT
- exec_allowed: yes | no
- next_skill: pge-exec <task-slug> | pge-exec .pge/tasks-<slug>/plan.md | pge-research <task-slug> (if RETURN_TO_RESEARCH) | pge-plan (after clarification)
```
