# PGE Agent Teams 通信设计

> Version: 0.1.0
> Date: 2026-04-29
> Status: Draft
> Scope: P/G/E 三角色的 runtime 通信平面（Agent Teams direct messaging）与 durable 控制平面（file artifacts）的职责划分、交互规则、resume 机制

---

## 1. Runtime Communication Plane

基于 Claude Code Agent Teams 的 `SendMessage` 机制。用于 agent 之间的实时、瞬态交互。

### 1.1 设计原则

- **消息是瞬态的**: SendMessage 内容不持久化到文件，不作为 resume 依据
- **消息是协作的**: P/G/E 通过消息进行实时讨论、澄清、挑战，而非通过文件轮转
- **Orchestrator 是中介**: `main`（orchestrator）可以观察和中介 agent 间通信，但不替代 agent 的专业判断

### 1.2 消息类型

| 消息类型 | 方向 | 语义 | 示例 |
|----------|------|------|------|
| `proposal` | G → E | Generator 提交 contract proposal 供 Evaluator review | "我的 execution plan 如下，请 review" |
| `challenge` | E → G | Evaluator 质疑 Generator 的某个声明或计划 | "verification_plan 中缺少对边界条件的检查" |
| `response` | G → E | Generator 回应 Evaluator 的 challenge | "已补充边界条件检查，更新如下" |
| `clarification_request` | E → G | Evaluator 请求 Generator 澄清某个细节 | "deliverable_ack 中的路径是相对还是绝对？" |
| `clarification` | G → E | Generator 回应澄清请求 | "是相对于 repo root 的路径" |
| `feedback` | E → G | Evaluator 提供 inline 反馈（非 blocking） | "evidence_plan 可以更具体，但不阻塞" |
| `preflight_verdict` | E → main | Evaluator 发送 preflight 结论摘要 | "PASS — contract 可执行" |
| `status` | G → main | Generator 报告执行进度 | "deliverable 已写入，开始 self-check" |
| `retry_brief` | main → G | Orchestrator 发送 retry 指令 + evaluator feedback | "Evaluator 反馈如下，请修复 proposal" |
| `rebriefing` | main → any | Orchestrator 在 resume 后重新 brief agent | "从 checkpoint 恢复，当前状态如下" |

### 1.3 Direct Message vs File Write 决策规则

```
问题: 这个信息需要在 session 之外存活吗？
  │
  ├─ 否 → SendMessage（runtime communication plane）
  │   例: preflight 讨论、clarification、challenge/response、status update
  │
  └─ 是 → 写文件（durable control plane）
      │
      问题: 这个信息是最终锁定结果吗？
      │
      ├─ 是 → 写入对应 artifact（contract, verdict, evidence, route）
      │
      └─ 否 → 写入 checkpoint 或 handoff（可恢复状态）
```

### 1.4 Orchestrator 的观察与中介角色

Orchestrator（`main`）在 agent-to-agent 通信中的职责：

| 职责 | 行为 |
|------|------|
| 发起 | 向 agent 发送 handoff 指令（含 context brief） |
| 观察 | 接收 agent 的 status 和 verdict 消息 |
| 中介 | 当 negotiation 陷入僵局时介入（见 §1.5 deadlock） |
| 路由 | 根据 verdict 消息决定下一步（retry / proceed / stop） |
| 不做 | 不替代 G/E 的专业判断，不修改 agent 的消息内容 |

Orchestrator 不需要"看到"G↔E 之间的每条消息。它只需要：
1. 发送 handoff brief 启动阶段
2. 接收阶段结束的 verdict/status 消息
3. 在超时或 deadlock 时介入

### 1.5 超时与 Deadlock 处理

| 场景 | 检测方式 | 处理 |
|------|----------|------|
| Agent 无响应 | Orchestrator 等待 verdict/status 超时 | 发送 `ping` 消息；若仍无响应，标记 `state = failed` |
| G↔E 循环不收敛 | preflight attempt 计数达到 `max_preflight_attempts` | Orchestrator 终止 preflight，路由到 `return_to_planner` 或 `negotiation_failed` |
| Challenge 循环 | 同一 challenge 主题出现 3 次以上 | Orchestrator 介入，要求 Evaluator 给出 final verdict |
| 全局超时 | `max_total_preflight_cycles` 耗尽 | 设置 `state = negotiation_failed`，停止 |

收敛仍由轮次计数控制（与 `pge-contract-negotiation-design.md` §5.2 一致），不引入 wall-clock timeout。

---

## 2. Durable Control Plane

基于文件 artifacts。用于持久化最终锁定结果、可审计证据、可恢复状态。

### 2.1 Artifact 分类

| Artifact 类型 | 文件 | 必需/派生 | 可变性 | 写入时机 |
|---------------|------|-----------|--------|----------|
| **Locked Contract** | `<run_id>-planner.md` | 必需 | 冻结后不可变 | Planner 阶段结束 |
| **Contract Proposal** | `<run_id>-contract-proposal.md` | 必需 | 每次 preflight attempt 可替换 | Preflight G 阶段结束 |
| **Preflight Result** | `<run_id>-preflight.md` | 必需 | 每次 preflight attempt 可替换 | Preflight E 阶段结束 |
| **Evidence** | `<run_id>-evidence/` | 必需 | Append-only | Generator 执行期间 |
| **Verdict** | `<run_id>-evaluator.md` | 必需 | 冻结后不可变 | Evaluator 阶段结束 |
| **Route** | `<run_id>-state.json` 中 `route` 字段 | 必需 | 每次路由决策可更新 | 路由阶段 |
| **Checkpoint** | `<run_id>-checkpoint.json` | 必需（多 round） | 每个 phase boundary 可替换 | Phase 边界 |
| **Handoff** | `<run_id>-handoff.md` | 必需（多 slice） | 每次 slice 切换可替换 | Slice 边界 |
| **Runtime State** | `<run_id>-state.json` | 必需 | 每个 phase 更新 | 每个 phase 边界 |
| **Summary** | `<run_id>-summary.md` | 派生 | 冻结后不可变 | Run 结束 |
| **Progress** | `<run_id>-progress.md` | 派生 | 每个 phase 更新 | 每个 phase 边界 |

### 2.2 不可变性规则

```
Locked Contract (planner.md)
  │ 一旦 Evaluator preflight PASS → 冻结
  │ 修改需要 return_to_planner → 新 negotiation round → 新版本
  │
Verdict (evaluator.md)
  │ 一旦写入 → 冻结
  │ 不可追溯修改
  │
Evidence
  │ Append-only — 新证据追加，不删除已有证据
  │
Contract Proposal / Preflight Result
  │ 每次 attempt 可替换（覆盖写入）
  │ 但 runtime-state 记录 attempt 序号，保证可追溯
  │
Runtime State / Checkpoint
  │ 每个 phase boundary 更新（替换写入）
  │ 是当前状态的快照，不是历史日志
```

### 2.3 文件写入时机

**核心规则: 文件只在 phase boundary 写入，不在 negotiation 过程中写入。**

```
Planner 阶段结束 → 写 planner.md
                  → 更新 state.json

Preflight G 结束 → 写 contract-proposal.md
                  → 更新 state.json

Preflight E 结束 → 写 preflight.md
                  → 更新 state.json

Generator 结束   → 写 generator.md + evidence/
                  → 更新 state.json

Evaluator 结束   → 写 evaluator.md
                  → 更新 state.json

Route 决策       → 更新 state.json (route, route_reason)

Run 结束         → 写 summary.md, progress.md
                  → 写 checkpoint.json (如果多 round)
                  → 最终更新 state.json
```

Preflight 过程中 G↔E 的讨论、challenge、clarification **不写文件**。只有 preflight 阶段结束时的 proposal 和 verdict 写文件。

---

## 3. 通信规则

### 3.1 明确禁止

| 规则 | 原因 |
|------|------|
| **文件不是消息总线** — 不为瞬态通信写文件 | 文件是 durable state，不是 chat channel |
| **文件不模拟聊天** — 不做 turn-by-turn 文件写入 | 每次文件写入都有 I/O 成本和 artifact 管理负担 |
| **不通过文件传递 feedback** — Evaluator 的 inline feedback 用 SendMessage | Feedback 是瞬态的，不需要在 session 外存活 |
| **不通过文件传递 retry 指令** — Orchestrator 的 retry brief 用 SendMessage | Retry 指令是一次性的，checkpoint 已记录需要 retry 的事实 |

### 3.2 明确要求

| 规则 | 原因 |
|------|------|
| **Preflight negotiation 必须使用 Agent Teams direct communication** | G↔E 的讨论是实时协作，不是文件交换 |
| **只有最终锁定结果写入文件** | Contract, negotiation summary, evidence, verdict, route 需要在 session 外存活 |
| **Resume 从 checkpoint/handoff 重建，不从 chat history 重放** | Chat history 不可靠（context compaction, session 边界） |
| **P/G/E 是稳定的 team 角色，有 direct communication 能力** | 不是三个只读写文件的独立 LLM 调用 |

### 3.3 决策边界

```
瞬态（SendMessage）                    持久（File）
─────────────────                    ──────────
preflight 讨论                        locked contract
challenge / response                  contract proposal（最终版）
clarification                         preflight verdict（最终版）
inline feedback                       evidence
status update                         evaluator verdict
retry brief                           route decision
resume rebriefing                     checkpoint / handoff
ping / deadlock intervention          runtime state
                                      summary / progress
```

---

## 4. 混合通信流程

以下用具体场景展示 runtime communication plane 和 durable control plane 如何协作。

### 4.1 Preflight Negotiation

```
main                    generator               evaluator
 │                         │                        │
 │── handoff brief ──────→ │                        │
 │   (SendMessage)         │                        │
 │                         │                        │
 │                         │── proposal ──────────→ │
 │                         │   (SendMessage)        │
 │                         │                        │
 │                         │ ←── challenge ─────── │
 │                         │     (SendMessage)      │
 │                         │                        │
 │                         │── response ──────────→ │
 │                         │   (SendMessage)        │
 │                         │                        │
 │                         │ ←── feedback ──────── │
 │                         │     (SendMessage)      │
 │                         │                        │
 │                         │── final proposal ────→ │
 │                         │   (SendMessage)        │
 │                         │                        │
 │                         │                        │── PASS
 │                         │                        │
 │ ←── preflight_verdict ──────────────────────── │
 │     (SendMessage)                                │
 │                                                  │
 │  [写文件: contract-proposal.md]                   │
 │  [写文件: preflight.md]                           │
 │  [更新: state.json]                               │
```

**关键**: G↔E 之间的 proposal/challenge/response/feedback 全部通过 SendMessage 完成。只有最终的 contract-proposal 和 preflight verdict 写入文件。

### 4.2 Evaluation

```
main                    generator               evaluator
 │                         │                        │
 │  [generator 已写文件:                             │
 │   generator.md, evidence/]                       │
 │                                                  │
 │── evaluation brief ────────────────────────────→ │
 │   (SendMessage, 含 artifact 路径引用)             │
 │                                                  │
 │                                                  │── 读 generator.md (File)
 │                                                  │── 读 evidence/ (File)
 │                                                  │── 独立验证
 │                                                  │
 │ ←── verdict summary ────────────────────────── │
 │     (SendMessage: "PASS, score 0.9")             │
 │                                                  │
 │                                                  │── [写文件: evaluator.md]
 │                                                  │
 │  [更新: state.json]                               │
```

**关键**: Evaluator 读 deliverable 和 evidence 是文件操作（durable plane），但 verdict summary 先通过 SendMessage 发给 orchestrator（快速路由决策），完整 verdict bundle 写入文件（审计/持久化）。

### 4.3 Retry

```
main                    generator               evaluator
 │                         │                        │
 │  [从 state.json 读取:                             │
 │   route = retry,                                 │
 │   evaluator feedback]                            │
 │                                                  │
 │── retry_brief ────────→ │                        │
 │   (SendMessage, 含:     │                        │
 │    - evaluator feedback │                        │
 │    - 原 contract 路径   │                        │
 │    - retry 约束)        │                        │
 │                         │                        │
 │                         │── 读原 contract (File)  │
 │                         │── 根据 feedback 修复    │
 │                         │── 写新 deliverable      │
 │                         │                        │
 │                         │── status ─────────────→ │
 │                         │   (SendMessage)        │
 │                         │                        │
 │  [写文件: generator.md (新版)]                    │
 │  [更新: state.json]                               │
```

**关键**: Retry 指令通过 SendMessage 传递（含 evaluator feedback 摘要），Generator 读原 contract 是文件操作。Evaluator feedback 的完整内容在 evaluator.md 中（durable），retry_brief 只携带摘要。

### 4.4 Before/After 对比: Smoke Test Preflight

#### Before（当前 file-only 方式）

```
1. main 发 handoff → generator 写 contract-proposal.md     [文件写入]
2. main 检查 gate
3. main 发 handoff → evaluator 读 contract-proposal.md      [文件读取]
4. evaluator 写 preflight.md                                [文件写入]
5. main 检查 gate
6. 如果 BLOCK: main 发 handoff → generator 读 preflight.md  [文件读取]
7. generator 写新 contract-proposal.md                      [文件写入]
8. 重复 3-5
```

问题:
- 每次 G↔E 交互都产生文件 I/O
- Generator 和 Evaluator 无法直接对话
- 中间状态的 contract-proposal.md 被反复覆盖，无法区分"讨论中"和"最终版"
- Orchestrator 必须在每次交互中充当文件中转

#### After（混合通信方式）

```
1. main 发 SendMessage → generator                          [消息]
2. generator 发 SendMessage(proposal) → evaluator            [消息]
3. evaluator 发 SendMessage(challenge) → generator           [消息]
4. generator 发 SendMessage(response) → evaluator            [消息]
5. evaluator 发 SendMessage(PASS) → main                     [消息]
6. 写 contract-proposal.md（最终版）                          [文件写入]
7. 写 preflight.md（最终 verdict）                            [文件写入]
8. 更新 state.json                                           [文件写入]
```

改进:
- G↔E 直接对话，无需 orchestrator 中转
- 文件只写最终结果，不写中间状态
- 文件写入次数从 N×2（每次 attempt 两个文件）降到固定 3 个
- "讨论中"和"最终版"有明确区分（消息 vs 文件）

---

## 5. 与当前设计的差异

### 5.1 Artifact 变更

| Artifact | 当前状态 | 变更 |
|----------|----------|------|
| `<run_id>-planner.md` | 保留 | 不变 — Planner 产出仍然是 durable artifact |
| `<run_id>-contract-proposal.md` | 保留 | **写入时机变更**: 不再在每次 preflight attempt 写入，只在 preflight 收敛后写入最终版 |
| `<run_id>-preflight.md` | 保留 | **写入时机变更**: 不再在每次 preflight attempt 写入，只在 preflight 收敛后写入最终 verdict |
| `<run_id>-generator.md` | 保留 | 不变 |
| `<run_id>-evaluator.md` | 保留 | 不变 |
| `<run_id>-state.json` | 保留 | **新增字段**: `negotiation_summary`（preflight 讨论摘要，从消息中提取） |
| `<run_id>-summary.md` | 保留 | 不变 |
| `<run_id>-progress.md` | 保留 | 不变 |
| `<run_id>-checkpoint.json` | 新增 | 多 round/slice 的可恢复状态快照 |
| `<run_id>-handoff.md` | 新增 | 多 slice 的 inter-phase context transfer |

### 5.2 移除或变为可选的文件

| 文件 | 变更 | 原因 |
|------|------|------|
| 中间版本的 `contract-proposal.md` | **移除** | Preflight 讨论通过消息进行，不再产生中间文件版本 |
| 中间版本的 `preflight.md` | **移除** | 同上 |
| Preflight repair 的 attempt 文件 | **移除** | Repair 讨论通过消息进行，只保留最终结果 |

### 5.3 新增消息类型

| 消息类型 | 用途 | 替代的文件操作 |
|----------|------|----------------|
| `proposal` (G→E) | Preflight 中 Generator 提交 proposal | 替代写 contract-proposal.md 中间版本 |
| `challenge` (E→G) | Evaluator 质疑 Generator | 替代写 preflight.md 中的 required_contract_fixes |
| `response` (G→E) | Generator 回应质疑 | 替代写 contract-proposal.md 修复版 |
| `clarification_request` (E→G) | Evaluator 请求澄清 | 无对应文件操作（当前缺失） |
| `clarification` (G→E) | Generator 回应澄清 | 无对应文件操作（当前缺失） |
| `feedback` (E→G) | Evaluator inline 反馈 | 无对应文件操作（当前缺失） |
| `preflight_verdict` (E→main) | Preflight 结论摘要 | 替代 main 解析 preflight.md 获取 verdict |
| `status` (G→main) | 执行进度 | 无对应文件操作（当前缺失） |
| `retry_brief` (main→G) | Retry 指令 + feedback | 替代 main 通过 handoff 模板传递 retry context |
| `rebriefing` (main→any) | Resume 后重新 brief | 新增（当前无 resume 机制） |

### 5.4 Handoff 模板变更

当前 `skills/pge-execute/handoffs/preflight.md` 定义了两步 file-backed handoff:
1. main → generator（写 contract-proposal.md）
2. main → evaluator（读 contract-proposal.md，写 preflight.md）

变更为:
1. main → generator（SendMessage: handoff brief）
2. generator ↔ evaluator（SendMessage: proposal/challenge/response 多轮）
3. evaluator → main（SendMessage: preflight_verdict）
4. 写 contract-proposal.md（最终版）+ preflight.md（最终 verdict）

Gate 检查仍然在文件写入后执行，确保 durable artifact 的结构完整性。

---

## 6. Resume 与恢复

### 6.1 核心原则

**Resume 不恢复完整 chat history。** Resume 从 checkpoint + handoff artifacts 重建最小必要 context，通过 SendMessage 重新 brief agents。

### 6.2 Resume 不做什么

| 不做 | 原因 |
|------|------|
| 不重放旧的 negotiation 消息 | 消息是瞬态的，只有锁定结果（文件）有意义 |
| 不恢复 G↔E 的讨论历史 | 讨论已收敛为 contract-proposal + preflight verdict |
| 不从 artifact 文件反推 chat 上下文 | 文件是结果，不是过程记录 |
| 不尝试恢复 agent 的"记忆" | Agent 是无状态的，通过 rebriefing 获得必要 context |

### 6.3 Resume 做什么

```
Session 恢复
  │
  ▼
[1] 读取 checkpoint.json
  │  - 当前 run_id, slice_id, round_id
  │  - 当前 state（哪个 phase）
  │  - 已完成的 phases
  │  - 未完成的 phase 及其 context
  │
  ▼
[2] 读取 state.json
  │  - 验证 checkpoint 与 state 一致
  │  - 获取 artifact refs
  │
  ▼
[3] 读取 handoff.md（如果跨 slice）
  │  - 上一个 slice 的结论
  │  - 当前 slice 的目标
  │  - 携带的 context
  │
  ▼
[4] 重建 team
  │  - TeamCreate（新 team，不恢复旧 team）
  │  - 新 team_name 记录在 state.json
  │
  ▼
[5] Rebriefing
  │  - 向每个需要的 agent 发送 rebriefing 消息（SendMessage）
  │  - 消息内容: checkpoint 摘要 + 当前 phase 的 context
  │  - 不发送历史讨论内容
  │
  ▼
[6] 从中断点继续
  │  - 如果中断在 preflight: 重新开始 preflight（不恢复之前的讨论）
  │  - 如果中断在 generation: 检查 deliverable 状态，决定继续或重做
  │  - 如果中断在 evaluation: 重新开始 evaluation
```

### 6.4 Checkpoint 结构

```jsonc
{
  "checkpoint_version": 1,
  "created_at": "2026-04-29T12:00:00Z",
  "run_id": "run-20260429T120000Z",
  "slice_id": "run-20260429T120000Z-s1",
  "round_id": "run-20260429T120000Z-s1-r1",

  "interrupted_phase": "preflight_pending",
  "completed_phases": ["initialized", "team_created", "planning"],

  "artifact_refs": {
    "planner": ".pge-artifacts/run-20260429T120000Z-planner.md",
    "state": ".pge-artifacts/run-20260429T120000Z-state.json"
  },

  "resume_context": {
    "contract_locked": false,
    "preflight_attempt": 1,
    "negotiation_round": 1
  }
}
```

### 6.5 旧 Negotiation 消息的处理

**旧 negotiation 消息在 resume 时丢失。这是设计决策，不是缺陷。**

理由:
1. Negotiation 消息的价值在于推动收敛，收敛结果已写入文件
2. 恢复旧消息需要重建完整 chat context，成本高且不可靠
3. 如果 preflight 在收敛前中断，重新开始 preflight 比恢复半完成的讨论更可靠
4. Agent 是无状态的 — 给它们 checkpoint context 比给它们旧消息更有效

### 6.6 Resume 与 Retry 的区别

| | Resume | Retry |
|---|--------|-------|
| 触发 | Session 中断后恢复 | Evaluator verdict 触发 |
| Context 来源 | Checkpoint + handoff artifacts | Evaluator feedback + 原 contract |
| Agent 状态 | 新 team，rebriefing | 同一 team，retry_brief |
| 消息历史 | 丢失 | 保留（同一 session 内） |
| 从哪里继续 | 中断点的 phase 开头 | 同一 phase 内重试 |
