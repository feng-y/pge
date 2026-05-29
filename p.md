# PGE vNext: Research / Plan / Exec Responsibility Realignment

## Goal

Reposition PGE from a prompt-driven workflow into an AI-native execution architecture for complex repositories.

The purpose of this redesign is not to add more gates or planning ceremony.
The purpose is to stabilize execution by separating:

* problem alignment
* repository/runtime reality extraction
* execution-path design
* bounded implementation execution

into different responsibility layers.

The target mainline becomes:

```text
Research:
Clarify the real problem.

Plan:
Design an AI-stable execution path.

Exec:
Perform bounded evidence-driven implementation.
```

---

# Core Problems Being Solved

## Problem 1 — Research / Plan Responsibility Drift

Current AI workflows frequently mix:

* goal clarification
* architecture design
* implementation-path selection
* execution repair

across multiple stages.

Typical failure shape:

```text
Research:
already designing implementation.

Plan:
re-litigates goals and scope.

Exec:
replans architecture while implementing.
```

Result:

* goal drift
* scope drift
* unstable execution
* endless redesign loops
* non-converging implementations

---

## Problem 2 — Repository Reality Misalignment

Most execution failures are not caused by unclear user goals.

They are caused by:

```text
Human understanding
vs
AI understanding
vs
actual repository/runtime reality
```

being inconsistent.

Typical failures:

* hidden coupling
* fake abstractions
* rollout constraints
* verification impossibility
* runtime-path mismatch
* protocol inconsistencies
* ownership ambiguity

The current workflow does not explicitly separate:

```text
problem understanding
```

from:

```text
implementation reality understanding
```

This redesign fixes that separation.

---

## Problem 3 — Exec Owns Too Many Design Decisions

Current execution agents frequently:

* redesign architecture
* redefine rollout paths
* change issue slicing
* reinterpret verification strategy
* introduce speculative abstractions

while implementing.

This destroys convergence.

Exec must become:

```text
strict bounded implementation runtime
```

instead of:

```text
continuous replanning layer
```

---

# High-Level Stage Model

| Stage              | Core Responsibility                 |
| ------------------ | ----------------------------------- |
| Research           | Problem contract discovery          |
| Reality Extraction | Repository/runtime truth extraction |
| Plan               | AI-stable execution-path design     |
| Exec               | Bounded implementation execution    |
| Review / Challenge | Validation and drift detection      |

---

# Research vNext

## Purpose

Research is responsible for stabilizing:

```text
what problem is actually being solved
```

before implementation-path design begins.

Research owns:

* goal clarification
* motivation clarification
* success-shape alignment
* scope clarification
* ambiguity surfacing
* root-problem identification
* user-intent stabilization
* determining whether the task is plannable

Research does NOT own:

* implementation architecture
* rollout sequencing
* issue slicing
* execution topology
* migration design
* verification topology
* implementation-path selection

---

## Research Output

Research produces:

```text
Problem Contract
```

Minimum required fields:

| Field                     | Purpose                                   |
| ------------------------- | ----------------------------------------- |
| goal                      | Real objective                            |
| success_shape             | What success means                        |
| scope                     | Included work                             |
| non_goals                 | Explicit exclusions                       |
| constraints               | Business/runtime/repo constraints         |
| ambiguity                 | Remaining unknowns                        |
| implementation_friction   | Known repo friction                       |
| progressive_feasibility   | Whether incremental execution is required |
| first_plannable_objective | First bounded planning target             |
| route                     | READY_FOR_PLAN / NEEDS_INFO / NEEDS_HUMAN |

---

## Research Rules

### 1. Do Not Assume User Solutions Are User Goals

Research must separate:

```text
requested solution
```

from:

```text
actual user objective
```

Example:

```text
User:
"Build an MCP service"

Actual problem:
- remote execution continuity
- mobile interaction
- session persistence
- long-running operational workflows
```

Research must stabilize the real problem before planning.

---

### 2. Separate Fact / Inference / Assumption

Research must explicitly separate:

* FACT
* INFERENCE
* ASSUMPTION
* UNKNOWN

Repository guesses must not be presented as repository truth.

---

### 3. Research Must Not Enter Implementation Design

Research may identify:

```text
implementation friction
```

but must not design:

* implementation topology
* migration sequence
* issue slicing
* rollout paths
* architecture transitions

Those belong to Plan.

---

# Reality Extraction Layer

## Purpose

Reality Extraction exists because:

```text
problem truth
```

and:

```text
implementation truth
```

are different problems.

Research aligns the problem.

Reality Extraction aligns repository/runtime reality.

---

## Responsibilities

Reality Extraction is responsible for discovering:

* actual runtime paths
* hidden coupling
* state topology
* verification topology
* protocol surfaces
* migration blockers
* rollout constraints
* ownership structure
* execution hotspots
* dependency shape
* validation boundaries
* rollback constraints

---

## Output

Reality Extraction produces:

```text
Execution Reality Map
```

including:

| Field                    | Purpose                                |
| ------------------------ | -------------------------------------- |
| runtime_paths            | Actual execution flow                  |
| protocol_surfaces        | Producer/consumer/validator boundaries |
| coupling_hotspots        | High-risk shared areas                 |
| rollout_constraints      | Deployment/runtime restrictions        |
| verification_constraints | Validation limitations                 |
| migration_blockers       | Structural blockers                    |
| execution_risks          | Runtime execution hazards              |
| ownership_map            | Repo/system ownership reality          |

---

# Plan vNext

# Core Positioning

Plan is NOT:

```text
implementation-plan formatting
```

Plan IS:

# AI-stable execution-path design.

Plan translates:

* aligned goals
* repository/runtime reality
* implementation friction
* verification constraints

into:

* bounded executable contracts
* issue execution graph
* rollout-safe migration paths
* incremental verification topology
* execution-safe implementation ordering

before execution begins.

---

# Plan Responsibilities

Plan owns:

* implementation-path decisions
* architecture-friction reduction
* issue slicing
* execution ordering
* verification topology
* migration sequencing
* complexity reduction
* rollout safety
* blast-radius minimization
* incremental execution strategy
* protocol coherence strategy
* execution ergonomics

Plan does NOT own:

* open-ended problem discovery
* redefining user goals
* speculative architecture redesign
* direct implementation
* runtime debugging

---

# Architecture Friction Resolution

## Purpose

The core value of Plan is resolving friction between:

* requested goals
* repository architecture
* runtime constraints
* verification topology
* execution stability

before work reaches Exec.

---

## Example

User goal:

```text
Unify feature loading.
```

Repository reality:

* shared runtime state
* hidden coupling
* no isolated verification
* rollout risk
* protocol inconsistency

Bad planning:

```text
Issue 1
Issue 2
Issue 3
```

Correct planning:

```text
1. Introduce registration surface
2. Preserve existing runtime path
3. Add compatibility adapter
4. Establish isolated verification point
5. Migrate incrementally
```

Plan must design:

```text
AI-stable execution shape
```

not merely task lists.

---

# Research Contract Override Rule

When consuming:

```text
research.v3
```

with:

```text
route: READY_FOR_PLAN
```

Plan inherits the research problem contract as authoritative.

Plan may challenge:

* implementation directions
* complexity
* rollout safety
* migration shape
* execution topology

Plan must NOT silently override:

* goal
* success_shape
* scope
* non_goals
* constraints
* progressive_feasibility
* first_plannable_objective

Semantic changes require:

* explicit user confirmation
* RETURN_TO_RESEARCH
* NEEDS_INFO
* NEEDS_HUMAN

Non-semantic refinements may be repaired inline.

---

# Plan Engineering Review

## Purpose

Plan Engineering Review is NOT another gate layer.

Its purpose is:

# reducing Exec friction.

---

## Responsibilities

Plan Engineering Review should:

* challenge unnecessary complexity
* reduce blast radius
* strengthen verification
* identify hidden coupling
* improve rollout safety
* improve issue slicing
* improve execution ergonomics
* identify weak evidence paths
* identify missing protocol alignment

Review should repair plans inline whenever possible.

Upstream routing should only occur when:

* the problem contract changes
* user authority is required
* success shape becomes invalid
* constraints become incompatible

---

## Depth Scaling

### LIGHT

* existing-code reuse
* verification sanity
* scope minimization

### MEDIUM

* approach tradeoffs
* issue slicing
* failure modes
* rollout shape
* verification topology

### DEEP

* architecture transition review
* protocol coherence
* migration safety
* parallel execution safety
* rollout sequencing
* data-flow constraints

DEEP review must remain bounded to execution-relevant surfaces.

Plan must not perform open-ended architecture redesign.

---

# Issue Slicing vNext

Issue slicing is NOT:

```text
task breakdown
```

Issue slicing IS:

# execution graph design.

---

## Good Issue Slices Must Be

| Property              | Meaning                      |
| --------------------- | ---------------------------- |
| bounded               | Controlled scope             |
| locally verifiable    | Local verification possible  |
| low coupling          | Minimized shared state       |
| rollback-safe         | Reversible                   |
| execution-order aware | Correct dependency order     |
| migration-aware       | Supports progressive rollout |
| evidence-producible   | Can generate evidence        |
| context-local         | Reduced context burden       |

---

# Incremental Verification Topology

Plan must explicitly classify:

* independently verifiable work
* coupled verification groups
* serial execution requirements
* isolated-worktree requirements
* parallel-safe execution groups
* first trustworthy verification point
* final integration verification point

Plan must NOT imply:

```text
independent execution
```

when verification is shared.

---

# Executable Contract Requirements

Each executable issue must explicitly define:

| Field                 | Purpose                        |
| --------------------- | ------------------------------ |
| behavior_delta        | What changes                   |
| target_areas          | Intended surfaces              |
| forbidden_areas       | Out-of-scope surfaces          |
| acceptance_criteria   | Success condition              |
| verification_hint     | Validation path                |
| required_evidence     | Required proof                 |
| dependencies          | Ordering requirements          |
| verification_coupling | Shared verification boundaries |
| AFK_HITL              | Human involvement requirements |
| risks                 | Execution hazards              |
| state                 | Execution readiness            |

---

# Exec vNext

## Core Positioning

Exec is:

# bounded evidence-driven implementation runtime.

Exec is NOT:

* open-ended planning
* architecture redesign
* scope renegotiation
* migration redesign
* execution-path selection

---

## Exec Responsibilities

Exec owns:

* implementation
* local repair
* contract alignment
* evidence generation
* runtime validation
* verification execution

Exec must:

* respect plan boundaries
* minimize unnecessary changes
* preserve rollout safety
* obey repository/runtime reality

---

## Exec Rules

Exec may surface:

* blockers
* broken assumptions
* invalid repository reality
* impossible verification

But Exec must NOT silently:

* redefine architecture direction
* redesign rollout
* rescope issues
* introduce speculative abstractions
* redefine verification topology

Escalation is required instead.

---

# Review / Challenge

## Purpose

Review and Challenge exist to:

* validate execution correctness
* detect drift
* detect hidden coupling
* identify unsafe assumptions
* identify verification weakness
* detect scope expansion

Review validates:

```text
implementation correctness
```

Challenge validates:

```text
execution and decision robustness
```

---

# Final Mainline

The final vNext execution chain becomes:

```text
User Goal
↓
Research
(problem contract discovery)
↓
Reality Extraction
(repository/runtime truth)
↓
Plan
(AI-stable execution-path design)
↓
Exec
(bounded evidence-driven implementation)
↓
Review / Challenge
(validation and drift detection)
↓
Ship
```

---

# Final Responsibility Summary

| Stage              | Owns                      | Must Not Own            |
| ------------------ | ------------------------- | ----------------------- |
| Research           | Problem truth             | Implementation topology |
| Reality Extraction | Repository/runtime truth  | Goal definition         |
| Plan               | Execution-path design     | Open-ended redesign     |
| Exec               | Bounded implementation    | Replanning architecture |
| Review / Challenge | Validation and robustness | Redefining goals        |

---

# Final Success Criteria

The redesign succeeds when:

* Research stabilizes the real problem instead of designing implementation.
* Reality Extraction exposes repository/runtime truth explicitly.
* Plan produces AI-stable execution paths instead of checklist plans.
* Plan resolves architecture friction before Exec.
* Exec performs bounded implementation instead of continuous replanning.
* Issue slicing produces stable execution topology.
* Verification topology is explicit and honest.
* Incremental rollout and rollback become first-class planning concepts.
* Review and Challenge validate robustness instead of adding procedural ceremony.
* Complex repository work converges with lower execution drift and lower replanning frequency.

已经整理为完整的 vNext 对齐方案，重点已经从“讨论式 prompt”收敛为：

* phase responsibility
* execution architecture
* repo reality extraction
* AI-stable execution path
* bounded execution runtime
* incremental verification topology
* architecture friction resolution

并且已经融合了你原始文档中的：

* Research Contract Override Rule
* Plan Engineering Review
* Incrementally Verifiable Output
* Verification Coupling
* Issue Slicing
* Protocol Coherence
* plan-eng-review 定位调整

同时重新定义了：

```text
Research → Plan → Exec
```

各自真正的职责边界。
