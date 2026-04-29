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
  docs/exec-plans/ROUND_012_PLANNER_STABILIZATION.md \
  skills/pge-execute/SKILL.md \
  skills/pge-execute/ORCHESTRATION.md \
  docs/design/pge-execute/layered-skill-model.md \
  docs/design/pge-execute/communication-protocol.md \
  docs/design/pge-execute/execution-framework-lessons.md \
  docs/design/pge-execute/role-mapping.md \
  skills/pge-execute/handoffs/planner.md \
  skills/pge-execute/handoffs/preflight.md \
  skills/pge-execute/handoffs/generator.md \
  skills/pge-execute/handoffs/evaluator.md \
  skills/pge-execute/handoffs/route-summary-teardown.md
do
  require_file "$file"
done

for name in entry-contract evaluation-contract round-contract routing-contract runtime-event-contract runtime-state-contract; do
  require_file "skills/pge-execute/contracts/${name}.md"
done

skill_lines="$(wc -l < skills/pge-execute/SKILL.md | tr -d ' ')"
if [[ "$skill_lines" -gt 220 ]]; then
  fail "skills/pge-execute/SKILL.md has ${skill_lines} lines; keep the entrypoint small"
fi

require_pattern skills/pge-execute/SKILL.md 'Contracts: `contracts/\*\.md` relative to this skill \(authoritative for this skill\)' \
  "skill-local contract authority note"
require_pattern skills/pge-execute/SKILL.md 'verify the runtime can resolve the `pge-planner`, `pge-generator`, and `pge-evaluator` agent surfaces' \
  "runtime agent surface resolution note"
require_pattern skills/pge-execute/SKILL.md 'docs/design/pge-execute/' \
  "external design reference note"
require_pattern skills/pge-execute/SKILL.md '^## Execution Flow$' \
  "top-level Execution Flow section"
require_pattern skills/pge-execute/SKILL.md 'User invokes /pge-execute' \
  "Execution Flow invocation"
require_pattern skills/pge-execute/SKILL.md 'teammate `planner` runs agent surface `pge-planner`' \
  "planner team binding"
require_pattern skills/pge-execute/SKILL.md 'spawn teammate `planner` using `pge-planner`' \
  "planner spawn binding"
require_pattern skills/pge-execute/SKILL.md 'allow bounded proposal repair attempts before any repo edits' \
  "bounded preflight repair note"
require_pattern skills/pge-execute/SKILL.md 'Runtime events: `contracts/runtime-event-contract.md`' \
  "runtime event contract disclosure"
require_pattern skills/pge-execute/SKILL.md 'advances from runtime events' \
  "skill event-driven advancement rule"
require_pattern agents/pge-planner.md '^tools: .*Write' \
  "Planner artifact write tool"
require_pattern agents/pge-generator.md '^tools: .*Write' \
  "Generator artifact write tool"
require_pattern agents/pge-evaluator.md '^tools: .*Write' \
  "Evaluator artifact write tool"
for section in "System Overview" "Component Summary" "Flow Diagram" "Component Details" "Execution Flow" "Example Execution" "Key Design Principles" "Architecture Patterns"; do
  require_pattern docs/design/pge-execute/layered-skill-model.md "^## ${section}$" \
    "layered model ${section} section"
done
require_pattern docs/design/pge-execute/layered-skill-model.md '^## Execution Flow$' \
  "layered model Execution Flow section"
require_pattern docs/design/pge-execute/layered-skill-model.md 'planner -> pge-planner' \
  "layered model planner binding"
require_pattern skills/pge-execute/ORCHESTRATION.md 'next_route = converged' \
  "smoke PASS next_route rule"
require_absent_pattern skills/pge-execute/ORCHESTRATION.md 'PASS requires .*\`route = converged\`' \
  "stale smoke route schema"
require_pattern skills/pge-execute/ORCHESTRATION.md 'advances only from runtime events defined in `skills/pge-execute/contracts/runtime-event-contract.md`' \
  "orchestration event-driven advancement rule"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md '^## progression rule$' \
  "runtime event contract progression section"
require_pattern skills/pge-execute/contracts/runtime-event-contract.md 'artifact existence alone is never enough to advance' \
  "runtime event contract no artifact-only advancement rule"
for event_type in planner_contract_ready mode_decision proposal_ready preflight_decision generator_completion final_verdict route_selected; do
  require_pattern skills/pge-execute/contracts/runtime-event-contract.md "${event_type}" \
    "runtime event contract event ${event_type}"
done

for state in preflight_pending ready_to_generate; do
  require_pattern skills/pge-execute/ORCHESTRATION.md "^[-] \`${state}\`$" \
    "P1a allowed state ${state}"
  require_pattern skills/pge-execute/runtime/artifacts-and-state.md "^[-] \`${state}\`$" \
    "P1a runtime state ${state}"
done

require_pattern skills/pge-execute/ORCHESTRATION.md 'repairable proposal issues may loop through bounded preflight repair attempts' \
  "bounded preflight repair orchestration rule"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md '"preflight_attempt_id": 1' \
  "runtime preflight attempt field"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md '"max_preflight_attempts": 2' \
  "runtime max preflight attempts field"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md '"mode": null' \
  "runtime initial mode is undecided"
require_absent_pattern skills/pge-execute/runtime/artifacts-and-state.md '"mode": "FULL_PGE"' \
  "stale default FULL_PGE mode"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'FAST_PATH.*must not write.*contract_proposal_artifact.*preflight_artifact.*generator_artifact.*summary_artifact.*progress_artifact' \
  "FAST_PATH forbidden artifact list"
require_pattern skills/pge-execute/ORCHESTRATION.md 'management artifacts.*at most 3' \
  "smoke FAST_PATH management artifact budget"
require_pattern skills/pge-execute/ORCHESTRATION.md 'FAST_PATH.*must not require or write.*contract-proposal.*preflight.*generator.*summary.*progress' \
  "orchestration FAST_PATH forbidden artifacts"
require_pattern skills/pge-execute/SKILL.md 'mode = null.*do not default to `FULL_PGE`' \
  "skill initial mode undecided rule"
require_pattern skills/pge-execute/handoffs/preflight.md 'FAST_PATH.*fast_finish_approved = true' \
  "preflight FAST_PATH approval route"
require_pattern skills/pge-execute/handoffs/preflight.md 'type: mode_decision' \
  "preflight FAST_PATH mode decision message schema"
require_pattern skills/pge-execute/handoffs/preflight.md 'requires_durable_proposal: false' \
  "preflight FAST_PATH no durable proposal message field"
require_pattern skills/pge-execute/handoffs/preflight.md 'requires_durable_preflight: false' \
  "preflight FAST_PATH no durable preflight message field"
require_pattern skills/pge-execute/handoffs/preflight.md 'type: proposal_ready' \
  "preflight proposal_ready event schema"
require_pattern skills/pge-execute/handoffs/preflight.md 'type: preflight_decision' \
  "preflight_decision event schema"
require_pattern skills/pge-execute/handoffs/generator.md 'If mode is `FAST_PATH`, do not write <generator_artifact>' \
  "generator FAST_PATH no artifact rule"
require_pattern skills/pge-execute/handoffs/generator.md 'type: generator_completion' \
  "generator FAST_PATH completion message schema"
require_pattern skills/pge-execute/handoffs/evaluator.md 'do not require `contract_proposal_artifact`, `preflight_artifact`, or `generator_artifact`' \
  "evaluator FAST_PATH no intermediate artifact dependency"
require_pattern skills/pge-execute/handoffs/evaluator.md 'type: final_verdict' \
  "evaluator final_verdict event schema"
require_pattern skills/pge-execute/handoffs/route-summary-teardown.md 'type: route_selected' \
  "route-selected event schema"
require_pattern agents/pge-evaluator.md 'pre-generation execution mode decision' \
  "Evaluator cost-gate responsibility"
require_pattern agents/pge-evaluator.md 'type: mode_decision' \
  "Evaluator cost-gate message schema"
require_pattern agents/pge-evaluator.md 'final_verdict' \
  "Evaluator final verdict event rule"
require_pattern agents/pge-generator.md 'output_artifact = None' \
  "Generator FAST_PATH no output artifact input"
require_pattern agents/pge-generator.md 'type: generator_completion' \
  "Generator FAST_PATH completion message schema"
require_pattern agents/pge-generator.md 'proposal_ready' \
  "Generator proposal_ready event rule"
require_pattern skills/pge-execute/contracts/runtime-state-contract.md '^## framing$' \
  "normative superset framing section"
require_pattern skills/pge-execute/contracts/runtime-state-contract.md 'normative semantic superset' \
  "normative superset framing text"
require_pattern skills/pge-execute/runtime/artifacts-and-state.md 'current executable subset of runtime state' \
  "current executable subset framing text"

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
require_pattern agents/pge-planner.md 'skills/pge-execute/contracts/round-contract.md' \
  "Planner skill-local contract dependency note"

future_planner_sections=(
  context_loading_strategy
  rejected_cuts
  failure_mode_register
  contract_self_check
)

for section in "${future_planner_sections[@]}"; do
  require_absent_pattern agents/pge-planner.md "^[-] \`## ${section}\`" \
    "forbidden Planner output section ${section}"
  require_absent_pattern skills/pge-execute/handoffs/planner.md "^[-] ## ${section}$|^[-] \`## ${section}\`" \
    "forbidden Planner handoff section ${section}"
done

require_pattern agents/pge-planner.md 'planner_escalation.*None' \
  "planner_escalation None rule"
require_pattern agents/pge-planner.md 'Planner owns current-round task split and DoD' \
  "Planner current-round task split ownership rule"
require_pattern agents/pge-planner.md 'does not own full-project backlog scheduling' \
  "Planner no full-project backlog scheduling rule"
require_pattern agents/pge-planner.md 'In `evidence_basis`, state what was read' \
  "Planner context loading inside evidence_basis rule"
require_pattern agents/pge-planner.md 'In `planner_note`, include a contract self-check' \
  "Planner contract self-check inside planner_note rule"
require_pattern agents/pge-planner.md 'Record material ways this round can fail in `design_constraints`' \
  "Planner failure modes inside design_constraints rule"
require_pattern agents/pge-planner.md 'decision: pass-through\|cut' \
  "Planner planner_note decision shape"
require_pattern agents/pge-planner.md 'planner_contract_ready' \
  "Planner runtime event emission rule"
for facet in 'Evidence steward' 'Scope challenger' 'Contract author' 'Risk registrar' 'Contract self-checker'; do
  require_pattern agents/pge-planner.md "$facet" "Planner responsibility facet ${facet}"
done
require_pattern skills/pge-execute/handoffs/planner.md 'planner_escalation.*always present|always present.*planner_escalation' \
  "planner_escalation always-present handoff rule"
require_pattern skills/pge-execute/handoffs/planner.md 'type: planner_contract_ready' \
  "Planner handoff runtime event schema"
require_pattern skills/pge-execute/handoffs/planner.md 'context loading strategy inside `## evidence_basis`' \
  "Planner handoff context loading semantic placement"
require_pattern skills/pge-execute/handoffs/planner.md 'decision: pass-through\|cut' \
  "Planner handoff planner_note decision shape"
require_pattern skills/pge-execute/handoffs/planner.md 'rejected cuts.*inside `## planner_note`|inside `## planner_note`.*rejected cuts' \
  "Planner handoff rejected cuts semantic placement"
require_pattern skills/pge-execute/handoffs/planner.md 'contract self-check inside `## planner_note`' \
  "Planner handoff self-check semantic placement"
require_pattern skills/pge-execute/handoffs/planner.md 'material failure modes in `## design_constraints`' \
  "Planner handoff failure mode semantic placement"
require_pattern skills/pge-execute/contracts/round-contract.md 'Within `evidence_basis`' \
  "round contract context loading semantic placement"
require_pattern skills/pge-execute/contracts/round-contract.md 'Within `design_constraints`' \
  "round contract failure mode semantic placement"
require_pattern skills/pge-execute/contracts/round-contract.md '`decision`: `pass-through` or `cut`' \
  "round contract planner_note decision shape"
require_pattern skills/pge-execute/contracts/round-contract.md '`contract_self_check`' \
  "round contract planner_note self-check shape"
require_pattern skills/pge-execute/contracts/round-contract.md 'rejected_cuts: None' \
  "round contract rejected cuts None shape"
require_pattern skills/pge-execute/contracts/round-contract.md 'Planner owns current-round task split and DoD' \
  "round contract Planner task split ownership rule"

preflight_generator_sections=(
  current_task
  execution_boundary_ack
  deliverable_ack
  verification_plan
  evidence_plan
  addressed_preflight_feedback
  unresolved_blockers
  preflight_status
)

for section in "${preflight_generator_sections[@]}"; do
  require_pattern skills/pge-execute/handoffs/preflight.md "## ${section}" \
    "Preflight generator section ${section}"
done

require_pattern skills/pge-execute/handoffs/preflight.md '## repair_owner' \
  "preflight repair owner section"
require_pattern skills/pge-execute/handoffs/preflight.md 'Allowed repair_owner values:' \
  "preflight repair owner values"
require_pattern skills/pge-execute/handoffs/preflight.md 'BLOCK \+ repair_owner = generator' \
  "bounded preflight repair routing"
for value in READY_FOR_EVALUATOR BLOCKED; do
  require_pattern skills/pge-execute/handoffs/preflight.md "^[-] ${value}$" \
    "preflight_status enum ${value}"
done
for value in PASS BLOCK ESCALATE; do
  require_pattern skills/pge-execute/handoffs/preflight.md "^[-] ${value}$" \
    "preflight_verdict enum ${value}"
done
for value in ready_to_generate return_to_planner; do
  require_pattern skills/pge-execute/handoffs/preflight.md "^[-] ${value}$" \
    "preflight next_route enum ${value}"
done
for value in generator planner; do
  require_pattern skills/pge-execute/handoffs/preflight.md "^[-] ${value}$" \
    "repair_owner enum ${value}"
done

generator_sections=(
  current_task
  boundary
  actual_deliverable
  deliverable_path
  changed_files
  local_verification
  evidence
  self_review
  known_limits
  non_done_items
  deviations_from_spec
  handoff_status
)

for section in "${generator_sections[@]}"; do
  require_pattern skills/pge-execute/handoffs/generator.md "## ${section}" \
    "Generator handoff section ${section}"
done

retry_count="$(grep -Ec '^## Retry Behavior$' agents/pge-generator.md || true)"
if [[ "$retry_count" -ne 1 ]]; then
  fail "expected exactly one Generator Retry Behavior section, found ${retry_count}"
fi
require_pattern agents/pge-generator.md 'skills/pge-execute/contracts/round-contract.md' \
  "Generator skill-local contract dependency note"
require_absent_pattern agents/pge-generator.md 'minimal_disclosed_context' \
  "stale minimal_disclosed_context term"

evaluator_sections=(
  verdict
  evidence
  violated_invariants_or_risks
  required_fixes
  next_route
)

for section in "${evaluator_sections[@]}"; do
  require_pattern agents/pge-evaluator.md "## ${section}" "Evaluator section ${section}"
  require_pattern skills/pge-execute/handoffs/evaluator.md "## ${section}" \
    "Evaluator handoff section ${section}"
done

for value in PASS RETRY BLOCK ESCALATE; do
  require_pattern skills/pge-execute/handoffs/evaluator.md "^[-] ${value}$" \
    "evaluator verdict enum ${value}"
done
for value in continue converged retry return_to_planner; do
  require_pattern skills/pge-execute/handoffs/evaluator.md "^[-] ${value}$" \
    "evaluator next_route enum ${value}"
done

require_pattern agents/pge-evaluator.md 'do state observable missing behavior' \
  "Evaluator required_fixes observable-behavior rule"
require_pattern agents/pge-evaluator.md 'skills/pge-execute/contracts/routing-contract.md' \
  "Evaluator routing contract dependency note"
require_pattern agents/pge-evaluator.md 'skills/pge-execute/contracts/runtime-state-contract.md' \
  "Evaluator runtime-state contract dependency note"
require_absent_pattern agents/pge-evaluator.md '^## route$' \
  "stale Evaluator route section"
require_absent_pattern skills/pge-execute/handoffs/evaluator.md '^[-] ## route$' \
  "stale Evaluator handoff route section"

printf 'PGE contract validation passed.\n'
