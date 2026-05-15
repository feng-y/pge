---
name: pge-knowledge
description: >
  Evaluate and extract repo knowledge from context friction, agent memory, code
  summaries, and run artifacts. Produces quality-scored candidates first; only
  promotes high-quality, evidence-backed items to durable repo docs.
argument-hint: "<evaluate|search|prune|export|stats|add> <optional focus>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# PGE Knowledge

Turn what the agent learned about working in this repo into durable, quality-checked repo knowledge.

This is not a handoff and not a generic "save everything we learned" command. It focuses on two sources:

1. **Context friction** — places where the agent struggled because the right context was missing, hidden, duplicated, stale, or hard to discover.
2. **Memory / code summaries** — agent-produced summaries of project memory, code structure, patterns, or run artifacts that may deserve promotion into repo docs.

The default output is a quality assessment. Promotion to durable docs happens only for candidates that are specific, evidence-backed, reusable, non-duplicative, and discoverable.

It also manages existing repo knowledge at a lightweight level: review, search, prune stale items, export a digest, show stats, or manually add a quality-scored candidate. PGE stores knowledge in repo docs, not a global memory database.

## When To Use

- The agent repeatedly reread files, forgot constraints, chose the wrong source, or needed user correction because context was unclear.
- A run produced manifest, evidence, deliverables, review findings, or legacy `learnings.md`, but it is unclear which candidates deserve promotion.
- A memory or code summary exists and needs review before becoming repo knowledge.
- You want to inspect whether existing repo knowledge is stale, noisy, duplicated, or undiscoverable.
- The user says the agent's summary captured an important pattern, but quality should be checked first.

Do not use this for session continuation. Use `pge-handoff` for temporary transfer between sessions.

## Commands

Parse `ARGUMENTS:`:

- `evaluate` or no command: extract and quality-score candidates from the current context, memory/code summaries, and relevant run artifacts.
- `search <query>`: search existing repo knowledge for a phrase, task, file, convention, or friction pattern.
- `prune`: find stale, contradictory, duplicated, or undiscoverable knowledge. Report recommended edits; do not delete without explicit approval.
- `export`: produce a concise markdown digest suitable for `CLAUDE.md`, `AGENTS.md`, `.pge/config/repo-profile.md`, or a planning handoff.
- `stats`: summarize knowledge health by target, candidate type, confidence, stale-risk, and discoverability.
- `add <text>`: treat the user's text as a candidate, score it with the rubric, then promote only if it passes.

If a command is ambiguous, default to `evaluate` and say what was assumed.

## Candidate Types

| Type | What It Captures | Possible Target |
|---|---|---|
| `context-friction` | Missing or poorly placed context that caused agent confusion | `CLAUDE.md`, `AGENTS.md`, relevant skill, or `.pge/config/docs-policy.md` |
| `repo-memory` | Durable repo conventions discovered from prior runs or memory artifacts | `.pge/config/repo-profile.md` |
| `domain-context` | Stable domain vocabulary or concept relationships | `CONTEXT.md` |
| `architecture-context` | Stable architecture decision or trade-off | `docs/adr/<YYYYMMDD>-<slug>.md` |
| `code-summary` | A compact map of code structure, ownership, or recurring patterns | nearest relevant doc, `.pge/config/repo-profile.md`, or withheld if too broad |
| `run-learning` | A reusable learning from `.pge/tasks-*/runs/*/{manifest.md,state.json,evidence/,deliverables/,review.md}` or legacy `learnings.md` | usually `.pge/config/repo-profile.md`, sometimes a skill rule |

Avoid creating new knowledge locations unless an existing entry point would naturally point future agents there.

## Knowledge Surface

Search and manage these sources, in this order:

1. `CLAUDE.md`, `AGENTS.md`, `README.md`
2. `.pge/config/*.md`
3. `CONTEXT.md`, `CONTEXT-MAP.md`
4. `docs/adr/*.md`
5. relevant `skills/*/SKILL.md`
6. `.pge/tasks-*/runs/*/{manifest.md,state.json,evidence/,deliverables/,review.md}`
7. legacy `.pge/tasks-*/runs/*/learnings.md` when present, as candidate evidence only
8. `.pge/handoffs/*` only for context-friction evidence, never as durable truth

For each discovered item, keep its source path. If the source cannot be found again, mark the item as weak or stale instead of relying on it.

## Quality Rubric

Score every candidate from 0-2 on each dimension:

| Dimension | 0 | 1 | 2 |
|---|---|---|---|
| Evidence | no source | plausible but indirect | concrete path, command, artifact, code, or user statement |
| Reuse | one-off task detail | likely useful in nearby tasks | broadly useful for future work in this repo |
| Specificity | vague advice | partially actionable | concrete trigger + action |
| Target fit | wrong layer | acceptable layer | narrowest durable layer |
| Discoverability | future agent unlikely to find it | findable with effort | naturally read before needed |
| Deduplication | duplicates existing knowledge | overlaps but adds nuance | distinct or cleanly updates existing item |
| Freshness | likely stale | unknown | matches current code/docs |
| Safety | may expose secret/private data | needs redaction | safe and minimal |

Interpretation:
- `14-16`: promote, unless the user asked for report-only.
- `10-13`: report as candidate; ask or gather more evidence before promoting.
- `<10`: withhold; explain what failed.

Do not promote low-confidence summaries just because they are well-written. A polished hallucination is worse than no memory.

## Process

### 1. Gather Inputs

Read only relevant sources:

- Current conversation context
- `CLAUDE.md`, `AGENTS.md`, `README.md`
- `.pge/config/*.md` if present
- `.pge/tasks-*/runs/*/{manifest.md,state.json,evidence/,deliverables/,review.md}` relevant to the focus
- legacy `.pge/tasks-*/runs/*/learnings.md` relevant to the focus, when present
- `.pge/handoffs/*` only when reviewing context friction, not as truth
- User-supplied memory or code-summary files
- Code/docs paths cited by the candidate

Do not bulk-ingest broad research notes unless the candidate explicitly depends on them.

### 2. Extract Candidates

Look for:

- User corrections that reveal missing resident context
- Repeated tool/search loops that a better doc would have avoided
- Ambiguous handoffs or source-selection friction
- Useful run artifact candidates that recur beyond one task
- Code summaries that identify stable ownership, flow, or convention
- Memory entries that are valuable but currently private, hidden, or not discoverable by future agents

Ignore:

- Ephemeral task progress
- Raw command logs
- Speculative ideas
- Preferences that apply only to one chat
- Implementation details already obvious from nearby code

### 3. Evaluate Quality

For each candidate, produce:

```markdown
### <candidate title>
- type: context-friction | repo-memory | domain-context | architecture-context | code-summary | run-learning
- proposed_target: <path or "withhold">
- quality_score: <0-16>
- verdict: promote | needs_evidence | withhold | refresh_existing
- evidence: <paths/commands/user statement/run artifact>
- reason: <why this helps future agents>
- risk: <duplication/staleness/privacy/over-broad summary risk>
```

### 4. Promote Carefully

Only write when verdict is `promote` and the target is clear.

Write the smallest durable entry:

```markdown
- <trigger/context> → <guidance/action> — evidence: <path/command/artifact> — confidence: <medium|high> — [extracted: <YYYY-MM-DD>]
```

For context friction, prefer improving the place future agents already read:

- `CLAUDE.md` for resident behavior rules
- `AGENTS.md` for routing/invariant pointers
- the relevant `skills/*/SKILL.md` when the friction belongs to one workflow
- `.pge/config/docs-policy.md` for documentation lookup policy

For memory or code summaries, prefer `.pge/config/repo-profile.md` unless the knowledge is domain or architecture specific.

### 5. Refresh Existing Knowledge

If a candidate contradicts or overlaps an existing entry:

- **Keep**: current entry still accurate.
- **Update**: current entry is right but needs clearer evidence or current paths.
- **Consolidate**: two entries say the same thing; keep one.
- **Mark stale**: likely outdated but evidence is insufficient to rewrite.
- **Recommend deletion**: only when clearly obsolete; do not delete without explicit user approval.

## Management Commands

### Search

Return matching entries grouped by source path. Include the matching phrase, candidate type if obvious, confidence if recorded, and whether the entry appears current.

### Prune

Review existing knowledge for:

- stale paths or commands
- duplicate entries across surfaces
- vague rules with no trigger/action
- entries that future agents would not naturally discover
- private or sensitive details that should be redacted

Default to report-only. Apply edits only when the fix is small, clear, and non-destructive. Never delete without explicit user approval.

### Export

Create a compact digest from existing knowledge. The export should preserve source paths and confidence, and should be tailored to the requested consumer:

- `CLAUDE.md`: resident rules and high-signal friction fixes
- `AGENTS.md`: routing and invariant pointers
- `.pge/config/repo-profile.md`: repo conventions and code-summary patterns
- handoff/planning: only the few items needed for the next task

### Stats

Report:

- total candidate entries by source
- high/medium/low confidence counts when available
- stale-risk count
- duplicate-risk count
- undiscoverable count
- top 3 surfaces that need cleanup

### Add

Treat user-provided text as an untrusted candidate. Score it with the rubric before writing. If it scores below 14, report the missing evidence instead of promoting it.

## Final Response

```md
## PGE Knowledge Result
- route: PROMOTED | REPORT_ONLY | EMPTY | DEGRADED
- command: evaluate | search | prune | export | stats | add
- candidates_reviewed: <count>
- promoted: <count>
- needs_evidence: <count>
- withheld: <count>
- refresh_recommended: yes | no — <reason>
- targets: <paths changed or "none">
- next: <suggested next action>
```
