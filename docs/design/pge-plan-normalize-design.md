# PGE Plan Normalize Design

## Why this exists

`pge-exec` 目前同时承担“执行 canonical plan”和“接住外部高质量 plan 并转成 canonical plan”。这让 exec 获得了额外的规划判断权，也让执行路径变重。

这个 skill 的目的就是把这件事拆出来：

> `pge-plan-normalize` 负责把 **高质量外部 plan** 无损转换成 `pge-exec` 能执行的 canonical `.pge/tasks-<slug>/plan.md`。

它不负责判断方案本身好不好。它判断的是：
- 外部 plan 里有哪些结构
- canonical plan 需要哪些字段
- 这些字段是否被完整映射
- 哪些字段是 inferred / missing / conflicting
- 是否足够 `READY_FOR_EXECUTE`

## Responsibility boundary

### This skill does
- accept high-quality external plans
- assess normalization coverage / conversion completeness
- write canonical `.pge/tasks-<slug>/plan.md` when the source is sufficiently complete
- record provenance metadata and explicit assumptions
- route `READY_FOR_EXECUTE | READY_FOR_EXECUTE_WITH_ASSUMPTIONS | NEEDS_HUMAN | BLOCKED`

### This skill does not
- re-plan the work
- challenge whether the feature should exist
- re-open architecture decisions already settled upstream
- guarantee that an external review was rigorous
- execute the plan

## Accepted inputs

### Primary
- Claude Code plan mode output
- `docs/exec-plan/` structured execution documents
- reviewed workflow plans with explicit goal / scope / acceptance / verification

### Rejected inputs
- vague brainstorm notes
- partial issue text with no bounded execution structure
- docs that would require inventing acceptance or target areas
- source plans with contradictory scope / ownership semantics

## Conversion target

The only successful output target is:
- `.pge/tasks-<slug>/plan.md`

Minimum metadata written into the canonical plan:
- `source_plan`
- `source_kind`
- `normalization_only: true`
- explicit assumptions, when route is `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`

## Normalization Coverage / Conversion Completeness

Normalization is judged by coverage, not by source prestige.

| Canonical Field | Source Field | Status | Confidence | Notes |
|---|---|---|---|---|
| Goal / Intent | external goal section | mapped | high | direct mapping when explicit |
| Stop Condition | external success / done criteria | mapped or inferred | medium-high | inference allowed only when mechanical |
| Scope / Phase | external scope / phase section | mapped | high | must remain bounded |
| Target Areas | implementation steps / ownership sections | mapped or inferred | medium-high | inference must not require architecture choice |
| Acceptance Criteria | external done criteria / behavior expectations | mapped | high | must not be invented |
| Verification / Evidence | test / compare / rollout / proof section | mapped / degraded / missing | medium-high | degraded means weaker-than-needed proof |
| Dependencies | step order / prerequisites | mapped or inferred | medium | inference must remain explicit |
| Non-goals / Exclusions | explicit exclusions | mapped / missing | medium-high | missing non-goals may still be acceptable if scope is otherwise sharply bounded |

### Status meanings
- `mapped` — direct source field exists
- `inferred` — mechanically derivable without replanning
- `missing` — required field absent
- `conflicting` — source content disagrees with itself or selected scope
- `degraded` — field exists but only in a weaker-than-needed form

## Execution-critical fields

These fields decide whether normalize may emit a plan that exec can run:
- goal
- observable stop condition
- bounded scope / current phase
- target areas or unambiguous ownership boundaries
- acceptance criteria
- verification / evidence expectation
- dependencies or explicit statement that dependencies are none

Everything else is secondary.

## Routes

### `READY_FOR_EXECUTE`
Use when:
- all execution-critical fields are mapped
- only non-critical fields, if any, are inferred
- no conflicts exist

### `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`
Use when:
- any execution-critical field is inferred
- the inference is mechanical, low-discretion, and explicitly recorded
- exec can run without hidden planning
- the resulting canonical plan records those assumptions explicitly enough for exec to consume them without inventing new ones

### `NEEDS_HUMAN`
Use when:
- execution-critical fields are missing
- or resolving them requires human judgment rather than mechanical mapping
- source itself is not contradictory

### `BLOCKED`
Use when:
- source conflicts with itself
- semantic ownership is ambiguous
- missing semantics would force replanning
- conversion would require inventing scope, acceptance, target areas, or architecture

## Hard rules

1. Normalize is a **lossless adapter**, not replanning.
2. Provenance is **metadata**, not quality proof.
3. If source quality is high but conversion completeness is low, normalize must still stop.
4. `pge-plan-normalize` may infer fields only when the inference is mechanical and auditable.
5. Every inferred execution-critical field must be written into the canonical plan as an explicit assumption.
6. Any inferred execution-critical field forces route `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`; plain `READY_FOR_EXECUTE` is reserved for mapped execution-critical fields.

## Source of truth after normalization

Once normalize succeeds:
- `.pge/tasks-<slug>/plan.md` becomes the only execution contract
- source documents remain provenance and evidence, not parallel execution inputs
- if the source document changes later, normalize must be rerun before exec continues

This prevents split-brain execution between source plan and canonical plan.

## Interaction with other skills

### Upstream
- `pge-plan` produces canonical plan directly when planning is needed
- Claude plan mode / external workflows may bypass `pge-plan` only if they are already high-quality plans

### Downstream
- `pge-exec` consumes only canonical `.pge/tasks-<slug>/plan.md`
- canonical execution routes accepted by exec are `READY_FOR_EXECUTE | READY_FOR_EXECUTE_WITH_ASSUMPTIONS`
- when route is `READY_FOR_EXECUTE_WITH_ASSUMPTIONS`, normalize must write the assumptions explicitly into the canonical plan; exec may consume those explicit assumptions but may not create new implicit ones
- `pge-review` and `pge-challenge` judge execution against the canonical plan

## Failure modes to guard against

1. **False confidence from reviewed sources**
   - a plan may be "reviewed" but still miss execution-critical fields
2. **Inference drift**
   - normalize starts inventing implementation structure instead of mapping it
3. **Split-brain truth**
   - exec consults both source doc and canonical plan after normalization
4. **Silent degraded verification**
   - source has “done criteria” but no real verification/evidence path

## Verification

Minimum validation for this skill:
1. A complete Claude plan mode output normalizes to canonical plan
2. A complete `docs/exec-plan/` doc normalizes to canonical plan
3. A source with missing acceptance or verification routes `NEEDS_HUMAN`
4. A conflicting source routes `BLOCKED`
5. A route with inferred critical fields records assumptions explicitly
6. After normalization, exec can treat the canonical plan as the only execution input
7. A `READY_FOR_EXECUTE_WITH_ASSUMPTIONS` route produces a canonical plan whose assumptions are explicit enough for exec to consume without replanning

## Not in scope

- scoring whether the source plan is strategically good
- replacing engineering review or challenge workflows
- executing the resulting plan
- durable knowledge extraction from run outputs
