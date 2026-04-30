# PGE Agent Teams 通信设计

> Version: 0.2.0
> Date: 2026-04-29
> Status: Draft
> Scope: P/G/E 三角色在 runtime 中的消息面与 durable 控制面的分工

> Current-repo note (2026-04-30):
> this document still contains the richer preflight / mode-decision communication design.
> It is useful as future architecture guidance, but it is not the authoritative description of the current executable lane.
> The current lane is the simpler `planner -> generator -> evaluator` skeleton with `main` as the only authoritative progress writer.

---

## 1. 目标

`0.5B` 要解决的是：

- 当前 P/G/E 很多交互仍然表现得像“读写文件的三个独立调用”
- 这与 Agent Teams 已经提供的 direct communication 能力不匹配
- 文件应该承担 durable state / audit / recovery，而不是模拟聊天

因此：

- 常规协商走 `SendMessage`
- durable phase outputs 才写文件
- resume 从 durable artifacts 重建，不重播消息历史

---

## 2. 两个通信平面

### 2.1 Runtime Communication Plane

基于 Agent Teams `SendMessage`，用于瞬态协作。

适用内容：

- proposal
- challenge
- clarification
- response
- inline feedback
- status
- fast-finish approval / rejection
- mode decision summary
- retry brief
- rebriefing

特点：

- 瞬态
- 高频
- 不直接用于 resume

### 2.2 Durable Control Plane

基于文件 artifacts，保存阶段结果和恢复状态。

适用内容：

- locked planner contract
- 最终 contract proposal / preflight verdict（当 mode 需要）
- generator durable output / evidence
- evaluator final verdict
- state / checkpoint / handoff
- mode-required summary / progress

特点：

- 低频
- 可审计
- 可恢复

---

## 3. 核心规则

### 3.1 默认规则

先问一个问题：

```text
这条信息是否需要在 session 之外继续存活？
```

- 如果不需要：走 `SendMessage`
- 如果需要：写 durable artifact

### 3.2 明确禁止

- 不把文件当 turn-by-turn 消息总线
- 不为每个 challenge / response / clarification 写一个文件版本
- 不让 orchestrator 充当 G↔E 每轮消息的人工中转站
- 不从 artifact 反推完整聊天历史

### 3.3 明确要求

- 在 richer preflight lane 中，Preflight 协商默认由 Generator 和 Evaluator 直接通信
- Planner / Generator / Evaluator 之间的常规反馈优先走 `SendMessage`
- 文件只记录“阶段收敛结果”，不记录“讨论过程本身”
- Resume 依赖 checkpoint / state / handoff，不依赖旧消息历史；这是 future recovery model，不是当前 executable lane 的已实现能力

---

## 4. Orchestrator 的角色

Orchestrator（`main`）负责：

- 发起阶段 handoff
- 观察阶段是否完成
- 接收阶段结论消息
- 将 durable phase outputs 落盘
- 根据 Evaluator 结论路由

Orchestrator 不负责：

- 充当每条消息的代理中转
- 替代 Evaluator 的 mode decision
- 修改 G/E 的专业结论

Evaluator 在通信面中的职责是：

- 在 preflight / triage 中做成本门控
- 在 execution 后做独立验收
- 给出足以驱动路由的最小 verdict

Evaluator 不应在通信面中退化成“长篇评审报告生成器”。消息和 durable 输出都应服务于收敛，而不是扩写审计文本。

---

## 5. 推荐消息类型

| 消息类型 | 方向 | 用途 |
|----------|------|------|
| `task_shape_brief` | main → planner | 启动 planner 阶段 |
| `execution_proposal` | generator → evaluator | 提交执行/验证方案 |
| `challenge` | evaluator → generator | 质疑 proposal |
| `clarification_request` | evaluator → generator | 请求补充 |
| `response` | generator → evaluator | 回应 challenge |
| `feedback` | evaluator → generator | 非 blocking 建议 |
| `mode_decision` | evaluator → main | richer adaptive lane 中说明 `FAST_PATH / LITE_PGE / FULL_PGE / LONG_RUNNING_PGE` |
| `preflight_verdict` | evaluator → main | richer preflight lane 中给出 PASS/BLOCK/ESCALATE |
| `status` | generator → main | 报告执行阶段进度 |
| `retry_brief` | main → generator | 传递 retry 摘要 |
| `rebriefing` | main → any | resume 后重建最小上下文 |

---

## 6. Preflight 的正确通信形态

### 6.1 Before

旧模型的问题：

1. Generator 写 `contract-proposal.md`
2. Evaluator 读这个文件
3. Evaluator 写 `preflight.md`
4. Generator 再读这个文件修复
5. 文件在协商过程中反复覆盖

这本质上是 file-only negotiation。

### 6.2 After (future richer lane)

正确模型：

```text
main -> generator: handoff brief
generator -> evaluator: execution_proposal
evaluator -> generator: challenge / clarification / feedback
generator -> evaluator: response / revised proposal
evaluator -> main: mode_decision + preflight_verdict
main: 仅在需要 durable audit 时写 contract-proposal.md / preflight.md
```

关键点：

- G↔E 直接对话
- durable file 只记录收敛后的阶段结果
- 中间 turns 不写文件

### 6.3 FAST_PATH / LITE_PGE / FULL_PGE 的差别

| Mode | preflight 文件要求 |
|------|--------------------|
| `FAST_PATH` | 默认不写 `contract-proposal.md` / `preflight.md` |
| `LITE_PGE` | 默认不写；必要时可保留最小 durable 结果 |
| `FULL_PGE` | 写最终 `contract-proposal.md` 与 `preflight.md` |
| `LONG_RUNNING_PGE` | 后续 phase 定义 |

---

## 7. Evaluation 阶段

Evaluation 的 durable 输入仍然重要，因为 Evaluator 需要独立读真实 deliverable。

正确分工：

- 实时 dispatch / status：走消息
- deliverable / evidence / generator durable output：走文件
- final evaluator verdict：走文件
- verdict summary / route hint：可先走消息，再落盘

因此，`0.5B` 改的是“协商过程”，不是删掉独立评估。

---

## 8. Resume / Recovery

### 8.1 原则

Resume 不恢复完整聊天历史。
Resume 从 durable artifacts 恢复最小必要上下文。

### 8.2 读取顺序

1. `checkpoint.json`
2. `state.json`
3. `handoff.md`（如果存在）
4. 必要的 planner / generator / evaluator durable artifacts

### 8.3 不做什么

- 不重放旧 negotiation 消息
- 不尝试恢复 agent 的“记忆”
- 不从文件反向推导完整聊天

### 8.4 要做什么

- 新建 team
- 给需要的 agent 发送 `rebriefing`
- 从中断 phase 的入口重新开始

---

## 9. Durable artifact 边界

| Artifact | 角色 |
|----------|------|
| `planner.md` | locked task-shape / round contract |
| `contract-proposal.md` | 最终 preflight proposal（仅 mode 需要时） |
| `preflight.md` | 最终 preflight verdict（仅 mode 需要时） |
| `generator.md` | generator durable output（仅 mode 需要时） |
| `evaluator.md` | final independent verdict |
| `state.json` | 机器可读 source of truth（future recovery lane） |
| `checkpoint.json` / `handoff.md` | 恢复与跨阶段延续（future recovery lane） |
| `summary.md` / `progress.md` | mode-required human-readable 派生物（older / future design surface） |

这个边界的关键不是“文件越少越好”，而是：

- 文件必须代表 durable phase result
- 文件不能退化成消息总线

---

## 10. 对 runtime surface 的要求

需要同步更新：

| 文件 | 要求 |
|------|------|
| `skills/pge-execute/SKILL.md` | 把 runtime claim 改成 messaging-first |
| `skills/pge-execute/ORCHESTRATION.md` | 明确 preflight 是消息优先、文件收敛 |
| `skills/pge-execute/handoffs/preflight.md` | 让 G/E 直接通信 |
| `skills/pge-execute/runtime/artifacts-and-state.md` | 让 artifact 变成 mode-aware |

如果这些 runtime surface 不同步，`0.5B` 只会停留在设计文档层面。
