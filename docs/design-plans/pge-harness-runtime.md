# PGE Harness Runtime

## 1. System thesis

We are not building a single skill, a single execution loop, or a workflow platform that happens to contain PGE.

We are building an **end-to-end harness system** that carries work through:

`intent -> shaping -> planning -> execution -> evaluation -> routing -> state -> progress -> improvement`

The strategic thesis for this repo is:
- the product is the harness, not the plan artifact and not the execution loop alone
- PGE is the first execution-core foothold, not the whole system
- long-running work should remain stable through structure, contracts, state, and routing, not through conversational continuity or one large root prompt

This document carries that reviewed strategy in runtime-centered form.
It explains where PGE sits inside the larger harness system and what the repo should prove next.

Companion reference:
- `docs/design-plans/harness-system-strategy.md` contains the fuller layer map and source-absorption analysis

## 2. Strategic layers and where PGE sits

### Layer 1: Intent / shaping

Purpose:
- receive raw intent
- identify ambiguity, constraints, and success conditions
- decide whether the request is ready for planning or still needs shaping

Current stance:
- this layer is still borrowed upstream
- PGE should not absorb clarify-first work

### Layer 2: Planning / plan artifact

Purpose:
- turn a shaped problem into an execution-authorizing artifact
- define what may enter execution and what should be rejected upstream

Current stance:
- the plan artifact is the entry artifact for execution
- the plan artifact is not the runtime itself

### Layer 3: Execution core (PGE)

Purpose:
- turn a valid upstream plan into a controlled multi-round execution loop
- preserve bounded round discipline, independent acceptance, explicit routing, and explicit state continuity

Current stance:
- this is the repo's first ownable runtime foothold
- this is the main build target right now

### Layer 4: Evaluation / routing / state

Purpose:
- judge deliverables independently
- translate verdict plus current state into the next explicit route
- preserve resumability through explicit runtime state

Current stance:
- this is part of the execution-core backbone, not a sidecar around generation
- the normalized seam set already exists in `contracts/`

### Layer 5: Progress consensus

Purpose:
- preserve the shared current execution truth across rounds and sessions
- expose the latest deliverable, evidence, blockers, verdict, route, and next step

Current stance:
- this layer matters, but it is adjacent to runtime state rather than identical to it
- the repo has guidance for it, but not yet a normalized contract set for it

### Layer 6: Hooks / capture / improvement

Purpose:
- turn runtime friction into harness improvement at the correct layer
- distinguish one-off execution failure from runtime-design failure

Current stance:
- this layer is strategically important
- it should not be platformized before one real execution loop is proven

## 3. Current repo truth

The repo is no longer organized around one root prompt or one root design document.
It already has the **document seams** of an execution core:

- responsibility seams in `agents/`
- handoff seams in `contracts/`
- one invocation seam in `skills/pge-execute/`
- one explicit runtime-state seam in `contracts/runtime-state-contract.md`
- richer governance/reference docs in `phase-contract.md`, `evaluation-gate.md`, and `progress-md.md`

Current anchors:
- `agents/planner.md`
- `agents/generator.md`
- `agents/evaluator.md`
- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `contracts/entry-contract.md`
- `contracts/round-contract.md`
- `contracts/evaluation-contract.md`
- `contracts/routing-contract.md`
- `contracts/runtime-state-contract.md`

So the truthful current position is:

> The repo has a doc-defined execution-core skeleton, but it does not yet have a proven runtime implementation.

What does **not** yet exist:
- no `runtime/` implementation substrate
- no mechanized orchestration loop
- no fully normalized progress-consensus contract
- no proven hook/capture pipeline
- no evidence yet that the current seams remain stable across real multi-round work

## 4. Current normalization status

The repo is not yet fully semantically unified.
The newer role and contract files are the cleanest normalized execution-core seams.
Several older governance docs still carry richer or partially different semantics.

### Normative execution-core seams

**For proving runs, these files are the source of truth for runtime state, verdict, and routing decisions:**
- `agents/*.md`
- `contracts/*.md`
- `skills/pge-execute/SKILL.md`

All runtime state transitions, verdict interpretations, and route decisions during proving must be expressible through these normalized seams.

### Supporting governance/reference docs

Use these as supporting references to enrich interpretation, but they must not silently override the normalized contract set:
- `phase-contract.md`
- `evaluation-gate.md`
- `progress-md.md`

### Known mismatches to keep explicit

Examples:
- `evaluation-gate.md` still uses richer score-based review and `Shrink and retry`
- `contracts/evaluation-contract.md` normalizes verdicts as `PASS`, `RETRY`, `BLOCK`, and `ESCALATE`
- `progress-md.md` still treats `progress.md` as the canonical state file and uses `Main / Scheduler` language
- `contracts/runtime-state-contract.md` defines the canonical minimum runtime state record more abstractly
- `phase-contract.md` still carries stronger phase/task and plan-fidelity semantics than the current `round-contract.md`

Alignment rule for v1 proof:
- routes used in proof must be expressible through `contracts/routing-contract.md`
- state transitions used in proof must be expressible through `contracts/runtime-state-contract.md`
- verdicts used in proof must be expressible through `contracts/evaluation-contract.md`
- older governance docs may enrich interpretation, but they must not introduce route/state/verdict vocabulary that contradicts the normalized seams

## 5. Scope of this document

This document does two jobs at once:
1. carry the reviewed overall strategy in runtime-centered form
2. define the execution-core design that the repo should prove next

It therefore should define:
- where PGE sits inside the larger harness system
- what kind of upstream input may enter PGE
- what the canonical execution loop is
- what state, verdict, and routing semantics the runtime must preserve
- what proof path should be used to validate the current design

It should not try to fully define:
- native shaping protocols
- a whole-system workflow platform
- heavy multi-skill or multi-agent orchestration
- a complete hooks platform
- final progress-consensus design for every future use case

## 6. Why PGE is the first foothold

PGE is the correct first ownable core because execution is the part most likely to collapse into vague chat unless it has:
- bounded contracts
- independent acceptance
- explicit routing
- explicit state continuity

Upstream shaping can be borrowed for now.
Progress consensus and improvement capture can be staged in later.
But execution-core semantics cannot be skipped if the system is to become real.

That means the strategic question is not:
- how to make PGE pretend to be the whole harness

It is:
- how to make PGE a stable execution core inside the larger harness system

## 7. Upstream boundary

PGE does not own clarify-first shaping.
For now, it assumes that Layer 1 and Layer 2 have already produced an upstream plan artifact that is shaped enough to enter execution.

### Accepted upstream input

PGE currently accepts an upstream plan only when it already provides:
- a concrete execution goal
- a boundary that can be preserved in execution
- a named deliverable or clear deliverable target
- a plausible verification path

This aligns with:
- `contracts/entry-contract.md`

### Reject conditions

Do not start the PGE loop when the upstream plan is:
- clarify-first instead of execute-first
- missing a concrete goal
- missing a meaningful boundary
- missing deliverable shape
- missing a plausible verification path
- so ambiguous that Planner cannot freeze one bounded current round

### Why this boundary matters

If PGE absorbs clarify-first work, the execution core loses its boundary and starts behaving like a generic planning wrapper around chat.
That would destroy the seam we are trying to prove.

## 8. Canonical execution-core responsibilities

PGE is responsible for the following behaviors:

1. **Entry check**
   - decide whether the upstream plan may enter execution

2. **Bounded round formation**
   - freeze exactly one current round contract
   - reject hidden planning spillover

3. **Preflight / contract-ack**
   - confirm that the frozen round contract is executable without guessing
   - confirm that acceptance, evidence, and deviation expectations are explicit enough for independent evaluation
   - fail back to planning/routing if the contract is not executable as written
   - preflight is represented as explicit runtime states: `preflight_pending` and `preflight_failed`

4. **Execution against the round contract**
   - execute only the current round
   - produce the named deliverable
   - return evidence and unverified areas

5. **Independent evaluation handoff**
   - hand off artifact and evidence for independent judgment
   - prevent generator self-certification

6. **Explicit routing**
   - translate verdict plus current state plus `run_stop_condition` into the next route
   - preserve why that route follows

7. **Explicit runtime state transitions**
   - preserve resumability across rounds
   - separate runtime state from conversational continuity

PGE is not responsible for:
- inventing the whole-system strategy from scratch
- owning native intent / shaping protocols yet
- turning plan formation itself into runtime semantics
- solving every progress/improvement concern before the loop is proven
- becoming a general workflow engine
- expanding immediately into broad multi-skill or multi-agent orchestration

## 9. Canonical loop

The current execution core should prove one stable control loop:

`upstream plan -> entry check -> planner -> round contract -> preflight / contract-ack -> generator -> deliverable + evidence -> evaluator -> verdict -> main/router -> next state`

Preflight sits between round contract freeze and generation start. It is represented as explicit runtime states (`preflight_pending`, `preflight_failed`) in the state model.

This is the minimum loop that preserves:
- bounded execution
- independent acceptance
- explicit routing
- explicit state continuity

### Role and contract ownership inside the loop

- Planner owns bounded round formation
- Generator owns deliverable and evidence production
- Evaluator owns independent acceptance
- Main / Router owns next-state decisions

Canonical references:
- `agents/planner.md`
- `agents/generator.md`
- `agents/evaluator.md`
- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `contracts/round-contract.md`
- `contracts/evaluation-contract.md`
- `contracts/routing-contract.md`

This document should not duplicate those files in detail.
It should define how they fit together as runtime orchestration.

## 10. Runtime state, verdict, and routing semantics

The first runtime does not need a large platform.
It does need one explicit state model, one explicit verdict model, and one explicit route model.

### State model

Canonical reference:
- `contracts/runtime-state-contract.md`

Minimum identity seams:
- `upstream_plan_ref`
- `active_slice_ref`
- `active_round_contract_ref`
- `run_stop_condition`

Minimum states:
- `intake_pending`
- `planning_round`
- `preflight_pending`
- `preflight_failed`
- `ready_to_generate`
- `generating`
- `awaiting_evaluation`
- `evaluating`
- `routing`
- `converged`
- `failed_upstream`

Preflight states:
- `preflight_pending`: round contract frozen, awaiting preflight confirmation
- `preflight_failed`: preflight determined contract is not executable or independently evaluable as written

Allowed transitions:
- `intake_pending -> planning_round`
- `intake_pending -> failed_upstream`
- `planning_round -> preflight_pending`
- `planning_round -> failed_upstream`
- `preflight_pending -> ready_to_generate`
- `preflight_pending -> preflight_failed`
- `preflight_failed -> planning_round`
- `ready_to_generate -> generating`
- `generating -> awaiting_evaluation`
- `generating -> routing`
- `awaiting_evaluation -> evaluating`
- `evaluating -> routing`
- `routing -> planning_round`
- `routing -> generating`
- `routing -> converged`

Transition rule:
- no hidden state change is valid unless the route reason is explicit

### Verdict model

Canonical reference:
- `contracts/evaluation-contract.md`

Minimum verdicts:
- `PASS`
- `RETRY`
- `BLOCK`
- `ESCALATE`

Interpretation rule:
- choose the narrowest verdict that explains the failure correctly
- use `RETRY` when local repair inside the current round is enough
- use `BLOCK` when a required condition is missing or violated but the current round remains the right repair frame
- use `ESCALATE` when the current round is no longer the right repair frame

### Route model

Canonical reference:
- `contracts/routing-contract.md`

Minimum routes:
- `continue`
- `retry`
- `return_to_planner`
- `converged`

Routing rule:
- route must follow from verdict plus current state
- if Main cannot explain that link explicitly, the runtime is not stable enough yet

### Default verdict -> route -> state effect

- `PASS` -> `continue` or `converged`
  - route to `continue` when the current round is accepted and `run_stop_condition` is not yet satisfied
  - route to `converged` when the accepted round satisfies `run_stop_condition`
  - Router checks `run_stop_condition` mechanically (e.g., `single_round`, `slice_complete`, `goal_satisfied`, `deliverable_count:N`) instead of interpreting prose
- `RETRY` -> `retry` -> return to `generating`
  - use when local repair inside the same bounded round is enough
- `BLOCK` -> default `retry` -> return to `generating`
  - keep `BLOCK` local when the required condition is missing or violated but the current round remains the correct repair frame
  - upgrade to `return_to_planner` only when the missing or violated condition shows that the current round is no longer the correct repair frame
- `ESCALATE` -> default `return_to_planner` -> return to `planning_round`
  - use when the current round is no longer the correct repair frame and simple retry would only repeat the mismatch

## 11. Failure semantics

The first runtime must make failure behavior explicit.

### Intake failure
- condition: upstream plan fails entry conditions
- route: do not enter the PGE loop
- state result: `failed_upstream`

### Planner / preflight failure
- condition: Planner cannot freeze one bounded round cleanly, or preflight cannot acknowledge the contract as executable and independently evaluable
- route: `return_to_planner` or upstream failure depending on whether the issue is local ambiguity or invalid intake
- state result: remain in planning lane with explicit reason, or transition to `preflight_failed` then back to `planning_round`

### Generator failure
- condition: Generator cannot execute without guessing, or cannot produce the named deliverable/evidence handoff
- route: `routing`
- allowed next outcomes: `retry` or `return_to_planner`

### Evaluator failure
- condition: required evidence is missing, contract is violated, or deviation remains unresolved
- route: `routing`
- allowed next outcomes: `retry`, `return_to_planner`, or `converged` only if evaluation passes

### Router failure
- condition: Main / Router cannot explain why the next state follows from verdict plus current state
- rule: this is a runtime-design error, not a soft concern
- state result: stop and surface the missing routing rationale

## 12. Relationship to adjacent layers

This runtime doc should acknowledge adjacent layers without collapsing them into the execution core.

### Relationship to shaping and planning
- intent / shaping remain upstream
- the plan artifact remains the entry artifact, not the runtime itself

### Relationship to progress consensus
- progress consensus matters because long-running work needs a visible current truth surface
- `progress-md.md` is useful guidance for that surface
- but progress consensus is adjacent to runtime state rather than identical to it
- the next proof should test their interaction without prematurely merging them into one abstraction

### Relationship to improvement
- round-end, evaluation, and session-end capture matter to the larger harness
- but the current job of PGE is to expose stable seams that those later layers can consume
- do not mistake future improvement capture for current runtime proof

## 13. Risks and mitigations

### Risk 1: runtime scope collapses back into whole-system design
Failure mode:
- the doc drifts into full shaping, progress, hook, and platform design and stops being a usable execution-core guide

Mitigation:
- keep the proof target centered on Layer 3
- acknowledge adjacent layers without absorbing them

### Risk 2: plan artifact and runtime get conflated
Failure mode:
- the upstream plan is treated as if it already contains bounded round semantics, evaluator independence, and routing discipline

Mitigation:
- preserve the boundary between plan-artifact intake and runtime orchestration
- force Planner to freeze one current round contract explicitly

### Risk 3: legacy governance docs silently override normalized contracts
Failure mode:
- proof work starts using `shrink`, score-based evaluation, or `progress.md` assumptions that are not represented in the normalized state/verdict/route seams

Mitigation:
- treat `agents/*.md`, `contracts/*.md`, and `skills/pge-execute/SKILL.md` as the normative execution-core seam set
- use older governance docs only when their semantics can be mapped explicitly to the normalized contracts

### Risk 4: maturity is overstated
Failure mode:
- the repo starts talking as if it already has a runnable harness runtime when it only has a document skeleton

Mitigation:
- state plainly that the repo has a doc-defined execution-core skeleton, not a proven implementation
- require real proving evidence before claiming runtime stability

### Risk 5: premature platform expansion
Failure mode:
- multi-agent runtime, multi-skill expansion, or workflow machinery arrive before one stable loop is proven, multiplying ambiguity instead of reducing it

Mitigation:
- require one real multi-round proof first
- add heavier machinery only when runtime friction demonstrates the need

## 14. Phased roadmap

### Phase 0: strategy framing

Goal:
- carry the reviewed overall strategy
- place PGE correctly inside the larger harness system
- keep the repo honest about its current maturity

Deliverable:
- this runtime-centered strategic document
- the companion strategy document in `docs/design-plans/harness-system-strategy.md`

### Phase 1: execution-core proof

Goal:
- prove one stable PGE execution loop over a real upstream plan

Scope:
- entry check
- bounded round formation
- execution against one current round
- independent evaluation
- explicit route and state transitions

Success criteria:
- one real plan survives multiple rounds without semantic collapse
- evaluator verdicts actually affect routing
- state remains resumable without reconstructing the run from chat alone
- role and contract boundaries remain visible under pressure

Proof protocol:
- use one real upstream plan that satisfies `contracts/entry-contract.md`
- exercise at least two routed rounds
- exercise at least one non-pass repair path: either `retry` or `return_to_planner`
- persist runtime state using the fields defined in `contracts/runtime-state-contract.md`
- record evaluator verdicts using the semantics in `contracts/evaluation-contract.md`
- record route decisions using the semantics in `contracts/routing-contract.md`
- update a progress artifact after each routed step

Fail the proof if any of the following happens:
- a state transition cannot be explained by explicit route reason
- a route outcome depends on hidden prose-only judgment not represented in the normalized contracts
- runtime state and progress record diverge without an explicit reconciliation rule
- the loop can proceed only by collapsing Planner, Generator, Evaluator, and Router responsibilities into one lane

### Phase 2: progress consensus and improvement seam proof

Goal:
- make runtime truth and friction capture more explicit without prematurely platformizing them

Scope:
- explicit runtime-state updates
- explicit progress updates at round boundaries
- visible route reasons and unresolved areas
- first friction-capture path from runtime pressure to design repair

Success criteria:
- the next round can resume from recorded state plus progress without reopening the whole discussion
- runtime state and progress remain distinct but cooperative
- repeated friction can be classified at the correct layer

### Phase 3: selective expansion

Only after Phase 1 is real should the repo consider:
- stronger retry / escalation handling
- stronger progress-consensus formalization
- stronger hook / improvement capture
- selective internalization of shaping when repeated runtime pressure justifies it
- additional skills only when they genuinely share the same runtime substrate
- stronger agentization if it solves a demonstrated runtime bottleneck

## 15. Immediate next step

The next highest-value move is:

**use one real proving task to test whether the current doc-defined PGE execution-core skeleton can support the plan -> round -> artifact + evidence -> verdict -> route -> next-state loop.**

Why this is next:
- the execution-core skeleton already exists in document form
- the largest remaining unknown is whether the current seam set survives real multi-round work
- more document layering will not answer that by itself

Do not do now:
- do not turn this repo into a workflow platform
- do not expand into many skills before the current execution core is proven
- do not claim runtime maturity that the repo has not yet earned
