# PGE HTML Template Contracts

Templates are not decorative skins. Each template must replace a concrete cognition task.

Every generated page must answer:
- What should the reader understand or decide faster?
- What should they look at first?
- What evidence supports the claims?
- What should a future agent avoid or verify?

## Common Quality Gate

All styles must include:
- **Cognitive job**: a one-sentence statement near the top.
- **Orientation**: start-here rail, summary strip, or first-read path list.
- **Visual structure**: diagram, grid, timeline, comparison, dashboard, annotated diff, or map.
- **Evidence surface**: source paths, commands, confidence, or provenance.
- **Responsive layout**: dense grids collapse on small screens.
- **No placeholder residue**: no TODO, TBD, lorem ipsum, placeholder comments, or fake external links.
- **Escaped source content**: no source-derived `innerHTML`.

## minimal

Use for a short human-readable page where visual structure would add noise.

Required:
- title
- source / provenance
- clean prose layout
- anchorable headings
- no decorative cards unless they frame a real repeated item

Fails if:
- it adds interaction without a job
- it hides source paths or provenance

## rich / implementation-plan

Cognitive job: understand what will be executed, in what order, and how done will be proven.

Required:
- plan objective and stop condition at top
- issue/slice timeline or board
- dependency map or ordered execution path
- acceptance criteria per issue
- verification/evidence checklist
- risk and rollback section
- HITL/AFK or equivalent execution mode markers when present

Fails if:
- issues are just long prose cards
- evidence is buried after the issue details
- risks do not connect to slices

## dashboard / status-report

Cognitive job: inspect current state and decide what needs attention.

Required:
- status summary strip
- issue/run cards grouped by state
- timeline or event log
- blockers separated from completed work
- evidence links or artifact paths
- carry-forward / next action section

Fails if:
- it looks like a weekly memo rather than a state console
- blocked work is visually similar to completed work

## comparison / comparison-board

Cognitive job: choose between alternatives.

Required:
- recommendation/default
- side-by-side option cards
- same-axis comparison table
- trade-offs, risks, rejected reasons
- decision criteria and scoring
- copy-as-prompt or next-decision export when useful

Fails if:
- options are unevenly described
- recommendation lacks rationale
- the page cannot support a decision

## review / review-annotated

Cognitive job: decide what to fix first from review findings.

Required:
- route/verdict at top
- fix-first list
- severity filters or severity grouping
- findings with file/line, reason, and concrete fix
- standards/spec/simplicity axis summary when present
- verification story and residual risk

Fails if:
- findings are only summaries without locations
- severity does not affect visual priority

## code-review

Cognitive job: review changed code with findings anchored to diff context.

Required:
- route/verdict and fix-first list
- changed-file sidebar
- rendered diff blocks with line numbers
- annotations pinned to specific files/lines/hunks
- severity and axis filters
- verification/evidence section

Fails if:
- it shows file:line references without code context
- annotations are detached from the diff

## pr-writeup

Cognitive job: help a reviewer understand why the PR exists and where to focus.

Required:
- motivation / problem statement
- before/after comparison
- file-by-file tour with change type and rationale
- review focus areas by risk
- testing notes with commands
- open decisions / known non-goals

Fails if:
- it reads like a changelog only
- review focus areas are not actionable

## explainer / research-explainer

Cognitive job: explain a domain, feature, or research result quickly and safely.

Required:
- TL;DR
- start-here / request path
- progressive drilldowns
- glossary or concept rail when terms are domain-specific
- gotchas / common wrong assumptions
- evidence paths or source confidence
- FAQ or "if you are changing X, check Y"

Fails if:
- it is a long essay with nicer headings
- important gotchas appear only at the end

## module-map

Cognitive job: help a future agent enter and modify an unfamiliar repo area safely.

Required:
- agent start-here rail
- module/entity map
- entrypoints, callers, callees
- seams, adapters, ownership, or boundaries
- risky seams / do-not-touch notes
- verification hotspots
- file-path rail
- copy-as-prompt panel when useful

Fails if:
- it only lists modules without relationships
- it lacks "where to start" and "what not to touch"

## execution-semantics

Cognitive job: understand a runtime path, data transformation chain, or feature execution semantics.

Required:
- one-sentence semantic model
- start-here rail: entrypoint, consumer, verification hotspot
- main diagram showing entry -> execution modules -> intermediate structures -> consumer
- data-shape strip: input, intermediate, output shapes
- per-entity or per-branch drilldown tabs/cards
- comparison to nearby path when useful
- verification hotspots: where to prove equivalence or correctness
- context-friction notes near the top, not only at the end
- source/evidence confidence per major claim

Fails if:
- it is a static module map with code snippets
- the reader must read every section to answer the core runtime questions
- transformations are not visible as input -> output relationships

## flowchart-diagram

Cognitive job: understand a process, state machine, or architecture flow at a glance.

Required:
- diagram legend
- node types or status color meaning
- critical path highlighted
- failure/retry paths visible when present
- detail panel or annotated node descriptions
- source path or command provenance

Fails if:
- it is just a rendered graph without explanation
- failure paths look optional when they are mandatory
