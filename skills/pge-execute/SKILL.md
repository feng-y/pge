# pge-execute

## Purpose
- Execute one bounded PGE loop over an upstream plan.
- Keep invocation separate from responsibility and handoff definitions.

## When to use
- Multi-round repo-internal work
- Work that must stay bounded and verifiable
- Work that needs independent acceptance before convergence

## Input
- upstream plan
- current repo context when needed
- current round state when resuming

## Uses
- responsibility layer:
  - `../../agents/main.md`
  - `../../agents/planner.md`
  - `../../agents/generator.md`
  - `../../agents/evaluator.md`
- handoff layer:
  - `../../contracts/entry-contract.md`
  - `../../contracts/round-contract.md`
  - `../../contracts/evaluation-contract.md`
  - `../../contracts/routing-contract.md`

## High-level flow
- Check whether the upstream input can enter PGE.
- Let Planner freeze one current round contract.
- Let Generator execute that contract.
- Let Evaluator issue an independent verdict.
- Let Main route `continue`, `retry`, `return_to_planner`, or `converged`.

## Non-goals
- defining runtime behavior
- defining multiple skills
- replacing agent files or contract files
- restating the full repo semantics inside this skill