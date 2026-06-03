# PGE Issue Files Contract Migration Plan

## Goal

Move PGE from plan-embedded full issue bodies to separate issue files so clear, well-scoped, well-verifiable work can proceed through `pge-exec` without making `plan.md` oversized or turning issue text into a second planning layer.

The direction is accepted:

```text
plan.md = stable plan and execution index
issues/Ixxx.md = Codex-compatible execution block
pge-exec = goal-directed implementer using issues as handles
Evaluator = run-level requirement / plan-outcome judge
```

This plan resolves the remaining boundary and responsibility questions needed to implement that direction safely.

## Execution Decision

Proceed with a coordinated protocol migration across `pge-plan`, Final Plan Gate, and `pge-exec`.

This is not a new planning workflow and not a new issue tracker. It is a contract-shape migration:

- producer change: `pge-plan` writes compact `plan.md ## issues` index plus `issues/Ixxx.md`
- validator change: Final Plan Gate validates the combined `plan.md` + issue-file contract
- consumer change: `pge-exec` executes only issue-file plans and rejects embedded issue-body plans before run creation
- evaluator boundary: Evaluator remains run-level and judges plan outcome, not issue checklist completion

Implementation should land as one coordinated change set. Partial migration is the main risk because it would let producer, validator, and consumer disagree about the executable plan shape.

## Final Plan Output

Intent:

- Make PGE plan output clear enough for low-context execution while keeping stable plan meaning separate from issue-local execution detail.
- Prevent a valid plan from becoming oversized because executable issue bodies are embedded inside `plan.md`.
- Preserve the existing Research -> Plan -> Execute -> Review -> Ship authority model.

Target:

- `pge-plan` produces `plan.md` as a stable contract and execution index.
- `pge-plan` writes full issue contracts to `issues/Ixxx.md`.
- Final Plan Gate validates the combined `plan.md` + referenced issue-file contract.
- `pge-exec` loads the issue index first, rejects embedded issue-body plans, then lazy-loads selected issue files.
- Evaluator judges the composed run against the plan-level outcome, not per-issue checklist completion.

Verification mechanism:

- Template inspection proves new `plan.md ## issues` is an index, not embedded issue storage.
- Issue template inspection proves issue files contain status, context, task, behavior contract, scope, target areas, acceptance, local validation, required evidence, risks, and source refs.
- Gate/eval scenarios prove missing issue files and embedded issue-body plans block execution.
- Exec docs/handoffs prove selected issue files are lazy-loaded and paired with `plan_context_packet`.
- Protocol consistency review compares producer, validator, consumer, evaluator/review, state writer, and final response surfaces.

Exec handoff:

```text
plan source: docs/exec-plans/pge-issue-files-contract-migration-plan.md
issue files: docs/exec-plans/pge-issue-files-contract-migration-plan-issues/I001.md..I005.md
dependency order: I001 -> I002 -> I003 -> I004 -> I005
ready condition: execute only as a coordinated protocol migration; do not ship producer-only or exec-only slices
completion proof: Required Verification Matrix + Protocol Consistency Review both pass
```

Method-review result:

- Matt-style issues support bounded vertical execution blocks with behavior contracts.
- Superpowers supports a hard design-before-exec gate and self-review before implementation.
- Claude Code / CC practice supports verification-first static artifacts and compact execution slices.
- Codex cross-context review supports independent plan pressure without creating a second canonical plan.
- GSD supports file-as-context and just-in-time loading while keeping progress run-scoped.
- Compound Engineering supports explicit producer/consumer/validator/evidence coherence across protocol changes.

## Execution-Ready Scope

This document is ready to drive implementation when it is used as the source for five bounded implementation issues:

| Issue | Issue Path | Owner Surface | Purpose | Evaluation | Must Land With |
|---|---|---|---|---|---|
| I001 | `pge-issue-files-contract-migration-plan-issues/I001.md` | `pge-plan` templates and docs | Produce issue-file plans by default | Producer foundation; unsafe without I002 validator support. | I002 |
| I002 | `pge-issue-files-contract-migration-plan-issues/I002.md` | Final Plan Gate | Validate index + issue files and reject embedded executable plans | Validator foundation; blocks malformed split contracts. | I001, I003 |
| I003 | `pge-issue-files-contract-migration-plan-issues/I003.md` | `pge-exec` source loading and dispatch | Require issue-file plans, lazy-load selected issue files, build `plan_context_packet` | Consumer foundation; highest drift risk without I002. | I002 |
| I004 | `pge-issue-files-contract-migration-plan-issues/I004.md` | Generator/Evaluator/Review wording | Preserve execution isolation and run-level evaluation | Boundary hardening; prevents checklist-style proof. | I003 |
| I005 | `pge-issue-files-contract-migration-plan-issues/I005.md` | evals / protocol coverage | Prove new contract and rejection route do not drift | Integration proof for the coordinated migration. | I001-I004 |

The first implementation pass should not add a compatibility executor for embedded issue bodies. Existing embedded plans are upgrade inputs for `pge-plan`, not valid `pge-exec` inputs.

This execution plan follows the same boundary: this file keeps the stable migration plan and execution index, while the full issue execution contracts live in sibling issue files.

## Source Inputs

This worktree includes the three source files used to shape this design:

| Source | Role In This Design |
|---|---|
| `codex_plan.md` | Accepted direction and target operating model for plan / issue / exec / evaluator responsibilities. |
| `plan.md` | Concrete failure example: a valid `plan.v2` whose embedded full issue bodies make `plan.md` too large and make issue boundaries harder to operate. |
| `research.md` | Evidence that the underlying product/work request can already be clear enough for planning and execution; the issue-file migration is about execution ergonomics and contract boundaries, not renewed problem discovery. |

Design interpretation:

- `codex_plan.md` is treated as the source direction, not as something to relitigate.
- `plan.md` is treated as the representative failure case to solve.
- `research.md` is treated as proof that the failure is downstream of research clarity: the problem can be understood, scoped, and verified, yet the generated plan can still become too heavy because issue bodies live inside it.

## Current Failure Mode

When user intent, target behavior, and verification are already clear, `pge-plan` can still produce a large canonical `plan.md` because each full issue body is embedded under `## issues`.

That creates three execution problems:

- `plan.md` mixes stable strategy with volatile execution packets.
- Issue bodies become mini-plans, making issue slicing harder to tune and easier to overfit.
- `pge-exec` must carry a large plan artifact even when it only needs one issue execution block.

The problem is not that the plan is invalid under the current contract. The problem is that the current contract makes a valid plan heavier than necessary for Codex/Claude-style progressive disclosure.

## Non-Goals

- Do not re-argue whether issue files are the right direction.
- Do not create GitHub/Jira issue semantics.
- Do not introduce a new planner/generator/evaluator authority.
- Do not create a second canonical plan file.
- Do not make issue files final acceptance objects.
- Do not add task-level exec state that competes with run-scoped `pge-exec` artifacts.
- Do not execute existing embedded-issue `plan.v2` files directly. Treat them as non-canonical execution inputs that `pge-plan` may upgrade / fast-adopt into the new issue-file shape.

## Target Artifact Model

New PGE task directories use this default shape:

```text
.pge/tasks-<slug>/
  research.md
  plan.md
  issues/
    I001.md
    I002.md
    I003.md
  runs/
    <run_id>/
      manifest.md
      state.json
      implementation-notes.md
      evidence/
      deliverables/
      review.md
```

Optional derived views may be produced later by `pge-html` or reporting tools, but they are not new sources of truth.

### Authority

| Artifact | Authority | Writer | Primary Consumer |
|---|---|---|---|
| `research.md` | Problem contract | `pge-research` | `pge-plan` |
| `plan.md` | Stable executable plan contract and issue index | `pge-plan` | `pge-exec`, `pge-review`, `pge-challenge` |
| `issues/Ixxx.md` | Issue-local execution contract | `pge-plan` | `pge-exec` Generator lanes |
| `runs/<run_id>/state.json` | Machine-readable execution state | `pge-exec` | `pge-exec` resume/recovery |
| `runs/<run_id>/manifest.md` | Human-readable execution rollup | `pge-exec` | `pge-review`, user |
| `runs/<run_id>/implementation-notes.md` | In-contract execution decisions and deviations | `pge-exec` | `pge-exec`, Evaluator, review |
| `runs/<run_id>/evidence/` | Long evidence payloads when needed | `pge-exec` | Evaluator, review |

## Canonical Plan Shape

`plan.md` remains the only canonical plan artifact. It must still expose the stable fields required for execution readiness:

- `schema_version`
- `source_contract_check`
- `selected_approach`
- `rejected_approaches`
- `goal`
- `non_goals`
- `target_areas`
- `forbidden_areas`
- `issues`
- `acceptance`
- `verification`
- `evidence_required`
- `risks`
- `terminal_conditions`
- `plan_gate`
- `stop_conditions`
- `route`
- metadata / handoff when useful

The meaning of `## issues` changes for new issue-file plans:

```text
## issues = Execution Index, not full issue body storage
```

This preserves a canonical heading that existing gates and readers can locate, while removing the payload that makes the plan too large.

### `## issues` Index Shape

For new issue-file plans, `## issues` should contain one compact row or block per issue:

```md
## issues

| ID | File | Title | State | Depends On | Verification Coupling | Execution Type | Parallel Hint |
|---|---|---|---|---|---|---|---|
| I001 | issues/I001.md | Wire control lane | READY_FOR_EXECUTE | none | serial verification required | AFK | sequential base |
| I002 | issues/I002.md | Add full recovery | READY_FOR_EXECUTE | I001 | serial verification required | AFK | after I001 |
```

Required index fields:

- `ID`
- `File`
- `Title`
- `State`
- `Depends On`
- `Verification Coupling`
- `Execution Type`

Recommended index fields:

- `Parallel Hint`
- `Target Area Summary`
- `Issue Kind` only when it helps execution

The index must be enough for `pge-exec` to schedule issue loading, detect ready work, and report blocked work without reading every issue file.

## Issue File Contract

Each `issues/Ixxx.md` is the full Codex-compatible execution block. It is authored by `pge-plan` and consumed by `pge-exec`.

Default shape:

```md
# I001: <action-oriented title>

## status

- State: READY_FOR_EXECUTE | NEEDS_INFO | BLOCKED | NEEDS_HUMAN
- Dependencies: <Ixxx or none>
- Verification Coupling: none | independent | compile-coupled with <IDs> | shared verification with <IDs> | integration-only | isolated worktree required | serial verification required
- Execution Type: AFK | HITL:verify | HITL:decision | HITL:action
- Security: yes | no

## context

- Plan: ../plan.md
- Requirement goal served: <short stable reference>
- Upstream decisions: <decision IDs or none>

## task

<bounded action-oriented execution block>

## behavior_contract

- Current Behavior: <current behavior or repo state>
- Desired Behavior: <post-change behavior>
- Behavior Delta: <smallest required behavior/contract change>
- Key Interfaces: <files, commands, config, schemas, public contracts>
- Trigger Predicate: <when relevant>
- Output Admission Predicate: <when relevant>
- Out Of Scope Confirmed: <adjacent work not allowed>
- What Not To Infer: <assumptions Generator must not invent>

## scope

### Do

- <allowed local work>

### Do Not

- <issue-local forbidden work>

## target_areas

- Modify: <path>
- Create: <path>

## acceptance

- <issue-local acceptance>

## local_validation

- <command or check>

## required_evidence

- <evidence pge-exec must produce>

## risks

- <risk and mitigation>

## source_refs

- research: <field or not_applicable>
- user_constraint: <prompt/source reference or not_applicable>
- repo_evidence: <path/line or not_applicable>
- mechanical_support: <why this issue is necessary support>
```

### Issue File Rules

- Issue IDs are stable local IDs: `I001`, `I002`, `I003`.
- Issue file paths are stable and relative to `plan.md`.
- Issue files must not redefine plan goal, non-goals, verification strategy, or forbidden areas.
- Issue-local `Do Not` may be stricter than plan-level `forbidden_areas`, but cannot loosen them.
- Issue-local validation is Generator self-check evidence, not final requirement proof.
- Issue completion is evidence for run-level evaluation, not final proof by itself.

## Progressive Disclosure Contract

Issue size and lazy loading are one progressive-disclosure problem:

```text
an issue file is an independently executable unit,
but it may reference stable plan artifacts for shared intent, constraints, and proof.
```

The target is **minimum sufficient execution context at each layer**.

The word "independent" means **execution-isolated**, not "unrelated to the same plan." A good issue can share the same plan goal and constraints with sibling issues while still being executed without reading sibling issue bodies or inheriting sibling assumptions.

This is close to the Matt-style issue idea: a bounded task slice that a low-context executor can start from, with enough context, scope, repo hints, validation, and expected evidence. PGE differs by making `plan.md` the stable plan artifact that issue files may reference instead of duplicating.

### What Belongs In `plan.md`

Keep stable, cross-issue, plan-level material in `plan.md`:

- goal
- repo-grounded path
- selected / rejected approach
- non-goals
- forbidden areas
- plan-level acceptance
- verification strategy
- return-to-plan conditions
- issue index and scheduling metadata

### What Belongs In `issues/Ixxx.md`

Keep issue-local execution context in the issue file. The issue should be runnable as a unit, but it should not duplicate the stable plan:

- bounded task
- behavior delta
- repo hints / key interfaces needed for this issue
- issue-local scope and do-not scope
- target areas
- local validation
- required evidence
- dependencies / verification coupling
- risks that affect this issue
- source refs that explain why this issue exists

An issue file may reference `../plan.md` sections for stable context, but should not copy whole plan sections into itself.

### What `pge-exec` Adds To The Brief

`pge-exec` reconstructs the minimum sufficient brief by combining:

```text
selected issue file
+ plan_context_packet
+ current user constraints
+ sibling context only when dependency or verification coupling requires it
```

This avoids both failure modes:

- issue files becoming mini-plans because they carry stable strategy
- lazy-loaded Generator lanes missing plan boundaries because the brief omitted global constraints

### Shared Plan Context Packet

`pge-exec` should derive a compact, stable `plan_context_packet` once per run from `plan.md` and attach it to every Generator brief.

Packet contents:

- plan goal
- selected approach summary
- non-goals
- forbidden areas
- plan-level acceptance relevant to all issues
- verification strategy / trust gates
- return-to-plan conditions
- current user constraints that narrow execution

Packet rules:

- It is read-only run context, not a second plan.
- It must not include all issue files.
- It must not include sibling issue implementation details by default.
- It may include sibling issue IDs and dependency/coupling summaries from the index.
- If an issue depends on a sibling, `pge-exec` may add a small dependency context excerpt, preferably from the index or prior run evidence, not from the full sibling issue body unless needed.

This gives every issue the same stable plan boundary while keeping issue execution isolated.

#### `plan_context_packet` Wire Shape

Use this shape in `pge-exec` brief construction. It may be rendered as Markdown in the handoff, but the field names should remain stable enough for docs, evals, and future parsers to reason about.

```yaml
plan_context_packet:
  plan_id: "<plan metadata id>"
  plan_path: ".pge/tasks-<slug>/plan.md"
  task_dir: ".pge/tasks-<slug>/"
  goal: "<one concise plan-level goal>"
  selected_approach_summary:
    approach: "<selected approach summary>"
    rationale: "<one-line rationale when present>"
  non_goals:
    - "<plan-level non-goal>"
  forbidden_areas:
    - area: "<path/module/behavior>"
      reason: "<why excluded>"
  global_acceptance:
    - id: "A1"
      criterion: "<plan-level acceptance criterion>"
      relevant_to: ["I001", "I002", "all"]
  verification_strategy:
    cheap_feedback:
      - "<command/check useful during implementation>"
    trust_gates:
      - "<final composed command/evidence/manual proof>"
    unavailable_checks:
      - "<check plus fallback/terminal handling, or none>"
  issue_graph_summary:
    - id: "I001"
      depends_on: []
      verification_coupling: "serial verification required"
      target_area_summary: "<compact summary>"
  return_to_plan_conditions:
    - "<condition that changes goal/scope/acceptance/verification/non-goals/forbidden areas>"
  current_user_constraints:
    - "<latest user constraint that narrows execution, or none>"
```

Rules for materialization:

- Build it from `plan.md` after plan validation and before dispatch.
- Record only the packet summary or fingerprint in `runs/<run_id>/manifest.md`; do not create a new task-level source artifact.
- Keep it read-only for all Generator lanes.
- If `plan.md` lacks a required packet field, treat that as a plan contract failure unless the field is not applicable and explicitly recorded.

### Issue Isolation Rules

An issue is execution-isolated when:

- the Generator can start from the issue file plus `plan_context_packet`
- sibling issue files are not needed unless dependency or verification coupling says so
- sibling implementation assumptions are not imported as facts
- target areas and forbidden areas are clear enough to prevent accidental cross-issue work
- verification can be local, or the first trustworthy shared verification point is explicit

If an issue needs broad sibling context to be understood, it is not isolated enough. Plan Engineering Review should either split/merge it, add an explicit dependency, or mark shared verification / serial execution.

### Size Heuristic

An issue is too large when:

- it contains multiple architecture moves
- it repeats most of the stable plan
- it cannot name a local validation or first trustworthy verification point
- it requires reading several unrelated sibling issue files to start

An issue is too small when:

- it only adds a placeholder, field, rename, or compile check
- it has no meaningful local validation
- it cannot produce evidence except "file changed"

Plan Engineering Review repairs these before Final Plan Gate. During execution, `pge-exec` may locally shard an oversized issue or merge tiny adjacent issue steps when the plan boundary and verification remain intact.

## Stage Responsibilities

### `pge-research`

Research continues to own problem discovery only:

- goal
- success shape
- scope
- non-goals
- constraints
- task-relevant repo reality
- risks and uncertainty
- route

Research must not produce executable issue files or issue queues.

### `pge-plan`

Plan owns the stable plan and issue files:

- synthesize repo-grounded path
- define target and forbidden areas
- define acceptance and verification strategy
- run Plan Engineering Review
- write `plan.md`
- write `issues/Ixxx.md`
- write compact `## issues` Execution Index in `plan.md`
- run Final Plan Gate across both `plan.md` and referenced issue files

Plan must not make the issue files mini-plans. The issue file is an execution block that points back to the stable plan.

## Strengthened Plan Engineering Review

The issue-file migration increases the importance of Plan Engineering Review. Once issue bodies move out of `plan.md`, the review must prove that the split contract is both faithful to the goal and efficient for execution.

Plan Engineering Review should become the place where PGE answers:

```text
Is this plan ready for fast execution by reading an index first and loading only the current issue file?
```

### Required Review Questions

For every MEDIUM/DEEP plan and every issue-file plan, Plan Engineering Review must check:

- Goal path: does the repo-grounded path still clearly implement the research/user goal?
- Repo anchors: are target files, runtime entry points, config surfaces, tests, and observable proof surfaces real enough for exec to start?
- Issue size: is any issue so broad that Generator cannot begin without replanning?
- Issue thinness: is any issue so small that it is only a mechanical checklist item without meaningful validation?
- Issue isolation: can each issue be executed from its issue file plus the shared plan context packet without sibling issue details interfering?
- Hidden coupling: do issues share files, runtime paths, fixtures, generated artifacts, or the same trust-gate command?
- Verification topology: what is the first trustworthy verification point for each issue or issue group?
- Index completeness: can `pge-exec` schedule from `plan.md ## issues` without reading every issue file?
- Issue-file completeness: does each ready issue file contain enough context, task, behavior contract, scope, target areas, local validation, required evidence, dependencies, risks, and security classification?
- Return-to-plan boundary: are plan-level stop conditions distinct from issue-local adaptation?

### Review Outputs

Findings must be written back into durable artifacts:

- stable decisions, constraints, rejected paths, and return-to-plan conditions go into `plan.md`
- issue-local execution details go into `issues/Ixxx.md`
- scheduling hints, dependencies, and verification coupling go into the `plan.md ## issues` index
- unresolved plan-level problems block `READY_FOR_EXECUTE`

Downstream must never depend on "plan-eng-review happened" as transient state. It may depend only on `plan.md`, referenced issue files, and any durable review artifact explicitly linked by `plan.md`.

### Issue Slicing Gate

Plan Engineering Review should reject both bad extremes:

| Failure | Symptom | Required Repair |
|---|---|---|
| Oversized issue | issue contains multiple architecture moves or cannot be locally validated | split into bounded execution blocks or make verification coupling explicit |
| Over-thin issue | issue only adds a field, placeholder, rename, or compile check | merge into adjacent issue or make it an internal task |
| Hidden dependency | issue depends on sibling implementation but index says `none` | add dependency or mark shared verification / serial coupling |
| Mini-plan issue | issue repeats stable strategy and broad architecture decisions | move stable material back to `plan.md`; leave task, scope, validation, evidence in issue |

### Plan-Eng-Review Acceptance

The review is strong enough when:

- the plan-level path is stable without reading every issue file
- the issue index is enough to schedule
- each issue file is enough to execute
- dependencies and verification coupling are explicit
- exec-local adaptation is allowed without weakening plan boundaries
- Final Plan Gate can validate the combined contract mechanically enough to block missing or stale issue files

### `pge-exec`

Exec owns execution scheduling and adaptation:

- read `plan.md`
- read `## issues` index first
- load only selected `issues/Ixxx.md` files on demand
- build compact Generator briefs from the issue file plus necessary stable plan context
- decide serial vs parallel vs isolated-worktree execution
- record run-scoped state and evidence under `runs/<run_id>/`
- adapt issue-local imperfections when plan goal, acceptance, verification, non-goals, and forbidden areas remain intact
- route upstream only for plan-level problems

Exec must not mutate `plan.md` or issue files as a way to approve scope changes. If issue-local interpretation needs to be recorded, it goes into `implementation-notes.md`.

## `pge-exec` Interface Protocol

The new interface is a two-level protocol:

```text
Level 1: plan.md
  - stable plan contract
  - issue index
  - plan-level acceptance / verification / forbidden areas / stop conditions

Level 2: issues/Ixxx.md
  - selected issue-local execution contract
  - task / behavior delta / target areas / local validation / required evidence
```

`pge-exec` consumes the protocol in this order:

1. Resolve canonical `plan.md`.
2. Validate `plan_gate`, route, stop conditions, forbidden areas, and global acceptance.
3. Validate that the plan uses the issue-file contract shape.
4. Parse `## issues` as an Execution Index.
5. Build an in-memory issue graph from index fields only.
6. Load full `issues/Ixxx.md` only for issues selected for dispatch, validation, repair, or final evaluation context.
7. Validate selected issue file before dispatch.
8. Build Generator brief from selected issue file plus stable plan context.
9. Persist execution state in `runs/<run_id>/state.json`, `manifest.md`, and `implementation-notes.md`.

### Index Contract For Exec

The index must give exec enough information to plan execution without opening all issue files:

- ready / blocked / human-needed state
- dependency graph
- rough work unit title
- issue file path
- verification coupling
- execution type
- optional parallel hint

If the index is missing fields needed for scheduling, `pge-exec` routes upstream to `pge-plan` instead of guessing.

### Issue File Dispatch Contract

Before dispatching a Generator, `pge-exec` validates the selected issue file has:

- `State`
- `Dependencies`
- `Verification Coupling`
- `Execution Type`
- `Security`
- task/action
- behavior contract
- scope / do-not scope
- target areas
- acceptance
- local validation
- required evidence
- risks
- source refs when source fidelity matters

Missing fields are contract failures, not implementation blockers.

### Brief Construction

The Generator brief is compact:

```text
selected issue file fields
+ plan_context_packet
+ current user/context constraints
+ sibling issue context only when dependency or verification coupling requires it
```

Do not include full `plan.md`, full `research.md`, or all issue files by default.

### Repair And Deviation Protocol

If exec adjusts issue-local execution, it records:

- what changed
- why it still satisfies the issue and plan contract
- whether verification changed
- whether dependency/scheduling changed
- evidence path

Record this in `runs/<run_id>/implementation-notes.md`. Do not edit issue files during execution to hide deviations.

## Fast Execution Scheduling

The scheduling objective is:

```text
maximize useful parallelism while minimizing context loaded per lane
```

`pge-exec` should use this fast path:

1. Read `plan.md` once.
2. Parse the issue index into an issue graph.
3. Classify ready issues by dependencies, target-area overlap, verification coupling, execution type, and security risk.
4. Dispatch the smallest safe independent set.
5. Load only the issue files for that dispatch set.
6. Prefer serial execution when issues share files, runtime path, fixtures, or trust-gate commands.
7. Prefer parallel Generator lanes only when issues have no dependencies, no target overlap, and no unsafe shared verification surface.
8. Use isolated worktrees only when parallel authoring is useful but shared verification would contaminate the same working tree.
9. Run final composed verification and Evaluator over the whole plan outcome.

### Scheduling Decision Table

| Condition | Default Scheduling |
|---|---|
| same file or same runtime path | serial |
| shared test fixture or compile command | serial verification; parallel authoring only with isolated worktrees |
| independent target areas and independent verification | parallel Generator lanes when runtime supports it |
| issue marked `HITL:*` | schedule after AFK dependencies; route `NEEDS_HUMAN` when human input is required |
| security/data/destructive/high-risk issue | serial or targeted Evaluator before continuing |
| issue file missing or malformed | route upstream to `pge-plan` |
| issue-local repo hint inaccurate but target remains clear | adapt locally and record note |
| plan assumption false or verification cannot prove goal | return to plan |

### Efficiency Rules

- Do not read all issue files up front unless the index is insufficient and that insufficiency itself should be reported.
- Do not run a per-issue Evaluator by default.
- Do not make plan a scheduler; plan gives dependencies, coupling, and hints.
- Do not let parallel hints override runtime truth.
- Do not block on issue wording imperfections when goal, scope, and validation are clear.
- Do not claim success from issue completion alone; final success is plan-level.

### Generator Lanes

Generator lanes receive one issue execution brief derived from `issues/Ixxx.md`, not the full task plan by default.

They own:

- issue-local implementation
- proportional local validation
- changed-hunk audit
- issue-contract self-review
- required evidence packet

They do not own:

- plan mutation
- final acceptance
- shipping route

### Evaluator

Evaluator remains run-level:

- validate composed run against `plan.md`
- inspect issue files only as supporting evidence
- check acceptance/evidence coverage
- detect issue completion that still misses the plan outcome
- route bounded repair through `pge-exec` when in-contract

Evaluator must not become a serial issue checklist approver.

## Exec Adaptation Policy

When these are true:

- user intent is clear
- goal is explicit
- plan direction is clear
- verification is available
- final output shape is clear

`pge-exec` should adapt locally and continue.

Allowed local adaptation:

- fix inaccurate repo hints by finding the real entry point
- split an oversized issue internally into local tasks
- merge tiny adjacent issue steps when they share the same acceptance and verification surface
- replace a weak local validation command with a stronger equivalent
- change serial/parallel/worktree scheduling
- make small adjacent in-contract changes needed for the same acceptance

Record meaningful adaptation in `runs/<run_id>/implementation-notes.md`.

Return to plan only when execution would change:

- goal
- scope
- acceptance
- verification strategy
- non-goals
- forbidden areas
- high-risk behavior
- human decision boundary

## Execution State Boundary

The proposal term `exec/progress.md` maps to existing run-scoped state:

```text
progress = runs/<run_id>/state.json + manifest.md
decision log = runs/<run_id>/implementation-notes.md
long evidence = runs/<run_id>/evidence/
```

Do not add task-level `exec/progress.md` or `exec/decision-log.md` in this migration. Task-level exec artifacts would create a second state surface outside the existing run/resume model.

If a future human-readable progress view is needed, generate it as a derived report from `state.json` and `manifest.md`, not as an independently edited source.

## Source Shape Policy

`pge-exec` supports only the new issue-file plan shape.

### Shape Detection

`pge-exec` classifies a plan before creating a run:

| Shape | Detection | Exec Handling |
|---|---|---|
| `issue_file_plan` | `## issues` is a compact index with `ID`, `File`, `State`, `Depends On`, `Verification Coupling`, and `Execution Type`; ready issue files exist under `issues/` | continue validation |
| `embedded_issue_plan` | `## issues` contains full issue bodies such as `### Issue`, `Action`, `Behavior Contract`, `Acceptance Criteria`, `Verification Hint`, or repeated issue body fields without issue file paths | stop with `non_canonical_plan_shape`; route to `pge-plan` upgrade |
| `malformed_issue_file_plan` | index exists but missing required fields, bad paths, unknown states, unknown dependencies, unreadable issue files, or index/file disagreement | stop before dispatch; route to `pge-plan` repair |
| `unknown_plan_shape` | cannot locate canonical `## issues` or required plan gate/route fields | stop before dispatch; route to `pge-plan` fast-adopt/repair |

Handling:

- Load issue contract from the referenced file.
- Validate issue file completeness before dispatch.
- Use issue file content to build Generator brief.

Embedded full issue bodies under `plan.md ## issues` are non-canonical execution input. They must be upgraded by `pge-plan` into issue files before `pge-exec` starts.

If `pge-exec` receives an embedded-issue plan, it must:

- stop before creating a run or dispatching lanes
- report `non_canonical_plan_shape`
- route upstream to `pge-plan` for contract upgrade / fast-adopt
- avoid extracting embedded issue bodies itself

Missing or unreadable issue files are execution-blocking contract failures and route upstream to `pge-plan`.

### Index/File Consistency Rules

Final Plan Gate and `pge-exec` both perform these checks. Final Plan Gate catches producer mistakes before routing `READY_FOR_EXECUTE`; `pge-exec` repeats the checks to protect execution from stale or manually edited artifacts.

For every indexed ready issue:

- `ID` in the index equals the issue file status ID implied by filename / title.
- `File` is a relative path under the same task directory, usually `issues/Ixxx.md`.
- file exists and is readable.
- index `State`, `Depends On`, `Verification Coupling`, `Execution Type`, and `Security` match the issue file `## status` block.
- dependencies reference known issue IDs.
- no dependency cycle exists.
- ready issue target areas are inside plan target areas or explicitly justified as mechanical support.
- issue file does not redefine plan goal, non-goals, forbidden areas, or global verification strategy.

Mismatch handling:

| Mismatch | Gate Handling | Exec Handling |
|---|---|---|
| missing file | `REVISE`, `Exec Allowed: no` | `BLOCKED`, route `pge-plan` |
| index dependency unknown | `REVISE`, `Exec Allowed: no` | `BLOCKED`, route `pge-plan` |
| index says ready, file says blocked/human | `REVISE`, `Exec Allowed: no` | hold dispatch, route `pge-plan` |
| file expands plan scope | `REJECT` or `ESCALATE` | `BLOCKED`, route `pge-plan` |
| minor title/summary drift only | repair index during planning | continue only if fields needed for scheduling still match; record warning in manifest |

## Final Plan Gate Changes

Final Plan Gate must validate the combined contract:

```text
plan.md stable fields
+ issues index
+ referenced issue files
= executable plan contract
```

Contract Completeness Gate checks:

- `plan.md` has required stable sections.
- `## issues` index has required fields.
- every ready issue file exists.
- every ready issue file has the required issue contract fields.

Execution Readiness Gate checks:

- at least one indexed issue is `READY_FOR_EXECUTE`.
- dependencies reference known issue IDs.
- ready issue files have Action/Task, Behavior Contract, Target Areas, Acceptance, Local Validation, Required Evidence, Risks, Security, Verification Coupling, and Execution Type.
- issue-level Target Areas remain inside plan target areas or are justified as mechanical support.

Skill Execution Stability Gate checks:

- `pge-exec` can recognize issue-file plans without interpreting prose.
- embedded full issue bodies are rejected before execution and routed to `pge-plan` for upgrade.
- route/status/verdict vocabulary is unchanged.
- issue file references are relative, stable, and inside the task directory.
- missing issue files block execution instead of being guessed.

## `pge-plan` Changes

Update `pge-plan` to write issue-file plans by default.

Required behavior:

- create `.pge/tasks-<slug>/issues/`
- write each full issue contract to `issues/Ixxx.md`
- keep `plan.md` focused on stable strategy, acceptance, verification, target/forbidden areas, risks, gate, route, and `## issues` index
- run self-review and Final Plan Gate over both `plan.md` and issue files
- final response reports both plan path and issue file count

Do not require `pge-plan` to write all issue files for future phases unless the current plan authorizes those phases.

## `pge-exec` Changes

Update `pge-exec` source routing and plan validation:

- resolve canonical `plan.md`
- require the issue-file plan shape
- reject embedded full issue bodies as non-canonical execution input
- parse `## issues` index and load selected issue files lazily
- validate issue files before dispatch
- include issue file path in manifest issue records
- record issue-local adaptation in `implementation-notes.md`
- keep run artifacts unchanged

Generator brief construction changes:

```text
brief = selected issue file
      + plan_context_packet
      + current context constraints
      + dependency/coupling context only when required
```

Do not paste full `plan.md` into every Generator brief when issue file plus stable context is sufficient.

## Template Changes

Update `skills/pge-plan/templates/plan.md`:

- replace full issue body section with compact `## issues` index
- add pointer that full issue files live under `issues/Ixxx.md`
- keep `## acceptance`, `## verification`, `## evidence_required`, `## plan_gate`, `## stop_conditions`, and `## route`
- add an optional "Issue File Contract" reference or mini-template

Add a new template:

```text
skills/pge-plan/templates/issue.md
```

This template should contain the issue file contract shape and field semantics.

## Documentation Changes

Update:

- `README.md`
- `README-CN.md`
- `CLAUDE.md` if resident authority wording needs precision
- `skills/pge-plan/SKILL.md`
- `skills/pge-plan/references/plan-gate.md`
- `skills/pge-exec/SKILL.md`
- `skills/pge-exec/handoffs/generator.md`
- `skills/pge-exec/handoffs/evaluator.md` only if evaluator input wording assumes embedded issue bodies
- `skills/pge-plan/evals/evals.json`

The docs must consistently say:

```text
plan.md remains canonical
issue files are canonical issue contracts referenced by plan.md
run artifacts remain run-scoped
issue completion is evidence, not final proof
```

## File Change Map

Use this map to keep implementation scoped. If a file listed here does not exist in the active branch, create it only when its owning issue explicitly says so.

| File | Change Type | Owning Issue |
|---|---|---|
| `skills/pge-plan/SKILL.md` | update producer behavior, Plan Engineering Review expectations, final response wording | I001 |
| `skills/pge-plan/templates/plan.md` | replace embedded full issue template with compact issue index | I001 |
| `skills/pge-plan/templates/issue.md` | add new issue-file template | I001 |
| `skills/pge-plan/references/engineering-review.md` | add issue slicing, isolation, progressive disclosure checks if not already covered | I001 |
| `skills/pge-plan/references/engineering-review-gate.md` | align gate wording with strengthened Plan Engineering Review | I001 |
| `skills/pge-plan/references/plan-gate.md` | require combined plan + issue-file validation and reject embedded executable plans | I002 |
| `skills/pge-plan/references/final-plan-gate.md` | add structured gate input/boundary wording for issue-file contract when needed | I002 |
| `skills/pge-plan/references/self-review.md` | ensure self-review catches issue-file completeness/index consistency | I002 |
| `skills/pge-exec/SKILL.md` | require issue-file plan shape, lazy-load issue files, build packet, reject embedded plans | I003 |
| `skills/pge-exec/handoffs/generator.md` | update execution brief to receive selected issue file fields plus `plan_context_packet` | I003 |
| `skills/pge-exec/references/generator-rules.md` | align issue isolation and local adaptation wording | I003 |
| `skills/pge-exec/handoffs/evaluator.md` | preserve run-level evaluation boundary | I004 |
| `skills/pge-exec/references/evaluator-thresholds.md` | remove checklist-style issue approval assumptions if present | I004 |
| `skills/pge-review/SKILL.md` | clarify review audits diff vs plan outcome, using issue files as support | I004 |
| `skills/pge-plan/evals/evals.json` | add producer/gate scenarios for issue-file plans | I005 |
| `skills/pge-plan/evals/joint-evals.json` | add cross-surface protocol scenario if current eval shape supports it | I005 |
| `README.md` | update artifact layout and active flow language | I001 or I005 |
| `README-CN.md` | mirror README changes if present | I001 or I005 |
| `CLAUDE.md` | only update if resident authority wording still says executable issues are embedded in `plan.md` | I005 |

## Implementation Order

Implement in this order:

1. Update `pge-plan` producer templates and issue-file contract.
2. Update Plan Engineering Review wording so issue slicing quality is checked before Final Plan Gate.
3. Update Final Plan Gate to validate `plan.md` index plus referenced issue files and reject embedded issue-body execution input.
4. Update `pge-exec` source routing to require issue-file plans before run creation.
5. Update `pge-exec` Generator brief construction to use selected issue file plus `plan_context_packet`.
6. Update Evaluator/review wording so issue files remain supporting evidence, not final proof.
7. Add eval coverage for the new happy path, missing file, embedded-plan rejection, and exec-local adaptation.
8. Run consistency grep and manual protocol review.

Do not merge a state where step 1 has landed without steps 3 and 4. That state would produce new artifacts that the validator/consumer do not reliably enforce.

## Required Verification Matrix

The implementation is not complete until these checks are true:

| Check | Expected Result | Evidence |
|---|---|---|
| New plan template | `## issues` is an index, not embedded issue bodies | inspect `skills/pge-plan/templates/plan.md` |
| New issue template | `skills/pge-plan/templates/issue.md` contains status, context, task, behavior contract, scope, target areas, acceptance, local validation, evidence, risks, source refs | inspect file |
| Final Plan Gate | missing issue file blocks `PASS` / `Exec Allowed: yes` | eval or manual gate scenario |
| Final Plan Gate | embedded full issue bodies under executable `## issues` block execution | eval or manual gate scenario |
| Exec source routing | embedded issue plan returns `non_canonical_plan_shape` before run creation | doc/eval scenario |
| Exec lazy loading | brief construction is defined as issue file + packet, not all issue files | inspect `skills/pge-exec/SKILL.md` and generator handoff |
| Packet contract | `plan_context_packet` fields are named and stable | inspect exec docs/handoff |
| Evaluator boundary | Evaluator judges composed plan outcome, not per-issue checklist completion | inspect evaluator docs |
| State boundary | no new task-level `exec/progress.md` or `exec/decision-log.md` source is introduced | grep |
| Vocabulary | route/status/verdict vocabulary remains existing PGE vocabulary plus `non_canonical_plan_shape` as an exec failure reason | grep/manual review |

## Implementation Issues

This plan intentionally does not embed full issue execution bodies here. The full issue contracts live in `pge-issue-files-contract-migration-plan-issues/Ixxx.md`, mirroring the contract shape this migration introduces.

| ID | File | Title | State | Depends On | Verification Coupling | Execution Type | Security | Introduction | Evaluation | Dependency Order |
|---|---|---|---|---|---|---|---|---|---|---|
| I001 | `pge-issue-files-contract-migration-plan-issues/I001.md` | Add Issue File Plan Contract To `pge-plan` | READY_FOR_EXECUTE | none | shared verification with I002 and I005 | AFK | no | Teach `pge-plan` to emit compact plan indexes plus separate issue files. | Producer foundation; must be validated with I002 because producer output is unsafe without gate support. | 1; starts the migration. |
| I002 | `pge-issue-files-contract-migration-plan-issues/I002.md` | Update Final Plan Gate For Combined Plan + Issue Files | READY_FOR_EXECUTE | I001 | shared verification with I001 and I005 | AFK | no | Update Final Plan Gate to validate the split plan/index/issue-file contract. | Validator foundation; blocks malformed or embedded-body plans before they become executable. | 2; after I001, before I003. |
| I003 | `pge-issue-files-contract-migration-plan-issues/I003.md` | Update `pge-exec` To Require And Load Issue Files Lazily | READY_FOR_EXECUTE | I002 | shared verification with I004 and I005 | AFK | no | Update `pge-exec` to reject embedded plans and lazy-load selected issue files. | Consumer foundation; highest drift risk if implemented without I002. | 3; after I002. |
| I004 | `pge-issue-files-contract-migration-plan-issues/I004.md` | Align Evaluator And Review Boundaries | READY_FOR_EXECUTE | I003 | shared verification with I003 and I005 | AFK | no | Preserve run-level Evaluator and review boundaries after issue files are introduced. | Boundary hardening; prevents issue completion from becoming final proof. | 4; after I003. |
| I005 | `pge-issue-files-contract-migration-plan-issues/I005.md` | Add Protocol Consistency Coverage | READY_FOR_EXECUTE | I001, I002, I003, I004 | integration-only | AFK | no | Add protocol coverage for producer, validator, consumer, adaptation, and evaluator behavior. | Integration proof; validates the coordinated migration and catches stale embedded-plan wording. | 5; after I001-I004. |

Execution dependency chain:

```text
I001 -> I002 -> I003 -> I004 -> I005
```

## Migration Strategy

Phase 1: Contract design and templates.

- Add issue file template.
- Update plan template and docs.
- Define embedded issue-body plans as non-canonical execution input.

Phase 2: Gate and exec consumer support.

- Add issue-file validation to plan gate.
- Update exec source loading.
- Add exec rejection route for embedded issue-body plans.

Phase 3: Default new output.

- Make `pge-plan` write issue-file plans by default.
- Existing embedded plans must be upgraded by `pge-plan` before execution.

Phase 4: Tighten after evidence.

- After repeated successful issue-file runs, remove stale wording that describes embedded issue plans as executable.
- Keep one clear upgrade path through `pge-plan`; do not add an exec fallback loader.

## Success Criteria

- New PGE plans keep `plan.md` focused on stable strategy and issue index.
- Full issue execution blocks live in `issues/Ixxx.md`.
- `pge-exec` executes only issue-file plans and routes embedded issue-body plans upstream for upgrade.
- Final Plan Gate validates the combined contract without weakening readiness.
- Run state remains under `runs/<run_id>/`; no task-level exec state competes with it.
- Evaluator judges requirement / plan-level outcome, using issue completion only as evidence.
- The backfill-style failure case can be represented as a short `plan.md` plus three issue files without losing acceptance, verification, or forbidden-area protection.

## Low-Cost Implementation Guardrails

These are implementation-level guardrails, not reasons to slow or reject the direction. They are low-cost checks that should be encoded in templates, Final Plan Gate, and `pge-exec` validation.

| Concern | Low-Cost Resolution |
|---|---|
| Embedded full issue plans still exist | `pge-exec` refuses them with `non_canonical_plan_shape`; `pge-plan` owns contract upgrade / fast-adopt into issue files. |
| New progress/decision artifacts could compete with run state | Do not add task-level exec state; map progress/decision concepts to `runs/<run_id>/state.json`, `manifest.md`, and `implementation-notes.md`. |

The only real failure mode is partial implementation: changing `pge-plan` output without updating Final Plan Gate and `pge-exec`, or updating `pge-exec` without enforcing issue-file completeness. The migration should therefore land as a coordinated contract change, even if each individual guardrail is small.

## Protocol Consistency Review

Producer:

- `pge-plan` writes `plan.md` and `issues/Ixxx.md`.

Consumer:

- `pge-exec` reads `plan.md` index and selected issue files.
- Generator receives an execution brief derived from the selected issue file.
- Evaluator reads plan and run evidence, consulting issue files only when needed.

Validator:

- Final Plan Gate validates stable plan sections, issue index, referenced issue files, route vocabulary, and execution readiness.
- `pge-exec` Plan Validation revalidates issue file existence and required issue fields before dispatch.

State/artifact writer:

- `pge-exec` writes only run-scoped execution artifacts under `runs/<run_id>/`.

Final response / repair route:

- `pge-plan` reports `plan_path`, ready issue IDs, issue file count, plan gate, and next `pge-exec` command.
- `pge-exec` reports run status, issue counts, verification, review, and artifacts.
- Review/challenge repair continues to flow through task-level review/challenge artifacts plus run provenance.

Consistency result:

- The design preserves one canonical plan artifact while adding canonical issue files referenced by that plan.
- It requires coordinated updates to `pge-plan`, Final Plan Gate, and `pge-exec`; partial implementation would create protocol drift and must not route ready.

## Multi-Round Review Consolidation

This section records the review pressure applied before implementation. It is part of the execution plan, not an implementation artifact. The result is that the migration is proceedable as a coordinated contract change, with explicit guardrails against turning issue files into a new workflow, checklist gate, or state surface.

### Review Inputs

| Input | Lens Used |
|---|---|
| `codex_plan.md` | Accepted target model: `plan.md` as stable plan/index, `issues/Ixxx.md` as Codex-compatible execution block, `pge-exec` as goal-directed implementer, Evaluator as run-level judge. |
| `plan.md` | Concrete failure case: a clear `plan.v2` becomes operationally heavy because full issue bodies live inside `## issues`. |
| `research.md` | Proof that the problem is downstream of research clarity, not a need to redo discovery. |
| `docs/research/ref-matt-skills.md` | Vertical issue slices, behavior-contract issues, progressive disclosure, small composable surfaces. |
| `docs/research/ref-superpowers.md` | Design-before-code gate, hard stop before implementation, spec self-review, one-way handoff. |
| `docs/research/ref-best-practice.md` | Claude Code/Codex cross-context review, verification-first, instruction budget, static artifacts over compaction. |
| `docs/research/ref-gsd.md` | File-as-context propagation, context budget, wave scheduling, pause/resume state boundaries. |
| `docs/research/ref-gstack.md` | Scope challenge, failure-mode pressure, outside voice, fix-first review, precise evidence requirements. |
| `docs/research/ref-anthropic.md` | Evaluator-Optimizer pattern, hard thresholds, just-in-time context, subagent outputs to filesystem. |
| `docs/research/ref-agent-harness-anatomy.md` | Harness components: context management, structured output parsing, state, error handling, verification loops. |

### Round 1: Contract Shape Review

Finding:

- The direction is correct: move volatile, issue-local execution context out of `plan.md` while preserving `plan.md` as the canonical plan artifact.
- The primary contract risk is not file count. The risk is letting two canonical planning surfaces emerge: one in `plan.md`, one in issue files.

Decision:

- `plan.md` remains canonical for stable plan meaning: goal, selected approach, non-goals, target/forbidden areas, plan-level acceptance, verification strategy, stop conditions, route, and the issue index.
- `issues/Ixxx.md` is canonical only for issue-local execution: task/action, behavior delta, local target areas, local validation, required evidence, risks, and source refs.
- Issue files may point back to `../plan.md`; they must not redefine plan goal, non-goals, global verification, or forbidden areas.

Proceed condition:

- The implementation must update producer, validator, and consumer in the same coordinated change set. A producer-only or exec-only migration is not acceptable.

### Round 2: Progressive Disclosure Review

Finding:

- Matt, Claude Code best-practice, GSD, and Anthropic context-engineering references all converge on the same principle: pass compact identifiers and load detail just in time.
- The plan's `plan_context_packet` is necessary. Without it, issue files either become mini-plans or Generator lanes lose stable plan boundaries.

Decision:

- `pge-exec` reads `plan.md` once, parses `## issues` as an execution index, builds an issue graph from index fields, and loads full issue files only for selected dispatch, repair, or final evaluation context.
- Generator brief shape is:

```text
selected issue file fields
+ plan_context_packet
+ current user constraints
+ dependency/coupling context only when required
```

Proceed condition:

- The `plan_context_packet` field names must be documented in `pge-exec` and generator handoff docs before issue-file plans can route `READY_FOR_EXECUTE`.

### Round 3: Gate And Failure-Mode Review

Finding:

- Superpowers and gstack both show that hard gates matter when the default agent behavior is to skip design or soften review findings.
- The current plan already names Final Plan Gate and `pge-exec` validation, but implementation must make shape rejection deterministic enough for Markdown contracts.

Decision:

- Final Plan Gate validates the combined artifact:

```text
plan.md stable fields
+ plan.md ## issues index
+ referenced issues/Ixxx.md files
= executable plan contract
```

- `pge-exec` repeats the shape checks before run creation. It must stop before creating `runs/<run_id>/` when the plan is embedded-body, malformed, missing issue files, or index/file inconsistent.
- `non_canonical_plan_shape` is allowed only as an exec failure reason. It is not a new plan route, review route, or verdict vocabulary.

Proceed condition:

- Missing issue file, unknown dependency, embedded full issue body, and index/file status mismatch must be represented in eval/manual protocol scenarios before this migration is considered complete.

### Round 4: Execution Ergonomics Review

Finding:

- GSD's wave model and Agent harness references support index-first scheduling, but this PGE change should not add a new scheduler artifact.
- The previous source direction mentioned `exec/progress.md` and `exec/decision-log.md`; this plan correctly rejects those as new task-level exec state because PGE already has run-scoped state.

Decision:

- Execution progress remains:

```text
runs/<run_id>/state.json
runs/<run_id>/manifest.md
runs/<run_id>/implementation-notes.md
runs/<run_id>/evidence/
```

- No `exec/progress.md`, `exec/decision-log.md`, `wave-plan.md`, or task-level run state is introduced in this migration.
- `Parallel Hint` in the issue index is advisory. Runtime truth, dependency graph, target-area overlap, verification coupling, execution type, and security risk decide scheduling.

Proceed condition:

- Any implementation that adds task-level exec state is out of scope and should route back to planning.

### Round 5: Evaluator Boundary Review

Finding:

- Anthropic's Evaluator-Optimizer evidence supports a separate evaluator, but gstack and Codex-style reviews show a common failure: review becomes checklist completion instead of outcome judgment.
- Issue files make that failure easier unless the boundary is explicit.

Decision:

- Evaluator remains final run-level pressure over the composed diff and evidence.
- Evaluator may inspect issue files as supporting issue-local contracts, but it judges whether the composed run satisfies `plan.md` goal, non-goals, acceptance, verification, stop conditions, and evidence requirements.
- Issue completion is evidence, not proof. Generator `READY` produces a candidate; final `PASS` belongs only after run-level verification.

Proceed condition:

- Evaluator and review docs must preserve this boundary before the migration routes ready.

## External Method Comparison

| Method | Relevant Strength | Migration Decision | What Not To Copy |
|---|---|---|---|
| Matt skills | Vertical slices, behavior-contract issues, progressive disclosure, small composable skills. | Issue files are bounded execution blocks; index-first plan keeps context small. | Do not turn PGE issues into GitHub issue tracker workflow or repeated HITL grilling. |
| Superpowers | Hard design-before-code gate and spec self-review before implementation. | Embedded issue plans are non-canonical execution input; upgrade goes through `pge-plan`, not `pge-exec`. | Do not require user approval after every section or make every tiny task pay full spec ceremony. |
| Claude Code best practice | Verification-first, cross-context review, static artifacts, small vertical plans. | Add eval/manual scenarios for happy path, rejection path, missing file, local adaptation. | Do not rely on prompts alone as control flow; preserve artifact gates. |
| Codex / cross-model review | Independent review can find plan/implementation drift without rewriting the source plan. | Use review pressure to strengthen the plan, not to re-decide the accepted direction. | Do not introduce a second canonical Codex plan file. |
| GSD | File-as-context, wave scheduling, context budget, durable handoffs. | Use issue files for just-in-time context and run-scoped artifacts for progress. | Do not add roadmap/state machinery or task-level exec progress files. |
| Compound Engineering | Producer/consumer/validator/evidence coherence for protocol surfaces. | Treat this as a coordinated contract migration across producer, validator, consumer, evaluator, and final response. | Do not create generic agent-OS abstractions or new resident agents. |
| gstack | Scope challenge, failure modes, outside voice, hard evidence. | Require source-fidelity, index/file consistency, hidden-coupling, and verification-topology checks. | Do not import interactive per-issue questioning or broad code-review checklists into planning. |
| Anthropic agent harnesses | Evaluator-Optimizer, hard thresholds, just-in-time context, durable outputs. | Preserve run-level Evaluator and issue lazy-loading. | Do not make Evaluator a per-issue serial approver. |

## Review Findings And Repairs Applied To This Plan

| Finding | Severity | Repair In This Plan |
|---|---|---|
| Source direction mentioned task-level `exec/progress.md` / `exec/decision-log.md`, which conflicts with PGE run-scoped state. | Required | Plan maps those concepts to `runs/<run_id>/state.json`, `manifest.md`, and `implementation-notes.md`; task-level exec state is a non-goal. |
| Issue files could become mini-plans. | Required | Plan separates `What Belongs In plan.md` from `What Belongs In issues/Ixxx.md` and requires issue files not to redefine plan-level contracts. |
| `pge-exec` could accidentally keep accepting old embedded issue plans. | Required | Plan defines shape detection and requires `non_canonical_plan_shape` before run creation. |
| Final Plan Gate could validate only `plan.md` and miss missing issue files. | Required | Plan requires combined plan + issue-file validation and index/file consistency checks. |
| Evaluator could degrade into issue checklist approval. | Important | Plan states Evaluator is run-level and issue completion is evidence only. |
| Migration could land partially. | Required | Plan requires coordinated implementation and names partial migration as the main failure mode. |
| Evals could lag behind docs. | Important | Plan includes I005 for producer/gate/exec rejection/adaptation scenarios. |

## Proceedable Version

This migration can proceed when the next turn is explicitly implementation-focused and the executor follows these constraints:

1. Implement as one coordinated protocol change, not independent cleanup.
2. Change only the scoped contract files named in the File Change Map.
3. Do not introduce new task-level exec state.
4. Do not add an embedded-plan compatibility executor.
5. Keep `schema_version: plan.v2`, `plan_gate`, `plan_route`, exec route values, review route values, and evaluator verdict values unchanged.
6. Treat `non_canonical_plan_shape` as an exec failure reason only.
7. Add or update eval/manual scenarios before claiming the migration complete.
8. Run the protocol consistency review after edits, comparing producer, consumer, validator, state/artifact writer, evaluator/review, and final response surfaces.

Recommended implementation grouping:

| Group | Includes | Why It Must Be Together |
|---|---|---|
| A: Producer + Template | `pge-plan` producer wording, `templates/plan.md`, new `templates/issue.md`, README artifact layout. | Creates the new artifact shape and prevents new plans from embedding issue bodies. |
| B: Validator + Self-Review | `plan-gate.md`, `final-plan-gate.md`, `self-review.md`, plan evals. | Prevents malformed split contracts from being marked executable. |
| C: Consumer + Brief | `pge-exec`, generator handoff, generator rules. | Makes execution reject old shape and lazy-load selected issue files with `plan_context_packet`. |
| D: Evaluator/Review Boundary | evaluator handoff, evaluator thresholds, `pge-review`. | Prevents issue completion from becoming final proof. |
| E: Coverage + Consistency | evals, grep/manual protocol review, final evidence matrix. | Proves producer/validator/consumer/evaluator alignment before closing. |

Implementation may still be delivered as one commit or one bounded run, but the review result forbids shipping only A without B+C.

## Pre-Implementation Stop Conditions

Stop before editing contract files if any of these are true:

- The next task asks for implementation compatibility with embedded issue bodies in `pge-exec`.
- The migration is narrowed to `pge-plan` templates only.
- The migration adds task-level execution state outside `runs/<run_id>/`.
- The route/status/verdict vocabulary is expanded beyond the single failure reason `non_canonical_plan_shape`.
- The executor cannot update or at least manually inspect eval coverage for missing issue files, embedded plan rejection, issue-file happy path, and exec-local adaptation.

If none of those stop conditions hold, the plan is ready to drive implementation.
