# Evaluation Gate

Use this file when evaluating whether the current task is actually complete.

## Independent evaluation

Evaluator reviews the deliverable against the task contract, not the Generator’s self-description.

Evaluator checks:
- scope discipline,
- deliverable quality,
- minimal verification,
- seam and handoff quality,
- whether the output remains phase-bounded,
- whether the output avoided becoming an isolated skeleton.

## Contract compliance check (MANDATORY)

Before scoring any task, Evaluator MUST verify contract compliance:

1. **Locate the contract document**
   - Usually Task 1 deliverable (e.g., IDENTITY_CONTRACT.md, contract.md)
   - Read the full contract to understand requirements

2. **Verify current task against contract**
   - All fields defined in contract exist in implementation
   - All interfaces defined in contract are exposed
   - Types match contract specifications
   - No contract requirements are missing

3. **If contract requirements are missing**
   - BLOCK immediately with score 0/10
   - List missing requirements clearly
   - Do NOT proceed to other evaluation criteria

**Example:**
- Contract defines: "FeatureTableMeta must include dataset_key field"
- Implementation missing dataset_key → BLOCK (0/10)
- Reason: "Missing dataset_key field required by IDENTITY_CONTRACT.md"

**Why this matters:**
This prevents downstream tasks from failing due to missing dependencies.
A task that passes its own acceptance criteria but violates the contract
will cause compilation failures or integration issues later.

**Contract takes precedence over task-level acceptance criteria.**

## Completion gate

**No task is complete without independent evaluation evidence.**

If the Evaluator has not reviewed the current deliverable against the current task contract, the task is not done.

Generator self-checks are useful, but they do **not** replace independent evaluation.

## Multi-round evaluation

Evaluation may take multiple rounds.

If blocking issues remain, the flow is:
1. Evaluator records blocking issues against the current contract.
2. Generator addresses only those issues or asks for contract clarification.
3. Evaluator reviews again.
4. Repeat until one of these is true:
   - **Pass**
   - **Pass with concerns**
   - **Reject**
   - **Shrink and retry**

Do **not** create a new standing review role just to support repeated evaluation.
Multi-round evaluation is still part of the Evaluator lane.

## Review scoring

Score each task on a **0–5** scale.

1. **Portability**  
   Does this remain valid outside one repo, one stack, or one domain?

2. **Role separation**  
   Are Main, Planner, Generator, and Evaluator still clearly separated?

3. **Task contract quality**  
   Is the task concrete, bounded, and independently executable?

4. **Scope discipline**  
   Does the work stay inside the current phase?

5. **Handoff quality**  
   Does the output leave a usable seam for the next task or phase?

6. **Anti-overdesign**  
   Does the work avoid framework drift, fake completeness, and premature abstraction?

7. **Form neutrality**  
   Does the skill stay neutral instead of drifting into web/app/browser-harness assumptions?

8. **Operational clarity**  
   Can the team act on it directly without extra interpretation?

## Verdicts

- **Pass** — The task satisfies the contract and preserves the next seam.
- **Pass with concerns** — The task is acceptable, but the next round must tighten specific points.
- **Reject** — The task misses the contract, drifts scope, or breaks role separation or handoff quality.
- **Shrink and retry** — The direction is plausible, but the task or phase was too large, too vague, or too heavy.

## Anti-patterns

### Evaluator becoming self-review
If Evaluator only says “looks good” or relies on the Generator’s summary instead of the contract, evaluation is invalid.

### Moving on with open blocking issues
If blocking issues were found, the current task is not complete. Re-run evaluation after correction.

### Replacing evaluation with chat confidence
Confidence, satisfaction, or “directionally correct” language are not evaluation evidence.
