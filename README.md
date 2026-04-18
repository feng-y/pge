# PGE (Plan-Generate-Evaluate)

A lightweight execution harness for repo-internal multi-round work that needs clear phase plans, verifiable task contracts, and separated planning/generation/evaluation.

PGE is an execute-first closed loop, not an execution-only skill and not an overall strategy host. It consumes PRDs, intent, or upstream plans and internally turns them into bounded current-scope work through a continuous planning lane before generation and evaluation begin.

## Positioning

PGE is an execution harness that separates upstream strategy from the current-phase execution loop:

- **Upstream layer:** strategy, roadmap intent, broad product or architecture direction, and external constraints live outside PGE.
- **`pge:execute`:** the core closed loop that consumes larger phase/spec input and internally slices it into bounded current-scope work through the Planner lane, then runs bounded execution through Generator, performs independent acceptance through Evaluator, and maintains progress/handoff state through Main/Scheduler.

The decomposition from larger plan to current executable slice stays inside the Planner lane rather than becoming a separate standing role or external preprocessing step.

## Usage

### `pge:execute`
The core execution loop. Use when you have a larger phase/spec input that needs to be turned into bounded, verifiable work.

The execution loop internally handles:
1. **Planning lane (Planner):** When the incoming plan is too large, first slice it into the current phase/slice, then freeze the current task/sprint contract with goal, boundary, deliverable, validation baseline, and handoff seam.
2. **Generation lane (Generator):** Execute the bounded contract and return deliverable + validation evidence + explicit unverified areas.
3. **Evaluation lane (Evaluator):** Independently accept or block based on contract compliance and evidence sufficiency.
4. **Orchestration layer (Main/Scheduler):** Maintain progress, dispatch work, and route convergence decisions.

The Planner lane is continuous: it handles both coarse slicing (larger input → current phase/slice) and current contract shaping (current phase/slice → current task contract), rather than these being separate roles or external steps.

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

## Input expectations

```bash
/pge path/to/plan.md
```

## PGE v1 Entry Gate

PGE accepts an upstream plan, not a pre-frozen current task contract.

An input plan may enter PGE v1 only if all of the following are true:

1. it has a concrete execution goal;
2. it has an identifiable scope boundary;
3. it does not require a clarify phase before execution can begin;
4. it has a minimum acceptance direction, so the round can be judged pass/fail.

If any of these conditions is missing, the input must not enter PGE. It must be routed upstream.

If the input is still primarily a clarify artifact, it must be routed upstream, not into PGE.

## Single bounded round (v1 heuristic)

A plan or slice forms a single bounded round only if all of the following are true:

1. it advances one clear goal;
2. it produces one primary deliverable;
3. it has one primary verification path for the round.

This heuristic exists only to decide whether Planner must cut further or must pass the plan through.

## Planner Entry Decision

Planner must use the “single bounded round (v1 heuristic)” as the only decision rule for determining whether to pass through or to slice.

After receiving the upstream plan, Planner must make one entry decision.

### Case A — Plan is already executable

This case applies if and only if the plan already satisfies the single bounded round heuristic.

If the plan already forms a single bounded round (one goal, one deliverable, one primary verification path), Planner must not decompose it further.

Planner must:
- freeze the current round contract,
- pass it directly to Generator.

### Case B — Plan still contains multiple slices

This case applies if and only if the plan does not satisfy the single bounded round heuristic.

If the plan does not yet form a single bounded round, Planner must produce exactly one current slice that already forms a single bounded round.

That slice must satisfy:
- one goal,
- one deliverable,
- one primary verification path,
- and must be directly executable by Generator.

Planner must not:
- perform multi-step or recursive decomposition in a single round,
- produce an intermediate slice that still requires further slicing before execution.

Planner must:
- freeze the round contract for that slice,
- then pass it to Generator.

## Anti-over-slicing

If the plan is already small enough to be executed as a single bounded round, Planner must not decompose it further.

PGE accepts an upstream plan. If the plan is already small enough, Planner must pass it through. If it is still large, Planner must cut exactly one executable slice.

## Team model

PGE uses **3 working roles plus 1 orchestration layer**:

### Main / Scheduler (orchestration layer)
- Owns orchestration for the current round
- Treats the plan as the execution blueprint for the current round
- Maintains `progress.md` as the source of truth for current execution state
- Collects evaluation results
- Handles scheduling, dispatch, state tracking, and convergence routing

### Planner
- Owns the continuous planning lane across both coarse slicing and current contract shaping
- When the incoming plan is too large, first slices it into the current phase/slice that can be executed in this round
- Then freezes the current phase contract and shapes the current task contract as a bounded execution slice
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
