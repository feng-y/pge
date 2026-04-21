# Evaluation Gate

## Normalization status

For the current PGE execution-core proof, `agents/*.md` and `contracts/*.md` are the normative seam set.
This file is a supporting reference for richer evaluator guidance and must not silently override the normalized verdict and routing seams.

Use this file when Evaluator performs independent acceptance on whether the current task is actually complete under both the blueprint and the current task slice.

## Independent acceptance

Evaluator reviews the deliverable against both the task contract and the governing plan, not the Generator’s self-description or self-judged completion.

Evaluator checks:
- task completion,
- blueprint fidelity,
- deliverable quality,
- validation evidence,
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
   - BLOCK immediately with score 0/5
   - List missing requirements clearly
   - Do NOT proceed to other evaluation criteria

**Example:**
- Contract defines: "FeatureTableMeta must include dataset_key field"
- Implementation missing dataset_key → BLOCK (0/5)
- Reason: "Missing dataset_key field required by IDENTITY_CONTRACT.md"

**Why this matters:**
This prevents downstream tasks from failing due to missing dependencies.
A task that passes its own acceptance criteria but violates the contract
will cause compilation failures or integration issues later.

**Contract compliance is mandatory, but contract interpretation still lives inside plan-governed execution.**
If contract compliance, task completion, and blueprint fidelity point in different directions, escalate to Main / Scheduler instead of locally deciding which source wins.

## Blueprint fidelity gate (MANDATORY)

Before scoring any task, Evaluator MUST verify blueprint fidelity:

1. **Check task slice against the plan**
   - Does the current task slice remain faithful to the plan?
   - Does the task preserve plan-level quality expectations for this round?

2. **Check implementation against blueprint intent**
   - Does the implementation satisfy the task slice?
   - Does it also preserve the plan’s intent, not just the task’s surface wording?

3. **If blueprint conflict exists**
   - Do NOT locally resolve the conflict
   - Record the conflict clearly
   - Escalate to Main / Scheduler for governance decision

## Validation evidence gate (MANDATORY)

Before scoring any task, Evaluator MUST inspect the validation evidence:

1. **Check what evidence was actually produced**
   - What commands were run?
   - What output or result was produced?

2. **Check required build / compile evidence when applicable**
   - If the slice required executable validation, was it actually run?

3. **Check test evidence when required**
   - Were relevant tests run when the plan or task required them?
   - Are uncovered paths explicitly identified?

4. **If required evidence is missing**
   - Evaluation may still proceed
   - Default handling is BLOCKER, not soft concern

## Completion gate

**No task is complete without independent evaluation evidence.**

If the Evaluator has not reviewed the current deliverable against both the current task contract and the blueprint, the task is not done.

Generator self-checks are useful, but they do **not** replace independent evaluation.

## Multi-round evaluation

Evaluation may take multiple rounds.

If blocking issues remain, the flow is:
1. Evaluator records blocking issues against the current contract and blueprint.
2. Generator addresses only those issues or asks for contract clarification.
3. If the issues expose blueprint ambiguity or task/plan conflict, escalate to Main / Scheduler.
4. Evaluator reviews again after the issue is corrected or routing decision is made.
5. Repeat until one of these is true:
   - **Pass**
   - **Block**
   - **Escalate to Main**
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

- **Pass** — The task satisfies the task slice, preserves blueprint intent, and includes sufficient validation evidence.
- **Block** — Required contract elements, validation evidence, or completion conditions are missing, so the task cannot be accepted as complete.
- **Escalate to Main** — Task completion, blueprint fidelity, or deviation acceptability cannot be resolved inside evaluation and requires governance decision.
- **Shrink and retry** — The direction is plausible, but the slice is too large, too vague, too evidence-light, or too difficult to stabilize in its current form.

## Anti-patterns

### Evaluator becoming self-review
If Evaluator only says “looks good” or relies on the Generator’s summary instead of the contract and blueprint, evaluation is invalid.

### Moving on with open blocking issues
If blocking issues were found, the current task is not complete. Re-run evaluation after correction or governance decision.

### Replacing evaluation with chat confidence
Confidence, satisfaction, or “directionally correct” language are not evaluation evidence.

### Accepting task success while ignoring blueprint failure
If the task appears complete but the output undermines the plan, do not pass it. Escalate.

### Treating missing evidence as a soft concern
If required evidence is missing, do not downgrade it into “concerns.” Default to blocker handling.

### Resolving plan/task ambiguity locally
If plan, task, and implementation point in different directions, do not pick one inside evaluation. Escalate to Main / Scheduler.

### Treating explanation-heavy output as clarity
Excessive explanation or excessive comments do not prove the slice is clear. Evaluate the artifact, evidence, and blueprint fidelity instead.
