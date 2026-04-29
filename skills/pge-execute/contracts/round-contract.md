# Round Contract

## minimum handoff
Planner hands Generator exactly one current-task / bounded round contract with:
- `goal`
- `evidence_basis`
- `design_constraints`
- `in_scope`
- `out_of_scope`
- `actual_deliverable`
- `acceptance_criteria`
- `verification_path`
- `required_evidence`
- `stop_condition`
- `handoff_seam`
- `open_questions`
- `planner_note`
- `planner_escalation`

## meaning
- `goal`: what this current task must settle now
- `evidence_basis`: the concrete facts, sources, confidence boundaries, and verification paths Planner used to choose this round
- `design_constraints`: the design, harness, invariant, scope, and risk constraints Generator must preserve
- `in_scope`: what this current task is allowed to change
- `actual_deliverable`: the real artifact this current task must produce
- `verification_path`: the primary way this current task will be checked
- `acceptance_criteria`: the minimum conditions that must be true for this current task to count as complete
- `required_evidence`: the minimum evidence Evaluator must see to judge the current task independently; for single-round proving this may include current-run control-plane artifacts that already exist by evaluation time, but must not require post-route artifacts such as the round summary before PASS
- `stop_condition`: what marks the current task as done for routing purposes
- `out_of_scope`: what must remain out of scope for this current task
- `handoff_seam`: where later work can continue without reopening this current task
- `open_questions`: unresolved uncertainty that does not block freezing the current round, or `None`
- `planner_note`: Planner's `decision` plus rejected cuts and contract self-check notes
- `planner_escalation`: exactly one focused question or blocker when the contract cannot be frozen cleanly, or `None`

## evidence basis shape

Each material evidence item should include:
- `source`: file path, tool output, runtime contract, explicit user instruction, or inference marker
- `fact`: the concrete claim used to shape the round
- `confidence`: `HIGH`, `MEDIUM`, or `LOW`
- `verification_path`: how Generator or Evaluator can re-check the claim when needed

Confidence meaning:
- `HIGH`: directly observed from code, runtime contract, tool output, or explicit user instruction
- `MEDIUM`: design-doc claim consistent with observed repo state
- `LOW`: inference, stale doc claim, unresolved ambiguity, or repo/doc conflict

LOW-confidence evidence cannot silently carry the contract. It must either have a verification path or be reflected in `open_questions` / `planner_escalation`.

## context loading strategy shape

Within `evidence_basis`, Planner should include:
- files or sections read
- files or sections intentionally not read
- reason the loaded context is sufficient for this bounded round
- any context budget tradeoff that could affect confidence

## design constraints shape

`design_constraints` should include:
- the chosen round boundary
- PGE invariants relevant to this round
- any rejected cut when it materially affects downstream behavior

Do not use `design_constraints` to prescribe Generator implementation details.

## failure mode register shape

Within `design_constraints`, each material failure mode should include:
- `failure`: what can go wrong
- `observable_signal`: how Generator or Evaluator can detect it
- `likely_owner`: `planner`, `generator`, or `evaluator`
- `mitigation`: the contract field or verification path that reduces the risk

Use `None` only when the task is deterministic and has no material failure mode beyond failing the stated verification path.

## planner note shape

`planner_note` should include:
- `decision`: `pass-through` or `cut`
- `rejected_cuts`: at most two rejected cuts, or `None`
- `contract_self_check`: placeholders, contradiction, scope creep, and ambiguous acceptance criteria check

## rejected cuts shape

When the round was selected from multiple plausible cuts, `planner_note` should include:
- at most two rejected cuts
- one concrete tradeoff or failure mode for each rejected cut

Use `rejected_cuts: None` when there was only one plausible current-round task.

This is the PGE-thin version of brainstorming: enough opposition research to avoid a bad round, not a separate design process.

## task split boundary

Planner owns current-round task split and DoD.

Planner does not own full-project backlog scheduling until multi-round runtime exists.
