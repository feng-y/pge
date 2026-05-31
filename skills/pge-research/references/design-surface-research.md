# Design / Experience Research Calibration

Use this reference only when the task has a human-visible surface and experience context would change planning. Examples include UI, documentation, CLI/prompt output, generated reports, workflow artifacts, or reviewable HTML/markdown surfaces.

This file calibrates optional Research behavior. It must not reintroduce obsolete Research-only fields or make optional design context part of the default `research.v3` contract.

## Boundary

Research captures problem-side design/experience context. It may describe what the surface must communicate, what would disappoint the audience, and which constraints Plan should preserve. It must not choose final layout, component design, visual system, copy package, implementation approach, acceptance criteria, or verification path.

## When to use

Use when a technically correct change could still fail because the human-facing surface is confusing, misleading, generic, off-tone, or hard to operate.

Do not use for purely internal refactors, build tooling, tests, migrations, or protocol edits with no human-visible behavior unless the artifact itself is the user-facing product.

## What to capture

Add an optional `Design / Experience Note` or concise Context/Direction bullets with only the dimensions that matter:

- **surface** — what artifact, workflow, UI, prompt, report, or document is being shaped
- **audience** — who uses or reads it and in what context
- **experience_success_shape** — what “good” should feel like or communicate
- **what_would_disappoint** — how the result could be technically correct but experientially wrong
- **existing conventions** — local docs, components, artifacts, tone, structure, or rendered evidence Plan should preserve
- **generic/slop risks** — patterns that would make the surface feel undifferentiated or misleading
- **open experience questions** — only those that change Plan and require user authority

## Route impact

- `READY_FOR_PLAN` is valid when experience context is sufficient for Plan to choose implementation details.
- `NEEDS_USER` when a product, audience, tone, trust, or positioning choice is required and cannot be inferred.
- `NEEDS_REPO_EVIDENCE` when existing surface conventions or rendered behavior must be inspected before planning.
- `BLOCKED` when the requested surface cannot be evaluated or changed under current constraints.

## Stop rule

After recording the relevant design/experience context, return to the main `pge-research` flow and write the `research.v3` brief. Do not create mockups, screenshots for presentation, design variants, preview pages, or code changes inside Research.
