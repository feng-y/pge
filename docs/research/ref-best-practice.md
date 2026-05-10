# 调研报告: shanraisshan/claude-code-best-practice

> 来源: https://github.com/shanraisshan/claude-code-best-practice
> 调研日期: 2026-04-29
> 调研重点: Development Workflows / 验证优先 / 小步推进 / 上下文管理

## 1. Development Workflows 核心流程

### 1.1 统一架构模式

所有主流 workflow 收敛到同一模式: **Research → Plan → Execute → Review → Ship**

repo 对比了 10 个主流 workflow 项目 (按 star 排序):
- Superpowers (168k): TDD-first, Iron Laws, whole-plan review
- Everything Claude Code (167k): instinct scoring, AgentShield
- Spec Kit (91k): spec-driven, constitution
- gstack (84k): role personas, /codex review, parallel sprints
- GSD (57k): fresh 200K contexts, wave execution, XML plans
- BMAD-METHOD (46k): full SDLC, agent personas
- OpenSpec (43k): delta specs, brownfield, artifact DAG
- oh-my-claudecode (31k): teams orchestration, tmux workers
- Compound Engineering (16k): Compound Learning, Plugin Marketplace
- HumanLayer (11k): RPI, context engineering

### 1.2 RPI → CRISPY 演进 (HumanLayer/Dex)

RPI (Research-Plan-Implement) 的实战教训 (Dex, MLOps Community 2026-03-24):

**RPI 的三个核心错误:**
1. 单一 mega-prompt 85+ 条指令 → 模型只能可靠遵循 ~150-200 条指令
2. 让用户读 1000 行 plan → plan 和 code 几乎等长, 不是 leverage
3. "magic words" 问题 → 必须说特定话术才能触发正确行为

**CRISPY 修正 (7 步替代 3 步):**
- Questions → Research → Design → Structure → Plan → Work → Implement → PR
- 每步 <40 条指令 (原来 85+)
- Design discussion ~200 行 (替代 1000 行 plan review)
- Structure outline = "C header file" — 只看签名和类型, 不看实现

**关键原则:**
- "Don't use prompts for control flow — use control flow for control flow"
- "Do not outsource the thinking" — 人类必须参与设计决策
- 垂直 plan (vertical) 优于水平 plan (horizontal) — 每个 phase 端到端可测试

### 1.3 Cross-Model Workflow

Claude Code (Opus) + Codex CLI (GPT) 交叉验证:
1. Plan (Claude, plan mode) → 2. QA Review (Codex) → 3. Implement (Claude) → 4. Verify (Codex)

Codex 在 plan 中插入 "Phase 2.5" 补充发现, 不重写原始 phase.

### 1.4 Orchestration Pattern: Command → Agent → Skill

三层编排:
- Command: 入口, 用户交互, 流程编排
- Agent: 带 preloaded skill 的执行者, 独立 context window
- Skill: 独立调用的能力单元, 可 fork context

## 2. 验证优先 (Verification-First) 策略

### 2.1 Boris Cherny 核心观点

> "Probably the most important thing to get great results out of Claude Code — give Claude a way to verify its work. If Claude has that feedback loop, it will 2-3x the quality of the final result."

具体做法:
- Claude tests every single change before landing
- 用 background agent 验证长时间任务
- 用 Stop hook 在 turn 结束时强制验证
- "prove to me this works" — 让 Claude diff main vs branch
- "grill me on these changes and don't make a PR until I pass your test"

### 2.2 Product Verification Skills (Thariq)

Thariq 将 verification 提升为独立 skill 类型:
- signup-flow-driver, checkout-verifier, tmux-cli-driver
- "It can be worth having an engineer spend a week just making your verification skills excellent"
- 配合 Playwright/tmux/browser MCP 实现端到端验证

### 2.3 Phase-wise Gated Plan (Dex)

每个 phase 有多层测试:
- Unit tests
- Automation tests  
- Integration tests
- 只有通过 gate 才能进入下一 phase

### 2.4 Cross-Model Verification

用不同模型做 "test time compute":
- "separate context windows make results better"
- "one agent can cause bugs and another (same model) can find them"
- Codex review Claude 的 plan 和 implementation

## 3. 小步推进 (Small-Step Progression) 策略

### 3.1 Vertical Plans vs Horizontal Plans

**Horizontal (模型默认倾向, 应避免):**
- 先做所有 database → 所有 services → 所有 API → 所有 frontend
- 1200 行代码后才发现不工作, 无法定位问题

**Vertical (推荐):**
- mock API endpoint → frontend 接入 → services layer → database migration → 集成
- 每个 checkpoint 可验证, 出错可定位

### 3.2 PR Size Discipline (Boris)

- p50 = 118 行 (141 PRs, 45K lines changed in a day)
- 一个 feature 一个 PR
- 始终 squash merge — 干净线性历史, 方便 revert/bisect
- 至少每小时 commit 一次

### 3.3 Design → Structure → Plan 渐进细化

- Design discussion: ~200 行, 方向对齐
- Structure outline: ~2 页, "C header file" 级别
- Plan: 完整实现细节, 但此时方向已锁定
- 每层都是 review checkpoint

### 3.4 Instruction Budget 管理

- 前沿 LLM 只能可靠遵循 ~150-200 条指令
- 单个 prompt <40 条指令
- 用 control flow (多步骤) 替代 prompt 内 control flow

## 4. 上下文管理 (Context Management) 策略

### 4.1 Context Rot 阈值 (Thariq)

- 1M context model: ~300-400k tokens 开始 context rot
- 新手: 保持 <40%, 到 60% 考虑收尾
- 老手: 激进保持 <30%, 简单任务才到 60%
- Autocompact 发生在模型最不智能的时刻 → 主动 /compact 带 hint 更好

### 4.2 五种 Turn 后选择 (Thariq)

每个 turn 结束是分支点:

| 选择 | 携带上下文 | 适用场景 |
|------|-----------|---------|
| Continue | 全部 | 同任务, 上下文仍相关 |
| /rewind (Esc Esc) | 保留前缀, 截断尾部 | Claude 走错路 |
| /compact <hint> | 有损摘要 | 中途, 会话膨胀 |
| /clear + brief | 仅你的 brief | 新任务, 高风险下一步 |
| Subagent | 全部 + 仅结果返回 | 大量中间输出只需结论 |

### 4.3 Rewind > Correct

- 纠正 ("no, try B") 留下失败尝试污染 context
- Rewind 回到失败前, 用学到的知识重新 prompt
- "summarize from here" → 让 Claude 写 handoff message 再 rewind

### 4.4 Subagent 作为上下文管理工具

核心判断: "will I need this tool output again, or just the conclusion?"
- 20 file reads + 12 greps + 3 dead ends → 只有 final report 返回 parent
- 探索噪音在 subagent 退出时被 GC

### 4.5 Static Artifacts 替代 Compaction (Dex/HumanLayer)

- 所有重要信息写入 static markdown artifacts (design, structure, plan)
- 不依赖 built-in compaction
- 可以随时从 artifacts 恢复, 不担心 autocompact 质量

## 5. 对 PGE Generator Sprint Execution 有价值的具体点

### 5.1 直接可用

1. **Vertical phase 设计** — PGE 的 multi-round execution 应该每轮端到端可验证, 不做水平切片
2. **Instruction budget** — PGE skill/contract 指令总量控制在 <40 条/步骤
3. **Static artifact 作为 context 锚点** — 每轮产出写入文件, 不依赖 context 内记忆
4. **Rewind-first 纠错** — proving run 失败时回退到 checkpoint 重试, 不在失败上下文中修补
5. **Verification skill 独立化** — PGE evaluator 应该是独立 skill, 不是 inline 逻辑
6. **Design → Structure → Plan 三层渐进** — PGE 的 contract negotiation 可以借鉴这个渐进对齐模式

### 5.2 需要适配

1. **Cross-model verification** — PGE 当前单模型, 但可以用 subagent 做 "不同 context window" 验证
2. **CRISPY 7 步** — PGE 不需要完整 7 步, 但 "design discussion" 对齐步骤值得引入
3. **PR size discipline** — PGE 是 docs/contracts skeleton, 但 "每轮一个可验证产出" 原则适用

## 6. 不适用于 PGE 的部分

1. **Plugin/Marketplace 分发** — PGE 是单项目, 不需要 skill 分发体系
2. **MCP 集成** (Slack, BigQuery, Sentry) — PGE 不涉及外部服务集成
3. **Agent Teams / tmux 并行** — PGE 当前是单线程 proving, 不需要并行编排
4. **Ralph Wiggum Loop** — PGE 需要人类参与 gate, 不适合全自主循环
5. **Voice dictation / Remote control** — 工具层面, 与 PGE 设计无关
6. **PostToolUse hooks / auto-format** — 运行时工具链, 不影响 PGE 合约设计

## 7. 引用来源

- [shanraisshan/claude-code-best-practice](https://github.com/shanraisshan/claude-code-best-practice) — README, 82 tips
- Boris Cherny (Claude Code creator): 13 tips (2026-01-03), 6 tips (2026-04-16)
- Thariq (Anthropic): Session Management & 1M Context (2026-04-16), Skills (2026-03-17)
- Dex Horthy (HumanLayer): "Everything We Got Wrong About RPI" (MLOps Community, 2026-03-24)
- RPI Workflow: development-workflows/rpi/rpi-workflow.md
- Cross-Model Workflow: development-workflows/cross-model-workflow/cross-model-workflow.md
- Orchestration Workflow: orchestration-workflow/orchestration-workflow.md
