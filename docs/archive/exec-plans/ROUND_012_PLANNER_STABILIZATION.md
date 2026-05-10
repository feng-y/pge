# Round 012: Planner Stabilization

## Goal

Complete the new Planner design implementation before tightening Generator and Evaluator.

The Planner must become an evidence-backed current-round task owner, not a thin cutter and not a full product-spec planner.

## Why This Comes First

Generator and Evaluator stability depends on Planner freezing a clear task boundary.

If Planner leaves task split, DoD, evidence basis, or risk boundaries implicit:
- Generator will invent missing task semantics during execution.
- Evaluator will judge against an unstable acceptance frame.
- Preflight will become a repair mechanism for Planner gaps instead of a contract sanity check.

## Role Positioning

Planner remains one independent PGE agent.

It should not be described as two hidden agents named researcher and architect. Instead, Planner exposes several narrow responsibility facets:

- Evidence steward: loads bounded context and records source / fact / confidence / verification path.
- Scope challenger: tests whether the input is one bounded task and records rejected cuts.
- Contract author: owns current-round task split, DoD, deliverable, acceptance criteria, verification path, and handoff seam.
- Risk registrar: records concrete failure modes, observable signals, likely owners, and mitigations.
- Contract self-checker: checks for placeholders, contradictions, scope creep, and ambiguous acceptance criteria.

## External References Adapted

`ref-anthropic.md`:
Planner defines what, not how. PGE keeps this, but narrows it to current-round task contract rather than full product spec.

`ref-best-practice.md`:
Use Questions -> Research -> Design as the internal order. Keep each stage short and explicit.

`ref-gsd.md`:
Context is chained through artifacts. Planner's `evidence_basis` becomes the first durable context link for Generator and Evaluator; context loading strategy is recorded inside that existing section for now.

`ref-gstack.md`:
Scope Challenge maps to Planner's rejected cuts and failure mode register.

`ref-openspec.md`:
The proposal/spec/design/tasks DAG is not copied as multiple files yet. Planner compresses the useful parts into one bounded round contract.

`ref-superpowers.md`:
Borrow thin brainstorming, rejected alternatives, and contract self-check. Do not copy full user-approval spec workflow.

## Design Decisions

Planner owns current-round task split and DoD.

Planner does not own full-project backlog scheduling until multi-round runtime exists.

Planner must not decide execution mode or fast finish.

Planner must not prescribe Generator's implementation approach.

Planner may use one focused `planner_escalation` question when a clean contract cannot be frozen.

Planner output must be inspectable by gate checks, not only by prose quality.

## Required Runtime Surface Changes

### `agents/pge-planner.md`

Add and preserve:
- responsibility facets
- Questions gate
- Research pass
- thin counter-research / brainstorming pass
- architecture pass
- current-round task split ownership
- contract self-check
- forbidden mode-selection and fast-finish authority

### `skills/pge-execute/handoffs/planner.md`

Keep the existing Planner external section interface unchanged for this round.

Planner's new responsibilities are expressed inside existing sections:
- context loading strategy lives in `## evidence_basis`
- rejected cuts live in `## planner_note`
- failure mode register lives in `## design_constraints`
- contract self-check lives in `## planner_note`

Do not add new top-level Planner output sections until Generator, Evaluator, and orchestration are adjusted together.

### `skills/pge-execute/contracts/round-contract.md`

Round contract must define:
- evidence basis shape
- context loading strategy shape
- rejected cuts shape
- failure mode register shape
- current-round task split boundary

These are semantic requirements inside existing sections, not new external handoff fields.

### `bin/pge-validate-contracts.sh`

Static validation must fail if Planner loses:
- responsibility facets
- current-round task split ownership
- no full-project backlog scheduling rule

### Design / Progress Docs

`docs/design/pge-rebuild-plan.md`, `docs/design/REBUILD_PROGRESS.md`, and `docs/exec-plans/CURRENT_MAINLINE.md` must identify Planner stabilization as the active sub-lane before Generator stabilization.

## Output Contract

Planner output sections remain unchanged after this round:

```md
## goal
## evidence_basis
## design_constraints
## in_scope
## out_of_scope
## actual_deliverable
## acceptance_criteria
## verification_path
## required_evidence
## stop_condition
## handoff_seam
## open_questions
## planner_note
## planner_escalation
```

Section-level expansion is a future coordinated change. It must be done with Generator, Evaluator, orchestration, and validation in one round.

## Done-When

- Planner no longer presents researcher/architect as vague identity labels.
- Planner has explicit responsibility facets.
- Planner owns current-round task split and DoD.
- Planner does not own full-project backlog scheduling.
- Planner exposes context loading, rejected cuts, failure modes, and contract self-check inside existing sections.
- Planner handoff requires the same sections.
- Round contract defines the new semantic content inside existing sections.
- Static validator checks the new Planner surface.
- `./bin/pge-validate-contracts.sh` passes.

## Non-Scope

- Do not redesign Generator in this round.
- Do not redesign Evaluator in this round.
- Do not add new agents.
- Do not split Planner into researcher / architect agents.
- Do not implement multi-round backlog scheduling.
- Do not run a full proving run until Planner static surface is stable.
- Do not add new Planner top-level sections in this round.

## Deferred Section TODO

Future coordinated section expansion may add:
- `## context_loading_strategy`
- `## rejected_cuts`
- `## failure_mode_register`
- `## contract_self_check`

Only do this when Generator, Evaluator, orchestration gates, runtime docs, and validator are updated together.

## Verification

Run:

```bash
./bin/pge-validate-contracts.sh
```

Expected result:

```text
PGE contract validation passed.
```

## Next Round

After Planner stabilization, start Generator stabilization.

Generator should become the contract executor:
- consume Planner's evidence-backed contract
- create implementation steps inside the task boundary
- execute real work
- run local verification
- produce evidence mapped to acceptance criteria
- report deviations
- never rewrite task boundary or DoD
