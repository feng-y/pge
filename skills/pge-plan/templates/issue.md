# I001: <action-oriented title>

## goal

<issue-local goal in one sentence; must support the plan goal>

## plan_context

<semantic pointer to the plan intent, decision, phase, or slice this issue implements>

## change

<bounded issue-local change to deliver>

## target_areas

- Modify: <path>
- Create: <path>

## recommended_approach

<implementation direction that should help execution without becoming a rigid algorithm>

## forbidden

- <plan or issue boundary the generator must not cross>

## validation

- Expected: <what must be true when this issue is done>
- Check: <command, inspection, or manual check>
- Evidence: <what pge-exec should record>

## optional_when_useful

- Stop if: <condition that means the issue must pause, clarify, require a human decision, or avoid unsafe scope expansion>
- Verification Coupling: <none | independent | compile-coupled with <IDs> | shared verification with <IDs> | integration-only | isolated worktree required | serial verification required; include first trustworthy verification point when non-independent>
- Source refs: <source plan / research / user constraint / repo evidence>
- Risk note: <risk and mitigation>
