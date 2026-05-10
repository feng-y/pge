# PGE Superpowers Learnings

> Date: 2026-04-30
> Status: Draft
> Purpose: capture what PGE should learn from Superpowers as a workflow system, plus one adjacent orchestration-writing reference that clarifies how the top-level shell should be documented.

---

## 1. Scope

This document is not a proposal to copy the whole Superpowers system.

It answers four narrower questions:

1. What does Superpowers do well that matches PGE's current execution problems?
2. What should PGE borrow at the workflow / contract / skill-writing level?
3. What should PGE explicitly **not** copy?
4. Which PGE documents should change if these lessons are adopted?

---

## 2. Source set

Primary Superpowers sources:

- `brainstorming/SKILL.md`
- `writing-plans/SKILL.md`
- `executing-plans/SKILL.md`
- `writing-skills/SKILL.md`

Companion orchestration-writing source:

- `claude-code-best-practice/orchestration-workflow.md`

Why include the orchestration-workflow reference here?

Because Superpowers is strongest on planning and execution discipline, while the orchestration-workflow reference is strongest on **how to write the top-level orchestration shell clearly**. PGE needs both.

---

## 3. What Superpowers teaches that PGE should absorb

### 3.1 From `brainstorming`

Superpowers treats design clarification as a hard workflow stage, not an optional suggestion.

The most useful lessons for PGE are:

1. **Hard gate before implementation**
   - no design approval -> no implementation
   - this maps directly to PGE's need for a real Planner gate

2. **One question at a time**
   - clarification should be focused
   - this maps to `planner_escalation` as a single focused question rather than a question dump

3. **Alternatives + rejected alternatives**
   - a good planning artifact records not just the chosen cut, but why the obvious alternatives were rejected
   - this matches PGE's thin brainstorming / rejected-cuts direction

4. **Self-check before handoff**
   - placeholder scan
   - contradiction scan
   - scope sanity check
   - ambiguity scan
   - this maps well to Planner contract self-check

5. **Anti-pattern guardrails**
   - "too small to need design"
   - "I'll explore first and design later"
   - "I'll fill in the details during implementation"
   - PGE should explicitly block these failure modes in planner-facing docs

### 3.2 From `writing-plans`

Superpowers treats a plan as an execution artifact, not as explanatory prose.

The most useful lessons for PGE are:

1. **Plan must be execution-ready**
   - not motivational text
   - not architecture vibes
   - not TODO placeholders

2. **Steps should be bite-sized**
   - small enough to execute and verify
   - this matches PGE's bounded-round philosophy

3. **File paths / commands / expected outputs should be concrete**
   - execution should not depend on downstream guessing
   - this is exactly what PGE's `actual_deliverable`, `verification_path`, and `required_evidence` should enforce

4. **Task-by-task plan shape**
   - the executor should know what to do next without reinterpretation
   - PGE should strengthen "locked contract as execution contract" in this direction

### 3.3 From `executing-plans`

Superpowers does not treat execution as "take a vague plan and freestyle."

The most useful lessons for PGE are:

1. **Read the plan carefully before acting**
2. **Critically review the plan before implementation**
3. **Execute in order**
4. **Verify each step**
5. **Stop on blocker instead of guessing**

This is a strong fit for PGE Generator.

PGE should not treat Generator as only "coder."
It should treat Generator as:

- coder
- integrator
- local reviewer

### 3.4 From `writing-skills`

Superpowers' skill-writing guidance is useful even when we do not copy the workflow itself.

The most useful lessons for PGE are:

1. **Progressive layers**
   - top-level entrypoint stays small
   - details live in referenced resources

2. **Decision-oriented writing**
   - less narration
   - more rules, patterns, examples, and red flags

3. **Explicit anti-drift structure**
   - what to do
   - what not to do
   - common failure modes

4. **Do not flatten the system into one giant prompt**
   - this strongly supports PGE's `SKILL.md` / `handoffs/` / `contracts/` / `runtime/` layering

### 3.5 From `orchestration-workflow`

The orchestration-workflow reference is not a planning framework. It is an orchestration-shell writing pattern.

The most useful lessons for PGE are:

1. **Top-level shell should be explicit**
   - component summary
   - component details
   - execution flow
   - example execution

2. **Orchestrator is not the same thing as a worker**
   - top-level shell coordinates
   - agents do specialized work
   - skill resources hold reusable procedure

3. **Agent and skill resources should stay separate**
   - role prompts are not where all orchestration logic should live

4. **Main flow should be short and legible**
   - this supports PGE's move toward fewer stages and harder gates

---

## 4. What PGE should borrow

PGE should borrow these things directly:

### 4.1 Workflow rules

- few stages
- hard gates
- one focused clarification question at a time
- no implementation before contract approval
- no silent reinterpretation during execution
- stop on blocker, do not guess through it

### 4.2 Plan / contract rules

- contract must be execution-ready
- rejected alternatives should be recorded when the cut is not obvious
- placeholder / contradiction / ambiguity self-check should be mandatory
- deliverable / verification / evidence must be concrete enough that Generator and Evaluator do not invent semantics

### 4.3 Generator rules

- Generator must review the locked contract before execution
- Generator must execute against the contract, not against its own reinterpretation
- Generator must provide verification evidence, not just completion prose

### 4.4 Skill-writing rules

- keep `SKILL.md` small and orchestration-only
- move role behavior into `agents/`
- move phase procedure into `handoffs/`
- move shared rules into `contracts/`
- write anti-patterns and non-goals explicitly

### 4.5 Orchestration-shell rules

- `main` should be documented as:
  - scheduler
  - corrector
  - exception handler
  - progress owner
  - quality/governance owner
- but not as a fourth domain expert

---

## 5. What PGE should not copy

PGE should explicitly avoid copying the following:

1. **Full Superpowers multi-skill workflow**
   - PGE is not trying to become a general product-design operating system

2. **User approval between every stage**
   - PGE must still run autonomously on clear bounded tasks

3. **Heavy always-on planning chain**
   - not every task should re-enact the whole brainstorming -> plan -> execute stack

4. **Narrative-heavy documents**
   - PGE needs fewer essays and more enforceable contracts

5. **Skill sprawl**
   - PGE should deepen one execution core before multiplying skill surfaces

---

## 6. Mapping from learnings to PGE document changes

| Learning | PGE surface that should change |
|---|---|
| hard gate before implementation | `skills/pge-execute/ORCHESTRATION.md`, `agents/pge-planner.md`, `agents/pge-generator.md` |
| one question at a time | `agents/pge-planner.md`, `skills/pge-execute/handoffs/planner.md` |
| rejected alternatives | `agents/pge-planner.md`, `skills/pge-execute/handoffs/planner.md` |
| self-check before handoff | `agents/pge-planner.md`, `skills/pge-execute/contracts/round-contract.md` |
| anti-pattern guardrails | `agents/pge-planner.md`, `agents/pge-generator.md`, possibly `agents/pge-evaluator.md` |
| execution-ready plan | `skills/pge-execute/contracts/round-contract.md` |
| bite-sized executable steps | `skills/pge-execute/contracts/round-contract.md`, `agents/pge-generator.md` |
| execute-in-order / stop-on-blocker | `agents/pge-generator.md`, `skills/pge-execute/handoffs/generator.md` |
| progressive layering in skill writing | `skills/pge-execute/SKILL.md`, `docs/design/pge-execute/layered-skill-model.md` |
| explicit orchestration shell docs | `docs/exec-plans/PGE_RUNTIME_ROLES_AND_PIPELINE.md`, `skills/pge-execute/ORCHESTRATION.md` |

---

## 7. Immediate implications for PGE

If PGE accepts these learnings, the next concrete moves should be:

1. strengthen Planner as `researcher + architect + planner`
2. strengthen Generator as `coder + reviewer + integrator`
3. keep Evaluator independent and compact
4. keep `main` as orchestration shell, not as a fourth expert
5. keep the primary runtime skeleton short
6. make the planner and generator gates harder
7. add anti-pattern rules before adding more phases

---

## 8. Bottom line

Superpowers does **not** mainly teach PGE to add more stages.

It teaches PGE to make the existing stages:

- harder
- clearer
- more bounded
- less guess-driven

The orchestration-workflow reference complements this by showing how to document the top-level orchestration shell without flattening everything into one prompt.

The right PGE adaptation is:

- fewer stages
- harder gates
- clearer role boundaries
- smaller orchestration shell
- stronger execution-ready contracts
