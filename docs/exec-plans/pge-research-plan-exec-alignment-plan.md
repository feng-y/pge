# PGE Research / Plan / Exec Function-Ownership Alignment Plan

## Goal

Use the user's four suggested axes as the **main backbone** of the assessment, but make the plan stronger by:

- evaluating which suggestions are right as-is
- correcting what is incomplete or too rough
- adding missing dimensions needed for a safe redesign
- turning the result into an actionable alignment plan

The goal is **not** generic simplification.
The goal is:

```text
clear function ownership
+ efficient context transfer
+ layered skill structure
+ preserved execution quality
```

for:

```text
intent -> research -> plan -> exec -> evidence / repair / review
```

## Non-Goals

- Do not collapse Research / Plan / Exec into one mega-skill.
- Do not weaken runtime quality to reduce hot-path size.
- Do not delete functions before identifying their downstream consumers and quality role.
- Do not assume that a large `SKILL.md` means the function itself is misplaced.
- Do not turn Dynamic Workflow into a second canonical planning surface.

## Why The User's Axes Are Right — And What They Miss

The user's four main axes are the correct backbone:

1. **Per-skill function list + whether it can be removed / weakened**
2. **Whether functions should be rearranged across skills**
3. **How context is passed, and why repeated rereading happens**
4. **How to aggregate / layer functions so large skills are structured rather than chaotic**

But they are not sufficient alone.

To make safe decisions, the plan also needs three additional axes:

5. **Producer / consumer / validator / evidence-consumer mapping**
   - A function cannot be removed just because it looks verbose.
   - We need to know who writes it, who reads it, who gates it, and who later depends on it.

6. **Function dependency and quality role**
   - Some functions are not visible in final artifacts, but they are still quality-critical runtime functions.
   - Example shape: Candidate Gate, Diagnostic Recovery, Final Plan Gate.

7. **Validator-aware debt-removal rule**
   - Do not defer clearly wrong debt just because validators are incomplete.
   - If a function/section is demonstrably wrong, harmful, owner-confusing, or consumerless, alignment work should fix, delete, demote, or move it in the current slice.
   - Validators are required before weakening high-risk or shared-contract functions whose consumers still rely on them.

So the full framework is:

```text
A. function inventory
B. cross-skill ownership
C. context transfer
D. layering / aggregation
E. producer-consumer-validator mapping
F. quality-role dependency
G. validator-aware debt-removal discipline
```

## Current Cross-Surface Model

The current stage model is still the right base model:

```text
user/current prompt
-> pge-research
-> .pge/tasks-<slug>/research.md
-> pge-plan
-> .pge/tasks-<slug>/plan.md + issues/Ixxx.md
-> pge-exec
-> .pge/tasks-<slug>/runs/<run_id>/*
```

Optional execution backend:

```text
plan.md
-> workflow-handoff.md
-> Dynamic Workflow runtime
-> workflow-result.md
```

The main problem is not the existence of these stages.
The main problems are:

- function/prose duplication
- unclear ownership of shared doctrine
- uneven context compression between stages
- oversized hot paths in `SKILL.md`
- insufficient mechanical validation of strong prose contracts

## Primary Stage-Core Interpretation

Before evaluating completeness, treat these as the **main parts** of the three skills:

### Research main part

`pge-research` is not only a brief writer. Its main part is:

- recover the real intent
- widen candidate framings through brainstorming when the prompt is fuzzy or solution-first
- grill those framings so the first plausible idea does not become the assumed goal
- reduce the result into a planning-safe problem contract

So brainstorming/grill is not just a "full version extra". It is part of Research's primary value when the request is underdefined, value-laden, or misleadingly solution-shaped.

### Plan main part

`pge-plan` is not only artifact emission or issue formatting. Its main part is:

- use plan-eng-review to close the gap between intended solution and actual repo / architecture reality
- select an executable approach that respects the inherited problem contract
- split the work into progressive, verifiable, executable slices
- make verification topology and execution order explicit enough that Exec does not guess

So Plan Engineering Review is not just a late hardening add-on. It is one of Plan's central solution-design functions.

### Exec main part

`pge-exec` is not only orchestration. Its main part is:

- consume a clear plan and issue contracts
- understand each issue deeply enough to strengthen, supplement, and complete the implementation inside the plan contract
- perform self-test and verification during execution, using TDD when it is the right behavior-feedback loop, or the strongest proportional verification when TDD would be artificial
- produce evidence that the implementation actually satisfied the plan contract

So implementation strengthening and self-test are primary Exec functions, not optional extras after dispatch.

## Unified Stage-Core Matrix

This matrix is the stricter cross-stage summary. It distinguishes:

- **Primary core** — if weakened, the stage stops being itself
- **Supporting core** — not the identity of the stage, but necessary for quality / usability / correct downstream handoff
- **Presentation / structure layer** — how the function is exposed or documented; may move or slim without changing real ownership

| Stage | Function / cluster | Classification | Owner | Main consumers | Can move? | Can weaken? | Parity risk if weakened/moved wrong |
|---|---|---|---|---|---|---|---|
| Research | A-vs-B intent recovery | Primary core | Research | Plan, user | No | No | Very high — solution hypothesis can replace user goal |
| Research | Brainstorming candidate framings for fuzzy / solution-first prompts | Primary core | Research | Research itself, then Plan | No | Only trigger-scoped, not capability-scoped | High — underexplores valid framings, locks too early |
| Research | Grill / challenge of candidate framings | Primary core | Research | Research itself, then Plan | No | Only trigger-scoped, not capability-scoped | High — first plausible framing becomes assumed truth |
| Research | Evidence / authority separation | Supporting core | Research | Plan, Review | Doctrine can centralize; application stays | Not as function | High — repo belief and user intent get conflated |
| Research | Implementation Friction / Progressive Feasibility / Core Friction Confirmation | Supporting core | Research | Plan, Exec, Review | No | No | High — Plan starts from unsafe or non-incremental assumptions |
| Research | Optional diagnostic lenses (`Four-Way Gap`, design/experience note, evidence notes) | Presentation/conditional support | Research | Plan, sometimes Review | Possibly to more conditional/reference use | Yes, selectively | Low to medium — mostly affects diagnosis richness, not base contract |
| Research | `research.md` emission | Supporting core | Research | Plan | No | No | Very high — no compressed problem contract |
| Plan | Direct prompt planning | Supporting core with primary ingress role | Plan | User, Exec indirectly | No | No | High — forces unnecessary upstream stage hopping |
| Plan | Fast Lane | Supporting core | Plan | User, Exec | No | Only if proportional replacement exists | Medium — LIGHT work becomes over-ceremonial |
| Plan | Fast Adopt | Supporting core | Plan | User, Exec, Workflow | No | No | High — external ready plans become manual or lossy to ingest |
| Plan | Plan-eng-review for closing intended-solution vs repo/architecture gap | Primary core | Plan | Exec, Review | No | No | Very high — plans stop being repo-real executable designs |
| Plan | Selected approach / rejected approaches / Architecture Delta Contract | Primary core | Plan | Exec, Workflow, Review | No | No | Very high — execution loses stable direction and boundary logic |
| Plan | Progressive executable slicing + verification coupling | Primary core | Plan | Exec, Workflow | No | No | Very high — Exec must guess sequencing, coupling, or proof strategy |
| Plan | Source Contract Check / Final Plan Gate / final sanity | Supporting core | Plan | Exec | No | No | Very high — execution authorization becomes weak or dishonest |
| Plan | `plan.md` + `issues/Ixxx.md` emission | Supporting core | Plan | Exec, Workflow, Review | No | No | Very high — no canonical execution contract |
| Plan | `workflow-handoff.md` generation | Supporting core | Plan | Dynamic Workflow backend | Keep owner; runtime detail can move | Not in first pass | Medium to high — backend loses safe adapter |
| Plan | DOT flow / repeated gate prose / some output ceremony (`Plan Grill Log`, `Quality Check Results`, explicit `Self-Evaluation`) | Presentation / structure layer | Plan docs/templates | Humans, sometimes Review | Yes | Maybe, after consumer scan | Low to medium unless an active consumer depends on it |
| Exec | Canonical-source enforcement / run selection / plan validation | Supporting core with primary ingress role | Exec | Runtime control plane | No | No | Very high — execution starts from wrong or stale source |
| Exec | Issue understanding + implementation strengthening/supplementation inside plan contract | Primary core | Exec | User outcome, Review | No | No | Very high — Exec degrades to shallow orchestration |
| Exec | Self-test during execution (TDD when right, proportional verification otherwise) | Primary core | Exec | Evaluator, final review, user trust | No | No | Very high — runtime gets fast but low quality |
| Exec | Candidate Gate | Supporting core | Exec main | Generator integration, Evaluator indirectly | No | No | Very high — malformed or weak candidates escape downstream |
| Exec | Targeted Evaluator + Repair Contract | Supporting core | Exec | Generator repair loop, final verification | No | No | High — cross-boundary defects stop getting bounded repair |
| Exec | Diagnostic Recovery / Watchdog / shared-tree contamination handling / fallback | Supporting core | Exec | Runtime stability | No | No | High — runtime becomes brittle or misleading |
| Exec | Final Evaluator verification + Exec QA Gate | Supporting core | Exec | final route, later review/challenge | No | No | Very high — execution success loses meaning |
| Exec | state.json / resumability / exception closure / run artifacts | Supporting core | Exec | resume path, repair path, review path | No | No | High — failures become unauditable and non-resumable |
| Exec | Packet schemas / lifecycle examples / wire detail in hot path | Presentation / structure layer | Exec handoffs/references | Humans, maintainers | Yes, to handoffs/references | Yes, presentation only | Low if behavior preserved; high if wire contracts drift |

### Matrix interpretation rules

1. If a row is **Primary core**, do not discuss removal before discussing whether the stage would still be the same stage.
2. If a row is **Supporting core**, do not weaken it blindly; first determine whether it is quality-bearing, actively consumed, or actually historical debt.
3. If a row is **Presentation / structure layer**, do not assume it is safe to cut — first verify that no active consumer depends on the current emitted shape.
4. When a function "can move," that usually means **presentation or doctrine can move**, not that stage ownership changes.
5. If a function/section is demonstrably wrong, consumerless, owner-confusing, or debt-amplifying, alignment should fix or remove it now rather than pushing it to a vague later cleanup.

## Per-Function Adversarial Matrix

Use this matrix when deciding whether to preserve, move, weaken, or refactor a function. It makes every important function answer the adversarial questions:

- what problem does this solve?
- who pays for it?
- who depends on it?
- what do we lose if we weaken it?
- what cost do we take on if we keep it?

### Research

| Function | Classification | Solves what problem? | Main consumers | Validator | Can move? | Can weaken? | Cost of keeping | What is lost if weakened/removed? |
|---|---|---|---|---|---|---|---|---|
| A-vs-B intent recovery | Primary core | Prevents the proposed solution from replacing the user's actual goal | Plan, user | Research self-review | No | No | More upfront reasoning on ambiguous prompts | Planning can optimize the wrong problem |
| Brainstorming candidate framings | Primary core | Expands candidate interpretations when prompt is fuzzy / solution-first | Research itself, then Plan | Research self-review | No | Only trigger-scoped | More token/time cost on ambiguous prompts | Viable framings are never surfaced; prompt gets overfit to first idea |
| Grill / challenge of candidate framings | Primary core | Forces adversarial pressure before planning commits to a direction | Research itself, then Plan | Research self-review | No | Only trigger-scoped | Additional reasoning cost and possible slower intake | Weak framing survives; later stages inherit hidden assumption drift |
| Evidence / authority separation | Supporting core | Prevents user belief, repo fact, and inference from being mixed | Plan, Review | Research self-review | Doctrine can move; application cannot | No as function | More doctrine text / classification burden | Plan treats guesses as constraints or repo behavior as user intent |
| Implementation Friction | Supporting core | Surfaces mismatch between expected system model and actual repo reality before Plan guesses | Plan | Research self-review | No | No | More repo investigation in mismatch cases | Plan starts from stale or false implementation assumptions |
| Progressive Feasibility | Supporting core | Reframes direct goal into first safe plannable objective when direct incremental planning is unsafe | Plan, Exec indirectly | Research self-review | No | No | More staged thinking and narrower first-slice output | Planning/exec target final goal directly and break incremental safety |
| Core Friction Confirmation | Supporting core | Forces confirmation/flagging of safety/correctness/scope-critical assumptions | Plan | Research self-review | No | No | More careful authority tagging and question discipline | Unsafe defaults silently become plan constraints |
| Four-Way Gap | Presentation / conditional support | Helps explain hard-to-express friction across user/AI/code/architecture | Plan, sometimes Review | Research self-review when used | Possibly to reference-driven conditional use | Yes, if no active consumer relies on it | Extra cognitive surface in hot path | Some hard friction may be explained less clearly, but base contract can still survive |
| Design / Experience Note | Presentation / conditional support | Carries human-visible experience context when it changes planning | Plan | Research self-review when used | Could be made more conditional | Yes, selectively | More optional section surface | Human-facing acceptance context may be thinner |
| Evidence Notes | Presentation / conditional support | Preserves checked facts/citations that materially affect planning | Plan, Review | Research self-review when used | Could be more reference-like | Yes, selectively | More artifact verbosity | Some provenance becomes less explicit |
| `research.md` emission | Supporting core | Compresses problem contract for downstream planning | Plan | route + artifact existence | No | No | Artifact creation and maintenance | Plan must reopen broad context and rediscover intent |

### Plan

| Function | Classification | Solves what problem? | Main consumers | Validator | Can move? | Can weaken? | Cost of keeping | What is lost if weakened/removed? |
|---|---|---|---|---|---|---|---|---|
| Direct prompt planning | Supporting core / ingress | Avoids unnecessary upstream stage hops when intent is already plan-ready | User, Exec indirectly | Source Contract Check | No | No | More ingress complexity | Clear prompts still pay unnecessary research/setup cost |
| Fast Lane | Supporting core | Keeps LIGHT work proportional without losing contract integrity | User, Exec | Final Plan Gate / self-review | No | Only if replaced proportionally | More branching in plan logic | LIGHT tasks become over-ceremonial or slower |
| Fast Adopt | Supporting core | Converts semantically sufficient external plans into canonical PGE contracts | User, Exec, Workflow | source fidelity + Final Plan Gate | No | No | Higher source-fidelity logic and conversion effort | Ready external plans become lossy, manual, or re-planned incorrectly |
| Source Contract Check | Supporting core | Prevents planning from proceeding on non-plan-ready or ambiguous source semantics | Plan itself, Exec indirectly | explicit route decision | No | No | More upfront gate discipline | Plan guesses goal/scope/success shape |
| Plan-eng-review gap closing | Primary core | Closes intended-solution vs repo/architecture gap before execution | Exec, Review | Plan Engineering Review + Final Plan Gate | No | No | More design pressure and repo reading | Plan becomes abstract/idealized and not execution-real |
| Selected / rejected approach logic | Primary core | Commits one executable direction and records why others lost | Exec, Workflow, Review | PER + Final Plan Gate | No | No | More explicit rationale burden | Execution loses direction and revisits solved design decisions |
| Architecture Delta Contract | Primary core for MEDIUM/DEEP/high-risk | Makes current reality, bounded delta, and target direction explicit | Exec, Workflow, Review | Final Plan Gate | No | No | More explicit plan structure on risky work | High-risk plans become TODO lists with hidden constraints |
| Progressive executable slicing | Primary core | Turns broad work into staged, verifiable, executable slices | Exec, Workflow | PER + Final Plan Gate | No | No | More slicing and coupling design effort | Exec must invent order, decomposition, or proof boundaries |
| Verification coupling / first trustworthy verification point | Primary core | Prevents false independence and unsafe parallelism | Exec, Workflow, Review | Final Plan Gate | No | No | More explicit coupling notation | Parallel execution and verification become misleading or unsafe |
| Final Plan Gate | Supporting core | Preserves a single execution-authorization point | Exec | gate verdict | No | No | More gate text and repair loops | Exec starts from weak or dishonest authorization |
| `plan.md` + issue files | Supporting core | Emits the canonical execution contract | Exec, Workflow, Review | artifact existence + gate checks | No | No | Artifact-writing overhead | Downstream must infer or reconstruct contract |
| `workflow-handoff.md` generation | Supporting core | Provides adapter for workflow backend without replacing canonical plan | Dynamic Workflow | adapter checks | Keep owner; some detail can move | Not in first pass | More output surface and template complexity | Workflow backend lacks safe launch adapter |
| Plan Grill Log | Presentation / structure layer | Makes contradiction pressure explicit when needed | Humans, sometimes Review | consumer scan if weakened | Yes, possibly to more conditional use | Yes, only after usage scan | Additional output ceremony | Some contradiction traceability becomes less visible |
| Quality Check Results | Presentation / structure layer | Records compact per-check outcomes when useful | Humans, maybe Review | consumer scan if weakened | Yes | Yes, only after usage scan | Additional output ceremony | Some fine-grained review trace becomes thinner |
| Explicit Self-Evaluation output section | Presentation / structure layer | Exposes internal decision-classification reasoning when needed | Humans, maybe Review | consumer scan if weakened | Yes | Yes, only after usage scan | Additional output ceremony | Some explicit trace of judgment calls disappears |
| DOT / flow explanation | Presentation / structure layer | Helps humans understand the overall process flow | Humans | none beyond doc review | Yes, to docs/reference | Yes | Hot-path bloat | Human onboarding becomes less visual, but stage function remains intact |

### Exec

| Function | Classification | Solves what problem? | Main consumers | Validator | Can move? | Can weaken? | Cost of keeping | What is lost if weakened/removed? |
|---|---|---|---|---|---|---|---|---|
| Canonical-source enforcement | Supporting core / ingress | Prevents execution from normalizing or guessing from non-canonical inputs | Runtime control plane | plan validation | No | No | More strict routing and user friction in ambiguous cases | Execution starts from stale or non-canonical contract |
| Run selection / resume | Supporting core | Preserves stateful continuity and avoids silent overwrite/restart errors | Runtime control plane, user | state.json + run-selection logic | No | No | More runtime state management | Work becomes non-resumable and harder to trust |
| `plan_context_packet` / execution brief compression | Supporting core | Prevents every lane from rereading whole plan/research context | Generator, Evaluator, main fallback | dispatch logic + plan validation | No | No | More packet-building discipline | Runtime gets slower, broader, and more error-prone |
| Issue understanding + implementation strengthening | Primary core | Lets Exec finish the real implementation rather than just route work blindly | User outcome, Review | Candidate Gate + final verification | No | No | More local reasoning and implementation effort in runtime | Exec degrades into shallow ticket shuffling |
| Self-test during execution (TDD or proportional verification) | Primary core | Gives immediate behavior feedback and catches regressions before final review | Evaluator, final review, user trust | Candidate Gate + Evaluator | No | No | More test/verification time during implementation | Runtime becomes faster but much lower quality |
| Lane startup verification + bounded fallback | Supporting core | Prevents ghost lanes or broken auth/channel/runtime from silently proceeding | Runtime stability | startup verification + lane health state | No | No | More orchestration complexity | False readiness and silent execution failure |
| Candidate Gate | Supporting core | Blocks malformed, weak-evidence, or scope-drift candidates before integration | Generator integration, Evaluator indirectly | Exec main | No | No | More review work per candidate | Weak candidates leak to later stages |
| Targeted Evaluator escalation | Supporting core | Adds bounded independent review on concrete cross-boundary risks | Generator repair loop, final route | Evaluator verdict + retry handling | No | No | More targeted review time | High-risk defects survive until too late |
| Evaluator Repair Contract | Supporting core | Turns evaluator findings into structured bounded repair rather than vague feedback | Generator repair loop, resume path | state + retry budget | No | No | More state and protocol management | Repairs become ad hoc and less trustworthy |
| Diagnostic Recovery | Supporting core | Stops trial-and-error when failures are unclear or repeated | Current failing issue / runtime stability | reproduced loop + notes | No | No | Slower recovery on hard failures | Runtime flails or patches blindly |
| Progress Watchdog | Supporting core | Detects stalled or non-meaningful lane progress | Runtime stability | status_request + recovery logic | No | No | More orchestration bookkeeping | Stalled lanes silently waste time/context |
| Shared-tree contamination handling | Supporting core | Prevents misattributing verification failures across coupled issues/files | Runtime stability, repair loop | main classification + recheck flow | No | No | More coordination complexity | Wrong issue gets blamed/fixed |
| Final Evaluator verification | Supporting core | Verifies composed run against plan before final route | final route logic | evaluator verdict structure | No | No | More final verification time | `SUCCESS` loses meaning |
| Exec QA Gate | Supporting core | Applies whole-diff code-quality/review pressure before SUCCESS | final route logic, user trust | review verdict structure | No | No | More reviewer time and artifact production | Runtime may ship with review-level defects |
| state.json / resumability / run artifacts | Supporting core | Makes failures, retries, resumes, and evidence auditable | resume path, repair path, later review | state/artifact write success | No | No | More artifact management overhead | Failures become opaque and non-reproducible |
| Packet schemas / lifecycle examples / wire detail in hot path | Presentation / structure layer | Helps humans maintain/runtime-wire semantics | Humans, maintainers | consumer scan + protocol consistency checks | Yes, to handoffs/references | Yes, presentation only | More hot-path text | Maintainability remains, but hot path stays bloated; if removed wrongly, wire drift increases |

### How to use this matrix

For any proposed change, answer in order:
1. Is this row Primary core, Supporting core, or Presentation layer?
2. What exact problem is it solving today?
3. Who consumes it directly or indirectly?
4. What validator currently protects it, if any?
5. If we move it, are we moving ownership or only presentation/doctrine?
6. If we weaken it, what quality, safety, or context-transfer capability is actually being given up?

No weakening/removal proposal is complete without these answers.

---

# Part A — Per-Skill Function Inventory And Evaluation

## 1. `pge-research`

Primary role:

```text
recover the correct problem contract before planning, especially when the prompt needs brainstorming and grill pressure to separate the real goal from the first plausible solution path
```

### Research function clusters

| Cluster | Major functions | Should stay in Research? | Can weaken/remove? | Notes |
|---|---|---|---|---|
| R1. Intent recovery and framing expansion | entry trigger, A-vs-B distinction, Intent Discovery Trigger, brainstorming candidate framings when the prompt is fuzzy/solution-first | Yes | No | This is Research's most important unique value. Brainstorming here is not a luxury extra; it is part of fair problem discovery. |
| R2. Grill / framing pressure | grill candidate framings so the first plausible solution does not silently become the goal | Yes | No | This belongs in Research because it challenges understanding before planning commits to implementation direction. |
| R3. Evidence / authority discipline | user vs repo vs inference separation, authority notes, observed-behavior handling | Yes | No as function; yes as repeated prose | Function must stay. Doctrine text can be centralized. |
| R4. Planning-readiness diagnosis | Implementation Friction, Progressive Feasibility, Core Friction Confirmation | Yes | No | These are real readiness functions, not documentation ceremony. |
| R5. Optional problem-side lenses | Four-Way Gap, Design / Experience Note, Evidence Notes | Mostly yes | Some may become more strictly conditional | These are auxiliary lenses, not always-on core contract. |
| R6. Brief emission | `research.md`, route contract, route reason, open questions | Yes | No | This is the canonical context-compression output for Plan. |

### Research: preserve / weaken / move judgment

**Must preserve fully:**
- A-vs-B recovery
- brainstorming for underdefined / solution-first framing recovery
- grill pressure over candidate framings before planning
- Intent Discovery Trigger
- authority discipline
- `Implementation Friction`
- `Progressive Feasibility`
- `Core Friction Confirmation`
- `research.v3` route contract and brief emission

**Can be weakened only as presentation:**
- repeated authority prose
- long-form examples
- edge-case explanation in the hot path

**Possible true weakening candidates, but only after consumer check:**
- `Four-Way Gap` default visibility
- some optional diagnostic snippets being shown too early in the hot path

### Research: producer / consumer / validator view

| Function | Producer | Consumer | Validator | Evidence consumer |
|---|---|---|---|---|
| A-vs-B / intent recovery | Research | Plan | Research self-review | user / planner |
| authority mapping | Research | Plan | Research self-review + later Plan handling | Plan / Review |
| Friction / feasibility outputs | Research | Plan | Research self-review | Plan / Exec / Review |
| route decision | Research | Plan / user | Research self-review | Plan |
| `research.md` | Research | Plan | route + artifact existence | Plan / later review of drift |

### Research: key conclusion

Research is **not overloaded by core functions**.
It is somewhat overloaded by **presentation and doctrine duplication**.

---

## 2. `pge-plan`

Primary role:

```text
turn problem contract into an executable contract by using plan-eng-review to close the gap between intended solution and actual repo / architecture reality, then split the work into progressive, verifiable, executable slices
```

### Plan function clusters

| Cluster | Major functions | Should stay in Plan? | Can weaken/remove? | Notes |
|---|---|---|---|---|
| P1. Input adaptation | direct prompt planning, selected-source handling, bare discovery behavior, source priority interpretation | Yes | No as function; maybe clearer/lighter | This is real stage-ingress logic. |
| P2. Source normalization | `research.v3` consumption, Fast Lane, Fast Adopt, bounded repo/runtime truth extraction | Yes | No | These functions are core to executable-contract creation. |
| P3. Gap-closing design review | use plan-eng-review to close implementation-vs-repo/architecture gaps, challenge naive solution paths, and force repo-reality-aware approach selection | Yes | No | This is one of Plan's primary functions, not just an optional refinement pass. |
| P4. Contract design | selected approach, rejected approaches, Architecture Delta Contract, target/forbidden areas, acceptance, verification, evidence_required | Yes | No | This is the heart of Plan's ownership. |
| P5. Progressive executable slicing | issue slicing, dependency structure, verification coupling, execution type, first trustworthy verification point, progressive verifiable delivery | Yes | No | This is a direct downstream input to Exec/Workflow and a primary value of Plan. |
| P6. Hardening / authorization | Source Contract Check, Plan Engineering Review, Final Plan Gate, final sanity | Yes | No | These are quality-bearing, not simplification targets. |
| P7. Artifact emission | `plan.md`, `issues/Ixxx.md`, `workflow-handoff.md` | Yes | No | Canonical output ownership is correct. |
| P8. Presentation / ceremony | DOT flow, repeated gate prose, plan output scaffolding like explicit logs/results sections | Mixed | Some may be weakened after consumer review | This is the biggest likely simplification zone. |

### Plan: preserve / weaken / move judgment

**Must preserve fully:**
- direct prompt planning
- Fast Lane
- Fast Adopt
- Source Contract Check
- plan-eng-review as a gap-closing mechanism between intended solution and repo/architecture reality
- Architecture Delta Contract
- selected/rejected approach logic
- progressive, verifiable, executable issue slicing
- issue slicing / verification coupling
- Plan Engineering Review
- Final Plan Gate
- canonical `plan.md` + `issues/Ixxx.md`
- `workflow-handoff.md` generation for ready plans

**Can be weakened only as presentation/layering:**
- repeated gate prose
- DOT flow in hot path
- repeated authority mapping text
- some output-ceremony sections if they have no strong consumer

**Possible true weakening candidates, but only after consumer + usage review:**
- default-visible `Plan Grill Log`
- default-visible `Quality Check Results`
- default-visible explicit `Self-Evaluation` output section

These are **not** candidates for removing Plan Engineering Review or Final Plan Gate themselves.

### Plan: producer / consumer / validator view

| Function | Producer | Consumer | Validator | Evidence consumer |
|---|---|---|---|---|
| source adaptation | Plan | Plan itself / user continuation path | Source Contract Check | later maintainers |
| approach selection | Plan | Exec / Workflow / Review | Plan Engineering Review + Final Plan Gate | Review |
| issue graph / verification coupling | Plan | Exec / Workflow | Final Plan Gate | Exec / Review |
| acceptance / verification / evidence_required | Plan | Exec / Review / Workflow | Final Plan Gate | Exec / Review / workflow-result consumer |
| `workflow-handoff.md` | Plan | Dynamic Workflow runtime | adapter checks / downstream validation | workflow-result consumer |

### Plan: key conclusion

Plan is **correctly owning the hard functions**, but its **presentation surface is too mixed**:

- owner functions
- doctrine
- flow explanation
- gate detail
- output ceremony

are too interleaved.

---

## 3. `pge-exec`

Primary role:

```text
execute a clear plan by understanding each issue deeply enough to strengthen, supplement, complete, and self-test the implementation inside the plan contract, with bounded repair and final execution QA
```

### Exec function clusters

| Cluster | Major functions | Should stay in Exec? | Can weaken/remove? | Notes |
|---|---|---|---|---|
| E1. Source/run management | canonical-source enforcement, run selection/resume, plan validation | Yes | No | This is core runtime trust management. |
| E2. Context compression | `plan_context_packet`, issue execution brief, targeted evaluation packet | Yes | No | This is the main anti-reread / anti-context-bloat seam. |
| E3. Issue understanding and implementation strengthening | understand issue intent, strengthen/supplement implementation inside plan contract, finish incomplete local design details without changing plan semantics | Yes | No | This is a primary Exec function, not an optional side effect of dispatch. |
| E4. Runtime dispatch | lane creation, startup verification, fallback, bounded Generator/Prep/Evaluator roles | Yes | No | Core execution orchestration. |
| E5. Candidate quality control and self-test | Generator self-review, TDD where appropriate, proportional contract verification where TDD is artificial, Candidate Gate, targeted Evaluator escalation | Yes | No | This is major runtime quality control and one of Exec's main values. |
| E6. Repair and recovery | Evaluator Repair Contract, main-thread takeover, shared-tree contamination handling, Diagnostic Recovery, Progress Watchdog | Yes | No | These are strong current advantages, not ceremony. |
| E7. Final assurance | final Evaluator verification, Exec QA Gate, final review artifacts, route decision | Yes | No | Must remain strong. |
| E8. Persistence and exception closure | state.json, resumability, artifact writing, exception routing, teardown discipline | Yes | No | This is critical runtime robustness. |
| E9. Packet schemas / lifecycle examples / wire detail | Partly top-level Exec, partly handoffs | Function stays; detail can move | Yes as presentation | This is the main hot-path layering problem. |

### Exec: preserve / weaken / move judgment

**Must preserve fully:**
- canonical-source enforcement
- run selection/resume
- plan validation
- `plan_context_packet`
- issue-level implementation strengthening/supplementation inside the plan contract
- self-test during execution, using TDD when appropriate and strongest proportional verification otherwise
- lane startup verification and bounded fallback
- Candidate Gate
- targeted Evaluator logic
- Evaluator Repair Contract
- Diagnostic Recovery
- Progress Watchdog
- state persistence / resumability
- HITL routing
- final Evaluator verification
- Exec QA Gate
- explicit final route discipline

**Cannot be weakened in first-pass alignment:**
- verification pressure
- evidence shape quality
- repair semantics
- final review gate
- route honesty
- startup/channel failure handling

**Can be weakened only as presentation/layering:**
- repeated packet schemas in hot path
- detailed lifecycle examples
- some wire/protocol narration

### Exec: producer / consumer / validator view

| Function | Producer | Consumer | Validator | Evidence consumer |
|---|---|---|---|---|
| `plan_context_packet` / execution brief | Exec | Generator / Evaluator / main fallback path | plan validation + dispatch logic | run artifacts / troubleshooting |
| Candidate Gate | Exec main | Generator integration flow | Exec main | Evaluator / final review indirectly |
| Evaluator Repair Contract | Exec main | Generator / Evaluator loop | Exec state + retry budget | resumability / review of repair path |
| Diagnostic Recovery | Exec | current failing issue / repair loop | reproduced feedback loop | run artifacts / later learning |
| final Evaluator verification | Evaluator / Exec fallback | Exec final route logic | Evaluator verdict structure | final review / user |
| Exec QA Gate | Exec reviewers | final route logic | review verdict structure | user / later review/challenge |

### Exec: key conclusion

Exec is **not too strong**. It is **too textually mixed**.

Its main problem is not function count.
Its main problem is that:
- runtime owner rules
- packet shapes
- fallback detail
- lifecycle examples
- reviewer/evaluator specifics

are all partially mixed into the same hot path.

---

# Part B — Should Functions Move Across Skills?

## Core judgment

Most **core functions should not move across skills**.

The biggest needed moves are:

1. **Shared doctrine move**
   - authority mapping
   - selector / slug / continuation convention
   - route / verdict vocabulary references

2. **Presentation detail move**
   - packet schemas
   - long examples
   - large protocol walkthroughs
   - some output scaffolding explanation

3. **Aggregation move (inside skill), not ownership move (across skill)**
   - group related functions into modules
   - do not split every capability into its own skill

## Cross-skill move matrix

| Function cluster | Current placement | Recommendation |
|---|---|---|
| authority doctrine | Research + Plan | Keep stage-local application, move canonical doctrine to shared reference |
| slug / continuation convention | Research + Plan + Exec | Create shared convention layer |
| candidate direction vs approach selection | Research + Plan | Keep split exactly as-is |
| Fast Adopt | Plan | Keep in Plan |
| verification coupling | Plan -> Exec | Keep owned by Plan, consumed by Exec |
| runtime packet detail | Exec top-level + handoffs | Move more detail into handoffs/reference layer |
| workflow-handoff runtime interpretation detail | Plan template / backend layer | Keep generation in Plan, keep runtime autonomy details out of Plan hot path |
| review/challenge repair intake | Exec | Keep in Exec |

## Cross-skill conclusion

This is mainly a **doctrine/layering relocation problem**, not a **stage-ownership migration problem**.

---

# Part C — Context Transfer And Why Repeated Reading Happens

## Current ideal transfer chain

| Boundary | Canonical artifact | Downstream should trust by default | Downstream should reread only when |
|---|---|---|---|
| User -> Research | prompt + bounded evidence | current prompt | prompt is ambiguous or conflicting |
| Research -> Plan | `research.md` | problem contract | original source semantics matter more than the derived brief, or repo reality may contradict |
| Direct source -> Plan | selected prompt/doc/spec | selected source semantics | source is incomplete or contradicted by repo |
| Plan -> Exec | `plan.md` + `issues/Ixxx.md` | execution contract | plan contract is missing/ambiguous or repair provenance invalidates assumptions |
| Plan -> Workflow | `workflow-handoff.md` + `plan.md` | adapter + plan | handoff/provenance is stale or the canonical plan changed |
| Exec -> repair rerun | run artifacts + review/challenge artifact | repair scope and provenance | provenance or plan identity mismatch |

## Why slowness happens today

Repeated reading happens for four different reasons, and they should not be confused:

1. **Necessary reread**
   - original source-of-truth outranks derivative artifact

2. **Trust-gap reread**
   - downstream cannot trust the artifact because it is underspecified

3. **Doctrine reread**
   - the same rule is restated in multiple places, so the model re-derives it

4. **Presentation-structure reread**
   - hot path and detailed protocol are mixed, so the model reads more than it needs

## Correct optimization strategy

Do **not** solve slowness by deleting gates.

Solve it by:

- stronger canonical artifacts
- explicit reread conditions
- shared doctrine centralization
- runtime packet compression
- validators that reduce trust-gap rereads

## Recommended context layering

| Layer | Contents | Main consumer |
|---|---|---|
| L0 | current prompt / explicit override / selected source | all stages |
| L1 | `research.md` problem contract | Plan |
| L2 | `plan.md` + issue files | Exec / Workflow |
| L3 | `plan_context_packet` + execution/evaluation packets | runtime lanes |
| L4 | run artifacts / review.md / challenge.md / workflow-result.md | repair / downstream review |

## Context-transfer conclusion

The correct target is:

- Research compresses ambiguity into `research.md`
- Plan compresses execution meaning into `plan.md` + issue files
- Exec compresses runtime work into `plan_context_packet` and bounded packets
- Workflow compresses backend evidence into `workflow-result.md`

If a downstream stage repeatedly rereads upstream material, either:
- the artifact is not sufficient,
- the reread trigger is not explicit,
- or the doctrine is too duplicated.

---

# Part D — Aggregation And Layering For Large Skills

Large skills should not become chaotic, but the answer is not infinite fragmentation.

## Aggregation rule

Aggregate functions when all are true:

- they have the same owner
- they are almost always used together
- they serve one quality boundary
- splitting them into separate skills would increase context and coordination cost

## Proposed functional modules

### `pge-research` modules

| Module | Functions | Keep together? |
|---|---|---|
| R-INGRESS | trigger, A-vs-B, intent recovery | Yes |
| R-EVIDENCE | authority, repo/user evidence distinction | Yes |
| R-READINESS | friction, feasibility, core-friction confirmation | Yes |
| R-EMIT | brief + route emission | Yes |

### `pge-plan` modules

| Module | Functions | Keep together? |
|---|---|---|
| P-INGRESS | source selection, direct prompt path, Fast Lane/Fast Adopt entry logic | Yes |
| P-DESIGN | approach selection, delta contract, issue graph, verification coupling | Yes |
| P-HARDEN | Source Contract Check, PER, sanity, Final Plan Gate | Yes |
| P-EMIT | canonical artifacts + workflow handoff | Yes |

### `pge-exec` modules

| Module | Functions | Keep together? |
|---|---|---|
| E-SOURCE | canonical-source enforcement, run selection, plan validation | Yes |
| E-DISPATCH | plan_context_packet, issue briefs, lane startup/dispatch | Yes |
| E-QUALITY | Candidate Gate, targeted Evaluator, final Evaluator, Exec QA Gate | Yes |
| E-RECOVERY | repair contracts, watchdog, Diagnostic Recovery, fallback, HITL, state persistence | Yes |

## Layering rule inside each module

Use four internal layers:

| Layer | What belongs there |
|---|---|
| Hot path | owner decisions and every-run rules |
| Conditional layer | risk-triggered or shape-triggered modules |
| Reference layer | packet schemas, examples, doctrine detail, templates |
| Validator layer | mechanical checks and smoke tests |

## Key correction to earlier simplification thinking

The right answer is often:

- **aggregate into clearer modules**
- **move detail into references**
- **add validators**

not:

- split every function into a new skill
- delete functions because the skill looks large

---

# Part E — What Is Missing From The Current Plan And Needs To Be Added

To make the plan complete, add these missing work items.

## Missing Item 1: Consumer map before weakening

Before marking any function removable/weakenable, add a direct consumer audit:

- who consumes it today
- whether the consumer is explicit or implicit
- whether the function is quality-bearing even without a direct artifact consumer
- whether it is actually harmful debt that should be removed now rather than preserved for caution

## Missing Item 2: Output ceremony usage scan

Before weakening any Plan output sections such as `Plan Grill Log`, `Quality Check Results`, or explicit `Self-Evaluation`, scan:

- template usage
- downstream review usage
- example plan usage
- any implicit eval/pressure-test dependence

## Missing Item 3: Shared doctrine extraction plan

Create a concrete target location for:

- authority doctrine
- slug / continuation convention
- route / verdict vocabulary references

without leaving those rules ownerless.

## Missing Item 4: Validator plan

The plan should explicitly stage validators for:

- plan heading / route / gate invariants
- issue linkage
- workflow-handoff invariants
- cross-surface route/vocabulary/doctrine consistency

## Missing Item 5: Hot-path slimming rules by skill

For each skill, explicitly define:

- what must remain in `SKILL.md` hot path
- what can move to references
- what must remain duplicated locally even if a shared reference exists, because it is too critical to hide

---

# Proposed Work

## Issue 1: Canonical Function Inventory And Consumer Map

Create a stable function inventory for Research / Plan / Exec, and attach:
- preserve / move / conditional weakening classification
- producer / consumer / validator / evidence-consumer mapping
- module ownership

## Issue 2: Primary-Core Correction Pass

Before any restructuring, explicitly align the plan with the primary cores of the three stages:
- Research primary core = brainstorming + grill for intent recovery when the prompt is fuzzy or solution-first
- Plan primary core = plan-eng-review that closes implementation-vs-repo/architecture gaps and produces progressive verifiable executable slices
- Exec primary core = issue understanding, implementation strengthening/completion, and self-test using TDD or other proportional verification

This pass must absorb these correct ideas, reject overstatements, and add missing operational boundaries.

## Issue 3: Shared Doctrine Extraction

Extract the shared doctrine that should not be copy-maintained in three places:
- authority mapping
- selector / slug / continuation convention
- route / verdict vocabulary references

## Issue 4: Context Compression Boundary Specification

Define when downstream should trust upstream artifacts vs reread original source.
Focus on:
- `research.md`
- `plan.md` + issue files
- `plan_context_packet`
- review/challenge repair provenance
- workflow result backflow

## Issue 5: Skill Layering Refactor Plan

For each large skill, define:
- hot path
- conditional modules
- reference layer
- validator layer

This is where the real anti-chaos restructuring should happen.

## Issue 6: Validator Scaffolding And Debt-Removal Gate

Add validator design/spec for:
- canonical plan contract
- issue linkage
- workflow-handoff invariants
- cross-surface vocabulary/doctrine consistency

Use these validators for **shared/high-risk** weakening decisions.

But do not wait on validators to remove debt that is already clearly wrong, consumerless, owner-confusing, or quality-negative. Such debt should be fixed or removed in the same alignment slice once evidence is sufficient.

---

# Phase Order

## Phase 1 — inventory and consumer mapping
- Issue 1
- Issue 2

## Phase 2 — doctrine and context boundaries
- Issue 3
- Issue 4

## Phase 3 — layering design
- Issue 5

## Phase 4 — validators plus debt-removal review
- Issue 6
- remove or correct proven harmful debt immediately when evidence is sufficient
- use validator coverage before weakening shared/high-risk functions that still have active consumers

---

# Success Criteria

- Every skill has a clear function inventory.
- The primary cores of the three stages are explicit and correctly bounded:
  - Research = brainstorming + grill for intent/problem recovery before planning
  - Plan = plan-eng-review-driven gap closing plus progressive executable slicing
  - Exec = issue understanding, implementation strengthening/completion, and self-test inside the plan contract
- Every weakening/removal discussion is backed by consumer and quality-role analysis.
- Cross-skill moves are limited to the right things: doctrine, conventions, presentation layers.
- Context propagation is explicit enough that downstream rereads upstream material only when justified.
- Large skills are organized into modules and layers rather than merely shortened.
- Proven harmful historical debt is corrected or removed in the current alignment slice when evidence is sufficient.
- Shared/high-risk weakening uses validator coverage rather than guesswork.

## Adversarial Review

This section pressure-tests the plan itself.

### What problem is this plan actually solving?

This plan is solving **contract and cognition drift**, not just file length.

More concretely, it is trying to solve:

1. **Function-ownership drift**
   - people cannot easily tell which skill truly owns which behavior
2. **Stage-core drift**
   - Research gets mistaken for brief writing only
   - Plan gets mistaken for formatting / issue emission only
   - Exec gets mistaken for orchestration only
3. **Context-transfer inefficiency**
   - downstream stages reread upstream material because the artifact or boundary is not strong enough
4. **Hot-path chaos**
   - owner logic, doctrine, examples, packet shapes, and validation concerns are mixed together
5. **Unsafe simplification risk**
   - without consumer maps and validators, people may weaken functions that are actually quality-bearing

If the plan is judged only by whether it shortens `SKILL.md`, it is solving the wrong problem.

### What is the cost of this plan?

This plan has real cost.

#### Direct cost
- more analysis before editing
- more up-front classification work
- more deliberate doctrine extraction work
- validator design and implementation effort
- potential short-term documentation churn while layering is corrected

#### Cognitive cost
- maintainers now need to think in terms of:
  - primary core
  - supporting core
  - presentation layer
  - producer / consumer / validator / evidence-consumer
- this is more disciplined than ad-hoc simplification, but it is not cheaper in the short term

#### Execution cost
- first slices will likely improve structure and validation before reducing visible verbosity
- some apparently easy cuts will be deferred until after consumer checks and validators exist

So this plan deliberately trades:

```text
short-term speed of editing
for
higher confidence that we are not weakening the system by accident
```

### What is this plan intentionally not optimizing first?

This plan is **not** optimizing first for:

- shortest possible `SKILL.md`
- fastest possible first-pass runtime
- least ceremony visible to maintainers
- most aggressive deduplication
- fewest files / references / validators

Why not?
Because those optimizations are exactly where hidden quality regressions are most likely.

### What is being given up or deferred?

This plan gives up, for now:

1. **Aggressive early simplification**
   - we are not taking the fastest path to smaller skills
2. **Immediate single-pass cleanup**
   - we are accepting staged restructuring instead of a one-shot rewrite
3. **Some local convenience**
   - repeated prose that looks removable may temporarily stay until its consumer map is proven
4. **Maximum short-term speed**
   - validator-first and consumer-first work is slower than just deleting sections

### What is the main adversarial criticism of this plan?

The strongest criticism is:

> This plan may become too meta — spending more effort classifying, mapping, and validating than actually improving the skills.

That is a valid risk.

### How does the plan answer that criticism?

By keeping the first execution slices concrete:

- function inventory + consumer map
- shared doctrine extraction
- context-boundary definition
- layering blueprint
- validator scaffolding

These are not abstract forever-work items. They are meant to directly unlock safer future simplification and clearer stage ownership.

### Adversarial pass verdict

This plan is justified only if it remains focused on **real contract and runtime quality problems**:

- function ownership confusion
- context-transfer waste
- stage-core misunderstanding
- prose duplication with drift risk
- missing validators for strong prose contracts
- harmful historical debt that should be corrected now rather than preserved for caution

If it drifts into abstract taxonomy work with no contract payoff, or if it uses "we'll fix it later" to preserve known-bad design, it should be cut back.

## Recommended Next Step

This is still an `docs/exec-plans` analysis document, not the canonical `.pge` plan.

If continuing:

1. fast-adopt this revised analysis through `pge-plan`
2. materialize a canonical `.pge/tasks-<slug>/plan.md`
3. make the first execution slice about:
   - function inventory + consumer map
   - shared doctrine extraction
   - context-boundary definition
   - layering blueprint
   - validator scaffolding

Only after that should the system revisit true weakening/removal candidates.
