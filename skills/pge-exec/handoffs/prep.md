# Prep Handoff

## Purpose

Prep lanes are optional, read-only native helpers for upcoming issues or issue groups. They reduce dispatch uncertainty for main and Generator lanes. They do not write code, modify artifacts, approve scope changes, produce acceptance evidence, or replace verification.

**Native lane responsibility**: Prep is a bounded read-only exploration lane that runs ahead of implementation using Claude Code native Agent Teams execution. Prep does not persist state, share context across issues, or replace Generator's own fresh reads. Prep hints are inputs to Generator dispatch, not cached truth.

Use prep only when a future dispatch has real uncertainty: likely implementation surface, existing capability search, legacy trap identification, coupling risk, or verification cost.

## Lifecycle Protocol

Before receiving prep work, each `prep-*` lane must acknowledge team startup with:

```text
type: lane_ready
lane: prep-*
status: READY | BLOCKED
reason: <none or one sentence>
```

On teardown, when main sends `shutdown_request`, the selected `prep-*` lane must stop accepting new work, approve the shutdown through the team runtime protocol using the request ID from that request, and then terminate.

## Dispatch Protocol

Main sends prep data only after the selected `prep-*` lane has passed Agent Startup Verification:

```text
---BEGIN PREP DATA---
You are @<prep-lane> in the pge-exec team.

run_id: <run_id>
plan_id: <plan_id>
target_issue_ids: <future issue IDs or issue group>

## Prep Task

Goal: <plan goal, concise>
Behavior Delta: <future issue behavior delta>
Target Areas: <candidate target areas>
Verification Hint: <planned verification command>
Known Dependencies: <issue IDs or "none">
Known Risks: <from plan, or "none">

## Rules

1. Read only. Do not modify files or artifacts.
2. Identify likely target surface, existing reusable capability, coupling warnings, legacy traps, verification risks, and stop-if conditions.
3. Return hints only. Do not claim implementation completion, acceptance, or evidence.
4. If the plan appears wrong in a contract-changing way, report the suspected conflict as a risk for main; do not rewrite the plan.
---END PREP DATA---
```

## Output

Send exactly one `preflight_hint` packet:

```text
type: preflight_hint
lane: <prep-lane>
status: READY | BLOCKED | STALE
target_issue_ids: <list>
likely_target_surface:
  - <file/symbol/command and why, or "none">
possible_reuse:
  - <existing capability or "none">
risks:
  - <legacy trap, coupling risk, verification risk, contract-changing risk, or "none">
stop_if:
  - <forbidden/high-risk/contract-changing condition or "none">
confidence: low | medium | high
evidence_paths:
  - <files/commands inspected, or "none">
blocked_reason: <only when BLOCKED or STALE; otherwise "none">
```

`BLOCKED` means prep could not complete useful read-only analysis. `STALE` means prep completed but its inspected context is no longer current enough for dispatch. Main records and discards blocked or stale prep unless the packet reports a suspected contract-changing risk, which main must evaluate through the ordinary upstream-routing rules.

If main sends a `status_request`, respond with the expected `preflight_hint` packet, including `status: BLOCKED` if no useful hint can be produced. Repeated no-evidence progress is a prep stall; main may discard the prep result because prep is optional and non-evidence.

Main may use a `READY` output to shape a compact Generator dispatch packet. Prep output is not Required Evidence and must not be cited as acceptance proof.
