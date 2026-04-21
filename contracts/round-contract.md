# Round Contract

## minimum handoff
Planner hands Generator exactly one current-task / bounded round contract with:
- `goal`
- `in_scope`
- `out_of_scope`
- `actual_deliverable`
- `verification_path`
- `acceptance_criteria`
- `required_evidence`
- `stop_condition`
- `handoff_seam`

## meaning
- `goal`: what this current task must settle now
- `in_scope`: what this current task is allowed to change
- `actual_deliverable`: the real artifact this current task must produce
- `verification_path`: the primary way this current task will be checked
- `acceptance_criteria`: the minimum conditions that must be true for this current task to count as complete
- `required_evidence`: the minimum evidence Evaluator must see to judge the current task independently
- `stop_condition`: what marks the current task as done for routing purposes
- `out_of_scope`: what must remain out of scope for this current task
- `handoff_seam`: where later work can continue without reopening this current task