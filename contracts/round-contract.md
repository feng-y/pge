# Round Contract

## minimum handoff
Planner hands Generator exactly one current round contract with:
- `goal`
- `boundary`
- `deliverable`
- `verification_path`
- `no_touch_boundary`
- `handoff_seam`

## meaning
- `goal`: what this round must settle now
- `boundary`: what this round is allowed to change
- `deliverable`: the artifact this round must produce
- `verification_path`: the primary way this round will be checked
- `no_touch_boundary`: what must remain out of scope
- `handoff_seam`: where later work can continue without reopening this round