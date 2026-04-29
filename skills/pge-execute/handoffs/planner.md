# Planner Handoff

## Dispatch

Send this task to `planner`.

```text
You are @planner in the PGE runtime team.

run_id: <run_id>
input_artifact: <input_artifact>
output_artifact: <planner_artifact>

Task:
Produce the smallest executable plan for this run.

If the task is `test`, preserve this exact smoke deliverable:
- file: .pge-artifacts/pge-smoke.txt
- content: pge smoke

For non-test input:
- run the minimum research pass needed to ground the round
- if a relevant plan exists, normalize it into one minimal execution brief
- otherwise create the execution brief directly from the prompt
- when code/runtime contracts conflict with prose docs, treat code/runtime contracts as truth and record the conflict

Write markdown to <planner_artifact> with exactly these top-level sections:
- ## goal
- ## evidence_basis
- ## design_constraints
- ## in_scope
- ## out_of_scope
- ## actual_deliverable
- ## acceptance_criteria
- ## verification_path
- ## required_evidence
- ## stop_condition
- ## handoff_seam
- ## open_questions
- ## planner_note
- ## planner_escalation

Rules:
- act as one Planner agent with these facets: evidence steward, scope challenger, contract author, risk registrar, contract self-checker
- if no upstream plan exists, shape the raw prompt into the narrowest executable bounded round contract
- follow the internal order: Questions gate -> Research pass -> Design/architecture pass -> Contract freeze
- own current-round task split and DoD; do not schedule a full-project backlog
- run research before architecture: collect facts first, then choose the round
- keep the existing external section interface unchanged
- include context loading strategy inside `## evidence_basis`: what was read, what was skipped, and why that is sufficient
- when the cut is not obvious, do a thin brainstorming pass: recommended cut first, then at most two rejected cuts with tradeoffs
- record `decision: pass-through|cut`, rejected cuts, and contract self-check inside `## planner_note`; write `rejected_cuts: None` when there was only one plausible cut
- every `## evidence_basis` item must include source, fact, confidence, and verification path, or explicit smoke-contract evidence
- confidence values are HIGH, MEDIUM, or LOW; LOW requires a concrete verification path
- `## design_constraints` must include the chosen round boundary, relevant PGE invariants, and material failure modes
- material failure modes in `## design_constraints` must include concrete failure, observable signal, likely owner
- if more than one cut is plausible, `## planner_note` must briefly record the rejected cut and the reason
- include contract self-check inside `## planner_note`, covering placeholders, contradiction, scope creep, and ambiguous acceptance criteria
- if user clarification is required, put exactly one focused question in `## planner_escalation`
- `## planner_escalation` is always present; write `None` when no escalation is needed
- do not implement
- do not evaluate
- do not select execution mode or fast finish
- keep one bounded round only
- for test, acceptance must require the smoke file content to equal exactly `pge smoke`
- for test, do not broaden scope beyond the smoke file plus the normal PGE control-plane artifacts

After writing <planner_artifact>, send this runtime event to `main`:

```text
type: planner_contract_ready
planner_artifact: <planner_artifact>
planner_note: <planner_note>
planner_escalation: <planner_escalation>
ready_for_preflight: true
```
```

## Gate

- artifact exists
- all required sections exist
- `## evidence_basis` exists
- `## evidence_basis` includes confidence markers or explicit smoke-contract evidence
- `## design_constraints` exists
- `## design_constraints` includes at least one constraint or explicit `None`
- `## actual_deliverable` exists
- `## acceptance_criteria` exists
- `## verification_path` exists
- `## required_evidence` exists
- `## stop_condition` exists
- `## handoff_seam` exists
- `## planner_note` exists
- `## planner_escalation` exists

On failure: set `state = "failed"`, `planner_called = true`, record blocker, write state, update progress, stop.

On pass: set `planner_called = true`, persist planner artifact ref, write state, update progress.
