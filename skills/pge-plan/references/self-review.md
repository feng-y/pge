# Final Sanity Pass Reference

Loaded by pge-plan Phase 4. This is a focused final sanity pass before the Final Plan Gate, not a second planning ceremony.

## Purpose

Confirm that the synthesized plan is still aligned, covered, verifiable, and executable after solution design. Do not reopen broad option generation, repeat Plan Engineering Review, or run an adversarial pressure-test loop by default.

## Depth Scaling

- **LIGHT**: one compact paragraph or checklist covering all four sanity areas.
- **MEDIUM**: one short bullet per sanity area, with evidence where useful.
- **DEEP**: add source/evidence citations for contract surfaces, protocol changes, or high-risk verification claims.

## Sanity Areas

1. **Goal-backward fit** — state the inherited problem contract and confirm the issues, acceptance, evidence, and stop condition satisfy it without scope drift.
2. **Coverage** — confirm current prompt constraints, upstream decisions, non-goals, target areas, forbidden areas, and relevant risks are covered, explicitly rejected, or routed.
3. **Verification and evidence** — confirm every major acceptance criterion has a concrete verification path or required evidence. "Run tests" alone is insufficient unless the named test scope proves the criterion.
4. **Exec readiness** — confirm each ready issue has concrete action, behavior contract, target areas, acceptance, verification hint/type, test expectation, required evidence, dependencies, risks, security classification, and execution state.

## Repair Rule

Fix failures inline once and rerun only the failed sanity area. If the same area still fails, route instead of looping:

- `REWORK_PLAN` when the problem contract is clear and Plan can repair issue shape, coverage, verification, or evidence.
- `NEEDS_INFO` when one user-authority answer is required.
- `RETURN_TO_RESEARCH` when goal, scope, success shape, constraints, or a Research-required adjustment must change.
- `BLOCKED` when the plan cannot fairly become executable in this turn.

## Record Shape

Use this compact shape only when it helps downstream execution or review:

```text
sanity_area: goal_fit | coverage | verification_evidence | exec_readiness
status: PASS | REWORK_PLAN | NEEDS_INFO | RETURN_TO_RESEARCH | BLOCKED
evidence: <source/evidence or "not needed for LIGHT">
repair: <specific repair or "none">
```

## Anti-Ceremony Rules

- Do not run all historical self-review checks by default.
- Do not add a pressure test unless the plan changes a high-risk contract surface or verification could pass trivially.
- Do not re-enter Phase 2 exploration unless a specific failed sanity area needs one bounded repo fact.
- Do not record pass/fail tables that do not change execution or review decisions.
