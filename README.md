# PGE (Plan-Generate-Evaluate)

A lightweight execution skill for repo-internal multi-round work that needs clear phase contracts, verifiable task contracts, and separated planning/generation/evaluation.

PGE is not the plan host. It consumes an external plan, blueprint, or exec-plan and turns the current scope into bounded execution contracts, independent evaluation, and stable cross-round progress state.

## Positioning

PGE separates the upstream planning layer from the execution harness layer:

- **Upstream layer:** strategy, long-term architecture intent, project plan, exec-plan, and phase intent live outside PGE.
- **PGE layer:** current phase contract, current task contract, bounded execution, independent acceptance, and progress / handoff state live inside PGE.

Use PGE when the upstream plan already exists or the current phase boundary is clear enough to freeze into an execution contract. If the incoming plan is still too large, split it into the current phase or slice before entering the PGE loop.

## When to use PGE

Use this skill when:
- The task spans multiple rounds
- The current phase must stay bounded
- Each task must be independently verifiable
- Planning, generation, and evaluation should stay separate
- The current phase must leave a usable seam for the next phase
- Context would otherwise sprawl across rounds
- You want review and convergence without heavy ceremony

**Do NOT use for:**
- One-shot trivial edits
- Pure ideation before any phase boundary exists
- Web/app/browser harness flows
- Project-specific SOPs
- Large workflow frameworks with many content roles or heavy standing ceremony

## Usage

```bash
/pge path/to/plan.md
```

PGE expects an upstream plan, blueprint, or exec-plan as input. It does not host the overall plan; it consumes that upstream artifact and freezes the current round into execution contracts.

If the incoming plan is still too large, an optional upstream init/decomposition step may split it into the current phase or slice before entering PGE. That decomposition lives outside PGE and is not a standing PGE role.

The upstream plan should define enough current-scope intent for PGE to freeze:
- Current phase contract (what this phase delivers, what it does NOT deliver)
- Task breakdown or slices with acceptance criteria
- Boundary constraints (no-touch zones)
- Required validation evidence
- Handoff seam to next phase

## Team model

PGE uses **3 working roles plus 1 orchestration layer**:

### Main / Scheduler (orchestration layer)
- Owns orchestration for the current round
- Treats the plan as the execution blueprint for the current round
- Maintains `progress.md` as the source of truth for current execution state
- Collects evaluation results
- Handles scheduling, dispatch, state tracking, and convergence routing

### Planner
- Owns the phase and task contract shaping surface for the current round
- Freezes the current phase contract as a plan-faithful task slice
- Shapes the current task contract so it stays bounded, verifiable, and aligned with the phase boundary
- Preserves plan-level quality and validation requirements without overcommitting detailed implementation
- Preserves the handoff seam, enforces anti-overreach, and avoids over-fragmentation

### Generator
- Owns bounded execution for the current round
- Executes the assigned task contract one bounded slice at a time
- Returns deliverable + validation evidence + explicit unverified areas
- May self-evaluate before handoff, but self-checks do not replace independent evaluation

### Evaluator
- Owns independent acceptance for the current round
- Performs independent review against both the task slice and the blueprint
- Verifies contract compliance, validation evidence, and completion conditions
- Blocks completion when required evidence or contract fidelity is missing
- Escalates plan/task/implementation conflicts to Main / Scheduler
- Scores and provides verdict

## Execution loop

1. **Round 0 — Blueprint alignment**
   - Planner freezes the current phase and task as a plan-faithful slice
   - If the plan is incomplete, ambiguous, or in conflict with high-quality execution, Main / Scheduler routes it back to Planner for blueprint repair
   - Main / Scheduler records the current round state in `progress.md`

2. **Round 1 — Generate**
   - Generator executes the current task slice
   - Returns deliverable + validation evidence + explicit unverified areas
   - If blueprint ambiguity blocks high-quality execution, Generator stops and escalates instead of guessing
   - Main / Scheduler ensures `progress.md` reflects the generation state

3. **Round 2 — Blueprint-aware evaluation**
   - Evaluator reviews against both the task slice and the blueprint
   - Evaluator verifies contract compliance, acceptance criteria, and validation evidence
   - If plan/task/implementation conflict appears, Evaluator escalates to Main / Scheduler
   - Evaluation may take multiple rounds until the verdict is stable

4. **Round 3 — Convergence routing**
   - Main / Scheduler routes: continue / retry / shrink and retry / return to Planner / converge
   - Main / Scheduler updates `progress.md` with the latest routing decision

## Key improvements (2026-04-16)

### 1. Contract + blueprint compliance check (MANDATORY)

Evaluator must verify both the current contract and the upstream blueprint before scoring:
- Read the contract document and upstream plan
- Verify all contract-defined fields/interfaces exist
- Check that the task slice and implementation remain faithful to blueprint intent
- If contract, task, and blueprint point in different directions, escalate to Main / Scheduler
- Missing required contract elements → immediate BLOCK

**Why:** Prevents downstream integration failures and prevents a task from appearing complete while still undermining the upstream plan.

### 2. Orchestration-aligned progress updates

`progress.md` is owned by Main / Scheduler and should reflect current execution and routing state.

After generation, `progress.md` should show the latest deliverable, evidence status, and whether anything remains unverified:
```markdown
- [x] Task 2: FeatureTableMeta ✅ GENERATED (2026-04-16)
  - Files: model_server/ftable/feature_table_meta.h
  - Evidence: bazel test //model_server/ftable:feature_table_meta_test
  - Unverified: duplicate compat mapping path not yet covered
  - Status: Awaiting evaluation
```

After evaluation, `progress.md` should show the verdict, blueprint/task alignment, evidence sufficiency, and whether Main / Scheduler must route any follow-up action:
```markdown
- [x] Task 2: FeatureTableMeta ✅ PASS
  - Task slice satisfied: yes
  - Blueprint fidelity preserved: yes
  - Evidence sufficient: yes
  - Follow-up routing needed: no
```

**Why:** Prevents progress/code desync and keeps the team aligned on evidence state, blueprint fidelity, and routing state across rounds.

## Supporting files

- **[SKILL.md](./SKILL.md)** — Core skill definition and team model
- **[phase-contract.md](./phase-contract.md)** — Phase contract, task contract, acceptable vs unacceptable task shapes
- **[evaluation-gate.md](./evaluation-gate.md)** — Independent evaluation, scoring, verdicts, anti-patterns
- **[progress-md.md](./progress-md.md)** — What `progress.md` should record and when to update it

## Guardrails

PGE rejects these patterns:
- Main doing production work
- Planner over-fragmenting the work
- Generator expanding the task beyond contract
- Evaluator becoming self-review
- Smuggling in the next phase
- Building an isolated skeleton
- Abstracting for appearance
- Writing plans as pseudo-implementation
- Replacing progress with chat history

## Completion gate

**No task is complete without independent evaluation evidence.**

If the Evaluator has not reviewed the current deliverable against both the current task contract and the blueprint, the task is not done.

A task is also not complete if required validation evidence is missing or if a detected deviation still requires a Main / Scheduler decision.

## Example workflow

```
User: /pge docs/exec-plans/data-loading/featuretable-phase1a-registration-plan.md

Round 0:
  Planner → Freezes a blueprint-faithful slice (registration only, no load/parse)
  Main → Records current round state in progress.md

Round 1 (Task 1):
  Generator → Creates IDENTITY_CONTRACT.md + validation evidence
  Main → Records generated deliverable and evidence status in progress.md
  Evaluator → Verifies contract and blueprint fidelity (PASS)
  Main → Records PASS and continues

Round 2 (Task 2):
  Generator → Creates feature_table_meta.h
  Main → Records generated deliverable and unverified areas in progress.md
  Evaluator → Checks contract compliance (missing dataset_key field)
  Evaluator → Blocks acceptance
  Main → Records BLOCK and routes back for correction
  Generator → Fixes missing field
  Evaluator → Re-evaluates against task slice + blueprint (PASS)
  Main → Records PASS and continues

Round 3 (Task 3):
  Generator → Creates feature_table_registry.{h,cpp} + evidence
  Main → Records current execution state in progress.md
  Evaluator → Verifies slice completion, blueprint fidelity, and evidence (PASS)
  Main → Records PASS and continues

Round 4 (Task 4):
  Generator → Creates compat_name_mapper + feature_table_db
  Main → Records current execution state in progress.md
  Evaluator → Verifies slice completion, blueprint fidelity, and evidence (PASS)
  Main → Records PASS and convergence decision

Convergence:
  Main → All tasks complete, phase 1a registration increment ready
  Main → Archives progress.md
  Main → Hands off to phase 1b
```

## Output format

### Main / Scheduler output
- Current progress
- Current worklist
- No-touch boundary
- Routing decision
- Accepted deviations or escalation outcome
- `progress.md` update

### Planner output
- Current phase contract
- Current task contract
- Blueprint fidelity statement
- Key boundary choices
- Unresolved ambiguities
- Required validation for this slice
- Handoff seam

### Generator output
- Current task
- Boundary
- Deliverable
- Validation evidence actually produced
- Explicit unverified areas
- Explicit non-done items
- Ambiguity or escalation needs
- Seam status

### Evaluator output
- Scores (0-5 per criterion)
- Verdict
- Blocking issues
- Plan/task alignment check
- Validation evidence check
- Deviation report
- Overreach check
- Isolated-skeleton check
- Handoff quality judgment
- Escalation recommendation to Main / Scheduler when needed

## License

MIT
