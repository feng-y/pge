# PGE HTML Template Contracts

Templates are not decorative skins. Each template must replace a concrete cognition task.

Every generated page must answer:
- What should the reader understand or decide faster?
- What should they look at first?
- What evidence supports the claims?
- What source packet or context bundle did this page consume?
- Which source facts are primary, supporting, or raw detail?
- Where is each primary/supporting fact represented in the page?
- What should a future agent avoid or verify?
- What can the reader do with the artifact: compare, annotate, tune, copy, export, or share?
- What HTML-native visual representation best fits the job: map, diagram, deck, annotated code, gallery, or local control surface?
- What context does the page need to carry so a teammate can understand it outside the current chat?

## Common Quality Gate

All styles must include:
- **Cognitive job**: a one-sentence statement near the top.
- **Context intake summary**: source file, task directory, current-thread context, generated draft, command output, browser observation, or mixed source packet used to build the page.
- **Orientation**: start-here rail, summary strip, or first-read role list.
- **Visual structure**: diagram, grid, timeline, comparison, dashboard, annotated diff, or map.
- **Evidence surface**: source paths, commands, confidence, or provenance.
- **Coverage surface**: primary facts are visible; supporting facts and raw details are reachable through tables, tabs, details blocks, evidence panels, or appendices.
- **Responsive layout**: dense grids collapse on small screens.
- **No placeholder residue**: no TODO, TBD, lorem ipsum, placeholder comments, or fake external links.
- **Escaped source content**: no source-derived `innerHTML`.
- **Action/export surface**: when the page supports a decision or edit, include a copy/export result that can be pasted back into Claude Code.
- **Share context**: teammate-facing artifacts include source/provenance, updated date or run context when relevant, and enough orientation to read without the originating conversation.
- **HTML-native fit**: flows, state, timelines, alternatives, spatial relationships, tunable values, and editable structured data are represented with diagrams, controls, grids, filters, or exportable local state before prose.
- **No mechanical translation**: do not copy Markdown heading order, tables, or prose blocks into HTML unless that structure is the best visual model for the cognitive job.
- **Semantic completeness**: reorganizing source material is required for non-render modes, but source meaning must not be lost. If a detail is omitted, the page or result must name the omission and why it is safe.
- **Sidebar discipline**: sidebars/rails are for navigation, filters, current selection, or start-here orientation; do not use them as dumps for evidence paths or long source lists.
- **Markup integrity**: exactly one page-level `<h1>`, valid table bodies, no unrendered Markdown syntax in prose, no pasted subreport shells, and no malformed code/detail blocks.

Visual quality gate:
- first viewport must contain the primary cognition object, not only title text, metric cards, or boxed notes
- primary cognition object should be visual or interactive whenever the source contains flows, trade-offs, hierarchy, spatial relationships, code review, or tunable choices
- use a small design system in the `<style>` block; avoid large amounts of one-off inline styling
- avoid card soup: repeated bordered panels may frame repeated items, but whole-page sections should not all look like identical cards
- avoid monotone beige/cream/slate palettes; use restrained contrast and semantic accent colors
- turn generated Markdown structure into a designed information model; do not render every heading/table in source order when it weakens comprehension
- consume current-thread or generated-output context directly when the user asks for it; do not require a temporary Markdown file as an artificial source
- coverage beats brevity: collapse dense information instead of deleting it
- pages meant for choice/edit/review must include interaction that changes what the user can decide or export; decorative interaction does not count
- pages synthesized from multiple files, git history, browser observations, or MCP records must keep provenance near the claims it supports, not only in a footer
- for cognition artifacts, source heading order must not be the page outline unless the generation explicitly justifies why that order is the fastest cognition path
- pages synthesized from generated reports must rebuild one integrated information architecture; repeated Overview/Summary/References sections from subreports are a failure signal

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

## editor / local-control-surface

Cognitive job: let the human manipulate a hard-to-describe decision or structured value and export the result back to Claude Code or the repo.

Required:
- editable controls matched to the data type: toggles, sliders, segmented controls, text areas, drag/reorder, tags, or table rows
- live preview or validation when the choice affects generated text/config/behavior
- dependency, prerequisite, warning, or constraint display when present
- copy/export result: prompt, Markdown, JSON, diff, or changed keys
- reset or clear affordance when edits are non-trivial
- source/provenance for the initial values

Fails if:
- the UI edits values but cannot export the result
- controls are generic text fields when the data has a clearer native control
- validation appears only after export

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
- first viewport answers the central runtime question directly; do not spend the first screen on terminology or source-document orientation
- start-here rail: entrypoint, consumer, verification hotspot, and the one mental model the reader must keep
- main diagram showing source -> grouping/state -> transformation surface -> per-branch/per-entity outputs -> consumer, visible in the first viewport on desktop
- data-shape strip: input, intermediate, output shapes, including the repeated unit or row/cell semantics when present
- value/cell formation surface when the topic is tensor, matrix, row, record, or request transformation: fix one representative unit and show where its values come from
- per-entity or per-branch drilldown tabs/cards that answer a question, not just hide source sections
- side-by-side comparison for nearby runtime branches when useful; for branch deltas, show the same unit through both branches
- verification hotspots: where to prove equivalence or correctness, attached to the relevant transformation step
- context-friction notes near the top, not only at the end
- source/evidence confidence per major claim
- detailed code anchors, boundary conditions, examples, and return semantics should be second-level drilldowns unless they are the primary cognition object

Fails if:
- it is a static module map with code snippets
- it looks like a long stack of similar cards rather than an execution surface
- the sidebar/rail is used as a file-path dump; keep evidence as inline source chips or a compact evidence panel
- the reader must read every section to answer the core runtime questions
- transformations are not visible as input -> output relationships
- generated Markdown order is copied directly instead of redesigned around the semantic model
- terminology, object registry, or source-document sections appear before the main runtime model
- tabs merely correspond to Markdown headings instead of answering "where does this value/state come from?"

For tensor/matrix/listwise-style sources, prefer this artifact shape:
- first screen: one-sentence model + main diagram + the repeated unit, such as `(group_idx, position_idx)`
- second screen: a "cell/value origin viewer" for the representative unit
- third screen: branch comparison for the same unit, such as gen vs non-gen or old vs new
- later drilldowns: object registry, code anchors, boundary conditions, examples, return/writeback semantics, verification

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
