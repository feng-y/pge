---
name: pge-handoff
description: >
  Create a temporary, focused handoff for another agent or future session.
  Matt-style task slice only: no pipeline control, no knowledge extraction,
  no repo memory writes.
argument-hint: "<what the next session should focus on>"
allowed-tools:
  - Read
  - Write
  - Bash
  - Glob
  - Grep
  - Agent
---

# PGE Handoff

Create a temporary Markdown handoff so another fresh agent/session can handle one focused task without polluting the current session.

This is Matt-style handoff with PGE boundaries. The important skill is not writing a document; it is selecting the relevant task slice.

Use it when a side quest, prototype, bug, review, issue draft, or return summary should move to a fresh session. Do not use it as `/compact`, durable memory, repo documentation, or a PGE route decision.

For durable repo learning, use `pge-learn`.

## Process

1. Treat `ARGUMENTS:` as the next session's focus. If the focus is missing or too vague, ask for it.
2. Create a temporary file:

```bash
mktemp -t pge-handoff-XXXXXX.md
```

3. Extract only the context needed for that focused task.
4. Reference existing files, issues, plans, PRDs, ADRs, diffs, or artifacts by path/URL instead of copying them.
5. Redact secrets, API keys, passwords, tokens, private config, and unnecessary PII.
6. Write the handoff.

## Include

- Why this is being handed off
- Focus for the next agent
- Relevant context from this conversation
- Constraints and non-goals
- Suggested skills / mode
- Expected output
- References to existing artifacts
- Return handoff expectations, if the child session should report back
- What to ignore or avoid retrying

## Do Not Include

- The whole conversation
- Full copies of artifacts already on disk or online
- Raw logs, raw diffs, or long command output
- Durable knowledge extraction or repo doc updates
- Pipeline authority claims such as marking research, plan, exec, or review complete
- A new plan unless the user explicitly asked the next session to plan

## Template

```markdown
# Handoff: <next session goal>

## Why This Is Being Handed Off
<why this task should leave the current session>

## Focus For The Next Agent
<the exact bounded task>

## Relevant Context
- <only context needed for this task>

## Constraints / Non-Goals
- <what the next session must not expand into>

## Suggested Skills / Mode
- <prototype | diagnose | review | issue-writing | pge-* skill | none>

## Expected Output
<prototype, issue draft, decision memo, patch, review, diagnosis, return handoff, etc.>

## References
- <path, URL, issue, artifact, command> — <why it matters>

## Return Handoff Expectations
<what should be sent back to the parent session, or "none">

## Ignore / Do Not Retry
- <stale context or failed path to avoid>
```

## Final Response

```md
## PGE Handoff Result
- artifact: <temporary handoff path>
- focus: <next-session focus>
- suggested_mode: <mode or "none">
- referenced_artifacts: <count>
- next: <suggested next action>
```
