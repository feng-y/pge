# External Plan Normalization

Legacy reference for the external-plan normalization split. `pge-exec` must not load this file during execution. Use `skills/pge-plan-normalize/SKILL.md` as the active normalization surface when the selected source is not a canonical `.pge/tasks-<slug>/plan.md` but appears clear and complete enough to execute.

This reference is intentionally domain-neutral. Do not copy internal project names, repository paths, model names, feature names, metrics, or proprietary implementation details into resident PGE docs. Use this as a shape guide for accepting external plans, not as a template for any specific project.

## Acceptable Source Shape

A strong external plan usually contains:

- **Executive goal** — one target outcome and why it matters.
- **Settled decisions** — architecture, ownership, rollout, or behavior decisions that must be preserved.
- **Core semantics** — definitions of the important data/model/control-flow concepts, written precisely enough to prevent ownership drift.
- **Boundaries** — what belongs inside the change and what must stay outside.
- **Implementation components** — the major components, call sites, interfaces, migration steps, or rollout modes to change.
- **Compatibility requirements** — old/new path behavior, known quirks to preserve, migration safety, or fallback behavior.
- **Verification checkpoints** — unit, integration, compare, rollout, metrics, manual proof, or evidence gates.
- **Reference evidence** — code references, prior examples, docs, commits, logs, or tests that support the plan.

The source does not need PGE field names, numbered PGE issues, or `.pge/` paths. It must give enough structure for `pge-plan-normalize` to derive those mechanically.

## Normalization Rules

Convert the source into `.pge/tasks-<slug>/plan.md` without changing decisions.

Map source content as follows:

| Source Shape | Canonical Plan Field |
|---|---|
| Executive goal / expected outcome | `goal`, `Stop Condition` |
| Settled decisions | `Plan Constraints`, `upstream_decision_refs` |
| Boundaries / exclusions | `non_goals`, issue `Scope`, `Risks` |
| Implementation components / migration steps | `## Slices` issues |
| Component ownership / named target areas | issue `Target Areas` |
| Behavior expectations / compatibility requirements | issue `Acceptance Criteria` |
| Tests / compare mode / rollout checks / metrics | `Verification Hint`, `Required Evidence`, `Test Expectation` |
| Reference evidence | `Repo Context`, issue `Risks`, `Required Evidence` |

Issue extraction may use source headings, phases, implementation components, rollout steps, or explicitly listed core changes. Each issue must trace back to source text. If an issue cannot point to source text, it is probably new planning, not normalization.

## Required Anonymization For Resident Docs

When using an internal plan as an example for improving PGE itself:

- Replace project names with neutral terms such as `<domain system>`, `<component>`, `<adapter>`, `<legacy path>`, `<new path>`, `<rollout mode>`.
- Replace repository paths with neutral path categories such as `<core module>`, `<call site>`, `<test file>`, `<shared utility>`.
- Replace metrics, flag names, model names, and protocol names with generic labels such as `<compare failure metric>` or `<rollout control>`.
- Keep only the structural lesson: what made the plan clear and complete, how fields map to PGE, and where normalization must stop.
- Do not include internal code snippets, proprietary terminology, exact paths, or business semantics unless the user explicitly says the target document is private to that repo.

## Stop Conditions

Do not normalize. Route `BLOCKED`, `NEEDS_HUMAN`, or back to `pge-plan` when:

- The goal or stop condition is missing.
- Scope or phase boundary is unclear.
- Semantic ownership is ambiguous.
- Target areas cannot be assigned mechanically from the source.
- Acceptance criteria or verification checkpoints must be invented.
- Issue boundaries would require choosing a new architecture or rollout strategy.
- The source asks for broad cleanup or "while here" work without explicit boundaries.
- The source contains contradictions that change execution scope.

## Positive Pattern

An external plan is a strong normalization candidate when it has:

- a single outcome
- explicit boundaries and non-goals
- a settled implementation direction
- named ownership or target areas
- compatibility or rollout rules
- concrete verification/evidence checkpoints
- enough structure to split work without changing the plan

For this pattern, run `pge-plan-normalize` first, then execute the generated canonical plan with `pge-exec`.
