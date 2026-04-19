# Harness System Strategy

## 1. System thesis

We are not building a single skill, a single execution loop, or a workflow platform that happens to contain PGE.

We are building an **end-to-end harness system** that carries work from:

`intent -> shaping -> planning -> execution -> evaluation -> routing -> state -> improvement`

The system thesis is:

- **The product is the harness**, not the plan artifact and not the execution loop alone.
- **PGE is the first execution-core foothold**, not the whole system.
- **Long-running work should remain stable through structure, contracts, state, and routing**, not through conversational memory or one large root prompt.

What this system is:
- a way to turn intent into bounded executable work
- a way to keep multi-round execution stable and resumable
- a way to make acceptance independent from generation
- a way to turn friction into runtime and contract improvement

What this system is not:
- not a pile of task-specific skills
- not a plan-following wrapper around chat
- not a copy of Anthropic's internal harness runtime
- not a multi-agent platform built before one real loop is proven
- not a review ceremony masquerading as runtime design

Why PGE is only one part:
- the current repo already contains the minimal skeleton of an execution runtime
- the overall harness still needs explicit treatment of intent intake, shaping, progress consensus, hooks, capture, and improvement
- therefore the strategic question is not "how to expand PGE into the whole system" but "how PGE fits inside the whole system"

## 2. Strategic layers

### Layer 1: Intent / Shaping

**Purpose**
- receive raw user intent
- identify unknowns, constraints, success criteria, and ambiguity
- decide whether the request is ready for planning or still needs shaping

**Input**
- raw request
- surrounding context
- explicit and implicit constraints

**Output**
- a shaped problem packet that is ready for planning
- or a clear rejection back to clarify / brainstorm discipline

**Current strategy**
- borrow this layer from Superpower-style upstream shaping
- do not absorb clarify-first work into PGE

**Why borrow first**
- the repo already has execution-core seams but does not yet have a proven runtime loop
- upstream shaping is useful immediately, but it is not yet the bottleneck
- borrowing shaping lets us avoid overbuilding the top of the stack before the middle is real

**When to internalize later**
Internalize this layer when one or more of the following becomes true:
- upstream plans repeatedly fail entry conditions
- the meaning of the plan artifact is unstable at intake
- different task classes require distinct shaping protocols
- execution friction repeatedly traces back to missing or weak shaping

**Non-goals now**
- building a native clarify protocol system
- building a general intent router
- making PGE responsible for upstream ambiguity repair

### Layer 2: Planning / Plan artifact

**Purpose**
- convert a shaped problem into an execution-authorizing artifact
- define what kind of work should enter execution and what should not

**Primary artifact types**
- writing-plan
- exec-plan
- proving packet

**Role in the system**
The plan artifact is the **entry artifact** for execution, not the runtime itself.

It should provide at least:
- a concrete execution goal
- an identifiable boundary
- a named deliverable shape
- a plausible verification direction

This aligns with `contracts/entry-contract.md`.

**Important boundary**
A plan artifact does not solve:
- bounded round formation
- execution semantics
- evaluator independence
- route decisions
- state carry across rounds

Those belong to the harness runtime.

**Strategic consequence**
- we should treat the plan as a necessary upstream input
- we should not confuse "good plan formation" with "having a harness system"

### Layer 3: Execution core (PGE)

**Purpose**
PGE is the first runtime core that turns a valid plan artifact into a controlled multi-round execution loop.

**Current responsibilities**
- perform entry check on upstream plan
- freeze one bounded current round contract
- execute only that contract
- produce deliverable plus evidence
- evaluate independently against artifact and evidence
- route explicitly to the next runtime state

**Current repo anchors**
Responsibility layer:
- `agents/planner.md`
- `agents/generator.md`
- `agents/evaluator.md`
- `agents/main.md`

Handoff layer:
- `contracts/entry-contract.md`
- `contracts/round-contract.md`
- `contracts/evaluation-contract.md`
- `contracts/routing-contract.md`
- `contracts/runtime-state-contract.md`

Invocation layer:
- `skills/pge-execute/SKILL.md`

Execution-core runtime plan:
- `docs/design-plans/pge-harness-runtime.md`

**What PGE is responsible for**
- execution semantics
- bounded round discipline
- independent evaluation handoff
- route-aware continuation
- explicit state transitions

**What PGE is not responsible for**
- upstream shaping and clarify-first work
- whole-system progress capture policy
- long-term rule memory by itself
- general workflow orchestration
- immediate multi-skill or multi-agent expansion

**Why it is the first foothold**
Execution is the part most likely to collapse into vague chat unless it has:
- bounded contracts
- independent acceptance
- explicit routing
- state continuity

That makes execution core the right first place to build our own system rather than borrowing somebody else's whole runtime.

### Layer 4: Evaluation / Routing / State

This layer is the real runtime backbone. It is not a sidecar around generation.

#### Evaluation
**Purpose**
- judge deliverable quality against contract and evidence
- reject self-certification
- distinguish local repair from contract mismatch

**Why it matters**
Without independent evaluation, execution turns into generator narrative plus confidence.

#### Routing
**Purpose**
- translate verdict plus current state into the next explicit route
- preserve why the route follows

**Why it matters**
Without routing, the system drifts into "probably continue" instead of governed progression.

#### State
**Purpose**
- make runtime identity and transitions explicit
- preserve resumability across rounds
- separate runtime state from conversation state

**Why it matters**
Without explicit state, long-running work depends on chat reconstruction and hidden continuity.

**System loop**
The canonical loop is:

`plan artifact -> entry check -> planner -> round contract -> generator -> deliverable + evidence -> evaluator -> verdict -> router -> next state`

This is the minimum structure that gives us:
- bounded execution
- independent acceptance
- explicit route semantics
- resumable multi-round work

### Layer 5: Progress consensus

**Purpose**
Progress is not just a record. It is the **shared current-state consensus surface**.

It should answer:
- what run is active
- what bounded slice is active
- what current round is active
- what deliverable and evidence currently exist
- what the latest verdict is
- what blockers remain open
- what the latest route is
- what happens next

**Relation to runtime state**
Progress consensus is not identical to runtime state.

- **runtime state** is the minimum machine-governing state for control and transition
- **progress consensus** is the human-runtime shared current fact surface

We need both.

**Why it is not a normal log**
A log records events.
A progress consensus object freezes the current agreed execution fact pattern.

If progress becomes a diary, it fails.
If progress becomes a full plan, it fails.
If progress fails to reflect current route and blockers, the next round starts from drift.

**Strategic role**
This layer is where the system gains:
- resumability without re-inflating context
- role-to-role coordination
- cross-session continuity
- a stable current truth surface

### Layer 6: External hooks / capture / improvement

This is where the harness becomes evolvable instead of merely runnable.

#### Round-end hook
Purpose:
- summarize the round outcome
- update progress consensus
- record route reason
- expose local friction and unresolved ambiguity

#### Evaluation hook
Purpose:
- capture repeated evidence failures
- capture contract mismatch patterns
- distinguish local execution failure from runtime design failure

#### Session-end hook
Purpose:
- identify what should become durable rules
- identify what should become future proving backlog
- discard one-off residue that should not become system memory

#### Improvement loop
The improvement loop is not "self-evolution" in a mystical sense.
It is:

`execution feedback -> friction capture -> classify -> repair at the right layer -> update runtime / contract / rule`

**Minimum friction classes**
- shaping failure
- plan artifact failure
- execution-core failure
- evaluation / routing / governance failure
- state / progress consensus failure

**Why this layer matters**
Without it, the system can run, but it cannot learn where its seams are weak.
With it, the harness can improve in response to actual runtime pressure instead of abstract completeness goals.

## 3. Source absorption map

### Anthropic

**What we absorb**
- planner / generator / evaluator separation
- external evaluator posture
- loop plus handoff as the stable long-task frame
- structure as the stabilizer for long-running work

**Where it lands**
- Layer 3: execution core role separation
- Layer 4: evaluation, routing, and explicit state loop
- Layer 5: progress as explicit continuity instead of conversational memory

**What we do not import**
- Anthropic-specific runtime internals
- Anthropic-specific topology or orchestration assumptions
- internal tool assumptions, isolation assumptions, or hidden harness implementation details

### Superpower

**What we absorb**
- brainstorming discipline
- clarify discipline
- writing-plan / exec-plan formation

**Where it lands**
- Layer 1: intent / shaping
- Layer 2: plan artifact formation

**What we do not import**
- the assumption that plan-following equals runtime
- the assumption that exec-plan is itself a durable execution loop
- the idea that upstream shaping should absorb execution governance

### GSD

**What we absorb**
- phase and slice progression
- bounded rounds
- context discipline and anti-rot thinking
- route-aware multi-step advancement

**Where it lands**
- Layer 2: bounded planning expectations
- Layer 3: planner freeze discipline for one current round
- Layer 5: progress consensus as visible state instead of hidden continuity

**What we do not import**
- heavy workflow infrastructure
- full SDK or orchestration machinery
- a protocol-heavy subagent system before core runtime proof exists

### gstack

**What we absorb**
- judgment pressure
- clear route outcomes
- explicit decision points around execution

**Where it lands**
- Layer 4: evaluation and routing semantics
- Layer 6: evaluation hook and governance pressure on continuation decisions

**What we do not import**
- heavy review ceremony
- turning the harness into a review platform
- forcing a large explicit governance stack before runtime seams are proven

## 4. Why this path

The recommended sequence is:

1. borrow Superpower-style upstream plan formation
2. build our own PGE execution runtime core
3. gradually internalize intent / shaping
4. gradually deepen execution, evaluation, routing, state, hooks, and improvement

### Why not build the whole stack first

Because we do not yet know enough to safely platformize the whole system.

If we start with a full-stack harness platform, we will lock in assumptions about:
- top-of-funnel shaping semantics
- routing semantics
- state model breadth
- improvement capture shape
- skill topology

before one real loop has been proven.

**Risk**
- Failure mode 1: we build a coherent architecture around unproven seams, then discover the real runtime pressure lives elsewhere.
- Failure mode 2: we prematurely standardize interfaces that later proving will show are the wrong boundaries.

**Mitigation**
- prove one real execution loop first
- let real proving friction determine which seams deserve system-level formalization next

### Why not start with multi-agent runtime

Because role multiplication does not solve missing semantics.

If bounded contract, evaluation semantics, routing semantics, and state semantics are weak, then multiple agents only multiply ambiguity.

**Risk**
- Failure mode: ambiguity is parallelized instead of reduced, producing noisier handoffs with no stronger acceptance logic.

**Mitigation**
- first prove one stable loop with explicit role boundaries and contracts
- only introduce stronger agentization when it solves a demonstrated runtime bottleneck

### Why PGE is the correct first foothold

PGE sits at the system's force center:
- upstream shaping can be borrowed temporarily
- downstream capture can be staged in later
- but execution-core semantics cannot be skipped if the system is to be real

A plan without a runtime is just an artifact.
A runtime without evaluation and routing is just an execution attempt.
A runtime without state is just chat continuity.

Therefore the first ownable strategic core should be the execution runtime.

### Why this also matches the current repo

The current branch is already beyond doc-only shape.
It already has:
- responsibility seams in `agents/`
- handoff seams in `contracts/`
- one invocation seam in `skills/pge-execute/`
- a runtime-state seam in `contracts/runtime-state-contract.md`
- a runtime construction draft in `docs/design-plans/pge-harness-runtime.md`

That means the repo is already positioned as an **execution-core skeleton**.
The missing piece is not another local patch. The missing piece is the strategic frame that places that skeleton inside the full harness system.

## 5. Phased roadmap

### Phase 0: Strategy framing

**Goal**
- define the harness system thesis and strategic layers
- place PGE correctly inside the whole system
- define the sequencing logic for what comes next

**Scope**
- overall system map
- source absorption map
- sequencing rationale
- repo-level role of PGE runtime design

**Deliverable**
- this strategy document
- agreement that `pge-harness-runtime.md` is execution-core design, not whole-system strategy

**Non-goals**
- no runtime directory expansion
- no multi-skill expansion
- no large contract rewrite
- no workflow platform design

### Phase 1: Execution runtime core proof

**Goal**
- prove one stable PGE execution loop over a real upstream plan

**Scope**
- entry check
- one bounded round freeze
- generator deliverable plus evidence
- independent evaluator verdict
- explicit route and state transition

**Deliverable**
- one multi-round proving path that stays stable under the current role and contract skeleton
- evidence that plan -> execution -> evaluation -> routing -> state can survive more than one round

**Non-goals**
- no native shaping system
- no heavy orchestration system
- no generalized multi-agent runtime
- no platform abstraction layer

### Phase 2: Progress consensus and improvement loop

**Goal**
- make runtime truth and friction capture first-class

**Scope**
- explicit progress consensus object
- round-end hook
- evaluation hook
- session-end hook
- friction classification and improvement capture

**Deliverable**
- a stable current-truth surface for runs
- a minimal closed loop from execution friction to system repair

**Non-goals**
- no global memory system for everything
- no fully automated governance platform
- no heavy metrics or observability stack

### Phase 3: Upward and downward expansion

**Goal**
- move upward into shaping where justified
- move downward into stronger runtime where justified

**Scope**
- selectively internalize shaping protocols
- strengthen retry / escalation semantics
- strengthen evaluation pressure
- add more skills only when they share the same runtime substrate
- strengthen state and hook machinery when real friction justifies it

**Deliverable**
- a broader harness system whose upper and lower layers grew from proven runtime needs

**Non-goals**
- no speculative platform completeness
- no skill proliferation without shared substrate proof
- no orchestration machinery without demonstrated need

## 6. Immediate next step

The single highest-value next step is:

**Use this strategy document as the top-level north-star reference, then align `pge-harness-runtime.md` explicitly as the Layer 3 execution-core document under it.**

Why this is the best next move:
- the repo already has enough local execution-core structure to continue
- what it lacks is the strategic frame that prevents local patches from pretending to be whole-system design
- without this framing, future work will keep oscillating between three wrong interpretations:
  - PGE is the whole system
  - plan artifacts are the harness
  - progress and hooks are optional side documents

This next step is intentionally narrow.
It does not require expanding runtime implementation yet.
It gives all future work a correct architectural target.

## 7. Suggested document layout in this repo

Recommended structure:

```text
docs/design-plans/
├── harness-system-strategy.md
└── pge-harness-runtime.md
```

Document roles:
- `harness-system-strategy.md`: overall harness thesis, layers, source absorption, sequencing, roadmap
- `pge-harness-runtime.md`: execution-core runtime design for the PGE layer

This preserves a clean separation:
- top-level system strategy above
- execution-core runtime design below

That separation is necessary so the repo can evolve from an execution-core skeleton into a full harness system without confusing one layer for the whole architecture.
