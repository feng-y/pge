# PGE Harness Runtime

## 1. Role in the overall harness system

PGE is **Layer 3: execution core** inside a larger harness system.

The full system thesis now lives in:
- `docs/design-plans/harness-system-strategy.md`

That larger system spans:
- intent / shaping
- planning / plan artifact formation
- execution
- evaluation
- routing
- state
- progress consensus
- improvement

This document does **not** redefine that whole system.
This document defines the **runtime strategy for the PGE execution core**.

In other words:
- `harness-system-strategy.md` answers: **what system are we building overall?**
- `pge-harness-runtime.md` answers: **what should the Layer 3 execution core do, and how should this repo evolve to prove it?**

## 2. Scope of this document

This document owns **runtime orchestration semantics** for PGE.

It should define:
- what kind of upstream input may enter PGE
- what the canonical execution loop is
- what state and routing semantics the runtime must preserve
- what failure semantics the runtime must make explicit
- what proving path should be used to validate the current execution-core design

It should **not** define:
- whole-system strategy
- native intent-shaping protocols
- broad plan-artifact taxonomy beyond what PGE currently consumes
- general workflow-platform orchestration
- immediate multi-agent or multi-skill architecture
- full progress/improvement system design for the whole harness

Canonical ownership stays split:
- `agents/*.md` define role responsibilities
- `contracts/*.md` define handoff and state contracts
- this document defines how those pieces run together as one execution core

## 3. Current repo position

The repo is still doc-defined, but its docs are now partitioned around runtime seams instead of living in one root prompt or one root design document.

Today it already has the **contractual shape** of an execution core:
- `agents/` for responsibility seams
- `contracts/` for handoff seams
- `skills/pge-execute/` for the current invocation seam
- `contracts/runtime-state-contract.md` for explicit runtime-state identity and transitions
- `progress-md.md` and `evaluation-gate.md` as richer governance references

Concretely:
- `agents/planner.md` describes freezing one bounded round
- `agents/generator.md` describes executing that round and returning evidence
- `agents/evaluator.md` describes independent acceptance
- `agents/main.md` describes route decisions
- `contracts/entry-contract.md` defines intake conditions
- `contracts/round-contract.md` defines minimum round handoff
- `contracts/evaluation-contract.md` defines verdict semantics
- `contracts/routing-contract.md` defines route meanings
- `contracts/runtime-state-contract.md` defines minimum state and transitions

So the repo's true current position is:

> It has a doc-defined execution-core seam partition, but not yet a proven execution-core protocol.

That is why this document should stay narrow.
The next job is to prove one stable execution core, not to redesign the whole harness at once.

### Current semantic mismatches that are still unresolved

The repo is not yet fully semantically unified.
Several older governance docs still carry stronger or partially different operational semantics than the current contract set.

Examples:
- `progress-md.md` still says `progress.md` is the canonical state file, uses `Main / Scheduler` language, and references routes such as `shrink`
- `evaluation-gate.md` still uses richer review scoring and `Shrink and retry` language
- `phase-contract.md` still carries stronger plan-fidelity and phase/task language than the current round contract

For current v1 proof, the alignment rule is:
- `agents/*.md` and `contracts/*.md` are the normative execution-core seams
- root governance docs are supporting references unless and until their stronger semantics are promoted into the contract set
- any route used in proof must be expressible through `contracts/routing-contract.md`
- any state transition used in proof must be expressible through `contracts/runtime-state-contract.md`

## 4. Upstream input boundary

PGE does not own clarify-first shaping.
For now, PGE assumes that Layer 1 and Layer 2 have already produced an upstream plan artifact that is shaped enough to enter execution.

Current working assumption:
- upstream shaping and plan formation are borrowed for now
- PGE begins at execution intake

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

If PGE absorbs clarify-first work, the execution core loses its boundary and starts behaving like a generic planning/chat wrapper.
That would collapse the runtime center we are trying to prove.

## 5. Runtime responsibilities

PGE is responsible for the following execution-core behaviors:

1. **Entry check**
   - decide whether the upstream plan may enter execution

2. **Bounded round formation**
   - freeze exactly one current round contract
   - reject hidden planning spillover

3. **Execution against the round contract**
   - execute only the current round
   - produce the named deliverable
   - return evidence and unverified areas

4. **Independent evaluation handoff**
   - hand off artifact and evidence for independent judgment
   - prevent generator self-certification

5. **Explicit routing**
   - translate verdict plus current state into the next route
   - preserve the reason for that route

6. **Explicit runtime state transitions**
   - preserve resumability across rounds
   - separate runtime state from conversational continuity

## 6. What PGE is not responsible for

PGE is not responsible for:
- inventing the whole-system strategy
- owning native intent / shaping protocols yet
- turning plan formation into runtime semantics
- solving full progress-consensus design for the whole harness
- owning long-term rule memory by itself
- becoming a general workflow engine
- expanding immediately into a broad multi-skill or multi-agent runtime

This boundary is important.
If PGE tries to solve the whole harness in one phase, the repo will drift into platform design before one real execution loop works.

## 7. Canonical loop

The current execution core should prove one stable control loop:

`upstream plan -> entry check -> planner -> round contract -> generator -> deliverable + evidence -> evaluator -> verdict -> main/router -> next state`

This is the minimum loop that preserves:
- bounded execution
- independent acceptance
- explicit routing
- explicit state continuity

### Role ownership inside the loop

- Planner owns bounded round formation
- Generator owns deliverable and evidence production
- Evaluator owns independent acceptance
- Main / Router owns next-state decisions

Canonical references:
- `agents/planner.md`
- `agents/generator.md`
- `agents/evaluator.md`
- `agents/main.md`
- `contracts/round-contract.md`
- `contracts/evaluation-contract.md`
- `contracts/routing-contract.md`

This document should not duplicate those files in detail.
It should only define how they fit together as runtime orchestration.

## 8. Runtime state model

The first runtime does not need a large state platform.
It does need one explicit state model.

The canonical state definition lives in:
- `contracts/runtime-state-contract.md`

### Minimum identity seams

A runtime state must distinguish:
- `upstream_plan_ref`
- `active_slice_ref`
- `active_round_contract_ref`

These seams matter because:
- the upstream plan may remain stable across multiple bounded slices
- the active slice may remain stable while Planner freezes a new current round
- the current round contract must update whenever the round changes

### Minimum states

- `intake_pending`
- `planning_round`
- `ready_to_generate`
- `generating`
- `awaiting_evaluation`
- `evaluating`
- `routing`
- `converged`
- `failed_upstream`

### Allowed transitions

- `intake_pending -> planning_round`
- `intake_pending -> failed_upstream`
- `planning_round -> ready_to_generate`
- `planning_round -> failed_upstream`
- `ready_to_generate -> generating`
- `generating -> awaiting_evaluation`
- `generating -> routing`
- `awaiting_evaluation -> evaluating`
- `evaluating -> routing`
- `routing -> planning_round`
- `routing -> generating`
- `routing -> converged`

### Transition rule

No hidden transition is valid unless the route reason is explicit.

That rule is part of the runtime center.
If state changes cannot be explained, the runtime is not stable enough yet.

## 9. Failure semantics

The first runtime must make failure behavior explicit.

### Intake failure
- condition: upstream plan fails entry conditions
- route: do not enter the PGE loop
- state result: `failed_upstream`

### Planner failure
- condition: Planner cannot freeze one bounded round cleanly
- route: `return_to_planner` or upstream failure depending on whether the issue is local ambiguity or invalid intake
- state result: remain in planning lane with explicit reason

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

## 10. Relationship to adjacent layers

This runtime doc should acknowledge adjacent layers without trying to absorb them.

### Upstream relationship
- intent / shaping and broader plan formation remain upstream of PGE
- for now, PGE depends on shaped input rather than owning shaping itself

### Side relationship: progress consensus
- `progress.md` guidance remains an important supporting reference
- but progress consensus is **adjacent** to the execution core, not identical to runtime state
- the next proving path should test how runtime state and progress interact without collapsing them into one object too early

### Downstream relationship: improvement
- round-end, evaluation, and session-end capture matter to the larger harness
- but the current PGE job is only to expose the seams that those later layers must consume
- do not turn this document into a whole-system hook design

## 11. Risks

### Risk 1: PGE expands back into whole-system strategy
If this document starts redefining shaping, planning taxonomy, progress design, and improvement design in full, it will drift beyond Layer 3 and duplicate `harness-system-strategy.md`.

**Mitigation**
- keep this doc focused on execution-core orchestration
- treat broader system design as reference, not as local scope

### Risk 2: plan artifact and runtime get conflated
If the upstream plan is treated as the runtime itself, then bounded round formation, evaluation independence, routing, and state discipline will weaken.

**Mitigation**
- preserve the boundary between plan artifact intake and runtime orchestration

### Risk 3: progress remains implicit
If progress stays only as conversational continuity, cross-round state will leak back into chat reconstruction.

**Mitigation**
- use the next proving path to test explicit interaction between runtime state and progress guidance
- avoid prematurely merging them into one abstraction

### Risk 4: premature platform expansion
If multi-agent runtime, multi-skill expansion, or workflow machinery arrives before one stable loop is proven, ambiguity will scale faster than capability.

**Mitigation**
- keep the proving target narrow
- require real runtime friction before adding heavier machinery

## 12. Proving roadmap for this repo

### v0: structure-first skeleton

What now exists:
- role seams in `agents/`
- handoff seams in `contracts/`
- one invocation seam in `skills/pge-execute/`
- one runtime-state seam in `contracts/runtime-state-contract.md`
- this runtime strategy as the Layer 3 execution-core framing

### v1: single PGE execution-loop proof

Objective:
- prove one stable multi-round execution loop over a real upstream plan

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
- a route outcome depends on hidden prose-only judgment not represented in the runtime contracts
- runtime state and progress record diverge without an explicit reconciliation rule
- the loop can proceed only by collapsing Planner, Generator, Evaluator, and Router responsibilities into one lane

### v1.5: state/progress seam proof

Objective:
- test the interaction between runtime state and progress guidance without prematurely platformizing either one

Scope:
- explicit runtime-state updates
- explicit progress updates at round boundaries
- visible route reasons and unresolved areas

Success criteria:
- the next round can resume from recorded state plus progress without reopening the whole discussion
- runtime state and progress remain distinct but cooperative

### Later

Only after v1 is real should the repo consider:
- stronger retry / escalation handling
- stronger progress-consensus formalization
- stronger hook / improvement capture
- additional skills that genuinely share the same runtime substrate
- stronger agentization if it solves a demonstrated runtime bottleneck

## 13. Immediate next step

The next highest-value move is:

**run one real proving task through the current Layer 3 execution core and use it to validate the plan -> round -> artifact+evidence -> verdict -> route -> next-state loop.**

Why this is next:
- the execution-core skeleton is already in place
- the biggest unknown is not more document structure
- the biggest unknown is whether the designed runtime survives real multi-round work

Do not do now:
- do not turn this repo into a workflow platform
- do not broaden this doc back into whole-system strategy
- do not expand into many skills before the current execution core is proven
