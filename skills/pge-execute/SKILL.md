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
  - `../../contracts/runtime-state-contract.md`

## High-level flow
- Check entry conditions against `../../contracts/entry-contract.md`.
- Initialize or resume runtime state via `../../contracts/runtime-state-contract.md`.
- Let Planner freeze one current round contract.
- Run a lightweight preflight / contract-ack on that frozen round to confirm it is executable without guessing and independently evaluable as written.
- Let Generator execute only that contract.
- Let Evaluator issue an independent verdict against artifact and evidence.
- Let Main record the route, route reason, and next runtime state.

## Non-goals
- defining runtime behavior beyond this thin invocation surface
- absorbing clarify-first or upstream shaping work into this loop
- turning preflight into a new planning subsystem or review ceremony
- defining multiple skills
- replacing agent files or contract files
- restating the full repo semantics inside this skill