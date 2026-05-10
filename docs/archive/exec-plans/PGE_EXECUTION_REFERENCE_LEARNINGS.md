# PGE Execution Reference Learnings

## Purpose

This document captures execution-layer learnings from four reference systems:

- Claude Code native runtime
- GSD (get-shit-done)
- gstack
- mattpocock/skills

It focuses only on execution concerns:

- role boundaries
- workflow layering
- inputs / outputs
- core dependencies
- what should become deterministic in PGE

This is not a product-strategy document.

## Why These References Matter

PGE's current pain is not "missing one more contract field."
The main pain is execution instability:

- teammate messages arrive late
- protocol actions get written in the wrong format
- `main` becomes a high-friction participant instead of a lean orchestrator
- progress/state semantics drift between prompts, artifacts, and runtime behavior

The references below are useful because they show better answers to those problems.

## Reference 1: Claude Code Native Runtime

### What it is

Claude Code native runtime provides:

- `Agent`
- `TeamCreate`
- `SendMessage`
- `TeamDelete`
- tool permission / session / hook system

### Role in the stack

Claude Code native runtime is a **substrate**, not a full deterministic execution framework.

### Inputs

- prompts
- settings
- permissions
- hooks
- tool contracts

### Outputs

- agent responses
- tool calls
- team transport
- session state

### Core dependency

PGE depends on Claude Code native runtime for transport and tool execution.

### Main lesson for PGE

Do not confuse substrate with orchestrator.

Claude Code gives:
- transport
- tool invocation
- team lifecycle primitives

It does not guarantee:
- protocol correctness
- route reduction correctness
- teardown correctness
- result/status consistency

PGE must supply those guarantees itself.

## Reference 2: GSD

Primary local references:

- `~/.claude/commands/gsd/fast.md`
- `~/.claude/commands/gsd/quick.md`
- `~/.claude/commands/gsd/execute-phase.md`
- `~/.claude/get-shit-done/workflows/fast.md`
- `~/.claude/get-shit-done/workflows/quick.md`
- `~/.claude/get-shit-done/templates/state.md`

### Workflow layering

GSD makes task tiering explicit:

1. **`gsd:fast`**
   - trivial task
   - no subagents
   - no planning overhead
   - inline execution

2. **`gsd:quick`**
   - small but non-trivial task
   - planner + executor
   - defaults to a lighter path
   - only becomes heavier when flags like `--research`, `--discuss`, or `--full` are added

3. **`gsd:execute-phase`**
   - complex multi-plan phase
   - parallel subagents / waves
   - explicit note: orchestrator stays lean

### Roles

At the execution layer, GSD implicitly separates:

- inline executor (`fast`)
- planner (`quick`)
- executor(s)
- optional verifier / checker
- orchestrator for phase execution

### Inputs

- task description
- project planning files
- workflow flags
- context files resolved by workflow

### Outputs

- code changes
- plan artifacts
- verification results
- state updates
- commits

### Core dependency

GSD depends on **task stratification**.

It does not try to run every task through one universal heavy workflow.

### Main lessons for PGE

1. Light tasks need light paths.
2. Heavy orchestration must be earned by task complexity.
3. Orchestrator should remain lean.
4. State/continuity files are useful as project memory, not as every-step runtime gate.

## Reference 3: gstack

Primary local references:

- `~/.claude/skills/gstack/CLAUDE.md`
- `~/.claude/skills/gstack/docs/skills.md`

### What gstack emphasizes

gstack is more toolchain-oriented than runtime-state oriented.

It emphasizes:

- evaluation and observability
- generated / validated workflow docs
- project-specific config discovery
- explicit workflow specialization
- keeping orchestration logic thin

### Roles

gstack does not push one universal P/G/E runtime.
Instead, it offers many specialized workflows:

- review
- investigate
- QA
- ship
- plan reviews
- design review

### Inputs

- repo context
- skill templates
- project config in `CLAUDE.md`
- eval/test infrastructure

### Outputs

- workflow-specific results
- tests/evals
- generated docs
- diagnostics

### Core dependency

The key dependency is **specialized workflow selection**, not a universal runtime state machine.

### Main lessons for PGE

1. Different tasks deserve different workflow thickness.
2. Generated and validated docs reduce drift.
3. Observability and evals are first-class.
4. Project config should be explicit and repo-local when possible.

## Reference 4: mattpocock/skills

Primary public reference:

- https://github.com/mattpocock/skills

Key README point:
- skills should be small, composable, and adaptable
- process-heavy systems can take away control and make process bugs harder to fix

### What it emphasizes

This reference is less about runtime orchestration and more about:

- skill composability
- lightweight process
- fixing common agent failure modes directly
- reducing control-plane overreach

### Main lessons for PGE

1. Small composable skills are easier to adapt than one giant process shell.
2. Process bugs are real bugs.
3. Heavy process can become harder to debug than the task itself.

## Cross-Reference Summary

| System | Primary strength | Main execution lesson for PGE |
| --- | --- | --- |
| Claude Code native runtime | transport + tool substrate | substrate is not a deterministic orchestrator |
| GSD | task-tiered workflows | light tasks need light paths; orchestrator stays lean |
| gstack | specialized workflows + observability | workflow specialization beats one universal heavy path |
| mattpocock/skills | small composable process units | over-owning process reduces control and increases process bugs |

## Synthesis For PGE

### What should remain true

PGE should keep:

- three execution roles:
  - planner
  - generator
  - evaluator
- one clear orchestrator:
  - main
- explicit artifact chain

### What should change

PGE should stop treating:

- prompt text
- freeform route interpretation
- multi-owner progress writing
- ad-hoc teardown behavior

as if they were stable protocol mechanisms.

## Recommended PGE Execution Model

### Fixed primary skeleton

All real tasks:

```text
planner -> generator -> evaluator
```

`main` stays outside that chain as the deterministic orchestrator.

### Deterministic responsibilities

These should be code-like or shim-like, not prompt-interpreted:

1. runtime event parsing
2. planner / deliverable / evaluator gate checks
3. route reduction
4. success/failure status mapping
5. teardown tool invocation
6. progress append

### Prompt-interpreted responsibilities

These can remain inside agent prompts:

1. planner contract quality
2. generator implementation approach
3. evaluator independent reasoning

## Improvement Plan A: Protocol Stabilization

### Goal

Make the current runtime mechanically consistent before making it more capable.

### Scope

- plain-string `SendMessage.message`
- canonical teammate events only
- deterministic `SUCCESS => PASS + converged`
- zero-argument `TeamDelete()`
- canonical progress schema
- ignore `idle_notification`

### Why first

Because execution is currently failing at the protocol layer before task quality even matters.

## Improvement Plan B: Deterministic Runtime Shim

### Goal

Move the most fragile orchestration actions out of model freeform behavior.

### Shim responsibilities

1. event parsing
2. route reduction
3. progress append
4. teardown sequence

### Why this matters

It keeps:

- planner
- generator
- evaluator

as real roles, while preventing:

- `PASS + continue`
- object-vs-string message failures
- `TeamDelete` misuse

## Improvement Plan C: Task Stratification

### Goal

Adopt GSD's best execution-layer lesson:
task complexity should decide workflow thickness.

### Proposed tiers

1. **Trivial**
   - inline / no team

2. **Quick**
   - `planner -> generator -> evaluator`
   - light orchestrator

3. **Complex**
   - same P/G/E skeleton
   - thicker planner / evidence / evaluation
   - optional future loop support

### Why this matters

PGE should not pay complex-task coordination cost on every small task.

## Improvement Plan D: Real-Task Validation

### Goal

Stop using smoke as the main argument source for runtime design.

### Validate with real tasks

Use real but bounded tasks to check:

1. Does planner stay reasonably thin?
2. Does generator handoff happen quickly?
3. Does evaluator produce stable route signals?
4. Does `main` close without semantic contradictions?
5. Does progress actually help identify friction?

## Recommended Order

1. Protocol stabilization
2. Deterministic runtime shim
3. Task stratification
4. Real-task proving

## Bottom Line

The common lesson across these systems is not:
"add more process."

The common lesson is:

- stratify the workflow
- keep orchestrators lean
- keep roles sharp
- make protocol-sensitive actions deterministic

That is the execution-layer path PGE should follow.
