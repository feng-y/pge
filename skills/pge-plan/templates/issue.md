# I001: <action-oriented title>

## status

- State: READY_FOR_EXECUTE | NEEDS_INFO | BLOCKED | NEEDS_HUMAN
- Dependencies: <Ixxx or none>
- Verification Coupling: none | independent | compile-coupled with <IDs> | shared verification with <IDs> | integration-only | isolated worktree required | serial verification required
- Execution Type: AFK | HITL:verify | HITL:decision | HITL:action
- Verification Type: AUTOMATED | MANUAL | MIXED
- Security: yes | no

## context

- Plan: ../plan.md
- Requirement goal served: <short stable reference>
- Upstream decisions: <decision IDs or none>

## task

<bounded action-oriented execution block>

## behavior_contract

- Current Behavior: <current behavior or repo state>
- Desired Behavior: <post-change behavior>
- Behavior Delta: <smallest required behavior/contract change>
- Key Interfaces: <files, commands, config, schemas, public contracts>
- Trigger Predicate: <when relevant, or not_applicable>
- Output Admission Predicate: <when relevant, or not_applicable>
- Out Of Scope Confirmed: <adjacent work not allowed>
- What Not To Infer: <assumptions Generator must not invent>

## scope

### Do

- <allowed local work>

### Do Not

- <issue-local forbidden work>

## target_areas

- Modify: <path>
- Create: <path>

## acceptance

- <issue-local acceptance>

## local_validation

- <command or check>

## required_evidence

- <evidence pge-exec must produce>

## risks

- <risk and mitigation>

## source_refs

- source_plan: <plan section / issue index row / external source section>
- research: <field or not_applicable>
- user_constraint: <prompt/source reference or not_applicable>
- repo_evidence: <path/line or not_applicable>
- mechanical_support: <why this issue is necessary support>
