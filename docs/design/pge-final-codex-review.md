# PGE Final Codex Review (Round 5)

> Reviewer: Independent external reviewer (Codex-style final review)
> Date: 2026-04-29
> Scope: All 5 design docs (post-Round 4 revision) + repo contracts + prior review records
> Perspective: Final quality gate — verify P0 fixes, check for regression, assess executability

---

## P0 修复验证

| Original P0 | Fixed? | Evidence | Remaining concern |
|-------------|--------|----------|-------------------|
| Sprint/slice 术语统一 (Codex P0-1) | PARTIAL | `pge-multiround-runtime-design.md` §1 添加了术语说明，结构字段（`slice_id`, `max_slices`, `slice_checkpoint`）全部使用 slice。`pge-reference-learning-notes.md` §1 扩展了 slice 与 sprint 的区别说明。 | **10 处残留 "Sprint" 引用**在 `pge-multiround-runtime-design.md` 的散文段落中未被替换：§7.3 continue-here 模板 "Sprint 1, Round 1"（line 555）、§7.4 "Sprint 间 handoff"（line 601）、§9.2 "Sprint N 结束"（line 753）、§9.4 "Sprint goal 必须从 upstream plan 派生"（lines 812, 815）、"Sprint 间的 goal 递进"（line 818）、§9.6 "Sprint 生命周期"（line 842）、"Sprint Start"（line 845）、"Sprint Complete"（line 860）、"Sprint Failed"（line 867）。这些是 Round 4 全局重命名遗漏。 |
| Artifact 命名一致 (R1 P0-1 / Codex P0-2) | YES | `pge-rebuild-plan.md` §1 Confirmed 表已修改为"3 个早期 run（使用 pre-ORCHESTRATION 命名约定：`-planner-output.md` 等，每个 run 4 个文件，不是当前 ORCHESTRATION.md 定义的完整 9-artifact 格式）"。准确反映了实际状态。 | 无 |
| Runtime-state schema 统一 (Codex P0-3) | YES | `pge-multiround-runtime-design.md` §2.1 的统一 schema 包含 contract-negotiation 的 6 个字段（`negotiation_round`, `max_negotiation_rounds`, `total_preflight_cycles`, `max_total_preflight_cycles`, `contract_locked`, `contract_locked_at_preflight`）。`pge-contract-negotiation-design.md` §10.3 标注 canonical schema 在 multiround design 中。 | 无 |
| 状态名统一 (Codex P0-4) | YES | 所有设计文档统一使用 `planning_round`。`pge-multiround-runtime-design.md` §8.1 添加了状态名对齐说明，§8.2 状态转换表全部使用 `planning_round`。`pge-contract-negotiation-design.md` §10.4 添加了对齐说明。明确标注 `ORCHESTRATION.md` 仍使用 `planning`，实施时需更新。 | 无（ORCHESTRATION.md 的更新属于实施范围，不是设计文档问题） |

---

## 修订引入的新问题

### N1 (P1-new): Sprint→Slice 重命名不完整

`pge-multiround-runtime-design.md` 中有 10 处散文段落仍使用 "Sprint" 而非 "Slice"：

- §7.3 line 555: `- Sprint 1, Round 1` → 应为 `Slice 1, Round 1`
- §7.4 line 601: `**Sprint 间 handoff**` → 应为 `**Slice 间 handoff**`
- §9.2 line 753: `Sprint N 结束` → 应为 `Slice N 结束`
- §9.4 lines 812, 815: `Sprint goal 必须从 upstream plan 派生` → 应为 `Slice goal`
- §9.4 line 818: `Sprint 间的 goal 递进` → 应为 `Slice 间的 goal 递进`
- §9.6 line 842: `### 9.6 Sprint 生命周期` → 应为 `### 9.6 Slice 生命周期`
- §9.6 lines 845, 860, 867: `Sprint Start/Complete/Failed` → 应为 `Slice Start/Complete/Failed`

同时，`pge-reference-learning-notes.md` §1 line 14 仍有一处 "sprint 失败" 引用（在描述 Anthropic 的 hard threshold 时），这处是合理的——它描述的是 Anthropic 的原始设计，不是 PGE 的术语。

`pge-rebuild-plan.md` §3 Gate 2/3/4 的"参考标准"段落中有 3 处 "sprint" 引用（lines 83, 100, 120），这些也是合理的——它们描述的是 Anthropic 的参考标准，不是 PGE 的术语。

**影响**: 中等。结构字段和定义已正确使用 slice，但散文段落的不一致可能在实施时造成混淆。

**修复**: 对 `pge-multiround-runtime-design.md` 执行 Sprint→Slice 替换，仅限上述 10 处散文段落。保留描述 Anthropic 原始设计的 sprint 引用。

### N2 (P2-new): `pge-rebuild-plan.md` §3 Gate 2 "参考标准"中 "sprint contract" 术语

`pge-rebuild-plan.md` line 83 描述 Gate 2 参考标准时使用 "sprint contract"。虽然这是描述 Anthropic 的原始设计，但在 PGE 已统一使用 slice 的上下文中，建议加括号标注 "(Anthropic 原始术语)" 以避免混淆。

**影响**: 低。

---

## 跨文档一致性检查

### 术语一致性: CONDITIONAL PASS

- **slice/sprint**: 结构字段和定义全部使用 slice。散文段落有 10 处残留 Sprint（见 N1）。
- **planning_round**: 所有设计文档统一使用 `planning_round`。明确标注 `ORCHESTRATION.md` 实施时需更新。PASS。
- **artifact 路径前缀**: `pge-rebuild-plan.md` 全局替换完成，所有路径使用 `skills/pge-execute/` 前缀。PASS。
- **verdict 枚举**: 所有文档统一使用 PASS/RETRY/BLOCK/ESCALATE。PASS。
- **route 枚举**: 所有文档统一使用 continue/converged/retry/return_to_planner。PASS。
- **max_preflight_attempts**: `pge-multiround-runtime-design.md` §2.1 和 `pge-contract-negotiation-design.md` §5.2 保持当前值 2，`pge-rebuild-plan.md` Phase 3 规划提升到 3。这是有意的设计（当前值 vs 目标值），不是不一致。PASS。

### Schema 一致性: PASS

- **runtime-state schema**: `pge-multiround-runtime-design.md` §2.1 是 canonical schema，包含 contract-negotiation 的 6 个字段。`pge-contract-negotiation-design.md` §10.3 正确引用 canonical schema。
- **verdict bundle schema**: `pge-evaluator-threshold-design.md` §6.1 定义完整 schema，§10.1 明确标注为"重大重构"并提供过渡策略。
- **evidence schema**: `pge-multiround-runtime-design.md` §4 和 `pge-evaluator-threshold-design.md` §5 的 evidence 分类互补（前者定义 Generator 产出格式，后者定义 Evaluator 评估标准）。无冲突。
- **route 参数结构**: `pge-multiround-runtime-design.md` §6.3 定义 route 参数，与 `routing-contract.md` 的 verdict→route 映射兼容。

### 流程一致性: PASS

- **Phase 依赖链**: `pge-rebuild-plan.md` Phase 2 已改为"无硬依赖"，Phase 1 和 Phase 2 可并行推进。与 `pge-rebuild-review-report.md` 的建议一致。
- **Negotiation 流程**: `pge-contract-negotiation-design.md` §5 状态机与 `pge-multiround-runtime-design.md` §8 状态机兼容。negotiation 是 round 内的 preflight 子流程，不与 round/slice 层次冲突。
- **Evaluator 过渡策略**: `pge-evaluator-threshold-design.md` §10.2 定义了 3 阶段实施（评分框架→证据结构化→校准与防御），§10.1 定义了 Phase 1 中间输出格式。与 `pge-rebuild-plan.md` Phase 1 验收标准对齐。
- **Checkpoint/Resume**: `pge-multiround-runtime-design.md` §7 的 checkpoint 机制与 §10 的 resume 流程形成完整闭环。resume 入口（§10.1）、恢复流程（§10.2）、恢复点判定（§10.3）、mandatory read list（§10.4）、不变量（§10.5）覆盖完整。

---

## Critical Gates 覆盖度

| Gate | 覆盖度 | 缺口（如有） |
|------|--------|-------------|
| Gate 1: Planner raw-prompt ownership | 充分 | `pge-rebuild-plan.md` §3 Gate 1 + Phase 4 定义了 intake negotiation 协议。`pge-contract-negotiation-design.md` §2 定义了 Planner 从 raw intent 到 proposal 的 5 步流程。歧义度阈值的具体判断标准留待实施时定义（合理——这需要实际运行数据校准）。 |
| Gate 2: Preflight multi-turn negotiation | 充分 | `pge-contract-negotiation-design.md` 提供了完整的多轮 negotiation 设计（§5 状态机、§5.2 收敛参数、§5.4 终止条件、§6 lock 条件、§7 hard gate）。`pge-rebuild-plan.md` Phase 3 定义了 structured feedback 和收敛检测。§12 实施路径已补充。 |
| Gate 3: Generator slice/feature granularity | 充分 | `pge-multiround-runtime-design.md` 提供了完整的 run/slice/round 三层设计（§1 层次、§8 状态机、§6 route 结构、§7 checkpoint）。`pge-rebuild-plan.md` Phase 2 定义了 retry/continue/return_to_planner 三条路由的实现。slice 术语已与 `runtime-state-contract.md` 的 `active_slice_ref` 对齐。 |
| Gate 4: Evaluator hard-threshold grading | 充分（最完整） | `pge-evaluator-threshold-design.md` 提供了 6 维度评分（§3）、硬阈值规则（§2.3）、7 blocking flags（§4）、6 weak deliverable fixtures（§8）、6 防退化机制（§9）、verdict bundle schema（§6）。过渡策略（§10）已从"扩展"修正为"重大重构"并定义了中间输出格式。 |
| Gate 5: Runtime long-running execution and recovery | 充分 | `pge-multiround-runtime-design.md` §7 checkpoint/handoff/resume + §9 多 slice 稳定执行 + §10 从文件恢复上下文。Context budget 机制已标注需要平台支持，提供了 3 种启发式替代方案（§9.2 实现约束说明）。 |

---

## 可执行性评估

- 是否足以指导代码改造: **YES (with minor cleanup)**
- 缺少什么才能开始实施:
  1. 修复 N1（Sprint→Slice 散文段落残留）— 10 分钟的文本替换
  2. `pge-rebuild-review-report.md` 中列出的 5 个未解决问题仍然有效，但都属于实施阶段的问题，不阻塞设计完成

每个 Phase 的实施入口清晰：
- Phase 1: 从 `pge-evaluator-threshold-design.md` §10.2 Phase 1 开始，更新 `agents/pge-evaluator.md` + `evaluation-contract.md`
- Phase 2: 从 `pge-multiround-runtime-design.md` §6 route 结构开始，更新 `routing-contract.md` + `ORCHESTRATION.md`
- Phase 3: 从 `pge-contract-negotiation-design.md` §4 structured feedback 开始，更新 `handoffs/preflight.md`
- Phase 4: 从 `pge-rebuild-plan.md` §3 Gate 1 开始，更新 `agents/pge-planner.md` + `entry-contract.md`
- Phase 5: 从 `pge-multiround-runtime-design.md` §7 checkpoint 开始，更新 `ORCHESTRATION.md` + `persistent-runner.md`

---

## New Findings

### P0

无新 P0。所有原始 P0 已修复或实质性修复。

### P1

**P1-1 (N1)**: Sprint→Slice 重命名不完整。`pge-multiround-runtime-design.md` 中 10 处散文段落仍使用 "Sprint"。详见上文 N1。

### P2

**P2-1 (N2)**: `pge-rebuild-plan.md` §3 Gate 2 参考标准中 "sprint contract" 建议加标注。详见上文 N2。

**P2-2**: `pge-multiround-runtime-design.md` §9.6 标题为 "Sprint 生命周期" 但内容使用 slice 字段名（`slice_checkpoint`, `slice_complete`）。标题与内容不一致。属于 N1 的一部分。

**P2-3**: `pge-evaluator-threshold-design.md` §6.2 Markdown 输出格式示例中 weighted score 3.60 ≥ 3.50 标注为 PASS，这与 §2.3 的规则 `weighted_score ≥ 3.5 → PASS` 一致。但 Codex Round 3 提出的 "exactly 3.5" 边界问题（Q6）未在文档中显式标注。建议在 §2.3 中添加一句 "weighted_score = 3.5 时判定为 PASS（≥ 包含等于）"。

---

## Overall Verdict

**CONDITIONAL PASS**

条件：
1. 修复 `pge-multiround-runtime-design.md` 中 10 处 Sprint→Slice 散文段落残留（P1-1/N1）

建议：
1. 上述修复是纯文本替换，不涉及设计变更，可在 5-10 分钟内完成
2. 修复后，5 份设计文档的内部一致性、跨文档一致性、与 repo 实际状态的对齐均达到可实施标准
3. 建议按 `pge-rebuild-review-report.md` 的推荐顺序开始实施：Phase 1 + Phase 2 并行 → Phase 3 → Phase 4 → Phase 5
4. 实施时注意 `pge-rebuild-review-report.md` 中 5 个未解决问题（ORCHESTRATION.md 状态名更新、context budget 精确检测、recovery round-trip 测试、evaluator instruction budget、max_negotiation_rounds 经验依据）
