# Oh My OpenAgent (OMO) Study for PGE

> 来源: github.com/code-yeongyu/oh-my-openagent (原 oh-my-opencode)
> 调研日期: 2026-05-07
> 调研目的: 理解 OMO 的多模型编排、specialist agent 分工、ultrawork 执行模式、以及 hash-anchored edit 等机制

---

## Study Goal

理解 Oh My OpenAgent 作为一个多模型 agent 编排 harness，如何解决单 agent 的顺序瓶颈、模型专长路由、上下文膨胀、和编辑可靠性问题。重点关注其三层架构、category-based routing、和 discipline-first 执行哲学。

## Original Context

- 项目: Oh My OpenAgent (OMO)，前身 oh-my-opencode
- 作者: YeonGyu Kim (code-yeongyu)，160+ 贡献者
- 规模: 56K+ GitHub stars, 1.6M+ npm downloads
- 定位: OpenCode (terminal AI coding agent) 的多模型编排插件层
- 许可: SUL-1.0 (自定义许可)
- 注: Anthropic 曾因 OMO 的使用模式封锁 OpenCode 的 OAuth 访问

## What Problem It Solves

1. **模型专长浪费**: 单 agent 用一个模型做所有事，但不同模型擅长不同任务（逻辑、前端、调试、规划）
2. **顺序瓶颈**: 单 agent 一次只做一件事，复杂任务被串行化
3. **上下文窗口耗尽**: 复杂任务吹爆上下文限制
4. **编辑不可靠**: 标准 edit tool 在模型无法精确复现空白/内容时失败
5. **中断丢失进度**: 会话中断后工作丢失
6. **供应商锁定**: 被锁定在单一模型提供商

## Core Mechanisms

### 三层架构

```
┌─────────────────────────────────────────┐
│  Planning Layer                          │
│  Prometheus: 战略规划、用户访谈、范围确认  │
│  Metis: 计划验证和精炼                    │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  Orchestration Layer                     │
│  Sisyphus: 主编排 agent，解析需求、       │
│            委派 specialist、驱动完成      │
│  Atlas: 协调委派、验证结果                │
└─────────────────┬───────────────────────┘
                  │
                  ▼
┌─────────────────────────────────────────┐
│  Execution Layer (9+ specialist agents)  │
│  Hephaestus: 自主深度工作 (GPT-5.4)      │
│  Oracle: 架构 & 调试                     │
│  Librarian: 文档 & 代码搜索              │
│  Explore: 快速 codebase grep             │
│  Frontend: UI/UX specialist              │
│  Multimodal Looker: 视觉分析             │
└─────────────────────────────────────────┘
```

### Category-Based Model Routing

Sisyphus 委派时选择 **category** 而非 model。Harness 将 category 映射到 model:

| Category | 用途 | 示例模型 |
|----------|------|----------|
| `visual-engineering` | 前端、UI/UX | Gemini 3 Pro |
| `deep` | 自主研究 + 执行 | GPT-5.4 |
| `quick` | 单文件修改、typo | Grok Code |
| `ultrabrain` | 硬逻辑、架构决策 | Opus 4.5 High |

### Ultrawork Mode (`ulw`)

一个关键词触发完整系统:
- 并行后台执行
- LSP 集成
- 上下文管理
- 自动任务分解
- 自我纠正循环

### Hash-Anchored Edits (Hashline)

```
11#VK| function hello() {
12#WX| return "world";
13#YZ| }
```

每行带内容 hash 标签。编辑引用这些标签。如果文件自上次读取后改变，hash 不匹配则编辑被拒绝。

效果: 一个模型的编辑成功率从 6.7% 提升到 68.3%。

### Boulder System (会话恢复)

以 Sisyphus 神话命名 — 如果中断，工作从中断点精确恢复。

### Ralph Loop / ulw-loop

自引用执行循环，直到任务 100% 完成才停止。

### IntentGate

在分类或行动前分析用户真实意图，防止字面误解。

### Todo Enforcer

如果 agent 空闲，系统将其拉回任务。

## Design Principles

1. **有主见的默认值，零配置**: 安装后输入 `ultrawork` 即可。作者花了 $24K token 测试配置
2. **模型无关编排**: 没有单一提供商主导。系统按任务类别跨提供商路由到最佳模型
3. **纪律优于自由**: Agent 被约束。Sisyphus 不会半途而废。Todo Enforcer 防止空闲。系统设计为完成任务，不是探索
4. **默认并行执行**: 复杂任务被分解并跨 specialist agent 并发运行
5. **上下文卫生**: 每个 agent 只获得所需上下文。Skill-embedded MCP 防止上下文膨胀。分层 AGENTS.md 按目录限定上下文
6. **编辑可靠性优于速度**: Hash-anchored edit 牺牲一些吞吐量换取保证正确性
7. **恢复优先**: Boulder system 和会话恢复自动处理中断、上下文限制和 API 故障
8. **开放市场哲学**: "未来不是选一个赢家；是编排所有赢家"

## Strengths

1. **大规模社区验证**: 56K+ stars，证明了多模型编排的实际价值
2. **真正解决了多模型路由问题**: 用最少用户配置实现 category → model 映射
3. **Hash-anchored edit 是真正的创新**: 显著提升编辑可靠性
4. **Ultrawork 极低摩擦入口**: 一个词激活完整系统
5. **纪律执行哲学**: "Sisyphus 不会半途而废" — 系统级完成保证
6. **完整的 Claude Code 兼容**: 现有 hooks、commands、skills、MCPs 不受影响
7. **预算友好**: 支持 ChatGPT $20 + Kimi $19 + GLM $10 的组合

## Failure Modes / Costs

1. **ULW-loop 失控**: ultrawork 循环有时任务完成后不停止，持续烧 token
2. **Rate limit 敏感**: 并行 agent 命中多个提供商可能触发限流
3. **Missing tool_result**: 编排失败当 tool result 未正确返回
4. **Agent 加载失败**: OMO 和 OpenCode 版本不匹配时 agent 无法加载
5. **上下文窗口仍可能爆**: 尽管有上下文卫生特性，激进并行执行仍可能耗尽上下文
6. **成本**: 多个前沿模型并行运行很贵
7. **复杂度**: 系统有很多活动部件。出错时调试需要理解完整编排栈
8. **Anthropic 封锁**: Anthropic 因 OMO 使用模式封锁了 OpenCode 访问
9. **遥测默认开启**: 匿名遥测是 opt-out 而非 opt-in

## What PGE Might Borrow

1. **Category-based routing 概念**: 不直接选 agent，而是选 "任务类别"，由 harness 映射到具体执行者
2. **纪律执行哲学**: "不完成不停止" 的 bounded loop 概念 — PGE 的 Generator 可以借鉴
3. **Hash-anchored edit 的可靠性思路**: 对 Generator 的文件编辑操作，增加 staleness 检测
4. **IntentGate 概念**: 在 Planner 接收用户输入时，先分析真实意图再分类
5. **上下文卫生的分层设计**: 每个 agent 只加载所需上下文，不是全量
6. **Boulder system 的恢复思路**: PGE run 中断后的恢复机制

## What PGE Should Not Borrow

1. **多模型路由的复杂度**: PGE 运行在 Claude Code 内，模型选择由用户/平台决定，不是 PGE 的职责
2. **9+ specialist agent 的膨胀**: PGE 是 3-agent 架构（P/G/E），不应膨胀为 N-agent
3. **"一个词激活一切" 的魔法**: PGE 需要明确的 bounded round contract，不是隐式激活
4. **供应商套利策略**: PGE 不做模型选择，这是用户的决策
5. **Ralph loop 的无限执行**: PGE 的核心约束是 bounded round，不是 "直到完成"
6. **Claude Code 兼容层的工程**: PGE 已经是 Claude Code 插件，不需要兼容层
7. **Sisyphus 的 "永不放弃" 哲学**: 在 PGE 中，识别何时停止（blocker、scope creep）比永不放弃更重要

## Potential PGE Relevance

- **Orchestration vs Execution 分离**: OMO 的三层架构（Planning → Orchestration → Execution）与 PGE 的 P/G/E 有结构相似性，但 PGE 的 "main orchestrator" 是第四层
- **纪律执行**: Sisyphus 的 "不完成不停止" + Todo Enforcer 可以启发 Generator 的执行纪律
- **上下文卫生**: 每个 PGE agent 应该只加载其 phase 所需的 artifacts，不是全量 runtime state
- **恢复机制**: PGE 的 runtime-state.json 已经是恢复机制，但 OMO 的 boulder system 更自动化
- **编辑可靠性**: Generator 的文件编辑是高频操作，staleness 检测值得考虑

## Open Questions for Step 2

1. PGE 的 main orchestrator 是否应该有类似 IntentGate 的意图分析层？
2. Generator 是否需要 "不完成不停止" 的执行纪律，还是应该在 bounded round 内尽力而为？
3. PGE 的上下文传递是否应该更严格地按 phase 隔离（类似 OMO 的分层 AGENTS.md）？
4. PGE run 中断恢复是否需要比当前 runtime-state.json 更自动化的机制？
5. Hash-anchored edit 的思路是否适用于 PGE 的 plan artifact 版本控制？

---

## PGE Context Lens

| PGE 已知问题 | OMO 相关性 |
|---|---|
| P/G/E 可能需要 bounded subagent 并发提效 | OMO 的并行 specialist 模式是参考，但 PGE 的 K 应该很小 |
| P/G/E phase 内部可能需要 workflow nodes | OMO 的三层架构是一种 workflow node 组织方式 |
| Planner plan 可能不完整/模糊 | IntentGate 可以在 plan 前澄清意图 |
| grill-with-docs 高摩擦 | OMO 的 ultrawork 是低摩擦的反面案例，但牺牲了精确性 |
| 未细化实现细节不应都被当作 blocking question | OMO 的 "纪律执行" 哲学: 前进而非阻塞 |
