# pge-plan vs 11 Frameworks: Per-Framework Comparison

Evaluation criteria:
1. **降低 Human In-The-Loop** — minimize user interruptions
2. **稳定执行** — stable, predictable agent execution
3. **解决需求理解错误** — prevent/detect requirement misunderstanding

---

## 1. CE (Compound Engineering) — `ce-plan`

| Dimension | CE ce-plan | pge-plan | Gap | Impact |
|-----------|-----------|----------|-----|--------|
| Depth classification | Phase 0: classifies LIGHT/MEDIUM/DEEP before planning | No depth classification — scales via anti-patterns | Missing | 稳定执行: explicit depth prevents over/under-planning |
| Multi-agent research | Phase 1: spawns parallel research agents per module | Phase 2 mentions "can use multi-Agent" but no protocol | Weak | 稳定执行: structured parallel research reduces drift |
| Flow analysis | Phase 2: explicit data-flow + control-flow tracing | Architecture Assessment mentions "data flow" loosely | Weak | 需求理解: flow tracing catches integration misunderstandings |
| Visual communication | Mermaid/ASCII diagrams conditional on content patterns | None | Missing | 需求理解: diagrams surface misalignment early |
| Domain-appropriate format | Adapts plan format to domain (itinerary, runbook, etc.) | Fixed template | N/A | Not relevant for engineering-only harness |
| Relationship to brainstorm | Explicit: "ce-brainstorm defines WHAT, ce-plan defines HOW" | Implicit via upstream consumption | OK | Already handled by pge-research |
| Year-awareness | Notes "current year is 2026" for time-sensitive plans | None | Minor | Low impact |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| Depth classification (LIGHT/MEDIUM/DEEP) | 稳定执行: prevents over-planning simple tasks, under-planning complex ones | HIGH |
| Structured multi-agent research protocol | 稳定执行: reduces single-agent drift on complex exploration | MEDIUM |
| Flow analysis requirement for multi-module changes | 需求理解: catches integration assumptions | MEDIUM |

---

## 2. GSD (Getting Stuff Done) — `gsd-planner`

| Dimension | GSD gsd-planner | pge-plan | Gap | Impact |
|-----------|----------------|----------|-----|--------|
| Multi-Source Coverage Audit | Mandatory audit over GOAL/REQ/RESEARCH/CONTEXT artifacts; flags unplanned items | Gate check reads upstream but no coverage audit | Missing | 需求理解: catches requirements silently dropped |
| Scope Reduction Prohibition | Prohibited words list ("v1", "simplified", "placeholder", "skip for now") | No Placeholders rule covers some but not all | Partial | 稳定执行: prevents agent from silently reducing scope |
| Task anatomy | `<files>`, `<action>`, `<verify>` with automated Nyquist Rule | Issues have Scope + Verification Hint but less structured | Weak | 稳定执行: structured task format reduces execution ambiguity |
| Interface-first ordering | Tasks ordered by interface creation before implementation | Ordered by dependency but no interface-first rule | Missing | 稳定执行: interface-first prevents rework |
| Discovery levels (0-3) | Explicit skip/quick/standard/deep classification | No explicit classification | Missing | Human-in-loop: auto-selects depth without asking |
| Goal-backward verification | 5-step process: state goal → derive truths → derive artifacts → derive wiring → key links | Self-Review checks upstream coverage | Weak | 需求理解: goal-backward catches missed requirements |
| Context budget awareness | Plans target ~50% context; 2-3 tasks max per plan | No context budget guidance | Missing | 稳定执行: prevents plans too large for executor context |
| STRIDE threat model | Security-sensitive plans get mandatory STRIDE analysis | Security mentioned in Architecture Assessment | Weak | 稳定执行: structured security review vs ad-hoc mention |
| Wave-based dependency | Tasks assigned to waves; file-overlap forces later waves | Sequential ordering only | Missing | 稳定执行: enables parallel execution by exec |
| Authority limits | Only 3 valid reasons to split/flag (context cost, missing info, dependency conflict) | No explicit authority limits | Missing | Human-in-loop: prevents unnecessary escalation |
| Prohibited justifications | "complex/difficult/non-trivial" cannot justify splitting | No such rule | Missing | Human-in-loop: forces concrete reasons for escalation |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| Multi-Source Coverage Audit | 需求理解: ensures nothing from upstream is silently dropped | HIGH |
| Scope Reduction Prohibition (expanded word list) | 稳定执行: catches agent scope-reduction drift | HIGH |
| Context budget awareness | 稳定执行: prevents plans that overflow executor context | HIGH |
| Goal-backward verification | 需求理解: systematic requirement traceability | MEDIUM |
| Authority limits (3 valid reasons only) | Human-in-loop: reduces unnecessary escalation | MEDIUM |
| Interface-first ordering rule | 稳定执行: reduces rework during execution | MEDIUM |
| Wave-based dependency for parallelism | 稳定执行: enables exec to parallelize safely | LOW (exec owns concurrency) |

---

## 3. Spec-Kit — `speckit.plan`

| Dimension | Spec-Kit | pge-plan | Gap | Impact |
|-----------|----------|----------|-----|--------|
| Constitution as hard input | `.specify/memory/constitution.md` loaded before every step | `.pge/config/docs-policy.md` is optional | Partial | 稳定执行: constitution prevents drift from project principles |
| Spec as hard input | `spec.md` must exist before plan starts | Structured upstream input required (similar) | OK | Already handled |
| Minimal plan content | Plan is just: tech context, design decisions, architecture, file structure | Full template with 15+ sections | N/A | pge-plan intentionally richer |
| Downstream chain | plan → tasks → implement (separate steps) | plan contains issues directly | OK | Intentional design choice |
| Feature directory isolation | Each feature gets its own directory | Plans in `.pge/plans/` flat | Minor | Low impact |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| Constitution/principles as mandatory input (not optional) | 稳定执行: prevents drift from project conventions | MEDIUM |

---

## 4. gstack — `plan-eng-review` + `autoplan`

| Dimension | gstack | pge-plan | Gap | Impact |
|-----------|--------|----------|-----|--------|
| 15 cognitive patterns | Explicit named patterns (state diagnosis, blast radius, boring by default, etc.) | Engineering Review has 4 dimensions but no named patterns | Partial | 稳定执行: named patterns are more memorable/executable |
| Confidence calibration (1-10) | Each finding scored 1-10 confidence | No confidence scoring | Missing | 需求理解: low-confidence findings get flagged for verification |
| Outside Voice (cross-model) | Codex/Claude subagent independently challenges the plan | Self-applied review only | Missing | 需求理解: independent challenge catches blind spots |
| Multi-perspective review | CEO → Design → Eng → DX sequential reviews | Single engineering review | Partial | N/A for engineering-only harness (CEO/Design not relevant) |
| Worktree parallelization strategy | Dependency table + parallel lanes for execution | Not in plan scope | N/A | Exec owns this |
| ASCII coverage diagram | Mandatory test coverage visualization | None | Minor | Low impact |
| Decision classification | Mechanical / Taste / User Challenge | No classification | Missing | Human-in-loop: only "User Challenge" needs human input |
| Degradation matrix | What to do when tools unavailable | No degradation guidance | Missing | 稳定执行: graceful degradation prevents hard failures |
| Review Readiness Dashboard | Pre-review checklist before starting | Gate check serves similar purpose | OK | Already handled |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| Confidence calibration on findings | 需求理解: surfaces uncertain assumptions for verification | HIGH |
| Decision classification (Mechanical/Taste/User Challenge) | Human-in-loop: only escalate "User Challenge" decisions | HIGH |
| Outside Voice (independent challenge agent) | 需求理解: catches blind spots in self-review | MEDIUM |
| Degradation guidance | 稳定执行: prevents hard failures when tools/context missing | LOW |

---

## 5. BMAD — `bmad-create-prd` + `bmad-create-epics-and-stories`

| Dimension | BMAD | pge-plan | Gap | Impact |
|-----------|------|----------|-----|--------|
| Micro-file sequential enforcement | Only current step in memory; no skipping | Full SKILL.md loaded at once | Different | 稳定执行: micro-files prevent context overflow but add complexity |
| SMART requirements | Specific/Measurable/Attainable/Relevant/Traceable | Acceptance criteria must be verifiable | Partial | 需求理解: SMART criteria catch vague requirements |
| Traceability chain | Vision → Success → Journeys → FRs → Epics → Stories | Intent → Issues (2-level) | Simpler | 需求理解: traceability catches dropped requirements |
| Validate-PRD skill | Separate validation skill (format, parity, density, measurability) | Self-Review inline | Partial | 稳定执行: separate validation is more thorough |
| State in frontmatter | `stepsCompleted` array tracks progress | No progress tracking in artifact | Missing | 稳定执行: resumability after interruption |
| Iron rule: HALT on gaps | "If intent gaps exist, do not fantasize, HALT and ask the human" | Self-Evaluation decides ASK_USER vs ASSUME | OK | Already handled (better — pge-plan tries to self-answer first) |
| Dual audience (human + LLM) | PRD written for both human readers and AI agents | Plan written primarily for pge-exec (agent) | OK | Intentional |
| Customization layering | `customize.toml` → project → user overrides | `.pge/config/*` serves similar purpose | OK | Already handled |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| Traceability check (requirements → issues mapping) | 需求理解: ensures every requirement has a corresponding issue | HIGH |
| Progress state in artifact (resumability) | 稳定执行: allows plan to resume after interruption | LOW |

---

## 6. OpenSpec — schema-enforced artifact chain

| Dimension | OpenSpec | pge-plan | Gap | Impact |
|-----------|---------|----------|-----|--------|
| Schema-enforced dependencies | YAML schema defines artifact order; system computes ready/blocked | Implicit ordering (research → plan → exec) | Different | 稳定执行: schema enforcement prevents out-of-order execution |
| Delta-based updates | ADDED/MODIFIED/REMOVED/RENAMED operations on specs | Plan is write-once | Different | N/A for planning (relevant for iteration) |
| Topological build order | Kahn's algorithm computes artifact readiness | Manual gate check | Simpler | OK for 3-stage pipeline |
| Filesystem-based completion | File exists = artifact complete | Route field signals completion | OK | Already handled |
| Proposal → Specs → Design → Tasks | 4-artifact chain before implementation | Research → Plan (2-stage) | Simpler | Intentional — fewer stages = less overhead |
| "Actions not phases" philosophy | Workflow is actions, not rigid phases | 4-phase model | Different | pge-plan's phases are internal structure, not user-facing |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| Schema validation of artifact completeness | 稳定执行: prevents incomplete artifacts from being consumed downstream | LOW (overkill for current pipeline size) |

---

## 7. Matt Pocock — `to-issues` + `to-prd`

| Dimension | Matt Pocock | pge-plan | Gap | Impact |
|-----------|------------|----------|-----|--------|
| Vertical slice (tracer bullet) | Each issue cuts through ALL layers end-to-end | "Vertical slices" mentioned but not enforced | Weak | 稳定执行: vertical slices are independently verifiable |
| HITL vs AFK classification | Each slice marked as needing human or not | No such classification | Missing | Human-in-loop: identifies which issues need human attention |
| Quiz the user on breakdown | Present breakdown, ask granularity/dependency questions | No user review of issue breakdown | Missing | 需求理解: user validates decomposition correctness |
| Domain glossary vocabulary | Issues use project's domain glossary | No glossary requirement | Missing | 需求理解: consistent terminology prevents misunderstanding |
| No file paths in issues | "Avoid specific file paths — they go stale fast" | Target Areas includes file paths | Conflict | Trade-off: paths help exec but go stale |
| Deep modules preference | "Extract deep modules that can be tested in isolation" | No module design guidance | Missing | 稳定执行: testable modules = verifiable execution |
| to-prd: no interview | "Do NOT interview the user — just synthesize what you already know" | Self-Evaluation minimizes questions | OK | Similar philosophy |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| HITL vs AFK classification per issue | Human-in-loop: exec knows which issues can run autonomously | HIGH |
| Enforce vertical slice rule explicitly | 稳定执行: each issue independently verifiable | MEDIUM |
| Domain glossary awareness | 需求理解: consistent terminology across pipeline | LOW |

---

## 8. HumanLayer — `create_plan`

| Dimension | HumanLayer | pge-plan | Gap | Impact |
|-----------|-----------|----------|-----|--------|
| Parallel research sub-agents | Spawns codebase-locator, codebase-analyzer, thoughts-locator, linear-ticket-reader in parallel | Phase 2 mentions multi-Agent but no named agents | Weak | 稳定执行: named agent roles reduce ambiguity |
| No open questions in final plan | "STOP. Research or ask immediately. Do NOT write plan with unresolved questions" | Self-Evaluation allows ASSUME_AND_RECORD and DEFER_TO_SLICE | Different | Trade-off: HumanLayer is stricter but more human-in-loop |
| Automated vs Manual verification split | Success criteria explicitly split into automated and manual | Verification Hint is single field | Missing | 稳定执行: exec knows what it can verify vs what needs human |
| Phase-based with human gates | "Pause here for manual confirmation before proceeding to next phase" | No inter-phase human gates | Different | Human-in-loop: HumanLayer is MORE human-in-loop (opposite of our goal) |
| Iterative plan development | Steps 1-5 with user feedback at each step | Write plan then self-review | Different | Human-in-loop: HumanLayer requires more interaction |
| Specific file:line in plan | "Include specific file paths and line numbers" | Target Areas has files, issues have Target Areas | OK | Already handled |
| "What we're NOT doing" section | Explicit out-of-scope | Non-goals section | OK | Already handled |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| Automated vs Manual verification split in issues | 稳定执行: exec knows what it can self-verify | HIGH |
| Named research agent roles (not generic "Agent") | 稳定执行: reduces agent role confusion | LOW |

---

## 9. Superpowers — `writing-plans`

| Dimension | Superpowers | pge-plan | Gap | Impact |
|-----------|------------|----------|-----|--------|
| Self-review (3 checks) | Spec coverage, placeholder scan, type consistency | Self-Review (3 checks): upstream coverage, placeholder scan, consistency | OK | Already adopted (Round 3) |
| No Placeholders (7 patterns) | 7 explicit failure patterns | 5 explicit failure patterns | Partial | Minor gap |
| Scope Check | "If spec covers multiple independent subsystems, break into separate plans" | Complexity Gate proposes phased delivery | OK | Similar mechanism |
| 2-5 minute task granularity | Each step is one action (2-5 min) | "Independently verifiable unit of work" (larger) | Different | Intentional — pge-plan produces issues, not micro-steps |
| TDD-first task structure | Red-Green-Refactor in every task | No TDD requirement | Different | Intentional — exec decides execution mode |
| File structure mapping before tasks | "Map out which files will be created or modified" before decomposition | Target Areas section | OK | Already handled |
| Worktree context | "Should be run in a dedicated worktree" | No worktree guidance | N/A | Exec concern |
| Plan document reviewer | Separate reviewer prompt for plan quality | Self-Review is inline | Partial | 需求理解: external review catches self-review blind spots |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| Expand No Placeholders to 7 patterns | 稳定执行: catches more placeholder drift | LOW |
| External plan reviewer (not just self-review) | 需求理解: independent review catches blind spots | MEDIUM (overlaps with gstack Outside Voice) |

---

## 10. agent-skills (RPI) — `/rpi:research`

| Dimension | RPI research | pge-plan | Gap | Impact |
|-----------|-------------|----------|-----|--------|
| GO/NO-GO/CONDITIONAL GO/DEFER | 4-level verdict with confidence | plan_route: 4 states (READY/NEEDS_INFO/BLOCKED/NEEDS_HUMAN) | OK | Similar mechanism |
| 6 specialist agents (serial) | requirement-parser → product-manager → Explore → senior-engineer → CTO-advisor → documentation-writer | Single agent with optional sub-agents | Different | pge-research handles this, not pge-plan |
| Code reality check | "CRITICAL: ensures based on actual code reality" | Engineering Review Existing Solutions Check | OK | Already handled |
| Confidence scoring | HIGH/MED/LOW per finding | No confidence scoring | Missing | 需求理解: low-confidence findings need verification |

**Key patterns to adopt:**

| Pattern | Benefit for 3 criteria | Priority |
|---------|----------------------|----------|
| Confidence scoring on findings (HIGH/MED/LOW) | 需求理解: surfaces uncertain assumptions | HIGH (same as gstack confidence calibration) |

---

## 11. Everything-CC

Note: `/code/3p/everything-cc/` does not exist as a separate repo. The relevant patterns from "Everything Claude Code" are already captured in gstack (which implements the multi-review pipeline).

---

## Summary: Prioritized Improvements for pge-plan

### HIGH Priority (directly addresses all 3 criteria)

| # | Pattern | Source | Criteria |
|---|---------|--------|----------|
| 1 | Multi-Source Coverage Audit | GSD | 需求理解 |
| 2 | Confidence calibration on findings/assumptions | gstack + RPI | 需求理解 |
| 3 | Decision classification (Mechanical/Taste/User Challenge) | gstack | Human-in-loop |
| 4 | HITL vs AFK classification per issue | Matt Pocock | Human-in-loop |
| 5 | Scope Reduction Prohibition (expanded) | GSD | 稳定执行 |
| 6 | Context budget awareness | GSD | 稳定执行 |
| 7 | Automated vs Manual verification split | HumanLayer | 稳定执行 |
| 8 | Traceability check (requirements → issues) | BMAD | 需求理解 |
| 9 | Depth classification (LIGHT/MEDIUM/DEEP) | CE | 稳定执行 |

### MEDIUM Priority (strengthens one criterion significantly)

| # | Pattern | Source | Criteria |
|---|---------|--------|----------|
| 10 | Goal-backward verification | GSD | 需求理解 |
| 11 | Outside Voice (independent challenge agent) | gstack | 需求理解 |
| 12 | Authority limits (3 valid reasons to escalate) | GSD | Human-in-loop |
| 13 | Interface-first ordering rule | GSD | 稳定执行 |
| 14 | Enforce vertical slice rule explicitly | Matt Pocock | 稳定执行 |
| 15 | Constitution/principles as mandatory input | Spec-Kit | 稳定执行 |
| 16 | Flow analysis for multi-module changes | CE | 需求理解 |
| 17 | Structured multi-agent research protocol | CE | 稳定执行 |

### LOW Priority (nice-to-have or handled elsewhere)

| # | Pattern | Source | Criteria |
|---|---------|--------|----------|
| 18 | Wave-based dependency for parallelism | GSD | 稳定执行 (exec owns) |
| 19 | Domain glossary awareness | Matt Pocock | 需求理解 |
| 20 | Named research agent roles | HumanLayer | 稳定执行 |
| 21 | Expand No Placeholders to 7 patterns | Superpowers | 稳定执行 |
| 22 | Schema validation of artifact completeness | OpenSpec | 稳定执行 |
| 23 | Degradation guidance | gstack | 稳定执行 |
| 24 | Progress state in artifact | BMAD | 稳定执行 |
