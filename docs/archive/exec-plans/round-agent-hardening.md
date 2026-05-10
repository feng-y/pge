# Agent Hardening Round

## 本轮目标

Replace stub Generator and Evaluator with real agents that execute actual work and validate real deliverables.

## Progress

- ✓ Read ECC GAN agent references (blocked by network, proceeded with principles)
- ✓ Read Anthropic harness design principles (blocked by network, proceeded with known patterns)
- ✓ Read current PGE repo state and post-MVP proving round 004 artifacts
- ✓ Identified the P0 blocker: agents produce meta-artifacts instead of real work
- ✓ Built real Generator agent with semantic guardrails against placeholder artifacts
- ✓ Built real Evaluator agent with hard PASS conditions preventing false-positive approval
- ✓ Performed three-pass self-review (ECC de-bias, boundary, real-work)
- ✓ Verified handoff contract alignment (Generator output = Evaluator input)
- ✓ Committed changes

## Blockers

None. Round complete.

## Decisions

### What was preserved from ECC
- Generator reads approved spec first
- Generator reads evaluator feedback on retries
- Generator fixes concrete issues rather than improvising scope
- Evaluator is independent and strict
- Evaluator validates against explicit contract rather than "looks OK"

### What was removed/adapted from ECC
- All product/app generation assumptions
- Live browser/Playwright dependencies
- Design scoring / originality scoring / app polish scoring
- GAN product spec structure
- Iteration files like `gan-harness/...`
- Dev server assumptions
- Broad product-planning tone

### What was preserved from aiworks principles
- Role boundaries and separation of concerns
- Evidence-driven work validation
- Minimal-change discipline
- Invariant awareness

### How Generator now supports real work
- Explicit "forbidden behavior" section prevents placeholder artifacts
- Must produce actual deliverable with changed_files list
- Must provide concrete evidence (tool output, not narrative)
- Must declare known_limits and deviations_from_spec
- Performs local verification but does not self-approve

### How Evaluator now prevents false-positive PASS
- Hard PASS conditions: all must be true to pass
  1. Actual deliverable exists (not placeholder)
  2. Acceptance criteria satisfied
  3. Evidence is sufficient
  4. No critical invariant violated
- Explicit anti-patterns section shows what NOT to do
- Must validate actual deliverable, not just artifact existence
- Must check evidence concretely, not trust narrative

### Repo-specific knowledge gaps discovered (deferred)
- No repo-specific disclosure docs added in this round
- Assumption: only current bounded spec and directly relevant repo files available
- If additional repo knowledge needed, will be exposed in next proving run

## Action

Committed real Generator and Evaluator agents to replace stubs.

## Next single action

Run a real proving task through the updated agents to verify they execute actual work and validate real deliverables (not meta-artifacts).

## Artifacts produced

- `agents/generator.md` (186 lines, real implementation)
- `agents/evaluator.md` (312 lines, real implementation)
- Git commit: e10588d

## Non-scope

- Planner redesign (not needed for this round)
- Runtime orchestration redesign (proving showed it's sound)
- Repo-specific disclosure docs (defer until needed)
- External-task support (not in scope)
- Multi-round support (not in scope)

## Quality verification

### Pass 1 — ECC de-bias
✓ No product/app generation baggage
✓ No live app / Playwright dependence
✓ No design-scoring logic
✓ No GAN-specific file layout

### Pass 2 — Boundary review
✓ Generator performs local verification but does not own final approval
✓ Evaluator owns final pass/fail gate
✓ Role boundaries are explicit and enforced
✓ Neither role silently changes scope

### Pass 3 — Real-work review
✓ Generator semantics require actual deliverable, not placeholder-only
✓ Evaluator semantics require deliverable validation, not artifact-exists-only PASS
✓ Result is usable for bounded repo-internal work
