# ADR 0001: PGE Contract Authority and Planning Responsibility

## Status

Accepted

## Context

PGE is evolving from an execution-heavy harness toward a plan-grounded execution-quality harness.

The repeated failure mode is not that execution lacks more process. It is that execution receives a plan with hidden ambiguity, unstated dependencies, stale architecture assumptions, weak verification, or unclear downstream consumption. If those gaps reach `pge-exec` or Dynamic Workflow, the execution layer either guesses, becomes heavy, or produces evidence that downstream stages cannot trust.

`CLAUDE.md` should not carry the full protocol design. It should be a resident bootstrap that points agents to the stable contract authority and active skill surfaces.

## Decision

Stable cross-surface protocol constraints live in ADRs or `docs/pge/*` contract references. `CLAUDE.md` only summarizes resident behavior and links to the durable authority.

Planning quality goals do not automatically become protocol fields. Do not add plan sections, issue fields, routes, task graphs, or workflow state only to encode "better planning"; use the existing contract surfaces unless a concrete producer, consumer, validator, and evidence consumer all require a protocol change.

For workflow, schema, route, artifact, or stage-authority changes, PGE uses a four-party contract gap check:

| Party | Question |
|---|---|
| Producer | Who writes or defines the contract, artifact, field, route, status, or claim? |
| Consumer | Who reads it and acts on it during execution or orchestration? |
| Validator | Who accepts, rejects, gates, or verifies it before execution continues? |
| Evidence Consumer | Who later uses the result for review, replan, ship, or handoff? |

The check is required when a change touches:

- route, status, verdict, or stage-authority vocabulary
- artifact schemas or templates
- execution handoffs or workflow adapters
- validation, evidence, review, challenge, or gate semantics
- public/plugin configuration or install behavior
- architecture or migration boundaries where a wrong assumption can execute correctly but wrongly

For ordinary code or documentation edits, the check should remain lightweight or be skipped when not relevant.

## Planning Responsibility

`pge-plan` owns the conversion from intent to executable logic.

Plan must:

- understand the inherited or current user intent
- confirm requirement boundaries when ambiguity would change goal, scope, acceptance, safety, or authority
- produce an executable solution approach
- use repo evidence to surface assumptions, missing validation, forbidden-zone risk, or unverifiable evidence when they affect correctness or trust
- slice work into issue contracts that can execute and verify in order
- produce evidence requirements that both `pge-exec` and Dynamic Workflow can satisfy without guessing

Plan must not:

- re-open Research problem discovery without evidence that the problem contract is invalid
- pre-write implementation code
- move orchestration into the plan
- create a second canonical plan, workflow graph, task DAG, dependency JSON, task tree, or subagent topology
- add ad hoc plan sections or issue fields when existing fields can carry the needed decision, boundary, verification, or stop condition
- push known plan gaps into execution and rely on heavy `pge-exec` or reviewer loops to discover them

## Execution Responsibility

`pge-exec` and Dynamic Workflow are execution backends.

They should receive:

- canonical goal and non-goals
- target and forbidden areas
- issue contracts
- dependency and verification-coupling hints
- stop conditions
- concrete validation/evidence expectations

They should not be responsible for discovering major requirement gaps, plan-changing architecture contradictions, missing validators, or unknown downstream consumers.

## Consequences

- `CLAUDE.md` remains short and operational.
- README remains user-facing positioning.
- `pge-plan` becomes the place where execution-quality gaps are pulled forward.
- `pge-exec` can stay light because it executes a clearer contract.
- Dynamic Workflow can own orchestration without becoming a second planning layer.
- Protocol changes must preserve producer, consumer, validator, and evidence-consumer alignment.
