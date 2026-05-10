# PGE TODO

Updated: 2026-05-10

This file tracks what is still missing before `pge-execute` can claim stronger alignment with Anthropic-style long-running harness behavior.

Right now PGE should be treated as structurally similar in some places, but still materially behind the article's demonstrated runtime behavior.

## Current truth

- `setup` is warmup/scaffolding, not a core execution phase.
- The active core phase chain is `research -> plan -> exec`.
- The current executable runtime is still one implementation round.
- `retry`, `continue`, and `return_to_planner` are defined as canonical routes, but they are not automatically redispatched yet.
- Durable truth is artifact-backed state and progress, not chat history.

## Anthropic Critical Gates

These are the five primary checks that matter most for honest alignment with the article:

1. Planner raw-prompt ownership
   - Article expectation: Planner can expand a short raw prompt into a fuller spec/product frame.
   - PGE now: `pge-planner` shapes one bounded round and intentionally stops short of full product-spec ownership.
   - Gap: partial by design; needs an explicit decision between bounded planner and separate spec planner.

2. Preflight multi-turn negotiation
   - Article expectation: Generator and Evaluator iterate on the sprint contract until "done" is agreed before code.
   - PGE now: bounded preflight negotiation is specified in docs/contracts, but runnable proof is still missing.
   - Gap: semantics exist; executable proof does not.

3. Generator sprint/feature granularity
   - Article expectation: Generator works sprint-by-sprint or feature-by-feature across a larger build.
   - PGE now: one accepted bounded round only.
   - Gap: no true multi-sprint execution yet.

4. Evaluator hard-threshold grading
   - Article expectation: Evaluator uses explicit criteria and hard thresholds to fail weak work.
   - PGE now: independent evaluation exists, but graded dimensions, thresholds, and calibration fixtures are incomplete.
   - Gap: independence is present; thresholded QA is not.

5. Runtime long-running execution and recovery
   - Article expectation: Harness can sustain long-running execution with durable context/handoffs.
   - PGE now: artifact-backed recovery model is defined, but current executable path is still single-round and stop-on-unsupported-route.
   - Gap: recovery semantics exist; long-running executable loops do not.

## TODO

- [x] Integrate `pge-research` into the downstream chain.
  - Teach `pge-plan` to consume `.pge/tasks-<slug>/research.md` when present.
  - Preserve clean handoff semantics from `research -> plan -> exec`.
  - Keep `setup` as warmup/scaffolding rather than letting it re-expand into a core phase.

- [ ] Run a fresh real-Team smoke proof for the current thin-skill architecture.
  - Prove `planner -> pge-planner`, `generator -> pge-generator`, `evaluator -> pge-evaluator`.
  - Prove preflight happens before repo edits.
  - Prove Evaluator independently reads the real deliverable.

- [ ] Prove P1b bounded preflight negotiation in a runnable runtime, not just in docs/contracts.
  - Exercise `BLOCK + repair_owner = generator`.
  - Exercise bounded `preflight_attempt_id` increments.
  - Prove stop behavior when repair must return to Planner.

- [ ] Implement P2 bounded evaluator-to-generator retry.
  - Keep retries file-backed and attempt-scoped.
  - Require Generator to address prior evaluator feedback explicitly.
  - Stop deterministically at `max_attempts_per_round`.

- [ ] Implement P3 return-to-planner redispatch.
  - Re-enter Planner with prior contract and evaluator verdict.
  - Freeze a new `round_id`.
  - Resume through preflight instead of silently patching the old contract.

- [ ] Decide and document the long-running runtime model more explicitly.
  - Either stay artifact-first with team recreation as the durable model,
  - or add a continuous-session mode and describe when it is authoritative.

- [ ] Strengthen Planner for Anthropic-style raw prompt intake.
  - Either add a separate spec planner,
  - or keep `pge-planner` bounded and state clearly that this is an intentional divergence from the article's full product-spec planner.

- [ ] Decide whether Planner remains a bounded round shaper or gains an upstream raw-prompt-to-spec role.
  - This is the explicit resolution for the first Anthropic critical gate.

- [ ] Add richer evaluator criteria and hard thresholds.
  - At minimum cover product depth, functionality, design/UX quality, and code quality.
  - One critical dimension failure must force non-PASS.

- [ ] Add evaluator calibration fixtures.
  - Include false PASS, RETRY, BLOCK, and ESCALATE examples.
  - Validate prompt/schema drift against expected verdicts and routes.

- [ ] Keep contract layering honest.
  - `skills/pge-execute/contracts/*.md` remains the runtime-authoritative contract layer.
  - `skills/pge-execute/runtime/*.md` remains the current executable subset.
  - Remove or demote stale historical references to the deleted root `contracts/*.md` paths.
  - Do not let target-state language leak into `SKILL.md` executable claims.
