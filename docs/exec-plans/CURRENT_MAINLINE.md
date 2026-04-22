# CURRENT_MAINLINE

## Current overall goal

Make `pge-execute` actually runnable as a real orchestration skill.

## Current stage goal

Evaluate whether agent-team orchestration is actually needed after the direct single-round path has been proven, and avoid adding it unless it unblocks a demonstrated need.

## Current P0 blockers

None.

## Explicit non-goals for this stage

- external task support
- multi-round support
- repo-specific disclosure docs
- broad agent semantic redesign
- heavy team orchestration
- planner/generator/evaluator interface redesign beyond the already proven smoke path

## Next single action

Do not implement heavy teams. Keep the direct dispatch path as the current mainline until a concrete blocker appears that the proven single-round path cannot handle.

## Round completion criteria

This stage is done when:
- the installed runtime-facing agents are discoverable under the names `pge-planner`, `pge-generator`, and `pge-evaluator`
- `/pge-execute` runs as an imperative orchestration skill instead of only showing descriptive flow text
- the runtime dispatch path uses the installed agents directly
- planner, generator, and evaluator artifacts are persisted for one bounded run
- routing result is explicit and inspectable
- one minimal smoke round converges end-to-end through `PASS` + `converged`
- consecutive smoke rounds write distinct runtime state files keyed by `run_id`
- the second smoke round does not reuse or overwrite the first run's runtime state
- one canonical proving packet exists with planner output, generator bundle, evaluator verdict, route, and round summary all inspectable from the same converged run
- canonical schema semantics are aligned so evaluator evidence is judged against artifacts available by evaluation time and summary remains a post-route artifact
- Phase 6 decision is explicit: heavy teams are not currently needed because the direct installed-agent dispatch path already proves the required bounded run without a demonstrated team-only blocker
