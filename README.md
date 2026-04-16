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
- Large workflow frameworks with many standing roles

## Usage

```bash
/pge path/to/plan.md
```

The plan document should define:
- Current phase contract (what this phase delivers, what it does NOT deliver)
- Task breakdown with acceptance criteria
- Boundary constraints (no-touch zones)
- Handoff seam to next phase

## Team model

PGE uses at most **4 standing roles**:

### Main / Scheduler
- Orchestrates the workflow
- Maintains `progress.md`
- Collects evaluation results
- Decides continue/retry/shrink/converge

### Planner
- Freezes the current phase contract
- Defines task contracts

### Generator
- Executes the assigned task contract
- Returns deliverable + minimal verification evidence

### Evaluator
- Performs independent acceptance review
- Verifies contract compliance
- Scores and provides verdict (PASS/BLOCK)

## Execution loop

1. **Round 0 — Contract freeze**
   - Planner freezes phase and task contracts
   - Main/Scheduler records state in `progress.md`

2. **Round 1 — Generate**
   - Generator executes task contract
   - Generator updates `progress.md` (status: GENERATED)
   - Returns deliverable + verification evidence

3. **Round 2 — Independent evaluation**
   - Evaluator verifies contract compliance
   - Evaluator checks acceptance criteria
   - Evaluator updates `progress.md` (status: PASS/BLOCK)
   - May take multiple rounds until verdict is stable

4. **Round 3 — Convergence**
   - Main/Scheduler decides: continue/retry/shrink/converge
   - Updates `progress.md` with decision

## Key improvements (2026-04-16)

### 1. Contract compliance check (MANDATORY)

Evaluator must verify contract document before scoring:
- Read contract document (usually Task 1 deliverable)
- Verify all contract-defined fields/interfaces exist
- Missing requirements → immediate BLOCK (0/10)

**Why:** Prevents downstream compilation failures. A task that passes its own acceptance criteria but violates the contract will cause integration issues later.

### 2. Mandatory progress updates

**Generator** must update `progress.md` after generating code:
```markdown
- [x] Task 2: FeatureTableMeta ✅ GENERATED (2026-04-16)
  - Files: model_server/ftable/feature_table_meta.h
  - Status: Awaiting evaluation
```

**Evaluator** must update `progress.md` after evaluation:
```markdown
- [x] Task 2: FeatureTableMeta ✅ PASS (10/10)
  - All acceptance criteria met
  - Contract compliance verified
```

**Why:** Prevents progress/code desync in multi-session work. `progress.md` is the source of truth for collaboration.

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

If the Evaluator has not reviewed the current deliverable against the current task contract, the task is not done.

## Example workflow

```
User: /pge docs/exec-plans/data-loading/featuretable-phase1a-registration-plan.md

Round 0:
  Planner → Freezes phase contract (registration skeleton only, no load/parse)
  Main → Creates progress.md

Round 1 (Task 1):
  Generator → Creates IDENTITY_CONTRACT.md
  Generator → Updates progress.md (GENERATED)
  Evaluator → Verifies contract (10/10, PASS)
  Evaluator → Updates progress.md (PASS)

Round 2 (Task 2):
  Generator → Creates feature_table_meta.h
  Generator → Updates progress.md (GENERATED)
  Evaluator → Checks contract compliance (missing dataset_key field)
  Evaluator → Updates progress.md (BLOCK 0/10)
  Generator → Fixes missing field
  Evaluator → Re-evaluates (10/10, PASS)
  Evaluator → Updates progress.md (PASS)

Round 3 (Task 3):
  Generator → Creates feature_table_registry.{h,cpp}
  Generator → Updates progress.md (GENERATED)
  Evaluator → Verifies (10/10, PASS)
  Evaluator → Updates progress.md (PASS)

Round 4 (Task 4):
  Generator → Creates compat_name_mapper + feature_table_db
  Generator → Updates progress.md (GENERATED)
  Evaluator → Verifies (10/10, PASS)
  Evaluator → Updates progress.md (PASS)

Convergence:
  Main → All tasks complete, phase 1a registration skeleton ready
  Main → Archives progress.md
  Main → Hands off to phase 1b
```

## Output format

### Main / Scheduler output
- Current progress
- Current worklist
- No-touch boundary
- Convergence decision
- `progress.md` update

### Planner output
- Current phase contract
- Current task contract
- Key boundary choices
- Handoff seam

### Generator output
- Current task
- Boundary
- Deliverable
- Minimal verification result
- Explicit non-done items
- Seam status

### Evaluator output
- Scores (0-10 per criterion)
- Verdict (PASS/BLOCK)
- Blocking issues
- Overreach check
- Isolated-skeleton check
- Handoff quality judgment

## License

MIT
