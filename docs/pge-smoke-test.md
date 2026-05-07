# PGE Smoke Test

## Purpose

Define the current smoke-oriented validation path for `pge-execute`.

This document is for proving the current thin-skill architecture by executing the real `/pge-execute` path in a Claude Code runtime and keeping the concrete runtime result.

It is not a historical proving log. It is the current manual validation procedure.

## Preconditions

- The plugin is available through either:
  - marketplace/plugin install, or
  - local dev override from `./bin/pge-local-install.sh`
- `agents/pge-planner.md`, `agents/pge-generator.md`, and `agents/pge-evaluator.md` are the active runtime agent surfaces.
- The active skill entrypoint is `skills/pge-execute/SKILL.md`.
- Do not replace execution with a capability pre-check. Attempt the preferred runtime action directly, keep the concrete TeamCreate / Agent / SendMessage / TeamDelete or direct Agent dispatch result, and treat that real call result as the smoke outcome.

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
- progress-log and event-contract checks pass
- no whitespace or patch-application issues remain

This static pass does not count as runtime smoke proof.

After a runtime smoke run completes, inspect timing with:

```bash
./bin/pge-progress-report.sh .pge-artifacts/<run_id>/progress.jsonl
```

This report is only useful when the progress log contains timestamps.

## Runtime Smoke Task

Run:

```text
/pge-execute test
```

The required smoke task is:

```text
Create .pge-artifacts/<run_id>/deliverables/smoke.txt with content exactly: pge smoke
```

## Runtime Success Criteria

The smoke run passes only if all of the following are true:

1. One team is created for the run.
2. The team contains exactly these teammate bindings:
   - `planner` -> `pge-planner`
   - `generator` -> `pge-generator`
   - `evaluator` -> `pge-evaluator`
3. Planner may remain idle; it is not on the critical path for the smoke shortcut.
4. Generator performs the real smoke write directly.
5. Evaluator independently reads the run-scoped smoke file.
7. Final evaluator verdict is `PASS`.
8. Final `next_route` is `converged`.
9. Shared progress log records the main execution events without gating the run.
10. Team teardown is attempted and recorded.

## Required Artifacts To Inspect

For the active `run_id`, inspect:

- `.pge-artifacts/<run_id>/manifest.json`
- `.pge-artifacts/<run_id>/input.md`
- `.pge-artifacts/<run_id>/progress.jsonl`
- `.pge-artifacts/<run_id>/evaluator.md`
- `.pge-artifacts/<run_id>/deliverables/smoke.txt`

## Failure Classification

Classify failures narrowly:

- **Bootstrap failure**: team or agent binding cannot be created.
- **Planner failure**: planner artifact missing or malformed.
- **Generator boundary failure**: generator does not produce the run-scoped smoke deliverable.
- **Evaluator independence failure**: evaluator does not inspect the real deliverable.
- **Routing failure**: final route contradicts verdict.
- **Progress logging failure**: progress log writes fail noisily or start gating execution.
- **Teardown failure**: run succeeds but does not record or attempt team shutdown cleanly.

## Historical Evidence Rule

Older proving runs may be useful context, but they do not substitute for a fresh smoke proof on the current thin-skill architecture.

Use earlier run artifacts only as debugging aids, not as completion evidence for the current stage.
