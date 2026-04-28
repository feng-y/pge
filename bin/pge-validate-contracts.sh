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

for file in \
  agents/pge-planner.md \
  agents/pge-generator.md \
  agents/pge-evaluator.md \
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

for name in entry-contract evaluation-contract round-contract routing-contract runtime-state-contract; do
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
done
require_pattern agents/pge-planner.md 'skills/pge-execute/contracts/round-contract.md' \
  "Planner skill-local contract dependency note"

require_pattern agents/pge-planner.md 'planner_escalation.*None' \
  "planner_escalation None rule"
require_pattern skills/pge-execute/handoffs/planner.md 'planner_escalation.*always present|always present.*planner_escalation' \
  "planner_escalation always-present handoff rule"

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
