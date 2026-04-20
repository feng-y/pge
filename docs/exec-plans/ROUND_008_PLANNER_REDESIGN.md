# Round 008: Planner Redesign

## 本轮目标

Redesign Planner to become a real PGE spec producer, not just a thin "round cutter". Make it output executable specs that directly drive Generator, Evaluator, and Main/Skill orchestration.

## Files Changed

- `agents/planner.md` - Complete redesign from thin cutter to spec producer

## What Changed in agents/planner.md

### 1. Input Model Changed

**Before (too abstract):**
```
Input:
- upstream_spec: The upstream plan or shaping artifact to execute
- current_blueprint_constraints: Any existing constraints or boundaries
- current_round_state: Runtime state when resuming or retrying
```

**After (more accurate and detailed):**
```
Input:
Primary input:
- upstream_spec: The upstream plan, shaping artifact, or task description
  (may be well-bounded or rough, single sentence or detailed plan)

Context inputs:
- current_blueprint_constraints: Existing architectural constraints, boundaries
- current_round_state: Runtime state when resuming or retrying
  (previous round ID, evaluator feedback, accumulated context)

Repo context (when needed):
- Use Read/Grep/Glob to understand repo structure
- Check existing patterns, conventions, constraints
- Verify claimed deliverable paths exist
```

**Key improvement:** Input model now acknowledges that upstream input may be rough or well-formed, and Planner may need to check repo context.

### 2. Output Became Real Executable Spec

**Before (abstract list):**
```
Output:
You must produce one executable PGE spec artifact containing:
- goal: What this round must settle now
- in_scope: What this round is allowed to change
- out_of_scope: What this round must not touch
- actual_deliverable: The concrete artifact this round must produce
- acceptance_criteria: Minimum conditions for completion
- verification_path: The primary way this round will be checked
- stop_condition: When this round should converge or escalate
- open_questions: Unresolved areas or low-confidence decisions
```

**After (concrete markdown template):**
```markdown
# Executable PGE Spec

## Goal
[What this round must settle now - one clear, bounded objective]

## Boundary
[What this round is allowed to change - specific files, directories, or areas]

## Deliverable
[The concrete artifact this round must produce - specific file paths or repo changes]

## Verification Path
[The primary way this round will be checked - specific commands or checks]

## Acceptance Criteria
- [Criterion 1: checkable condition]
- [Criterion 2: checkable condition]
- [Criterion 3: checkable condition]

## Required Evidence
[What evidence Generator must provide for Evaluator to validate]

## Allowed Deviation Policy
[Which local deviations may remain vs. which must route back out]

## No Touch Boundary
[What must remain out of scope - specific areas that must not change]

## Handoff Seam
[Where later work can continue without reopening this round]

## Stop Condition
[When this round should converge, retry, or escalate]

## Open Questions
[Unresolved areas or low-confidence decisions - explicit uncertainty]

## Planner Note
[pass-through | cut]

## Upstream Spec Reference
[Reference to the original upstream input]
```

**Key improvements:**
- Concrete markdown template with structure
- Clear artifact location: `.pge-artifacts/{run_id}-planner-output.md`
- Field names aligned with skill expectations (`boundary` not `in_scope/out_of_scope`)
- Inline guidance for each field
- Structured format that downstream roles can parse

### 3. Loop Bridge Established

**Before (vague interface role):**
```
## Interface Role

Your output is the round interface:
- For Generator: The executable PGE spec defines what to implement
- For Evaluator: The executable PGE spec defines what to validate
- For Main/Skill: The executable PGE spec defines orchestration, round closure, retry, or escalation
```

**After (three explicit alignment sections):**

**Added "Output contract alignment" section:**
- Maps Planner output → Generator consumption
- Maps Planner output → Evaluator validation
- Maps Planner output → Main/Skill orchestration

**Added "Alignment with Skill Orchestration" section:**
- Lists all fields skill expects
- Explains skill workflow after Planner output:
  1. Preflight check
  2. Generator spawn
  3. Evaluator spawn
  4. Routing

**Added "Alignment with Generator Communication" section:**
- Explains what Generator receives from spec
- Maps fields to Generator's needs
- Ensures Generator can execute without guessing

**Added "Alignment with Evaluator Communication" section:**
- Explains what Evaluator receives from spec
- Maps fields to Evaluator's needs
- Ensures Evaluator can validate independently

**Key improvement:** Explicit bridge between Planner output and all downstream roles with concrete field mappings.

### 4. Evidence Discipline Added

**Before:** No guidance on evidence gathering

**After:** Added "Evidence Discipline" section:

**When to gather evidence:**
- Upstream spec references specific files/areas → verify they exist
- Upstream spec assumes certain patterns → check if present
- Upstream spec conflicts with repo structure → document the conflict

**Do NOT gather evidence for:**
- Implementation details (Generator's job)
- Validation details (Evaluator's job)
- Exhaustive repo analysis (not needed for spec freezing)

**How to use evidence:**
- Verify upstream spec assumptions are valid
- Detect conflicts between spec and repo reality
- Make bounded slice selection more accurate
- Populate `open_questions` with concrete conflicts

**Key improvement:** Clear boundaries on when/how to gather evidence, avoiding both under-research and over-research.

### 5. Anti-Guessing Mechanism Strengthened

**Before:** Brief mention of "record open questions"

**After:** Detailed "Handle uncertainty explicitly" section in Core Behavior:

**When upstream spec is ambiguous:**
- Do NOT silently guess the intent
- Record the ambiguity in `open_questions`
- Provide your interpretation but mark it as low-confidence
- Let Evaluator or Main/Skill decide if escalation is needed

**When repo reality conflicts with upstream spec:**
- Do NOT silently adapt or reinterpret
- Record the conflict in `open_questions`
- Explain what the spec says vs. what repo reality is
- Escalate if the conflict prevents clean spec freezing

**Examples:**
- "Upstream spec says 'add to login page' but there are 3 login pages in the repo - assuming `src/auth/login.ts` (low confidence)"
- "Upstream spec requires modifying `database.ts` but that file doesn't exist - escalating"

**Key improvement:** Concrete guidance on handling ambiguity and conflicts, with examples.

### 6. Scenario Handling Added

**Before:** No concrete guidance for common cases

**After:** Added "Handling Common Scenarios" section with 5 scenarios:

1. **Upstream spec is well-bounded** → Pass-through
2. **Upstream spec is too broad** → Cut one bounded slice
3. **Upstream spec is ambiguous** → Provide narrowest interpretation + mark in open_questions
4. **Repo reality conflicts with upstream spec** → Document conflict, escalate if blocking
5. **Retrying after evaluator feedback** → Read prior feedback and adjust spec

**Key improvement:** Concrete action guidance for common situations Planner will encounter.

### 7. Core Behavior Expanded

**Before:** 7 numbered steps, mostly abstract

**After:** 10 numbered steps with concrete guidance:

1. Read and parse upstream input (with repo context checking)
2. Apply single bounded round heuristic (with simplicity-first principle)
3. Define the deliverable concretely (with good/bad examples)
4. Define acceptance criteria as checkable conditions (with good/bad examples)
5. Specify verification path (with examples)
6. Define boundaries explicitly (boundary + no touch boundary)
7. Handle uncertainty explicitly (ambiguity + conflicts)
8. Define stop condition (converge/retry/escalate)
9. Decide pass-through or cut (with criteria)
10. Write the executable PGE spec artifact (with self-check)

**Key improvement:** More detailed, actionable steps with examples throughout.

### 8. Forbidden Behavior Organized

**Before:** Flat list of "must NOT" items

**After:** Organized into 6 clear categories:

1. Do not do implementation design
2. Do not expand scope
3. Do not guess silently
4. Do not produce multiple specs
5. Do not leave gaps
6. Do not inject repo-specific knowledge

Each category has detailed explanation and examples.

**Key improvement:** Better organization makes forbidden behaviors clearer and easier to follow.

### 9. Quality Bar Strengthened

**Before:** Generic good vs bad examples

**After:** Specific examples for each quality dimension:

**Good executable PGE spec:**
- Clear, bounded goal (one concrete objective)
- Concrete deliverable (specific file paths)
- Checkable acceptance criteria (Evaluator can verify)
- Concrete verification path (specific commands)
- Explicit boundaries (what may/must not change)
- Executable without guessing
- Independently evaluable
- Preserves upstream intent
- Records open questions explicitly
- Aligns with downstream expectations

**Bad executable PGE spec:**
- Vague goals ("improve the system")
- Abstract deliverables ("better user experience")
- Uncheckable criteria ("code is high quality")
- Vague verification ("check if it works")
- Implicit boundaries
- Requires guessing
- Cannot be validated
- Reinterprets upstream spec
- Silently guesses
- Misaligns with downstream

**Key improvement:** Concrete examples for each dimension, making quality bar actionable.

## What aiworks Principles Were Absorbed

### From researcher:
1. **Evidence discipline**: When/how to gather evidence, what NOT to gather
2. **Explicit open questions**: Mark ambiguities, flag conflicts, no silent guessing
3. **Low-confidence handling**: Mark interpretations as low-confidence when uncertain

### From archi:
1. **Executable planning**: Bounded slice selection, concrete deliverables, checkable criteria
2. **Simplicity first**: Prefer simplest slice, avoid premature optimization
3. **Explicit verification path**: Specify how to verify, not just what to deliver

## What Was Intentionally NOT Absorbed

1. ✗ **Repo-specific domain knowledge**: Planner stays generic
2. ✗ **Heavy research workflow**: Minimal evidence gathering only
3. ✗ **Large evidence packages**: No exhaustive repo analysis
4. ✗ **Role expansion**: No full "intent → spec" ownership yet
5. ✗ **External knowledge injection**: No domain-specific patterns
6. ✗ **Multi-round decomposition**: Still produces one spec per round

## Preserved Core Ideas

✓ Single bounded round heuristic
✓ Pass-through or cut decision
✓ Freeze exactly one current round contract/spec
✓ No recursive decomposition
✓ No implementation design
✓ No offloading semantic gaps to Generator

## Quality Bar Met

✓ Same role name: Planner
✓ Much more useful than the thin version
✓ Outputs executable PGE spec with concrete structure
✓ Clearly bridges upstream spec to PGE execution loop
✓ Stays generic (no repo-specific knowledge)
✓ Does not drift into implementation design
✓ File length reasonable (~450 lines, not a huge essay)
✓ Satisfies skill orchestration needs
✓ Satisfies Generator communication needs
✓ Satisfies Evaluator communication needs

## Next Steps

1. Test Planner with actual `/pge-execute` invocation
2. Verify Planner produces specs that Generator can execute
3. Verify Planner produces specs that Evaluator can validate
4. Verify Planner produces specs that Main/Skill can orchestrate with
5. Iterate based on real execution feedback
