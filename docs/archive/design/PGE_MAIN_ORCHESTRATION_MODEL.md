# PGE Main Orchestration Model

> Date: 2026-04-30
> Status: Draft
> Purpose: define `main` as the authoritative orchestration shell for the current PGE execution core.

---

## 1. Scope

This document defines only the current execution-core role of `main`.

It does **not** redefine:
- Planner role semantics
- Generator role semantics
- Evaluator verdict semantics
- future preflight / multi-round / resume lanes

It exists to make one thing explicit:

> `main` is the only orchestration shell and control-plane owner for the active execution lane.

---

## 2. What `main` is

`main` is:

- the run-level scheduler
- the gate executor
- the correction / routing reducer
- the exception classifier
- the sole authoritative progress writer
- the teardown owner

`main` is **not**:

- a fourth expert agent
- a substitute planner
- a substitute generator
- a substitute evaluator

`main` may:
- dispatch
- wait
- gate
- classify
- reduce
- record

`main` must not:
- perform domain research in place of Planner
- invent implementation semantics in place of Generator
- rewrite verdict semantics in place of Evaluator

---

## 3. Main lifecycle

The current execution-core lifecycle is:

```text
user task / upstream intent
  -> main initialize run
  -> main create agents team
  -> main dispatch planner
  -> main gate planner artifact
  -> main dispatch generator
  -> main gate deliverable / generator artifact
  -> main dispatch evaluator
  -> main gate evaluator artifact
  -> main deterministic route reduction
  -> main deterministic teardown
```

This is the only active execution skeleton for the current lane.

`main` must not insert extra default stages into this lane.

---

## 4. Main responsibilities

### 4.1 Initialize run

`main` must:
- resolve the user task or upstream intent
- allocate `run_id`
- resolve artifact paths
- write `input_artifact`
- initialize `progress_artifact`
- verify the runtime can resolve the required agent surfaces

### 4.2 Create agents team

`main` must:
- create exactly one team for the run
- attach exactly three teammates:
  - `planner`
  - `generator`
  - `evaluator`
- verify team creation or stop with a concrete runtime blocker

### 4.3 Dispatch roles

`main` must:
- send explicit work to the next required role
- keep each dispatch single-destination and phase-scoped
- avoid natural-language orchestration drift

### 4.4 Gate outputs

`main` must:
- wait for canonical runtime events
- validate the referenced artifact side effects
- block progression on failed gates

### 4.5 Reduce route

`main` must:
- reduce evaluator output into current-stage route behavior
- keep route reduction deterministic
- avoid inventing new route vocabulary

### 4.6 Record process

`main` must:
- write all authoritative progress / friction / repeated-failure logs
- record gate outcomes
- record route outcome
- record teardown outcome

### 4.7 Teardown

`main` must:
- send shutdown requests
- delete the team
- record teardown result

---

## 5. Main non-responsibilities

`main` must not:
- reinterpret Planner's contract into a different contract
- reinterpret Generator's execution judgment into a different technical judgment
- reinterpret Evaluator's verdict into a different acceptance judgment
- repair role semantics directly
- let progress logging become a gate

---

## 6. Main ↔ Planner interaction

### `main -> planner`

`main` sends:
- task input
- required artifact path(s)
- any bounded orchestration constraints

### `planner -> main`

Planner returns:
- `planner_contract_ready`
- `planner_artifact`
- `planner_note`
- `planner_escalation`

### Main responsibilities at this seam

`main` must:
- wait only for the canonical planner runtime event
- gate the planner artifact
- stop or repair-route when the contract is incomplete or unfair

### Planner review point

This is the first hard review point:
- contract completeness
- evidence completeness
- acceptance / verification clarity
- escalation correctness

---

## 7. Main ↔ Generator interaction

### `main -> generator`

`main` sends:
- locked planner contract
- allowed artifact path(s)
- deliverable target

### `generator -> main`

Generator returns:
- `generator_completion`
- deliverable path
- verification result
- optional durable generator artifact

### Main responsibilities at this seam

`main` must:
- gate deliverable existence
- gate generator artifact if required
- inspect `generator_plan_review` when a durable generator artifact exists

### Generator review point

This is the second hard review point:
- deliverable exists
- verification exists
- evidence exists
- self-review exists
- deviations are declared

### Main consumption of `generator_plan_review`

When present, `main` must inspect:
- `review_verdict`
- `missing_prerequisites`
- `repair_direction`
- `scope_risk`

Use this rule:

- `review_verdict = BLOCK`
  - stop
  - record blocked result
  - do not dispatch Evaluator

- `review_verdict = PASS` + material `missing_prerequisites` / `repair_direction`
  - stop
  - record execution blocker
  - do not dispatch Evaluator

- `review_verdict = PASS` + non-blocking `scope_risk` / `known_limits`
  - record friction
  - continue to Evaluator

- no durable Generator artifact
  - use lightweight path
  - rely on deliverable and verification result

`main` must not reinterpret Generator's technical judgment into a different contract meaning.

---

## 8. Main ↔ Evaluator interaction

### `main -> evaluator`

`main` sends:
- planner artifact
- actual deliverable
- optional generator artifact

### `evaluator -> main`

Evaluator returns:
- `final_verdict`
- evaluator artifact

### Main responsibilities at this seam

`main` must:
- gate the evaluator artifact
- reduce the verdict into current-stage route behavior
- record the result without rewriting the verdict

### Evaluator review point

This is the final hard review point:
- independent verification
- verdict validity
- route validity
- required fixes / route reason presence

### Main consumption of evaluator verdicts

Use this rule:

- `PASS + converged`
  - success path
  - continue to teardown

- `PASS + continue`
  - record canonical route
  - downgrade to `unsupported_route`
  - stop cleanly

- `RETRY`
  - classify as execution-level non-acceptance
  - record required fixes and friction
  - stop at `unsupported_route`

- `BLOCK`
  - if current contract still looks fair -> execution blocker
  - if route reason says contract is no longer fair -> contract blocker
  - stop at `unsupported_route`

- `ESCALATE`
  - classify as contract-level failure signal
  - record escalation reason
  - stop at `unsupported_route`

`main` may reduce route/state/logging consequences.
`main` must not rewrite the verdict into a different acceptance judgment.

---

## 9. Progress / friction logging model

### Single-writer rule

Only `main` writes authoritative:
- progress
- friction
- repeated-failure
- route outcome
- teardown outcome

Planner / Generator / Evaluator do **not** write authoritative progress directly.

### What `main` records

At minimum:
- run start
- team creation
- dispatch sent
- gate passed / failed
- blocker class
- route selected
- teardown started / finished
- friction events

### Friction classes

Recommended categories:
- contract friction
- execution friction
- evaluation friction
- protocol friction
- runtime friction

### Repeated failure rule

If the same class repeats:
- first occurrence -> record
- second occurrence -> record as repeated friction
- third occurrence -> treat as systemic, not incidental

---

## 10. Interaction necessity audit

Every interaction in the active lane must justify its existence.

Use this test:

1. does the interaction provide new information?
2. does it change a real decision?
3. does it have a clear owner if it fails?
4. would removing it reduce friction without lowering execution quality?

If the answer is mostly "no", the interaction is likely orchestration drag.

### `main -> planner`

Necessary because:
- Planner is the only role allowed to freeze the current-round contract
- the run cannot proceed safely without a bounded contract

New information created:
- contract shape
- evidence basis
- scope boundary
- acceptance / verification definition

### planner gate

Necessary because:
- it blocks bad contracts from propagating into execution

Bad version of this interaction:
- blocking on wording issues that do not change execution or evaluation quality

### `main -> generator`

Necessary because:
- Generator is the only role allowed to convert the contract into a real deliverable

New information created:
- real deliverable
- verification result
- execution evidence
- explicit executability review

### `generator_plan_review`

Necessary because:
- it surfaces whether the locked contract was executable before `main` blindly trusts downstream output

Why it should remain embedded:
- it provides real value
- but it does not justify a whole new runtime stage

### generator gate

Necessary because:
- it blocks placeholder or under-evidenced work from reaching Evaluator

Bad version of this interaction:
- duplicating full acceptance work that only Evaluator should do

### `main -> evaluator`

Necessary because:
- Evaluator is the only independent final gate

New information created:
- acceptance judgment
- route signal
- final required fixes

### evaluator gate

Necessary because:
- route reduction must never start from an invalid verdict bundle

Bad version of this interaction:
- demanding audit depth that does not change the route decision

### route reduction

Necessary because:
- evaluator verdict semantics and current-stage route behavior are not identical

Why it must stay deterministic:
- freeform route logic is a protocol failure waiting to happen

### progress logging

Necessary because:
- proving and later improvement need durable friction / repeated-failure evidence

Why it must stay lightweight:
- it must record the run, not control the run

---

## 11. Bottleneck and blocker audit

Not every issue should stop the run.

The lane stays stable only if `main` distinguishes:
- hard blockers
- soft blockers / friction

### Hard blockers

These should stop progression:

- team creation failure
- canonical runtime event missing or malformed
- planner contract missing material execution fields
- deliverable missing
- deliverable clearly placeholder-only
- verification impossible with no bounded alternative
- evaluator verdict bundle invalid
- teardown command-shape failure

### Soft blockers / friction

These should usually be recorded, not instantly stop the run:

- weak but non-zero evidence
- non-critical scope risk
- known limits that do not invalidate the current acceptance frame
- queue / wait delays
- repeated clarification pressure
- artifact verbosity that does not change the decision

### Bottleneck signals

Treat these as signs the shell is getting too heavy:

- `main` repeatedly rewrites role outputs before dispatching the next role
- the same gate fails on wording problems that do not change execution behavior
- `generator_plan_review` often blocks on contract vagueness that Planner should have caught
- Evaluator regularly reports issues Generator gate should already have screened
- friction logs show more waiting / reformatting than role work

### Upgrade rule

If the same friction pattern repeats:

- first time -> record
- second time -> repeated friction
- third time -> execution-core improvement candidate

---

## 12. Proving-readiness checklist for `main`

Before using a real bounded task as proving target, confirm:

1. the lifecycle is fixed and documented
2. the three hard review points are fixed
3. `main` is the only authoritative progress writer
4. `main` has deterministic rules for:
   - generator plan-review consumption
   - evaluator verdict consumption
   - route reduction
   - teardown
5. hard blockers vs soft blockers are distinguishable
6. `main` does not need to invent specialist semantics mid-run
7. no known interaction exists only to duplicate information or create waiting

If these are not true, a proving run risks validating orchestration confusion instead of validating the execution core itself.

---

## 13. Exception handling model

### Planner failure

Examples:
- unfair contract
- missing evidence basis
- unresolved blocking ambiguity

Owner:
- `planner`

### Generator failure

Examples:
- missing deliverable
- unverifiable execution
- silent boundary drift
- insufficient evidence

Owner:
- `generator`

### Evaluator failure

Examples:
- invalid verdict bundle
- missing independent verification
- unsupported acceptance reasoning

Owner:
- `evaluator`

### Protocol / control-plane failure

Examples:
- invalid event shape
- route reduction contradiction
- progress schema violation
- teardown call-shape failure

Owner:
- `main`

### Runtime / substrate failure

Examples:
- TeamCreate failure
- SendMessage failure
- TeamDelete failure
- permission / hook / session transport failure

Owner:
- runtime environment, surfaced by `main`

### Exception-handling rule

`main` owns:
- classification
- logging
- deciding whether the run may continue

Agents own:
- repairing their own role outputs

`main` must not repair role semantics directly.

---

## 14. Failure action matrix

Use this matrix when `main` handles a failure signal in the active lane:

| Failure class | Typical signal | `main` records | Current-stage action | Role owner follow-up |
| --- | --- | --- | --- | --- |
| Planner failure | incomplete / unfair contract, unresolved blocking ambiguity, missing evidence basis | planner blocker + contract friction | stop before Generator | `planner` repairs contract or escalates |
| Generator failure | missing deliverable, placeholder-only output, unverifiable execution, silent boundary drift | execution blocker + generation friction | stop before Evaluator | `generator` repairs execution result |
| Evaluator failure | invalid verdict bundle, missing independent verification, unsupported acceptance reasoning | evaluation blocker + protocol/evaluation friction | stop before route reduction | `evaluator` repairs verdict artifact |
| Protocol failure | malformed event, contradictory route reduction inputs, progress schema violation, teardown command-shape issue | protocol blocker | stop immediately | `main` / control-plane fix |
| Runtime failure | TeamCreate / SendMessage / TeamDelete / permission / hook failure | runtime blocker | stop immediately | runtime environment / operator fix |

### Action rules

#### Planner failure

- stop progression before Generator
- record contract blocker
- if the issue is minor wording noise with no execution consequence, treat it as friction instead of blocker
- if the issue makes the contract unfair or guess-driven, do not continue

#### Generator failure

- if deliverable is missing, placeholder-only, or unverifiable -> stop
- if issue is non-critical scope risk or known limit -> record friction and continue only if the deliverable remains evaluable
- if `generator_plan_review` marks a material prerequisite blocker -> stop before Evaluator

#### Evaluator failure

- if the verdict bundle itself is invalid -> stop
- if verdict is valid but non-terminal in the current stage -> reduce to `unsupported_route` and stop cleanly
- if evaluator reports execution incompleteness under a fair contract -> classify as execution blocker
- if evaluator reports the contract is no longer a fair repair frame -> classify as contract blocker

#### Protocol failure

- stop immediately
- do not ask Planner / Generator / Evaluator to guess their way around protocol failure
- record enough detail to make the control-plane failure reproducible

#### Runtime failure

- stop immediately
- report one concrete runtime blocker
- do not retry blindly inside the same turn if the runtime primitive itself failed

### Friction vs blocker rule

Use this distinction:

- **blocker**
  - progression would become unfair, guess-driven, or semantically invalid

- **friction**
  - progression remains valid, but the run exposed unnecessary drag, weak evidence, repeated delay, or mild risk

If unsure:
- prefer blocker when continuing would require semantic invention
- prefer friction when continuing preserves the same acceptance frame

---

## 15. Review model

There are exactly three hard review points in the current lane:

1. Planner artifact gate
2. Generator deliverable / artifact gate
3. Evaluator verdict gate

Do not add extra default review stages unless they clearly reduce risk more than they increase orchestration drag.

---

## 16. Main quality bar

A good `main`:
- keeps the skeleton short
- records the process clearly
- blocks bad artifacts early
- reduces verdicts deterministically
- classifies failures cleanly
- never turns itself into the fourth expert

A bad `main`:
- rewrites role meaning
- invents new route logic mid-run
- allows artifact existence alone to advance the run
- allows progress logging to become a gate
- hides blockers by over-interpreting weak outputs

---

## 17. Bottom line

`main` is the execution governor of the current PGE lane.

It is responsible for:
- sequencing
- gating
- reducing
- logging
- classifying
- tearing down

It is not responsible for replacing the specialist judgment of Planner, Generator, or Evaluator.

---

## 18. Completion status (2026-04-30)

Current status of the `main` control-plane model:

### Completed

- lifecycle is explicit:
  - initialize run
  - create agents team
  - dispatch planner / generator / evaluator
  - gate artifacts
  - route reduce
  - teardown
- progress ownership is explicit:
  - `main` is the only authoritative writer of progress / friction / repeated-failure logs
- hard review points are explicit:
  - planner gate
  - generator gate
  - evaluator gate

### Mostly completed

- interaction model between `main` and Planner / Generator / Evaluator
- interaction-necessity and bottleneck audit
- failure ownership classification:
  - planner failure
  - generator failure
  - evaluator failure
  - protocol failure
  - runtime failure

### Still not fully completed

- failure-handling action matrix is not yet fully fixed for every class:
  - when to stop
  - when to record friction only
  - when to return to role owner
  - when to classify as `unsupported_route`
- this model has not yet been validated by a real bounded task proving run

### Practical reading

This means:

- design/documentation completeness for `main`: high
- runtime-proven completeness for `main`: still partial
