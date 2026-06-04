# CLAUDE.md

## Resident Rules

This file is the resident agent entry point for work inside this repo. It is not a README, product pitch, or design document.

Use it to decide:

- what is authoritative
- which PGE surface owns the current work
- where artifacts must be written
- when to stop, ask, replan, review, or execute
- how to keep workflow contract changes coherent

## First Reads

For non-trivial work, read only what the task needs. Default order:

1. `README.md` for project map only
2. the active skill being modified or invoked
3. adjacent producer / consumer / validator files for that contract

Do not bulk-read all skills by default.

## Truth Hierarchy

Active skill files are authoritative for runtime behavior:

- `skills/pge-research/SKILL.md`
- `skills/pge-plan/SKILL.md`
- `skills/pge-exec/SKILL.md`
- `skills/pge-review/SKILL.md`
- `skills/pge-challenge/SKILL.md`
- `skills/pge-ai-native-refactor/SKILL.md`
- `skills/pge-handoff/SKILL.md`
- `skills/pge-learn/SKILL.md`

Templates define artifact semantics where referenced by a skill:

- `skills/pge-plan/templates/plan.md`
- `skills/pge-plan/templates/issue.md`
- `skills/pge-plan/templates/workflow-handoff.md`

Stable cross-surface contract authority:

- `docs/adr/0001-pge-contract-authority-and-planning.md`

`README.md` is a project map and user-facing positioning, not the final authority on runtime details.

`docs/research/*` and `docs/exec-plans/*` are source evidence or design notes. They are not active runtime contracts unless explicitly fast-adopted into `.pge/tasks-<slug>/plan.md`.

## Core Invariants

- PGE is a harness, not an agent OS.
- Preserve user intent, bounded scope, forbidden areas, and verification expectations.
- Prefer the smallest contract change that improves execution quality.
- Do not add ceremony, fields, routes, agents, or artifacts without a current contract need.
- Do not silently revive removed Planner / Generator / Evaluator agent-team architecture.
- Subagents and workers are bounded helpers, not workflow authorities.

## Stage Authority

- `pge-research` owns bounded problem discovery: goal, success shape, scope, non-goals, constraints, task-relevant context, optional problem-side experience notes, conditional Implementation Friction / Progressive Feasibility, and route.
- `pge-plan` owns executable solution design: intent confirmation, requirement boundaries, repo-reality alignment, selected/rejected approaches, issue slicing, target/forbidden areas, acceptance, verification, evidence requirements, terminal conditions, Plan Engineering Review, Final Plan Gate, and ready-plan `workflow-handoff.md` generation.
- `pge-exec` owns default execution inside a ready plan contract: scheduling, bounded repair, implementation evidence, Diagnostic Recovery, and Exec QA Gate.
- Dynamic Workflow is an optional execution backend through `.pge/tasks-<slug>/workflow-handoff.md`. It owns runtime orchestration only after explicit launch and must preserve `plan.md`.
- `workflow-result.md` is evidence backflow for the next selected review, replan, ship, or handoff step. It is not a `pge-exec` repair artifact and not a `pge-review` route.
- `pge-review` owns the `/pge-review` surface only when explicitly invoked. It returns a bounded review verdict; it does not own all workflow results by default.
- `pge-challenge` owns manual prove-it pressure before PR/ship when invoked.
- `pge-ai-native-refactor` owns pre-PGE shaping for one human-selected AI-friction direction. It must not execute implementation or invoke PGE automatically.
- `pge-handoff` owns temporary task handoff only. It must not extract durable knowledge.
- `pge-learn` owns learning and quality evaluation before durable knowledge promotion.

## Artifact Rules

Canonical PGE task artifacts live under `.pge/tasks-<slug>/`.

- `research.md`: optional problem-discovery contract
- `plan.md`: canonical executable plan after Final Plan Gate passes
- `issues/Ixxx.md`: full issue execution contracts
- `workflow-handoff.md`: optional Dynamic Workflow launch adapter for ready plans
- `runs/<run_id>/*`: `pge-exec` run artifacts
- `workflow-result.md`: Dynamic Workflow evidence backflow
- `review.md` / `challenge.md`: bounded review or prove-it feedback when invoked

Do not create a second canonical plan, derived workflow graph, task DAG, dependency JSON, task tree, subagent topology, or runtime state file from `workflow-handoff.md`.

## Execution Principle

- PGE is a do-my-best execution system under explicit goal and verification, not a prove-everything-before-execution system.
- `READY_FOR_EXECUTE` means the current contract is good enough to start, not that no clarification will ever be needed.
- Issues are the best current executable slices, not perfect closed-world objects.
- Validation is the strongest economical signal available now, not exhaustive proof.
- Exec should keep moving inside the contract and clarify only when continuing would change goal, scope, validation, boundaries, or authority.

## Missing Detail Policy

Classify missing information before asking:

- **requirement gap**: affects goal, scope, acceptance, or safety -> ask the user
- **design choice**: multiple valid options -> recommend a default and proceed
- **implementation detail**: resolve by repo convention or leave to execution freedom

Ask only for true requirement gaps that block a fair contract.

## Workflow Contract Changes

When editing skills, agents, handoffs, templates, route/state/verdict vocabulary, artifact schemas, final response formats, README/CLAUDE resident rules, or workflow docs, read `docs/adr/0001-pge-contract-authority-and-planning.md` and run its contract gap check before finalizing.

Before adding or changing any protocol action, distinguish the desired effect from the implementation mechanism:

- Desired effect: what quality, efficiency, safety, or alignment outcome should improve.
- Protocol action: who must do what differently, at which stage, using which artifact or field.
- Necessity: why existing fields, instructions, checks, or review surfaces cannot already achieve the effect.
- Consumer value: which downstream consumer, validator, or evidence consumer becomes more capable because of the change.
- Failure mode: what concrete failure this prevents or exposes earlier.

Do not encode an effect as a constraint and assume the target will happen. For example, "improve execution quality" is a goal; it is not by itself a valid new field, route, checklist, or template section. Add protocol only when the action is concrete, consumed, validated, and cheaper than leaving the behavior to existing contract surfaces.

Fix in-scope mismatches in the same change. If the mismatch requires broader redesign, stop and surface it as a blocker or follow-up.

## Workflow Tool Authorization

For PGE contract maintenance only, you may use Claude Code Workflow for audit or verification fan-out without re-asking.

Use it for multi-file producer/consumer/validator checks, adversarial contract review, or route/status consistency review.

Prefer direct edits for small bounded changes. This authorization does not apply to target-repo product work, destructive actions, or non-PGE contract work.

## Work Discipline

- Understand before changing.
- Do not present guesses as facts.
- Keep changes minimal and relevant.
- Preserve the newest user correction over older strategy text.
- Do not expand PGE into a generic autonomous agent OS.
- Do not add resident agents unless explicitly required by the current mainline.
- Every meaningful change should improve task delivery or future AI-operability.

## Validation Commands

```bash
./bin/pge-progress-report.sh <progress.jsonl-or-task-dir>
./bin/pge-local-install.sh
```

## Gotchas

- Plugin source and marketplace source are the same repo; installed layout differs from source layout.
- `agents/pge-code-reviewer.md` and `agents/pge-code-simplifier.md` are active review agents spawned by `pge-exec`.
- `docs/exec-plans/` files are design notes unless fast-adopted into `.pge/tasks-<slug>/plan.md`.
