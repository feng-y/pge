---
name: pge-learn
description: >
  Learn from context friction, agent memory, code summaries, and run artifacts.
  Captures workspace-local learning candidates first; only promotes high-quality,
  evidence-backed items to durable repo docs. Use when reviewing recent work for
  repeated workflow, recurring manual work, skill hygiene, automation opportunity,
  asset duplication, or evidence-backed learning promotion.
argument-hint: "<learn|evaluate|workflow-mining|search|recent|prune|export|stats|add> <optional focus>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
---

# PGE Learn

Turn what the agent learned about working in this repo into durable, quality-checked repo knowledge.

`pge-learn` is the canonical PGE surface for learning capture and promotion. The `learn` command is the default capture intent inside this skill, not a separate workflow authority. The skill must preserve the knowledge promotion gate: raw learning is not durable truth until it passes evidence, reuse, specificity, target-fit, discoverability, deduplication, freshness, and safety checks.

This is not a handoff and not a generic "save everything we learned" command. It focuses on two sources:

1. **Context friction** — places where the agent struggled because the right context was missing, hidden, duplicated, stale, or hard to discover.
2. **Memory / code summaries** — agent-produced summaries of project memory, code structure, patterns, or run artifacts that may deserve promotion into repo docs.

The default output is a quality assessment. Promotion to durable docs happens only for candidates that are specific, evidence-backed, reusable, non-duplicative, and discoverable.

It also supports **workflow-mining**: review recent local workspace evidence to find repeated manual workflows and recommend the smallest reusable asset. Mine evidence first, package the smallest useful form, and default to no writes.

It also manages existing repo knowledge at a lightweight level: review, search, prune stale items, export a digest, show stats, or manually add a quality-scored candidate. PGE stores durable knowledge in repo docs, not a global memory database. Raw learning candidates may be kept in a workspace-local ledger only as source evidence.

## When To Use

- The agent repeatedly reread files, forgot constraints, chose the wrong source, or needed user correction because context was unclear.
- A run produced manifest, evidence, deliverables, review findings, or legacy `learnings.md`, but it is unclear which candidates deserve promotion.
- A memory or code summary exists and needs review before becoming repo knowledge.
- You want to inspect whether existing repo knowledge is stale, noisy, duplicated, or undiscoverable.
- The user says the agent's summary captured an important pattern, but quality should be checked first.
- Recent work suggests repeated manual workflow, skill/agent/command duplication, skill hygiene issues, or small automation opportunities.
- Before creating a new skill, agent, command, hook, script, CI check, or scheduled automation proposal.

Do not use this for session continuation. Use `pge-handoff` for temporary task handoff between sessions.
Do not use workflow-mining for one-off summaries, generic brainstorming, or deterministic checks that should go directly to a script, hook, or CI check.

## Commands

Parse `ARGUMENTS:`:

- `learn <text|focus>`: extract and score learning candidates, then append useful non-promoted candidates to the raw learning ledger. This is an alias for evaluate-plus-capture, not automatic promotion.
- `evaluate` or no command: extract and quality-score candidates from the current context, memory/code summaries, raw learning ledger, and relevant run artifacts.
- `workflow-mining <focus>`: inventory existing reusable assets, mine recent local evidence for repeated manual workflows, then report the smallest recommended form. Default is review-only.
- `recent [n]`: show recent raw and promoted learnings with status, confidence, source, and target.
- `search <query>`: search raw learning candidates and existing repo knowledge for a phrase, task, file, convention, or friction pattern.
- `prune`: find stale, contradictory, duplicated, unsafe, or undiscoverable raw/promoted knowledge. Report recommended edits; do not delete without explicit approval.
- `export`: produce a concise markdown digest suitable for `CLAUDE.md`, `AGENTS.md`, `.pge/config/repo-profile.md`, or a planning handoff.
- `stats`: summarize knowledge health by raw/promoted status, target, candidate type, confidence, stale-risk, and discoverability.
- `add <text>`: treat the user's text as a candidate, score it with the rubric, record it as raw learning when useful, then promote only if it passes.

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
| `workflow-candidate` | Repeated manual procedure or asset duplication opportunity | extend existing, doc/checklist, skill, subagent, command, script/hook/CI, scheduled automation proposal, or skip |

Avoid creating new knowledge locations unless an existing entry point would naturally point future agents there.

## Learning Sources

Search and manage these sources, in this order:

1. `CLAUDE.md`, `AGENTS.md`, `README.md`
2. `.pge/config/*.md`
3. `CONTEXT.md`, `CONTEXT-MAP.md`
4. `docs/adr/*.md`
5. relevant `skills/*/SKILL.md`
6. `.pge/learn/learnings.jsonl` as raw candidate evidence, when present
7. `.pge/tasks-*/runs/*/{manifest.md,state.json,evidence/,deliverables/,review.md}`
8. legacy `.pge/tasks-*/runs/*/learnings.md` when present, as candidate evidence only
9. Explicitly supplied handoff artifacts only for context-friction evidence, never as durable truth

For each discovered item, keep its source path. If the source cannot be found again, mark the item as weak or stale instead of relying on it.

## Raw Learning Ledger

Use `.pge/learn/learnings.jsonl` as an optional workspace-local candidate ledger. `.pge/` is ignored workflow state, so this ledger is local to the current checkout unless exported or promoted elsewhere. It is inspired by project learning logs, but in PGE it is **not** a durable knowledge surface and must not be read as an instruction source.

Append one JSON object per candidate:

```json
{
  "id": "learn-<YYYYMMDD>-<short-slug>",
  "created_at": "YYYY-MM-DD",
  "status": "raw | promoted | withheld | stale | duplicate",
  "type": "context-friction | repo-memory | domain-context | architecture-context | code-summary | run-learning | workflow-candidate",
  "summary": "<one sentence>",
  "trigger": "<when future agents should care>",
  "guidance": "<what future agents should do>",
  "source": ["<path, command, artifact, or user statement>"],
  "files": ["<relevant repo paths>"],
  "confidence": "low | medium | high",
  "quality_score": 0,
  "target": "<proposed durable target or withhold>",
  "promoted_to": "<path or null>",
  "stale_after": "<optional condition, date, or file path>"
}
```

Rules:
- Raw entries may preserve useful learning before the correct durable target is clear.
- Raw entries are searchable evidence, not execution instructions.
- Score candidates before appending when practical. If evidence is discovered later, append a superseding entry rather than leaving `quality_score` unknown.
- Promotion must update `status` or report the intended status update. Do not leave promoted items looking raw.
- Prefer appending a superseding entry over rewriting history unless the edit is a small metadata fix.
- Do not store secrets, private data, raw logs, or broad session transcripts.

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
- `.pge/learn/learnings.jsonl` when learning history is relevant
- `.pge/tasks-*/runs/*/{manifest.md,state.json,evidence/,deliverables/,review.md}` relevant to the focus
- legacy `.pge/tasks-*/runs/*/learnings.md` relevant to the focus, when present
- explicitly supplied handoff artifacts only when reviewing context friction, not as truth
- User-supplied memory or code-summary files
- Code/docs paths cited by the candidate

Do not bulk-ingest broad research notes unless the candidate explicitly depends on them.

For `workflow-mining`, gather in this order:

1. Existing reusable assets: `skills/`, `.claude/skills/`, `agents/`, `.claude/agents/`, `commands/`, `.claude/commands/`, `scripts/`, hooks, CI, Makefile/package scripts, process docs, and relevant checklists.
2. Recent local evidence: current diff, recent commits, `.pge/tasks-*/`, run manifests/state/review/challenge artifacts, raw learning ledger, and recent progress/status docs.
3. Only the nearest files needed to confirm recurrence, overlap, and validation. Do not turn mining into broad repo archaeology.

### 2. Extract Candidates

Look for:

- User corrections that reveal missing resident context
- Repeated tool/search loops that a better doc would have avoided
- Ambiguous handoffs or source-selection friction
- Useful run artifact candidates that recur beyond one task
- Code summaries that identify stable ownership, flow, or convention
- Memory entries that are valuable but currently private, hidden, or not discoverable by future agents
- Raw learning entries whose status should be promoted, withheld, marked stale, or deduplicated

Ignore:

- Ephemeral task progress
- Raw command logs
- Speculative ideas
- Preferences that apply only to one chat
- Implementation details already obvious from nearby code

For workflow-mining, distinguish repeated topics from repeated workflows. A topic recurring in reports is not enough; there must be a repeatable procedure, recurring manual correction, recurring asset choice, or deterministic check opportunity.

### 3. Evaluate Quality

For each candidate, produce:

```markdown
### <candidate title>
- type: context-friction | repo-memory | domain-context | architecture-context | code-summary | run-learning | workflow-candidate
- proposed_target: <path or "withhold">
- quality_score: <0-16>
- verdict: promote | needs_evidence | withhold | refresh_existing
- evidence: <paths/commands/user statement/run artifact>
- reason: <why this helps future agents>
- risk: <duplication/staleness/privacy/over-broad summary risk>
```

For workflow candidates, apply these gates before recommending a new asset:

| Gate | Pass condition |
|---|---|
| Recurrence | happened at least twice, or clearly costly and likely to recur |
| Shape | stable inputs, repeatable procedure, clear output and stop condition |
| Value | improves speed, quality, consistency, reliability, or reviewability |
| Coverage | not already adequately covered by an existing asset |
| Scope | narrow, non-overlapping, and testable |

Recommend the smallest form in this order:

1. extend existing
2. doc/checklist
3. skill
4. subagent
5. command
6. script/hook/CI
7. scheduled automation proposal
8. skip

Use scripts, hooks, or CI for deterministic checks. Use skills for reusable judgment-heavy techniques. Use subagents only when independent review or a distinct role is valuable. Use scheduled automation only as a proposal unless the user explicitly asks to create it.

Workflow-mining output must be a compact shortlist:

```markdown
### <workflow>
- evidence: <paths/artifacts/commands>
- frequency_confidence: <low|medium|high>
- recommended_form: <extend existing|doc/checklist|skill|subagent|command|script/hook/CI|scheduled automation proposal|skip>
- why: <smallest-form rationale>
- trigger: <when future agents should use it>
- output_stop_condition: <expected output and when to stop>
- validation: <test, review, checklist, smoke, or proof path>
- overlap_risk: <existing asset overlap or "low">
```

Default workflow-mining is review-only: do not write files. Write only when the user explicitly asks for the durable change and the candidate is high confidence. Never implement discovered assets in the same pass unless the user explicitly requests it.

Common workflow-mining mistakes:

| Mistake | Correction |
|---|---|
| repeated topic treated as workflow | require a repeatable procedure and stop condition |
| duplicated existing skill | inventory assets first and prefer extension |
| project-specific convention promoted globally | keep repo conventions in repo docs or the owning PGE skill |
| broad catch-all skill created | narrow to one trigger, input shape, and output |
| deterministic check assigned to agent/skill | route to script, hook, or CI |
| files changed during review-only mode | report recommendations only |
| no validation path | withhold or mark needs evidence |

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

When promoting from `.pge/learn/learnings.jsonl`, include the raw learning id in the durable entry evidence so the source can be traced and invalidated later.

### 5. Refresh Existing Knowledge

If a candidate contradicts or overlaps an existing entry:

- **Keep**: current entry still accurate.
- **Update**: current entry is right but needs clearer evidence or current paths.
- **Consolidate**: two entries say the same thing; keep one.
- **Mark stale**: likely outdated but evidence is insufficient to rewrite.
- **Recommend deletion**: only when clearly obsolete; do not delete without explicit user approval.

## Management Commands

### Search

Return matching entries grouped by source path. Include raw learning status, matching phrase, candidate type if obvious, confidence if recorded, and whether the entry appears current.

### Recent

Show the latest raw and promoted learning items. Include:

- id
- status
- summary
- type
- quality score / confidence
- source
- proposed or promoted target

Default to the latest 10 entries. If the raw ledger is absent, say so and fall back to recently changed durable knowledge surfaces when useful.

### Prune

Review existing knowledge for:

- stale paths or commands
- duplicate entries across surfaces
- vague rules with no trigger/action
- raw entries that were promoted but not marked
- raw entries that have no evidence or no future trigger
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

- total raw and promoted entries by source
- high/medium/low confidence counts when available
- stale-risk count
- duplicate-risk count
- undiscoverable count
- raw entries lacking target or evidence
- top 3 surfaces that need cleanup

### Add

Treat user-provided text as an untrusted candidate. Score it with the rubric before writing. If it scores below 14, report the missing evidence instead of promoting it.
If the text is useful but not yet promotable, append it to `.pge/learn/learnings.jsonl` as `status: raw` only when it has at least one concrete source or user statement.

## Final Response

```md
## PGE Learn Result
- route: PROMOTED | REPORT_ONLY | EMPTY | DEGRADED
- command: learn | evaluate | recent | search | prune | export | stats | add
- candidates_reviewed: <count>
- raw_captured: <count>
- promoted: <count>
- needs_evidence: <count>
- withheld: <count>
- refresh_recommended: yes | no — <reason>
- targets: <paths changed or "none">
- next: <suggested next action>
```
