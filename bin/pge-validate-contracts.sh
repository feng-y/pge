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
require_pattern skills/pge-research/SKILL.md 'mkdir -p \.pge/tasks-<slug>/' \
  "pge-research task directory creation"
require_pattern skills/pge-research/SKILL.md 'research_route: READY_FOR_PLAN \| NEEDS_INFO \| BLOCKED' \
  "pge-research route contract"
require_pattern skills/pge-research/SKILL.md 'Completion gate' \
  "pge-research completion gate"
require_pattern skills/pge-research/SKILL.md 'Do NOT auto-invoke `pge-plan`' \
  "pge-research manual next-step handoff"
require_pattern skills/pge-research/SKILL.md 'Do NOT produce plans, numbered issues, implementation code, function bodies, pseudocode' \
  "pge-research no code boundary"

require_pattern skills/pge-plan/SKILL.md '\.pge/tasks-<slug>/plan\.md' \
  "pge-plan preferred plan artifact"
require_pattern skills/pge-plan/SKILL.md 'mkdir -p \.pge/tasks-<slug>/' \
  "pge-plan task directory creation"
require_pattern skills/pge-plan/SKILL.md 'If research was skipped, pge-plan creates the task directory' \
  "pge-plan task directory ownership"
require_pattern skills/pge-plan/SKILL.md 'on a bare `pge-plan` invocation, first discover any research artifact under `\.pge/tasks-<slug>/research\.md`' \
  "pge-plan bare invocation research discovery"
require_pattern skills/pge-plan/SKILL.md 'If both the discovered research artifact and the current conversation are plausible upstream sources, ask the user whether to continue from the research artifact or from the current context' \
  "pge-plan source selection question"
require_pattern skills/pge-plan/SKILL.md 'Direct planning from intent, conversation, or another accepted structured upstream source remains supported when no research artifact exists, or when the user explicitly chooses that mode' \
  "pge-plan direct planning fallback"
require_pattern skills/pge-plan/SKILL.md 'A discovered research artifact and the current conversation both look like valid upstream sources: ask the user which one to use instead of guessing' \
  "pge-plan context-vs-research guard"
require_pattern skills/pge-plan/SKILL.md 'Multiple plausible research artifacts and no explicit selector: ask the user which task to continue instead of guessing' \
  "pge-plan ambiguous research selection guard"
require_pattern skills/pge-plan/SKILL.md 'broken handoff instead of silently pretending the research artifact exists' \
  "pge-plan broken handoff guard"
require_pattern skills/pge-plan/SKILL.md 'Self-Evaluation' \
  "pge-plan self evaluation"
require_pattern skills/pge-plan/SKILL.md 'READY_FOR_EXECUTE' \
  "pge-plan ready state"
require_pattern skills/pge-plan/SKILL.md 'Security`: yes \| no' \
  "pge-plan security flag"
require_absent_pattern skills/pge-plan/SKILL.md '\.pge/plans/' \
  "pge-plan legacy plan path"
require_pattern skills/pge-plan/SKILL.md 'Completion gate' \
  "pge-plan completion gate"
require_pattern skills/pge-plan/SKILL.md 'Do not: write business code, write implementation pseudocode or function bodies' \
  "pge-plan no implementation boundary"

require_pattern skills/pge-exec/SKILL.md '^  - TeamCreate$' \
  "pge-exec TeamCreate tool"
require_pattern skills/pge-exec/SKILL.md '^  - TeamDelete$' \
  "pge-exec TeamDelete tool"
require_pattern skills/pge-exec/SKILL.md '^  - SendMessage$' \
  "pge-exec SendMessage tool"
require_pattern skills/pge-exec/SKILL.md '\.pge/tasks-<slug>/runs/<run_id>/' \
  "pge-exec run artifact"
require_absent_pattern skills/pge-exec/SKILL.md '\.pge/runs/' \
  "pge-exec legacy run path"
require_pattern skills/pge-exec/SKILL.md 'on a bare `pge-exec` invocation, first discover `\.pge/tasks-<slug>/plan\.md`' \
  "pge-exec bare invocation plan discovery"
require_pattern skills/pge-exec/SKILL.md 'ask the user which source to continue from instead of guessing' \
  "pge-exec source selection question"
require_pattern skills/pge-exec/SKILL.md 'report a broken handoff instead of silently pretending the plan artifact exists' \
  "pge-exec broken handoff guard"
require_pattern skills/pge-exec/SKILL.md 'multiple plausible plan artifacts exist and no explicit selector is given' \
  "pge-exec ambiguous plan selection guard"
require_pattern skills/pge-exec/SKILL.md 'mkdir -p \.pge/tasks-<slug>/runs/<run_id>/' \
  "pge-exec run directory creation"
require_pattern skills/pge-exec/SKILL.md 'Generator \+ Evaluator' \
  "pge-exec generator/evaluator split"
require_pattern skills/pge-exec/SKILL.md 'pge-exec-pre-<run_id>' \
  "pge-exec rollback tag"
require_pattern skills/pge-exec/SKILL.md 'state\.json' \
  "pge-exec resume state"
require_pattern skills/pge-exec/SKILL.md 'learnings\.md' \
  "pge-exec learnings artifact"
require_pattern skills/pge-exec/SKILL.md '\.pge/tasks-smoke-test/runs/<run_id>/deliverables/smoke\.txt' \
  "pge-exec smoke test task-dir path"
require_pattern skills/pge-exec/SKILL.md 'Completion gate' \
  "pge-exec completion gate"
require_pattern skills/pge-exec/SKILL.md 'not chat-only summaries or ad-hoc pseudocode' \
  "pge-exec real artifact boundary"

require_pattern skills/pge-handoff/SKILL.md '\.pge/handoffs/<YYYYMMDD-HHMMSS>-<slug>\.md' \
  "pge-handoff save artifact"
require_pattern skills/pge-handoff/SKILL.md 'mkdir -p \.pge/handoffs/' \
  "pge-handoff directory creation"
require_pattern skills/pge-handoff/SKILL.md 'save\|extract\|restore' \
  "pge-handoff modes"

printf 'OK: PGE active contracts validated\n'
