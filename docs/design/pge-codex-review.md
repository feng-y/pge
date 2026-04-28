# PGE Codex Independent Review (Round 3)

> Reviewer: Independent external reviewer (Codex-style)
> Date: 2026-04-29
> Scope: All docs/design/ documents + repo context
> Perspective: External reviewer with no project history, maximum skepticism

---

# Findings

## P0 Blocking Issues

### P0-1: Sprint layer contradicts explicit "don't learn Sprint" conclusion

- **issue**: `pge-multiround-runtime-design.md` introduces a full sprint layer (run > sprint > round) as a core structural concept. However, `pge-reference-learning-notes.md` Section 1 "不学什么" item 1 explicitly states: "V2 移除 Sprint 构造 — Anthropic 在 Opus 4.6 上移除了 sprint 构造，因为模型原生能力足以处理长任务分解。PGE 的 bounded round 是有意的设计约束（proving 需要边界），不应因模型能力提升而移除。" The rationale in Appendix B ("Anthropic 的 sprint contract 模式证明了 bounded slice 的价值") directly contradicts the learning note's conclusion that Anthropic *removed* sprints. The design learns the thing it said not to learn.
- **evidence**: `pge-reference-learning-notes.md` line 26-27 vs `pge-multiround-runtime-design.md` §1 entire section + Appendix B decision D1
- **affected document**: `pge-multiround-runtime-design.md`, `pge-reference-learning-notes.md`
- **affected Critical Gate**: Gate 3 (Generator sprint/feature granularity), Gate 5 (Runtime long-running execution)
- **required fix**: Either (a) remove the sprint layer and use a flat run > round model with Planner re-planning as the natural "phase boundary", or (b) explicitly revise the learning note to explain why PGE's sprint is semantically different from Anthropic's removed sprint construct, with a clear definition of what PGE's sprint adds that a simple "Planner re-plan round" does not. The current state is self-contradictory.

### P0-2: Actual artifact naming diverges from all design documents

- **issue**: All design documents reference artifact paths like `<run_id>-planner.md`, `<run_id>-generator.md`, `<run_id>-evaluator.md`, `<run_id>-summary.md`. The actual `.pge-artifacts/` directory contains files named `<run_id>-planner-output.md`, `<run_id>-generator-output.md`, `<run_id>-evaluator-verdict.md`, `<run_id>-round-summary.md`. Additionally, the 3 historical runs contain only 4 files each, missing 5 of the 9 artifacts defined in `ORCHESTRATION.md` (no `-input.md`, `-contract-proposal.md`, `-preflight.md`, `-state.json`, `-progress.md`).
- **evidence**: `ls .pge-artifacts/` shows `run-1776665033-planner-output.md` etc. vs `ORCHESTRATION.md` line 57-65 defining `<run_id>-planner.md` etc.
- **affected document**: `pge-rebuild-plan.md` §1 "Confirmed" table, `pge-multiround-runtime-design.md` Appendix A, `pge-contract-negotiation-design.md` §9.3
- **affected Critical Gate**: All gates (artifact paths are foundational)
- **required fix**: (1) Acknowledge in `pge-rebuild-plan.md` that the 3 historical runs used a pre-ORCHESTRATION naming convention and are not "complete runs" by current definition. (2) Decide whether the design docs or the actual naming is authoritative and align. (3) Remove or qualify the "3 个完整 run" claim.

### P0-3: Two independent, conflicting runtime-state schema extensions

- **issue**: `pge-multiround-runtime-design.md` §2.1 defines a runtime-state schema with `sprint_id`, `round_id`, `sprint_sequence`, `sprint_goal`, `sprint_status`, `round_sequence`, `team_status`, `route_reason`, `convergence_reason`, etc. `pge-contract-negotiation-design.md` §10.3 defines a separate extension with `negotiation_round`, `max_negotiation_rounds`, `total_preflight_cycles`, `max_total_preflight_cycles`, `contract_locked`, `contract_locked_at_preflight`. Neither document references the other's fields. If both are implemented, the runtime-state schema has two independent, uncoordinated extensions.
- **evidence**: `pge-multiround-runtime-design.md` §2.1 schema vs `pge-contract-negotiation-design.md` §10.3 "新增 Runtime State 字段"
- **affected document**: Both design documents
- **affected Critical Gate**: Gate 2 (Preflight negotiation), Gate 3 (Generator granularity), Gate 5 (Runtime recovery)
- **required fix**: Produce a single unified runtime-state schema that incorporates both extensions. Define which fields are Phase 1 vs Phase 2 vs Phase 3. Ensure no naming conflicts or semantic overlaps.

### P0-4: `pge-contract-negotiation-design.md` introduces `planning_round` state not in multiround design

- **issue**: `pge-contract-negotiation-design.md` §5.1 state machine and §10.4 introduce `planning_round` as a state with transitions `routing -> planning_round` and `preflight_pending -> planning_round`. The `pge-multiround-runtime-design.md` §8.1 state enumeration uses `planning` (not `planning_round`). The `runtime-state-contract.md` uses `planning_round`. The `ORCHESTRATION.md` uses `planning`. Three different documents use two different state names for what appears to be the same concept, with no reconciliation.
- **evidence**: `pge-contract-negotiation-design.md` §10.4 uses `planning_round`; `pge-multiround-runtime-design.md` §8.1 uses `planning`; `runtime-state-contract.md` line 57 uses `planning_round`; `ORCHESTRATION.md` line 73 uses `planning`
- **affected document**: `pge-contract-negotiation-design.md`, `pge-multiround-runtime-design.md`
- **affected Critical Gate**: Gate 2, Gate 3
- **required fix**: Pick one canonical name. Update all design documents and the normative contract to use it consistently.

## P1 Major Issues

### P1-1: "从当前 repo 提升" framing understates implementation scope

- **issue**: `pge-multiround-runtime-design.md` §8.4 and Appendix C repeatedly describe new states (`preflight_failed`, `awaiting_evaluation`, `routing`, `sprint_complete`) as "从 runtime-state-contract.md 提升" and "不是凭空引入". While technically true (these states exist in the normative superset), the framing obscures the fact that these states have never been executed. The normative superset is a design document, not a running system. "Promoting" from a design doc to another design doc is not the same as "promoting" from a running system. This framing may cause implementers to underestimate the work.
- **evidence**: `pge-multiround-runtime-design.md` §8.4 "新增状态全部来自当前 runtime-state-contract.md 的规范性超集，不是凭空引入" vs `ORCHESTRATION.md` which only implements `initialized`, `team_created`, `planning`, `preflight_pending`, `ready_to_generate`, `generating`, `evaluating`, `unsupported_route`, `converged`, `stopped`, `failed`
- **affected document**: `pge-multiround-runtime-design.md`
- **affected Critical Gate**: Gate 3, Gate 5
- **required fix**: Reframe as "将规范性定义转为可执行实现" and explicitly list which states are currently executable vs design-only.

### P1-2: Evaluator threshold design is a major format rewrite disguised as "extension"

- **issue**: `pge-evaluator-threshold-design.md` §10.1 claims "扩展而非替换当前 agents/pge-evaluator.md 的行为". The current evaluator outputs 5 markdown sections (verdict, evidence, violated_invariants_or_risks, required_fixes, next_route). The proposed design requires 6 scored dimensions with rationale and evidence_refs each, 7 boolean blocking flags, a weighted score calculation, structured evidence items with type/source/content_summary/supports_criteria/independent fields, severity-tagged invariant violations, structured required_fixes with contract_field and required_evidence, and anti-slop detection. This is not an extension — it is a complete redesign of the evaluator output format.
- **evidence**: Current `agents/pge-evaluator.md` output fields vs `pge-evaluator-threshold-design.md` §6.1 full schema
- **affected document**: `pge-evaluator-threshold-design.md`
- **affected Critical Gate**: Gate 4 (Evaluator hard-threshold grading)
- **required fix**: Acknowledge this is a format rewrite. Define a concrete migration path: what does the evaluator output look like at Phase 1 (minimal scoring added to existing format) vs Phase 2 (structured evidence) vs Phase 3 (full schema)? The current §10.2 phases are too vague — they don't show intermediate output formats.

### P1-3: Phase dependency chain may be unnecessarily sequential

- **issue**: `pge-rebuild-plan.md` §6 declares Phase 2 (Multi-round routing) depends on Phase 1 (Evaluator hard-threshold), with rationale "Evaluator 必须能产出结构化反馈，retry 才有意义". But the current evaluator already produces `required_fixes` (free text) and `next_route`. A retry loop needs: (1) a route decision, (2) feedback to pass to the next round, (3) loop termination. The current evaluator already provides (1) and (2) in narrative form. Quantified scoring is valuable but not a prerequisite for retry. Making Phase 1 a hard dependency on Phase 2 delays the most impactful capability (multi-round) behind the most complex change (evaluator rewrite).
- **evidence**: `pge-rebuild-plan.md` §6 Phase 2 "依赖: Phase 1" vs current `agents/pge-evaluator.md` which already outputs `required_fixes` and `next_route`
- **affected document**: `pge-rebuild-plan.md`
- **affected Critical Gate**: Gate 3, Gate 4
- **required fix**: Consider making Phase 1 and Phase 2 independent. Multi-round routing can work with narrative evaluator feedback. Evaluator hardening can proceed in parallel. This unblocks the highest-value capability sooner.

### P1-4: No runtime artifact for contract negotiation design

- **issue**: `pge-contract-negotiation-design.md` defines a complete multi-round negotiation protocol (§5 state machine, §5.2 convergence parameters, §5.4 termination conditions, §6 lock conditions, §7 hard gate) but does not specify which existing runtime files need to change or what new files are needed. The "需要的 artifact" section is missing. The design references `ORCHESTRATION.md`, `handoffs/preflight.md`, `runtime/artifacts-and-state.md`, and `contracts/evaluation-contract.md` as needing updates, but these are scattered across the document without a consolidated change list.
- **evidence**: `pge-contract-negotiation-design.md` has no "需要的 artifact" or "实施路径" section comparable to `pge-evaluator-threshold-design.md` §10
- **affected document**: `pge-contract-negotiation-design.md`
- **affected Critical Gate**: Gate 2 (Preflight multi-turn negotiation)
- **required fix**: Add an implementation section listing: (1) which existing files change, (2) what sections are added/modified, (3) what new files are created, (4) phased implementation order.

### P1-5: Context budget mechanism assumes unavailable API

- **issue**: `pge-multiround-runtime-design.md` §9.2 defines context budget levels (NORMAL 0-40%, WARNING 40-60%, CRITICAL 60%+) and states "main 在每次 phase 转换时检查 context budget". PGE is a prompt-driven harness with no runtime code. Claude Code does not expose a context usage percentage API to the agent. The design does not explain how `main` (which is Claude Code interpreting SKILL.md) would obtain the current context usage percentage.
- **evidence**: `pge-multiround-runtime-design.md` §9.2 "Context budget 分级" — no mechanism specified for obtaining context usage
- **affected document**: `pge-multiround-runtime-design.md`
- **affected Critical Gate**: Gate 5 (Runtime long-running execution)
- **required fix**: Either (a) specify a concrete mechanism for context budget detection (e.g., heuristic based on artifact count, token estimation from file sizes, or Claude Code's built-in compaction signals), or (b) mark this as a design aspiration that requires Claude Code platform support, and define a fallback (e.g., fixed round limits as proxy for context budget).

### P1-6: `pge-rebuild-plan.md` uses shortened contract paths throughout

- **issue**: Multiple sections reference `contracts/evaluation-contract.md`, `contracts/routing-contract.md`, etc. without the `skills/pge-execute/` prefix. The repo's `README.md` explicitly states "Top-level `contracts/` has been removed so runtime authority is not ambiguous." The actual paths are `skills/pge-execute/contracts/*.md`. While intent is inferrable, a rebuild plan should use exact paths to avoid ambiguity during implementation.
- **evidence**: `pge-rebuild-plan.md` §3 Gate 4: "在 `contracts/evaluation-contract.md` 中增加评分维度定义" vs actual path `skills/pge-execute/contracts/evaluation-contract.md`
- **affected document**: `pge-rebuild-plan.md`
- **affected Critical Gate**: All gates
- **required fix**: Use full paths (`skills/pge-execute/contracts/...`) in all artifact references. A global find-replace is sufficient.

### P1-7: Evaluator anti-slop rule "任一 slop_flag 触发时 verdict 不可为 PASS" is overly rigid

- **issue**: `pge-evaluator-threshold-design.md` §9.2 Mechanism 5 defines 4 slop patterns and states "任一 slop_flag 触发时，verdict 不可为 PASS". The `issue_minimization` flag triggers when "evidence 中识别了问题但 verdict 为 PASS". This is a legitimate evaluation pattern — an evaluator may identify minor issues that don't affect acceptance criteria and still issue PASS. The rule as written would force RETRY for any PASS verdict that acknowledges any issue, which contradicts the evaluation contract's "choose the narrowest verdict" principle.
- **evidence**: `pge-evaluator-threshold-design.md` §9.2 Mechanism 5 vs `evaluation-contract.md` "choose the narrowest verdict that explains the failure correctly"
- **affected document**: `pge-evaluator-threshold-design.md`
- **affected Critical Gate**: Gate 4
- **required fix**: Refine `issue_minimization` to trigger only when identified issues are severity >= major but verdict is still PASS. Minor acknowledged issues with PASS should not trigger the flag.

### P1-8: No acceptance test for the design documents themselves

- **issue**: `pge-rebuild-plan.md` §7 defines acceptance criteria for each implementation phase, but these criteria require running actual proving runs (e.g., "执行一次 proving run，Evaluator 产出包含维度评分和置信度的 verdict"). There is no intermediate acceptance check that validates the design documents are internally consistent and complete *before* implementation begins. Given that Round 1-2 review already found P0 issues (naming inconsistency, schema conflicts), the design docs need their own acceptance gate.
- **evidence**: `pge-rebuild-plan.md` §7 — all acceptance criteria are runtime-based, none are document-level
- **affected document**: `pge-rebuild-plan.md`
- **affected Critical Gate**: All gates
- **required fix**: Add a "Phase 0: Design alignment" acceptance check: (1) all artifact paths in design docs match repo reality, (2) runtime-state schema is unified across all design docs, (3) state names are consistent, (4) no self-contradictions between design docs.

## P2 Improvements

### P2-1: `pge-reference-learning-notes.md` "学到哪个模块" tables use shortened paths

- **issue**: Multiple target module paths use `contracts/evaluation-contract.md` instead of `skills/pge-execute/contracts/evaluation-contract.md`. Same class of issue as P1-6.
- **suggestion**: Use full paths for consistency.

### P2-2: Checkpoint JSON schemas are verbose and may exceed practical limits

- **issue**: `pge-multiround-runtime-design.md` §7.2 and §7.3 define checkpoint schemas with nested objects (`state_snapshot`, `artifact_refs`, `carry_forward`, `precise_position`, `team_state`, `decisions_made`). For a prompt-driven harness where Claude Code writes JSON by interpreting markdown instructions, complex nested schemas increase the chance of malformed output. Simpler flat schemas would be more reliable.
- **suggestion**: Consider flattening checkpoint schemas or defining a minimal checkpoint (just `run_id`, `state`, `active_phase`, `artifact_refs`) with optional extended fields.

### P2-3: `pge-evaluator-threshold-design.md` fixture W4 has inconsistent blocking flag

- **issue**: Fixture W4 "Self-Assessment as Evidence" has `expected_blocking_flags: [BF_NO_EVIDENCE]` and `expected_verdict: RETRY`. But §4.2 states `BF_NO_EVIDENCE` triggers `verdict = RETRY`. The fixture's `expected_scores` show `DA: 3-4` (deliverable exists and is real). The blocking flag name `BF_NO_EVIDENCE` is misleading — the fixture has evidence, it's just all self-reported. A more accurate flag would be `BF_NO_INDEPENDENT_EVIDENCE`.
- **suggestion**: Rename `BF_NO_EVIDENCE` to `BF_NO_INDEPENDENT_EVIDENCE` or split into `BF_NO_EVIDENCE` (zero evidence) and `BF_SELF_ONLY_EVIDENCE` (only E_SELF/E_NARR).

### P2-4: `pge-multiround-runtime-design.md` §9.4 scope control is aspirational

- **issue**: "Sprint goal 必须从 upstream plan 派生" and "如果 Planner 认为 upstream plan 需要修改，必须 ESCALATE" are behavioral instructions for an LLM agent. There is no structural mechanism to enforce this — it relies entirely on the Planner agent following instructions. This is the same class of problem as the current evaluator weakness (agent behavior depends on prompt compliance).
- **suggestion**: Acknowledge this as a prompt-compliance dependency. Consider adding a structural check: `main` verifies that the sprint goal text appears as a substring or semantic match in the upstream plan before proceeding.

### P2-5: No versioning strategy for design documents

- **issue**: All design documents are version 0.1.0 or "Draft". When implementation begins and documents are updated, there is no defined versioning or change tracking strategy. Design decisions may be silently revised without audit trail.
- **suggestion**: Define a simple versioning rule: bump minor version on substantive changes, maintain a changelog section at the bottom of each design doc.

### P2-6: `pge-rebuild-plan.md` non-goals may be too restrictive

- **issue**: N2 states "不新增 agent — 保持 Planner/Generator/Evaluator 三个稳定角色，不膨胀为 4+ agent". The contract negotiation design effectively requires the Evaluator to operate in two distinct modes: preflight review (contract quality) and final evaluation (deliverable quality). These are different evaluation contexts with different criteria. Forcing both into one agent role may lead to prompt bloat in `pge-evaluator.md`.
- **suggestion**: Monitor evaluator prompt size. If it exceeds instruction budget limits (~150-200 instructions per the best-practice notes), consider whether preflight review should be a separate evaluator mode or a lightweight sub-role.

### P2-7: Recovery design assumes team can be rebuilt from artifacts alone

- **issue**: `pge-multiround-runtime-design.md` §7.6 states "不依赖旧 team 的 chat history" and "通过 artifact 文件传递所有必要上下文". This is architecturally sound but untested. The mandatory read list (§10.4) for a generator resume includes state, progress, planner_artifact, preflight_artifact — potentially 4+ large markdown files. Whether a fresh agent can reconstruct sufficient context from these files alone (without the conversational context of why certain decisions were made) is an empirical question.
- **suggestion**: Add a proving run specifically designed to test recovery: run to generator phase, kill the team, rebuild, and verify the new generator produces equivalent output. This should be an explicit acceptance test for Phase 5.

---

# Missing Acceptance Checks

1. **Design document internal consistency**: No check that all design docs use the same state names, artifact paths, and runtime-state fields.

2. **Schema unification gate**: No check that `pge-multiround-runtime-design.md` and `pge-contract-negotiation-design.md` runtime-state extensions are compatible before implementation begins.

3. **Sprint justification gate**: No explicit acceptance check that the sprint layer adds value beyond what a flat "Planner re-plan" boundary provides. The sprint concept is introduced but never tested against the simpler alternative.

4. **Evaluator output format migration**: No intermediate acceptance check for evaluator output format between current (5 sections) and target (full verdict bundle). Phase 1 acceptance criteria (§7) jump straight to "Evaluator 产出包含维度评分和置信度的 verdict" without defining what the transitional format looks like.

5. **Context budget detection feasibility**: No acceptance check that `main` can actually detect context budget levels in the Claude Code runtime environment.

6. **Cross-document path consistency**: No automated check (e.g., extension to `bin/pge-validate-contracts.sh`) that design document artifact path references match actual repo paths.

7. **Recovery round-trip test**: No acceptance check that a team rebuilt from artifacts alone can continue execution equivalently to the original team.

---

# Questions / Assumptions

1. **Is the sprint layer load-bearing?** The multiround design introduces sprint as a structural layer between run and round. But the only behavioral difference between "sprint boundary" and "Planner re-plan within the same run" appears to be the sprint_checkpoint and carry_forward mechanism. Could these be attached to a "re-plan round" without introducing a new hierarchical layer? The sprint layer adds complexity (sprint_id, sprint_sequence, sprint_status, sprint_goal, max_sprints, sprint_checkpoint) — is this complexity justified by a concrete capability that a flat model cannot provide?

2. **What is the instruction budget for the evaluator?** The evaluator threshold design adds ~15 new behavioral rules (6 scoring dimensions, 7 blocking flags, 4 anti-slop patterns, evidence sufficiency rules, independent verification requirements). Combined with the existing evaluator instructions, this may exceed the ~150-200 instruction limit noted in the best-practice research. Has anyone estimated the total instruction count for the post-redesign evaluator prompt?

3. **How does `max_negotiation_rounds: 3` interact with `max_rounds_per_sprint: 3`?** The contract negotiation design allows up to 3 negotiation rounds (each with up to 2 preflight attempts) before implementation even starts. The multiround design allows up to 3 rounds per sprint. In the worst case, a single sprint could consume 3 negotiation rounds + 3 implementation rounds = 6 total cycles. Is this the intended behavior? What is the total token budget for a worst-case sprint?

4. **Who owns the unified runtime-state schema?** Currently `runtime-state-contract.md` is the normative superset, `artifacts-and-state.md` is the executable subset, and two design documents propose independent extensions. After implementation, which file is the single source of truth for the runtime-state schema?

5. **Is `pge-rebuild-plan.md` §1 "Confirmed" table accurate?** The table claims "历史运行产物 | 3 个完整 run" but the actual artifacts use different naming and are missing 5 of 9 required artifacts per run. Should this be downgraded to "3 partial runs using pre-ORCHESTRATION format"?

6. **What happens when the evaluator's weighted score is exactly 3.5?** The threshold design says `weighted_score ≥ 3.5 → PASS` and `weighted_score < 3.5 → RETRY`. The boundary is clear, but the 1-5 integer scoring with 6 dimensions and specific weights means certain score combinations land exactly on 3.5 (e.g., all dimensions = 3 gives weighted_score = 3.0; DA=4,ES=4,CC=3,SD=3,VI=3,CP=3 gives 3.5). The "exactly 3.5" case should be explicitly documented as PASS to avoid ambiguity.
