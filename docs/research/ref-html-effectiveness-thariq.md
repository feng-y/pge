# 调研：HTML as Agent Output Format (Thariq/Anthropic)

来源：Thariq Shihipar / Anthropic Blog, "Using Claude Code: The unreasonable effectiveness of HTML" (published 2026-05-20)
记录日期：2026-05-21

---

## 核心论点

Markdown 的核心优势是"易于人工编辑"，但当人越来越少直接编辑 agent 产出时，这个优势消失了。HTML 提供更高信息密度、更好可读性、更易分享、双向交互。

## 关键观察

1. Markdown 的优势是简单、可编辑、便携；但当 agent 产物主要由人阅读、分享、审阅或再次交给 agent 修改时，HTML 的信息密度和可读性更重要。
2. HTML 的核心价值不是"更漂亮的 Markdown"，而是能表达表格、CSS 设计信息、SVG、脚本交互、工作流、空间数据、图片和本地编辑界面。
3. "Copy as prompt / copy as JSON / copy diff" 模式是关键闭环：人可以在 HTML 中调整，再把结果带回 Claude Code 或提交到文件。
4. 多方案探索、PR/代码审查、设计原型、研究报告、交互式解释器、一次性配置/提示词/票据编辑器都适合 HTML。
5. Claude Code 的优势是可摄取文件系统、MCP、浏览器和 git history；HTML artifact 应该能综合这些上下文，而不只转换单个 Markdown 文件。
6. 版本控制仍是 HTML 最大痛点之一，核心 PGE pipeline contract 不应因此改成 HTML。

## 对 PGE 的适用性分析

| 场景 | 适合 HTML？ | 原因 |
|------|------------|------|
| 核心 pipeline artifacts (research.md, plan.md) | 否 | 需要被下游 skill 机器解析 |
| Final Response / 用户汇报 | 可选 | 人读的，HTML 更直观 |
| pge-handoff restore 展示 | 可选 | 恢复上下文时视觉化有帮助 |
| 复杂 plan 的人工审阅 | 可选 | 5+ issues 的 plan 用 HTML 更易读 |
| exec manifest / run 结果 | 可选 | dashboard 式展示比 Markdown 表格好 |
| learnings.md | 否 | 需要被 grep/搜索 |
| 一次性编辑界面（prompt/config/tickets/dataset） | 是 | HTML 控件 + copy/export 能把人类选择带回 agent |
| 多源代码/PR/研究解释器 | 是 | 可以把文件系统、git history、MCP/browser context 合成可读 artifact |

## 结论

**已采纳为 `pge-html` support surface，而不是 pipeline format replacement。** PGE 的 skill-to-skill artifact 仍保持 Markdown，因为它们需要 greppable、diffable、稳定地被下游 skill 消费。HTML 用于人类理解、审阅、分享、参与和一次性编辑。

**落地原则：**
- `pge-html` 不是 Markdown-to-HTML converter；输入是 source material，输出是 task-specific cognition surface。
- 不做 Markdown 机械转译；先定义 cognitive job，再重建信息架构。
- 长计划、复杂 review、run dashboard、PR writeup、feature explainer、multi-source report 应优先生成 HTML cognition tool。
- 面向选择/编辑的 HTML 必须带 copy/export，把人类决策带回 Claude Code 或 repo。
- HTML artifact 应该携带足够 provenance 和 orientation，方便离开当前对话分享。
- 对执行语义/数据变换类文档，不能按原始章节顺序搬运。失败信号是：HTML 虽然有组件、tabs、diagram，但读者仍必须按 Markdown 原顺序读完整篇才能建立主模型。

**listwise raw-data-to-tensor 反例总结：**
- 更好的 cognitive job 不是"阅读 listwise 文档"，而是"理解最终送模矩阵中一个 `(group_idx, position_idx)` 的值如何形成"。
- 首屏应该直接回答 request -> group -> `[G,L]` -> user/item/seq/mask -> Galaxy，而不是先铺术语表和原文章节。
- 核心交互面应是共同骨架、四类输入切换器、gen/non-gen 对照；代码锚点、边界条件、例子、返回值解释降为二级 drilldown。
- 判断标准：首屏能建立主心智模型才是 artifact；只是改变信息层级和组件但沿原文 heading 走，仍是转换。

**后续方向：**
- pge-exec 完成后，可选生成一个 HTML dashboard（run 结果可视化）
- pge-plan 的 Outside Voice review 可以产出 HTML 格式的 review report
- pge-handoff restore 可以生成 HTML 状态页
- 对复杂 plan/review/run 自动提供"generate HTML view"提示，但不自动替代 canonical artifact。

## 对 PGE 设计的间接验证

- "100 行以上的 Markdown 没人读" → PGE 的 SKILL.md 控制在 200-270 行，details 在 references/（progressive disclosure）
- "先探索多方案再深入一个" → pge-research 的 options + recommendation 模式
- "验证 agent 用 HTML specs 作为全局视角" → pge-exec 的 Evaluator 读 plan 作为 ground truth
- "HTML 作为本地编辑器" → pge-html 的 editor templates 必须具备 copy/export surface
