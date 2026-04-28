# PGE Communication Protocol

## Topology

PGE uses one team with exactly three teammates:

- `planner`
- `generator`
- `evaluator`

`main` is the orchestrator and observer. It is not a fourth agent and must not perform role work.

All semantic handoff happens through files. `SendMessage` is used only to dispatch a phase with artifact paths and constraints.

## Communication Rules

- Agents do not rely on chat history as the source of truth.
- Agents read the input artifacts named in the dispatch message.
- Agents write exactly the output artifact named in the dispatch message.
- Agents may write the actual deliverable only when their role allows it.
- Main gates artifacts before routing to the next phase.
- Main updates `state_artifact` and `progress_artifact` after each phase transition.
- Direct agent-to-agent semantic decisions are not authoritative unless captured in file-backed artifacts.

## Current Single-Round Message Flow

```text
main -> planner
  inputs: input_artifact
  output: planner_artifact
  purpose: evidence-backed bounded round contract

main -> generator
  inputs: planner_artifact
  output: contract_proposal_artifact
  purpose: preflight execution proposal; no repo edits

main -> evaluator
  inputs: planner_artifact, contract_proposal_artifact
  output: preflight_artifact
  purpose: independent preflight gate

main -> generator
  inputs: planner_artifact, contract_proposal_artifact, preflight_artifact
  output: generator_artifact + actual deliverable
  purpose: implementation, local verification, local self-review

main -> evaluator
  inputs: planner_artifact, contract_proposal_artifact, preflight_artifact, generator_artifact, actual deliverable
  output: evaluator_artifact
  purpose: independent final verdict and next_route

main routes
  inputs: evaluator_artifact, state_artifact
  outputs: state_artifact, summary_artifact, progress_artifact
```

## Future Persistent Routes

These routes are canonical now, but automatic redispatch is future work unless explicitly implemented.

### `retry`

Evaluator says the current contract remains valid and Generator can repair locally.

Future message:

```text
main -> generator
  inputs: planner_artifact, prior_generator_artifact, evaluator_artifact
  output: generator_artifact for attempt N+1
  purpose: fix required_fixes without reopening planning
```

### `return_to_planner`

Evaluator says the contract is ambiguous, unfair, or mismatched.

Future message:

```text
main -> planner
  inputs: prior planner_artifact, generator_artifact, evaluator_artifact, current state
  output: repaired planner_artifact for round N+1
  purpose: repair the round contract before generation
```

### `continue`

Evaluator accepts the current round but the run stop condition is not satisfied.

Future message:

```text
main -> planner
  inputs: accepted artifacts, current state, run_stop_condition
  output: next bounded round contract
  purpose: select the next slice
```

## Artifact Discipline

Every artifact must be:

- path-addressable
- bounded to one phase
- written before main advances state
- structurally gated by main
- referenced from `artifact_refs`

For robust long-running execution, agents should write complete artifacts in one pass. If a tool/runtime supports atomic writes, prefer temp file then rename; otherwise main must gate only after the expected final sections are present.

## Progress Discipline

`progress_artifact` is the human and recovery-facing view of the run.

It should include:

- phase table
- current route
- current blocker
- artifact paths
- whether Generator edits are allowed
- latest evaluator/preflight result
- next expected dispatch

`progress_artifact` is updated by main, not by teammates.
