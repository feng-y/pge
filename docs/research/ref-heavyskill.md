# HeavySkill Study for PGE

> 来源: arxiv:2605.02396 + github.com/wjn1996/HeavySkill
> 调研日期: 2026-05-07
> 调研目的: 理解 HeavySkill 的 parallel reasoning + sequential deliberation 机制，及其对 agentic harness 设计的启示

---

## Study Goal

理解 HeavySkill 作为一种 test-time scaling 技术，如何将"重度思考"定义为 agentic harness 中的最小执行单元和模型内化技能。重点关注其两阶段 pipeline 设计、与外部编排的关系、以及 RL 可扩展性。

## Original Context

- 论文: "HeavySkill: Heavy Thinking as the Inner Skill in Agentic Harness" (Wang et al., 2026-05-04)
- 作者: Jianing Wang, Linsen Guo, Zhengyu Chen, Qi Guo, Hongyu Zang, Wenjie Shi, Haoxiang Ma, Xiangyu Xi, Xiaoyu Li, Wei Wang, Xunliang Cai
- 背景: 当前 agentic harness 通过复杂编排（多 agent、memory、skill、tool use）在复杂推理任务上取得成功，但真正驱动性能的底层机制被系统设计的复杂性遮蔽了

## What Problem It Solves

1. **归因模糊**: 复杂 agentic 系统中，性能提升到底来自编排层还是模型自身推理能力？HeavySkill 论证是后者
2. **编排脆弱性**: 外部编排层增加复杂度、故障点和工程开销，但可能不是性能的主要贡献者
3. **Best-of-N 的局限**: 传统 BoN（多次采样取多数投票）没有利用跨轨迹的交叉验证和批判性综合
4. **推理深度不可学习**: 传统方法中推理的深度和宽度是固定的超参数，不是可训练的能力

## Core Mechanisms

### 两阶段 Pipeline

```
User Query
    │
    ▼
┌─────────────────────────────────┐
│  Stage 1: Parallel Reasoning    │
│  生成 K 条独立推理轨迹           │
│  (temperature=1.0, 完全独立)     │
│  过滤退化/重复响应               │
└─────────────┬───────────────────┘
              │
              ▼
┌─────────────────────────────────┐
│         Memory Cache            │
│  存储 & 组织 K 条轨迹            │
│  支持 random/max_diversity 选择  │
└─────────────┬───────────────────┘
              │
              ▼
┌─────────────────────────────────┐
│  Stage 2: Sequential            │
│  Deliberation                   │
│  - 分析答案分布                  │
│  - 交叉验证推理链                │
│  - 识别逻辑错误                  │
│  - 批判性综合最终答案            │
│  (可选: 迭代 refinement)         │
└─────────────┬───────────────────┘
              │
              ▼
         Final Answer
```

### 关键参数

| 参数 | 默认值 | 含义 |
|------|--------|------|
| `reason_k` | 8 | 并行推理轨迹数 |
| `summary_k` | 4 | 审议采样数 |
| `iterations` | 1 | 迭代轮数 |
| `reason_temperature` | 1.0 | 推理多样性 |
| `summary_temperature` | 0.7 | 审议确定性 |
| `max_trajectory_tokens` | 80000 | 轨迹 token 预算 |

### 双模式交付

| 模式 | 形态 | 适用场景 |
|------|------|----------|
| Workflow | Python async pipeline + CLI | 批量评估、研究实验 |
| Skill | 纯 markdown prompt 文件 | Claude Code / agentic harness 中交互使用 |

### Skill 模式执行协议

在 Claude Code harness 中:
1. 识别问题 → 提取核心推理任务
2. 用 Agent tool 并行启动 K=3 独立推理 agent（单条消息多 tool call）
3. 收集所有 agent 输出
4. **自己执行审议**（不委托此步骤）
5. 输出综合最终答案

### 审议的核心原则

- 多数共识是信号但不是证明
- 少数答案如果有严格逻辑支撑可能是正确的
- 所有轨迹可能都错 — 准备从错误中重新推理
- 审议是综合，不是投票

## Design Principles

1. **内化优于外化**: 推理能力应存在于模型参数中，而非脆弱的外部脚手架
2. **最小执行单元**: heavy thinking 是编排 harness 中的原子工作单元；其他一切是路由
3. **先并行后聚合**: 基本推理模式是探索多路径然后综合
4. **RL 可扩展**: 推理的深度/宽度不是固定的；可以通过强化学习训练扩展
5. **Harness 无关**: 该技能在任何编排框架之下运行，具有可组合性
6. **独立性关键**: 并行 agent 必须不共享上下文或看到彼此的工作
7. **多样性有益**: 鼓励跨 agent 使用不同问题解决策略

## Strengths

1. **清晰的理论透镜**: 提供了理解为什么某些 agentic 系统比其他系统更好的框架
2. **模型内部推理可匹配外部编排**: 证明了不需要复杂多 agent 编排也能达到同等或更好效果
3. **具体的训练路径**: 通过 RL 提升推理深度，不增加系统复杂度
4. **强模型受益更多**: 暗示该方法随模型能力提升而 scale
5. **双模式设计**: 既有研究用的 workflow pipeline，又有实践用的 skill prompt
6. **审议 > 投票**: 比简单 majority voting 更有效地利用多轨迹信息
7. **可迭代**: 审议结果可以反馈回 cache 进行多轮 refinement

## Failure Modes / Costs

1. **弱模型受益有限**: 论文明确指出强 LLM 受益更多，弱模型可能无法有效内化该技能
2. **计算成本**: 并行推理内部仍然消耗 token/compute；用推理成本换编排复杂度
3. **不透明性**: 内化推理比显式多 agent trace 更难检查/调试
4. **RL 训练不稳定**: 通过 RL 扩展引入 reward hacking、训练不稳定等挑战
5. **不替代 tool use**: 论文处理的是推理，不是工具调用或环境交互，后者仍需外部 harness
6. **适用域有限**: 主要验证在数学/STEM/代码竞赛等有明确正确答案的领域
7. **审议质量依赖轨迹质量**: 如果所有并行轨迹都走了同一个错误方向，审议也难以纠正
8. **token 预算压力**: K=8 轨迹 × 32K tokens = 256K tokens 仅用于 Stage 1

## What PGE Might Borrow

1. **"先并行后综合" 作为 phase 内部提效模式**: Generator 执行复杂实现时，可以并行生成多个方案再综合
2. **审议 ≠ 投票的原则**: Evaluator 评估时不应简单 pass/fail，而应交叉验证多个证据链
3. **独立性约束**: 并行 subagent 必须不共享上下文 — 这是获得多样性的前提
4. **Memory Cache 作为中间层**: 轨迹存储 + 选择策略的概念可用于 plan alternatives
5. **Skill 模式的 prompt 设计**: 纯 markdown 即可驱动复杂多 agent 协议
6. **迭代 refinement 的有界性**: 最多 2-3 轮迭代，不是无限循环

## What PGE Should Not Borrow

1. **"编排是脆弱的" 这个结论的全盘接受**: PGE 的编排解决的是 coordination 问题（谁做什么、何时交接），不是推理问题。HeavySkill 论证的是推理不需要编排，但 PGE 的 P/G/E 分工不是推理分工
2. **高 K 值的并行**: K=8 在 PGE 场景中 token 成本不可接受（PGE 处理的是完整实现任务，不是数学题）
3. **温度 1.0 的多样性策略**: 对代码实现任务，高温度产生的不是"不同方法"而是"不同错误"
4. **"模型内化一切" 的极端立场**: PGE 的 tool use、file I/O、test execution 不可能内化到模型参数中
5. **忽略 harness 的贡献**: 相关论文 (arxiv:2604.07236) 证明 harness 可以改变固定模型性能 6 倍。两者不矛盾但不应只取一边

## Potential PGE Relevance

- **Planner 阶段**: 当 plan 不确定时，可以用 parallel reasoning 生成多个 plan 方案，再用 deliberation 综合最优方案
- **Generator 阶段**: 对关键实现决策，可以并行探索 2-3 个实现路径（低 K 值），再选择最优
- **Evaluator 阶段**: 评估不应是单次 pass/fail，而应是多角度交叉验证后的综合判断
- **bounded subagent 并发**: HeavySkill 的 K=3 skill 模式正好是 PGE 可能需要的 bounded 并发规模
- **"审议是综合不是投票" 原则**: 直接适用于 Evaluator 的 verdict 生成逻辑

## Open Questions for Step 2

1. PGE 的 Planner 是否应该在 plan 不确定时自动触发 parallel reasoning？触发条件是什么？
2. **"可自答问题" 的 HeavySkill 化**: 当 Planner 遇到不确定但不需要问用户的问题时，是否应该用 parallel reasoning（多方案生成）+ deliberation（评分选择）来自行解决？这比阻塞等用户回答更高效
3. Generator 的 parallel exploration 应该用什么粒度？整个实现 vs 关键决策点？
4. Evaluator 的 "deliberation" 和当前的 verdict 生成有什么结构性差异？
5. HeavySkill 的 memory cache 概念是否可以用于 PGE 的 plan alternatives 存储？
6. 如何在 PGE 的 bounded round 约束下控制 parallel reasoning 的 token 成本？

---

## PGE Context Lens

| PGE 已知问题 | HeavySkill 相关性 |
|---|---|
| Planner plan 可能不完整/不确定/模糊 | parallel reasoning 可生成多个 plan 方案供审议 |
| P/G/E 可能需要 bounded subagent 并发提效 | HeavySkill skill 模式 K=3 正好是 bounded 并发 |
| 未细化实现细节不应都被当作 blocking question | parallel exploration 可以在不确定时前进而非阻塞 |
| Planner 缺少 issue/slice 划分逻辑 | 不直接相关 |
| grill-with-docs 高摩擦 | 不直接相关 |
