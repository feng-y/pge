# PGE 自适应执行设计

> Version: 0.2.0
> Date: 2026-04-29
> Status: Draft
> Scope: execution mode 选择、authority chain、artifact budget、deterministic check、轻量闭环与完整闭环的边界

> Current-repo note (2026-04-30):
> this file is an adaptive-execution design reference, not the authoritative description of the current executable lane.
> The active lane is still the simpler `planner -> generator -> evaluator` skeleton documented in
> `skills/pge-execute/SKILL.md`, `skills/pge-execute/ORCHESTRATION.md`, and `docs/exec-plans/PGE_RUNTIME_ROLES_AND_PIPELINE.md`.
> Treat `FAST_PATH / LITE_PGE / FULL_PGE / LONG_RUNNING_PGE` here as future or partial design intent unless the active execution-core seams say otherwise.

---

## 1. 问题定义

当前 PGE 的设计问题最初来自把所有任务都送进同一条过重的流水线。历史草案里，`/pge-execute test` 这类简单确定性任务也会被描述成经历 Planner → Preflight → Generator → Evaluator，并产出大量管理 artifact。

问题不是 P/G/E 三角色本身，而是：

- 简单任务没有轻量闭环
- Planner、Generator、Evaluator 的 authority 还没有为“快速结束”定义清楚
- deterministic task 的验证没有被降级成更便宜的路径

---

## 2. 核心原则

### 2.1 Team-backed，不回退到 direct execution

`0.5A` 不把简单任务退化成“无 team 的直接执行”。

简单任务仍然经过 Agent Teams quick triage，只是减少交互轮数和 durable artifacts。

### 2.2 Planner 没有 fast-finish 决策权

Planner 的职责是：

- 识别任务形态
- 塑形任务边界
- 明确验收条件
- 锁定当前轮 contract

Planner **不**做以下事情：

- 不输出 `recommended_mode`
- 不决定 `FAST_PATH`
- 不决定 fast finish

### 2.3 Generator 提出执行方式

Generator 基于 Planner contract 提出：

- 执行路径
- 验证方式
- 风险和前提
- 是否存在足够确定性的快速闭环机会

它是 proposal owner，不是 mode owner。

### 2.4 Evaluator 拥有 Execution Cost Gate

Evaluator 看到：

- Planner 的 task shape / contract
- Generator 的执行方案和验证方案

然后决定：

- `FAST_PATH`
- `LITE_PGE`
- `FULL_PGE`
- `LONG_RUNNING_PGE`

以及：

- 是否允许 fast finish
- 是否必须保留完整 preflight / full evaluation surface

### 2.4A Evaluator 的职责边界

Evaluator 的核心职责只有三类：

- **独立验收**：直接检查 deliverable 和关键证据，不接受 Generator 自述代替验证
- **路由裁决**：给出足以驱动 runtime 的最小结论（`PASS` / `RETRY` / `BLOCK` / `ESCALATE` 及对应 `next_route`）
- **成本门控**：判断任务应进入 `FAST_PATH`、`LITE_PGE`、`FULL_PGE` 还是 `LONG_RUNNING_PGE`

Evaluator 不应默认承担这些角色：

- 不做产品规划
- 不替 Generator 修实现
- 不输出长篇审计报告
- 不因为可以评分就默认写大评分矩阵

判断原则：

**Evaluator 的输出必须足够让 orchestrator 决策，但不能重到让 Evaluator 自己变成瓶颈。**

### 2.5 Orchestrator 只执行，不裁决

Orchestrator 负责：

- 建队
- 派发
- 收集 durable outputs
- 执行 deterministic checks
- 记录 state / summary / progress

Orchestrator 不负责：

- 自己判定复杂度
- 自己决定 fast finish
- 越权覆盖 Evaluator 的 mode decision

---

## 3. 四种执行模式

| Mode | 适用场景 | 特征 | 管理 artifact 预算 |
|------|---------|------|-------------------|
| `FAST_PATH` | 单一、确定性、可快速验证的任务 | quick triage + deterministic check + Evaluator 最终确认 | ≤ 3 |
| `LITE_PGE` | bounded task，仍需 Generator 真正执行，但不需要 full preflight artifact surface | 轻量 preflight + Generator 产出 + Evaluator 最终确认 | ≤ 4 |
| `FULL_PGE` | 需要完整 contract negotiation 和独立评估 | 完整 planner / preflight / generator / evaluator durable outputs | 当前完整集 |
| `LONG_RUNNING_PGE` | 大任务、跨多轮或恢复需求 | 依赖后续 Phase 2/5 | 未来定义 |

说明：

- `LONG_RUNNING_PGE` 在 `0.5A` 中先定义语义，不提前谎称已经完整可执行
- 管理 artifact 不包含 `input_artifact` 和最终 deliverable 本身

---

## 4. 模式选择流程

### 4.1 Quick triage authority chain

```text
main 创建 team
  -> planner 产出 task shape / locked contract
  -> generator 提交 execution proposal + verification proposal
  -> evaluator 审核 proposal 并决定 execution mode
  -> main 按 evaluator 决定执行
  -> evaluator 做最终确认
```

### 4.2 决策信号

| 信号 | Planner 提供 | Generator 提供 | Evaluator 使用 |
|------|--------------|----------------|----------------|
| 任务目标是否明确 | 是 | 参考 | 是 |
| 验收标准是否确定性 | 是 | 强化/具体化 | 是 |
| 是否存在轻量执行路径 | 否，最多描述任务特征 | 是 | 是 |
| 风险/前提 | 边界层面 | 执行层面 | 是 |
| mode 决策 | 否 | 否 | 是 |

### 4.3 决策规则

```text
if task is deterministic and bounded
  and generator can explain a cheap verification path
  and evaluator approves fast finish:
    mode = FAST_PATH
else if task is bounded and clear
  and full durable preflight is unnecessary:
    mode = LITE_PGE
else if task fits current bounded full workflow:
    mode = FULL_PGE
else:
    mode = LONG_RUNNING_PGE
```

---

## 5. 每种模式的执行闭环（future / partial design）

### 5.1 FAST_PATH

适用：

- smoke test
- 精确文件写入
- 单一 deterministic command / output check

闭环：

1. Planner 写最小 locked contract
2. Generator 通过消息提出执行/验证方案
3. Evaluator 通过 quick triage 确认允许 fast finish
4. Generator 产出 deliverable
5. Orchestrator 执行 deterministic check
6. Evaluator 基于 deliverable + check 结果给出最终 verdict
7. 写最终可接受的轻量 closeout artifact（当前 repo 不再把 `state.json` 作为 executable-lane 必需物）

关键约束：

- 不写 `contract-proposal.md`
- 不写 `preflight.md`
- 不写 `generator.md`
- 不写 `summary.md` / `progress.md`
- 当前 active lane 至少保留 `planner.md` 与 `evaluator.md`；`state.json` 属于旧设计/未来恢复面，不是现行必需物
- Evaluator 使用 lightweight verdict，不要求完整评分矩阵

### 5.2 LITE_PGE

适用：

- 任务有真实执行工作
- 但 full preflight artifact surface 过重
- 验收标准仍然偏确定性

闭环：

1. Planner 写 locked contract
2. Generator / Evaluator 通过消息完成轻量 preflight
3. Evaluator 选择 `LITE_PGE`
4. Generator 执行并写 `generator.md`
5. Orchestrator 跑 deterministic check（如果有）
6. Evaluator 输出最终 verdict

关键约束：

- 默认不写 `contract-proposal.md`
- 默认不写 `preflight.md`
- 保留 `generator.md`
- 当前 active lane 使用 `progress.jsonl`，且只由 `main` 记录；这里的 `progress.md` 仅代表旧的人类可读派生面
- Evaluator 使用 compact core scoring，而不是完整评分矩阵

### 5.3 FULL_PGE

适用：

- contract 需要完整协商
- 执行边界存在真实风险
- 需要完整验收面，但不需要默认进入重型审计模式

闭环：

- 保持现有 bounded full flow
- 但 preflight 协商过程使用 `SendMessage`
- durable files 只记录阶段结果，不记录讨论过程
- Evaluator 使用 compact core scoring；不默认要求 weighted score、blocking flags 矩阵或 confidence 矩阵
- `FULL_PGE` 的重点仍然是“是否收敛”和“如何路由”，不是生成冗长评审稿

### 5.4 LONG_RUNNING_PGE

适用：

- 当前单轮 bounded lane 不足以完成
- 需要 checkpoint / recovery / multi-round

`0.5A` 只定义语义：

- Evaluator 可以把任务分类为 `LONG_RUNNING_PGE`
- 当前 lane 不得假装已经具备完整 long-running 执行能力
- 后续由 Phase 2 / 5 承接

---

## 6. Artifact Budget

| Artifact | `FAST_PATH` | `LITE_PGE` | `FULL_PGE` | `LONG_RUNNING_PGE` |
|----------|-------------|------------|------------|--------------------|
| `planner.md` | 必须 | 必须 | 必须 | 必须 |
| `contract-proposal.md` | 禁止 | 默认不写 | 必须 | 未来定义 |
| `preflight.md` | 禁止 | 默认不写 | 必须 | 未来定义 |
| `generator.md` | 禁止 | 必须 | 必须 | 未来定义 |
| `evaluator.md` | 必须 | 必须 | 必须 | 必须 |
| `state.json` | 旧设计 / 未来恢复面 | 旧设计 / 未来恢复面 | 旧设计 / 未来恢复面 | 未来定义 |
| `summary.md` | 旧的人类可读派生面 | 旧的人类可读派生面 | 旧的人类可读派生面 | 未来定义 |
| `progress.md` | 旧的人类可读派生面 | 旧的人类可读派生面 | 旧的人类可读派生面 | 未来定义 |

强制规则：

- artifact budget 由 Evaluator 选出的 mode 决定
- 超预算是 runtime warning，不应被当成“正常行为”
- `FAST_PATH` 的预算是“最小 durable 审计面”，不是“零审计”

---

## 7. Deterministic Check

deterministic check 仍由 orchestrator 执行，而不是由 Planner 或 Generator 宣称成功。

它可以包括：

- `exact_match`
- `contains`
- `regex`
- `exit_code`
- `file_exists`
- `diff`

规则：

- `FAST_PATH` 必须有 deterministic check 或同等级别的轻量验证
- `LITE_PGE` 优先使用 deterministic check
- `FULL_PGE` 中 Evaluator 必须引用 check 结果（如果存在），但不能用“引用 check”代替独立 verdict

---

## 8. state.json 与 progress.md（historical / future design note）

这节保留的是较早的设计思路，不是当前 executable lane 的权威描述。
当前 active lane:
- 不要求 `state.json`
- 使用 `progress.jsonl`
- 且 progress 只由 `main` 记录

新增的核心字段：

```jsonc
{
  "mode": "FAST_PATH | LITE_PGE | FULL_PGE | LONG_RUNNING_PGE",
  "mode_decision_owner": "evaluator",
  "fast_finish_approved": true,
  "artifact_budget": 3,
  "check": {}
}
```

规则：

- 所有 mode 都写 `state.json`
- 只有 `FULL_PGE` 及未来 `LONG_RUNNING_PGE` 默认写 `progress.md`
- `progress.md` 必须从 `state.json` 派生，不得独立发明状态

---

## 9. 需要修改的 runtime surface

| 文件 | 修改内容 |
|------|---------|
| `skills/pge-execute/SKILL.md` | 改成 messaging-first + mode-aware runtime lane |
| `skills/pge-execute/ORCHESTRATION.md` | 用单 run、多 mode 描述当前执行壳 |
| `skills/pge-execute/runtime/artifacts-and-state.md` | 增加 mode / budget / optional artifacts |
| `skills/pge-execute/handoffs/preflight.md` | 让 Evaluator 拥有 mode decision |
| `skills/pge-execute/contracts/routing-contract.md` | 明确 mode 不是 route |

不应该再要求的行为：

- Planner 输出 `recommended_mode`
- Planner 触发 short-circuit
- `FAST_PATH` 跳过 Evaluator
- 简单任务默认落回 full artifact chain
