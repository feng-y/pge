# PGE Knowledge Design

## Why this exists

`pge-exec` should emit execution facts, not do default compound or durable knowledge promotion inline. Once that responsibility moves out of exec, `pge-knowledge` needs a clearer contract so the system does not lose reusable learnings or silently degrade repo observability.

This document defines one thing:

> `pge-knowledge` evaluates run artifacts and other knowledge candidates, then promotes only durable, evidence-backed items into repo-visible knowledge surfaces.

It is not a session handoff, not a generic memory dump, and not a second planning or review workflow.

## Target boundary

`pge-knowledge` is responsible for:

1. reading candidate knowledge inputs from approved surfaces
2. scoring candidate quality using evidence, reuse value, target fit, freshness, and safety
3. routing each candidate as `PROMOTE | NEEDS_EVIDENCE | WITHHOLD | REFRESH_EXISTING`
4. writing the smallest durable repo update when a candidate clears the gate
5. reporting stale, duplicate, or undiscoverable knowledge that should be refreshed later

`pge-knowledge` is not responsible for:
- executing the plan
- re-reviewing code correctness or plan acceptance
- acting as a temporary handoff layer
- storing every run artifact as durable knowledge
- inventing conventions that are not evidenced in code, docs, or run artifacts

## Hard rules

### 1. Evidence-first promotion
- no candidate is promoted just because it sounds useful
- every promoted item must cite a concrete source:
  - code path
  - repo doc
  - run artifact
  - command output
  - explicit user statement

### 2. Facts in, durable knowledge out
- `pge-exec` writes runtime facts
- `pge-knowledge` judges whether any of those facts deserve promotion
- raw run artifacts are evidence inputs, not durable knowledge by themselves
- default behavior is not automatic promotion inside exec's main path; knowledge evaluation happens by explicit `pge-knowledge` invocation or a separately defined post-run surface, not by silently re-expanding exec

### 3. No hidden replanning
- `pge-knowledge` may summarize or generalize
- it may not reopen plan scope, reinterpret acceptance, or decide that unfinished work is now complete

### 4. Smallest-target rule
- every promoted item must land in the narrowest durable surface future agents will naturally read
- prefer updating an existing surface over creating a new one

### 5. Discoverability over completeness theater
- a beautifully written note hidden in the wrong place is a failed output
- if future agents will not naturally find it, the candidate should be rerouted or withheld

### 6. Refresh before duplicate
- when a candidate overlaps existing knowledge, default to `REFRESH_EXISTING` or consolidate
- do not create parallel rules across `CLAUDE.md`, `.pge/config/`, skill docs, and ADRs unless the separation is semantically necessary

### 7. Safety and redaction
- never promote secrets, credentials, personal data, or unnecessarily sensitive operational details
- if a candidate is useful but overshared, redact before promotion or route `NEEDS_EVIDENCE`

## Approved inputs

### Primary inputs
- `.pge/tasks-<slug>/runs/<run_id>/manifest.md`
- `.pge/tasks-<slug>/runs/<run_id>/state.json`
- `.pge/tasks-<slug>/runs/<run_id>/evidence/`
- `.pge/tasks-<slug>/runs/<run_id>/deliverables/`
- `.pge/tasks-<slug>/runs/<run_id>/review.md` when present
- user-confirmed memory or code-summary artifacts
- relevant repo docs already considered durable surfaces

### Secondary inputs
- legacy `.pge/tasks-<slug>/runs/<run_id>/learnings.md` when present, only as candidate evidence and never as required exec output
- `.pge/handoffs/*` only as evidence of context friction, never as durable truth
- current conversation corrections when the user explicitly indicates a durable lesson

### Rejected inputs
- raw chat transcripts treated as truth without corroboration
- ephemeral task status
- speculative ideas or future wishes
- broad summaries with no concrete source path

## Required downstream interface from exec

After the exec split, `pge-knowledge` depends on exec continuing to emit a minimum artifact surface:
- `manifest`
- `state`
- `evidence`
- `deliverables`
- `review report` when the final gate runs

Removing compound from exec must not reduce this evidence surface. If these artifacts are missing or too weak, `pge-knowledge` should route `NEEDS_EVIDENCE` rather than pretending durable learnings exist.

## Candidate classes

| Candidate class | What it captures | Typical durable target |
|---|---|---|
| `context-friction` | missing instructions or poorly placed context that caused avoidable confusion | `CLAUDE.md`, `AGENTS.md`, relevant `skills/*/SKILL.md`, `.pge/config/docs-policy.md` |
| `repo-memory` | reusable repo convention or workflow rule | `.pge/config/repo-profile.md` |
| `domain-context` | stable domain term or concept relationship | `CONTEXT.md` |
| `architecture-context` | stable design decision or architectural tradeoff | `docs/adr/<YYYYMMDD>-<slug>.md` |
| `run-learning` | a reusable lesson extracted from run artifacts such as manifest, state, evidence, deliverables, review, or legacy learnings | usually `.pge/config/repo-profile.md`, sometimes a skill doc |
| `code-summary` | durable code structure or ownership map worth keeping resident | nearest relevant doc or `.pge/config/repo-profile.md` |

## Quality gate

Every candidate is scored across these dimensions:
- evidence quality
- reuse value
- specificity
- target fit
- discoverability
- deduplication
- freshness
- safety

Interpretation:
- `PROMOTE` — strong evidence, reusable, specific, correct target
- `NEEDS_EVIDENCE` — promising, but source proof or freshness is insufficient
- `WITHHOLD` — too vague, task-local, duplicative, stale, or unsafe
- `REFRESH_EXISTING` — a current durable entry is roughly right but should be updated or consolidated

A high-quality writeup is not enough. Promotion requires high-quality evidence.

## Promotion routes

### `PROMOTE`
Use when:
- the candidate is evidence-backed
- it is reusable beyond the originating run
- the destination surface is clear
- no material duplication or safety problem exists

### `NEEDS_EVIDENCE`
Use when:
- the lesson is plausible but not yet well grounded
- freshness against current code/docs is uncertain
- the candidate depends on weak or indirect artifacts

### `WITHHOLD`
Use when:
- the candidate is one-off task debris
- it duplicates existing knowledge without improving it
- it is too broad to be actionable
- it would expose sensitive information

### `REFRESH_EXISTING`
Use when:
- a durable entry already exists
- the new candidate mainly supplies better wording, clearer evidence, or updated paths
- consolidation is better than adding a new rule

## Interaction with other skills

### Upstream
- `pge-exec` produces run artifacts and execution facts
- `pge-review` may produce review findings that become evidence inputs
- `pge-handoff` remains session-only and must not be treated as durable truth

### Downstream
- repo-visible knowledge is promoted into durable surfaces such as:
  - `CLAUDE.md`
  - `AGENTS.md`
  - `.pge/config/repo-profile.md`
  - `CONTEXT.md`
  - `docs/adr/*.md`
  - relevant `skills/*/SKILL.md`

`pge-knowledge` is the quality gate before those surfaces are changed. It does not replace them.

## Trigger model

`pge-knowledge` is not part of the mandatory exec critical path.

Default expectation:
- exec completes and writes run artifacts
- knowledge promotion happens only when `pge-knowledge` is explicitly invoked, or when a future post-run hook is deliberately specified outside exec's main path
- no default inline compound step should be reintroduced into `pge-exec`

## Migration phases

### Phase 1: Freeze the boundary
Update `skills/pge-knowledge/SKILL.md` so it explicitly states:
- input surfaces
- evidence-first promotion
- routing outcomes
- relationship to exec artifacts
- prohibition on session-handoff and hidden replanning

### Phase 2: Align exec artifact expectations
Cross-check the `pge-exec` contract so the required artifact surface for knowledge intake remains explicit after compound removal.

### Phase 3: Narrow promotion targets
Make target selection stricter:
- smallest-target rule
- refresh-before-duplicate behavior
- clearer distinction between report-only candidates and promoted knowledge

### Phase 4: Verify end-to-end intake
Run a real flow:
- execute a bounded task
- confirm run artifacts exist
- run `pge-knowledge`
- verify it can correctly withhold weak candidates and promote strong ones

## Files expected to change

Primary:
- `skills/pge-knowledge/SKILL.md`

Likely related:
- `skills/pge-exec/SKILL.md`
- `.pge/config/repo-profile.md`
- `CLAUDE.md`
- `AGENTS.md`
- `CONTEXT.md`
- `docs/adr/*.md`

## Migration risks

1. **Evidence starvation**
   - exec removes compound, but does not leave enough artifact evidence for knowledge evaluation
2. **Knowledge inflation**
   - every run artifact starts getting promoted, creating noisy resident docs
3. **Wrong-surface promotion**
   - good guidance is written somewhere future agents will never naturally read
4. **Duplicate rule spread**
   - the same lesson gets copied into multiple surfaces with small wording drift
5. **Hidden replanning drift**
   - knowledge summaries start rewriting history instead of recording durable learnings

## Verification

Minimum required verification after migration:

1. a run with strong evidence in manifest/state/evidence/deliverables/review artifacts produces at least one correctly promoted durable candidate
2. a weak or task-local learning is correctly routed `WITHHOLD` or `NEEDS_EVIDENCE`
3. overlapping knowledge routes `REFRESH_EXISTING` instead of duplicating rules
4. promoted knowledge includes concrete evidence and a correct target surface
5. `pge-knowledge` does not treat `.pge/handoffs/*` as durable truth
6. removing compound and mandatory `learnings.md` from exec does not reduce the evidence needed for later knowledge extraction

## Not in scope

- replacing repo docs with a separate memory database
- storing full run history as durable knowledge
- re-running review or execution from knowledge artifacts
- broad autonomous documentation rewrites unrelated to evidenced candidates
