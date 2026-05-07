#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

fail() {
  printf 'FAIL: %s\n' "$1" >&2
  exit 1
}

require_file() {
  [[ -f "$1" ]] || fail "missing required file: $1"
}

require_pattern() {
  local file="$1"
  local pattern="$2"
  local label="$3"

  grep -Eq "$pattern" "$file" || fail "$label missing in $file"
}

require_absent_pattern() {
  local file="$1"
  local pattern="$2"
  local label="$3"

  if grep -Eq "$pattern" "$file"; then
    fail "$label found in $file"
  fi
}

require_count() {
  local file="$1"
  local pattern="$2"
  local expected="$3"
  local label="$4"
  local actual

  actual="$(grep -Ec "$pattern" "$file" || true)"
  if [[ "$actual" -ne "$expected" ]]; then
    fail "$label expected ${expected}, found ${actual} in $file"
  fi
}

for file in \
  agents/pge-planner.md \
  agents/pge-generator.md \
  agents/pge-evaluator.md \
  bin/pge-progress-report.sh \
  skills/pge-execute/SKILL.md \
  skills/pge-execute/ORCHESTRATION.md \
  skills/pge-execute/runtime/artifacts-and-state.md \
  skills/pge-execute/handoffs/planner.md \
  skills/pge-execute/handoffs/preflight.md \
  skills/pge-execute/handoffs/generator.md \
  skills/pge-execute/handoffs/evaluator.md \
  skills/pge-execute/handoffs/route-summary-teardown.md \
  skills/pge-execute/contracts/round-contract.md \
  skills/pge-execute/contracts/helper-report-contract.md \
  skills/pge-execute/contracts/routing-contract.md \
  skills/pge-execute/contracts/evaluation-contract.md \
  skills/pge-execute/contracts/runtime-event-contract.md \
  skills/pge-execute/contracts/runtime-state-contract.md \
  docs/pge-smoke-test.md \
  docs/exec-plans/ROUND_013_THREE_AGENT_WORKFLOW_HARDENING.md \
  README.md
do
  require_file "$file"
done

skill_lines="$(wc -l < skills/pge-execute/SKILL.md | tr -d ' ')"
if [[ "$skill_lines" -gt 260 ]]; then
  fail "skills/pge-execute/SKILL.md has ${skill_lines} lines; keep the entrypoint under 260 lines"
fi

if [[ "$skill_lines" -gt 220 ]]; then
  printf 'WARN: skills/pge-execute/SKILL.md has %s lines; consider slimming the entrypoint toward <= 220 lines\n' "$skill_lines" >&2
fi

require_pattern skills/pge-execute/SKILL.md 'one bounded run where Planner freezes the contract, Generator implements, and Evaluator validates' \
  "bounded P/G/E progression claim"
require_pattern skills/pge-execute/SKILL.md 'bounded same-contract `generator <-> evaluator` repair loop for retryable failures' \
  "bounded repair loop claim"
require_pattern skills/pge-execute/SKILL.md 'max generator attempts per round is 10 total attempts, including the initial generation' \
  "skill max generator attempts"
require_pattern skills/pge-execute/SKILL.md 'same `failure_signature` repeated on 3 consecutive evaluations requires a saved repair snapshot and explicit main decision before continuing' \
  "skill same failure checkpoint"
require_pattern skills/pge-execute/SKILL.md 'progress log is weak dependency only' \
  "progress weak dependency note"
require_pattern skills/pge-execute/SKILL.md 'Create the run-scoped smoke file \.pge-artifacts/<run_id>/deliverables/smoke\.txt' \
  "run-scoped smoke task"
require_pattern skills/pge-execute/SKILL.md 'do not treat teammate `idle_notification` as completion' \
  "idle notifications are not completion"
require_pattern skills/pge-execute/SKILL.md 'Use Claude Code native Agent Teams' \
  "agent teams executable claim"
require_pattern skills/pge-execute/SKILL.md 'Do not add a separate capability-check phase before execution' \
  "skill no capability pre-check rule"
require_pattern skills/pge-execute/SKILL.md 'Do not fail from tool-list inspection or other speculative pre-checks' \
  "skill no tool-list failure rule"
require_pattern skills/pge-execute/SKILL.md 'Spawn exactly three teammates:' \
  "exact three teammates rule"
require_pattern skills/pge-execute/SKILL.md 'canonical teammate-to-main message whose first non-empty line is `type: planner_contract_ready`' \
  "planner canonical event wait rule"
require_pattern skills/pge-execute/SKILL.md 'canonical teammate-to-main message whose first non-empty line is `type: generator_completion`' \
  "generator canonical event wait rule"
require_pattern skills/pge-execute/SKILL.md 'canonical teammate-to-main message whose first non-empty line is `type: final_verdict`' \
  "evaluator canonical event wait rule"
require_pattern skills/pge-execute/SKILL.md 'protocol_recovery: missing_team_message_event_artifact_gate' \
  "degraded artifact-gated recovery rule"
require_pattern skills/pge-execute/SKILL.md 'use non-canonical teammate hints, including recovery/resume recap or task-state replay, only to trigger a clarification / resend request to the same teammate; do not advance from them unless the canonical notification text is present' \
  "recovery recap non-canonical rule"
require_pattern skills/pge-execute/SKILL.md 'ignore or log support messages such as `planner_support_request` / `planner_support_response` while waiting for phase completion' \
  "skill support messages ignored while waiting"
require_pattern skills/pge-execute/SKILL.md 'keep wait/recovery observation quiet; do not expose foreground polling scripts or verbose verification transcripts as the progress model' \
  "skill quiet wait observation rule"
require_pattern skills/pge-execute/SKILL.md 'do not emit user-facing "waiting for \.\.\." chatter between dispatch and the required runtime event' \
  "no waiting chatter rule"
require_pattern skills/pge-execute/SKILL.md 'Do not insert a separate preflight or mode-decision phase into the current executable lane' \
  "no preflight gate rule"
require_pattern skills/pge-execute/SKILL.md '`planner` using `pge-planner`' \
  "planner agent binding"
require_pattern skills/pge-execute/SKILL.md 'for `test`, send implementation task to generator with `output_artifact = None` and the resolved `smoke_deliverable`' \
  "test direct generator dispatch"
require_pattern skills/pge-execute/SKILL.md 'send evaluation task to evaluator' \
  "final evaluator dispatch"
require_pattern skills/pge-execute/SKILL.md 'if `generator_completion` has `handoff_status: BLOCKED` and the artifact shows a still-local same-contract issue with a narrow `repair_direction`, send `generator_repair_request` to the resident `generator` instead of tearing down immediately' \
  "generator blocked completion redispatches resident generator when repairable"
require_pattern skills/pge-execute/SKILL.md 'if `generator_completion` has `handoff_status: BLOCKED` and the artifact does not show a still-local same-contract repair path, record the Generator blocker, do not dispatch Evaluator' \
  "generator blocked completion stops evaluator dispatch only when not repairable"
require_pattern skills/pge-execute/handoffs/generator.md 'attempt the narrow repair direction that stays inside the same Planner contract before handoff' \
  "generator internal repair before handoff"
require_pattern agents/pge-generator.md 'If local verification exposes a narrow development bug that Generator can fix within the same Planner contract, Generator should fix it during self-review instead of handing the first failed attempt to `main`' \
  "generator self-review repairs development bugs"
require_pattern agents/pge-generator.md 'If verification exposes a narrow development bug that can be fixed inside the same Planner contract, Generator should repair it before handoff instead of surfacing the first failed attempt as a terminal blocker' \
  "generator verification repairs before handoff"
require_pattern skills/pge-execute/SKILL.md 'if `planner_contract_ready` has `ready_for_generation: false`, record Planner blocker/escalation, do not dispatch Generator' \
  "planner not-ready stops generator dispatch"
require_pattern skills/pge-execute/SKILL.md 'asking generator to write any missing required durable `generator_artifact` and send that event with `handoff_status: READY_FOR_EVALUATOR` or `handoff_status: BLOCKED`' \
  "generator handoff-gap repair can return blocked completion"
require_pattern skills/pge-execute/SKILL.md 'if the real deliverable appears but `generator_artifact` or `generator_completion` is missing, treat it as a recoverable Generator handoff gap first' \
  "generator deliverable-before-event recovery rule"
require_pattern skills/pge-execute/SKILL.md 'treat failed acceptance verification, including command crash/signal/non-zero results such as exit code `139`, as task non-acceptance' \
  "skill verification failure is task failure"
require_pattern skills/pge-execute/SKILL.md 'task_status: <passed \| failed \| blocked \| unsupported>' \
  "skill final task status field"
require_pattern skills/pge-execute/SKILL.md 'teardown_status: <ok \| friction \| failed \| not_attempted>' \
  "skill final teardown status field"
require_pattern skills/pge-execute/SKILL.md '`task_status` is derived from Planner/Generator/Evaluator deliverable evidence and verification, not from teardown' \
  "skill task status separate from teardown"
require_pattern skills/pge-execute/SKILL.md 'request teammate shutdown, wait boundedly for teammate `shutdown_response` messages to `team-lead`, delete team' \
  "skill bounded shutdown ack before delete"
require_pattern skills/pge-execute/SKILL.md 'artifact and deliverable entries must be complete absolute paths copied from manifest/progress values' \
  "skill final path integrity rule"
require_pattern skills/pge-execute/SKILL.md 'if no generator message arrives and degraded recovery cannot be proven, stop with `protocol_violation: missing_team_message_event`' \
  "generator missing message hard stop"
require_pattern skills/pge-execute/SKILL.md 'for `test`, never redispatch planner, generator, or evaluator after an idle notification' \
  "no redispatch on idle rule"
require_pattern skills/pge-execute/SKILL.md 'treat `TaskUpdate\(status: completed\)` as bookkeeping only; it is not a PGE phase-completion event' \
  "taskupdate is not completion"
require_pattern skills/pge-execute/SKILL.md 'treat `TaskUpdate\(status: completed\)` as phase completion' \
  "forbidden taskupdate completion"
require_absent_pattern skills/pge-execute/SKILL.md 'state_artifact' \
  "stale state artifact reference"

require_pattern skills/pge-execute/ORCHESTRATION.md 'All tasks use the same resident P/G/E progression' \
  "orchestration P/G/E progression rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'retryable Evaluator feedback may loop back to resident Generator while the same contract remains fair' \
  "orchestration same-contract retry loop rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'require the exact `pge-planner`, `pge-generator`, and `pge-evaluator` agent surfaces' \
  "exact PGE runtime teammate surfaces rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'never replace the required Team control-plane calls with speculative capability or tool-list pre-checks' \
  "orchestration no speculative control-plane precheck"
require_pattern skills/pge-execute/ORCHESTRATION.md '\.pge-artifacts/<run_id>/deliverables/smoke\.txt' \
  "orchestration run-scoped smoke path"
require_pattern skills/pge-execute/ORCHESTRATION.md 'append-only execution log' \
  "orchestration progress log note"
require_pattern skills/pge-execute/ORCHESTRATION.md '`main` advances only after a canonical teammate-to-main `SendMessage` notification plus the matching phase gate' \
  "agent teams sendmessage gate rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'resident researcher \+ architect teammate' \
  "resident planner orchestration role"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Each teammate is a workflow actor, not a one-shot persona' \
  "resident workflow actor orchestration rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'bounded internal researcher subagents in parallel' \
  "planner multi-agent research orchestration rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Planner sends `planner_research_decision` to `main` before broad repo research for a non-test contract' \
  "planner orchestration research decision message rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Planner chooses `mode: parallel_multi_agent_research` and launches bounded internal researcher subagents in parallel before continuing serial research' \
  "planner orchestration multi-agent research before serial research"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Helper scale threshold: at least two independent evidence questions, two or more relevant subsystems/directories, or an unfamiliar nontrivial repo area' \
  "planner orchestration helper scale threshold"
require_pattern skills/pge-execute/ORCHESTRATION.md '`main` may log `planner_research_decision` as support traffic' \
  "planner research decision support traffic rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Planner freezes exactly one `current_round_slice` inside `handoff_seam`' \
  "planner current round slice orchestration rule"
require_pattern skills/pge-execute/ORCHESTRATION.md '`current_round_slice.ready_for_generator` must be true before `main` dispatches Generator' \
  "planner current round slice ready gate"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Durable helper outputs follow `skills/pge-execute/contracts/helper-report-contract.md`' \
  "orchestration helper report contract rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Foreground polling scripts and verbose verification transcripts are not the user-facing progress model' \
  "main quiet progress orchestration rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'After `planner_contract_ready`, Planner does not exit; it remains resident, available, and responsive for bounded clarification, architecture guidance, and repo research until shutdown' \
  "planner resident support rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'resident implementation teammate' \
  "resident generator orchestration role"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Generator handles directly relevant local context itself' \
  "generator offloads broad research to planner"
require_pattern skills/pge-execute/ORCHESTRATION.md 'asks resident Planner only for broad repo archaeology, architecture interpretation, contract-scope ambiguity, or multi-file research' \
  "generator planner escalation trigger"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Generator records this boundary in `planner_support_decision`' \
  "generator planner support decision orchestration rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'bounded coder workers and read-only reviewer helpers in parallel' \
  "generator helper orchestration rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'After `generator_completion`, Generator does not exit; it remains resident, available, and responsive for bounded implementation clarification or repair investigation until shutdown' \
  "generator resident support rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'resident independent validation teammate' \
  "resident evaluator orchestration role"
require_pattern skills/pge-execute/ORCHESTRATION.md 'bounded read-only verification helpers in parallel' \
  "evaluator helper orchestration rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'After `final_verdict`, Evaluator does not exit; it remains resident, available, and responsive for bounded verdict clarification until shutdown' \
  "evaluator resident support rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Recovery/resume recap and task-state replay are still non-canonical hints unless the canonical notification text is present verbatim' \
  "recovery recap orchestration rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'protocol_violation: missing_team_message_event' \
  "missing team message protocol violation rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'protocol_recovery: missing_team_message_event_artifact_gate' \
  "degraded recovery orchestration rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'TaskUpdate\(status: completed\)` is teammate bookkeeping only; it is not a phase-completion event' \
  "taskupdate orchestration non-completion rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Support messages are coordination traffic' \
  "orchestration support traffic rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Main exception handling' \
  "orchestration main exception handling section"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Capability uncertainty: do not inspect the apparent tool list and stop before execution' \
  "orchestration capability uncertainty rule"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Missing completion event: send one canonical resend request' \
  "orchestration missing completion handling"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Generator handoff gap: if the real deliverable exists but `generator.md` or `generator_completion` is missing' \
  "orchestration generator handoff gap recovery"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Task outcome and teardown outcome are separate' \
  "orchestration task teardown separation"
require_pattern skills/pge-execute/ORCHESTRATION.md 'A failed verification path, including a crash/signal/non-zero result such as exit code `139`, is a deliverable correctness failure' \
  "orchestration crash verification is task failure"
require_pattern skills/pge-execute/ORCHESTRATION.md 'bounded same-contract Generator repair path' \
  "orchestration generator repair path"
require_pattern skills/pge-execute/ORCHESTRATION.md '`main` may redispatch resident Generator when the current contract remains fair and the required fix is still local to Generator, whether the issue was first surfaced by Generator or by Evaluator' \
  "orchestration main redispatches resident generator for local issues"
require_pattern skills/pge-execute/ORCHESTRATION.md 'max generator attempts per round: 10 total attempts, including the initial generation' \
  "orchestration max generator attempts"
require_pattern skills/pge-execute/ORCHESTRATION.md 'same `failure_signature` repeated on 3 consecutive evaluations triggers a repair decision checkpoint' \
  "orchestration same failure checkpoint"
require_pattern skills/pge-execute/ORCHESTRATION.md '`main` must save a repair snapshot before deciding' \
  "orchestration repair snapshot before decision"
require_pattern skills/pge-execute/ORCHESTRATION.md '`main` sends `generator_repair_request` to `generator`' \
  "orchestration generator repair request dispatch"
require_pattern skills/pge-execute/ORCHESTRATION.md '`main` sends `evaluator_recheck_request` to `evaluator`' \
  "orchestration evaluator recheck request dispatch"
require_pattern skills/pge-execute/ORCHESTRATION.md 'Explicit blocked completion: if the Generator artifact shows a still-local same-contract issue with a narrow `repair_direction`, redispatch resident Generator' \
  "orchestration blocked completion redispatch handling"
require_pattern skills/pge-execute/ORCHESTRATION.md 'must not wait indefinitely after the single protocol repair attempt' \
  "orchestration no indefinite wait rule"
require_absent_pattern skills/pge-execute/ORCHESTRATION.md 'state\.json|state_artifact' \
  "stale orchestration state artifact reference"

require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'progress_artifact = \.pge-artifacts/<run_id>/progress\.jsonl' \
  "progress artifact path"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'manifest_artifact = \.pge-artifacts/<run_id>/manifest\.json' \
  "manifest artifact path"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'run-directory index' \
  "manifest index description"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'ownership: `main` only' \
  "main-only progress ownership rule"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'write mode: append-only' \
  "append-only progress rule"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'write failures must not block execution' \
  "progress non-blocking rule"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md '`ts` is mandatory' \
  "progress timestamp requirement"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'latency_ms' \
  "progress quantitative field note"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'There is no required `state_artifact` in the current executable lane' \
  "no state artifact rule"
require_absent_pattern skills/pge-execute/runtime/artifacts-and-state.md 'contract_proposal_artifact|preflight_artifact|state_artifact =' \
  "stale runtime artifact paths"

require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'planner_contract_ready' \
  "planner event"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'generator_completion' \
  "generator event"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'final_verdict' \
  "evaluator event"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'route_selected' \
  "route event"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'generator_repair_request' \
  "generator repair request message"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'asks resident Generator to repair a still-local same-contract issue that was surfaced either by Generator self-review/local verification or by Evaluator' \
  "generator repair request local issue semantics"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'evaluator_recheck_request' \
  "evaluator recheck request message"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'planner_research_decision' \
  "planner research decision support message"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'planner_support_request' \
  "planner support request message"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'planner_support_response' \
  "planner support response message"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'Support messages are allowed teammate coordination messages, but they are not phase-completion events and do not advance `main`' \
  "support messages non-progression rule"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'why_generator_cannot_resolve_locally' \
  "planner support local insufficiency field"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'reply_to' \
  "planner support reply_to field"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'replan_needed: true\|false' \
  "planner support replan field"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'ready_for_generation: true\|false' \
  "planner ready or blocked event"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'when `ready_for_generation: false`, `main` must record Planner blocker/escalation and stop before dispatching Generator' \
  "planner not-ready main handling"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'Generator must stop implementation and send canonical `generator_completion` with `handoff_status: BLOCKED`' \
  "planner support replan blocked completion"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'If Generator sends one `planner_support_request` and no valid `planner_support_response` arrives' \
  "generator support response missing handling"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'While `main` is waiting for a phase-completion event, support messages are neither completion hints nor protocol-repair triggers' \
  "support messages do not consume repair"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'main exception handling rule' \
  "runtime main exception handling rule"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'If a canonical BLOCKED / not-ready event arrives' \
  "runtime explicit blocked handling"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'For Generator only: if a real deliverable or artifact-written hint exists but the required `generator_artifact` or `generator_completion` is missing' \
  "runtime generator handoff gap recovery"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'Generator handoff-gap repair overrides this generic event-only resend' \
  "runtime generator repair overrides generic resend"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md '`main` must not convert a visible generated deliverable plus missing Generator handoff artifacts directly into route BLOCK' \
  "runtime no direct block on generator handoff gap"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md '`main` must not spin indefinitely after one repair attempt' \
  "runtime no indefinite wait rule"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'send the canonical notification shape for the phase, using a blocked / not-ready status when the phase cannot complete' \
  "notification repair rule"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'PGE currently targets Claude Code Agent Teams for runtime execution' \
  "agent teams runtime target"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'canonical runtime event must be delivered as a teammate-to-main team message through `SendMessage`' \
  "teammate to main sendmessage rule"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'The teammate-to-main message is the only legal progression trigger in the current Agent Teams lane' \
  "team-only legal progression trigger rule"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'must not infer control-plane absence from an apparent tool list or capability pre-check' \
  "runtime no speculative control-plane inference"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'TaskUpdate\(status: completed\)` is task bookkeeping only' \
  "taskupdate runtime non-completion rule"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'recovery / resume recap' \
  "recovery recap runtime hint"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'TaskUpdate\(status: completed\)` / task-list completion' \
  "taskupdate runtime non-canonical hint"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'canonical notification text only, with no recap, summary wrapper, idle wrapper, or explanatory prefix' \
  "canonical resend only rule"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'protocol_violation: missing_team_message_event' \
  "missing team message runtime violation"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'protocol_recovery: missing_team_message_event_artifact_gate' \
  "missing team message degraded runtime recovery"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'This is degraded progression, not a normal pass' \
  "degraded progression distinction"
require_absent_pattern skills/pge-execute/contracts/runtime-event-contract.md 'terminal_response|push_event' \
  "no codex terminal response branch"
require_absent_pattern skills/pge-execute/contracts/runtime-event-contract.md 'advances only when it receives a valid runtime event' \
  "stale event-only progression rule"
require_absent_pattern skills/pge-execute/contracts/runtime-event-contract.md 'mode_decision|proposal_ready|preflight_decision|ready_for_preflight' \
  "stale preflight events"

require_pattern skills/pge-execute/contracts/evaluation-contract.md 'record `verification_helper_decision` in `## independent_verification`' \
  "evaluation contract verification helper decision"
require_pattern skills/pge-execute/contracts/round-contract.md '`multi_agent_research_decision`: `mode`, `scale_threshold_met`, `researcher_count`, `research_questions`, `dispatch_timing`, `research_report_refs`, and `not_parallel_reason`' \
  "round contract planner multi-agent research decision shape"
require_pattern skills/pge-execute/contracts/round-contract.md 'make the multi-agent research decision before broad repo research, after only small intake' \
  "round contract planner multi-agent research decision timing"
require_pattern skills/pge-execute/contracts/round-contract.md 'The scale threshold is met when repo understanding requires at least two independent evidence questions, spans two or more relevant subsystems/directories, or targets an unfamiliar nontrivial repo area' \
  "round contract planner scale threshold"
require_pattern skills/pge-execute/contracts/round-contract.md 'When the threshold is unclear after small intake on an unfamiliar or nontrivial repo task, treat it as met' \
  "round contract unclear threshold defaults to met"
require_pattern skills/pge-execute/contracts/round-contract.md 'When the threshold is met and Planner chooses `mode: solo_research`, `multi_agent_research_decision.not_parallel_reason` must state the concrete exception' \
  "round contract solo research exception"
require_pattern skills/pge-execute/contracts/round-contract.md 'Planner should also have sent a `planner_research_decision` support message to `main` before broad repo research' \
  "round contract planner research decision support message"
require_pattern skills/pge-execute/contracts/round-contract.md 'current round slice shape' \
  "round contract current round slice section"
require_pattern skills/pge-execute/contracts/round-contract.md '`handoff_seam` should include exactly one `current_round_slice`' \
  "round contract current round slice required"
require_pattern skills/pge-execute/contracts/round-contract.md '`ready_for_generator: true\|false`' \
  "round contract current round slice ready field"
require_pattern skills/pge-execute/contracts/runtime-state-contract.md 'active_slice_ref` maps to Planner'\''s single `handoff_seam.current_round_slice.slice_id`' \
  "runtime state current slice mapping"
require_pattern skills/pge-execute/contracts/helper-report-contract.md '\.pge-artifacts/<run_id>/helpers/<phase>/<helper_id>\.md' \
  "helper report location contract"
require_pattern skills/pge-execute/contracts/helper-report-contract.md 'Helper reports are advisory evidence only' \
  "helper report advisory rule"
require_pattern skills/pge-execute/contracts/helper-report-contract.md '`## helper_scope`' \
  "helper report minimum helper scope"
require_pattern skills/pge-execute/contracts/helper-report-contract.md '`## sources_checked`' \
  "helper report minimum sources checked"
require_pattern skills/pge-execute/contracts/helper-report-contract.md '`## authority_boundary`' \
  "helper report authority boundary section"
require_pattern skills/pge-execute/contracts/helper-report-contract.md 'Phase-owner artifacts must reference helper reports when helpers were used' \
  "helper report phase owner reference rule"
require_pattern skills/pge-execute/contracts/evaluation-contract.md 'Task size changes audit depth, not the required verdict section shape' \
  "evaluation contract current-stage depth rule"
require_pattern skills/pge-execute/contracts/evaluation-contract.md 'selecting execution mode or adding a preflight gate' \
  "evaluation contract no preflight ownership"
require_absent_pattern skills/pge-execute/contracts/evaluation-contract.md 'FAST_PATH|LITE_PGE|FULL_PGE|LONG_RUNNING_PGE|execution cost gate|During preflight|preflight lane' \
  "stale evaluation mode/preflight vocabulary"

require_pattern skills/pge-execute/contracts/routing-contract.md 'Planner `stop_condition`' \
  "routing contract planner stop condition"
require_pattern skills/pge-execute/contracts/routing-contract.md '`converged` is the only successful terminal route in the current executable lane' \
  "routing contract current-stage terminal route"
require_pattern skills/pge-execute/contracts/routing-contract.md 'progress/summary output' \
  "routing contract no runtime-state route persistence"
require_pattern skills/pge-execute/contracts/routing-contract.md 'max generator attempts per round: 10 total attempts, including the initial generation' \
  "routing max generator attempts"
require_pattern skills/pge-execute/contracts/routing-contract.md 'repeated same failure threshold: same `failure_signature` on 3 consecutive evaluations requires a saved repair snapshot and explicit main decision before continuing' \
  "routing same failure threshold"
require_absent_pattern skills/pge-execute/contracts/routing-contract.md 'FAST_PATH|LITE_PGE|FULL_PGE|LONG_RUNNING_PGE|runtime state|run_stop_condition|route-to-state|Stage 2' \
  "stale routing mode/state vocabulary"

require_pattern skills/pge-execute/handoffs/preflight.md 'not part of the current executable lane' \
  "archived preflight note"

require_pattern skills/pge-execute/handoffs/planner.md 'ready_for_generation: true' \
  "planner ready_for_generation event"
require_pattern skills/pge-execute/handoffs/planner.md 'your final action for the initial planning deliverable must be `SendMessage` to `main`' \
  "planner sendmessage completion rule"
require_pattern skills/pge-execute/handoffs/planner.md 'The final action must still be SendMessage for the initial planning deliverable' \
  "planner sendmessage completion rule"
require_pattern skills/pge-execute/handoffs/planner.md 'resident researcher \+ architect workflow actor' \
  "planner handoff resident role"
require_pattern skills/pge-execute/handoffs/planner.md 'stay alive for the whole PGE run, do not exit after writing the plan, and remain responsive until `main` sends `shutdown_request`' \
  "planner handoff stay alive rule"
require_pattern skills/pge-execute/handoffs/planner.md 'bounded parallel research helpers' \
  "planner handoff parallel helper rule"
require_pattern skills/pge-execute/handoffs/planner.md 'before broad repo research for a non-test contract, send `planner_research_decision` to `main`; later repeat the final `multi_agent_research_decision` in `## planner_note`' \
  "planner handoff research decision message required"
require_pattern skills/pge-execute/handoffs/planner.md 'allowed intake before this decision is small' \
  "planner handoff small intake before helper decision"
require_pattern skills/pge-execute/handoffs/planner.md 'do not perform multiple serial `Read` calls, read a long doc/source file, or inspect neighboring examples before deciding whether multi-agent research is needed' \
  "planner handoff no serial reads before multi-agent decision"
require_pattern skills/pge-execute/handoffs/planner.md 'the scale threshold activates helper research when repo understanding requires at least two independent evidence questions, spans two or more relevant subsystems/directories, or targets an unfamiliar nontrivial repo area' \
  "planner handoff helper scale threshold"
require_pattern skills/pge-execute/handoffs/planner.md 'if the threshold is unclear after the small intake and the repo/task is unfamiliar or nontrivial, treat the threshold as met' \
  "planner handoff unclear threshold defaults to met"
require_pattern skills/pge-execute/handoffs/planner.md 'if the scale threshold is met and subagents are available, choose `mode: parallel_multi_agent_research` and launch 1-2 read-only researcher subagents before continuing serial research' \
  "planner handoff parallel multi-agent research mode"
require_pattern skills/pge-execute/handoffs/planner.md 'record `multi_agent_research_decision` with `mode`, `scale_threshold_met`, `researcher_count`, `research_questions`, `dispatch_timing`, `research_report_refs`, and `not_parallel_reason`' \
  "planner handoff multi-agent research decision fields"
require_pattern skills/pge-execute/handoffs/planner.md 'when `scale_threshold_met: true` and `mode: solo_research`, `multi_agent_research_decision.not_parallel_reason` must be concrete' \
  "planner handoff solo research exception"
require_pattern skills/pge-execute/handoffs/planner.md 'type: planner_research_decision' \
  "planner handoff research decision message shape"
require_pattern skills/pge-execute/handoffs/planner.md 'This support message does not complete planning' \
  "planner handoff research decision non-completion rule"
require_pattern skills/pge-execute/handoffs/planner.md '`## planner_note` includes `multi_agent_research_decision.mode`, `scale_threshold_met`, `researcher_count`, `research_questions`, `dispatch_timing`, `research_report_refs`, and `not_parallel_reason`' \
  "planner gate multi-agent decision field gate"
require_pattern skills/pge-execute/handoffs/planner.md '`## handoff_seam` must include exactly one `current_round_slice`' \
  "planner handoff current round slice required"
require_pattern skills/pge-execute/handoffs/planner.md '`## handoff_seam.current_round_slice` includes `slice_id`, `ready_for_generator`, `dependency_refs`, `blocked_by`, `parallelizable`, `verification_path`, and `handoff_refs`' \
  "planner handoff current round slice fields"
require_pattern skills/pge-execute/handoffs/planner.md 'if `current_round_slice.ready_for_generator` is false, the canonical event must use `ready_for_generation: false`' \
  "planner handoff current round slice blocked gate"
require_pattern skills/pge-execute/handoffs/planner.md 'launch independent repo-understanding questions concurrently' \
  "planner handoff concurrent helper rule"
require_pattern skills/pge-execute/handoffs/planner.md 'default helpers: 0-2; normal maximum: 3; hard maximum: 4' \
  "planner helper limit rule"
require_pattern skills/pge-execute/handoffs/planner.md 'remain available for bounded plan clarification, architecture guidance, and repo research until `main` sends `shutdown_request`' \
  "planner post-plan guidance role"
require_pattern skills/pge-execute/handoffs/planner.md 'launch bounded read-only helper research lanes concurrently' \
  "planner post-plan concurrent research lanes"
require_pattern skills/pge-execute/handoffs/planner.md 'helper-report-contract.md' \
  "planner handoff helper report contract"
require_pattern skills/pge-execute/handoffs/planner.md 'when receiving `planner_support_request`, respond with `SendMessage\(to="<reply_to>", message="<plain-string planner_support_response>"\)`' \
  "planner support response handoff rule"
require_pattern skills/pge-execute/handoffs/planner.md '`planner_support_response` is advisory and is not a replacement for `planner_contract_ready`' \
  "planner support non-progression handoff rule"
require_pattern skills/pge-execute/handoffs/planner.md 'ready_for_generation: true\|false' \
  "planner handoff ready or blocked event"
require_pattern skills/pge-execute/handoffs/planner.md 'Do not omit the event when planning is blocked' \
  "planner blocked still sends event"
require_pattern skills/pge-execute/handoffs/planner.md 'resend only the exact canonical event text above' \
  "planner canonical resend rule"
require_pattern skills/pge-execute/handoffs/planner.md 'Do not only write the artifact' \
  "planner artifact existence not completion"
require_pattern skills/pge-execute/handoffs/planner.md 'Do not call `TaskUpdate\(status: completed\)` as the completion signal' \
  "planner taskupdate not completion"
require_pattern skills/pge-execute/handoffs/planner.md 'Do not call `TaskUpdate\(status: completed\)` for the planning phase at all' \
  "planner no completed taskupdate"
require_pattern skills/pge-execute/handoffs/planner.md 'After this SendMessage, do not exit; remain resident, available, and responsive for bounded clarification, guidance, and research until shutdown' \
  "planner handoff remain responsive after sendmessage"
require_absent_pattern skills/pge-execute/handoffs/planner.md 'write state|update progress only when enabled|ready_for_preflight' \
  "planner stale state logic"

require_pattern skills/pge-execute/handoffs/generator.md 'smoke_deliverable: <smoke_deliverable or None>' \
  "generator smoke path input"
require_pattern skills/pge-execute/handoffs/generator.md 'type: generator_completion' \
  "generator completion event schema"
require_pattern skills/pge-execute/handoffs/generator.md 'your final action must be `SendMessage` to `main` with the exact canonical completion event below' \
  "generator sendmessage completion rule"
require_pattern skills/pge-execute/handoffs/generator.md 'resend only the exact canonical `generator_completion` text' \
  "generator canonical resend rule"
require_pattern skills/pge-execute/handoffs/generator.md 'Do not only write the artifact' \
  "generator artifact existence not completion"
require_pattern skills/pge-execute/handoffs/generator.md 'Do not call `TaskUpdate\(status: completed\)` as the completion signal' \
  "generator taskupdate not completion"
require_pattern skills/pge-execute/handoffs/generator.md 'Do not ask Planner for routine local context' \
  "generator handoff planner research support"
require_pattern skills/pge-execute/handoffs/generator.md 'Ask resident Planner only when implementation needs broad repo research, architecture interpretation, contract-scope clarification, or multi-file pattern discovery' \
  "generator handoff planner trigger"
require_pattern skills/pge-execute/handoffs/generator.md 'if the same required fix or `failure_signature` fails again' \
  "generator repeated failure record"
require_pattern skills/pge-execute/handoffs/generator.md 'type: generator_repair_request' \
  "generator repair request dispatch shape"
require_pattern skills/pge-execute/handoffs/generator.md 'send a fresh canonical `generator_completion` to `main`' \
  "generator repair completion response"
require_pattern skills/pge-execute/handoffs/generator.md 'read `handoff_seam.current_round_slice` before acting' \
  "generator reads current round slice"
require_pattern skills/pge-execute/handoffs/generator.md 'keep implementation inside the named `current_round_slice`' \
  "generator current round slice boundary"
require_pattern skills/pge-execute/handoffs/generator.md 'record the decision in `planner_support_decision`' \
  "generator planner support decision record rule"
require_pattern skills/pge-execute/handoffs/generator.md '## planner_support_decision' \
  "generator planner support artifact section"
require_pattern skills/pge-execute/handoffs/generator.md 'SendMessage\(to="planner", message="<plain-string planner_support_request>"\)' \
  "generator planner support request handoff"
require_pattern skills/pge-execute/handoffs/generator.md 'wait for Planner to reply with `SendMessage\(to="generator", message="<plain-string planner_support_response>"\)`' \
  "generator waits for direct planner support response"
require_pattern skills/pge-execute/handoffs/generator.md 'if no valid `planner_support_response` arrives after the support wait / clarification attempt' \
  "generator missing support response blocked completion"
require_pattern skills/pge-execute/handoffs/generator.md 'stop implementation, write the durable Generator artifact when required, and send canonical `generator_completion` to `main` with `handoff_status: BLOCKED`' \
  "generator missing support writes durable artifact"
require_pattern skills/pge-execute/handoffs/generator.md 'run local verification against Planner'"'"'s `verification_path` and acceptance criteria when practical' \
  "generator verifies planner verification path"
require_pattern skills/pge-execute/handoffs/generator.md 'if a required verification command fails, crashes, exits by signal, or returns a non-zero code such as `139`' \
  "generator crash verification blocks ready"
require_pattern skills/pge-execute/handoffs/generator.md 'do not treat `planner_support_response` as approval, route, or phase completion' \
  "generator planner support response non-approval rule"
require_pattern skills/pge-execute/handoffs/generator.md 'still send canonical `generator_completion` to `main` with `handoff_status: BLOCKED`' \
  "generator replan blocked completion"
require_pattern skills/pge-execute/handoffs/generator.md 'bounded coder workers' \
  "generator handoff coder worker rule"
require_pattern skills/pge-execute/handoffs/generator.md 'bounded reviewer helpers' \
  "generator handoff reviewer helper rule"
require_pattern skills/pge-execute/handoffs/generator.md 'launch independent coder/reviewer lanes concurrently' \
  "generator handoff concurrent helper rule"
require_pattern skills/pge-execute/handoffs/generator.md 'Before editing, make a visible `helper_decision`' \
  "generator handoff helper decision rule"
require_pattern skills/pge-execute/handoffs/generator.md 'If two or more independent implementation units exist, use coder workers unless conflict risk or helper overhead makes that worse' \
  "generator handoff coder trigger rule"
require_pattern skills/pge-execute/handoffs/generator.md 'If code was changed and a reviewer helper is available, use at least one read-only reviewer helper before handoff unless the change is trivial or smoke/test-only' \
  "generator handoff reviewer trigger rule"
require_pattern skills/pge-execute/handoffs/generator.md '## helper_decision' \
  "generator helper decision artifact section"
require_pattern skills/pge-execute/handoffs/generator.md 'when durable Generator output is required, `## planner_support_decision` exists' \
  "generator planner support gate"
require_pattern skills/pge-execute/handoffs/generator.md 'record `helper_decision` with counts, reason, parallel units, not-using reason, and helper report identifiers or `None`' \
  "generator helper decision content"
require_pattern skills/pge-execute/handoffs/generator.md 'helper-report-contract.md' \
  "generator handoff helper report contract"
require_pattern skills/pge-execute/handoffs/generator.md 'You remain the only implementation lead, integrator, artifact owner, and `generator_completion` sender' \
  "generator handoff ownership rule"
require_pattern skills/pge-execute/handoffs/generator.md 'Do not call `TaskUpdate\(status: completed\)` for the generation phase at all' \
  "generator no completed taskupdate"
require_pattern skills/pge-execute/handoffs/generator.md 'The final action must still be SendMessage for the initial generation deliverable' \
  "generator sendmessage completion continuation rule"
require_pattern skills/pge-execute/handoffs/generator.md 'After SendMessage in Agent Teams mode, do not exit; remain resident, available, and responsive for bounded implementation clarification, evidence questions, and repair investigation until shutdown' \
  "generator handoff remain responsive after sendmessage"
require_absent_pattern skills/pge-execute/handoffs/generator.md 'preflight_artifact|contract_proposal_artifact|write state' \
  "generator stale preflight/state logic"

require_pattern skills/pge-execute/handoffs/evaluator.md 'smoke_deliverable: <smoke_deliverable or None>' \
  "evaluator smoke path input"
require_pattern skills/pge-execute/handoffs/evaluator.md 'type: final_verdict' \
  "evaluator final verdict event schema"
require_pattern skills/pge-execute/handoffs/evaluator.md 'your final action must be `SendMessage` to `main` with exactly this canonical runtime event' \
  "evaluator sendmessage completion rule"
require_pattern skills/pge-execute/handoffs/evaluator.md 'resend only the exact canonical `final_verdict` text above' \
  "evaluator canonical resend rule"
require_pattern skills/pge-execute/handoffs/evaluator.md 'Do not only write the artifact' \
  "evaluator artifact existence not completion"
require_pattern skills/pge-execute/handoffs/evaluator.md 'Do not call `TaskUpdate\(status: completed\)` as the completion signal' \
  "evaluator taskupdate not completion"
require_pattern skills/pge-execute/handoffs/evaluator.md 'resident independent validation teammate' \
  "evaluator handoff resident role"
require_pattern skills/pge-execute/handoffs/evaluator.md 'bounded read-only verification helpers' \
  "evaluator handoff helper rule"
require_pattern skills/pge-execute/handoffs/evaluator.md 'launch independent verification lanes concurrently' \
  "evaluator handoff concurrent helper rule"
require_pattern skills/pge-execute/handoffs/evaluator.md 'Before evaluating deeply, make a visible `verification_helper_decision`' \
  "evaluator handoff helper decision rule"
require_pattern skills/pge-execute/handoffs/evaluator.md 'If two or more independent evidence/deliverable checks exist, use verification helpers unless helper overhead would make evaluation slower or weaker' \
  "evaluator handoff helper trigger rule"
require_pattern skills/pge-execute/handoffs/evaluator.md 'record `verification_helper_decision` in `## independent_verification`' \
  "evaluator helper decision artifact content"
require_pattern skills/pge-execute/handoffs/evaluator.md 'helper-report-contract.md' \
  "evaluator handoff helper report contract"
require_pattern skills/pge-execute/handoffs/evaluator.md 'independently check Planner'"'"'s `verification_path` and acceptance criteria when practical' \
  "evaluator checks planner verification path"
require_pattern skills/pge-execute/handoffs/evaluator.md 'inspect `handoff_seam.current_round_slice`' \
  "evaluator current round slice inspection"
require_pattern skills/pge-execute/handoffs/evaluator.md 'if an acceptance-required command fails, crashes, exits by signal, or returns a non-zero code such as `139`, verdict must not be `PASS`' \
  "evaluator crash verification is not pass"
require_pattern skills/pge-execute/handoffs/evaluator.md 'distinguish deliverable correctness failure from runtime-team teardown failure' \
  "evaluator separates task failure from teardown"
require_pattern skills/pge-execute/handoffs/evaluator.md 'record a stable `failure_signature` for non-PASS verdicts' \
  "evaluator failure signature"
require_pattern skills/pge-execute/handoffs/evaluator.md 'if the same `failure_signature` remains after repair' \
  "evaluator repeated failure handling"
require_pattern skills/pge-execute/handoffs/evaluator.md 'You remain the only verdict owner, next-route signal owner, artifact owner, and `final_verdict` sender' \
  "evaluator handoff ownership rule"
require_pattern skills/pge-execute/handoffs/evaluator.md 'type: evaluator_recheck_request' \
  "evaluator recheck request dispatch shape"
require_pattern skills/pge-execute/handoffs/evaluator.md 'send a fresh canonical `final_verdict` to `main`' \
  "evaluator recheck completion response"
require_pattern skills/pge-execute/handoffs/evaluator.md 'answer bounded post-verdict clarification about evidence, violated criteria, required fixes, and route reasoning' \
  "evaluator clarification boundary"
require_pattern skills/pge-execute/handoffs/evaluator.md 'do not use Planner or Generator clarification as a substitute for independent verification' \
  "evaluator clarification not evidence substitute"
require_pattern skills/pge-execute/handoffs/evaluator.md 'do not issue a changed verdict unless `main` dispatches bounded re-evaluation' \
  "evaluator no silent verdict change"
require_pattern skills/pge-execute/handoffs/evaluator.md 'Do not call `TaskUpdate\(status: completed\)` for the evaluation phase at all' \
  "evaluator no completed taskupdate"
require_pattern skills/pge-execute/handoffs/evaluator.md 'The final action must still be SendMessage for the initial evaluation deliverable' \
  "evaluator sendmessage completion continuation rule"
require_pattern skills/pge-execute/handoffs/evaluator.md 'After this SendMessage, do not exit; remain resident, available, and responsive for bounded verdict clarification until shutdown' \
  "evaluator handoff remain responsive after sendmessage"
require_pattern skills/pge-execute/handoffs/evaluator.md 'if verdict is `PASS`, `next_route` must be `converged`' \
  "test pass implies converged rule"
require_absent_pattern skills/pge-execute/handoffs/evaluator.md 'preflight_artifact|contract_proposal_artifact|write state|compact_scores' \
  "evaluator stale preflight/state logic"

require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'Append a best-effort progress log entry after route selection' \
  "route progress log rule"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'SendMessage\(to="planner", message="type: shutdown_request"\)' \
  "plain-string shutdown message"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'Each teammate must answer shutdown with `SendMessage\(to="team-lead", message="<plain-string shutdown_response>"\)`' \
  "shutdown response to team-lead rule"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'Do not call `TeamDelete` until the bounded shutdown_response wait has completed' \
  "bounded shutdown ack before TeamDelete"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'Missing shutdown_response messages after the bounded wait are teardown friction' \
  "missing shutdown ack is teardown friction"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'Final text artifact paths must be copied from the manifest/progress values as complete absolute paths' \
  "final artifact path integrity rule"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md '^TeamDelete\(\)$' \
  "zero-arg TeamDelete call"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md '`status = SUCCESS` is valid only when `verdict = PASS` and `route = converged`' \
  "success status mapping"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'do not convert `retry` to `unsupported_route`; preserve `retry` when the bounded repair loop stops without convergence' \
  "route summary preserves retry route"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'progress log path when `progress_artifact` exists' \
  "summary progress log path"
require_absent_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'state:' \
  "route event stale state field"

require_pattern agents/pge-generator.md 'If orchestration omits `output_artifact`' \
  "generator optional durable artifact rule"
require_pattern agents/pge-generator.md 'type: generator_completion' \
  "generator runtime event rule"
require_pattern agents/pge-generator.md 'tools: Read, Write, Edit, Bash, Grep, Glob, Agent, SendMessage' \
  "generator Agent and SendMessage tools"
require_pattern agents/pge-generator.md 'Generator is a resident implementation workflow actor' \
  "generator resident workflow model"
require_pattern agents/pge-generator.md 'Planner support boundary' \
  "generator planner support boundary"
require_pattern agents/pge-generator.md 'do not ask Planner for routine local context' \
  "generator asks planner for broad research"
require_pattern agents/pge-generator.md 'ask resident Planner only for broad repo research, architecture interpretation, contract-scope clarification, or multi-file pattern discovery' \
  "generator planner trigger boundary"
require_pattern agents/pge-generator.md 'record the decision in `planner_support_decision`' \
  "generator planner support decision"
require_pattern agents/pge-generator.md '## Planner support protocol' \
  "generator planner support protocol section"
require_pattern agents/pge-generator.md 'type: planner_support_request' \
  "generator planner support request shape"
require_pattern agents/pge-generator.md 'SendMessage\(to="planner", message="<the plain-string planner_support_request>"\)' \
  "generator direct support request sendmessage"
require_pattern agents/pge-generator.md 'Planner must respond with `SendMessage\(to="generator", message="<plain-string planner_support_response>"\)`' \
  "generator direct support response"
require_pattern agents/pge-generator.md 'If no valid Planner response arrives after the support wait / clarification attempt' \
  "generator missing planner support response"
require_pattern agents/pge-generator.md 'used_planner_support: true\|false' \
  "generator planner support decision fields"
require_pattern agents/pge-generator.md 'still send canonical `generator_completion` to `main` with `handoff_status: BLOCKED`' \
  "generator blocked completion after replan"
require_pattern agents/pge-generator.md 'bounded coder workers' \
  "generator coder worker model"
require_pattern agents/pge-generator.md 'bounded reviewer helpers' \
  "generator reviewer helper model"
require_pattern agents/pge-generator.md 'launch independent lanes in parallel/concurrently' \
  "generator concurrent helper model"
require_pattern agents/pge-generator.md 'Before editing, you MUST make a visible `helper_decision`' \
  "generator helper decision required"
require_pattern agents/pge-generator.md '`helper_decision` fields' \
  "generator helper decision fields"
require_pattern agents/pge-generator.md 'if there are two or more independent implementation units, use coder workers unless conflict risk or helper overhead would make that worse' \
  "generator coder worker trigger"
require_pattern agents/pge-generator.md 'if code was changed and a reviewer helper is available, use at least one read-only reviewer helper before handoff unless the change is trivial or smoke/test-only' \
  "generator reviewer helper trigger"
require_pattern agents/pge-generator.md 'helper_decision.not_using_helpers_reason' \
  "generator helper non-use explanation"
require_pattern agents/pge-generator.md 'Generator remains the only implementation lead, integrator, artifact owner, and `generator_completion` sender' \
  "generator integration ownership"
require_pattern agents/pge-generator.md 'resend only the canonical `generator_completion` text' \
  "generator resend wording"
require_pattern agents/pge-generator.md 'your work is not complete until you `SendMessage` the canonical runtime event to `main`' \
  "generator work not complete until sendmessage"
require_pattern agents/pge-generator.md 'Do not use `TaskUpdate\(status: completed\)` as the PGE phase-completion signal' \
  "generator taskupdate not completion"
require_pattern agents/pge-generator.md '## Completion protocol \(MANDATORY\)' \
  "generator mandatory completion protocol"
require_pattern agents/pge-generator.md 'Do NOT call `TaskUpdate\(status: completed\)` for the generation phase' \
  "generator no completed taskupdate in completion"
require_pattern agents/pge-generator.md 'After SendMessage, do not exit; remain resident, available, and responsive for bounded implementation clarification until `main` sends `shutdown_request`' \
  "generator remains resident after sendmessage"
require_pattern agents/pge-generator.md 'If `main` sends a protocol repair request after a deliverable exists but `generator_artifact` or `generator_completion` is missing' \
  "generator repairs missing handoff after deliverable"
require_pattern agents/pge-generator.md 'Runtime retry is the current bounded same-contract Generator repair loop' \
  "generator retry current support"
require_pattern agents/pge-generator.md '`main` only decides whether to redispatch the resident Generator; Generator owns the actual repair workflow' \
  "generator owns repair workflow"
require_pattern agents/pge-generator.md 'SendMessage to `team-lead` with a plain-string shutdown response' \
  "generator shutdown response target"
require_absent_pattern agents/pge-generator.md 'proposal_ready|preflight validated' \
  "generator stale preflight role text"

require_pattern agents/pge-evaluator.md 'You own final independent deliverable validation' \
  "evaluator ownership rule"
require_pattern agents/pge-evaluator.md 'final_verdict' \
  "evaluator final verdict rule"
require_pattern agents/pge-evaluator.md 'tools: Read, Write, Bash, Grep, Glob, Agent, SendMessage' \
  "evaluator Agent and SendMessage tools"
require_pattern agents/pge-evaluator.md 'Evaluator is a resident independent validation teammate with an internal workflow' \
  "evaluator resident workflow model"
require_pattern agents/pge-evaluator.md 'bounded read-only verification helpers' \
  "evaluator verification helper model"
require_pattern agents/pge-evaluator.md 'launch independent verification lanes in parallel/concurrently' \
  "evaluator concurrent helper model"
require_pattern agents/pge-evaluator.md 'Before evaluating deeply, you MUST make a visible `verification_helper_decision`' \
  "evaluator helper decision required"
require_pattern agents/pge-evaluator.md '`verification_helper_decision` fields' \
  "evaluator helper decision fields"
require_pattern agents/pge-evaluator.md 'if there are two or more independent evidence/deliverable checks and helpers are available, use verification helpers unless helper overhead would make evaluation slower or weaker' \
  "evaluator helper trigger"
require_pattern agents/pge-evaluator.md 'if the Generator used coder workers, use at least one read-only verification helper unless the changed surface is trivial or smoke/test-only' \
  "evaluator worker follow-up helper trigger"
require_pattern agents/pge-evaluator.md 'Evaluator remains the only verdict owner and `final_verdict` sender' \
  "evaluator verdict ownership"
require_pattern agents/pge-evaluator.md 'Clarification boundary' \
  "evaluator clarification boundary section"
require_pattern agents/pge-evaluator.md 'do not use Generator or Planner clarification as a substitute for independent verification' \
  "evaluator independent verification preserved"
require_pattern agents/pge-evaluator.md 'turning clarification into a new verdict without `main` dispatch' \
  "evaluator no changed verdict without dispatch"
require_pattern agents/pge-evaluator.md 'resend only the canonical `final_verdict` text' \
  "evaluator resend wording"
require_pattern agents/pge-evaluator.md 'your work is not complete until you `SendMessage` the canonical runtime event to `main`' \
  "evaluator work not complete until sendmessage"
require_pattern agents/pge-evaluator.md 'Do not use `TaskUpdate\(status: completed\)` as the PGE phase-completion signal' \
  "evaluator taskupdate not completion"
require_pattern agents/pge-evaluator.md '## Completion protocol \(MANDATORY\)' \
  "evaluator mandatory completion protocol"
require_pattern agents/pge-evaluator.md 'Do NOT call `TaskUpdate\(status: completed\)` for the evaluation phase' \
  "evaluator no completed taskupdate in completion"
require_pattern agents/pge-evaluator.md 'After SendMessage, do not exit; remain resident, available, and responsive for bounded verdict clarification until `main` sends `shutdown_request`' \
  "evaluator remains resident after sendmessage"
require_pattern agents/pge-evaluator.md 'SendMessage to `team-lead` with a plain-string shutdown response' \
  "evaluator shutdown response target"
require_absent_pattern agents/pge-evaluator.md 'mode_decision|pre-generation execution mode decision|runtime-state-contract' \
  "evaluator stale preflight/state role text"

require_absent_pattern agents/pge-planner.md 'FAST_PATH|LITE_PGE|FULL_PGE|LONG_RUNNING_PGE' \
  "planner stale mode labels"
require_pattern agents/pge-planner.md 'tools: Read, Write, Grep, Glob, Agent, SendMessage' \
  "planner SendMessage tool"
require_pattern agents/pge-planner.md 'Planner is a resident researcher \+ architect teammate with an internal workflow' \
  "planner resident workflow model"
require_pattern agents/pge-planner.md 'stay alive for the whole PGE run until `main` sends `shutdown_request`' \
  "planner stay alive invariant"
require_pattern agents/pge-planner.md 'do not exit, self-complete, or mark the planning phase completed after writing the plan' \
  "planner no exit invariant"
require_pattern agents/pge-planner.md 'respond to bounded clarification / guidance / research requests from `main` or Generator after the initial contract is ready' \
  "planner responsive invariant"
require_pattern agents/pge-planner.md 'research / architecture advisor' \
  "planner post-plan research architecture role"
require_pattern agents/pge-planner.md 'bounded parallel research helpers' \
  "planner parallel research helper model"
require_pattern agents/pge-planner.md 'Before broad repo research for a non-test contract, you MUST send `planner_research_decision` to `main`; later repeat the final `multi_agent_research_decision` inside `planner_note`' \
  "planner research decision message required"
require_pattern agents/pge-planner.md 'Allowed intake before this decision is small' \
  "planner small intake before helper decision"
require_pattern agents/pge-planner.md 'Do not perform multiple serial `Read` calls, read a long doc/source file, or inspect neighboring examples before deciding whether multi-agent research is needed' \
  "planner no serial reads before multi-agent decision"
require_pattern agents/pge-planner.md 'The scale threshold activates helper research when repo understanding requires at least two independent evidence questions, spans two or more relevant subsystems/directories, or targets an unfamiliar nontrivial repo area' \
  "planner helper scale threshold"
require_pattern agents/pge-planner.md 'If the threshold is unclear after the small intake and the repo/task is unfamiliar or nontrivial, treat the threshold as met' \
  "planner unclear threshold defaults to met"
require_pattern agents/pge-planner.md 'If the scale threshold is met and subagents are available, choose `mode: parallel_multi_agent_research` and launch 1-2 read-only researcher subagents before continuing serial research' \
  "planner parallel multi-agent research mode"
require_pattern agents/pge-planner.md '`multi_agent_research_decision` fields: `mode: solo_research\|parallel_multi_agent_research`, `scale_threshold_met: true\|false`, `researcher_count`, `research_questions`, `dispatch_timing`, `research_report_refs`, and `not_parallel_reason`' \
  "planner multi-agent research decision fields"
require_pattern agents/pge-planner.md 'When `scale_threshold_met: true` and `mode: solo_research`, `multi_agent_research_decision.not_parallel_reason` must be concrete' \
  "planner solo research exception"
require_pattern agents/pge-planner.md 'The `planner_research_decision` message is support traffic only' \
  "planner research decision support traffic rule"
require_pattern agents/pge-planner.md 'type: planner_research_decision' \
  "planner agent research decision message shape"
require_pattern agents/pge-planner.md 'Record exactly one `current_round_slice` in `handoff_seam`' \
  "planner agent current round slice required"
require_pattern agents/pge-planner.md 'In `handoff_seam.current_round_slice`, include `slice_id`, `ready_for_generator`, `dependency_refs`, `blocked_by`, `parallelizable`, `verification_path`, and `handoff_refs`' \
  "planner agent current round slice fields"
require_pattern agents/pge-planner.md 'launch those helper lanes in parallel/concurrently' \
  "planner concurrent helper model"
require_pattern agents/pge-planner.md 'Default helpers: 0-2. Normal maximum: 3. Hard maximum: 4' \
  "planner helper max rule"
require_pattern agents/pge-planner.md 'Post-plan resident research / advisory role' \
  "planner post-plan advisory section"
require_pattern agents/pge-planner.md 'performing bounded post-plan repo / architecture research' \
  "planner post-plan research responsibility"
require_pattern agents/pge-planner.md 'For a `planner_support_request`, respond with `SendMessage\(to="<reply_to>", message="<plain-string planner_support_response>"\)`' \
  "planner support response rule"
require_pattern agents/pge-planner.md 'A support response is not `planner_contract_ready`' \
  "planner support non-progression rule"
require_pattern agents/pge-planner.md 'Use `ready_for_generation: false` when `planner_escalation` records a blocker' \
  "planner blocked ready flag"
require_pattern agents/pge-planner.md 'resend only the canonical event text' \
  "planner resend wording"
require_pattern agents/pge-planner.md 'your work is not complete until you `SendMessage` the canonical runtime event to `main`' \
  "planner work not complete until sendmessage"
require_pattern agents/pge-planner.md 'Do not use `TaskUpdate\(status: completed\)` as the PGE phase-completion signal' \
  "planner taskupdate not completion"
require_pattern agents/pge-planner.md '## Completion protocol \(MANDATORY\)' \
  "planner mandatory completion protocol"
require_pattern agents/pge-planner.md 'Do NOT call `TaskUpdate\(status: completed\)` for the planning phase' \
  "planner no completed taskupdate in completion"
require_pattern agents/pge-planner.md 'After SendMessage, do not exit; remain resident, available, and responsive for bounded plan clarification until `main` sends `shutdown_request`' \
  "planner remains resident after sendmessage"

require_absent_pattern skills/pge-execute/SKILL.md 'direct_agent_compat|direct Agent compatibility|direct Agent result|selected runtime' \
  "stale direct compatibility skill language"
require_absent_pattern skills/pge-execute/ORCHESTRATION.md 'direct_agent_compat|direct Agent compatibility|direct Agent result|selected runtime' \
  "stale direct compatibility orchestration language"
require_absent_pattern skills/pge-execute/contracts/runtime-event-contract.md 'direct_agent_compat|direct Agent compatibility|direct Agent result' \
  "stale direct compatibility runtime event language"
require_absent_pattern agents/pge-planner.md 'direct-agent compatibility|direct Agent result' \
  "stale direct compatibility planner language"
require_absent_pattern agents/pge-generator.md 'direct-agent compatibility|direct Agent result' \
  "stale direct compatibility generator language"
require_absent_pattern agents/pge-evaluator.md 'direct-agent compatibility|direct Agent result' \
  "stale direct compatibility evaluator language"
require_pattern agents/pge-planner.md 'SendMessage to `team-lead` with a plain-string shutdown response' \
  "planner shutdown response target"

planner_sections=(
  goal
  evidence_basis
  design_constraints
  in_scope
  out_of_scope
  actual_deliverable
  acceptance_criteria
  verification_path
  required_evidence
  stop_condition
  handoff_seam
  open_questions
  planner_note
  planner_escalation
)

for section in "${planner_sections[@]}"; do
  require_pattern agents/pge-planner.md "## ${section}" "Planner section ${section}"
  require_pattern skills/pge-execute/handoffs/planner.md "## ${section}" "Planner handoff section ${section}"
  require_pattern skills/pge-execute/contracts/round-contract.md "\`${section}\`" \
    "round contract Planner field ${section}"
done

require_count agents/pge-planner.md '^- `## (goal|evidence_basis|design_constraints|in_scope|out_of_scope|actual_deliverable|acceptance_criteria|verification_path|required_evidence|stop_condition|handoff_seam|open_questions|planner_note|planner_escalation)' 14 \
  "Planner exact output section list"
require_count skills/pge-execute/handoffs/planner.md '^- ## (goal|evidence_basis|design_constraints|in_scope|out_of_scope|actual_deliverable|acceptance_criteria|verification_path|required_evidence|stop_condition|handoff_seam|open_questions|planner_note|planner_escalation)$' 14 \
  "Planner handoff exact output section list"

require_pattern docs/pge-smoke-test.md '\.pge-artifacts/<run_id>/deliverables/smoke\.txt' \
  "smoke doc run-scoped deliverable"
require_pattern docs/pge-smoke-test.md '\.pge-artifacts/<run_id>/manifest\.json' \
  "smoke doc manifest artifact"
require_pattern docs/pge-smoke-test.md '\.pge-artifacts/<run_id>/progress\.jsonl' \
  "smoke doc progress log"
require_pattern docs/pge-smoke-test.md 'pge-progress-report\.sh' \
  "smoke doc progress report script"
require_absent_pattern docs/pge-smoke-test.md 'state\.json|preflight|FAST_PATH' \
  "smoke doc stale preflight/state language"

require_pattern docs/exec-plans/ROUND_013_THREE_AGENT_WORKFLOW_HARDENING.md 'Planner as researcher \+ architect' \
  "round 013 planner hardening goal"
require_pattern docs/exec-plans/ROUND_013_THREE_AGENT_WORKFLOW_HARDENING.md 'Generator as local-first implementer' \
  "round 013 generator hardening goal"
require_pattern docs/exec-plans/ROUND_013_THREE_AGENT_WORKFLOW_HARDENING.md 'Evaluator as independent verifier' \
  "round 013 evaluator hardening goal"
require_pattern docs/exec-plans/ROUND_013_THREE_AGENT_WORKFLOW_HARDENING.md 'Support messages are coordination evidence, not phase progression events' \
  "round 013 support non-progression decision"

require_pattern README.md 'a bounded same-contract `generator <-> evaluator` repair loop for retryable failures' \
  "README execution-core summary"
require_absent_pattern README.md 'runtime state, verdict, routing' \
  "README stale runtime state summary"

printf 'PGE contract validation passed.\n'
