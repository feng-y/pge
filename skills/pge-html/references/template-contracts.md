# PGE HTML Template Contracts

Templates are not decorative skins. Each template must replace a concrete cognition task.

Every generated page must answer:
- What should the reader understand or decide faster?
- What should they look at first?
- What evidence supports the claims?
- What should a future agent avoid or verify?
- What can the reader do with the artifact: compare, annotate, tune, copy, export, or share?
- What HTML-native visual representation best fits the job: map, diagram, deck, annotated code, gallery, or local control surface?

## Common Quality Gate

All styles must include:
- **Cognitive job**: a one-sentence statement near the top.
- **Orientation**: start-here rail, summary strip, or first-read role list.
- **Visual structure**: diagram, grid, timeline, comparison, dashboard, annotated diff, or map.
- **Evidence surface**: source paths, commands, confidence, or provenance.
- **Responsive layout**: dense grids collapse on small screens.
- **No placeholder residue**: no TODO, TBD, lorem ipsum, placeholder comments, or fake external links.
- **Escaped source content**: no source-derived `innerHTML`.
- **Action/export surface**: when the page supports a decision or edit, include a copy/export result that can be pasted back into Claude Code.
- **No mechanical translation**: do not copy Markdown heading order, tables, or prose blocks into HTML unless that structure is the best visual model for the cognitive job.
- **Sidebar discipline**: sidebars/rails are for navigation, filters, current selection, or start-here orientation; do not use them as dumps for evidence paths or long source lists.

Visual quality gate:
- first viewport must contain the primary cognition object, not only title text, metric cards, or boxed notes
- primary cognition object should be visual or interactive whenever the source contains flows, trade-offs, hierarchy, spatial relationships, code review, or tunable choices
- use a small design system in the `<style>` block; avoid large amounts of one-off inline styling
- avoid card soup: repeated bordered panels may frame repeated items, but whole-page sections should not all look like identical cards
- avoid monotone beige/cream/slate palettes; use restrained contrast and semantic accent colors
- turn generated Markdown structure into a designed information model; do not render every heading/table in source order when it weakens comprehension
- pages meant for choice/edit/review must include interaction that changes what the user can decide or export; decorative interaction does not count

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

## code-understanding

Cognitive job: follow one concrete behavior through the codebase and understand where to inspect or change it safely.

Required:
- one-sentence behavior model at top
- primary path diagram visible in the first viewport
- callstack or request-path walkthrough with numbered steps
- key files rail with each file's role, not just paths
- highlighted trust boundary, mutation point, or highest-risk step when present
- collapsible source snippets or compact code evidence for the core steps
- gotchas / wrong assumptions near the top or in a sticky rail
- verification hotspots or tests tied to the behavior

Fails if:
- it becomes a broad inventory of modules instead of one behavior path
- key files are listed without roles or order
- the diagram does not connect to the walkthrough steps
- source snippets dominate the page before the reader understands the path
- it should have been `execution-semantics` because data-shape or runtime transformation correctness is the main question

## module-map

Cognitive job: help a future agent enter and modify an unfamiliar repo area safely.

Required:
- agent start-here rail
- module/entity map
- entrypoints, callers, callees
- seams, adapters, ownership, or boundaries
- risky seams / do-not-touch notes
- verification hotspots
- source paths attached to the module, edge, or claim they support
- copy-as-prompt panel when useful

Fails if:
- it only lists modules without relationships
- it lacks "where to start" and "what not to touch"
- the sidebar is mostly file paths instead of orientation

## execution-semantics

Cognitive job: understand a runtime path, data transformation chain, or feature execution semantics.

Required:
- one-sentence semantic model
- start-here rail: entrypoint, consumer, verification hotspot
- main diagram showing entry -> execution modules -> intermediate structures -> consumer, visible in the first viewport on desktop
- data-shape strip: input, intermediate, output shapes
- per-entity or per-branch drilldown tabs/cards
- comparison to nearby path when useful
- verification hotspots: where to prove equivalence or correctness
- context-friction notes near the top, not only at the end
- source/evidence confidence per major claim

Fails if:
- it is a static module map with code snippets
- it looks like a long stack of similar cards rather than an execution surface
- the sidebar/rail is used as a file-path dump; keep evidence as inline source chips or a compact evidence panel
- the reader must read every section to answer the core runtime questions
- transformations are not visible as input -> output relationships
- generated Markdown order is copied directly instead of redesigned around the semantic model

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
