# PGE Learn Design

## Status

Design only. This document does not implement `pge-learn` behavior and does not create the learning output surfaces.

## Positioning

`pge-learn` should turn raw session signals and run artifacts into maintained harness knowledge.

It preserves raw learning signals as source evidence, evaluates candidates, and promotes only durable, evidence-backed knowledge into the correct surface: skills, `CLAUDE.md`, `AGENTS.md`, `.pge/config/*.md`, domain/architecture docs, or plugin metadata.

The core distinction:

- Raw memory is evidence and original signal.
- Knowledge is evaluated, reusable, target-fit guidance.
- Harness rules are promoted only into the surfaces that actually control agent behavior.

## Design Goals

1. Preserve high-value raw signals without pretending they are already rules.
2. Convert repeated friction, user corrections, and run evidence into durable knowledge when they pass a quality bar.
3. Keep resident context lean by promoting knowledge into the narrowest surface future agents will naturally read.
4. Make knowledge maintainable: every item should have source, confidence, evidence, related files, and a staleness path.
5. Prevent accidental mythology: summaries, guesses, and polished prose must not become durable truth without evidence.
6. Close the harness feedback loop: PGE executions, reviews, challenges, and user corrections should improve the harness over time.
7. Reduce human-in-the-loop burden by turning repeated clarification into harness changes, so humans make high-value decisions instead of correcting the same process ambiguity repeatedly.

## AI-Native Goal

The goal is not to make the agent remember more chat. The goal is to make the harness learn from human correction.

```text
human correction / repeated clarification
  -> friction signal
  -> decision context
  -> candidate rule or memory
  -> quality gate
  -> harness update
  -> future agent behavior improves
```

Human-in-the-loop should move up the value chain:

- keep humans in the loop for intent, product judgment, risk acceptance, and irreversible decisions;
- remove humans from repeated correction of workflow boundaries, routing, artifact expectations, and already-decided conventions.

Repeated clarification is a primary knowledge signal. `pge-learn` should diagnose what contract was unclear, preserve the decision context, and propose the narrowest durable surface that would prevent the same clarification loop in future sessions.

## Usage Scenarios

### Capture Raw Session Signals

Use when a session contains a durable correction, decision context, or agent mistake, but the correct durable target is not clear yet.

Example: the user clarifies that small PGE changes still require review, and compact review means shorter review content rather than skipping review.

Expected result: raw corpus candidate, not behavior change.

### Evaluate Run Artifacts

Use after `pge-exec`, `pge-review`, or `pge-challenge` produces evidence that may generalize beyond one task.

Example: multiple runs show the same routing ambiguity or repeated context-friction pattern.

Expected result: scored candidates with promote / needs evidence / withhold / refresh existing recommendations.

### Promote Harness Rules

Use when a candidate clearly changes how PGE should run.

Example: `pge-exec SUCCESS` means Execute stage complete, not workflow complete; normal next stage is `pge-review`.

Expected result: update the controlling skill or resident rule surface, not a generic memory entry.

### Maintain Existing Knowledge

Use periodically or after harness changes to find stale entries, duplicates, contradictions, unsafe details, and undiscoverable memory.

Expected result: report-only prune recommendations unless the user approves edits.

### Export Context For A Consumer

Use when another workflow needs a compact digest of relevant knowledge.

Example consumers: `CLAUDE.md`, `AGENTS.md`, planning handoff, review handoff, or repo profile.

Expected result: audience-specific digest, not a bulk dump.

## Inputs

Primary inputs:

- current session signals, especially user corrections and explicit preferences;
- `.pge/tasks-*/runs/*/{manifest.md,state.json,evidence/,deliverables/,review.md}`;
- `.pge/tasks-*/review.md` and `.pge/tasks-*/challenge.md`;
- existing `CLAUDE.md`, `AGENTS.md`, `README.md`, skills, `.pge/config/*.md`, and docs;
- user-supplied memory or code summaries;
- prior raw learning ledger entries and promoted repo knowledge, once those surfaces exist.

Input requirements:

- Every candidate must keep a source path, command, artifact, commit, or user statement.
- Claims based only on inference must be marked as inferred and lower confidence.
- Sensitive data must be redacted before capture or promotion.
- Broad research notes should not be bulk-ingested unless a candidate explicitly depends on them.

## Outputs

`pge-learn` should produce one of four output classes.

### Raw Corpus

Purpose: preserve original signal and evidence.

Future target:

```text
.pge/learn/learnings.jsonl
```

This output is not direct instruction.

### Candidate Report

Purpose: show extracted candidates and their quality.

Shape:

```markdown
### <candidate>
- type: <candidate type>
- source: user-stated | observed | inferred | cross-model | run-artifact
- confidence: <1-10>
- proposed_target: <path or withhold>
- quality_score: <0-16>
- verdict: promote | needs_evidence | withhold | refresh_existing
- evidence: <paths / commands / artifacts / user statement>
- files: <paths for staleness checks>
- reason: <why this helps future agents>
- risk: <duplication / staleness / privacy / over-broad summary>
```

### Promoted Knowledge

Purpose: update the surface that should govern future behavior.

Targets:

- `skills/*/SKILL.md` for workflow behavior;
- `CLAUDE.md` / `AGENTS.md` for resident invariants and routing;
- `.pge/config/*.md` for repo profile or docs policy;
- nearest relevant repo docs for stable repo memory that belongs outside `.pge/config`;
- `CONTEXT.md` / `docs/adr/` for domain and architecture knowledge;
- `.claude-plugin/plugin.json` for distribution metadata.

### Maintenance Report

Purpose: keep memory healthy.

Includes:

- stale files or commands;
- contradictions;
- duplicates;
- unsafe or private details;
- undiscoverable entries;
- raw items already promoted;
- stats by type/source/confidence.

## Follow-On Workflow

The intended flow is:

```text
1. Capture
   Preserve valuable raw signal only when it may matter later.

2. Evaluate
   Extract candidates from raw signals, run artifacts, and existing docs.

3. Decide
   Promote, withhold, request more evidence, or refresh an existing entry.

4. Promote
   Write the smallest durable change to the controlling surface.

5. Verify
   Check that the promoted target is discoverable and does not contradict existing rules.

6. Maintain
   Search, prune, export, and review stats over time.
```

Backflow rules:

- If knowledge changes workflow behavior, route the durable change to the relevant skill and consider plugin version impact.
- If knowledge changes planning or execution contracts, later PGE runs should consume it through the canonical skill or plan surface, not raw memory.
- If knowledge is only source evidence, keep it raw and do not expose it as resident instruction.

## Prior Art

### `note`

`note` is a short-term working-memory mechanism for compaction resilience. It has priority, working, and manual sections, and explicitly trades context budget for continuity.

PGE should not copy this as durable knowledge. The useful boundary is that not all remembered context deserves promotion into resident instructions.

Alignment to AI-native goal:

- useful for short-term continuity;
- not sufficient for reducing repeated human correction across sessions;
- teaches PGE that transient memory and durable harness knowledge must stay separate.

### `gstack/learn`

`gstack/learn` manages searchable project learnings backed by JSONL. Its useful model is metadata:

- `type`
- `key`
- `insight`
- `confidence`
- `source`
- `files`

It also supports search, prune, export, stats, and manual add. PGE should borrow the metadata and maintenance commands, but keep storage repo-local and evidence-backed rather than user-global.

Alignment to AI-native goal:

- provides the maintenance verbs PGE needs: search, prune, export, stats, add;
- provides a confidence/source/files model for staleness and trust;
- PGE should strengthen it with target-fit scoring and promotion into controlling harness surfaces.

### `gstack/retro`

`gstack/retro` captures learnings only when they are genuine discoveries that would save future time. Its useful constraint is the capture bar:

- do not log obvious things;
- distinguish user-stated, observed, inferred, and cross-model sources;
- include files for staleness detection.

PGE should apply this bar before raw capture and again before promotion.

Alignment to AI-native goal:

- distinguishes real learning from noisy session residue;
- gives PGE a capture threshold: save only discoveries that would reduce future work or repeated clarification;
- encourages file-linked evidence so knowledge can be invalidated when the repo changes.

### `document-release`

`document-release` audits docs against shipped diffs and checks discoverability. Its useful model is cross-doc consistency: durable knowledge must be reachable from the surfaces future agents actually read.

PGE should treat undiscoverable knowledge as low quality even when the content is true.

Alignment to AI-native goal:

- prevents correct knowledge from becoming useless because future agents cannot find it;
- suggests every promoted item needs a discoverability check against `CLAUDE.md`, `AGENTS.md`, skills, docs, or config.

### `harness-audit` / `harness-evolve`

These skills treat docs, constraints, and cleanup as harness quality. `pge-learn` should be the memory-to-harness maintenance layer: it feeds durable discoveries into the harness and helps prune stale knowledge.

Alignment to AI-native goal:

- turns knowledge maintenance into recurring harness quality work;
- treats stale docs, duplicated rules, and ambiguous contracts as sources of future human interruption;
- gives PGE a reason to score and evolve knowledge surfaces, not just append entries.

## Capability Alignment

| Capability | Source Skill Model | PGE Learn Adaptation | Human-in-the-loop Reduction |
|---|---|---|---|
| Short-term continuity | `note` | Explicitly separate temporary context from durable knowledge | Avoids bloating resident context while preserving current-session continuity |
| Learning metadata | `gstack/learn` | Type/source/confidence/files/evidence metadata | Lets agents trust, search, and invalidate knowledge without asking humans |
| Genuine discovery threshold | `gstack/retro` | Capture only non-obvious signals that save future time | Prevents noise from becoming future confusion |
| Search/prune/export/stats | `gstack/learn` | Maintenance commands over repo-local memory surfaces | Lets agents self-serve prior knowledge and clean stale entries |
| Discoverability audit | `document-release` | Promoted knowledge must be reachable from natural entry points | Reduces repeated "where was this documented?" clarification |
| Harness quality loop | `harness-audit` / `harness-evolve` | Treat knowledge drift as harness debt | Makes repeated clarification a fixable system defect |
| User correction handling | `retro` source model | Mark direct corrections as `user-stated` with high confidence, but still score target fit | Preserves human decisions while avoiding over-promotion |

## Pipeline

```text
session signals / run artifacts / agent corrections
  -> raw corpus candidate
  -> candidate extraction
  -> quality scoring
  -> promotion decision
  -> target-specific durable surface
  -> maintenance: search, prune, export, stats
```

## Raw Corpus

Raw corpus should preserve original signals before interpretation. Examples:

- user corrections;
- decision context;
- agent mistakes or misread workflow assumptions;
- run artifacts that expose reusable patterns;
- original language that should remain traceable.

Raw corpus is not direct agent instruction. A future agent may use it as evidence, but behavior changes require promotion.

Proposed future surface:

```text
.pge/learn/learnings.jsonl
```

Required raw metadata:

```yaml
type: raw-session-signal | run-learning | context-friction
source: user-stated | observed | inferred | cross-model | run-artifact
confidence: 1-10
files:
  - path/to/relevant-file
evidence:
  - path / command / commit / artifact
created: YYYY-MM-DD
```

## Candidate Types

| Type | Meaning | Likely Target |
|---|---|---|
| `raw-session-signal` | Original signal worth preserving | `.pge/learn/learnings.jsonl` |
| `context-friction` | Missing or misplaced context caused agent confusion | `CLAUDE.md`, `AGENTS.md`, relevant skill, docs policy |
| `harness-rule` | Stable workflow or agent behavior rule | relevant skill, `CLAUDE.md`, `AGENTS.md`, plugin metadata |
| `repo-memory` | Durable convention or recurring repo pattern | `.pge/config/repo-profile.md` or nearest relevant repo doc |
| `domain-context` | Stable vocabulary or concept relation | `CONTEXT.md` |
| `architecture-context` | Stable design decision or trade-off | `docs/adr/` |
| `code-summary` | Stable structure or ownership map | nearest relevant doc or repo profile |
| `run-learning` | Reusable lesson from PGE artifacts | repo profile, skill, or memory entry |

## Quality Gates

Promotion requires more than being well written. A candidate should be scored on:

- evidence;
- reuse;
- specificity;
- target fit;
- discoverability;
- deduplication;
- freshness;
- safety.

Suggested interpretation:

- `14-16`: promote, unless report-only;
- `10-13`: keep as candidate or gather evidence;
- `<10`: withhold.

## Promotion Rules

Promotion should write the smallest durable entry into the narrowest correct surface.

Examples:

- Workflow behavior belongs in the relevant `skills/*/SKILL.md`.
- Global resident behavior belongs in `CLAUDE.md` or `AGENTS.md`.
- Stable repo memory belongs in `.pge/config/repo-profile.md` or the nearest relevant repo doc.
- Raw evidence stays in `.pge/learn/learnings.jsonl`.
- Distribution metadata belongs in `.claude-plugin/plugin.json`.

Promotion must not turn raw notes into resident instructions by accident.

## Commands To Design

### `capture`

Preserve raw source corpus. It should not promote behavior rules.

### `evaluate`

Read relevant raw corpus, run artifacts, and docs. Extract candidates, score them, and recommend promote / needs evidence / withhold / refresh existing.

### `search`

Search raw and promoted knowledge with source, confidence, and staleness context.

### `prune`

Detect stale files, contradictions, duplicates, unsafe details, and promoted raw items. Default to report-only.

### `export`

Produce consumer-specific digests for resident rules, planning, handoff, or repo knowledge surfaces.

### `stats`

Report raw vs entry counts, confidence distribution, stale risk, duplicate risk, and undiscoverable knowledge.

### `add`

Treat user text as an untrusted candidate. Score before writing.

## Non-Goals

- Not session continuation. Use `pge-handoff`.
- Not a global memory database.
- Not a transcript archive.
- Not automatic promotion of summaries.
- Not a replacement for `pge-review`, `pge-challenge`, or docs release sync.

## Open Design Questions

- Should raw corpus be created opportunistically by `pge-learn capture`, or only when explicitly requested?
- Should promoted repo knowledge be read by default, or only through `pge-learn search/evaluate`?
- What is the retention policy for raw ledger entries after their candidates are promoted?
- Should run artifacts reference promoted knowledge back-links?
- Should plugin version bumps be required when harness rules change?
