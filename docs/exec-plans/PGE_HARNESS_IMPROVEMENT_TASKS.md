# PGE Harness Improvement Tasks

## Purpose

Track the staged work needed to evolve `pge-execute` from a bounded smoke harness into a planner/generator/evaluator review loop inspired by Anthropic's long-running harness design, without overstating what the current runtime supports.

Local reference: `/code/3p/aiworks/davinci/skill/dev-cycle/SKILL.md`.

External references folded into this plan:

- Anthropic long-running harness for Planner/Generator/Evaluator separation.
- OpenAI Agents SDK handoffs, guardrails, and tracing for explicit phase boundaries.
- Superpowers, Gstack, GSD, Matt Pocock skills, Claude Code best-practice, and OpenSpec for progressive disclosure, artifact-guided planning, isolated role contexts, and review-loop ergonomics.

Role mapping for PGE:

- `researcher + archi` map into `pge-planner`: gather lightweight evidence, identify constraints, freeze the current round contract.
- `coder + local reviewer` map into `pge-generator`: implement, verify locally, self-review, and hand off without final approval.
- Anthropic-style independent QA maps into `pge-evaluator`: final skeptical gate, no code edits.

## Current executable claim

`pge-execute` currently supports one real Agent Team run:

1. Planner writes one bounded round contract.
2. Generator performs real repo work and writes evidence.
3. Evaluator independently checks the deliverable.
4. Main routes `PASS + converged` to success.
5. Main preserves other canonical routes but stops without redispatch.

## Anthropic Gate Checklist

Use this checklist when judging whether PGE is merely structurally similar to the article or actually aligned with it:

- Planner: can PGE truthfully handle raw prompt -> spec expansion, or is it intentionally bounded to round shaping?
- Preflight: is contract negotiation just documented, or proven as a real multi-turn runtime loop?
- Generator: does execution happen one bounded round at a time only, or across sprint/feature slices?
- Evaluator: does QA use explicit hard-threshold criteria, or only free-form acceptance language?
- Runtime: can the system recover and continue long-running work, or does it still stop on unsupported canonical routes?

Current answer:
- Planner: bounded round shaping only
- Preflight: specified, not yet runtime-proven
- Generator: single round only
- Evaluator: independent, but not yet threshold-calibrated
- Runtime: artifact-recovery model defined, long-running redispatch not yet implemented

## Task List

### P0 - Schema and artifact alignment

Status: done in this round.

- Align `skills/pge-execute/SKILL.md` with `agents/pge-evaluator.md` by using `## next_route` instead of a separate `## route` / `## route_reason` artifact schema.
- Require evaluator sections `## violated_invariants_or_risks` and `## required_fixes` so non-PASS outcomes carry actionable feedback.
- Add missing Planner sections `## required_evidence`, `## planner_note`, and `## planner_escalation` to the executable skill gate.
- Add Planner sections `## evidence_basis` and `## design_constraints` to reflect the `researcher + archi -> planner` mapping.
- Add Generator section `## self_review` to reflect the `coder + local reviewer -> generator` mapping.
- Remove hard-coded legacy artifact output names from Generator and Evaluator prompts; agents must write to orchestration-provided `output_artifact`.
- Add explicit `unsupported_route` state for canonical routes that are recognized but not yet redispatched.
- Split long skill instructions into progressive-disclosure detail files under `runtime/`, `handoffs/`, and `docs/design/pge-execute/`.
- Keep external framework lessons in `docs/design/pge-execute/execution-framework-lessons.md`; do not expand the `SKILL.md` entrypoint with copied workflow prose.
- Add `docs/design/pge-execute/layered-skill-model.md` so `pge-execute` is authored as an orchestration workflow skill rather than a flat instruction file.
- Treat `skills/pge-execute/contracts/*.md` as the authoritative runtime contracts for this skill.
- Do not rely on top-level `contracts/` for installed runtime behavior; migrate legacy references over time.

Acceptance:

- No current runtime prompt asks Evaluator for both `route` and `next_route`.
- Agent prompts do not force old `*-output.md` / `*-verdict.md` filenames when orchestration provides a different output path.
- Non-converged canonical routes are persisted honestly instead of being collapsed into generic stopped state.
- `SKILL.md` remains a compact entrypoint; detailed phase prompts and gates live in dedicated files.
- The skill has explicit layers: orchestrator skill, runtime resources, resident agents, phase resources, contracts, validation/progress.
- External workflow references are traceable without becoming runtime dependencies.
- Runtime behavior does not depend on top-level `contracts/`.

### P1a - Contract preflight gate

Status: implemented and verified.

Goal:

Add a pre-generation contract review step so Generator and Evaluator confirm that the current round is executable and independently testable before implementation starts.

Tasks:

- Add `preflight_artifact = .pge-artifacts/<run_id>-preflight.md`.
- Add `progress_artifact = .pge-artifacts/<run_id>-progress.md`.
- Add state transitions `planning -> preflight_pending -> ready_to_generate`.
- Send the Planner artifact to Generator for an execution proposal.
- Send the proposal to Evaluator for preflight review.
- Freeze the accepted contract before Generator starts real edits.

Acceptance:

- Generator does not start repo writes until preflight passes.
- Evaluator can reject vague, untestable, or overbroad contracts before implementation.
- Preflight failure routes to `return_to_planner` or `unsupported_route` until replanning is implemented.
- Progress records phase status, open issues, evaluator gate status, and whether Generator edits are allowed.

### P1b - Bounded contract negotiation

Status: implemented in skill/runtime docs; pending runnable smoke verification.

Goal:

Allow Generator and Evaluator to repair a weak contract proposal a bounded number of times before returning to Planner.

Tasks:

- Add `max_preflight_attempts`, default 2.
- Track `preflight_attempt_id`.
- Send Evaluator `required_contract_fixes` back to Generator for proposal repair.
- Stop at `return_to_planner` when repeated proposal repair fails.

Acceptance:

- A vague but repairable execution proposal can be fixed before implementation.
- A broken Planner contract still returns to Planner rather than being patched by Generator.

### P2 - Bounded retry loop

Status: queued.

Goal:

Implement the first real feedback loop: Evaluator feedback can be sent back to Generator for a bounded retry of the same round.

Tasks:

- Add `max_attempts` to runtime state, default 3.
- Track `attempt_id` and per-attempt generator/evaluator artifacts.
- On `RETRY` or `BLOCK + retry`, send Evaluator `required_fixes` back to Generator.
- Require Generator retry output to cite previous feedback and changed evidence.
- Stop at `failed` or `unsupported_route` after repeated failure on the same issue.

Acceptance:

- A repairable Evaluator failure triggers another Generator attempt without asking the user.
- All attempts are file-backed and traceable.
- The loop stops deterministically at max attempts.

### P3 - Return-to-planner loop

Status: queued.

Goal:

Support contract repair when Evaluator decides the current round contract is not a fair acceptance frame.

Tasks:

- On `ESCALATE` or `return_to_planner`, send Planner the previous contract, Generator bundle, and Evaluator verdict.
- Require Planner to produce a repaired round contract with a new `round_id`.
- Preserve `upstream_plan_ref` while updating `active_round_contract_ref`.
- Resume preflight after replanning.

Acceptance:

- Ambiguous or broken contracts are repaired by Planner, not silently reinterpreted by Generator.
- Runtime state makes the contract identity change explicit.

### P4 - Product/spec planner split

Status: queued.

Goal:

Separate high-level product/spec expansion from bounded round planning.

Tasks:

- Add a `pge-spec-planner` role for raw user prompt to product/spec shaping.
- Keep `pge-planner` focused on one bounded executable round.
- Add a mode flag:
  - `smoke`: current single-round smoke path
  - `review-loop`: bounded Generator/Evaluator retry loop
  - `full`: spec planner plus round loop

Acceptance:

- The current Planner is no longer pressured to both expand product scope and cut a bounded round.
- `smoke` remains minimal and fast.

### P5 - Evaluator calibration fixtures

Status: queued.

Goal:

Make Evaluator less generous and more consistent by maintaining examples of correct verdicts and by grading against clearer hard-threshold criteria.

Tasks:

- Add fixtures for false PASS, RETRY, BLOCK, and ESCALATE cases.
- Include expected verdict, expected route, and rationale.
- Add explicit acceptance dimensions for at least product depth, functionality, design/UX quality, and code quality.
- Define minimum thresholds that force non-PASS when one critical dimension fails.
- Add a validation command that checks prompt/schema consistency against fixtures.

Acceptance:

- Evaluator prompt changes can be reviewed against known failure modes.
- Evaluator judgments are anchored to explicit dimensions instead of only free-form critique.
- The harness has a practical way to tune QA behavior without relying only on prose.
