# Official Plugin Alignment Plan

## Goal

Use Anthropic official Claude Code plugins as external evidence to improve PGE's user-facing workflow clarity, review gates, security-check layering, and learning loop without turning PGE into a copy of those plugins.

## Source Evidence

- `feature-dev`: reference for PGE's Research -> Plan -> Exec -> Review arc.
- `code-review`: reference for reviewer role separation, confidence handling, and review output quality.
- `security-guidance`: reference for layered safety checks: deterministic patterns, diff review, and deeper agentic review.
- `claude-code-setup`: reference for read-only automation recommendations and small top-N reusable asset suggestions.

## Non-Goals

- Do not merge PGE into a single `/feature-dev` command.
- Do not create broad meta-agents.
- Do not import official plugin code or copy their directory structure.
- Do not add hooks, CI, commands, or agents before a PGE-specific candidate passes `pge-learn` review.
- Do not rewrite unrelated PGE contracts while doing terminology or documentation alignment.

## Operating Principle

Official plugins are comparison evidence, not authority. PGE keeps its artifact-backed phase boundaries:

```text
pge-research -> pge-plan -> pge-exec -> pge-review -> pge-challenge -> pge-learn
```

The improvement path is to learn from official plugin ergonomics, then make the smallest PGE-native change.

## Reference Mapping

| Official plugin | PGE surface | What to learn | What not to copy |
|---|---|---|---|
| `feature-dev` | `pge-research`, `pge-plan`, `pge-exec`, `pge-review` | plain phase names, clear use/don't-use boundaries, discovery -> design -> implementation -> review shape | one-command ownership of the full workflow |
| `code-review` | `pge-review`, `pge-exec` Final Review Gate | reviewer specialization, confidence filtering, actionable findings | unbounded review fan-out |
| `security-guidance` | `pge-review`, future safety checks | split deterministic checks from LLM/agent review | putting deterministic policy into prose-only skill rules |
| `claude-code-setup` | `pge-learn` | read-only recommendation mode, top 1-2 reusable asset suggestions, clear asset categories | setup wizard behavior or broad automation creation |

## Issue 1: Clarify PGE User Mental Model

**Intent:** Make PGE easier to understand by mapping official-style phase names onto existing PGE surfaces.

**Target areas:**
- `README.md`
- possibly `CLAUDE.md` if a resident-rule pointer is needed

**Work:**
- Add a compact "PGE in plain phases" table:
  - Discovery / Exploration -> `pge-research`
  - Design / Architecture -> `pge-plan`
  - Implementation -> `pge-exec`
  - Quality Review -> `pge-review` / `pge-challenge`
  - Learning -> `pge-learn`
- Keep existing PGE artifact names and authority boundaries.
- Make clear that PGE is staged and artifact-backed, unlike a single all-in-one command.

**Acceptance:**
- A new reader can tell which PGE surface to use after seeing an official `feature-dev` style workflow.
- The docs do not imply PGE has a `/feature-dev` equivalent.
- No skill behavior changes.

**Validation:**
- Manual doc review against `README.md` and `CLAUDE.md`.
- Search for accidental new command claims such as `/feature-dev`.

## Issue 2: Tighten `pge-learn` Around Friction-Driven Improvement

**Intent:** Make `pge-learn` the place where official-plugin comparisons and local friction become scored improvement candidates.

**Target areas:**
- `skills/pge-learn/SKILL.md`

**Work:**
- Preserve `learn` as one capability: recent work, memory, code summaries, context friction, and repeated workflow learning.
- Add or refine output guidance so learning reports recommend only the top 1-2 high-signal improvements when the input is broad.
- Ensure artifact-shape friction is captured, such as user expecting `implementation-notes.html` while `pge-exec` currently owns `implementation-notes.md`.
- Keep recommendations read-only unless the user explicitly asks for promotion.

**Acceptance:**
- `pge-learn` can evaluate official plugin links as source evidence without creating new assets by default.
- It distinguishes local PGE friction from generic "official plugin does X" copying.
- It recommends the smallest target: clarify docs, update owning skill, derived HTML view, hook/CI, or skip.

**Validation:**
- Run a manual pressure scenario: "Compare official `feature-dev` to PGE" should produce candidates, not implementation.
- Run a manual pressure scenario: "`implementation-notes.html` expectation" should identify artifact-shape friction and route to the owning PGE surface.

## Issue 3: Move High-Frequency Review Capabilities Into `pge-exec`

**Intent:** Use official `code-review` as a capability reference, but put high-frequency fixable checks into `pge-exec` so `pge-review` remains the final independent audit.

**Target areas:**
- `skills/pge-exec/SKILL.md`
- `skills/pge-exec/handoffs/generator.md`
- `skills/pge-exec/handoffs/evaluator.md`
- `skills/pge-exec/references/generator-rules.md`
- `skills/pge-exec/references/evaluator-thresholds.md`
- `skills/pge-review/SKILL.md` only to preserve final-audit positioning

**Work:**
- Strengthen Generator's candidate quality gate so it checks issue alignment, goal/non-goal alignment, repo constraints, changed-hunk bugs, deleted invariants, caller/callee impact, performance risk, code quality, scope, and evidence before `READY`.
- Strengthen Evaluator so final run verification independently catches the same high-frequency execution defects and returns bounded repair feedback.
- Keep `pge-review` as a final independent audit rather than the first systematic bug finder.
- Treat repeated fixable findings escaping to `pge-review` as evidence that `pge-exec` needs stronger gates.

**Acceptance:**
- Generator cannot send `READY` without changed-hunk audit and quality-axis evidence.
- Evaluator checks issue/goal alignment, repo constraints, performance, code quality, verification, and composed behavior before `PASS`.
- Routine fixable defects are repaired inside `pge-exec` when in-contract.
- `pge-review` remains an independent final audit and does not become a dumping ground for execution-stage misses.

**Validation:**
- Inspect `pge-exec` contracts for Generator/Evaluator/main Candidate Gate closure.
- Run a manual pressure scenario where Generator misses a local bug; Evaluator should return a bounded RETRY before final review.
- Run a manual pressure scenario where a repo artifact contract is violated; exec should catch or route it before review.

## Issue 4: Security Guidance Layering

**Intent:** Keep security checks in the right layer.

**Target areas:**
- `pge-review` security axis
- future script/hook/CI proposal only if deterministic checks recur
- docs if clarification is enough

**Work:**
- Classify potential security improvements into:
  - deterministic pattern checks -> script/hook/CI candidate
  - diff-risk review -> `pge-review`
  - high-risk or broad threat modeling -> dedicated review path only if evidence supports it
- Do not encode deterministic security rules as long prose if a mechanical check is more reliable.

**Acceptance:**
- PGE docs or skills clearly route deterministic security checks away from prose-only agent judgment.
- No hook or CI file is created in this plan unless a later issue explicitly asks for implementation.

**Validation:**
- Manual review of proposed security candidates for layer fit.

## Issue 5: Automation Recommendation Discipline

**Intent:** Borrow the `claude-code-setup` recommendation discipline for PGE learning outputs.

**Target areas:**
- `skills/pge-learn/SKILL.md`
- possibly README if user-facing explanation is needed

**Work:**
- When the input is broad, cap recommendations to the top 1-2 per output, not a full backlog.
- Name the recommended asset type explicitly: extend existing, doc/checklist, skill, subagent, command, hook/script/CI, scheduled automation proposal, or skip.
- Require evidence and overlap risk for each recommendation.

**Acceptance:**
- `pge-learn` output stays concise and decision-oriented.
- The user can choose the next action without reading a broad inventory.

**Validation:**
- Use the official plugin links as a test input and confirm the output is a shortlist, not a taxonomy dump.

## Suggested Execution Order

1. Issue 2: tighten `pge-learn` first so future official-plugin comparisons are captured correctly.
2. Issue 1: clarify the user-facing PGE mental model in README.
3. Issue 3: calibrate review gates.
4. Issue 4: document security layering or propose deterministic checks.
5. Issue 5: refine recommendation discipline if Issue 2 did not fully cover it.

## Success Criteria

- PGE has a clearer external-reference story: official plugins inform PGE, but do not override its artifact-backed staged architecture.
- `pge-learn` can process official plugin references and local friction into small, evidence-backed improvement candidates.
- Research/plan/exec/review remain separate PGE surfaces.
- Any deterministic future work is routed to script/hook/CI proposals instead of prose-only agent instructions.

## Risks

- Overfitting to official plugin structure and weakening PGE's staged artifact model.
- Turning `pge-learn` into a broad meta-planner instead of a learning gate.
- Adding review/security machinery without repeated local evidence.
- Documentation drift if README mappings are updated but skill contracts are not.
