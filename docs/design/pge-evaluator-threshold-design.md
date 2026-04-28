# PGE Evaluator Threshold Design

> 版本: 0.1.0
> 日期: 2026-04-29
> 状态: 设计草案
> 依赖: agents/pge-evaluator.md, skills/pge-execute/contracts/evaluation-contract.md

---

## 1. Evaluator 当前问题

基于 repo 分析 (`docs/design/research/repo-analysis.md`) 和历史证明运行记录，当前 Evaluator 存在以下具体薄弱点：

### 1.1 无量化评分机制

当前 Evaluator 只产出叙述性判断（verdict + evidence + violated_invariants_or_risks + required_fixes + next_route）。没有数字化的评分维度。这导致：

- **判断漂移**：同一质量水平的交付物在不同运行中可能获得不同 verdict
- **无法校准**：没有基准分数，无法检测 Evaluator 是否过严或过松
- **无部分学分**：只有 PASS/RETRY/BLOCK/ESCALATE 四档，无法区分"差一点就 PASS"和"完全不合格"

### 1.2 Gate 只做结构检查

`bin/pge-validate-contracts.sh` 和 orchestration gate 只检查 artifact section 是否存在，不检查内容质量。这意味着：

- Generator 可以写出包含所有必需 section 但内容为空洞叙述的 artifact，仍然通过 gate
- "artifact exists" ≠ "deliverable is real"（evaluator agent 定义中已声明此原则，但缺乏量化执行机制）

### 1.3 无 Evaluator 校准 Fixtures

`SKILL.md` 明确列出 "evaluator calibration fixtures" 为未实现功能。没有：

- 已知弱交付物的标准样例
- 已知强交付物的标准样例
- Evaluator 应该对这些样例给出什么 verdict 的预期

### 1.4 证据要求模糊

当前 `required_evidence` 字段由 Planner 定义，但没有结构化的证据分类。Evaluator 必须自行判断什么算"充分"证据，判断标准不透明。

### 1.5 无 AI Slop 防御

Anthropic 调研明确指出：开箱即用的 Claude 是糟糕的 QA agent，会识别问题然后说服自己"不是大问题"。当前 Evaluator prompt 虽然有 "forbidden behavior" 列表，但缺乏结构化的 slop 检测机制。

---

## 2. Hard-Threshold Grading 模型

### 2.1 设计原则

借鉴 Anthropic 的 hard-threshold 机制：**任一维度低于阈值则整体不 PASS**，无论其他维度多高。

```
总体 verdict = f(各维度分数, 各维度阈值)

规则:
- 任一维度 < 该维度硬阈值 → 不可 PASS
- 所有维度 ≥ 硬阈值 且 加权总分 ≥ 总分阈值 → PASS
- 否则 → RETRY / BLOCK（取决于差距性质）
```

### 2.2 评分尺度

每个维度使用 1-5 分制：

| 分数 | 含义 | 对应质量 |
|------|------|----------|
| 1 | 缺失或占位符 | 交付物不存在、空白、或纯 TODO/placeholder |
| 2 | 存在但不可接受 | 有内容但不满足合约要求，或纯叙述无实质 |
| 3 | 最低可接受 | 满足合约字面要求，但质量勉强、证据薄弱 |
| 4 | 良好 | 满足合约要求，证据充分，无明显缺陷 |
| 5 | 优秀 | 超出合约要求，证据完整且独立可验证 |

### 2.3 硬阈值规则

```
PASS 必要条件:
  - 所有维度 ≥ 3（最低可接受）
  - 加权总分 ≥ 3.5
  - 无任何 blocking_flag 为 true

RETRY 条件:
  - 至少一个维度 < 3，但所有维度 ≥ 2
  - 且方向正确（deliverable_alignment ≥ 3）

BLOCK 条件:
  - 任一维度 = 1
  - 或 deliverable_alignment < 2
  - 或存在 blocking_flag

ESCALATE 条件:
  - contract_coherence < 2
  - 或评分过程中发现合约本身有歧义/冲突
```

---

## 3. Score Dimensions（评分维度）

### 3.1 维度定义

六个评分维度，分为两类：

**核心维度（高权重，硬阈值 = 3）：**

| 维度 | 代号 | 权重 | 评估对象 | 硬阈值 |
|------|------|------|----------|--------|
| Deliverable Alignment | `DA` | 0.25 | 实际交付物是否匹配合约批准的 `actual_deliverable` | 3 |
| Evidence Sufficiency | `ES` | 0.25 | 证据是否充分、独立、可验证 | 3 |
| Contract Compliance | `CC` | 0.20 | 是否满足所有 `acceptance_criteria` 和 `design_constraints` | 3 |

**支撑维度（低权重，硬阈值 = 2）：**

| 维度 | 代号 | 权重 | 评估对象 | 硬阈值 |
|------|------|------|----------|--------|
| Scope Discipline | `SD` | 0.10 | `in_scope`/`out_of_scope` 边界是否被尊重 | 2 |
| Verification Integrity | `VI` | 0.10 | `verification_path` 是否被执行且结果可信 | 2 |
| Completeness | `CP` | 0.10 | `stop_condition` 是否满足，`non_done_items` 是否可接受 | 2 |

### 3.2 各维度评分标准

#### Deliverable Alignment (DA) — 交付物对齐度

| 分数 | 判定标准 |
|------|----------|
| 1 | `deliverable_path` 不存在，或指向空文件/纯占位符 |
| 2 | 文件存在但内容与合约 `actual_deliverable` 不匹配（如：合约要求代码实现，交付的是设计文档） |
| 3 | 内容匹配合约要求的交付物类型，但覆盖不完整或有明显遗漏 |
| 4 | 内容完整匹配合约要求，`changed_files` 反映真实工作 |
| 5 | 完整匹配且超出预期，交付物质量明显高于合约最低要求 |

#### Evidence Sufficiency (ES) — 证据充分性

| 分数 | 判定标准 |
|------|----------|
| 1 | 无证据，或证据仅为 Generator 自述（"我检查了，没问题"） |
| 2 | 有证据但不独立（仅 `local_verification` 或 `self_review`，无工具输出） |
| 3 | 有独立证据（工具输出、文件内容检查），但未覆盖所有 `acceptance_criteria` |
| 4 | 每个 `acceptance_criteria` 都有对应的独立证据项 |
| 5 | 证据完整且包含反面验证（验证了不应该发生的事情确实没发生） |

#### Contract Compliance (CC) — 合约合规性

| 分数 | 判定标准 |
|------|----------|
| 1 | 多个 `acceptance_criteria` 未满足，或存在未声明的重大偏离 |
| 2 | 部分 `acceptance_criteria` 满足，但关键条款缺失 |
| 3 | 所有 `acceptance_criteria` 字面满足，`design_constraints` 被尊重 |
| 4 | 合约完全满足，偏离（如有）已声明且合理 |
| 5 | 合约完全满足，无偏离，且 `evidence_basis` 中的约束全部被验证 |

#### Scope Discipline (SD) — 范围纪律

| 分数 | 判定标准 |
|------|----------|
| 1 | `changed_files` 包含 `out_of_scope` 中明确禁止的文件 |
| 2 | 范围有轻微越界但未触及禁止区域 |
| 3 | `changed_files` 在 `in_scope` 范围内，`out_of_scope` 被尊重 |
| 4 | 范围严格受控，`handoff_seam` 完整保留 |
| 5 | 范围严格受控，且主动声明了边界附近的决策理由 |

#### Verification Integrity (VI) — 验证完整性

| 分数 | 判定标准 |
|------|----------|
| 1 | `verification_path` 未执行，无任何验证记录 |
| 2 | 执行了验证但不是合约指定的 `verification_path`，且未声明偏离 |
| 3 | 执行了合约指定的 `verification_path`，或声明了合理的替代验证 |
| 4 | 验证完整执行，结果可复现 |
| 5 | 验证完整执行，包含边界情况和失败路径验证 |

#### Completeness (CP) — 完整性

| 分数 | 判定标准 |
|------|----------|
| 1 | `stop_condition` 明显未满足，大量 `non_done_items` |
| 2 | `stop_condition` 部分满足，`non_done_items` 影响核心功能 |
| 3 | `stop_condition` 满足，`non_done_items` 不影响当前轮次验收 |
| 4 | `stop_condition` 满足，`non_done_items` 仅为后续轮次的延伸工作 |
| 5 | 完全满足，无 `non_done_items`，`handoff_seam` 清晰定义 |

### 3.3 加权总分计算

```
weighted_score = DA × 0.25 + ES × 0.25 + CC × 0.20 + SD × 0.10 + VI × 0.10 + CP × 0.10
```

---

## 4. Blocking Criteria（阻断条件）

### 4.1 Blocking Flags

除了维度分数外，以下条件为独立的 blocking flags。任一 flag 为 true 时，无论分数多高，verdict 不可为 PASS。

| Flag | 代号 | 触发条件 |
|------|------|----------|
| Missing Deliverable | `BF_MISSING` | `deliverable_path` 不存在或指向空文件 |
| Placeholder Only | `BF_PLACEHOLDER` | 交付物内容全部为 TODO/placeholder/stub |
| Narrative Only | `BF_NARRATIVE` | Generator 只提供叙述，无实际 repo 工作 |
| No Independent Evidence | `BF_NO_INDEPENDENT_EVIDENCE` | `evidence` 字段为空或仅含自述（E_SELF/E_NARR），无高独立性证据 |
| Scope Violation | `BF_SCOPE_VIOLATION` | `changed_files` 包含 `out_of_scope` 明确禁止的文件 |
| Undeclared Deviation | `BF_UNDECLARED_DEV` | 存在未在 `deviations_from_spec` 中声明的重大偏离 |
| Contract Rewrite | `BF_CONTRACT_REWRITE` | Generator 静默重新定义了 `acceptance_criteria` 或 `actual_deliverable` |

### 4.2 Blocking Flag 与 Verdict 的关系

```
if any BF_* is true:
  if BF_MISSING or BF_PLACEHOLDER or BF_NARRATIVE:
    verdict = BLOCK
    next_route = retry (if contract still valid) or return_to_planner
  if BF_CONTRACT_REWRITE:
    verdict = ESCALATE
    next_route = return_to_planner
  if BF_NO_INDEPENDENT_EVIDENCE:
    verdict = RETRY (evidence can be gathered without re-implementation)
  if BF_SCOPE_VIOLATION or BF_UNDECLARED_DEV:
    verdict = BLOCK
    next_route = retry
```

---

## 5. Evidence Requirements（证据要求）

### 5.1 证据分类

| 证据类型 | 代号 | 描述 | 独立性 |
|----------|------|------|--------|
| Tool Output | `E_TOOL` | Bash/Read/Grep 等工具的实际输出 | 高 — Evaluator 可独立复现 |
| File Content | `E_FILE` | `deliverable_path` 处文件的实际内容片段 | 高 — Evaluator 可直接 Read |
| Diff Evidence | `E_DIFF` | 变更前后的具体差异 | 高 — 可通过 git diff 验证 |
| Test Result | `E_TEST` | 测试运行的实际输出（pass/fail + 输出） | 高 — Evaluator 可重新运行 |
| Self Report | `E_SELF` | Generator 的自述或 `self_review` | 低 — 不可作为唯一证据 |
| Narrative | `E_NARR` | 无工具支撑的文字描述 | 无 — 不接受为证据 |

### 5.2 证据充分性规则

每个 `acceptance_criteria` 条目必须有至少一个高独立性证据（`E_TOOL` / `E_FILE` / `E_DIFF` / `E_TEST`）支撑。

```
for each criterion in acceptance_criteria:
  supporting_evidence = evidence items mapped to this criterion
  high_independence = [e for e in supporting_evidence if e.type in (E_TOOL, E_FILE, E_DIFF, E_TEST)]
  
  if len(high_independence) == 0:
    criterion_met = false  → ES 维度扣分
  if len(supporting_evidence) == 0:
    criterion_met = false  → BF_NO_INDEPENDENT_EVIDENCE if all criteria lack evidence
```

### 5.3 Evaluator 独立验证要求

Evaluator 不仅检查 Generator 提供的证据，还必须执行独立验证：

1. **文件存在性验证**：Read `deliverable_path`，确认文件存在且非空
2. **内容实质性验证**：检查交付物内容是否为真实工作（非占位符/非纯叙述）
3. **变更表面验证**：检查 `changed_files` 是否反映真实变更
4. **至少一项独立复现**：对至少一个 `acceptance_criteria`，Evaluator 用自己的工具独立验证（而非仅信任 Generator 的工具输出）

---

## 6. Verdict Schema（判定数据结构）

### 6.1 完整 Verdict Bundle Schema

```yaml
verdict_bundle:
  # 元数据
  run_id: string
  round_id: string
  evaluator_version: string          # evaluator prompt/schema 版本
  timestamp: string                  # ISO 8601
  
  # 维度评分
  scores:
    deliverable_alignment:
      score: integer                 # 1-5
      rationale: string              # 一句话判定理由
      evidence_refs: list[string]    # 支撑此评分的证据引用
    evidence_sufficiency:
      score: integer
      rationale: string
      evidence_refs: list[string]
    contract_compliance:
      score: integer
      rationale: string
      evidence_refs: list[string]
    scope_discipline:
      score: integer
      rationale: string
      evidence_refs: list[string]
    verification_integrity:
      score: integer
      rationale: string
      evidence_refs: list[string]
    completeness:
      score: integer
      rationale: string
      evidence_refs: list[string]
  
  # 加权总分
  weighted_score: float              # 1.0-5.0, 精确到小数点后两位
  
  # Blocking flags
  blocking_flags:
    BF_MISSING: boolean
    BF_PLACEHOLDER: boolean
    BF_NARRATIVE: boolean
    BF_NO_INDEPENDENT_EVIDENCE: boolean
    BF_SCOPE_VIOLATION: boolean
    BF_UNDECLARED_DEV: boolean
    BF_CONTRACT_REWRITE: boolean
  
  has_blocking_flag: boolean         # any(blocking_flags.values())
  
  # Verdict 判定
  verdict: enum[PASS, RETRY, BLOCK, ESCALATE]
  verdict_reason: string             # 一段话解释 verdict 选择理由
  
  # 证据记录
  evidence:
    - id: string                     # e.g. "ev-01"
      type: enum[E_TOOL, E_FILE, E_DIFF, E_TEST, E_SELF, E_NARR]
      source: string                 # 工具名或文件路径
      content_summary: string        # 证据内容摘要
      supports_criteria: list[string] # 支撑的 acceptance_criteria 条目
      independent: boolean           # Evaluator 是否独立验证了此证据
  
  # 问题记录
  violated_invariants_or_risks:
    - invariant: string              # 被违反的不变量或风险
      severity: enum[critical, major, minor]
      evidence_ref: string           # 支撑此判定的证据 id
  
  # 修复要求（仅 RETRY/BLOCK 时）
  required_fixes:
    - description: string            # 缺失/违反的具体条件
      contract_field: string         # 关联的合约字段
      required_evidence: string      # 需要什么证据才能解除此 fix
  
  # 路由
  next_route: enum[continue, converged, retry, return_to_planner]
  route_reason: string               # 路由选择理由
```

### 6.2 Verdict Bundle 的 Markdown 输出格式

Evaluator 实际产出仍为 markdown artifact（与当前 agent 定义兼容），但必须包含结构化评分 section：

```markdown
## verdict
PASS | RETRY | BLOCK | ESCALATE

## scores
| Dimension | Score | Hard Threshold | Status |
|-----------|-------|----------------|--------|
| Deliverable Alignment (DA) | 4 | 3 | PASS |
| Evidence Sufficiency (ES) | 3 | 3 | PASS |
| Contract Compliance (CC) | 4 | 3 | PASS |
| Scope Discipline (SD) | 4 | 2 | PASS |
| Verification Integrity (VI) | 3 | 2 | PASS |
| Completeness (CP) | 3 | 2 | PASS |
| **Weighted Score** | **3.60** | **3.50** | **PASS** |

## blocking_flags
- BF_MISSING: false
- BF_PLACEHOLDER: false
- BF_NARRATIVE: false
- BF_NO_INDEPENDENT_EVIDENCE: false
- BF_SCOPE_VIOLATION: false
- BF_UNDECLARED_DEV: false
- BF_CONTRACT_REWRITE: false

## evidence
[具体证据条目，每条包含 type/source/content_summary/supports_criteria]

## violated_invariants_or_risks
[具体违反项，每条包含 severity 和 evidence_ref]

## required_fixes
[仅 RETRY/BLOCK 时，具体修复要求]

## next_route
continue | converged | retry | return_to_planner

## route_reason
[路由选择理由]
```

---

## 7. RETRY / BLOCK / ESCALATE 判定边界

### 7.1 判定流程图

```
开始评估
  │
  ├─ 检查 Blocking Flags
  │   ├─ BF_CONTRACT_REWRITE = true → ESCALATE
  │   ├─ BF_MISSING / BF_PLACEHOLDER / BF_NARRATIVE = true → BLOCK
  │   ├─ BF_NO_INDEPENDENT_EVIDENCE = true → RETRY
  │   └─ BF_SCOPE_VIOLATION / BF_UNDECLARED_DEV = true → BLOCK
  │
  ├─ 计算维度分数
  │   ├─ 任一核心维度 (DA/ES/CC) = 1 → BLOCK
  │   ├─ 任一核心维度 (DA/ES/CC) = 2 → RETRY（如果方向正确）或 BLOCK
  │   ├─ 任一支撑维度 (SD/VI/CP) = 1 → BLOCK
  │   └─ 所有维度 ≥ 硬阈值 → 继续
  │
  ├─ 计算加权总分
  │   ├─ weighted_score < 3.0 → BLOCK
  │   ├─ weighted_score < 3.5 → RETRY
  │   └─ weighted_score ≥ 3.5 → PASS
  │
  └─ 检查合约一致性
      ├─ 合约本身有歧义/冲突 → ESCALATE
      └─ 合约清晰 → 维持上述 verdict
```

### 7.2 边界条件详解

#### PASS ↔ RETRY 边界（weighted_score 3.5 附近）

```
PASS 最低线:
  - 所有核心维度 ≥ 3
  - 所有支撑维度 ≥ 2
  - weighted_score ≥ 3.5
  - 无 blocking_flag

RETRY 最高线:
  - 所有维度 ≥ 2
  - DA ≥ 3（方向正确）
  - weighted_score ∈ [3.0, 3.5)
  - 或某个核心维度 = 2 但其余补偿
```

典型 RETRY 场景：
- DA=4, ES=2, CC=3, SD=3, VI=3, CP=3 → weighted=3.10 → RETRY（证据不足但交付物方向正确）
- DA=3, ES=3, CC=3, SD=3, VI=2, CP=2 → weighted=2.80 → RETRY（验证和完整性不足）

#### RETRY ↔ BLOCK 边界

```
BLOCK 触发:
  - 任一维度 = 1
  - 或 DA < 2（交付物根本不对）
  - 或 weighted_score < 3.0 且 DA < 3
  - 或任一 blocking_flag (BF_MISSING/BF_PLACEHOLDER/BF_NARRATIVE/BF_SCOPE_VIOLATION/BF_UNDECLARED_DEV)

RETRY 而非 BLOCK:
  - 所有维度 ≥ 2
  - DA ≥ 3（方向正确，只是不完整）
  - 问题可在当前轮次内修复
```

典型 BLOCK 场景：
- DA=1, 其余全 5 → BLOCK（交付物不存在，其他再好也没用）
- DA=3, ES=1, CC=3 → BLOCK（完全无证据）
- BF_SCOPE_VIOLATION=true → BLOCK（越界编辑）

#### BLOCK ↔ ESCALATE 边界

```
ESCALATE 触发:
  - BF_CONTRACT_REWRITE = true
  - 或合约本身有歧义/冲突导致无法公平评估
  - 或 Generator 的实现语义与合约语义根本性分歧
  - 或 retry 会重复同样的 mismatch

BLOCK 而非 ESCALATE:
  - 合约本身清晰
  - 问题是执行不足，不是合约不对
  - 修复后可在同一合约下重新评估
```

### 7.3 next_route 判定规则

| verdict | 条件 | next_route |
|---------|------|------------|
| PASS | `run_stop_condition` 满足 | `converged` |
| PASS | `run_stop_condition` 未满足 | `continue` |
| RETRY | — | `retry` |
| BLOCK | 合约仍是正确的修复框架 | `retry` |
| BLOCK | 缺失条件表明合约不再是正确框架 | `return_to_planner` |
| ESCALATE | — | `return_to_planner` |

---

## 8. Weak Deliverable Fixtures（弱交付物校准样例）

### 8.1 用途

这些 fixtures 用于校准 Evaluator 的判断一致性。每个 fixture 定义一个已知弱交付物和预期 verdict，用于：

- 检测 Evaluator 是否过松（应 BLOCK 但给了 PASS）
- 检测 Evaluator 是否过严（应 RETRY 但给了 BLOCK）
- 跨运行一致性验证

### 8.2 Fixture 定义

#### Fixture W1: Empty Deliverable

```yaml
fixture_id: W1
name: "Empty Deliverable"
description: "Generator 声称完成但 deliverable_path 指向空文件"
expected_verdict: BLOCK
expected_blocking_flags: [BF_MISSING]
expected_scores:
  DA: 1
  ES: 1-2
  CC: 1
  SD: 3-5
  VI: 1
  CP: 1

mock_generator_bundle:
  actual_deliverable: "实现 X 功能的代码"
  deliverable_path: "src/feature-x.ts"
  changed_files: ["src/feature-x.ts"]
  local_verification: "已通过本地测试"
  evidence:
    - "文件已创建"
  self_review: "实现完整，质量良好"

mock_deliverable_content: ""  # 空文件
```

#### Fixture W2: Narrative-Only Bundle

```yaml
fixture_id: W2
name: "Narrative-Only Bundle"
description: "Generator 提供详细叙述但无实际 repo 变更"
expected_verdict: BLOCK
expected_blocking_flags: [BF_NARRATIVE]
expected_scores:
  DA: 1
  ES: 1
  CC: 1-2
  SD: 3
  VI: 1
  CP: 1

mock_generator_bundle:
  actual_deliverable: "分析报告和实现方案"
  deliverable_path: "docs/analysis.md"
  changed_files: []  # 无文件变更
  local_verification: "已完成分析"
  evidence:
    - "经过深入分析，方案 A 是最优选择"
    - "考虑了 3 种替代方案"
  self_review: "分析全面，覆盖了所有关键维度"
```

#### Fixture W3: Placeholder Deliverable

```yaml
fixture_id: W3
name: "Placeholder Deliverable"
description: "交付物存在但全部为 TODO/placeholder"
expected_verdict: BLOCK
expected_blocking_flags: [BF_PLACEHOLDER]
expected_scores:
  DA: 1
  ES: 2
  CC: 1
  SD: 3
  VI: 2
  CP: 1

mock_generator_bundle:
  actual_deliverable: "API 端点实现"
  deliverable_path: "src/api/endpoint.ts"
  changed_files: ["src/api/endpoint.ts"]
  local_verification: "文件已创建，结构正确"
  evidence:
    - "文件包含正确的导出结构"

mock_deliverable_content: |
  // TODO: implement endpoint
  export function handler() {
    // TODO: add request parsing
    // TODO: add validation
    // TODO: add response
    throw new Error('Not implemented');
  }
```

#### Fixture W4: Self-Assessment as Evidence

```yaml
fixture_id: W4
name: "Self-Assessment as Evidence"
description: "交付物存在且有内容，但证据全部为 Generator 自述"
expected_verdict: RETRY
expected_blocking_flags: [BF_NO_INDEPENDENT_EVIDENCE]
expected_scores:
  DA: 3-4
  ES: 1
  CC: 3
  SD: 3
  VI: 2
  CP: 3

mock_generator_bundle:
  actual_deliverable: "配置文件重构"
  deliverable_path: "config/settings.yaml"
  changed_files: ["config/settings.yaml", "config/defaults.yaml"]
  local_verification: "我检查了配置格式，看起来正确"
  evidence:
    - "配置结构合理"
    - "默认值设置正确"
    - "与现有系统兼容"
  self_review: "重构完成，质量良好，无遗留问题"
```

#### Fixture W5: Scope Violation

```yaml
fixture_id: W5
name: "Scope Violation"
description: "交付物质量良好但越界修改了 out_of_scope 文件"
expected_verdict: BLOCK
expected_blocking_flags: [BF_SCOPE_VIOLATION]
expected_scores:
  DA: 4
  ES: 4
  CC: 3
  SD: 1
  VI: 3
  CP: 4

mock_round_contract:
  in_scope: ["src/feature/"]
  out_of_scope: ["src/core/", "config/"]

mock_generator_bundle:
  changed_files: ["src/feature/handler.ts", "src/core/utils.ts", "config/routes.yaml"]
```

#### Fixture W6: Contract Rewrite

```yaml
fixture_id: W6
name: "Silent Contract Rewrite"
description: "Generator 静默重新定义了 acceptance_criteria"
expected_verdict: ESCALATE
expected_blocking_flags: [BF_CONTRACT_REWRITE]

mock_round_contract:
  acceptance_criteria:
    - "API 端点返回正确的 JSON 响应"
    - "错误情况返回适当的 HTTP 状态码"
    - "请求验证覆盖所有必需字段"

mock_generator_bundle:
  actual_deliverable: "API 端点实现（简化版）"
  deviations_from_spec: []  # 未声明偏离
  evidence:
    - "端点可以接收请求"  # 重新定义了"正确响应"的含义
  self_review: "核心功能已实现，验证部分将在后续迭代中完成"
  # 实际上跳过了 acceptance_criteria 2 和 3，但未声明
```

---

## 9. 防止 Evaluator 退化为文件存在性检查

### 9.1 问题描述

Anthropic 调研明确指出：Agent 评估自己的工作时倾向于自信地赞美。即使是独立的 Evaluator，也可能退化为：

- 检查文件是否存在 → PASS
- 检查 section 是否存在 → PASS
- 读到 Generator 的自述"质量良好" → PASS

### 9.2 防御机制

#### 机制 1: 强制独立验证步骤

Evaluator 必须在 verdict bundle 中包含 `independent_verification` section，记录至少一项 Evaluator 自己执行的验证（不是引用 Generator 的验证结果）。

```
规则: 如果 verdict_bundle 中没有 independent_verification section，
      或该 section 为空，verdict 自动降级为 RETRY。
```

#### 机制 2: 证据类型强制分布

```
规则: evidence 列表中，E_SELF 和 E_NARR 类型的条目
      不得超过总证据条目数的 30%。
      如果超过 → ES 维度自动 cap 在 2。
```

#### 机制 3: Deliverable Content Sampling

Evaluator 必须对 `deliverable_path` 执行内容抽样检查：

```
规则: Evaluator 必须 Read deliverable_path 并在 evidence 中
      引用至少一段实际内容（非文件名、非 section 标题）。
      如果 evidence 中没有引用实际交付物内容 → DA 维度自动 cap 在 2。
```

#### 机制 4: Acceptance Criteria 逐条映射

```
规则: verdict bundle 的 evidence section 必须为每个 acceptance_criteria
      条目提供至少一个 evidence_ref 映射。
      未映射的 criteria 视为未验证 → CC 维度按比例扣分。
      
      CC_adjusted = CC_raw × (mapped_criteria / total_criteria)
      向下取整到最近整数，最低为 1。
```

#### 机制 5: Anti-Slop 检测

以下模式在 verdict_reason 或 evidence 中出现时，触发自动审查标记：

| 模式 | 检测规则 | 效果 |
|------|----------|------|
| 空洞赞美 | verdict_reason 包含 "excellent"/"impressive"/"well-crafted" 等无实质内容的赞美词 | 标记为 `slop_flag: praise_without_substance` |
| 问题最小化 | evidence 中识别了 severity ≥ major 的问题但 verdict 为 PASS | 标记为 `slop_flag: issue_minimization` |
| 存在即合格 | evidence 仅引用文件路径/section 标题，无内容 | 标记为 `slop_flag: existence_as_quality` |
| 自述循环 | evidence 引用 Generator 的 self_review 作为主要依据 | 标记为 `slop_flag: self_reference_loop` |

```
规则: 任一 slop_flag 触发时，verdict 不可为 PASS。
      Evaluator 必须重新审视被标记的证据项，
      要么提供更强的独立证据，要么降级 verdict。

例外: issue_minimization 仅在识别的问题 severity ≥ major 时触发。
      识别了 minor 问题但 verdict 为 PASS 是合理的评估模式，
      与 evaluation-contract.md 的 "choose the narrowest verdict" 原则一致。
```

#### 机制 6: Calibration Fixture 回归测试

定期（每 N 次运行或 evaluator prompt 变更后）对 Section 8 中的 fixtures 运行 Evaluator，检查：

```
for each fixture in W1..W6:
  actual_verdict = run_evaluator(fixture)
  if actual_verdict != fixture.expected_verdict:
    calibration_drift_detected = true
    log: "Evaluator 校准漂移: fixture {id} 预期 {expected} 实际 {actual}"
```

---

## 10. 实施路径

### 10.1 与当前 Evaluator Agent 的兼容性

本设计是对当前 `agents/pge-evaluator.md` 输出格式的重大重构，不是简单的扩展。当前 Evaluator 产出 5 个 markdown section（verdict, evidence, violated_invariants_or_risks, required_fixes, next_route），目标格式包含 6 维度评分、7 个 blocking flags、结构化证据和 anti-slop 检测。以下是从当前格式到目标格式的具体变更：

| 当前行为 | 目标行为 | 过渡策略 |
|----------|---------|---------|
| 产出 verdict section | 增加 scores section 和 blocking_flags section | Phase 1: 在现有 verdict section 后追加 scores table |
| 叙述性 evidence | 结构化为 type/source/content_summary/supports_criteria | Phase 2: 逐步引入结构化字段 |
| 叙述性 violated_invariants | 增加 severity 和 evidence_ref | Phase 2 |
| 叙述性 required_fixes | 增加 contract_field 和 required_evidence | Phase 2 |
| 无独立验证要求 | 增加 independent_verification section | Phase 1 |

### 10.2 分阶段实施

**Phase 1 — 评分框架**（最小可行）：
- 在 evaluator agent prompt 中增加六维度评分要求
- 在 verdict bundle 中增加 scores table
- 实施硬阈值判定规则
- Phase 1 中间输出格式：保留当前 5 个 section，在 verdict section 后追加 `## scores` table 和 `## blocking_flags` list。evidence 仍为叙述性，但必须包含 `## independent_verification` section。

**Phase 2 — 证据结构化**：
- 实施证据分类（E_TOOL/E_FILE/E_DIFF/E_TEST/E_SELF/E_NARR）
- 实施 acceptance_criteria 逐条映射
- 实施独立验证要求

**Phase 3 — 校准与防御**：
- 实施 weak deliverable fixtures
- 实施 anti-slop 检测
- 实施 calibration 回归测试

### 10.3 验证方式

- Phase 1 验证：对历史运行产物（`.pge-artifacts/`）回溯评分，检查评分是否与实际 verdict 一致
- Phase 2 验证：对 W1-W6 fixtures 运行 Evaluator，检查 verdict 是否匹配预期
- Phase 3 验证：在连续 5 次证明运行中检查评分一致性（同质量交付物的分数方差 < 0.5）



