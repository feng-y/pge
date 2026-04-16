# PGE Blueprint Governance Redesign Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Redesign the PGE skill so that the plan acts as the execution blueprint, Main/Scheduler governs conflicts and deviations, and completion requires blueprint fidelity plus explicit validation evidence.

**Architecture:** Update the core skill contract in `SKILL.md`, then align the three supporting documents so Planner, Generator, Evaluator, and Main all operate under the same blueprint-governed execution model. The redesign should preserve PGE’s multi-round structure while changing who has interpretation authority, when execution must stop, and how validation and review outcomes are recorded.

**Tech Stack:** Markdown skill files, repo-internal workflow documentation

---

## File structure

- Modify: `SKILL.md`
  - Rewrite the skill’s core principle, role definitions, execution loop, completion gate, and output format so plan is the execution blueprint and Main owns governance decisions.
- Modify: `phase-contract.md`
  - Expand the task contract so each task slice explicitly preserves plan fidelity, quality expectations, validation requirements, and ambiguity stop rules.
- Modify: `evaluation-gate.md`
  - Turn evaluation into blueprint-aware review with explicit plan/task alignment checks, validation evidence checks, escalation rules, and stronger blocker semantics.
- Modify: `progress-md.md`
  - Make `progress.md` track governance state, validation evidence state, and escalation decisions instead of only task progress.
- Optional reference read while editing: `README.md`
  - Keep examples and explanatory text aligned with the revised protocol if wording in the main docs changes significantly.

### Task 1: Redefine the core PGE protocol in `SKILL.md`

**Files:**
- Modify: `SKILL.md:8-149`
- Reference: `README.md:1-209`

- [ ] **Step 1: Rewrite the core principle to make the plan the execution blueprint**

Replace the current core principle section with language that says the plan is the execution blueprint, task contracts are only current-round slices of the blueprint, Generator must not fill strategic gaps, Evaluator must review against both blueprint and task slice, and Main/Scheduler governs ambiguity, conflict, and deviation.

- [ ] **Step 2: Rewrite the role definitions to match governance ownership**

Update the `Main / Scheduler`, `Planner`, `Generator`, and `Evaluator` sections so they express the following semantics:
- Main/Scheduler interprets the plan at execution time, decides what happens when plan/task/implementation conflict, and sends work back to Planner when blueprint repair is needed.
- Planner converts the plan into a current-round task slice without weakening plan-level quality or validation requirements.
- Generator implements only what the slice clearly authorizes and must escalate strategic gaps instead of filling them.
- Evaluator reviews against both plan and task slice, detects deviations and evidence gaps, and escalates governance questions to Main instead of resolving them locally.

- [ ] **Step 3: Replace the execution loop with a blueprint-governed loop**

Rewrite the `Execution loop` section so the rounds become:
1. Blueprint alignment
2. Strict execution
3. Blueprint-aware evaluation
4. Governance decision

Add explicit language that returning to Planner for blueprint repair is a normal outcome when ambiguity, conflict, or quality shortfall blocks high-quality execution.

- [ ] **Step 4: Strengthen the completion gate and output format**

Replace the single completion gate with wording that makes a task incomplete if it lacks required verification evidence, conflicts with the plan, depends on unresolved blueprint ambiguity, or requires a deviation that Main has not accepted.

Then revise the output format so:
- Planner output includes blueprint fidelity, unresolved ambiguity, and required validation for the slice.
- Generator output includes verification evidence actually produced, unverified areas, and ambiguity/escalation needs.
- Evaluator output includes plan/task alignment, evidence sufficiency, deviation report, and escalation recommendation.
- Main output includes governance decision, accepted/rejected deviations, and next action.

- [ ] **Step 5: Review `SKILL.md` for internal consistency**

Read the updated file and verify:
- `Main` is no longer described as orchestration-only.
- The new loop matches the new role definitions.
- Completion semantics align with the new evaluation semantics.
- No section still implies Generator or Evaluator can unilaterally resolve blueprint ambiguity.

### Task 2: Turn task contracts into blueprint-preserving slices in `phase-contract.md`

**Files:**
- Modify: `phase-contract.md:1-60`
- Reference: `SKILL.md`

- [ ] **Step 1: Expand the task contract fields**

Add the following required task contract fields after the existing list:
- Plan fidelity
- Quality bar
- Required validation evidence
- Ambiguity stop rule

Define each field in plain language so Planner must preserve plan-level requirements instead of silently downgrading them.

- [ ] **Step 2: Tighten acceptable and unacceptable task shapes**

Update the acceptable task shape guidance so a good task is not only small enough to verify, but also preserves the plan’s quality bar and does not shift unresolved blueprint decisions into generation.

Update the unacceptable task shape guidance to reject:
- slices that omit plan-required validation,
- slices that weaken plan-level quality requirements,
- slices that rely on Generator to interpret blueprint ambiguity,
- slices that could be functionally complete while still violating plan intent.

- [ ] **Step 3: Re-read for alignment with the new governance model**

Verify the document now clearly treats task contracts as slices of the blueprint rather than as independent mini-specs, and confirm the stop rule language is consistent with “return to Planner when ambiguity blocks high-quality execution.”

### Task 3: Redesign evaluation as blueprint-aware review in `evaluation-gate.md`

**Files:**
- Modify: `evaluation-gate.md:1-118`
- Reference: `SKILL.md`
- Reference: `phase-contract.md`

- [ ] **Step 1: Add a blueprint fidelity gate before scoring**

Before the scoring section, add a mandatory pre-score check that requires Evaluator to verify:
- implementation satisfies the current task slice,
- the current task slice remains faithful to the plan,
- the implementation satisfies plan-level quality expectations for this slice,
- unresolved ambiguity or deviation is escalated to Main/Scheduler rather than locally resolved.

- [ ] **Step 2: Add a validation evidence gate before scoring**

Add a second mandatory pre-score check requiring Evaluator to inspect what verification evidence was actually produced, whether build/compile evidence was provided when applicable, whether relevant tests were run when required, and which paths remain uncovered.

State explicitly that missing required evidence may still enter evaluation, but defaults to blocker handling rather than soft concern handling.

- [ ] **Step 3: Update verdicts and anti-patterns**

Revise the verdict section so it clearly distinguishes:
- Pass
- Block
- Escalate to Main
- Shrink and retry

Then add anti-patterns covering:
- accepting task success while ignoring blueprint failure,
- treating missing evidence as a soft concern,
- locally resolving plan/task ambiguity,
- passing code because it “looks reasonable”,
- treating explanation-heavy output or excessive comments as evidence of clarity.

- [ ] **Step 4: Review scoring and examples for compatibility**

Re-read the full file and make sure the new gates and verdicts still fit with the existing scoring approach, examples, and contract compliance language. Remove or rewrite any wording that would let Evaluator pass work that satisfies the task but violates blueprint intent.

### Task 4: Make `progress.md` carry governance state in `progress-md.md`

**Files:**
- Modify: `progress-md.md:1-101`
- Reference: `SKILL.md`
- Reference: `evaluation-gate.md`

- [ ] **Step 1: Expand what `progress.md` should record**

Add fields so `progress.md` records:
- current plan fidelity status,
- unresolved plan/task conflicts,
- latest governance decision by Main/Scheduler,
- validation evidence status,
- explicit blocker reason.

- [ ] **Step 2: Update Generator and Evaluator progress responsibilities**

Rewrite the Generator section so after generation it must record:
- what verification commands were run,
- what evidence was produced,
- what remains unverified,
- whether ambiguity blocked full execution.

Rewrite the Evaluator section so after evaluation it must record:
- whether the task slice was satisfied,
- whether plan fidelity was preserved,
- whether evidence was sufficient,
- whether escalation to Main is required.

- [ ] **Step 3: Update Main / Scheduler progress responsibilities**

Rewrite the Main section so after each governance decision it must record:
- continue / retry / shrink / return to Planner / converge,
- the reason for the decision,
- whether any deviation was accepted or rejected.

- [ ] **Step 4: Review the full file for role consistency**

Verify `progress.md` is now a compact governance state record rather than a diary, and confirm each role’s required update matches the revised responsibilities defined in `SKILL.md`.

### Task 5: Cross-file consistency pass

**Files:**
- Modify: `SKILL.md`
- Modify: `phase-contract.md`
- Modify: `evaluation-gate.md`
- Modify: `progress-md.md`
- Reference: `README.md`

- [ ] **Step 1: Read all four updated files together**

Read `SKILL.md`, `phase-contract.md`, `evaluation-gate.md`, and `progress-md.md` in order and confirm they all use the same model:
- plan is the blueprint,
- Main owns governance decisions,
- Planner preserves blueprint fidelity,
- Generator does not fill strategic gaps,
- Evaluator detects deviations and escalates rather than arbitrates.

- [ ] **Step 2: Fix inconsistent terminology inline**

Search for outdated terms and fix them so they consistently reflect the new protocol. In particular, rewrite any lingering phrases such as:
- “orchestration only” for Main,
- “current task contract only” for Evaluator,
- “minimal verification” when the text should require explicit evidence,
- any phrasing that makes task contracts sound independent from the plan.

- [ ] **Step 3: Run a placeholder and contradiction scan**

Read each file once more and check for:
- leftover old semantics,
- contradictory role responsibilities,
- unclear escalation points,
- vague validation wording,
- unresolved mention of examples that no longer fit the new protocol.

- [ ] **Step 4: Update `README.md` only if necessary**

If the README’s examples or explanation now materially misrepresent the protocol, update the minimal set of lines needed so the README no longer teaches the old model. If it still fits closely enough, leave it unchanged.

- [ ] **Step 5: Verify the final change set is focused**

Make sure the edits stay within the redesign scope above and do not add unrelated workflow ideas, extra roles, or framework ceremony beyond what is required to support blueprint-governed execution.
