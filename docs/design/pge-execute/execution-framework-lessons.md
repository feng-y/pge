# Execution Framework Lessons

This document records external and local workflow lessons that PGE should absorb without turning `pge-execute` into a heavy workflow platform.

## Sources

- OpenAI Agents SDK handoffs: https://openai.github.io/openai-agents-python/handoffs/
- OpenAI Agents SDK guardrails: https://openai.github.io/openai-agents-python/guardrails/
- OpenAI Agents SDK tracing: https://openai.github.io/openai-agents-python/tracing/
- Anthropic Claude Code subagents: https://code.claude.com/docs/en/sub-agents
- Anthropic Claude Code hooks: https://code.claude.com/docs/en/hooks
- Anthropic long-running harness article: https://www.anthropic.com/engineering/harness-design-long-running-apps
- Superpowers: https://github.com/obra/superpowers
- Matt Pocock skills: https://github.com/mattpocock/skills/tree/main/skills
- Claude Code best practices: https://github.com/shanraisshan/claude-code-best-practice
- Gstack: https://github.com/garrytan/gstack
- GSD: https://github.com/gsd-build/get-shit-done
- OpenSpec: https://github.com/Fission-AI/OpenSpec
- Local Superpowers workflows: `/code/3p/superpowers/skills/`
- Local PGE advisory references for Superpower/Gstack/GSD: `docs/proving/README.md`, `docs/design-plans/harness-system-strategy.md`

## OpenAI Lessons To Absorb

### Handoffs

OpenAI's Agents SDK treats handoffs as explicit transitions to a specific agent, with optional typed metadata and input filtering. PGE should mirror this by keeping every phase dispatch explicit:

- one destination role per dispatch
- explicit artifact inputs
- explicit output artifact path
- route metadata stored in artifacts/state, not hidden in conversation

PGE should not let agents choose arbitrary next agents. Main owns routing.

### Guardrails

OpenAI distinguishes input, output, and tool guardrails, and warns that guardrails attach to specific workflow boundaries. PGE should keep guardrails at the same boundaries:

- Planner gate: contract shape and evidence sufficiency
- Preflight gate: executable and independently evaluable contract
- Generator gate: actual deliverable plus evidence
- Evaluator gate: final independent acceptance

Guardrails should be structural and artifact-backed where possible.

### Tracing

OpenAI tracing records agent runs, tool calls, handoffs, guardrails, and custom events. PGE's equivalent is not an observability backend yet, but it needs the same shape:

- `state_artifact` for machine-readable state
- `progress_artifact` for human-readable trace
- phase artifacts as spans
- `artifact_refs` as trace links

## Anthropic Lessons To Absorb

### Subagents

Claude Code subagents have separate context windows and role-specific tool permissions. PGE should keep:

- role-specific prompts
- role-specific tool limits
- file-backed handoffs so fresh context can resume work
- no reliance on parent chat context

### Hooks

Claude Code hooks can observe lifecycle events and prevent runaway loops. PGE should not require hooks for the current runtime, but should design hook-like checkpoints:

- before tool/edit phase: preflight must pass
- after phase output: structural gate must pass
- before terminal response: Evaluator verdict and progress must be persisted

### Long-Running Harness

Anthropic's long-running harness separates Planner, Generator, and Evaluator, uses file communication, contract negotiation, and feedback loops. PGE's mapping:

- `researcher + archi -> planner`
- `coder + local reviewer -> generator`
- independent QA -> evaluator

The key adoption is not "more agents"; it is skeptical independent evaluation plus bounded redispatch.

### Alignment Assessment

Against the article's coding harness, PGE currently looks like this:

Surface-aligned now:

- three-agent split: planner / generator / evaluator
- file-backed communication and artifact handoff
- independent evaluator instead of generator self-grading
- preflight seam exists before implementation
- bounded round framing instead of open-ended build scope
- artifact-backed state model instead of chat history

But these are mostly architecture-shape matches, not proof that the runtime already behaves like the article's harness.

Intentionally narrower than the article:

- Planner shapes one bounded executable round, not a full ambitious product spec
- current runtime still executes one implementation round instead of a multi-sprint build
- PGE treats artifact-based recovery and team recreation as the durable model, even though the article's later harness could stay in one continuous session

Still missing relative to the article:

- fresh runnable smoke proof for the current thin-skill architecture
- bounded evaluator-to-generator retry loop proven in runtime
- bounded return-to-planner loop proven in runtime
- evaluator calibration fixtures / thresholds comparable to the article's grading calibration
- richer product-depth and UX-style grading criteria beyond the current contract/evidence gate

This means PGE is currently much closer to a harness sketch than to the article's demonstrated long-running system. It is aligned on some ownership seams and artifact shapes, but still far from equivalent runtime capability.

### Second-Pass Article Check

Reading the article closely, the important comparison points are not just the role names. They are the decisions each role owns and the runtime depth the harness can actually sustain.

- Planner ambition:
  - Article: Planner expands a 1-4 sentence prompt into a full product spec and high-level technical design.
  - PGE now: Planner may shape a raw prompt into one bounded round contract, but it intentionally does not claim full product-spec ownership.
  - Assessment: partial alignment by design; closer to "round shaper" than to the article's full product planner.

- Generator cadence:
  - Article: Generator executes in sprints, one feature at a time, across a multi-sprint build.
  - PGE now: Generator executes one accepted bounded round only.
  - Assessment: architecture is compatible, current executable depth is not aligned yet.

- Contract negotiation:
  - Article: Generator and Evaluator iterate on a sprint contract until they agree on what done means before code is written.
  - PGE now: bounded preflight negotiation is specified, including Generator-owned proposal repair and Planner return when the contract itself is weak, but runnable proof is still missing.
  - Assessment: semantically aligned, operationally still partial.

- Evaluator standard:
  - Article: Evaluator inspects the real application, grades against bugs plus product depth, functionality, visual design, and code quality, and uses hard thresholds.
  - PGE now: Evaluator is independent and must inspect the actual deliverable, but the richer graded criteria, hard thresholds, and calibration fixtures are still absent.
  - Assessment: aligned on independence and real-artifact checking, not yet aligned on grading depth.

- Session model:
  - Article: the later harness ran as one continuous session with compaction, while the earlier harness relied on context resets plus handoff artifacts.
  - PGE now: durable truth is artifact-backed state and recovery; if the team is lost, recovery recreates the same-role team from artifacts.
  - Assessment: intentionally diverges from the later continuous-session model and stays closer to artifact-first recovery semantics.

- Long-running claim:
  - Article: the harness is explicitly a long-running, multi-hour, multi-sprint build system.
  - PGE now: the skill must truthfully claim only a single implementation round plus non-executable canonical redispatch routes.
  - Assessment: not yet aligned on runtime depth, and the docs should keep saying so.

The practical conclusion is narrow: PGE borrows the article's structure, but still needs runtime-proven negotiation loops, richer evaluator criteria, and real multi-round execution before it can claim meaningful alignment with Anthropic-level long-running behavior.

### Critical Alignment Gates

For ongoing review, treat these five checks as the non-negotiable comparison surface against the article:

1. whether Planner can or should own raw-prompt-to-spec expansion
2. whether preflight is truly multi-turn and runtime-proven
3. whether Generator executes at sprint/feature granularity instead of one isolated round
4. whether Evaluator uses a compact, independent acceptance surface instead of only narrative critique
5. whether runtime actually supports long-running execution and recovery rather than only documenting it

If one of these is still missing, the docs should say "partially aligned" or "not yet aligned" rather than implying parity with the article.

## Skill System Lessons To Absorb

Skill systems from OpenAI/Anthropic-style skills and Matt Pocock's skill catalog converge on the same shape:

- small trigger-facing entrypoint
- one job per skill or command surface
- details in referenced folders
- examples and scripts loaded only when needed
- high-signal gotchas instead of restating general coding behavior

PGE adaptation:

- `SKILL.md` remains orchestration and navigation only.
- Phase rules live in `handoffs/`.
- Durable state/recovery rules live in `runtime/`.
- Role semantics and framework lessons live in `docs/design/pge-execute/`.
- Do not add broad tutorials, release notes, or copied external workflow prose to the skill folder.

## Orchestration Workflow Skill Writing

Claude best-practice's orchestration workflow demonstrates a command/agent/skill composition pattern. PGE should express the same structure in its own vocabulary:

- `pge-execute` is the orchestrator skill.
- The orchestrator owns run sequencing, artifact paths, progress, and teardown.
- The resident agents own role work.
- `runtime/`, `handoffs/`, and `contracts/` are skill resources that the orchestrator loads at the needed phase.
- Agent outputs return to the orchestrator as files; the orchestrator routes from artifacts, not hidden memory.

This is why the PGE skill must not stay flat. New behavior should be placed in the lowest owning layer described by `docs/design/pge-execute/layered-skill-model.md`.

## Superpowers Lessons To Absorb

From Superpowers and local Superpowers:

- execute written plans task-by-task
- use fresh context per implementation slice when possible
- review spec compliance before code quality
- never ignore a BLOCK; change context, model, plan, or scope
- keep plans bite-sized and verifiable
- use TDD or at least failing/negative fixtures for behavior changes

PGE adaptation:

- Preflight is the spec-compliance review before implementation.
- Evaluator final pass is code/behavior quality gate.
- Future retry loops must not re-dispatch the same prompt unchanged after a blocker.

## Gstack Lessons To Absorb

Gstack is useful as a catalog of operator-facing review surfaces: CEO/plan review, engineering review, design review, QA, shipping, canary, benchmark, security, and retro. The lesson for PGE is not to copy every command, but to make each review surface explicit and routeable.

PGE adaptation:

- make phase ordering obvious
- keep operator-visible state in `progress_artifact`
- make route decisions explicit and actionable
- avoid hidden magic in main
- keep review surfaces named by purpose rather than by vague "agent opinion"

## GSD Lessons To Absorb

GSD emphasizes context engineering, state across sessions, atomic plans, verification steps, and a thin orchestrator that spawns specialized agents while keeping the main context light.

PGE adaptation:

- one active bounded phase at a time
- hard caps for attempts and rounds
- explicit exit criteria per phase
- no scope expansion inside retry loops
- store project/run truth in artifacts, not conversation
- use fresh role context on resume or redispatch when possible

## Claude Best-Practice Lessons To Absorb

The Claude best-practice catalog reinforces a few constraints that PGE already needs:

- split large instructions into subfolders instead of one growing prompt
- use subagents for isolated context and independent review
- use checked-in commands/skills for repeated inner loops
- make setup, build, and test commands discoverable enough that a fresh agent can run them
- keep partial migrations and mixed patterns out of the codebase when possible

PGE adaptation:

- progress and state artifacts must let a fresh three-role team resume without old chat context.
- Planner must expose allowed paths and verification commands when it can discover them.
- Generator may read directly relevant code/config/tests/docs to follow existing patterns, but not broaden product scope.
- Evaluator should verify real artifacts with fresh context.

## OpenSpec Lessons To Absorb

OpenSpec's artifact-guided flow uses a proposal, specs/scenarios, design, tasks, implementation, and archive. PGE should keep that artifact discipline while staying smaller:

- Planner owns a bounded round contract, not a full waterfall spec.
- Preflight checks whether the round has enough proposal/spec/design/task shape to execute fairly.
- Generator implements only the accepted round.
- Evaluator gates against the frozen round contract and actual artifacts.
- Summary/archive artifacts should preserve what changed and why before teardown.

## PGE Design Rules

1. Keep `SKILL.md` as a compact entrypoint.
2. Put phase details under `handoffs/`.
3. Put state and recovery rules under `runtime/`.
4. Put framework lessons and role semantics under `design/`.
5. Every route must be supported by state, progress, and artifact references before it is advertised as executable.
6. A BLOCK changes something: contract, context, attempt, route, or scope. It must not trigger blind repetition.
