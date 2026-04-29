# Anthropic Harness Design 调研报告

> 调研日期: 2026-04-29
> 来源: Anthropic Engineering Blog 系列文章

## 1. 核心设计理念

Anthropic 的 agent harness 设计遵循一个核心原则：**找到最简单的可行方案，只在确实能改善结果时才增加复杂度**。

关键理念：
- **简单、可组合的模式** 优于复杂框架。最成功的实现不依赖专用库，而是用基础组件构建
- **Harness 编码的是对模型能力不足的假设**，这些假设需要随模型进步持续验证和剥离
- **Context 是有限资源**，存在递减边际收益。每个新 token 都消耗注意力预算
- **模型越强，harness 越轻**，但有趣的 harness 组合空间不会缩小——它会移动

## 2. Planner / Generator / Evaluator 三角色架构

### 来源
"Harness design for long-running application development" (2026-03-24, Prithvi Rajasekaran)

### 架构演进

**V1: 两角色 (Initializer + Coding Agent)**
- Initializer: 将用户 prompt 展开为 feature list，设置环境
- Coding Agent: 逐 feature 实现，每个 session 结束时留下结构化 artifact

**V2: 三角色 (Planner + Generator + Evaluator)**

| 角色 | 职责 | 关键设计点 |
|------|------|-----------|
| **Planner** | 将 1-4 句 prompt 展开为完整产品 spec | 关注产品上下文和高层技术设计，不指定细粒度实现细节。避免 spec 错误级联到下游 |
| **Generator** | 按 sprint 逐 feature 实现 | 每个 sprint 结束自评，有 git 版本控制。与 Evaluator 协商 sprint contract |
| **Evaluator** | 用 Playwright MCP 实际操作应用，按标准打分 | 独立于 Generator 的判断。有硬阈值，任一标准低于阈值则 sprint 失败 |

### 为什么需要分离

**自评估问题**: Agent 评估自己的工作时，倾向于自信地赞美——即使质量明显平庸。这在主观任务（如设计）上尤为突出。

**分离的好处**: 调优一个独立的 evaluator 使其持怀疑态度，比让 generator 对自己的工作保持批判性要容易得多。一旦外部反馈存在，generator 就有了具体的迭代目标。

## 3. 多轮 Sprint 执行模型

### Sprint 结构 (V1 Harness)

Generator 按 sprint 工作，每个 sprint 实现一个 feature：

1. **Sprint 开始**: 读取 progress file 和 git log，选择下一个未完成 feature
2. **实现**: 编码、自测
3. **Sprint 结束**: git commit + progress update，留下干净状态

**"干净状态"定义**: 适合合并到 main 分支的代码——无重大 bug，代码有序且有文档，开发者可以直接开始新 feature 而不需要先清理无关的混乱。

### Sprint Contract 协商 (V2 Harness)

每个 sprint 开始前，Generator 和 Evaluator 协商一个 **sprint contract**：

- Generator 提出要构建什么以及如何验证成功
- Evaluator 审查提案，确保 Generator 构建的是正确的东西
- 双方迭代直到达成一致
- **通信通过文件**: 一个 agent 写文件，另一个读取并回应

这个机制存在是因为产品 spec 故意保持高层级，需要一个步骤来桥接用户故事和可测试的实现。

### V2 简化: 移除 Sprint 构造

在 Opus 4.6 上，sprint 构造被完全移除：
- 模型原生能力足以处理长任务分解
- Evaluator 改为在运行结束时做单次评估
- Evaluator 的价值取决于任务是否在模型独立能力边界之外

**关键洞察**: Evaluator 不是固定的 yes/no 决策。当任务超出当前模型独立可靠完成的范围时，它才值得投入成本。

## 4. Preflight Negotiation 机制

### Sprint Contract 模式

这是 Anthropic 实现 preflight negotiation 的核心机制：

```
Generator 提案 → Evaluator 审查 → 迭代协商 → 达成 contract → 开始实现
```

**Contract 内容**:
- 本 sprint 要构建什么
- 成功的验证标准（可测试的行为）
- Sprint 3 的例子有 27 个标准覆盖 level editor

**通信方式**: 文件交换（不是对话）。一个 agent 写文件，另一个读取并在该文件中回应或创建新文件。

### Feature List 作为全局 Contract

Initializer agent 创建的 feature list 充当全局 contract：
- 200+ features，每个初始标记为 "failing"
- 使用 JSON 格式（模型不太可能不当修改 JSON vs Markdown）
- 强措辞指令: "It is unacceptable to remove or edit tests"
- Coding agent 只能修改 `passes` 字段

```json
{
  "category": "functional",
  "description": "New chat button creates a fresh conversation",
  "steps": [
    "Navigate to main interface",
    "Click the 'New Chat' button",
    "Verify a new conversation is created"
  ],
  "passes": false
}
```

## 5. Hard Evaluator Thresholds

### 前端设计评估标准

四个评分维度，权重不等：

| 维度 | 描述 | 权重 |
|------|------|------|
| **Design Quality** | 设计是否感觉像一个连贯的整体？颜色、排版、布局、图像是否组合创造出独特的情绪和身份？ | 高 |
| **Originality** | 是否有自定义决策的证据？还是模板布局、库默认值、AI 生成模式？ | 高 |
| **Craft** | 技术执行：排版层次、间距一致性、颜色和谐、对比度 | 低（默认已足够好） |
| **Functionality** | 独立于美学的可用性 | 低（默认已足够好） |

**硬阈值机制**: 每个标准有硬阈值，任一标准低于阈值则 sprint 失败，Generator 收到详细反馈。

### 全栈编码评估标准

适配为覆盖四个维度：
- Product depth（产品深度）
- Functionality（功能性）
- Visual design（视觉设计）
- Code quality（代码质量）

### Evaluator 校准方法

- 使用 **few-shot examples** 配合详细评分分解来校准
- 确保 evaluator 的判断与人类偏好对齐
- 减少跨迭代的评分漂移
- 需要多轮调优循环：读 evaluator 日志 → 找到判断偏差 → 更新 prompt

### 评估中的非确定性处理

- **pass@k**: 在 k 次尝试中至少一次成功的概率（适合"找到一个解就行"的场景）
- **pass^k**: 所有 k 次尝试都成功的概率（适合需要一致性的场景）
- k=1 时两者相同；k=10 时讲述相反的故事

## 6. Long-Running Runtime 设计

### 核心问题

Agent 必须在离散 session 中工作，每个新 session 开始时没有之前的记忆。想象一个轮班制的软件项目，每个新工程师到达时对上一班发生的事情毫无记忆。

### 两个关键失败模式

1. **一次性尝试过多**: Agent 试图 one-shot 整个应用，context 用尽时 feature 半完成且无文档
2. **过早宣布完成**: 看到已有进展后，agent 宣布工作完成

### 解决方案: Initializer + Coding Agent

**Initializer Agent** (首次 session):
- 设置 `init.sh` 脚本
- 创建 `claude-progress.txt` 进度日志
- 初始 git commit
- 展开 feature list

**Coding Agent** (后续每个 session):
1. `pwd` 确认工作目录
2. 读 git log 和 progress file 了解最近工作
3. 读 feature list，选择最高优先级未完成 feature
4. 运行 `init.sh` 启动开发服务器
5. 基础端到端测试确认应用未损坏
6. 实现一个 feature
7. 自验证 feature
8. git commit + progress update

### Context 管理策略

**Context Reset vs Compaction**:
- **Compaction**: 总结早期对话，同一 agent 继续。保持连续性但不消除 context anxiety
- **Context Reset**: 完全清除 context window，启动新 agent + 结构化 handoff。提供干净起点，但需要 handoff artifact 有足够状态

Sonnet 4.5 表现出强烈的 "context anxiety"（接近 context 限制时过早收尾），compaction 不够，必须用 context reset。
Opus 4.5/4.6 基本消除了这个行为，可以用 SDK 的自动 compaction 处理。

### Durable State 结构

**进度文件** (`claude-progress.txt`):
- Agent 完成工作后写入摘要
- 下一个 agent 启动时首先读取
- 配合 git history 提供完整上下文

**Feature List** (JSON):
- 全局任务清单，每个 feature 有 passes 状态
- Agent 只能修改 passes 字段
- 充当跨 session 的 ground truth

**Git**:
- 每个有意义的变更都 commit
- 描述性 commit message
- 允许 revert 坏的代码变更
- 恢复工作状态

## 7. 多 Agent 研究系统设计

### 来源
"How we built our multi-agent research system" (2025-06-13)

### Orchestrator-Worker 模式

- **Lead Agent**: 分析查询，制定策略，生成 subagent
- **Subagents**: 并行探索不同方面，各自有独立 context window
- **CitationAgent**: 处理文档和研究报告，标注引用来源

### 关键设计原则

1. **教 orchestrator 如何委派**: 每个 subagent 需要目标、输出格式、工具/来源指导、清晰的任务边界
2. **按查询复杂度缩放**: 简单查询 1 agent + 3-10 tool calls；复杂研究 10+ subagents
3. **工具设计至关重要**: 工具描述质量直接影响 agent 行为
4. **让 agent 改进自己**: Claude 4 模型可以诊断 prompt 失败并建议改进
5. **先广后窄**: 先用短、宽泛的查询探索，再逐步缩小焦点

### Token 使用分析

- Agent 通常使用 chat 交互的 4x token
- Multi-agent 系统使用 chat 的 15x token
- Token 使用量单独解释了 BrowseComp 评估中 80% 的性能方差

### 生产可靠性

- **Agent 是有状态的，错误会复合**: 需要 durable execution + 错误处理
- **Rainbow deployments**: 渐进式流量切换，避免中断运行中的 agent
- **Subagent 输出到文件系统**: 减少"电话游戏"效应，避免信息在多阶段处理中丢失

## 8. Context Engineering 策略

### 来源
"Effective context engineering for AI agents" (2025-09-29)

### Context 作为有限资源

- Context rot: 随着 token 增加，模型准确回忆信息的能力下降
- n² 成对关系: transformer 架构中每个 token 关注每个其他 token
- 性能梯度而非硬悬崖: 模型在长 context 下仍然高度能力，但精度降低

### 三种长期 Context 管理技术

| 技术 | 适用场景 | 机制 |
|------|---------|------|
| **Compaction** | 需要大量来回的任务 | 总结 context window 内容，用摘要重新初始化 |
| **Structured Note-taking** | 有明确里程碑的迭代开发 | Agent 定期写笔记到 context window 外的持久存储 |
| **Sub-agent Architecture** | 需要并行探索的复杂研究 | 专门的 sub-agent 在干净 context 中处理聚焦任务 |

### Just-in-time Context 策略

- 维护轻量级标识符（文件路径、查询、链接）
- 运行时动态加载数据
- 渐进式披露: agent 通过探索逐步发现相关 context
- 混合策略: 部分数据预取 + 自主探索

## 9. 基础 Workflow 模式分类

### 来源
"Building effective agents" (2024-12-19)

Anthropic 将 agentic 系统分为 **Workflows**（预定义代码路径编排）和 **Agents**（LLM 动态指导自身过程）。

| 模式 | 描述 | 适用场景 |
|------|------|---------|
| **Prompt Chaining** | 任务分解为顺序步骤，每步 LLM 处理上一步输出 | 可清晰分解为固定子任务的场景 |
| **Routing** | 分类输入，导向专门的后续任务 | 有明确类别且需要分别处理的复杂任务 |
| **Parallelization** | 同时处理任务的不同方面（Sectioning/Voting） | 可并行的子任务，或需要多视角的高置信度结果 |
| **Orchestrator-Workers** | 中央 LLM 动态分解任务，委派给 worker | 无法预测子任务的复杂任务 |
| **Evaluator-Optimizer** | 一个 LLM 生成，另一个评估反馈，循环迭代 | 有明确评估标准且迭代改进有可衡量价值的场景 |

**PGE 直接对应 Evaluator-Optimizer 模式**，但扩展为三角色（加入 Planner）。

## 10. Eval 设计最佳实践

### 来源
"Demystifying evals for AI agents" (2026-01-09)

### Eval 结构

- **Task**: 单个测试，有定义的输入和成功标准
- **Trial**: 对 task 的一次尝试（因模型非确定性需多次 trial）
- **Grader**: 评分逻辑（code-based / model-based / human）
- **Transcript**: trial 的完整记录
- **Outcome**: 环境中的最终状态

### 三类 Grader

| 类型 | 优势 | 劣势 |
|------|------|------|
| **Code-based** | 快速、便宜、客观、可复现 | 对有效变体脆弱，缺乏细微差别 |
| **Model-based** | 灵活、可扩展、捕捉细微差别 | 非确定性、更贵、需要校准 |
| **Human** | 金标准质量、匹配专家判断 | 昂贵、慢、需要规模化专家 |

### 关键建议

- **评估结果而非路径**: Agent 经常找到 eval 设计者未预料的有效方法
- **建立部分学分**: 正确识别问题但未完成退款的 agent 明显优于立即失败的
- **0% pass@100 通常意味着 task 有 bug**，不是 agent 无能
- **从 20-50 个 task 开始**，不要等到有数百个才开始

## 11. 对 PGE 改建最有价值的设计点

### 11.1 三角色分离是核心架构

Anthropic 的实验明确证明：Generator 自评不可靠。分离 Evaluator 是关键杠杆。PGE 的 P/G/E 分离方向正确。

### 11.2 Sprint Contract 协商机制

这是 PGE preflight negotiation 的直接参考：
- Generator 提案 → Evaluator 审查 → 迭代 → 达成 contract → 实现
- 通信通过文件（不是对话），减少 token 消耗
- Contract 包含可测试的验证标准

### 11.3 Hard Threshold 而非宽松 PASS

Evaluator 必须有硬阈值。Anthropic 的经验：
- 开箱即用的 Claude 是糟糕的 QA agent
- 会识别问题然后说服自己"不是大问题"
- 需要多轮调优才能让 evaluator 合理评分
- 明确惩罚 AI slop 模式

### 11.4 Feature List 作为 Durable Ground Truth

JSON 格式的 feature list 充当跨 session 的 ground truth：
- 每个 feature 有 passes 状态
- 强措辞防止 agent 修改测试本身
- JSON 比 Markdown 更不容易被不当修改

### 11.5 Context Reset > Compaction（对某些模型）

对于表现出 context anxiety 的模型，完全 reset + 结构化 handoff 优于 compaction。PGE 的 round 机制应该支持两种模式。

### 11.6 Incremental Progress 是关键

一次只做一个 feature。这解决了 agent 试图一次做太多的倾向。每个 session 结束时留下干净状态。

### 11.7 Harness 组件需要持续验证

每个 harness 组件编码了对模型能力不足的假设。随着模型进步，需要：
- 逐个移除组件测试影响
- 剥离不再承重的部分
- 添加新组件以实现之前不可能的能力

### 11.8 End-to-End 测试不可替代

Claude 倾向于标记 feature 为完成但未做端到端测试。提供浏览器自动化工具（Playwright MCP）后性能显著提升。Agent 能识别和修复仅从代码看不出的 bug。

## 12. 引用来源

| 文章 | 发布日期 | URL |
|------|---------|-----|
| Building effective agents | 2024-12-19 | https://www.anthropic.com/engineering/building-effective-agents |
| Raising the bar on SWE-bench Verified | 2025-01-06 | https://www.anthropic.com/engineering/swe-bench-sonnet |
| How we built our multi-agent research system | 2025-06-13 | https://www.anthropic.com/engineering/multi-agent-research-system |
| Effective context engineering for AI agents | 2025-09-29 | https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents |
| Effective harnesses for long-running agents | 2025-11-26 | https://www.anthropic.com/engineering/effective-harnesses-for-long-running-agents |
| Demystifying evals for AI agents | 2026-01-09 | https://www.anthropic.com/engineering/demystifying-evals-for-ai-agents |
| Harness design for long-running application development | 2026-03-24 | https://www.anthropic.com/engineering/harness-design-long-running-apps |
| Best Practices for Claude Code | (docs) | https://www.anthropic.com/engineering/claude-code-best-practices |
