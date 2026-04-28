# PGE Smoke Test

## Purpose

Define the current smoke-oriented validation path for `pge-execute`.

This document is for proving the current thin-skill architecture in a real Claude Code runtime that supports TeamCreate, Agent binding, SendMessage, and TeamDelete.

It is not a historical proving log. It is the current manual validation procedure.

## Preconditions

- Claude Code runtime supports TeamCreate, Agent, SendMessage, and TeamDelete.
- The plugin is available through either:
  - marketplace/plugin install, or
  - local dev override from `./bin/pge-local-install.sh`
- `agents/pge-planner.md`, `agents/pge-generator.md`, and `agents/pge-evaluator.md` are the active runtime agent surfaces.
- The active skill entrypoint is `skills/pge-execute/SKILL.md`.

## Static Validation Before Runtime Smoke

Run:

```bash
./bin/pge-validate-contracts.sh
git diff --check
```

Expected:

- skill-local contract checks pass
- orchestration-workflow section checks pass
- planner/generator/evaluator required sections pass
- preflight/evaluator enum checks pass
- no whitespace or patch-application issues remain

This static pass does not count as runtime smoke proof.

## Runtime Smoke Task

Run:

```text
/pge-execute test
```

The required smoke task is:

```text
Create .pge-artifacts/pge-smoke.txt with content exactly: pge smoke
```

## Runtime Success Criteria

The smoke run passes only if all of the following are true:

1. One team is created for the run.
2. The team contains exactly these teammate bindings:
   - `planner` -> `pge-planner`
   - `generator` -> `pge-generator`
   - `evaluator` -> `pge-evaluator`
3. Planner writes a bounded planner artifact.
4. Generator writes a preflight proposal before any repo edits.
5. Evaluator preflight returns an artifact with valid fields and allowed enums.
6. Generator performs the real smoke write only after preflight `PASS + ready_to_generate`.
7. Evaluator independently reads `.pge-artifacts/pge-smoke.txt`.
8. Final evaluator verdict is `PASS`.
9. Final `next_route` is `converged`.
10. Summary, state, and progress artifacts are written.
11. Team teardown is attempted and recorded.

## Required Artifacts To Inspect

For the active `run_id`, inspect:

- `.pge-artifacts/<run_id>-input.md`
- `.pge-artifacts/<run_id>-planner.md`
- `.pge-artifacts/<run_id>-contract-proposal.md`
- `.pge-artifacts/<run_id>-preflight.md`
- `.pge-artifacts/<run_id>-generator.md`
- `.pge-artifacts/<run_id>-evaluator.md`
- `.pge-artifacts/<run_id>-state.json`
- `.pge-artifacts/<run_id>-summary.md`
- `.pge-artifacts/<run_id>-progress.md`
- `.pge-artifacts/pge-smoke.txt`

## Failure Classification

Classify failures narrowly:

- **Bootstrap failure**: team or agent binding cannot be created.
- **Planner failure**: planner artifact missing or malformed.
- **Preflight failure**: proposal/preflight artifact missing, malformed, or illegal enum value.
- **Generator boundary failure**: repo edits happen before preflight PASS.
- **Evaluator independence failure**: evaluator does not inspect the real deliverable.
- **Routing failure**: final route or state contradicts verdict.
- **Teardown failure**: run succeeds but does not record or attempt team shutdown cleanly.

## Historical Evidence Rule

Older proving runs may be useful context, but they do not substitute for a fresh smoke proof on the current thin-skill architecture.

Use earlier run artifacts only as debugging aids, not as completion evidence for the current stage.
