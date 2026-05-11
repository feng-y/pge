# 调研：HTML as Agent Output Format (Thariq/Anthropic)

来源：Thariq @trq212 "Using Claude Code: The Unreasonable Effectiveness of HTML" (2026-05-09)
日期：2026-05-11

---

## 核心论点

Markdown 的核心优势是"易于人工编辑"，但当人越来越少直接编辑 agent 产出时，这个优势消失了。HTML 提供更高信息密度、更好可读性、更易分享、双向交互。

## 关键观察

1. "我不会读超过 100 行的 Markdown 文件" — 验证了 progressive disclosure 的必要性
2. HTML 生成比 Markdown 慢 2-4x，但可读性收益值得
3. "Copy as prompt" 模式 — HTML 页面上的按钮可以把调参结果复制为下一步的 prompt
4. 用 HTML 做探索（多方案并排对比）比 Markdown 列表直观得多
5. 版本控制是 HTML 最大痛点（diff 杂乱）

## 对 PGE 的适用性分析

| 场景 | 适合 HTML？ | 原因 |
|------|------------|------|
| 核心 pipeline artifacts (research.md, plan.md) | 否 | 需要被下游 skill 机器解析 |
| Final Response / 用户汇报 | 可选 | 人读的，HTML 更直观 |
| pge-handoff restore 展示 | 可选 | 恢复上下文时视觉化有帮助 |
| 复杂 plan 的人工审阅 | 可选 | 5+ issues 的 plan 用 HTML 更易读 |
| exec manifest / run 结果 | 可选 | dashboard 式展示比 Markdown 表格好 |
| learnings.md | 否 | 需要被 grep/搜索 |

## 结论

**当前不改。** PGE 的 artifact 是 skill-to-skill 的机器接口，不是人类阅读物。Markdown 的机器可解析性比 HTML 的视觉表现力更重要。

**未来可能的方向：**
- pge-exec 完成后，可选生成一个 HTML dashboard（run 结果可视化）
- pge-plan 的 Outside Voice review 可以产出 HTML 格式的 review report
- pge-handoff restore 可以生成 HTML 状态页

这些都是锦上添花，不是核心 gap。优先级低于实际执行稳定性。

## 对 PGE 设计的间接验证

- "100 行以上的 Markdown 没人读" → PGE 的 SKILL.md 控制在 200-270 行，details 在 references/（progressive disclosure）
- "先探索多方案再深入一个" → pge-research 的 options + recommendation 模式
- "验证 agent 用 HTML specs 作为全局视角" → pge-exec 的 Evaluator 读 plan 作为 ground truth
