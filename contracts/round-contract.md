# Round Contract

## minimum handoff
Planner hands Generator exactly one current round contract with:
- `goal`
- `boundary`
- `deliverable`
- `verification_path`
- `acceptance_criteria`
- `required_evidence`
- `allowed_deviation_policy`
- `no_touch_boundary`
- `handoff_seam`

## meaning
- `goal`: what this round must settle now
- `boundary`: what this round is allowed to change
- `deliverable`: the artifact this round must produce
- `verification_path`: the primary way this round will be checked
- `acceptance_criteria`: the minimum conditions that must be true for this round to count as complete
- `required_evidence`: the minimum evidence Evaluator must see to judge the round independently
- `allowed_deviation_policy`: which local deviations may still remain inside the current round and which must route back out
- `no_touch_boundary`: what must remain out of scope
- `handoff_seam`: where later work can continue without reopening this round