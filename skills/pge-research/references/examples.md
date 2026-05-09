# Research Brief Examples

Reference examples for pge-research output. Load only when needed for calibration.

## Example 1: Simple (single option, 0 questions)

```markdown
# Research: add-dark-mode-toggle

## Metadata
- research_id: 20260509-1430-dark-mode-toggle
- date: 2026-05-09
- research_route: READY_FOR_PLAN

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

## Options

### Option A: CSS custom properties + class toggle
- Approach: Add `.dark` class to document root, swap CSS custom property values
- Evidence: Existing theme system already uses custom properties (theme.css:1-45)
- Tradeoff: None significant — aligns with existing pattern
- Effort: S

## Recommendation
- Pick: Option A
- Why: Direct extension of existing pattern, no new dependencies

## Open Questions
- None

## Next
- next_skill: pge-plan
- task_dir: .pge/tasks-dark-mode-toggle/
```

## Example 2: Complex (multiple options, 1 question asked)

```markdown
# Research: rethink-state-management

## Metadata
- research_id: 20260509-1500-state-management
- date: 2026-05-09
- research_route: READY_FOR_PLAN

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

## Options

### Option A: Expand React Context + useReducer
- Approach: Split state into domain contexts (UserContext, AppContext, etc.), use useReducer for complex state
- Evidence: Already have 2 contexts working (src/contexts/), pattern is proven in this codebase
- Tradeoff: Can get verbose with many contexts; no devtools; re-render optimization needs memo
- Effort: M

### Option B: Zustand
- Approach: Lightweight store with hooks, replace useState/context with Zustand stores
- Evidence: 2.9KB gzipped (fits budget), no boilerplate, works with React 18
- Tradeoff: New dependency; team needs to learn API (minimal)
- Effort: M

### Option C: Jotai
- Approach: Atomic state model, each piece of state is an atom
- Evidence: 3.4KB gzipped, granular re-renders by default, minimal boilerplate
- Tradeoff: Different mental model (atoms vs stores); less conventional for team
- Effort: M

## Recommendation
- Pick: Option B (Zustand)
- Why: Smallest learning curve, fits bundle budget, proven at scale, closest to existing useState mental model

## Open Questions
- Should we migrate incrementally or all-at-once? — blocks_plan: no

## Next
- next_skill: pge-plan
- task_dir: .pge/tasks-state-management/
```
