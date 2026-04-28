# Orchestration Workflow Skill Model

## System Overview

`pge-execute` is an orchestration workflow skill.

It should be authored like a compact command/skill that coordinates resident agents and skill resources, not like one flat instruction file.

The model:

- **Orchestrator skill**: `SKILL.md` owns invocation, sequencing, artifact paths, progress, routing, and teardown.
- **Resident agents**: Planner, Generator, and Evaluator stay alive for one run and do role-specific work.
- **Skill resources**: `runtime/`, `handoffs/`, and `skills/pge-execute/contracts/` provide reusable procedures, schemas, and gates loaded only when needed.
- **Artifacts**: phase outputs and state files carry the durable truth.

## Component Summary

| Component | Role | PGE Surface |
| --- | --- | --- |
| Orchestrator skill | Entry point and run coordinator | `skills/pge-execute/SKILL.md` |
| Runtime resources | State, artifact paths, lifecycle, recovery | `ORCHESTRATION.md`, `runtime/*.md` |
| Planner agent | Evidence-backed bounded round shaping | `agents/pge-planner.md` |
| Generator agent | Execute accepted round and self-review | `agents/pge-generator.md` |
| Evaluator agent | Independent final gate and route proposal | `agents/pge-evaluator.md` |
| Phase resources | Dispatch text, artifact schema, gates | `handoffs/*.md` |
| Contract resources | Shared vocabulary and invariants | `skills/pge-execute/contracts/*.md` |
| Validation/progress | Drift checks and development state | `bin/pge-validate-contracts.sh`, `progress.md` |

## Source Pattern Matrix

| Source | Skill-writing pattern | PGE adoption |
| --- | --- | --- |
| Superpowers `brainstorming` | Hard gate before implementation, context exploration, one-question-at-a-time clarification, alternatives, design/spec self-review, explicit transition to planning | Planner owns context-backed bounded round shaping; preflight acts as spec self-review; Generator edits are forbidden until preflight passes |
| Superpowers `executing-plans` | Load plan, critically review it, execute bite-sized tasks in order, update task state, run specified verification, stop on blocker or repeated failure | Generator executes only the accepted round; progress artifact records phase movement; verification is required; non-PASS routes stop or redispatch only when implemented |
| Claude orchestration workflow | Command/skill coordinates agent-with-skill and independent skill resources; component table; flow diagram; execution flow; concrete file outputs; single responsibility per component | `SKILL.md` is the orchestrator; resident agents do role work; `runtime/`, `handoffs/`, and `skills/pge-execute/contracts/` are skill resources; outputs are file artifacts |

Non-adoptions:

- Do not require user approval between every Planner section in `pge-execute`; the skill must run autonomously on clear tasks.
- Do not require git commits as part of Planner or Generator output.
- Do not copy Superpowers worktree requirements into PGE unless the runtime actually creates isolated workspaces.
- Do not treat phase resources as separate user-invoked skills; they are orchestrator-loaded resources.

## Flow Diagram

```text
╔══════════════════════════════════════════════════════════════════╗
║                  PGE ORCHESTRATION WORKFLOW                     ║
║        Orchestrator Skill -> Resident Agents -> Resources        ║
╚══════════════════════════════════════════════════════════════════╝

                         ┌───────────────────┐
                         │ User Invocation   │
                         │ /pge-execute ...  │
                         └─────────┬─────────┘
                                   │
                                   ▼
         ┌─────────────────────────────────────────────────────┐
         │ pge-execute — Orchestrator Skill                    │
         │ reads runtime resources, initializes artifacts       │
         └─────────────────────────┬───────────────────────────┘
                                   │
                         TeamCreate + Agent bindings
                                   │
                                   ▼
         ┌─────────────────────────────────────────────────────┐
         │ Resident Team                                       │
         │ planner -> pge-planner                              │
         │ generator -> pge-generator                          │
         │ evaluator -> pge-evaluator                          │
         └──────────────┬─────────────────┬────────────────────┘
                        │                 │
                        ▼                 ▼
         ┌──────────────────────┐  ┌───────────────────────────┐
         │ Planner phase         │  │ Preflight phase            │
         │ handoffs/planner.md   │  │ handoffs/preflight.md      │
         │ -> planner artifact   │  │ -> proposal + preflight    │
         └───────────┬──────────┘  └────────────┬──────────────┘
                     │                          │
                     └──────────────┬───────────┘
                                    ▼
         ┌─────────────────────────────────────────────────────┐
         │ Generator phase                                     │
         │ handoffs/generator.md -> deliverable + evidence      │
         └─────────────────────────┬───────────────────────────┘
                                   │
                                   ▼
         ┌─────────────────────────────────────────────────────┐
         │ Evaluator phase                                     │
         │ handoffs/evaluator.md -> verdict + next_route        │
         └─────────────────────────┬───────────────────────────┘
                                   │
                                   ▼
         ┌─────────────────────────────────────────────────────┐
         │ Route / Summary / Teardown                          │
         │ route-summary-teardown.md -> state + summary         │
         └─────────────────────────────────────────────────────┘
```

## Component Details

### 1. Orchestrator Skill

Location: `skills/pge-execute/SKILL.md`

Purpose:

- parse `ARGUMENTS`
- initialize `input_artifact`, `state_artifact`, and `progress_artifact`
- create one per-run resident team
- load phase resources progressively
- dispatch work through the team
- gate artifacts before advancing
- route, summarize, and tear down

Non-responsibilities:

- role reasoning
- implementation
- final acceptance
- hidden redispatch

### 2. Resident Agents

Locations:

- `agents/pge-planner.md`
- `agents/pge-generator.md`
- `agents/pge-evaluator.md`

Team binding:

- teammate `planner` uses agent surface `pge-planner`
- teammate `generator` uses agent surface `pge-generator`
- teammate `evaluator` uses agent surface `pge-evaluator`

Purpose:

- Planner maps raw prompt or upstream context to one bounded round contract.
- Generator implements only the accepted round, verifies locally, and self-reviews.
- Evaluator reads the actual deliverable independently and emits verdict plus `next_route`.

Lifetime:

- created once per `pge-execute` run
- stay resident through planner, preflight, generator, evaluator, and teardown phases
- not reused across separate skill invocations
- not the durable source of truth

### 3. Phase Skill Resources

Locations:

- `handoffs/planner.md`
- `handoffs/preflight.md`
- `handoffs/generator.md`
- `handoffs/evaluator.md`
- `handoffs/route-summary-teardown.md`

Purpose:

- provide phase-specific dispatch text
- define exact top-level artifact sections
- define gates
- keep phase details out of `SKILL.md`

These resources are invoked by the orchestrator. They are not independent user-facing skills.

### 4. Contract And Runtime Resources

Locations:

- `skills/pge-execute/contracts/*.md`
- `runtime/artifacts-and-state.md`
- `runtime/persistent-runner.md`
- `ORCHESTRATION.md`

Purpose:

- define shared route/state/round/evaluation vocabulary
- define artifact paths and durable state
- define what is executable now versus future design
- keep recovery independent of chat history

## Execution Flow

1. **User Invocation**: user invokes `/pge-execute test` or `/pge-execute <task prompt>`.
2. **Runtime Initialization**: orchestrator creates artifact paths, initial state, and progress.
3. **Team Creation**: orchestrator creates one resident team with planner, generator, and evaluator.
4. **Planner Dispatch**: orchestrator loads `handoffs/planner.md`, sends input artifact, waits for planner artifact, and gates it.
5. **Preflight Proposal**: orchestrator loads `handoffs/preflight.md`, asks Generator for an execution proposal with no repo edits.
6. **Preflight Review**: Evaluator reviews the Planner contract plus Generator proposal. Only `PASS + ready_to_generate` permits implementation.
7. **Generation**: Generator performs the real deliverable, local verification, and self-review.
8. **Evaluation**: Evaluator independently reads the actual deliverable and emits verdict plus `next_route`.
9. **Routing**: orchestrator routes from artifacts. `PASS + converged` succeeds; other canonical routes stop at `unsupported_route` until redispatch is implemented.
10. **Teardown**: orchestrator writes summary/progress and deletes the team.

## Example Execution

```text
Input: /pge-execute test
├─ Step 1: Orchestrator initializes .pge-artifacts/<run_id>-*
├─ Step 2: TeamCreate
│  ├─ teammate planner -> pge-planner
│  ├─ teammate generator -> pge-generator
│  └─ teammate evaluator -> pge-evaluator
├─ Step 3: Planner -> bounded smoke contract
├─ Step 4: Generator preflight -> contract proposal, no repo edits
├─ Step 5: Evaluator preflight -> PASS + ready_to_generate
├─ Step 6: Generator -> writes .pge-artifacts/pge-smoke.txt
├─ Step 7: Evaluator -> independently reads pge-smoke.txt
└─ Output:
   ├─ verdict: PASS
   ├─ route: converged
   ├─ summary artifact
   ├─ state artifact
   └─ progress artifact
```

## Skill Writing Lessons To Apply

From Superpowers `brainstorming`:

- inspect context before freezing design
- record only the ambiguity that matters for the current bounded round
- compare alternatives when the design path is not obvious
- self-review the contract for placeholders, contradictions, ambiguous requirements, and oversized scope
- transition from design/spec to execution plan only after the contract is clear enough

PGE mapping:

- Planner owns context-backed round shaping.
- Planner output must include evidence, constraints, scope, acceptance, verification, and escalation fields.
- Preflight is the automated version of spec self-review before implementation.

From Superpowers `executing-plans`:

- load and critically review the plan before executing
- execute bite-sized tasks in order
- mark progress as each task moves
- run the specified verification
- stop or route when blocked; do not guess through unclear instructions or repeated verification failure

PGE mapping:

- Generator may not edit before preflight passes.
- Generator implements the accepted round exactly, verifies locally, and records evidence.
- BLOCK changes context, route, scope, or attempt; it does not trigger blind repetition.

From Claude orchestration workflow:

- the top-level command/skill orchestrates
- agents own specialized work
- reusable skill resources carry procedure
- outputs are concrete files
- each component has one responsibility

PGE mapping:

- `SKILL.md` is orchestration, not role logic.
- `agents/*.md` are role surfaces.
- `handoffs/*.md`, `runtime/*.md`, and `skills/pge-execute/contracts/*.md` are progressively loaded skill resources.

## Key Design Principles

1. **Orchestrator as coordinator**: `pge-execute` sequences phases, gates artifacts, and records state.
2. **Resident agents for role work**: planner/generator/evaluator stay alive for one run but do not persist across runs.
3. **Skill resources for procedure**: phase and contract details live below `SKILL.md`.
4. **Clean separation**: plan -> preflight -> generate -> evaluate -> route.
5. **Artifact-backed truth**: state, progress, and phase artifacts are durable; chat history is not.
6. **Honest capability boundary**: retry, continue, and return-to-planner are future loops until implemented and validated.

## Architecture Patterns

### Agent With Resource Pack

PGE agents do not receive one huge prompt. The orchestrator supplies the relevant resource pack for the current phase:

```text
planner agent + handoffs/planner.md + skills/pge-execute/contracts/round-contract.md
generator agent + handoffs/preflight.md or handoffs/generator.md
evaluator agent + handoffs/preflight.md or handoffs/evaluator.md
```

### Direct Skill Resource Invocation

The orchestrator directly reads skill resources before dispatch:

```text
runtime/artifacts-and-state.md
handoffs/<phase>.md
skills/pge-execute/contracts/*.md
```

These files behave like local skill modules. They are loaded only when their phase needs them.

Design references such as this document live under `docs/design/pge-execute/`. They guide skill maintenance, but they are not loaded during every normal run.

## Design Rule

When adding PGE behavior, add it to the lowest layer that owns it:

- entry/lifecycle change -> `SKILL.md`, `ORCHESTRATION.md`, or `runtime/`
- role behavior -> `agents/`
- phase schema/gate -> `handoffs/`
- shared vocabulary -> `skills/pge-execute/contracts/`
- drift checks/progress -> `bin/`, `progress.md`, or plan docs

Do not flatten new behavior into `SKILL.md` unless it changes top-level invocation, lifecycle, or the visible execution flow.
