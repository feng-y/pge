# pge-plan I/O & Self-Correction: Best-Practice Comparison

## INPUT Comparison

| Framework | Required Input | Gate Behavior |
|-----------|---------------|---------------|
| **GSD** | CONTEXT.md + STATE.md + ROADMAP + REQUIREMENTS.md + RESEARCH.md (5 files) | Cannot plan without all 5; returns PHASE SPLIT if missing |
| **CE** | feature_description + brainstorm requirements doc (optional) + STRATEGY.md | Empty → ask; brainstorm found → carry forward all IDs |
| **Superpowers** | Spec or requirements doc (single file) | Scope Check: if multiple subsystems → suggest breaking |
| **HumanLayer** | Ticket file + parallel research agents gather codebase reality | "Read ALL files FULLY"; never partial reads |
| **BMAD** | PRD + Architecture decisions (validated prerequisites) | step-01-validate-prerequisites gates entry |
| **Spec-Kit** | constitution + spec.md (chain) | Non-interactive; assumes chain complete |
| **Matt Pocock** | Plan/spec/PRD from conversation context | Minimal gate; works from whatever exists |
| **pge-plan** | 5 accepted sources (priority order) + .pge/config/* | Gate check: stop if incomplete/missing + complex |

**Gap:** pge-plan's input is well-defined. No major gap vs best practice.

---

## OUTPUT Comparison (Task/Issue Structure)

| Framework | Task Unit | Fields per Task | Actionability |
|-----------|-----------|-----------------|---------------|
| **GSD** | XML `<task>` | Type, Files (exact paths), Action (what to do), Verify (command), Done (expected state) | Very high — executor needs zero interpretation |
| **CE** | `### U<N>. [Name]` | Goal, Requirements (R/A/F/AE IDs), Dependencies (U-IDs), Files (repo-relative), Approach, Test scenarios (happy/edge/error/integration), Verification | Very high — traceability + test coverage |
| **Superpowers** | `### Task N: [Name]` | Files (Create/Modify/Test with exact paths), Steps (checkbox with code blocks), Commit instructions | Maximum — includes actual code |
| **HumanLayer** | Phase with Changes | Overview, Changes Required (per file with code), Success Criteria (Automated checklist + Manual checklist) | High — code-level detail |
| **BMAD** | Story | Acceptance criteria for Developer agent | Medium — no file paths |
| **Spec-Kit** | `- [ ] [TaskID] Description` | TaskID, Description with file path, organized by phase | Medium — checklist format |
| **Matt Pocock** | Issue | Title, Type (HITL/AFK), Blocked by, What to build, Acceptance criteria | Medium — behavior-focused, no file paths |
| **pge-plan** | `### Issue N: [Title]` | ID, Title, Scope, Target Areas, Acceptance Criteria, Verification Hint, Verification Type, Execution Type, State, Dependencies, Risks | Medium-High — missing Action, Files detail, Test scenarios |

### Key OUTPUT gaps in pge-plan:

1. **No explicit Action field** — "Scope" describes what the issue covers, but not what to DO. GSD's `<action>` is imperative: "Create X", "Modify Y to add Z", "Wire A to B".
2. **Target Areas is vague** — "files/modules" vs GSD/Superpowers' exact paths with Create/Modify/Test distinction.
3. **No Test scenarios per issue** — CE requires happy/edge/error/integration test scenarios per unit. pge-plan has Verification Hint (a command) but no test design.
4. **No Done state** — GSD defines what "done" looks like per task (expected state after execution). pge-plan has Acceptance Criteria but it's less concrete.

---

## SELF-CORRECTION Comparison

| Framework | Mechanism | When | Iterative? |
|-----------|-----------|------|-----------|
| **GSD** | Goal-backward + Context fidelity self-check + Multi-Source Coverage Audit | Before returning | No — single pass, returns to orchestrator |
| **CE** | Phase 5.1 "Review Before Writing" + Phase 5.3 "Confidence Check and Deepening" | Before write + after write | Yes — deepening can trigger re-research |
| **Superpowers** | Self-Review (spec coverage, placeholder scan, type consistency) | After write | No — fix inline |
| **HumanLayer** | "Be Skeptical" + verify sub-task results + iterate with user | Throughout | Yes — multiple user checkpoints |
| **BMAD** | Sequential enforcement + token-count HALT + "do not fantasize" | Throughout | Yes — HALT and ask |
| **Matt Pocock** | Quiz user on breakdown (4 questions) | After decomposition | Yes — iterate until approved |
| **pge-plan** | Coverage Audit + Engineering Review + Self-Evaluation + Self-Review (6 steps) | Phase 2 + Phase 3 + Phase 4 | No — fix inline, move on |

### Key SELF-CORRECTION gaps:

1. **No post-write deepening loop** — CE has "Confidence Check and Deepening" that can trigger re-research after writing. pge-plan fixes inline but never re-enters Phase 2.
2. **No decomposition validation** — Matt Pocock quizzes user on breakdown. pge-plan writes and routes. (Trade-off: human-in-loop vs correctness)

---

## QUESTION Behavior Comparison

| Framework | When it asks | How many | Format |
|-----------|-------------|----------|--------|
| **GSD** | Never during planning | 0 | Returns structured options to orchestrator |
| **CE** | Only when materially affects architecture/scope/risk | Minimal | One at a time, single-select |
| **Superpowers** | Never during planning | 0 | Offers execution choice at end |
| **HumanLayer** | Multi-checkpoint (after research, design, outline, draft) | 4+ rounds | Open-ended feedback |
| **BMAD** | HALT on intent gaps; menus require selection | Per-menu | Menu choices |
| **Matt Pocock** | Quiz on breakdown (4 specific questions) | 1 round of 4 | Specific questions |
| **Spec-Kit** | Never | 0 | Non-interactive |
| **pge-plan** | Only User Challenge + 3 valid reasons | 0-1 | One question max |

### Key QUESTION gaps:

1. **No decomposition quiz** — Matt Pocock validates breakdown with user. pge-plan skips this. (Intentional for human-in-loop reduction, but risky for DEEP tasks)
2. **No "return structured options to orchestrator" pattern** — GSD never asks the user directly; it returns options to the orchestrator who decides. pge-plan asks directly.

---

## Recommended Fixes

### HIGH (output actionability)

1. **Add `Action` field to issues** — imperative description of what to do (not just scope)
2. **Expand Target Areas to Files** — with Create/Modify distinction and exact paths
3. **Add Test Expectations per issue** — at minimum: what to test (happy path + one edge case)

### MEDIUM (self-correction)

4. **Add post-write confidence gate** — after Self-Review, if any issue has LOW confidence on a correctness-affecting assumption, re-enter Phase 2 Explore for that specific gap (bounded: max 1 re-entry)

### LOW (question behavior, trade-off with human-in-loop)

5. **Optional decomposition validation for DEEP tasks** — present breakdown summary before writing full plan. Not a quiz (too many questions), just a one-line confirmation: "Plan will have N issues covering X, Y, Z. Proceed?"
