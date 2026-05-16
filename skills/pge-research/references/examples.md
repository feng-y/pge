# Research Brief Examples

Reference examples for pge-research output. Load only when needed for calibration.

## Example 1: Simple (single option, 0 questions)

```markdown
# Research: add-dark-mode-toggle

## Metadata
- research_id: 20260509-1430-dark-mode-toggle
- date: 2026-05-09
- route: READY_FOR_PLAN

## Intent
User wants a dark mode toggle in the settings panel so people can switch themes without leaving the existing preferences flow. Theming already exists, so the boundary is adding a user-facing toggle rather than redesigning the theme system.

## Findings
- Theme system uses CSS custom properties defined in `src/styles/theme.css:1-45` — source: src/styles/theme.css:1
- Settings panel component at `src/components/Settings.tsx:22` has an existing preferences section — source: src/components/Settings.tsx:22
- No existing dark mode implementation found — source: grep across src/
- localStorage is used for other preferences (language, notifications) — source: src/utils/preferences.ts:8

## Affected Areas
- src/styles/theme.css — reason: add dark color values
- src/components/Settings.tsx — reason: add toggle UI
- src/utils/preferences.ts — reason: persist preference

## Constraints
- Must work with existing CSS custom property system

## Assumptions
- Toggle persists via localStorage (consistent with existing preference pattern) — reason: other preferences already use this
- System preference detection (prefers-color-scheme) as initial default — reason: standard UX practice

## Planning Handoff
- facts_plan_must_preserve: existing CSS custom property system works, localStorage pattern established
- constraints_plan_must_not_violate: must use existing custom property system, not introduce new theming library
- known_invalid_directions: full theme system redesign (out of scope)
- likely_affected_areas: src/styles/theme.css, src/components/Settings.tsx, src/utils/preferences.ts
- verification_risks: none significant
- unresolved_blockers: none

## Open Questions
- None

## Next
- next_skill: pge-plan
- task_dir: .pge/tasks-dark-mode-toggle/
```

## Example 2: Complex (multiple framings, 1 question asked)

```markdown
# Research: rethink-state-management

## Metadata
- research_id: 20260509-1500-state-management
- date: 2026-05-09
- route: READY_FOR_PLAN

## Intent
User wants to replace the current ad-hoc state management because prop drilling is now hurting maintainability as the app grows. The likely boundary is client-side state structure, not server-state fetching, unless later answers expand the scope.

## Findings
- 14 components use prop drilling deeper than 3 levels — source: grep -r "props\." src/components/ (manual count)
- Current state lives in App.tsx with 8 useState hooks — source: src/App.tsx:15-42
- Two existing context providers (AuthContext, ThemeContext) — source: src/contexts/
- No existing state management library in package.json — source: package.json
- Bundle size budget mentioned in CLAUDE.md: "keep bundle under 200KB" — source: CLAUDE.md:34
- React 18 used, concurrent features not yet adopted — source: package.json:12

## Affected Areas
- src/App.tsx — reason: state currently lives here
- src/components/ (14 files) — reason: prop drilling removal
- src/contexts/ — reason: may expand or replace
- package.json — reason: potential new dependency

## Constraints
- Bundle size budget: under 200KB total
- React 18 (no React 19 features)

## Assumptions
- Server state (API calls) is separate concern, not in scope — reason: user said "state management" not "data fetching" (confirmed via question)

## Planning Handoff
- facts_plan_must_preserve: 2 existing contexts work (AuthContext, ThemeContext), React 18 concurrent features available but not yet adopted
- constraints_plan_must_not_violate: bundle budget under 200KB, must not break existing context consumers
- known_invalid_directions: keeping current prop drilling (user explicitly wants change), adopting React 19 features (not available)
- likely_affected_areas: src/App.tsx, src/components/ (14 files), src/contexts/, package.json
- verification_risks: partial migration may leave inconsistent state access patterns
- unresolved_blockers: none

Approach candidates for plan engineering review:
- Expand React Context + useReducer: proven in codebase (2 contexts exist), verbose with many contexts, no devtools
- Zustand: 2.9KB gzipped (fits budget), minimal boilerplate, closest to existing useState mental model
- Jotai: 3.4KB gzipped, granular re-renders, different mental model (atoms vs stores)

## Open Questions
- Should we migrate incrementally or all-at-once? — blocks_plan: no

## Next
- next_skill: pge-plan
- task_dir: .pge/tasks-state-management/
```
