# PGE Execute Runtime Artifacts And Progress

## Artifact Paths

Use `repo_root` as the current working directory. Create `.pge-artifacts/` if needed.

```text
run_id = "run-" + current UTC timestamp in YYYYMMDDTHHMMSSZ
artifact_dir = .pge-artifacts
input_artifact = .pge-artifacts/<run_id>-input.md
planner_artifact = .pge-artifacts/<run_id>-planner.md
generator_artifact = .pge-artifacts/<run_id>-generator.md
evaluator_artifact = .pge-artifacts/<run_id>-evaluator.md
summary_artifact = .pge-artifacts/<run_id>-summary.md
progress_artifact = .pge-artifacts/<run_id>-progress.jsonl
smoke_deliverable = .pge-artifacts/<run_id>-smoke.txt
team_name = pge-runtime-<run_id>
```

Current executable lane artifacts:

- all runs: `input_artifact`, `planner_artifact`, `evaluator_artifact`, `progress_artifact`
- larger runs may additionally persist `generator_artifact`
- `summary_artifact` is optional human-readable closeout
- deliverables are task-defined repo artifacts; for `test`, use `smoke_deliverable`

There is no required `state_artifact` in the current executable lane.
Legacy runtime-state materials may remain on disk as future design references, but they are not a required dependency for normal execution.

## Progress Artifact

`progress_artifact` is one shared append-only execution log.

- format: JSONL
- ownership: `main` only
- write mode: append-only
- dependency level: weak
- write failures must not block execution
- the progress log must never advance the run by itself

Planner, Generator, and Evaluator do not write authoritative progress directly.
They produce artifacts and runtime events; `main` records the orchestration-visible facts, friction, retries, blockers, and gate outcomes.

Each line should record one externally visible fact.
`ts` is mandatory. A progress line without timestamp has little diagnostic value.

```json
{
  "ts": "<UTC ISO8601 timestamp>",
  "run_id": "<run_id>",
  "actor": "main|planner|generator|evaluator",
  "phase": "init|planning|generation|evaluation|route|teardown",
  "event": "<short event name>",
  "status": "ok|blocked|error",
  "artifact": "<path or null>",
  "detail": "<short factual note>",
  "blocker": "<short blocker or null>",
  "latency_ms": "<optional integer or null>",
  "bytes": "<optional integer or null>",
  "command": "<optional short command or null>"
}
```

Recommended quantitative fields:

- `latency_ms`: how long the operation or wait took
- `bytes`: useful for file writes / reads
- `command`: useful for deterministic verification commands

At minimum, the log should be rich enough to answer:

- when a teammate finished its work
- when `main` received the event
- when the gate started
- when the gate passed or failed
- where the largest queue / wait gap happened

Recommended event names:

- `run_started`
- `team_created`
- `dispatch_sent`
- `task_started`
- `context_read`
- `artifact_written`
- `file_changed`
- `command_run`
- `deliverable_read`
- `gate_passed`
- `gate_failed`
- `final_verdict`
- `route_selected`
- `teardown_started`
- `teardown_finished`
- `friction`

Recommended friction examples:

- `message_timeout`
- `artifact_gate_failed`
- `agent_disconnect`
- `human_intervention`
- `phase_slow`

The progress log is for observability and later PGE improvement.
It is not a state machine, not a recovery primitive, and not a success gate.
