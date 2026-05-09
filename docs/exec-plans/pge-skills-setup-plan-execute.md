# PGE Skills Setup / Plan / Execute Refactor Plan

## Purpose

Plan the PGE skill refactor before implementation.

This plan is intentionally limited to planning. It does not modify skill files, agent files, contracts, plugin metadata, or validation scripts.

## Inspection Basis

Files inspected before writing this plan:

- `README.md`
- `CLAUDE.md`
- `AGENTS.md`
- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `skills/pge-execute/contracts/*.md`
- `skills/pge-execute/handoffs/*.md`
- `skills/pge-execute/runtime/*.md`
- `agents/pge-planner.md`
- `agents/pge-generator.md`
- `agents/pge-evaluator.md`
- `docs/design/`
- `docs/design/pge-execute/`
- `docs/design/research/`
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ISSUES_LEDGER.md`
- `docs/exec-plans/ROUND_TEMPLATE.md`
- `.claude-plugin/plugin.json`
- `bin/pge-validate-contracts.sh`

## Observed Current State

Confirmed from current repo files:

- There is currently one runnable skill surface: `skills/pge-execute/SKILL.md`.
- `skills/pge-execute/SKILL.md` currently declares `TeamCreate`, `TeamDelete`, `Agent`, and `SendMessage` as allowed tools.
- Current runtime docs describe one Claude Code Agent Team with exactly three teammates: `planner`, `generator`, and `evaluator`.
- Current `agents/pge-*.md` files are runtime-facing role definitions for Planner / Generator / Evaluator.
- Current docs repeatedly state that `main` owns route, state, gates, progress, repair routing, and teardown.
- Current `pge-execute` is already not a TDD skill: TDD appears only as external-reference material, not as the active runtime authority.
- `skills/pge-execute/runtime/persistent-runner.md` describes a future recovery model and includes a future long-running state machine, but it is explicitly archived / future-design material for the current executable lane.
- `.claude-plugin/plugin.json` currently exposes only `./skills/` plus the three `agents/pge-*.md` agent files.

Inference from the user's requested direction:

- The next refactor should split the current single-skill surface into three skill slices: `pge-setup`, `pge-plan`, and `pge-execute`.
- The target architecture should remove the Claude Code Agent Teams orchestration claim from the executable skill path.
- `.claude/agents/pge-*` should no longer be treated as live runtime teammate bindings; they should be treated as role spec / prompt material / future SDK runner material.
- `pge-execute` should align to a triage/state-machine execution model, where TDD is one execution mode among others.

## Global Refactor Rules

- Do not implement an SDK runner in this refactor.
- Do not use `TeamCreate`.
- Do not use Claude Code Agent Teams as the active orchestration mechanism.
- Do not preserve "exactly three resident teammates" as executable semantics.
- Do not preserve "three agent orchestrator" semantics where Planner / Generator / Evaluator are live teammates managed by `main`.
- Do not turn `pge-execute` into a TDD skill.
- Treat TDD as one possible execution mode selected by triage/state-machine policy.
- Treat `.claude/agents/pge-*` and source `agents/pge-*.md` as role specs, prompt material, and possible future SDK runner material only.
- Keep `main` as the local control-plane owner for state, route, gates, and user-facing decisions.
- Keep changes minimal and route-facing. Do not add unrelated new workflow theory.

## Slice 1: `pge-setup`

### Modified Files

Planned file changes:

- Add `skills/pge-setup/SKILL.md`
- Add `skills/pge-setup/contracts/setup-contract.md`
- Add `skills/pge-setup/runtime/setup-artifacts.md`
- Update `.claude-plugin/plugin.json` only if the plugin manifest does not automatically expose all skill directories under `./skills/`
- Update `README.md` only to list the new skill and its purpose
- Update `CLAUDE.md` only if resident first-read guidance must point to the new setup surface
- Update `bin/pge-validate-contracts.sh` to validate the new setup skill surface and anti-Agent-Teams invariants

Files not to modify in this slice:

- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `agents/pge-*.md`

### Goal

Create a setup skill that prepares and verifies the repo-local PGE environment without running planning or execution.

`pge-setup` should own:

- plugin/source layout checks
- required file presence checks
- installed-surface sanity checks when applicable
- contract validation entrypoint guidance
- artifact directory expectations
- clear reporting of missing setup prerequisites

### Not Doing

- No execution of user tasks.
- No planning of user tasks.
- No SDK runner.
- No TeamCreate or Agent Teams lifecycle.
- No mutation of skill/agent semantics beyond setup documentation.
- No automatic repair of installation unless explicitly requested by a future setup contract.

### Acceptance Criteria

- `skills/pge-setup/SKILL.md` exists and has a narrow setup-only scope.
- `pge-setup` never claims to run Planner / Generator / Evaluator as teammates.
- `pge-setup` does not list `TeamCreate`, `TeamDelete`, `Agent`, or `SendMessage` unless a later plan explicitly reintroduces them for a non-executable diagnostic reason.
- Setup output distinguishes `PASS`, `WARN`, and `BLOCKED`.
- Static validation confirms setup files exist and old Agent Teams orchestration language is not introduced into the setup skill.
- README describes `pge-setup` as preparation/validation, not planning/execution.

### Risks

- Setup could grow into a hidden preflight gate for every execution.
- Setup could accidentally mutate user files while checking environment.
- Setup could overfit to local installation paths and become brittle.

### Verification Against Old Agent Teams Error

Verify:

- `rg -n "TeamCreate|TeamDelete|exactly three teammates|Agent Team|resident team" skills/pge-setup README.md CLAUDE.md`
- `./bin/pge-validate-contracts.sh`
- `git diff --check`

Expected result:

- No executable setup instruction uses TeamCreate or a three-teammate runtime.
- Any historical mention, if retained in README/CLAUDE for migration context, is clearly marked as historical or non-authoritative.

## Slice 2: `pge-plan`

### Modified Files

Planned file changes:

- Add `skills/pge-plan/SKILL.md`
- Add `skills/pge-plan/contracts/plan-contract.md`
- Add `skills/pge-plan/runtime/plan-artifacts.md`
- Optionally add `skills/pge-plan/handoffs/role-spec-usage.md` to define how `agents/pge-*.md` may be read as prompt material
- Update `README.md` to list `pge-plan` as the planning surface
- Update `CLAUDE.md` first-read guidance only after `pge-plan` becomes real runtime truth
- Update `bin/pge-validate-contracts.sh` for plan-skill required sections and forbidden runtime-team claims

Files not to modify in this slice:

- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `agents/pge-*.md`, except for a later cleanup slice if the plan explicitly authorizes role-spec wording changes

### Goal

Create a planning skill that turns user input or repo intent into a bounded, evidence-backed execution plan artifact.

`pge-plan` should own:

- task intake
- ambiguity classification
- repo inspection guidance
- bounded slice selection
- acceptance criteria
- verification path
- execution mode recommendations, including TDD when appropriate
- explicit triage hints for `pge-execute`

The output should be an execution-ready plan artifact, not a live instruction to spawn Planner / Generator / Evaluator.

### Not Doing

- No implementation.
- No execution loop.
- No SDK runner.
- No TeamCreate.
- No live Planner / Generator / Evaluator teammate creation.
- No `.claude/agents/pge-*` runtime binding.
- No mandatory TDD. TDD may be recommended only when the task shape benefits from red/green/refactor.

### Acceptance Criteria

- `skills/pge-plan/SKILL.md` exists and defines a standalone planning workflow.
- The plan contract includes at minimum:
  - goal
  - evidence basis
  - in scope
  - out of scope
  - deliverable
  - acceptance criteria
  - verification path
  - recommended execution mode
  - state-machine starting state or route hint for `pge-execute`
  - risks and blockers
- Planning output is durable and can be consumed by `pge-execute`.
- The skill may read `agents/pge-*.md` only as role-spec / prompt material, not as live agent definitions.
- The skill explicitly says TDD is optional execution mode guidance, not the identity of PGE execution.

### Risks

- `pge-plan` could duplicate all old Planner prompt semantics without simplifying the architecture.
- The output contract could become too large for simple tasks.
- The skill could accidentally preserve the old "Planner freezes, Generator implements, Evaluator validates as teammates" runtime story.

### Verification Against Old Agent Teams Error

Verify:

- `rg -n "TeamCreate|TeamDelete|Spawn exactly three|exactly three teammates|resident teammate|Agent Teams runtime|SendMessage" skills/pge-plan`
- `rg -n "TDD|test-driven|red-green" skills/pge-plan`
- `./bin/pge-validate-contracts.sh`
- `git diff --check`

Expected result:

- No plan-skill instruction creates or assumes Agent Teams.
- Any TDD mention is framed as one possible `execution_mode`, never as the required runtime.
- Any use of `agents/pge-*.md` is explicitly role-spec/prompt-material consumption.

## Slice 3: `pge-execute`

### Modified Files

Planned file changes:

- Rewrite `skills/pge-execute/SKILL.md` around triage/state-machine execution.
- Rewrite or replace `skills/pge-execute/ORCHESTRATION.md` to remove Agent Teams lifecycle and define the active state machine.
- Update `skills/pge-execute/contracts/entry-contract.md` for input from raw prompt or `pge-plan` artifact.
- Update `skills/pge-execute/contracts/runtime-event-contract.md` to remove teammate-to-main SendMessage events as required progression signals.
- Update `skills/pge-execute/contracts/runtime-state-contract.md` to become active state-machine truth instead of archived/future material, if this slice chooses a durable state file.
- Update `skills/pge-execute/contracts/routing-contract.md` to align route decisions with the state machine.
- Update `skills/pge-execute/contracts/evaluation-contract.md` to describe evaluator logic as an execution/evaluation step, not a resident teammate.
- Update `skills/pge-execute/runtime/artifacts-and-state.md` for state, progress, plan, evidence, and result artifacts.
- Archive or rewrite `skills/pge-execute/handoffs/*.md` that currently assume Planner / Generator / Evaluator teammate dispatch.
- Keep `skills/pge-execute/runtime/persistent-runner.md` as future SDK-runner material unless this slice explicitly replaces it with a non-SDK state machine.
- Update `README.md`, `CLAUDE.md`, and `AGENTS.md` after runtime truth changes.
- Update `.claude-plugin/plugin.json` only if agent registration must be removed to prevent runtime confusion.
- Update `bin/pge-validate-contracts.sh` to enforce new anti-TeamCreate and state-machine invariants.

### Goal

Refactor `pge-execute` into the executable triage/state-machine skill.

`pge-execute` should own:

- resolving raw prompt or `pge-plan` artifact input
- triaging task complexity and risk
- selecting an execution mode
- executing the task directly within the current Codex/Claude session
- using TDD only when selected as the right execution mode
- writing durable state/progress/evidence artifacts
- running verification proportional to risk
- routing to terminal result, retry, blocked, or needs-plan states

The active model should be:

```text
intake
  -> triage
  -> plan_required | ready_to_execute | blocked
  -> execute
  -> verify
  -> evaluate
  -> route
  -> done | retry | blocked | needs_plan
```

### Not Doing

- No SDK runner.
- No TeamCreate.
- No Agent Teams runtime lifecycle.
- No SendMessage teammate progression requirements.
- No live Planner / Generator / Evaluator resident teammates.
- No three-agent orchestrator semantics.
- No automatic multi-round autonomous system beyond explicitly bounded state-machine transitions.
- No treating TDD as mandatory.
- No hidden fallback to old `planner -> generator -> evaluator` teammate dispatch.

### Acceptance Criteria

- `skills/pge-execute/SKILL.md` does not allow or instruct `TeamCreate`, `TeamDelete`, `Agent`, or `SendMessage` for PGE orchestration.
- `skills/pge-execute/SKILL.md` describes triage/state-machine execution as the active runtime.
- `skills/pge-execute/ORCHESTRATION.md` contains the active state machine and no required Agent Teams lifecycle.
- `runtime-state-contract.md` and `routing-contract.md` agree on states and routes.
- TDD appears only as one possible execution mode, with conditions for when to choose it.
- Old handoff files are either archived with clear "not active" wording or rewritten as state-machine step references.
- Final output reports task status, route, changed files, verification, evidence, and blockers.
- Static validation fails if TeamCreate or exactly-three-teammate claims reappear in executable skill surfaces.

### Risks

- Removing Agent Teams semantics could leave the current docs internally inconsistent if README/CLAUDE/AGENTS are not updated in the same slice.
- Rewriting `pge-execute` could accidentally make `pge-plan` redundant or bypass plan artifacts.
- A state-machine skill can become too abstract unless each state has concrete entry, exit, artifact, and verification rules.
- Without an SDK runner, state transitions remain prompt-driven; the docs must be honest about that.

### Verification Against Old Agent Teams Error

Verify:

- `rg -n "TeamCreate|TeamDelete|Spawn exactly three|exactly three teammates|one Team|Agent Teams runtime|resident team|SendMessage coordination|teammate" skills/pge-execute README.md CLAUDE.md AGENTS.md`
- `rg -n "TDD|test-driven|red-green|execution_mode" skills/pge-execute`
- `./bin/pge-validate-contracts.sh`
- `git diff --check`
- Run the smallest documented `pge-execute` smoke path after implementation, but only after the skill rewrite exists.

Expected result:

- No active executable doc requires Claude Code Agent Teams.
- No active executable doc says P/G/E are live resident teammates.
- TDD wording is mode-scoped.
- State-machine routes are explicit and do not imply an SDK runner.

## Cross-Slice Migration Order

1. Add `pge-setup` first because it is lowest risk and gives validation a place to live.
2. Add `pge-plan` second because execution should consume a plan artifact without relying on live Planner teammate semantics.
3. Rewrite `pge-execute` last because it touches the current runtime truth and must update docs/validator in one coherent slice.

## Cross-Slice Validation Checklist

Run after each implementation slice:

- `git status --short`
- `git diff --check`
- `./bin/pge-validate-contracts.sh`
- `rg -n "TeamCreate|TeamDelete|Spawn exactly three|exactly three teammates|Agent Teams runtime|resident teammate|three agent orchestrator|three-agent orchestrator" skills README.md CLAUDE.md AGENTS.md`
- `rg -n "SDK runner|OpenAI Agents SDK|Claude Agent SDK" skills README.md CLAUDE.md AGENTS.md`
- `rg -n "TDD|test-driven|red-green" skills README.md CLAUDE.md AGENTS.md`

Interpretation:

- Old Agent Teams terms should be absent from active executable skill surfaces.
- If old terms remain in historical docs, they must be outside runtime truth or explicitly marked historical.
- SDK mentions must be future-material only, not implementation claims.
- TDD mentions must be execution-mode scoped.

## Final Done Criteria

The refactor is complete when:

- Three skill directories exist: `skills/pge-setup`, `skills/pge-plan`, and `skills/pge-execute`.
- README and resident instructions describe the new three-skill flow.
- `pge-execute` is aligned to triage/state-machine semantics.
- No active skill requires TeamCreate or Agent Teams.
- `.claude/agents/pge-*` are documented only as role specs / prompt material / future SDK runner material, or removed from plugin runtime registration if that is the safer implementation choice.
- TDD is documented only as one execution mode.
- Validation scripts enforce the above invariants.
