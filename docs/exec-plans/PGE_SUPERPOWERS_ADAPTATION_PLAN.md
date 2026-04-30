# PGE Superpowers Adaptation Plan

## Goal

Adapt the most useful workflow-control lessons from Superpowers and the orchestration-workflow reference into PGE's execution core without turning PGE into a heavy multi-skill workflow platform.

This plan is about:

- hardening the current execution core
- clarifying role boundaries
- tightening contracts
- making orchestration docs clearer

This plan is **not** about copying the entire Superpowers workflow.

---

## Non-goals

- do not add many new user-facing skills
- do not reintroduce a heavy default preflight lane into the current executable path
- do not require user approval between every stage
- do not turn PGE into a general product-design operating system

---

## Guiding Principles

1. **Few stages**
   - reduce runtime friction

2. **Hard gates**
   - no soft pass-through on missing contract / deliverable / verdict shape

3. **Explicit role I/O**
   - each role should have narrow, stable inputs and outputs

4. **Main is orchestration shell**
   - dispatch
   - correction
   - exception handling
   - progress ownership
   - quality governance

5. **Contracts should be execution-ready**
   - not prose-heavy
   - not placeholder-heavy
   - not dependent on downstream reinterpretation

---

## Workstream A — Planner hardening

### Why

This is the closest PGE equivalent to Superpowers `brainstorming` + `writing-plans`.

### Files

- `agents/pge-planner.md`
- `skills/pge-execute/handoffs/planner.md`
- `skills/pge-execute/contracts/round-contract.md`

### Required changes

1. Add explicit anti-pattern guardrails to Planner:
   - "too small to need contract"
   - "details can be decided during implementation"
   - "verification can be filled later"

2. Keep one focused clarification question only.

3. Strengthen Planner self-check:
   - placeholder scan
   - contradiction scan
   - scope sanity scan
   - ambiguity scan

4. Strengthen execution-ready contract rules:
   - clearer deliverable
   - clearer verification path
   - clearer required evidence

### Acceptance

- Planner output is harder to execute incorrectly.
- Planner output is harder to evaluate ambiguously.
- Planner does not expand into product-spec essay mode.

---

## Workstream B — Generator discipline

### Why

This is the closest PGE equivalent to Superpowers `executing-plans`.

### Files

- `agents/pge-generator.md`
- `skills/pge-execute/handoffs/generator.md`

### Required changes

1. Explicitly require Generator to review the locked contract before acting.
2. Explicitly forbid silent contract reinterpretation.
3. Explicitly require verification evidence, not only completion prose.
4. Explicitly require stop-on-blocker behavior.
5. Clarify Generator identity as:
   - coder
   - reviewer
   - integrator

### Acceptance

- Generator is less likely to freestyle.
- Generator outputs are easier for Evaluator to inspect independently.
- Generator failures are easier to classify as role failures instead of orchestration failures.

---

## Workstream C — Orchestration shell clarity

### Why

This is where the orchestration-workflow reference is most relevant.

### Files

- `skills/pge-execute/SKILL.md`
- `skills/pge-execute/ORCHESTRATION.md`
- `docs/exec-plans/PGE_RUNTIME_ROLES_AND_PIPELINE.md`

### Required changes

1. Keep the top-level shell small.
2. Keep `main` clearly described as orchestration / governance owner.
3. Add or tighten:
   - component summary
   - role matrix
   - I/O summary
   - flow diagram
   - non-responsibilities

4. Make gate boundaries obvious:
   - planner gate
   - generator gate
   - evaluator gate
   - route / teardown reduction

### Acceptance

- `main` is easier to reason about.
- orchestration rules no longer hide inside agent prose
- it is clearer which failures belong to protocol vs agent vs runtime

---

## Workstream D — Anti-drift skill writing cleanup

### Why

This is the closest PGE equivalent to lessons from `writing-skills`.

### Files

- `docs/design/pge-execute/layered-skill-model.md`
- `docs/design/pge-execute/execution-framework-lessons.md`

### Required changes

1. Add explicit note on what PGE borrows from Superpowers skill writing:
   - progressive layers
   - fewer giant prompts
   - high-signal gotchas
   - anti-patterns

2. Keep agent role logic out of `SKILL.md`.
3. Keep workflow authority in the lowest owning layer.

### Acceptance

- PGE becomes easier to maintain without flattening.
- future behavior additions have clearer homes.

---

## Suggested sequencing

### P0

1. Land this plan doc
2. Land `docs/design/pge-superpowers-learnings.md`
3. Harden Planner surfaces

### P1

4. Harden Generator surfaces
5. Tighten orchestration-shell docs

### P2

6. Clean up layered skill-writing docs
7. Re-run real bounded task proving to validate behavior

---

## Real-task proving focus

Do not validate these learnings only on smoke.

Use at least one real bounded task and check:

1. whether Planner still over-writes prose instead of contract
2. whether Generator still silently reinterprets plan fields
3. whether Evaluator can still independently judge the output
4. whether `main` remains lean instead of becoming the fourth expert
5. whether the harder gates reduce downstream ambiguity instead of increasing runtime drag

---

## Success criteria

This adaptation is successful when:

1. Planner contract quality improves without adding new default runtime stages
2. Generator execution becomes more plan-faithful
3. role boundaries become easier to audit
4. orchestration docs become more authoritative and easier to follow
5. the main runtime remains short:
   - planner
   - generator
   - evaluator
   - route / teardown

---

## Bottom line

The best Superpowers adaptation for PGE is not "more workflow."

It is:

- stronger contracts
- harder gates
- cleaner orchestration writing
- less freestyle execution

The best orchestration-workflow adaptation is not "more abstraction."

It is:

- clearer component ownership
- clearer shell structure
- clearer execution flow
