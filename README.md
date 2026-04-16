# PGE (Plan-Generate-Evaluate)

A lightweight execution skill for repo-internal multi-round work that needs clear phase contracts, verifiable task contracts, and separated planning/generation/evaluation.

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

The plan is the governing execution blueprint for the current phase. It should define:
- Current phase contract (what this phase delivers, what it does NOT deliver)
- Task breakdown or slices with acceptance criteria
- Boundary constraints (no-touch zones)
- Required validation evidence
- Handoff seam to next phase

## Team model

PGE uses **3 working roles plus 1 orchestration layer**:

### Main / Scheduler (orchestration layer)
- Owns execution governance
- Treats the plan as the governing blueprint for the current round
- Maintains `progress.md` as the source of truth for current execution and governance state
- Collects evaluation results
- Decides ambiguity, conflict, deviation, and completion outcomes

### Planner
- Owns the goal-and-constraint definition surface for the current round
- Freezes the current phase contract as a plan-faithful task slice
- When starting from a short prompt, expands it into an ambitious spec while staying at product context and high-level technical design
- Preserves plan-level quality and validation requirements in that slice without overcommitting detailed implementation

### Generator
- Owns the constrained delivery surface for the current round
- Executes the assigned task contract one bounded feature / sprint slice at a time
- Returns deliverable + validation evidence + explicit unverified areas
- May self-evaluate before handoff, but self-checks do not replace independent evaluation

### Evaluator
- Owns the independent acceptance and correction surface for the current round
- Performs independent review against both the task slice and the blueprint
- Exercises the real application like a user where applicable (UI / API / data), not just the Generator summary
- Verifies contract compliance and validation evidence
- Enforces thresholds on product depth, functionality, design, and code quality
- Escalates plan/task/implementation conflicts to Main / Scheduler
- Scores and provides verdict

## Execution loop

1. **Round 0 — Blueprint alignment**
   - Planner freezes the current phase and task as a plan-faithful slice
   - If the plan is incomplete, ambiguous, or in conflict with high-quality execution, Main / Scheduler returns it to Planner for blueprint repair
   - Main / Scheduler records blueprint and governance state in `progress.md`

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

4. **Round 3 — Governance decision**
   - Main / Scheduler decides: continue / retry / shrink and retry / return to Planner / converge
   - Main / Scheduler updates `progress.md` with the latest governance decision

## Key improvements (2026-04-16)

### 1. Contract + blueprint compliance check (MANDATORY)

Evaluator must verify both the current contract and the governing blueprint before scoring:
- Read the contract document and governing plan
- Verify all contract-defined fields/interfaces exist
- Check that the task slice and implementation remain faithful to blueprint intent
- If contract, task, and blueprint point in different directions, escalate to Main / Scheduler
- Missing required contract elements → immediate BLOCK

**Why:** Prevents downstream integration failures and prevents a task from appearing complete while still undermining the governing plan.

### 2. Governance-aligned progress updates

`progress.md` is owned by Main / Scheduler and should reflect current execution and governance state.

After generation, `progress.md` should show the latest deliverable, evidence status, and whether anything remains unverified:
```markdown
- [x] Task 2: FeatureTableMeta ✅ GENERATED (2026-04-16)
  - Files: model_server/ftable/feature_table_meta.h
  - Evidence: bazel test //model_server/ftable:feature_table_meta_test
  - Unverified: duplicate compat mapping path not yet covered
  - Status: Awaiting evaluation
```

After evaluation, `progress.md` should show the verdict, blueprint/task alignment, evidence sufficiency, and whether Main / Scheduler must decide anything:
```markdown
- [x] Task 2: FeatureTableMeta ✅ PASS
  - Task slice satisfied: yes
  - Blueprint fidelity preserved: yes
  - Evidence sufficient: yes
  - Governance action needed: no
```

**Why:** Prevents progress/code desync and keeps the team aligned on evidence state, blueprint fidelity, and governance state across rounds.

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
  Main → Records current blueprint and governance state in progress.md

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
- Blueprint governance decision
- Accepted or rejected deviations
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
