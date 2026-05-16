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
  commands/local-install.md \
  docs/exec-plan/pge-exec-boundary-transcript.md \
  bin/pge-local-install.sh \
  skills/pge-research/SKILL.md \
  skills/pge-plan/SKILL.md \
  skills/pge-plan-normalize/SKILL.md \
  skills/pge-exec/SKILL.md \
  skills/pge-review/SKILL.md \
  skills/pge-challenge/SKILL.md \
  skills/pge-ai-native-refactor/SKILL.md \
  skills/pge-handoff/SKILL.md \
  skills/pge-knowledge/SKILL.md \
  skills/pge-html/SKILL.md \
  skills/pge-html/references/template-contracts.md \
  skills/pge-html/templates/01-exploration-code-approaches.html \
  skills/pge-html/templates/02-exploration-visual-designs.html \
  skills/pge-html/templates/03-code-review-pr.html \
  skills/pge-html/templates/04-code-understanding.html \
  skills/pge-html/templates/05-design-system.html \
  skills/pge-html/templates/06-component-variants.html \
  skills/pge-html/templates/07-prototype-animation.html \
  skills/pge-html/templates/08-prototype-interaction.html \
  skills/pge-html/templates/09-slide-deck.html \
  skills/pge-html/templates/10-svg-illustrations.html \
  skills/pge-html/templates/11-status-report.html \
  skills/pge-html/templates/12-incident-report.html \
  skills/pge-html/templates/13-flowchart-diagram.html \
  skills/pge-html/templates/14-research-feature-explainer.html \
  skills/pge-html/templates/15-research-concept-explainer.html \
  skills/pge-html/templates/16-implementation-plan.html \
  skills/pge-html/templates/17-pr-writeup.html \
  skills/pge-html/templates/18-editor-triage-board.html \
  skills/pge-html/templates/19-editor-feature-flags.html \
  skills/pge-html/templates/20-editor-prompt-tuner.html
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
require_pattern README.md 'routing to fix, challenge, or ship' \
  "README review gate summary"
require_pattern README.md 'skills/pge-research/SKILL.md' \
  "README pge-research surface"
require_pattern README.md 'skills/pge-plan/SKILL.md' \
  "README pge-plan surface"
require_pattern README.md 'skills/pge-plan-normalize/SKILL.md' \
  "README pge-plan-normalize surface"
require_absent_pattern README.md 'support surfaces.*pge-plan-normalize' \
  "README duplicate pge-plan-normalize support classification"
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
require_pattern README.md 'semantic alignment' \
  "README semantic alignment invariant"
require_pattern README.md 'fixed interfaces with flexible expression' \
  "README fixed interface flexible expression"
require_pattern README.md 'Every stage must consume its explicit input plus relevant current context' \
  "README stage input context intake"
require_pattern README.md 'Exec should not be where major intent or acceptance ambiguity is resolved' \
  "README exec ambiguity boundary"

require_pattern CLAUDE.md 'skills/pge-research/SKILL.md' \
  "CLAUDE pge-research first read"
require_pattern CLAUDE.md 'skills/pge-plan-normalize/SKILL.md' \
  "CLAUDE pge-plan-normalize first read"
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
require_pattern CLAUDE.md 'semantic alignment with the original user intent' \
  "CLAUDE semantic alignment invariant"
require_pattern CLAUDE.md 'contract discipline, not template bureaucracy' \
  "CLAUDE contract discipline invariant"
require_pattern CLAUDE.md 'Every stage must consume its explicit invocation input plus relevant current context' \
  "CLAUDE stage input context intake"
require_pattern CLAUDE.md 'Research and plan own intent discovery' \
  "CLAUDE research plan own discovery"
require_absent_pattern CLAUDE.md 'invoke office-hours|invoke investigate|invoke ship|invoke qa|invoke document-release|invoke plan-eng-review' \
  "CLAUDE non-PGE generic skill routing"

require_pattern AGENTS.md 'Active research surface' \
  "AGENTS research surface"
require_pattern AGENTS.md 'Active normalization surface' \
  "AGENTS normalization surface"
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
for skill in pge-research pge-plan pge-plan-normalize pge-exec pge-ai-native-refactor pge-handoff pge-knowledge pge-html; do
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
require_pattern commands/local-install.md 'real smoke exercise in a Claude Code runtime surface that can execute the Agent Team control-plane calls' \
  "local install real Agent Team smoke requirement"
require_pattern commands/local-install.md 'Do not add a fake inline test mode to `pge-exec`' \
  "local install fake pge-exec smoke prohibition"
require_absent_pattern commands/local-install.md '/pge-exec test|pge-exec test|tasks-smoke-test/runs/<run_id>/deliverables/smoke\.txt' \
  "local install stale fake pge-exec smoke path"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'Non-Canonical Source' \
  "pge-exec transcript non-canonical route"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'type: lane_ready' \
  "pge-exec transcript lane-ready packet"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'type: generator_completion' \
  "pge-exec transcript generator packet"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'type: evaluator_verdict' \
  "pge-exec transcript evaluator packet"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'next: pge-review task-alpha' \
  "pge-exec transcript review-stage route"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'alternate_next: pge-challenge task-alpha \(prove-it gate inside Review stage\)' \
  "pge-exec transcript challenge prove-it route"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'pge-exec repair review findings for task-alpha' \
  "pge-exec transcript repair rerun prompt"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'task artifacts: `\.pge/tasks-task-alpha/review\.md`, `\.pge/tasks-task-alpha/challenge\.md`' \
  "pge-exec transcript task artifact repair input"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'reads matching review/challenge task artifacts plus current context as bounded repair input' \
  "pge-exec transcript task-artifact repair backflow"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md '`in-contract` findings stay inside `pge-exec` as bounded repair work' \
  "pge-exec transcript in-contract repair boundary"
require_pattern docs/exec-plan/pge-exec-boundary-transcript.md 'only findings that require changing the plan contract route upstream to `pge-plan`' \
  "pge-exec transcript contract-change upstream boundary"

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
require_pattern skills/pge-research/SKILL.md 'brainstorm.*clarify.*zoom-out|brainstorm.*clarify / grill-with-me.*zoom-out' \
  "pge-research integrated brainstorm clarify zoom-out"
require_pattern skills/pge-research/SKILL.md 'Research Value Proof' \
  "pge-research value proof"
require_pattern skills/pge-research/SKILL.md 'Intent Spec' \
  "pge-research intent spec"
require_pattern skills/pge-research/SKILL.md 'intent alignment' \
  "pge-research intent alignment"
require_pattern skills/pge-research/SKILL.md 'intent_spec' \
  "pge-research minimum contract intent_spec"
require_pattern skills/pge-research/SKILL.md 'clarify_status' \
  "pge-research minimum contract clarify_status"
require_pattern skills/pge-research/SKILL.md 'plan_delta' \
  "pge-research minimum contract plan_delta"
require_pattern skills/pge-research/SKILL.md 'Resolve stage input and current context' \
  "pge-research stage input context intake"
require_pattern skills/pge-research/SKILL.md 'grill-with-me' \
  "pge-research user clarification challenge"
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
require_pattern skills/pge-research/templates/brief.md 'Intent Lock' \
  "pge-research intent lock template"
require_pattern skills/pge-research/templates/brief.md 'minimum contract scaffold' \
  "pge-research minimum contract scaffold"
require_pattern skills/pge-research/templates/brief.md 'intent_spec' \
  "pge-research contract field intent_spec"
require_pattern skills/pge-research/templates/brief.md 'clarify_status' \
  "pge-research contract field clarify_status"
require_pattern skills/pge-research/templates/brief.md 'plan_delta' \
  "pge-research contract field plan_delta"
require_pattern skills/pge-research/templates/brief.md 'Brainstorm' \
  "pge-research brainstorm template"
require_pattern skills/pge-research/templates/brief.md 'Clarify / Grill-With-Me Log' \
  "pge-research clarify grill template"
require_pattern skills/pge-research/templates/brief.md 'Intent Spec' \
  "pge-research intent spec template"
require_pattern skills/pge-research/templates/brief.md 'Intent Spec Challenge' \
  "pge-research intent spec challenge template"
require_pattern skills/pge-research/templates/brief.md 'Zoom-Out Map' \
  "pge-research zoom-out map template"
require_pattern skills/pge-research/templates/brief.md 'Research Value Proof' \
  "pge-research value proof template"
require_pattern skills/pge-research/templates/brief.md 'Plan Delta' \
  "pge-research plan delta template"
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
require_pattern skills/pge-plan/SKILL.md 'Context Intake and Clarification' \
  "pge-plan context intake and clarification"
require_pattern skills/pge-plan/SKILL.md 'Plan may self-research from intent' \
  "pge-plan self research from intent"
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
require_pattern skills/pge-plan/SKILL.md 'contract alignment' \
  "pge-plan contract alignment"
require_pattern skills/pge-plan/SKILL.md 'goal' \
  "pge-plan minimum contract goal"
require_pattern skills/pge-plan/SKILL.md 'non_goals' \
  "pge-plan minimum contract non_goals"
require_pattern skills/pge-plan/SKILL.md 'evidence_required' \
  "pge-plan minimum contract evidence_required"
require_pattern skills/pge-plan/templates/plan.md 'Plan Constraints' \
  "pge-plan plan constraints template"
require_pattern skills/pge-plan/templates/plan.md 'minimum contract scaffold' \
  "pge-plan minimum contract scaffold"
require_pattern skills/pge-plan/templates/plan.md 'ready_for_exec' \
  "pge-plan ready_for_exec contract field"
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
require_pattern skills/pge-plan-normalize/SKILL.md 'READY_FOR_EXECUTE_WITH_ASSUMPTIONS' \
  "pge-plan-normalize assumptions route"
require_pattern skills/pge-plan-normalize/SKILL.md 'lossless adapter, not a planning workflow' \
  "pge-plan-normalize role boundary"
require_pattern skills/pge-plan-normalize/SKILL.md 'Any inferred execution-critical field forces this route' \
  "pge-plan-normalize inferred critical route"
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
require_pattern skills/pge-exec/SKILL.md 'lane_ready' \
  "pge-exec lane ready preflight"
require_pattern skills/pge-exec/SKILL.md 'general-purpose' \
  "pge-exec generator default lane type"
require_pattern skills/pge-exec/SKILL.md 'agent-skills:code-reviewer' \
  "pge-exec evaluator default lane type"
require_pattern skills/pge-exec/SKILL.md 'shutdown_response' \
  "pge-exec shutdown confirmation"
require_pattern skills/pge-exec/SKILL.md 'shutdown approval|teammate termination' \
  "pge-exec runtime-level shutdown completion"
require_pattern skills/pge-exec/SKILL.md 'consumes only canonical `\.pge/tasks-<slug>/plan\.md`' \
  "pge-exec canonical only"
require_absent_pattern skills/pge-exec/SKILL.md 'Normalize in exec|Prefer exec normalization|execute-normalize directly' \
  "stale exec normalization path"
require_absent_pattern skills/pge-exec/SKILL.md 'Empty learnings\.md is a protocol violation|Feedback to Config' \
  "stale exec compound path"
require_absent_pattern skills/pge-exec/SKILL.md 'TeamDelete\(team_name=team_name\)' \
  "pge-exec legacy TeamDelete signature"
require_absent_pattern skills/pge-exec/SKILL.md '`coder` \| `reviewer`|default `coder` / `reviewer`' \
  "pge-exec legacy default lane types"
require_pattern skills/pge-exec/SKILL.md '\.pge/tasks-<slug>/runs/<run_id>/' \
  "pge-exec run artifact"
require_absent_pattern skills/pge-exec/SKILL.md '\.pge/runs/' \
  "pge-exec legacy run path"
require_pattern skills/pge-exec/SKILL.md 'Do not execute from conversation context or a non-canonical source' \
  "pge-exec rejects non-canonical sources"
require_pattern skills/pge-exec/SKILL.md 'pge-exec <task-slug> --run-id <run_id>' \
  "pge-exec explicit run-id invocation"
require_pattern skills/pge-exec/SKILL.md 'pge-exec repair review findings for <task-slug>' \
  "pge-exec review repair prompt"
require_pattern skills/pge-exec/SKILL.md 'pge-exec repair challenge findings for <task-slug>' \
  "pge-exec challenge repair prompt"
require_pattern skills/pge-exec/SKILL.md '\.pge/tasks-<slug>/review\.md.*\.pge/tasks-<slug>/challenge\.md' \
  "pge-exec task-artifact repair input"
require_pattern skills/pge-exec/SKILL.md 'current-context review/challenge output as bounded repair input|current context.*bounded repair input' \
  "pge-exec current-context repair input"
require_pattern skills/pge-exec/SKILL.md 'mkdir -p \.pge/tasks-<slug>/runs/<run_id>/' \
  "pge-exec run directory creation"
require_pattern skills/pge-exec/SKILL.md 'peer Generator \+ Evaluator lanes|Generator and Evaluator are complementary peer lanes' \
  "pge-exec generator/evaluator peer lanes"
require_pattern skills/pge-exec/SKILL.md 'pge-exec-pre-<run_id>' \
  "pge-exec rollback tag"
require_pattern skills/pge-exec/SKILL.md 'state\.json' \
  "pge-exec resume state"
require_pattern skills/pge-exec/SKILL.md 'Non-Team fallback is not a valid `pge-exec` execution mode' \
  "pge-exec no non-team fallback"
require_absent_pattern skills/pge-exec/SKILL.md 'In headless mode, auto-approve|In headless mode, pick the first option|record as LOW-confidence assumption' \
  "pge-exec stale headless HITL auto decision"
require_pattern skills/pge-exec/SKILL.md 'Headless mode must not turn missing human confirmation into approval or missing human choice into a decision' \
  "pge-exec headless HITL no false approval"
require_pattern skills/pge-exec/SKILL.md 'Without human confirmation or an explicit plan-provided automated substitute, route `NEEDS_HUMAN`' \
  "pge-exec HITL verify needs human"
require_pattern skills/pge-exec/SKILL.md 'Without a user decision, route `NEEDS_HUMAN`' \
  "pge-exec HITL decision needs human"
require_absent_pattern skills/pge-exec/SKILL.md 'learnings_recorded' \
  "pge-exec stale learnings response field"
require_pattern skills/pge-exec/SKILL.md 'Do not require `learnings\.md`' \
  "pge-exec facts-only artifact boundary"
require_pattern skills/pge-exec/SKILL.md 'pge-challenge <task-slug> \(prove-it gate inside Review stage\)' \
  "pge-exec challenge next-step review-stage qualifier"
require_pattern skills/pge-exec/SKILL.md '`PASS`.*`READY_FOR_CHALLENGE`' \
  "pge-exec final review pass mapping"
require_pattern skills/pge-exec/SKILL.md '`ADVISORY_ONLY`.*`READY_FOR_CHALLENGE`' \
  "pge-exec final review advisory mapping"
require_pattern skills/pge-exec/SKILL.md '`REPAIR_REQUIRED`.*`NEEDS_FIX`' \
  "pge-exec final review repair mapping"
require_pattern skills/pge-exec/SKILL.md '`BLOCKED`.*`BLOCK_SHIP`' \
  "pge-exec final review blocked mapping"
require_pattern skills/pge-exec/SKILL.md 'When `pge-exec` is rerun after `pge-review`, `pge-challenge`, or external review, read the matching task artifact under `\.pge/tasks-<slug>/review\.md` or `\.pge/tasks-<slug>/challenge\.md` plus any explicit review/challenge output in current context, and treat `in-contract` findings as bounded repair input' \
  "pge-exec review challenge backflow"
require_pattern skills/pge-exec/SKILL.md 'If no task artifact or explicit current-context repair input is present, route `NEEDS_HUMAN` for the missing repair input instead of guessing' \
  "pge-exec missing repair input needs human"
require_pattern skills/pge-exec/SKILL.md 'routes upstream to `pge-plan` only when resolving it would require changing the plan contract itself' \
  "pge-exec contract-change upstream boundary"
require_pattern skills/pge-exec/SKILL.md 'default post-exec path remains `pge-review` then `pge-challenge`' \
  "pge-exec default review challenge path"
require_pattern skills/pge-exec/SKILL.md 'hand off directly to `pge-challenge` as a prove-it gate inside the Review stage' \
  "pge-exec direct challenge prove-it path"
require_pattern skills/pge-exec/SKILL.md '`READY_TO_SHIP` is not produced by `pge-exec` final review' \
  "pge-exec no ready-to-ship final review route"
require_pattern skills/pge-exec/SKILL.md 'Completion gate' \
  "pge-exec completion gate"
require_pattern skills/pge-exec/SKILL.md 'not chat-only summaries or ad-hoc pseudocode' \
  "pge-exec real artifact boundary"
require_pattern skills/pge-exec/SKILL.md 'evidence alignment' \
  "pge-exec evidence alignment"
require_pattern skills/pge-exec/handoffs/generator.md 'type: lane_ready' \
  "pge-exec generator lane ready packet"
require_pattern skills/pge-exec/handoffs/generator.md 'type: shutdown_response' \
  "pge-exec generator shutdown response"
require_pattern skills/pge-exec/handoffs/generator.md 'shutdown_request' \
  "pge-exec generator shutdown request handling"
require_pattern skills/pge-exec/handoffs/evaluator.md 'type: lane_ready' \
  "pge-exec evaluator lane ready packet"
require_pattern skills/pge-exec/handoffs/evaluator.md 'type: shutdown_response' \
  "pge-exec evaluator shutdown response"
require_pattern skills/pge-exec/handoffs/evaluator.md 'shutdown_request' \
  "pge-exec evaluator shutdown request handling"
require_pattern skills/pge-exec/handoffs/reviewer.md '`READY_TO_SHIP` is not produced by `pge-exec` final review' \
  "pge-exec reviewer handoff no ready-to-ship route"
require_pattern skills/pge-exec/handoffs/reviewer.md '`REPAIR_REQUIRED`.*`NEEDS_FIX`' \
  "pge-exec reviewer handoff repair route mapping"

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
require_pattern skills/pge-html/SKILL.md 'version: 2\.0\.0' \
  "pge-html v2 version"
require_pattern skills/pge-html/SKILL.md 'Scoring dimensions' \
  "pge-html scoring-based template selection"
require_pattern skills/pge-html/SKILL.md 'structure.*reader-task.*density|structure \+ reader-task.*content-density' \
  "pge-html scoring dimensions"
require_pattern skills/pge-html/SKILL.md 'Winner: `04-code-understanding`' \
  "pge-html listwise template decision"
require_pattern skills/pge-html/SKILL.md '不丢内容' \
  "pge-html content preservation rule"
require_pattern skills/pge-html/SKILL.md '子结构混合' \
  "pge-html substructure mixing rule"
require_pattern skills/pge-html/SKILL.md 'Phase 5: Reshape' \
  "pge-html reshape phase"
require_pattern skills/pge-html/SKILL.md 'Reference palette by default' \
  "pge-html reference palette rule"
require_pattern skills/pge-html/SKILL.md 'Escape all source text before inserting into HTML' \
  "pge-html escaping rule"
require_pattern skills/pge-html/references/template-contracts.md 'Common Quality Gate' \
  "pge-html common quality gate"
require_pattern skills/pge-html/references/template-contracts.md '## code-understanding' \
  "pge-html code understanding contract"
require_pattern skills/pge-html/references/template-contracts.md '## code-review' \
  "pge-html code review contract"
require_pattern skills/pge-html/templates/04-code-understanding.html 'How authentication flows through the codebase' \
  "pge-html code understanding template"
require_pattern skills/pge-html/templates/04-code-understanding.html 'details class="snippet"' \
  "pge-html code understanding collapsible snippets"
require_pattern skills/pge-html/templates/11-status-report.html 'Engineering Status' \
  "pge-html status report template"
require_pattern skills/pge-html/templates/13-flowchart-diagram.html 'annotated flowchart' \
  "pge-html flowchart template"
require_pattern skills/pge-html/templates/16-implementation-plan.html 'Implementation plan' \
  "pge-html implementation plan template"

require_pattern skills/pge-review/SKILL.md 'Review Gate' \
  "pge-review gate section"
require_pattern skills/pge-review/SKILL.md 'BLOCK_SHIP.*NEEDS_FIX.*READY_FOR_CHALLENGE.*READY_TO_SHIP' \
  "pge-review route contract"
require_pattern skills/pge-review/SKILL.md 'The default successful route is `READY_FOR_CHALLENGE`' \
  "pge-review default success route"
require_pattern skills/pge-review/SKILL.md 'task_dir: \.pge/tasks-<slug>/' \
  "pge-review task artifact path"
require_pattern skills/pge-review/SKILL.md 'artifact_path: \.pge/tasks-<slug>/review\.md' \
  "pge-review review artifact path"
require_pattern skills/pge-review/SKILL.md 'Exec Repair Contract' \
  "pge-review exec repair contract"
require_pattern skills/pge-review/SKILL.md '`source`:' \
  "pge-review source field"
require_pattern skills/pge-review/SKILL.md '`severity`:' \
  "pge-review severity field"
require_pattern skills/pge-review/SKILL.md '`scope`:' \
  "pge-review scope field"
require_pattern skills/pge-review/SKILL.md '`bounded_fix`:' \
  "pge-review bounded-fix field"
require_pattern skills/pge-review/SKILL.md '`next_repair_path`:' \
  "pge-review next-repair-path field"
require_pattern skills/pge-review/SKILL.md 'in-contract' \
  "pge-review in-contract scope anchor"
require_pattern skills/pge-review/SKILL.md 'contract-change' \
  "pge-review contract-change scope anchor"
require_pattern skills/pge-review/SKILL.md 'route upstream to `pge-plan`' \
  "pge-review contract-change upstream route"
require_pattern skills/pge-review/SKILL.md 'Semantic Alignment' \
  "pge-review semantic alignment axis"
require_pattern skills/pge-review/SKILL.md 'original user intent' \
  "pge-review original intent check"

require_pattern skills/pge-challenge/SKILL.md 'Prompt Challenge Matrix' \
  "pge-challenge prompt proof matrix"
require_pattern skills/pge-challenge/SKILL.md 'Plan Fulfillment Matrix' \
  "pge-challenge plan fulfillment matrix"
require_pattern skills/pge-challenge/SKILL.md 'Review Self-Proof Matrix' \
  "pge-challenge self proof matrix"
require_pattern skills/pge-challenge/SKILL.md 'task_dir: \.pge/tasks-<slug>/' \
  "pge-challenge task artifact path"
require_pattern skills/pge-challenge/SKILL.md 'artifact_path: \.pge/tasks-<slug>/challenge\.md' \
  "pge-challenge challenge artifact path"
require_pattern skills/pge-challenge/SKILL.md 'Execution Feedback Contract' \
  "pge-challenge execution feedback contract"
require_pattern skills/pge-challenge/SKILL.md '`source`:' \
  "pge-challenge source field"
require_pattern skills/pge-challenge/SKILL.md '`result`:' \
  "pge-challenge result field"
require_pattern skills/pge-challenge/SKILL.md '`scope`:' \
  "pge-challenge scope field"
require_pattern skills/pge-challenge/SKILL.md '`bounded_fix`:' \
  "pge-challenge bounded-fix field"
require_pattern skills/pge-challenge/SKILL.md '`next_repair_path`:' \
  "pge-challenge next-repair-path field"
require_pattern skills/pge-challenge/SKILL.md 'in-contract' \
  "pge-challenge in-contract scope anchor"
require_pattern skills/pge-challenge/SKILL.md 'contract-change' \
  "pge-challenge contract-change scope anchor"
require_pattern skills/pge-challenge/SKILL.md 'route upstream to `pge-plan`' \
  "pge-challenge contract-change upstream route"
require_pattern skills/pge-challenge/SKILL.md 'prove_expected \| challenge_claim' \
  "pge-challenge challenge models"
require_pattern skills/pge-challenge/SKILL.md 'sentence to prove or challenge' \
  "pge-challenge statement argument"
require_pattern skills/pge-challenge/SKILL.md 'judgment claim' \
  "pge-challenge judgment claim proof"
require_pattern skills/pge-challenge/SKILL.md 'prompt_ref: not_provided' \
  "pge-challenge prompt optional execution mode"
require_pattern skills/pge-challenge/SKILL.md 'BLOCK_SHIP.*NEEDS_FIX.*READY_TO_SHIP' \
  "pge-challenge route contract"
require_pattern skills/pge-challenge/SKILL.md 'Current prompt outranks older plan/research artifacts' \
  "pge-challenge prompt priority"
require_pattern skills/pge-challenge/SKILL.md 'Do not fix implementation' \
  "pge-challenge no implementation boundary"

printf 'OK: PGE active contracts validated\n'
