# pge-handoff

`pge-handoff` creates a temporary handoff for one focused task. The value is not the Markdown file itself; the value is using the prompt to make the agent select the relevant task slice.

Use it when the current session should stay focused, but a side task needs another fresh agent/session.

## Good Use

Write the request naturally. Do not fill out a rigid form. Make sure the request tells the agent:

- what task should move to the next session
- why it should leave the current session
- what boundaries the next session must keep
- what output should come back

Example:

```text
/pge-handoff Take the API split question we found during this planning session and package it for a fresh agent.
The parent session should stay focused on the plan gate, so the new session should only analyze whether completion signal and iteration control belong in one API or two.
Do not implement anything or expand into the whole runtime. It should return a short decision memo with evidence, risks, and any follow-up questions.
```

## Why This Works

The next agent does not need the whole parent session. It needs the smallest useful task package:

- relevant context
- constraints and non-goals
- artifact pointers
- suggested mode
- expected output
- what to ignore

Everything already recoverable from files, issues, plans, PRDs, diffs, or docs should be referenced, not copied.

## Avoid

- `/pge-handoff` with no focus
- asking it to summarize the whole conversation
- using it as `/compact`
- turning it into durable repo documentation
- asking the child session to expand scope without a clear reason
