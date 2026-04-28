# PGE Role Mapping

PGE keeps exactly three teammates while borrowing the useful structure from dev-cycle and Anthropic-style harnesses.

Local reference:

- `/code/3p/aiworks/davinci/skill/dev-cycle/SKILL.md`
- `/code/3p/aiworks/README.md`
- Anthropic long-running harness: planner / generator / evaluator with file-backed feedback.

## Mapping

- `researcher + archi -> pge-planner`
  - gather lightweight evidence
  - identify design and harness constraints
  - freeze one bounded round contract

- `coder + local reviewer -> pge-generator`
  - implement the deliverable
  - run local verification
  - perform skeptical self-review
  - never issue final approval

- independent QA gate -> `pge-evaluator`
  - inspect the actual deliverable independently
  - validate against Planner contract and Generator evidence
  - issue verdict and canonical next route
  - never modify files

## Design Constraints

- Main is only orchestration, observer state, and route selection.
- Main must not simulate planner/generator/evaluator work.
- Preflight exists to shift quality left before Generator edits.
- Generator self-review is useful evidence, not final acceptance.
- Evaluator is the final gate.
- Canonical routes must be preserved even when redispatch is not implemented.
