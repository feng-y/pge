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
  README.md \
  CLAUDE.md \
  AGENTS.md \
  .claude-plugin/plugin.json \
  .claude-plugin/marketplace.json \
  bin/pge-local-install.sh \
  docs/exec-plans/CURRENT_MAINLINE.md \
  docs/exec-plans/ISSUES_LEDGER.md \
  docs/exec-plans/pge-skills-setup-plan-execute.md \
  docs/exec-plans/pge-skills-contract-first.md \
  skills/pge-setup/SKILL.md \
  skills/pge-plan/SKILL.md \
  skills/pge-exec/SKILL.md
do
  require_file "$file"
done

require_pattern README.md 'pge-setup -> pge-plan -> pge-exec' \
  "README split workflow summary"
require_pattern README.md 'skills/pge-setup/SKILL.md' \
  "README pge-setup surface"
require_pattern README.md 'skills/pge-plan/SKILL.md' \
  "README pge-plan surface"
require_pattern README.md 'skills/pge-exec/SKILL.md' \
  "README pge-exec surface"
require_pattern README.md 'legacy runtime material' \
  "README legacy runtime framing"

require_pattern CLAUDE.md 'skills/pge-setup/SKILL.md' \
  "CLAUDE pge-setup first read"
require_pattern CLAUDE.md 'skills/pge-plan/SKILL.md' \
  "CLAUDE pge-plan first read"
require_pattern CLAUDE.md 'skills/pge-exec/SKILL.md' \
  "CLAUDE pge-exec first read"
require_pattern CLAUDE.md 'Do not silently restore a Planner / Generator / Evaluator Claude Code Agent Teams orchestrator' \
  "CLAUDE no legacy orchestrator invariant"

require_pattern AGENTS.md 'Active setup surface' \
  "AGENTS setup surface"
require_pattern AGENTS.md 'Active planning surface' \
  "AGENTS planning surface"
require_pattern AGENTS.md 'Active execution surface' \
  "AGENTS execution surface"

require_pattern .claude-plugin/plugin.json '"skill_directories"' \
  "plugin split skill directory allowlist"
require_pattern .claude-plugin/plugin.json '"pge-setup"' \
  "plugin pge-setup skill"
require_pattern .claude-plugin/plugin.json '"pge-plan"' \
  "plugin pge-plan skill"
require_pattern .claude-plugin/plugin.json '"pge-exec"' \
  "plugin pge-exec skill"
require_pattern .claude-plugin/plugin.json '"legacy_cleanup"' \
  "plugin legacy cleanup policy"
require_absent_pattern .claude-plugin/plugin.json '"\./agents/pge-' \
  "active plugin agent path"

require_pattern bin/pge-local-install.sh 'skill_directories' \
  "local install skill allowlist support"
require_pattern bin/pge-local-install.sh 'legacy_cleanup' \
  "local install legacy cleanup support"

require_pattern skills/pge-setup/SKILL.md '\.pge/config/repo-profile\.md' \
  "pge-setup repo profile artifact"
require_pattern skills/pge-setup/SKILL.md '\.pge/config/backlog-policy\.md' \
  "pge-setup backlog policy artifact"
require_pattern skills/pge-setup/SKILL.md '\.pge/config/docs-policy\.md' \
  "pge-setup docs policy artifact"
require_pattern skills/pge-setup/SKILL.md '\.pge/config/artifact-layout\.md' \
  "pge-setup artifact layout artifact"
require_pattern skills/pge-setup/SKILL.md '\.pge/config/verification\.md' \
  "pge-setup verification artifact"
require_pattern skills/pge-setup/SKILL.md '\.pge/config/route-policy\.md' \
  "pge-setup route policy artifact"
require_pattern skills/pge-setup/SKILL.md '\.pge/config/open-gaps\.md' \
  "pge-setup open gaps artifact"
require_pattern skills/pge-setup/SKILL.md 'SETUP_READY' \
  "pge-setup ready status"
require_pattern skills/pge-setup/SKILL.md 'SETUP_PARTIAL' \
  "pge-setup partial status"
require_pattern skills/pge-setup/SKILL.md 'SETUP_BLOCKED' \
  "pge-setup blocked status"

require_pattern skills/pge-plan/SKILL.md '\.pge/plans/<plan_id>\.md' \
  "pge-plan plan artifact"
require_pattern skills/pge-plan/SKILL.md 'Planning Self-Evaluation' \
  "pge-plan self evaluation"
require_pattern skills/pge-plan/SKILL.md 'Issue 1' \
  "pge-plan numbered issues"
require_pattern skills/pge-plan/SKILL.md 'READY_FOR_EXECUTE' \
  "pge-plan ready state"
require_pattern skills/pge-plan/SKILL.md 'NEEDS_HUMAN' \
  "pge-plan human state"
require_pattern skills/pge-plan/SKILL.md 'pge-exec' \
  "pge-plan handoff to pge-exec"

for heading in \
  'Purpose' \
  'When to use' \
  'Inputs' \
  'Workflow' \
  'Artifact Contract' \
  'Handoff Contract' \
  'State / Route Contract' \
  'Worker Model' \
  'Repair Policy' \
  'Decision Handling' \
  'Guardrails' \
  'Stop Conditions' \
  'Next Suggested Action'
do
  require_pattern skills/pge-exec/SKILL.md "^## ${heading}$" \
    "pge-exec ${heading} section"
done

require_pattern skills/pge-exec/SKILL.md 'smallest unfinished issue' \
  "pge-exec numbered issue progression"
require_pattern skills/pge-exec/SKILL.md 'MAX_REPAIR_ATTEMPTS = 2' \
  "pge-exec repair attempt limit"
require_pattern skills/pge-exec/SKILL.md 'decision-research\.md' \
  "pge-exec decision research artifact"
require_pattern skills/pge-exec/SKILL.md 'decision-request\.md' \
  "pge-exec decision request artifact"
require_pattern skills/pge-exec/SKILL.md 'workers/issue-001' \
  "pge-exec worker artifact layout"
require_pattern skills/pge-exec/SKILL.md 'DONE_NEEDS_REVIEW' \
  "pge-exec done needs review route"
require_pattern skills/pge-exec/SKILL.md 'RETRY_RECOMMENDED' \
  "pge-exec retry recommended route"
require_pattern skills/pge-exec/SKILL.md 'NEEDS_MAIN_DECISION' \
  "pge-exec main decision route"
require_pattern skills/pge-exec/SKILL.md 'Workers do not decide final route' \
  "pge-exec worker authority boundary"

for active_file in \
  skills/pge-setup/SKILL.md \
  skills/pge-plan/SKILL.md \
  skills/pge-exec/SKILL.md
do
  require_absent_pattern "$active_file" '^  - TeamCreate$' \
    "forbidden TeamCreate tool in $active_file"
  require_absent_pattern "$active_file" '^  - TeamDelete$' \
    "forbidden TeamDelete tool in $active_file"
  require_absent_pattern "$active_file" '^  - SendMessage$' \
    "forbidden SendMessage tool in $active_file"
  require_absent_pattern "$active_file" 'MERGED[^`]*as status|SHIPPED[^`]*as status' \
    "forbidden shipped/merged status in $active_file"
done

require_pattern skills/pge-exec/SKILL.md 'Forbidden routes:' \
  "pge-exec forbidden routes section"
require_pattern skills/pge-exec/SKILL.md '`PASS`' \
  "pge-exec PASS forbidden vocabulary"
require_pattern skills/pge-exec/SKILL.md '`MERGED`' \
  "pge-exec MERGED forbidden vocabulary"
require_pattern skills/pge-exec/SKILL.md '`SHIPPED`' \
  "pge-exec SHIPPED forbidden vocabulary"

printf 'OK: PGE split contracts validated\n'
