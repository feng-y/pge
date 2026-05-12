---
name: pge-handoff
description: >
  Compact the current conversation into a one-off handoff document for another
  agent or future session. Matt-style observer summary only: no pipeline control,
  no knowledge extraction, no repo memory writes.
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

Write a compact handoff document so a fresh agent can continue from the current conversation.

This skill is intentionally temporary and observational. It does not extract durable knowledge, update repo docs, choose pipeline routes, or modify plans. For durable repo learning, use `pge-knowledge`.

## Process

1. Treat `ARGUMENTS:` as the intended focus of the next session.
2. Create a temporary handoff path with:

```bash
mktemp -t pge-handoff-XXXXXX.md
```

3. Read the empty file before writing to confirm the path exists.
4. Summarize only the state that a new agent cannot reliably recover from existing artifacts.
5. Reference existing artifacts by path or URL instead of duplicating their contents.
6. Write the handoff document to the temporary path.

## Include

- Current goal and requested next focus
- Relevant git state: branch, dirty files, recent commit if useful
- Files or artifacts the next agent should read
- Decisions made in conversation that are not already captured on disk
- Current blockers or open questions
- Suggested next command or skill invocation
- What to ignore: stale hypotheses, superseded attempts, unrelated exploration

## Do Not Include

- Full copies of PRDs, plans, ADRs, diffs, logs, or command output already on disk
- Knowledge extraction or recommendations to update permanent repo docs
- Speculative ideas not accepted by the user
- A new plan unless the user explicitly asked the next session to plan
- Pipeline authority claims such as marking research, plan, or exec complete

## Template

```markdown
# Handoff: <short title>

## Next Session Focus
<one paragraph>

## Current State
- Branch: <branch>
- Working tree: <clean | dirty summary>
- Current task: <one sentence>

## Read First
- <path or URL> — <why it matters>

## Conversation-Only Context
- <decision, constraint, or user preference not captured elsewhere>

## Blockers / Questions
- <blocker or "none">

## Suggested Next Step
<command or skill invocation>

## Ignore
- <stale context to avoid re-chasing>
```

## Final Response

```md
## PGE Handoff Result
- artifact: <temporary handoff path>
- focus: <next-session focus or "general continuation">
- referenced_artifacts: <count>
- next: <suggested next action>
```
