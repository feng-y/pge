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

require_absent_file() {
  [[ ! -e "$1" ]] || fail "stale file should not exist: $1"
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
  bin/pge-local-install.sh \
  skills/pge-research/SKILL.md \
  skills/pge-plan/SKILL.md \
  skills/pge-exec/SKILL.md \
  skills/pge-handoff/SKILL.md
do
  require_file "$file"
done

require_absent_file progress.md
require_absent_file ISSUES.md
require_absent_file skills/pge-setup/SKILL.md

require_pattern README.md 'pge-research → pge-plan → pge-exec' \
  "README core pipeline"
require_pattern README.md 'skills/pge-research/SKILL.md' \
  "README pge-research surface"
require_pattern README.md 'skills/pge-plan/SKILL.md' \
  "README pge-plan surface"
require_pattern README.md 'skills/pge-exec/SKILL.md' \
  "README pge-exec surface"
require_pattern README.md 'skills/pge-handoff/SKILL.md' \
  "README pge-handoff surface"
require_pattern README.md '\.pge/tasks-<slug>/plan\.md' \
  "README preferred plan artifact"

require_pattern CLAUDE.md 'skills/pge-research/SKILL.md' \
  "CLAUDE pge-research first read"
require_pattern CLAUDE.md 'skills/pge-handoff/SKILL.md' \
  "CLAUDE pge-handoff first read"
require_pattern CLAUDE.md 'skills/pge-execute/` — removed' \
  "CLAUDE legacy pge-execute framing"
require_pattern CLAUDE.md 'Do not silently restore a Planner / Generator / Evaluator Claude Code Agent Teams orchestrator' \
  "CLAUDE no legacy orchestrator invariant"

require_pattern AGENTS.md 'Active research surface' \
  "AGENTS research surface"
require_pattern AGENTS.md '\.pge/tasks-<slug>/research\.md' \
  "AGENTS preferred task artifact flow"
require_absent_pattern AGENTS.md 'docs/exec-plans/CURRENT_MAINLINE\.md|docs/exec-plans/ISSUES_LEDGER\.md' \
  "stale exec-plan docs reference"
require_absent_pattern AGENTS.md 'Active setup surface' \
  "stale pge-setup surface in AGENTS"
require_absent_pattern AGENTS.md 'pge-setup, pge-research' \
  "stale pge-setup in AGENTS invariants"
require_pattern AGENTS.md 'pge-research.*pge-plan.*pge-exec' \
  "AGENTS active workflow flow"

require_pattern .claude-plugin/plugin.json '"skill_directories"' \
  "plugin skill directory allowlist"
for skill in pge-research pge-plan pge-exec pge-handoff; do
  require_pattern .claude-plugin/plugin.json "\"${skill}\"" \
    "plugin ${skill} skill"
done
require_pattern .claude-plugin/plugin.json '"legacy_cleanup"' \
  "plugin legacy cleanup policy"
require_pattern .claude-plugin/plugin.json '"agents"' \
  "plugin agents declaration"

require_pattern bin/pge-local-install.sh 'skill_directories' \
  "local install skill allowlist support"
require_pattern bin/pge-local-install.sh 'legacy_cleanup' \
  "local install legacy cleanup support"

for active_skill in \
  skills/pge-research/SKILL.md \
  skills/pge-plan/SKILL.md \
  skills/pge-exec/SKILL.md \
  skills/pge-handoff/SKILL.md
do
  require_pattern "$active_skill" '^  - Agent$' \
    "Agent tool allowed in $active_skill"
  require_absent_pattern "$active_skill" 'MERGED[^`]*as status|SHIPPED[^`]*as status' \
    "forbidden shipped/merged status in $active_skill"
done

require_pattern skills/pge-research/SKILL.md '\.pge/tasks-<slug>/research\.md' \
  "pge-research task artifact"
require_pattern skills/pge-research/SKILL.md 'research_route: READY_FOR_PLAN \| NEEDS_INFO \| BLOCKED' \
  "pge-research route contract"

require_pattern skills/pge-plan/SKILL.md '\.pge/tasks-<slug>/plan\.md' \
  "pge-plan preferred plan artifact"
require_pattern skills/pge-plan/SKILL.md 'Self-Evaluation' \
  "pge-plan self evaluation"
require_pattern skills/pge-plan/SKILL.md 'READY_FOR_EXECUTE' \
  "pge-plan ready state"
require_pattern skills/pge-plan/SKILL.md 'Security`: yes \| no' \
  "pge-plan security flag"

require_pattern skills/pge-exec/SKILL.md '^  - TeamCreate$' \
  "pge-exec TeamCreate tool"
require_pattern skills/pge-exec/SKILL.md '^  - TeamDelete$' \
  "pge-exec TeamDelete tool"
require_pattern skills/pge-exec/SKILL.md '^  - SendMessage$' \
  "pge-exec SendMessage tool"
require_pattern skills/pge-exec/SKILL.md '\.pge/tasks-<slug>/runs/<run_id>/' \
  "pge-exec preferred run artifact"
require_pattern skills/pge-exec/SKILL.md 'Generator \+ Evaluator' \
  "pge-exec generator/evaluator split"
require_pattern skills/pge-exec/SKILL.md 'pge-exec-pre-<run_id>' \
  "pge-exec rollback tag"
require_pattern skills/pge-exec/SKILL.md 'state\.json' \
  "pge-exec resume state"
require_pattern skills/pge-exec/SKILL.md 'learnings\.md' \
  "pge-exec learnings artifact"

require_pattern skills/pge-handoff/SKILL.md '\.pge/handoffs/<YYYYMMDD-HHMMSS>-<slug>\.md' \
  "pge-handoff save artifact"
require_pattern skills/pge-handoff/SKILL.md 'save\|extract\|restore' \
  "pge-handoff modes"

printf 'OK: PGE active contracts validated\n'
