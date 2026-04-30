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
  skills/pge-execute/contracts/routing-contract.md \
  skills/pge-execute/contracts/evaluation-contract.md \
  skills/pge-execute/contracts/runtime-event-contract.md \
  skills/pge-execute/contracts/runtime-state-contract.md \
  docs/pge-smoke-test.md \
  README.md
do
  require_file "$file"
done

skill_lines="$(wc -l < skills/pge-execute/SKILL.md | tr -d ' ')"
if [[ "$skill_lines" -gt 220 ]]; then
  fail "skills/pge-execute/SKILL.md has ${skill_lines} lines; keep the entrypoint small"
fi

require_pattern skills/pge-execute/SKILL.md 'one bounded run with `planner -> generator -> evaluator` for normal tasks' \
  "single skeleton claim"
require_pattern skills/pge-execute/SKILL.md 'progress log is weak dependency only' \
  "progress weak dependency note"
require_pattern skills/pge-execute/SKILL.md 'Create the run-scoped smoke file \.pge-artifacts/<run_id>/deliverables/smoke\.txt' \
  "run-scoped smoke task"
require_pattern skills/pge-execute/SKILL.md 'ignore teammate `idle_notification` messages completely' \
  "ignore idle notifications rule"
require_pattern skills/pge-execute/SKILL.md 'do not emit user-facing "waiting for \.\.\." chatter between dispatch and the required runtime event' \
  "no waiting chatter rule"
require_pattern skills/pge-execute/SKILL.md 'Do not insert a separate preflight or mode-decision phase into the current executable lane' \
  "no preflight gate rule"
require_pattern skills/pge-execute/SKILL.md 'spawn teammate `planner` using `pge-planner`' \
  "planner spawn binding"
require_pattern skills/pge-execute/SKILL.md 'for `test`, send implementation task to generator with `output_artifact = None` and the resolved `smoke_deliverable`' \
  "test direct generator dispatch"
require_pattern skills/pge-execute/SKILL.md 'send evaluation task to evaluator' \
  "final evaluator dispatch"
require_pattern skills/pge-execute/SKILL.md 'for `test`, never redispatch planner, generator, or evaluator after an idle notification' \
  "no redispatch on idle rule"
require_absent_pattern skills/pge-execute/SKILL.md 'state_artifact' \
  "stale state artifact reference"

require_pattern skills/pge-execute/ORCHESTRATION.md 'All tasks use the same skeleton: `planner -> generator -> evaluator`' \
  "orchestration skeleton rule"
require_pattern skills/pge-execute/ORCHESTRATION.md '\.pge-artifacts/<run_id>/deliverables/smoke\.txt' \
  "orchestration run-scoped smoke path"
require_pattern skills/pge-execute/ORCHESTRATION.md 'append-only execution log' \
  "orchestration progress log note"
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
require_absent_pattern skills/pge-execute/contracts/runtime-event-contract.md 'mode_decision|proposal_ready|preflight_decision|ready_for_preflight' \
  "stale preflight events"

require_pattern skills/pge-execute/handoffs/preflight.md 'not part of the current executable lane' \
  "archived preflight note"

require_pattern skills/pge-execute/handoffs/planner.md 'ready_for_generation: true' \
  "planner ready_for_generation event"
require_absent_pattern skills/pge-execute/handoffs/planner.md 'write state|update progress only when enabled|ready_for_preflight' \
  "planner stale state logic"

require_pattern skills/pge-execute/handoffs/generator.md 'smoke_deliverable: <smoke_deliverable or None>' \
  "generator smoke path input"
require_pattern skills/pge-execute/handoffs/generator.md 'type: generator_completion' \
  "generator completion event schema"
require_absent_pattern skills/pge-execute/handoffs/generator.md 'preflight_artifact|contract_proposal_artifact|write state' \
  "generator stale preflight/state logic"

require_pattern skills/pge-execute/handoffs/evaluator.md 'smoke_deliverable: <smoke_deliverable or None>' \
  "evaluator smoke path input"
require_pattern skills/pge-execute/handoffs/evaluator.md 'type: final_verdict' \
  "evaluator final verdict event schema"
require_pattern skills/pge-execute/handoffs/evaluator.md 'if verdict is `PASS`, `next_route` must be `converged`' \
  "test pass implies converged rule"
require_absent_pattern skills/pge-execute/handoffs/evaluator.md 'preflight_artifact|contract_proposal_artifact|write state|compact_scores' \
  "evaluator stale preflight/state logic"

require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'Append a best-effort progress log entry after route selection' \
  "route progress log rule"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'SendMessage\(to="planner", message="type: shutdown_request"\)' \
  "plain-string shutdown message"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md '^TeamDelete\(\)$' \
  "zero-arg TeamDelete call"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md '`status = SUCCESS` is valid only when `verdict = PASS` and `route = converged`' \
  "success status mapping"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'progress log path when `progress_artifact` exists' \
  "summary progress log path"
require_absent_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'state:' \
  "route event stale state field"

require_pattern agents/pge-generator.md 'If orchestration omits `output_artifact`' \
  "generator optional durable artifact rule"
require_pattern agents/pge-generator.md 'type: generator_completion' \
  "generator runtime event rule"
require_absent_pattern agents/pge-generator.md 'proposal_ready|preflight validated' \
  "generator stale preflight role text"

require_pattern agents/pge-evaluator.md 'You own final independent deliverable validation' \
  "evaluator ownership rule"
require_pattern agents/pge-evaluator.md 'final_verdict' \
  "evaluator final verdict rule"
require_absent_pattern agents/pge-evaluator.md 'mode_decision|pre-generation execution mode decision|runtime-state-contract' \
  "evaluator stale preflight/state role text"

require_absent_pattern agents/pge-planner.md 'FAST_PATH|LITE_PGE|FULL_PGE|LONG_RUNNING_PGE' \
  "planner stale mode labels"

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

require_pattern README.md 'planner/generator/evaluator execution, verdict, routing, progress logging' \
  "README execution-core summary"
require_absent_pattern README.md 'runtime state, verdict, routing' \
  "README stale runtime state summary"

printf 'PGE contract validation passed.\n'
