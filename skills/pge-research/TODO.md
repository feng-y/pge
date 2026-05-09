# pge-research TODO

## Goal

Track follow-up design and implementation work for `pge-research` after the initial skill draft.

## Design TODO

- [ ] Re-compare `SKILL.md` against `superpowers/brainstorming` and confirm the remaining differences are deliberate, not gaps.
- [ ] Review `grill-with-docs` again and tighten the questioning section if there are still places where wording is too explanatory instead of behavior-shaping.
- [ ] Decide whether `templates/brief.md` should stay as a single `research.md` artifact or grow into a small task directory contract with additional files.
- [ ] Define the exact handoff contract for `pge-plan` consuming `.pge/tasks-<slug>/research.md`.
- [ ] Decide whether `research_route` needs sharper criteria examples for `READY_FOR_PLAN`, `NEEDS_INFO`, and `BLOCKED`.
- [ ] Re-check whether the current anti-pattern set is complete or whether one more anti-pattern is needed around overconfident assumptions.

## Implementation TODO

- [ ] Update `pge-plan` to read `.pge/tasks-<slug>/research.md` when present.
- [ ] Align any downstream examples or docs that still mention `.pge/research/` paths.
- [ ] Add one realistic end-to-end dry run for a simple intent and one for an ambiguous intent.
- [ ] Validate that `templates/brief.md` and `references/examples.md` stay consistent with `SKILL.md` after future edits.

## Further Learning TODO

- [ ] Revisit `Spec Kit /clarify` and decide which ambiguity-taxonomy pieces are still worth borrowing without making `pge-research` heavier.
- [ ] Revisit `RPI /research` and extract only the parts that improve research artifact gating and handoff quality.
- [ ] Revisit `Dex / HumanLayer` notes and see whether the small-artifact / multi-step narrowing pattern should shape the task directory contract.
- [ ] Revisit `grill-with-docs` after a few dry runs and check whether the current questioning section still misses intent-sharpening triggers in ambiguous prompts.
- [ ] Revisit `brainstorming` after `pge-plan` integration and confirm the remaining differences are still intentional.
- [ ] Use `superpowers/writing-skills` as a follow-up tuning guide: capture baseline failures, keep modifications minimal, and add near-miss evals instead of growing the skill by feel.
- [ ] Decide later whether CE-style ideate vs brainstorm separation is useful, or whether it would just over-split the research phase.

## Notes

This file is intentionally lightweight. It is for local skill evolution, not as a user-facing artifact.
