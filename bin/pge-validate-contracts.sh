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
  skills/pge-ai-native-refactor/SKILL.md \
  skills/pge-handoff/SKILL.md \
  skills/pge-knowledge/SKILL.md \
  skills/pge-html/SKILL.md \
  skills/pge-html/references/template-contracts.md \
  skills/pge-html/templates/status-report.html \
  skills/pge-html/templates/research-explainer.html \
  skills/pge-html/templates/implementation-plan.html \
  skills/pge-html/templates/flowchart-diagram.html \
  skills/pge-html/templates/module-map.html \
  skills/pge-html/templates/execution-semantics.html \
  skills/pge-html/templates/comparison-board.html \
  skills/pge-html/templates/review-annotated.html \
  skills/pge-html/templates/code-review.html \
  skills/pge-html/templates/pr-writeup.html
do
  require_file "$file"
done

require_absent_file progress.md
require_absent_file ISSUES.md
require_absent_file skills/pge-setup/SKILL.md

require_pattern README.md 'pge-research → pge-plan → pge-exec' \
  "README core pipeline"
require_pattern README.md 'Research → Plan → Execute → Review → Ship' \
  "README full workflow arc"
require_pattern README.md 'pge-review → pge-challenge → ship' \
  "README review prove ship tail"
require_pattern README.md 'BLOCK_SHIP.*NEEDS_FIX.*READY_FOR_CHALLENGE.*READY_TO_SHIP' \
  "README review gate routes"
require_pattern README.md 'skills/pge-research/SKILL.md' \
  "README pge-research surface"
require_pattern README.md 'skills/pge-plan/SKILL.md' \
  "README pge-plan surface"
require_pattern README.md 'skills/pge-exec/SKILL.md' \
  "README pge-exec surface"
require_pattern README.md 'skills/pge-ai-native-refactor/SKILL.md' \
  "README pge-ai-native-refactor surface"
require_pattern README.md 'skills/pge-handoff/SKILL.md' \
  "README pge-handoff surface"
require_pattern README.md 'skills/pge-review/SKILL.md' \
  "README pge-review surface"
require_pattern README.md 'skills/pge-challenge/SKILL.md' \
  "README pge-challenge surface"
require_pattern README.md 'skills/pge-knowledge/SKILL.md' \
  "README pge-knowledge surface"
require_pattern README.md '\.pge/tasks-<slug>/plan\.md' \
  "README preferred plan artifact"

require_pattern CLAUDE.md 'skills/pge-research/SKILL.md' \
  "CLAUDE pge-research first read"
require_pattern CLAUDE.md 'skills/pge-handoff/SKILL.md' \
  "CLAUDE pge-handoff first read"
require_pattern CLAUDE.md 'skills/pge-review/SKILL.md' \
  "CLAUDE pge-review first read"
require_pattern CLAUDE.md 'skills/pge-challenge/SKILL.md' \
  "CLAUDE pge-challenge first read"
require_pattern CLAUDE.md 'skills/pge-ai-native-refactor/SKILL.md' \
  "CLAUDE pge-ai-native-refactor first read"
require_pattern CLAUDE.md 'skills/pge-knowledge/SKILL.md' \
  "CLAUDE pge-knowledge first read"
require_pattern CLAUDE.md 'Research → Plan → Execute → Review → Ship' \
  "CLAUDE full workflow authority"
require_pattern CLAUDE.md 'BLOCK_SHIP.*NEEDS_FIX.*READY_FOR_CHALLENGE.*READY_TO_SHIP' \
  "CLAUDE review gate routes"
require_pattern CLAUDE.md 'skills/pge-execute/` — removed' \
  "CLAUDE legacy pge-execute framing"
require_pattern CLAUDE.md 'Do not silently restore a Planner / Generator / Evaluator Claude Code Agent Teams orchestrator' \
  "CLAUDE no legacy orchestrator invariant"

require_pattern AGENTS.md 'Active research surface' \
  "AGENTS research surface"
require_pattern AGENTS.md 'Active review surface' \
  "AGENTS review surface"
require_pattern AGENTS.md 'Active prove-it surface' \
  "AGENTS prove-it surface"
require_pattern AGENTS.md 'Active AI-native refactor shaping surface' \
  "AGENTS ai-native refactor surface"
require_pattern AGENTS.md '\.pge/tasks-<slug>/research\.md' \
  "AGENTS preferred task artifact flow"
require_absent_pattern AGENTS.md 'docs/exec-plans/CURRENT_MAINLINE\.md|docs/exec-plans/ISSUES_LEDGER\.md' \
  "stale exec-plan docs reference"
require_absent_pattern AGENTS.md 'Active setup surface' \
  "stale pge-setup surface in AGENTS"
require_absent_pattern AGENTS.md 'pge-setup, pge-research' \
  "stale pge-setup in AGENTS invariants"
require_pattern AGENTS.md 'pge-research.*pge-plan.*pge-exec.*pge-review.*pge-challenge' \
  "AGENTS active workflow flow"

require_pattern .claude-plugin/plugin.json '"skill_directories"' \
  "plugin skill directory allowlist"
for skill in pge-research pge-plan pge-exec pge-ai-native-refactor pge-handoff pge-knowledge pge-html; do
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
require_pattern skills/pge-research/SKILL.md 'digraph pge_research' \
  "pge-research execution flow"
require_pattern skills/pge-research/SKILL.md 'Consume Upstream Contract.*Intent \+ Ledger \+ Decisions' \
  "pge-research flow consumes upstream contract"
require_pattern skills/pge-research/SKILL.md 'Spec Coverage Gate.*Ledger \+ Decisions \+ Phases' \
  "pge-research flow spec coverage gate"
require_pattern skills/pge-research/SKILL.md 'needs_info -> write_artifact' \
  "pge-research flow closes blocked route"
require_pattern skills/pge-research/SKILL.md 'Consume upstream specs' \
  "pge-research upstream input digestion"
require_pattern skills/pge-research/SKILL.md 'Capability: Upstream Contract Preservation' \
  "pge-research upstream preservation capability"
require_pattern skills/pge-research/SKILL.md 'Spec coverage gate' \
  "pge-research spec coverage gate"
require_pattern skills/pge-research/SKILL.md 'Does not re-litigate' \
  "pge-research does-not-relitigate principle"
require_pattern skills/pge-research/SKILL.md 'Upstream preservation review checklist' \
  "pge-research upstream preservation review checklist"
require_pattern skills/pge-research/SKILL.md 'Reframe ambiguous instructions as success criteria' \
  "pge-research success criteria reframing"
require_pattern skills/pge-research/SKILL.md 'Decision / Rationale / Alternatives considered' \
  "pge-research decision log"
require_pattern skills/pge-research/SKILL.md 'NEEDS CLARIFICATION.*three' \
  "pge-research clarification cap"
require_pattern skills/pge-research/SKILL.md 'Summarize The Spec Into A Fragment' \
  "pge-research no spec fragment anti-pattern"
require_pattern skills/pge-research/SKILL.md 'Intent = What To Do' \
  "pge-research structured intent anti-pattern"
require_pattern skills/pge-research/SKILL.md 'Planning should be able to produce executable issues from the brief without re-reading the original upstream spec' \
  "pge-research upstream digest completeness standard"
require_pattern skills/pge-research/SKILL.md 'Do NOT auto-invoke `pge-plan`' \
  "pge-research manual next-step handoff"
require_pattern skills/pge-research/SKILL.md 'Do NOT produce plans, numbered issues, implementation code, function bodies, pseudocode' \
  "pge-research no code boundary"
require_pattern skills/pge-research/templates/brief.md 'The Problem' \
  "pge-research structured intent problem"
require_pattern skills/pge-research/templates/brief.md 'Why This Step / Why Now' \
  "pge-research structured intent why now"
require_pattern skills/pge-research/templates/brief.md 'Synthesis Summary' \
  "pge-research stated inferred out summary"
require_pattern skills/pge-research/templates/brief.md 'basis: direct \| external \| reasoned' \
  "pge-research finding basis requirement"
require_pattern skills/pge-research/templates/brief.md 'validation:' \
  "pge-research assumption validation"
require_pattern skills/pge-research/templates/brief.md 'Decision Log' \
  "pge-research decision log template"
require_pattern skills/pge-research/templates/brief.md 'Alternatives considered' \
  "pge-research decision alternatives template"
require_pattern skills/pge-research/templates/brief.md 'Upstream Requirement Ledger' \
  "pge-research upstream requirement ledger"
require_pattern skills/pge-research/templates/brief.md 'Spec Coverage' \
  "pge-research spec coverage template"
require_pattern skills/pge-research/templates/brief.md 'Research Quality Gates' \
  "pge-research quality gates template"
require_pattern skills/pge-research/templates/brief.md 'Upstream Preservation Review' \
  "pge-research upstream review template"
require_pattern skills/pge-research/templates/brief.md 'Final Readiness' \
  "pge-research final readiness template"
require_pattern skills/pge-research/templates/brief.md 'pass/fail/n/a' \
  "pge-research quality gate status template"

require_pattern skills/pge-plan/SKILL.md '\.pge/tasks-<slug>/plan\.md' \
  "pge-plan preferred plan artifact"
require_pattern skills/pge-plan/SKILL.md 'mkdir -p \.pge/tasks-<slug>/' \
  "pge-plan task directory creation"
require_pattern skills/pge-plan/SKILL.md 'If research was skipped, pge-plan creates the task directory' \
  "pge-plan task directory ownership"
require_pattern skills/pge-plan/SKILL.md 'on a bare `pge-plan` invocation, discover research artifacts under `\.pge/tasks-<slug>/research\.md`' \
  "pge-plan bare invocation research discovery"
require_pattern skills/pge-plan/SKILL.md 'ask the user to choose when both a discovered artifact and current context look valid' \
  "pge-plan source selection question"
require_pattern skills/pge-plan/SKILL.md 'Direct prompt planning is a first-class path' \
  "pge-plan direct prompt planning capability"
require_pattern skills/pge-plan/SKILL.md 'Current prompt content is the highest-priority input and must never be ignored' \
  "pge-plan current prompt highest priority"
require_pattern skills/pge-plan/SKILL.md 'selector as the source location and the remaining text as binding current user constraints' \
  "pge-plan selector plus trailing constraints"
require_pattern skills/pge-plan/SKILL.md 'A discovered research artifact and the current conversation both look like valid upstream sources: ask the user which one to use instead of guessing' \
  "pge-plan context-vs-research guard"
require_pattern skills/pge-plan/SKILL.md 'Multiple plausible research artifacts and no explicit selector: ask the user which task to continue instead of guessing' \
  "pge-plan ambiguous research selection guard"
require_pattern skills/pge-plan/SKILL.md 'broken handoff instead of silently pretending the research artifact exists' \
  "pge-plan broken handoff guard"
require_pattern skills/pge-plan/SKILL.md 'Self-Evaluation' \
  "pge-plan self evaluation"
require_pattern skills/pge-plan/SKILL.md 'Consume Selected Source.*Current Constraints' \
  "pge-plan flow consumes selected source and constraints"
require_pattern skills/pge-plan/SKILL.md 'Coverage Audit.*requirements \+ decisions \+ phases' \
  "pge-plan flow coverage audit"
require_pattern skills/pge-plan/SKILL.md 'Input Priority Interpretation' \
  "pge-plan input priority interpretation"
require_pattern skills/pge-plan/SKILL.md 'derived research artifact names or depends on an original source-of-truth artifact' \
  "pge-plan original source reread rule"
require_pattern skills/pge-plan/SKILL.md 'Current constraint extraction' \
  "pge-plan current constraint extraction"
require_pattern skills/pge-plan/SKILL.md 'Scope Compression For Constrained Tasks' \
  "pge-plan constrained scope compression"
require_pattern skills/pge-plan/SKILL.md 'authority_ask -> self_eval' \
  "pge-plan flow returns after user answer"
require_pattern skills/pge-plan/SKILL.md 'authority_ask -> needs_human' \
  "pge-plan flow handles unanswered user challenge"
require_pattern skills/pge-plan/SKILL.md 'Decision Log / upstream spec decisions' \
  "pge-plan consumes upstream decisions"
require_pattern skills/pge-plan/SKILL.md 'Spec decisions coverage is mandatory' \
  "pge-plan spec decision coverage gate"
require_pattern skills/pge-plan/SKILL.md 'Spec-level decisions from upstream are authoritative' \
  "pge-plan spec-level decision authority"
require_pattern skills/pge-plan/SKILL.md 'Implementation-level choices are plan-owned' \
  "pge-plan implementation choice authority"
require_pattern skills/pge-plan/SKILL.md 'upstream_decision_refs' \
  "pge-plan issue upstream decision refs"
require_pattern skills/pge-plan/templates/plan.md 'Plan Constraints' \
  "pge-plan plan constraints template"
require_pattern skills/pge-plan/templates/plan.md 'Input Priority' \
  "pge-plan input priority template"
require_pattern skills/pge-plan/templates/plan.md 'Current prompt is the highest-priority input' \
  "pge-plan current prompt template"
require_pattern skills/pge-plan/templates/plan.md 'Current Constraints' \
  "pge-plan current constraints template"
require_pattern skills/pge-plan/templates/plan.md 'Spec Decisions Coverage' \
  "pge-plan spec decision coverage template"
require_pattern skills/pge-plan/templates/plan.md 'Phase Boundary' \
  "pge-plan phase boundary template"
require_pattern skills/pge-plan/templates/plan.md 'Upstream Decision ID' \
  "pge-plan decision override id template"
require_pattern skills/pge-plan/templates/plan.md 'Upstream ID' \
  "pge-plan upstream id coverage template"
require_pattern skills/pge-plan/templates/plan.md 'upstream_decision_refs' \
  "pge-plan issue decision refs template"
require_pattern skills/pge-plan/references/self-review.md 'Spec decision coverage' \
  "pge-plan self-review spec decision coverage"
require_pattern skills/pge-plan/references/self-review.md 'Current prompt constraints have the highest priority' \
  "pge-plan self-review current prompt priority"

require_pattern skills/pge-ai-native-refactor/SKILL.md 'Cannot Enter.*Cannot Contain.*Cannot Verify.*Structural Toxicity.*Missing Invariant' \
  "pge-ai-native-refactor friction lenses"
require_pattern skills/pge-ai-native-refactor/SKILL.md 'Matt Architecture Vocabulary' \
  "pge-ai-native-refactor matt architecture vocabulary"
require_pattern skills/pge-ai-native-refactor/SKILL.md 'Module.*Interface.*Depth.*Seam.*Adapter.*Leverage.*Locality' \
  "pge-ai-native-refactor matt terms"
require_pattern skills/pge-ai-native-refactor/SKILL.md 'PLAN_READY.*INTERACTION_REQUIRED.*BLOCKED' \
  "pge-ai-native-refactor route contract"
require_pattern skills/pge-ai-native-refactor/SKILL.md 'does not execute implementation, run PGE, or perform broad architecture modernization' \
  "pge-ai-native-refactor execution boundary"
require_pattern skills/pge-ai-native-refactor/SKILL.md 'Do not create `\.pge/` artifacts and do not invoke `pge-plan` automatically' \
  "pge-ai-native-refactor no auto-PGE boundary"
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
require_pattern skills/pge-exec/SKILL.md 'on a bare `pge-exec` invocation, discover `\.pge/tasks-<slug>/plan\.md`' \
  "pge-exec bare invocation plan discovery"
require_pattern skills/pge-exec/SKILL.md 'ask the user whether to execute the plan artifact or continue from the current context' \
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

require_pattern skills/pge-handoff/SKILL.md 'mktemp -t pge-handoff-XXXXXX\.md' \
  "pge-handoff temporary artifact"
require_pattern skills/pge-handoff/SKILL.md 'no knowledge extraction' \
  "pge-handoff no knowledge extraction boundary"
require_absent_pattern skills/pge-handoff/SKILL.md 'save\|extract\|restore|Mode: extract|HANDOFF_EXTRACTED|repo knowledge layer' \
  "old pge-handoff mixed-mode knowledge extraction"

require_pattern skills/pge-knowledge/SKILL.md 'Context friction' \
  "pge-knowledge context friction focus"
require_pattern skills/pge-knowledge/SKILL.md 'Memory / code summaries' \
  "pge-knowledge memory code-summary focus"
require_pattern skills/pge-knowledge/SKILL.md 'Quality Rubric' \
  "pge-knowledge quality rubric"
require_pattern skills/pge-knowledge/SKILL.md 'evaluate\|search\|prune\|export\|stats\|add' \
  "pge-knowledge management commands"
require_pattern skills/pge-knowledge/SKILL.md 'quality_score: <0-16>' \
  "pge-knowledge scored candidates"
require_pattern skills/pge-knowledge/SKILL.md 'Do not use this for session continuation' \
  "pge-knowledge not handoff boundary"

require_pattern skills/pge-html/SKILL.md 'Do not just make Markdown prettier' \
  "pge-html cognition-first rule"
require_pattern skills/pge-html/SKILL.md 'references/template-contracts\.md' \
  "pge-html template contracts reference"
require_pattern skills/pge-html/SKILL.md 'execution-semantics' \
  "pge-html execution semantics style"
require_pattern skills/pge-html/SKILL.md 'Escape all source text before inserting into HTML' \
  "pge-html escaping rule"
require_pattern skills/pge-html/references/template-contracts.md 'Common Quality Gate' \
  "pge-html common quality gate"
require_pattern skills/pge-html/references/template-contracts.md '## execution-semantics' \
  "pge-html execution semantics contract"
require_pattern skills/pge-html/references/template-contracts.md '## module-map' \
  "pge-html module map contract"
require_pattern skills/pge-html/references/template-contracts.md '## code-review' \
  "pge-html code review contract"
require_pattern skills/pge-html/templates/execution-semantics.html 'Execution Semantics' \
  "pge-html execution semantics template"
require_pattern skills/pge-html/templates/execution-semantics.html 'Agent Gotchas First' \
  "pge-html execution semantics gotchas"
require_pattern skills/pge-html/templates/execution-semantics.html 'Verification Hotspots' \
  "pge-html execution semantics verification"
require_pattern skills/pge-html/templates/execution-semantics.html 'textContent' \
  "pge-html execution semantics safe text update"

require_pattern skills/pge-review/SKILL.md 'Review Gate' \
  "pge-review gate section"
require_pattern skills/pge-review/SKILL.md 'BLOCK_SHIP.*NEEDS_FIX.*READY_FOR_CHALLENGE.*READY_TO_SHIP' \
  "pge-review route contract"
require_pattern skills/pge-review/SKILL.md 'The default successful route is `READY_FOR_CHALLENGE`' \
  "pge-review default success route"

printf 'OK: PGE active contracts validated\n'
