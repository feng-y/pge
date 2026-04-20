# Planner Output

## Round Contract

**Goal**: Execute the upstream plan as one bounded round

**Boundary**: Only what the upstream plan explicitly requires

**Deliverable**: The artifact specified in the upstream plan

**Verification Path**: Check that the deliverable exists and matches the plan

**Acceptance Criteria**:
- Deliverable artifact exists
- Deliverable matches upstream plan requirements
- No scope expansion beyond the plan

**Required Evidence**:
- Path to deliverable artifact
- Brief verification that it matches the plan

**Allowed Deviation Policy**: Minor implementation details may vary if semantics are preserved

**No Touch Boundary**: Do not modify files outside the deliverable scope

**Handoff Seam**: Generator receives this contract and produces the deliverable

## Planner Note

Pass-through: upstream plan is already bounded and executable.

## Upstream Plan Reference

upstream-plan-round-001-closure.md
