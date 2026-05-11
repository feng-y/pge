---
name: pge-research
description: >
  You MUST use this before pge-plan when the user's intent is still fuzzy,
  multiple approaches seem viable, the task touches unfamiliar code, or you
  are tempted to ask clarifying questions before reading the repo. Explore
  project context, resolve ambiguity from code and docs, and write a research
  brief for planning. Use this whenever intent needs to become evidence-backed
  understanding before planning.
version: 0.1.0
argument-hint: "<topic or intent>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---

# PGE Research

Turn a vague or ambiguous intent into a structured research brief through evidence-driven exploration. Start by understanding the current project context, resolve as much ambiguity as you can from code and docs, then write the brief for planning.

<HARD-GATE>
Do NOT produce plans, numbered issues, implementation code, function bodies, pseudocode, field rewiring, fallback behavior decisions, or invoke `pge-plan`. This applies even when the task feels simple. Your only output artifact is a research brief written to the task directory.
</HARD-GATE>

## Anti-Pattern: "This Is Too Simple To Need Research"

Simple tasks are where hidden assumptions waste the most time. A small request often looks obvious until you read the code and discover naming mismatches, local conventions, or nearby constraints. The research can be short, but you still need to ground it in the repo before handing anything to planning.

## Anti-Pattern: "Let Me Just Ask The User"

Asking the user is the most expensive operation in this system. Every question interrupts flow and adds latency. Before you ask anything, you should have already read the relevant code, checked docs and config, considered reasonable defaults, and decided whether one more file would answer it. If you can answer it yourself by reading one more file, do that instead.

## Anti-Pattern: "Let Me Map The Entire Codebase"

You are not writing documentation. Explore only what is relevant to the intent. Stop when your findings stabilize — when reading one more file would not change your recommendation. A focused 10-file exploration that produces clear findings beats a 50-file survey that produces vague ones.

## Anti-Pattern: "Keep Every Dead End In Main Context"

Exploration has context cost. Before loading broad evidence, ask: "Will downstream planning need this raw output, or only the conclusion?" If only the conclusion matters and the search is broad enough that delegation will reduce main-context noise, use a bounded Agent to quarantine the search. The Agent may read many files and discard dead ends; the research brief should receive only the conclusion, source paths, confidence, and caveats.

## Anti-Pattern: "Let Me Quietly Turn This Into A Plan"

Research is not planning with softer nouns. Do not start decomposing implementation work into slices, drafting numbered issues, or mentally committing to an execution order. Your job is to leave the next stage with sharper understanding, not to smuggle planning decisions into the brief.

## Anti-Pattern: "Let Me Be Helpful And Draft The Code"

Do not output implementation-shaped research. No function bodies, no method-level pseudocode, no exact field rewiring, no fallback logic, no "just sketching" the final code. If a detail has not been confirmed from the repo, record it as an assumption or open question. If a detail belongs to planning, record it as a planning note, not as code.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Load accumulated knowledge** — read `.pge/config/repo-profile.md` if exists (contains learnings from prior runs: conventions, constraints, patterns). Also search ALL `.pge/tasks-*/runs/*/learnings.md` for patterns relevant to current intent using keyword grep. Prioritize recent learnings (check dates in `[from: ...]` tags). Learnings older than 30 days: verify against current code before relying on them.
2. **Explore project context** — check files, docs, and recent commits related to the intent
3. **Check scope first** — narrow or decompose over-scoped work before researching details
4. **Scan for ambiguity** — across scope, affected areas, constraints, existing patterns, terminology, and acceptance
5. **Self-resolve** — answer what you can from code, docs, defaults, and prior learnings before asking
6. **Ask only when needed** — one at a time, grounded in evidence, and only when it improves correctness more than it adds clarification overhead
7. **Form options** — propose 1-3 approaches with evidence, tradeoffs, and recommendation only after the direction is clear enough
8. **Grill the brief** — adversarial self-challenge: cross-check terminology against code, pressure-test evidence and assumptions, detect scope drift
9. **Write research artifact** — save `research.md` to the task directory
10. **Transition to planning** — report route and point to `pge-plan`

## The Process

**Early-exit for trivial tasks:**

If after step 1 (load knowledge) and step 2 (explore context), the intent maps to a single obvious file change with no ambiguity, no competing approaches, and existing patterns clearly show how to do it — write a minimal brief immediately and skip the full exploration. A 2-line config change doesn't need 6-lens ambiguity scanning. Record: "Early exit — trivial task, single file, pattern clear from <file:line>."

**Understanding the intent:**

Check out the current project state first. Read `.pge/config/*` if it exists, especially `repo-profile.md` and `docs-policy.md`. Then look at `CLAUDE.md`, `README.md`, and the code directly related to the intent. Recent commits touching relevant areas often reveal constraints that docs miss.

Before asking detailed questions, assess scope. If the intent actually describes multiple independent subsystems, or work that clearly wants decomposition before planning, flag that immediately. Narrow it or decompose it before you spend effort researching details.

If the user explicitly signals uncertainty about the goal or scope — for example "not sure", "messy", "rethink", or "full replacement or refinement" — treat that as intent ambiguity. In that case, prefer one goal-sharpening question before you spend time comparing implementation directions.

For appropriately-scoped work, keep exploring until you can explain what the user's words map to in this codebase, what areas are likely affected, and what constraints are already visible.

If the task spans multiple independent modules, use `Agent` to explore them in parallel. For single-module work, explore directly.

**Context quarantine rule:** Consider an Agent only when exploration is broad, cross-cutting, or likely to produce many dead ends whose raw output will not be needed again. For coherent single-module work, explore directly even if it takes a few reads. Agent reports must be compact: conclusion, evidence paths, confidence, and dead ends that should not be retried. Do not paste bulk tool output into the research brief.

**Resolving ambiguity from the repo:**

Use six lenses while you explore:

- **Scope** — what to do, what not to do, where the boundaries are
- **Affected areas** — which modules, files, or interfaces will be touched
- **Constraints** — technical limits, compatibility requirements, performance needs
- **Existing patterns** — how similar things are already done here
- **Terminology** — what the user's words actually map to in the code
- **Acceptance** — how you would know the work is done correctly

Most ambiguity resolves itself once you read the code. If the code or docs answer a question, record it as a finding with a `file:line` source. If a reasonable default exists, use it and record it as an assumption with rationale. If something is uncertain but won't change the plan, note it as a non-blocking open question. Only carry a question forward when the answer would materially change planning.

Keep findings, assumptions, and open questions separate. Findings are what is true in the repo. Assumptions are what is probably safe. Open questions are what planning still cannot fairly decide alone.

**Exploring approaches:**

Once you understand the landscape, propose 1-3 approaches with tradeoffs. Present options conversationally, but anchor them in evidence. Lead with your recommended option and explain why.

Simple tasks can have one option and "proceed." Don't manufacture extra approaches just to satisfy a pattern.

**Asking questions:**

The workflow shape here follows brainstorming: ask one question at a time, keep the conversation moving, and use questions to refine understanding before handing off to planning. The questioning style itself should feel closer to grill-with-docs: challenge vague language, press on unclear intent, and do not let soft words stand in for real decisions.

Correctness matters more than clarification volume, but unnecessary clarification is still waste. Ask only when a question materially improves the correctness of what planning will inherit, and only after the repo has given you everything it can.

Do not ask repo questions the code can answer for you. Do not ask implementation-detail questions that planning can decide later. Do not ask preference questions just because uncertainty exists — uncertainty alone is not enough.

Ask one question at a time. Prefer multiple choice when possible. If a topic needs more exploration, break it into multiple questions rather than bundling them into one big prompt.

Focus questions on understanding intent, constraints, and success criteria. If the user's goal is still fuzzy, ask one goal-sharpening question before you ask direction or tradeoff questions.

Treat explicit user uncertainty as a trigger, not as a footnote. When the user says they are unsure whether the problem calls for replacement, refinement, expansion, or narrowing, do not silently choose one and move on.

Every useful question should come with what you found, why it matters, the smallest useful choice set, and your recommendation. Sometimes that is a yes/no on your recommendation. Sometimes it is 2 options. Only show 3 when 3 paths are genuinely viable. If the repo already makes the direction clear, do not ask a question just to confirm what you already know.

A strong early answer often resolves several related questions. Reassess after each answer: some follow-ups will disappear, some will shrink, and some will turn into repo questions you can answer yourself.

Stop asking when the intent is clear enough to plan fairly, or when further questions are no longer improving correctness in a meaningful way.

If critical ambiguity remains and neither the repo nor the user can resolve it fairly, return `NEEDS_INFO` or `BLOCKED` rather than passing the ambiguity downstream.

Pure semantic clarification — "what do you mean by X?" — can be asked directly without research backing.

**Working in existing codebases:**

Explore the current structure before drawing conclusions. Follow existing patterns unless there is strong evidence they are the problem.

Where existing code has issues that materially affect the work — unclear ownership, tangled responsibilities, naming drift, duplicated flows — call them out in the research. But do not turn research into a wishlist of unrelated cleanup. Stay focused on what serves the current intent.

If a local inconsistency looks ugly but doesn't change the research outcome, leave it alone. If it changes the likely approach, the risk, or the affected areas, it belongs in the brief.

**Grill the brief (adversarial self-challenge):**

Before writing the artifact, switch to adversarial mode. You are no longer the researcher — you are the skeptic trying to break the research. This is the matt-skill grill-with-docs pattern adapted for research output.

Challenge each finding:

1. **Terminology cross-check** — for every domain term in your findings, verify it matches what the code actually calls it. If you wrote "the auth middleware handles sessions" — go read the middleware file and confirm it's actually called that, does that, and nothing else. Mismatched terminology between brief and code is the #1 source of downstream plan failures.

2. **Evidence pressure** — for each finding marked as fact, can you point to a specific `file:line`? If not, downgrade to assumption. Findings without source references are opinions, not evidence.

3. **Assumption stress-test** — for each assumption, construct one scenario where it's wrong. If that scenario is plausible and would change the recommendation, the assumption needs verification or the brief needs a conditional.

4. **Option viability check** — for each proposed option, identify one concrete reason it might fail in *this* codebase (not in theory). Check: does the pattern you're recommending actually work with the existing abstractions, or are you assuming a cleaner codebase than exists?

5. **Scope drift detection** — compare your findings against the original intent. Did you quietly expand or narrow the scope during exploration? If the brief answers a different question than what was asked, fix it.

6. **Missing perspective** — what would someone who maintains this code daily say about your findings? Is there an obvious constraint you missed because you only read the happy path?

7. **Downstream simulation** — imagine pge-plan receiving this brief. Can it produce a plan without re-exploring anything? If plan would need to re-read files you already read, your findings are incomplete. If plan would need to guess which approach to take, your options section is unclear.

Fix every issue you find. If the grill reveals a finding was wrong, remove or correct it — don't leave it with a caveat. If it reveals a gap, go read one more file to fill it. The grill is a repair pass, not a findings report. One round is enough — don't loop.

## After the Research

**Documentation:**

The research artifact MUST be written only to `.pge/tasks-<slug>/research.md`. This `.pge/` path is canonical. Notes outside `.pge/` are non-authoritative and must not replace the required pipeline artifact.

Create the task directory before writing:

```bash
mkdir -p .pge/tasks-<slug>/
```

Write the research artifact to:

```text
.pge/tasks-<slug>/research.md
```

Use the template at `templates/brief.md`.

**Failure paths:**

Not every research run succeeds.

- If critical ambiguity remains and you still cannot plan fairly after repo exploration and intent clarification, set `research_route: BLOCKED`
- If the task appears infeasible from repo evidence, set `research_route: BLOCKED` and explain why in the brief
- If the user says "stop" or redirects to implementation/planning mid-run, write the best brief you can to `.pge/tasks-<slug>/research.md` and set `research_route: NEEDS_INFO` or `BLOCKED` instead of silently exiting

**Completion gate:**

Do NOT declare the research complete, summarize completion, or change routes until BOTH are true:

1. `.pge/tasks-<slug>/research.md` exists and follows `templates/brief.md`
2. You are about to output the Final Response block exactly once

If you are interrupted or the user changes direction, close the stage first by writing the best available brief. Research may end in `READY_FOR_PLAN`, `NEEDS_INFO`, or `BLOCKED`, but it must not end without a written artifact.

**Transition to planning:**

After writing the brief, output the Final Response block and explicitly tell the user to invoke `pge-plan` next. Do NOT auto-invoke `pge-plan`. Do NOT produce a plan yourself, and do NOT start decomposing the work "just to be helpful." Each pipeline stage is a separate skill invocation and the user decides when to advance.

## Key Principles

- **One question at a time** — don't overwhelm the user with bundles
- **Multiple choice preferred** — easier to answer than open-ended when possible
- **Code is truth** — prefer observed repo evidence over assumptions
- **Correctness beats clarification** — ask when it materially improves correctness
- **Defaults beat interruptions** — a reasonable assumption is often better than a question
- **Explore alternatives** — propose options when multiple real paths exist
- **Stay focused** — depth on what matters, not breadth on everything

## Research Brief Template

Use the exact template at `templates/brief.md`.

## Final Response

```md
## PGE Research Result
- task_dir: .pge/tasks-<slug>/
- research_path: .pge/tasks-<slug>/research.md
- research_route: READY_FOR_PLAN | NEEDS_INFO | BLOCKED
- options_count: <N>
- recommended: <Option name>
- questions_asked: <0-3>
- next_skill: pge-plan
```
