# Design Surface Research Contract

For visual, UI, workflow, documentation, CLI/prompt, or artifact-facing work, `pge-research` must be stronger than generic "user-facing context." It should absorb the useful research-side capabilities from gstack's `design-consultation`, `design-shotgun`, `design-review`, and `plan-design-review` without taking over their implementation or review authority.

Run this design-surface contract whenever `experience_scope` is not `none`:

1. **Product and audience context** (`design-consultation`)
   - Must do: identify what the product/artifact is, who it is for, what space it lives in, and what job the surface does for that audience.
   - Evidence to write: `design_surface_context.product_or_surface`, `audience`, `artifact_purpose`, and `usage_context`.
   - Enhanced check: if README, office-hours notes, existing docs, or current prompt do not make the product/audience clear, ask one focused question before planning.
   - Fail route: if the audience or product job is still unknown and would change the experience direction, route `NEEDS_INFO`.

2. **Existing design system and local conventions** (`design-consultation`, `design-review`)
   - Must do: check for `DESIGN.md`, `design-system.md`, local UI docs, existing components, and rendered or documented conventions that planning must preserve.
   - Evidence to write: `design_surface_context.design_system_sources`, `design_system_status: explicit | inferred | absent`, and conventions planning must preserve.
   - Enhanced check: if no design system exists, record that absence as a planning risk; do not invent a full design system in research.
   - Fail route: if existing design system sources conflict and the conflict changes planning, ask the user which source is authoritative or route `NEEDS_INFO`.

3. **Landscape and category baseline** (`design-consultation`)
   - Must do: when category fit matters, identify what users likely expect in this product category and what would feel generic or surprising.
   - Evidence to write: `category_baseline`, `expected_conventions`, `generic_risks`, and any external or repo evidence used.
   - Enhanced check: distinguish table-stakes conventions from opportunities to differentiate.
   - Boundary: external visual research is optional and depends on available tools, user consent, and task risk; if skipped, record why.
   - Fail route: if category expectations are central to success and no evidence or informed assumption is available, ask one question or route `NEEDS_INFO`.

4. **Safe/risk design tradeoffs** (`design-consultation`, `design-shotgun`)
   - Must do: capture where planning should play safe for literacy and where a deliberate risk could make the surface memorable.
   - Evidence to write: `safe_tradeoffs`, `risky_tradeoffs`, what each risk gains, what it costs, and whether user confirmation is needed.
   - Enhanced check: if a risky differentiator would change product positioning, brand tone, or user trust, ask the user instead of treating it as repo evidence.
   - Boundary: research may frame safe/risk tradeoffs; it must not choose a final aesthetic system, palette, typography, or motion package.

5. **Divergent experience framings** (`design-shotgun`)
   - Must do: when the user has not seen what the surface could become, compare 2-3 experience directions before narrowing.
   - Evidence to write: `experience_framings` with audience feeling, hierarchy emphasis, density, tone, and risk if wrong.
   - Enhanced check: each framing must name what it optimizes for and what it would sacrifice.
   - Boundary: these are experience directions, not mockups or final layouts. Research may recommend what the experience should communicate; `pge-plan` owns implementation shape.

6. **Design completeness dimensions** (`plan-design-review`)
   - Must do: for plan-shaping UI/UX work, assess whether research has enough context for information architecture, visual hierarchy, interaction states, edge cases, responsive behavior, accessibility, content/microcopy, and trust.
   - Evidence to write: `design_dimension_gaps` with any missing dimensions that would make planning under-specified.
   - Enhanced check: empty, loading, error, first-time, power-user, long-content, mobile, keyboard, screen-reader, and reduced-motion states are user experiences, not polish.
   - Fail route: if a missing dimension would change acceptance or core scope, route `NEEDS_INFO`; otherwise hand it to planning as a required constraint or risk.

7. **Rendered-experience evidence when available** (`design-review`)
   - Must do: if an existing live/rendered surface is relevant and accessible, use screenshots, snapshots, or extracted rendered facts as evidence; if not available, record the limitation.
   - Evidence to write: `visual_evidence_sources`, first-impression observations, actual fonts/colors/hierarchy when observed, and `rendered_evidence_limits` when evidence is unavailable or partial.
   - Enhanced check: first-impression observations must state what the surface communicates at a glance and whether that matches the user's goal.
   - Boundary: research records problem-side evidence; it does not run a full visual QA fix loop.

8. **AI-slop and generic-design risk** (`design-review`, `plan-design-review`)
   - Must do: identify whether the requested direction risks generic AI-looking output, card soup, centered-everything, decorative blobs, purple gradients, vague hero copy, or cookie-cutter section rhythm.
   - Evidence to write: `anti_slop_risks` and constraints planning must preserve to avoid them.
   - Enhanced check: if avoiding slop requires a product/brand choice, ask the user; otherwise record it as a planning constraint.
   - Boundary: research flags and constrains slop risk; it does not redesign the surface.

9. **Research-stage stop boundary**
   - Must do: stop after recording design context and design risks in the research brief.
   - Evidence to write: `planning_handoff` entries for design facts, constraints, invalid directions, and verification risks.
   - Boundary: do not create design variants, preview pages, DESIGN.md, screenshots for presentation, plan edits, or code changes inside `pge-research`.
