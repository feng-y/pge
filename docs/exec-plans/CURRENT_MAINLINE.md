# CURRENT_MAINLINE

## Current overall goal

Make PGE installable and updatable through the Claude Code plugin marketplace flow without relying on development-time `.claude/` symlinks.

## Current stage goal

Add the minimum plugin packaging layer that keeps the repo source-oriented while making the installed runtime layout, contracts placement, and version/update behavior explicit.

## Current P0 blockers

None.

## Explicit non-goals for this stage

- redesigning Planner / Generator / Evaluator semantics
- redesigning runtime orchestration broadly
- converting the source repo into a `.claude` runtime tree
- installing contracts as top-level `.claude/contracts/`
- building a custom updater framework beyond the marketplace/plugin model

## Next single action

None in this repo for the active round. The next external step, if desired, is to publish a marketplace catalog entry from a separate marketplace repo and test install/update through that catalog.

## Round completion criteria

This stage is done when:
- the repo has explicit plugin metadata with versioning
- the installed runtime layout is documented clearly
- contracts are packaged in a sane plugin-owned location
- source layout vs installed layout is explicit
- update behavior is documented through the marketplace/plugin flow
