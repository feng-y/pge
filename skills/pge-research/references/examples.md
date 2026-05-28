# Research Brief Examples

Reference examples for `pge-research` output. Load only when needed for calibration.

## Example 1: Simple v3 brief, 0 questions

```markdown
# Research: add-dark-mode-toggle

schema_version: research.v3
route: READY_FOR_PLAN

## 1. Spec Discovery

- user_request: Add a dark mode toggle; no code yet, research current theming and safest direction.
- goal: Let users switch themes from the existing settings/preferences flow.
- success_shape: Planning can add a toggle that uses the existing theme mechanism without redesigning the theme system.
- scope: Settings toggle, theme values, preference persistence.
- non_goals: Full theme redesign; new theming library; unrelated settings cleanup.
- constraints: Preserve existing CSS custom property pattern.

## 2. Context

- relevant_user_context: User wants research before code.
- relevant_repo_or_architecture_context:
  - Theme system uses CSS custom properties in `src/styles/theme.css`.
  - Settings panel has an existing preferences section in `src/components/Settings.tsx`.
  - Other preferences persist through `src/utils/preferences.ts`.
- assumptions:
  - Initial default can follow existing preference conventions unless Plan finds a stronger local pattern.

## 3. Direction

- simplest_direction: Add the toggle through the existing settings and preference path, using CSS custom properties.
- rejected_directions:
  - Full theme-system redesign — outside requested scope.
  - New theming library — unnecessary given existing CSS variable pattern.
- why_this_is_enough_for_plan: Goal, scope, constraints, and likely affected surfaces are clear enough for Plan to choose implementation details.

## 4. Open Questions

- blocking_questions: none
- non_blocking_questions: none

## 5. Route

- route: READY_FOR_PLAN
- route_reason: Plan can proceed without inventing user intent or repo reality.

## Metadata

- research_id: 20260509-1430-dark-mode-toggle
- date: 2026-05-09
- task_dir: .pge/tasks-dark-mode-toggle/
```

## Example 2: Implementation Friction

```markdown
# Research: lighten-research-contract

schema_version: research.v3
route: READY_FOR_PLAN

## 1. Spec Discovery

- user_request: Remove heavy Research handoff fields so Research is lightweight.
- goal: Make Research lighter without breaking downstream Plan consumption.
- success_shape: Planning receives a safe migration target instead of deleting fields that are still consumed.
- scope: Research output contract and Plan input compatibility.
- non_goals: Exec redesign; broad historical cleanup.
- constraints: Preserve downstream compatibility during the transition.

## 2. Context

- relevant_user_context: User wants Research to stop behaving like a heavy template.
- relevant_repo_or_architecture_context:
  - Plan currently consumes legacy `planning_handoff` semantics.
- assumptions: Legacy v2 consumption can remain as compatibility while v3 becomes current.

## 3. Direction

- simplest_direction: Make `research.v3` current and add a minimal Plan adapter that still accepts v2.
- rejected_directions:
  - Hard-delete `planning_handoff` everywhere — breaks current Plan assumptions.
- why_this_is_enough_for_plan: Plan has a clear compatibility boundary and can choose the execution slice.

## 4. Open Questions

- blocking_questions: none
- non_blocking_questions: none

## Conditional: Implementation Friction

- expected_understanding: Research can remove the old handoff fields directly.
- actual_implementation_reality: Plan still consumes legacy handoff semantics.
- conflict: Direct deletion would break downstream planning assumptions.
- why_it_matters_for_plan: Plan must authorize compatibility migration, not hard removal.
- required_plan_adjustment: Add research.v3 consumption while preserving v2 compatibility.

## 5. Route

- route: READY_FOR_PLAN
- route_reason: Friction is resolved into a safe required Plan adjustment.
```

## Example 3: Progressive Feasibility

```markdown
# Research: full-workflow-protocol-redesign

schema_version: research.v3
route: READY_FOR_PLAN

## 1. Spec Discovery

- user_request: Redesign Research, Plan, Exec, Review, docs, evals, and historical references around a universal protocol.
- goal: Move PGE toward a lighter, more general discovery-to-execution contract without breaking the active pipeline.
- success_shape: The first plan moves one safe structural boundary and leaves later redesign explicit.
- scope: Determine whether the direct goal can be planned safely.
- non_goals: Full Exec redesign; Review/Challenge redesign; historical archive cleanup in the first slice.
- constraints: Preserve Research → Plan → Exec → Review / Challenge → Ship.

## 2. Context

- relevant_user_context: User wants the workflow improved but bounded.
- relevant_repo_or_architecture_context: Multiple active skill/docs/evals consume current Research semantics.
- assumptions: A first compatibility slice can be verified statically.

## 3. Direction

- simplest_direction: First make `research.v3` authoritative in Research and add minimal Plan compatibility.
- rejected_directions:
  - One-shot redesign of all stages — too broad and unsafe for direct planning.
- why_this_is_enough_for_plan: The first objective is bounded and protects downstream consumers.

## 4. Open Questions

- blocking_questions: none
- non_blocking_questions: Later Plan optimization details remain deferred.

## Conditional: Progressive Feasibility

- direct_goal: Full workflow protocol redesign.
- direct_planning_risk: Too many stage contracts and validation assumptions would change at once.
- structural_blocker: Research producer, Plan consumer, docs, and eval calibration need an explicit compatibility boundary first.
- first_plannable_objective: Make `research.v3` authoritative in `pge-research` and add minimal `pge-plan` compatibility.
- deferred_goal_parts: Exec redesign, Review/Challenge redesign, universal protocol extraction, historical cleanup.
- plan_instruction: Plan the first compatibility slice, not the full final goal.

## 5. Route

- route: READY_FOR_PLAN
- route_reason: Progressive Feasibility narrows the valid goal to a safe first plannable objective.
```
