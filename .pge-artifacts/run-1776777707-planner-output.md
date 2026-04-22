planner_note: pass-through
planner_escalation: none

goal: Create one smoke-test document at `docs/pge-smoke-test.md` containing exactly the required text.

in_scope:
- Create or update only `docs/pge-smoke-test.md` as the task deliverable.
- Run minimal local verification needed to prove file existence, exact content, and isolated task-file change.

out_of_scope:
- Do not modify any other task-facing repo files.
- Do not redesign plugin, skill, agent, contract, or runtime behavior.
- Do not add extra content, formatting, or surrounding explanation to the smoke-test file.

actual_deliverable: File `docs/pge-smoke-test.md` containing exactly `PGE smoke test` followed by a trailing newline.

acceptance_criteria:
- File exists at `docs/pge-smoke-test.md`.
- File content is exactly `PGE smoke test` with no extra text.
- No other task-facing repo files are changed by this round.

verification_path:
- Read `docs/pge-smoke-test.md` directly.
- Verify exact content bytes.
- Verify task-facing changed file set is only `docs/pge-smoke-test.md`.

stop_condition: single_round

required_evidence:
- Direct file read showing the exact content of `docs/pge-smoke-test.md`.
- Command output proving the task-facing changed file set is limited to `docs/pge-smoke-test.md`.

handoff_seam: Later work may reuse or delete `docs/pge-smoke-test.md` without reopening this round.

open_questions:
- none
