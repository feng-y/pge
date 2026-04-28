# PGE Harness Progress

Updated: 2026-04-28

## Local harness reference

Reference inspected: `/code/3p/aiworks/davinci/skill/dev-cycle/SKILL.md` and `/code/3p/aiworks/README.md`.

Reusable concepts:

- Maintain per-run `progress.md` as the state-machine view.
- Keep an evaluator/reviewer as the final gate.
- Use bounded loop counts and explicit escalation instead of unbounded retries.
- Preserve role boundaries and route BLOCK findings back to the correct phase.
- Treat observer/progress logging as orchestration output, not an extra teammate.

PGE role mapping:

- `researcher + archi -> pge-planner`
- `coder + local reviewer -> pge-generator`
- independent Anthropic-style QA gate -> `pge-evaluator`

## Active evaluator gate

All PGE harness changes must preserve these constraints:

- Keep `pge-execute` honest about the executable surface it actually supports.
- Use a real planner/generator/evaluator team with file-backed handoffs.
- Do not simulate agent work in main orchestration.
- Freeze or preflight the current round contract before Generator performs repo edits.
- Require Generator to produce real deliverables and concrete evidence.
- Require Evaluator to inspect the actual deliverable independently before PASS.
- Preserve canonical routes instead of collapsing them into vague success/failure prose.
- Do not claim automatic multi-round execution until redispatch is implemented and verified.

Current runtime invariants:

- The current executable runtime is still a single implementation round.
- `retry`, `continue`, and `return_to_planner` have communication and persistence models, but automatic redispatch is not implemented yet.
- Durable truth is `state_artifact`, `progress_artifact`, and phase artifacts. Chat history is not durable state.
- If a team is lost, future recovery must recreate a same-role team from artifacts instead of relying on old conversational context.

## Current development state

Status: P0 complete, P1a verified, P1b implemented in skill/runtime docs and under validation.

Completed:

- Added a staged improvement task list at `docs/exec-plans/PGE_HARNESS_IMPROVEMENT_TASKS.md`.
- Refactored `skills/pge-execute/SKILL.md` into a progressive-disclosure entrypoint.
- Added `skills/pge-execute/runtime/` and `skills/pge-execute/handoffs/` runtime detail files.
- Added `docs/design/pge-execute/communication-protocol.md` for main-mediated file-backed teammate communication.
- Added `docs/design/pge-execute/layered-skill-model.md` to define the orchestration workflow skill writing model.
- Added `skills/pge-execute/runtime/persistent-runner.md` for long-running state, recovery, and future route loops.
- Added `docs/design/pge-execute/execution-framework-lessons.md` with OpenAI, Anthropic, Superpowers, Matt Pocock skills, Claude best-practice, Gstack, GSD, and OpenSpec lessons.
- Aligned the runtime skill with the Evaluator schema by switching from `route` / `route_reason` sections to `next_route`.
- Added Evaluator feedback sections `violated_invariants_or_risks` and `required_fixes` to the runtime gate.
- Added missing Planner gate sections `required_evidence`, `planner_note`, and `planner_escalation`.
- Added Planner evidence/design sections for the `researcher + archi -> planner` mapping.
- Added Generator `self_review` for the `coder + local reviewer -> generator` mapping.
- Removed hard-coded legacy output artifact filenames from Generator and Evaluator prompts.
- Added explicit `unsupported_route` for recognized routes that are not yet redispatched.
- Fixed reviewed agent issues around Planner required fields, raw prompt shaping, evidence basis, Generator context boundary, duplicate retry text, and Evaluator required_fixes wording.
- Updated the persistent runner plan with artifact-guided/spec-driven constraints from OpenSpec and context-management constraints from GSD/Claude best practices.
- Verified P1a preflight alignment across `SKILL.md`, `ORCHESTRATION.md`, `runtime/artifacts-and-state.md`, and `handoffs/preflight.md`.
- Added missing `preflight_pending` and `ready_to_generate` states to `ORCHESTRATION.md`.
- Reframed `skills/pge-execute/contracts/*.md` as the sole runtime-authoritative contracts for `pge-execute`; top-level `contracts/` is no longer treated as install-time authority.
- Removed the duplicate top-level `contracts/` files so root-level runtime authority is no longer ambiguous.
- Added `bin/pge-validate-contracts.sh` for static contract/schema drift checks.
- Reframed PGE as an orchestration workflow skill: `SKILL.md` orchestrates, resident agents do role work, and `runtime/` + `handoffs/` + `contracts/` act as phase skill resources.
- Rebuilt `docs/design/pge-execute/layered-skill-model.md` around the Claude orchestration-workflow structure: System Overview, Component Summary, Flow Diagram, Component Details, Execution Flow, Example Execution, Key Design Principles, and Architecture Patterns.
- Added a source pattern matrix for Superpowers `brainstorming`, Superpowers `executing-plans`, and Claude orchestration workflow, including non-adopted behaviors.
- Clarified team binding: teammates are named `planner`, `generator`, and `evaluator`, and they run agent surfaces `pge-planner`, `pge-generator`, and `pge-evaluator`.
- Moved design references out of the skill folder to `docs/design/pge-execute/`; `SKILL.md` now points there for maintenance context only.
- Added enum-value validation for critical preflight/evaluator route fields in `bin/pge-validate-contracts.sh`.
- Added explicit framing that `skills/pge-execute/contracts/runtime-state-contract.md` is the normative semantic superset while `runtime/artifacts-and-state.md` is the current executable subset.
- Reconciled `CURRENT_MAINLINE.md`, `CURRENT_STEP.md`, and `STAGE_PROGRESS.md` so historical smoke evidence is no longer presented as current thin-skill proof.
- Replaced the placeholder `docs/pge-smoke-test.md` with a current manual smoke-oriented validation procedure for the thin-skill architecture.
- Added an explicit Anthropic-harness alignment assessment to `docs/design/pge-execute/execution-framework-lessons.md`, separating adopted, intentionally narrower, and still-missing parts.
- Added a second-pass Anthropic alignment check that distinguishes role-name similarity from the article's deeper requirements: full product-spec planning, multi-sprint generator cadence, runtime-proven contract negotiation, hard-threshold evaluator grading, and continuous-session versus artifact-recovery runtime model.
- Added `todo.md` as the explicit unmet-gap list for Anthropic-alignment and current runtime missing pieces, so remaining work is separated from completed progress.
- Promoted the five Anthropic critical gates into explicit review surfaces across `todo.md`, `docs/design/pge-execute/execution-framework-lessons.md`, and `docs/exec-plans/PGE_HARNESS_IMPROVEMENT_TASKS.md`: Planner raw-prompt ownership, preflight multi-turn negotiation, Generator sprint/feature granularity, Evaluator hard thresholds, and real long-running runtime/recovery.
- Tightened the Anthropic assessment wording so it no longer reads like near-parity; current PGE is now described as structurally similar in places but still materially behind the article's demonstrated runtime behavior.

External references inspected this round:

- Anthropic long-running harness: planner/generator/evaluator split, file communication, independent evaluation.
- OpenAI Agents SDK: handoffs, guardrails, tracing as explicit boundaries.
- Superpowers: composable skills, written plans, TDD, spec-compliance review before quality review, fresh subagent context.
- Superpowers executing-plans/brainstorming: full source files inspected; compact skill writing, plan review before execution, bounded tasks, verification, blocker stop, context-first design, alternatives, hard gates, and spec self-review.
- Matt Pocock skills: small categorized skill catalog, one-purpose skill surfaces.
- Claude Code best-practice: progressive-disclosure folders, subagents for isolated context, durable commands/skills for repeated inner loops.
- Claude orchestration workflow: full source file inspected; command/orchestrator coordinates agent-with-skill and independent skill resources; component summary, flow diagram, execution flow, example execution, key design principles, and architecture patterns.
- Gstack: explicit operator review surfaces such as plan review, engineering review, design review, QA, shipping, canary, benchmark, security, retro.
- GSD: context engineering, state files, atomic plans, phase tracking, thin orchestrator plus fresh specialized agents.
- OpenSpec: proposal/spec/design/tasks/apply/archive artifact path.

In progress:

- Keeping preflight bounded to the current single implementation round.
- Keeping `SKILL.md` small and using the directory structure for detailed instructions.
- Reviewing remaining `pge-planner`, `pge-generator`, and `pge-evaluator` consistency after blocker fixes.
- Verifying that external framework lessons remain design guidance only and do not overstate executable redispatch.
- Validating the first bounded redispatch step: P1b preflight negotiation.

## Open issues

- Some historical docs still reference removed top-level contract paths, but runtime validation now keys off `skills/pge-execute/contracts/`; runtime smoke validation is still separate work.
- The current runtime still does not implement automatic `retry`, `continue`, or `return_to_planner` redispatch.
- Bounded preflight negotiation is now specified in the skill/runtime docs, but it still needs a runnable smoke proof in a real Team runtime.
- Persistent runner design now exists, but the executable skill still stops at `unsupported_route` for redispatch routes.
- No evaluator calibration fixtures exist yet for false PASS, RETRY, BLOCK, or ESCALATE cases.
- `bin/pge-validate-contracts.sh` is static only; it does not yet execute a real `/pge-execute test` smoke run.
- `SKILL.md` is near the entrypoint size limit; keep future additions out of the entrypoint unless they are routing-level instructions.
- Agent review blocker fixes have been applied, but prompt/schema consistency still needs a final validation pass.
- External framework references are incorporated as constraints and lessons; no external command system has been vendored or made a runtime dependency.
- The richer contract/state layer and the current executable runtime layer remain intentionally distinct; future edits must preserve that separation.

## Next tasks

1. Finish validating P1b bounded preflight negotiation with `max_preflight_attempts` and `preflight_attempt_id`.
2. Run consistency checks for stale route schema and artifact filename references after each prompt change.
3. Add a separate smoke-oriented validation path once a runnable Team runtime is available.
