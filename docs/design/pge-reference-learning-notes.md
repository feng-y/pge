# PGE 参考学习笔记

> 日期: 2026-04-29
> 目的: 从 6 个参考项目中提取 PGE 可借鉴的具体设计点，明确学什么、不学什么、映射到哪个模块

---

## 1. Anthropic Harness

### 学什么

1. **Contract 协商机制** — Generator 提案 → Evaluator 审查 → 迭代 → 达成 contract → 实现。通信通过文件交换，不是对话。PGE 的 preflight 阶段已经实现了这个模式的雏形，但可以强化迭代协商的结构。

2. **强 Evaluator Gate，但不默认重评分** — Anthropic 证明了独立 Evaluator 很关键，也证明了模型会把问题最小化。PGE 应该学习的是“独立验收 + 明确 acceptance frame + anti-slop 规则”，而不是把每个任务都变成大评分矩阵。

3. **Feature List 作为 Durable Ground Truth** — JSON 格式的 feature list 充当跨 session 的 ground truth。Agent 只能修改 `passes` 字段，不能修改测试本身。JSON 比 Markdown 更不容易被不当修改。

4. **Context Reset > Compaction** — 对表现出 context anxiety 的模型，完全 reset + 结构化 handoff 优于 compaction。每个 session 结束时留下"干净状态"（适合合并到 main 的代码）。

5. **Evaluator 校准方法** — 用 few-shot examples 配合详细评分分解来校准 evaluator 判断。需要多轮调优循环：读 evaluator 日志 → 找到判断偏差 → 更新 prompt。

6. **pass@k / pass^k 非确定性处理** — pass@k（k 次中至少一次成功）适合"找到一个解就行"；pass^k（所有 k 次都成功）适合需要一致性的场景。k=1 时两者相同，k=10 时讲述相反的故事。

### 不学什么

1. **V2 移除 Sprint 构造** — Anthropic 在 Opus 4.6 上移除了 sprint 构造，因为模型原生能力足以处理长任务分解。PGE 的 bounded round 是有意的设计约束（proving 需要边界），不应因模型能力提升而移除。PGE 使用 "slice"（对应 `runtime-state-contract.md` 的 `active_slice_ref`）作为 run 内的有界工作阶段，这与 Anthropic 已移除的 sprint 构造在语义上不同：slice 是 PGE bounded proving 的固有需求，不是从 Anthropic 借鉴的概念。

2. **Initializer Agent** — Anthropic 用 Initializer 做环境设置和 feature list 展开。PGE 的 Planner 已经承担了这个角色的核心功能（round shaping），不需要额外的初始化角色。

3. **Playwright MCP 端到端测试** — Anthropic 用浏览器自动化做 UI 验证。PGE 是 proving/execution 框架，验证对象是合约和 artifact，不是 UI。

4. **Multi-agent 研究系统的 15x token 消耗模型** — PGE 是单线程 proving，不需要并行 subagent 探索。Token 效率比探索广度更重要。

### 学到 PGE 哪个模块里

| 设计点 | 目标模块 |
|--------|---------|
| 强 Evaluator Gate | `agents/pge-evaluator.md` — 增加紧凑验收面、mode-aware 输出、anti-slop 规则 |
| Contract 协商强化 | `skills/pge-execute/handoffs/preflight.md` — 强化迭代协商结构 |
| Feature List 作为 Ground Truth | `skills/pge-execute/contracts/round-contract.md` — acceptance_criteria 用 JSON 结构 |
| Evaluator 校准 | `skills/pge-execute/contracts/evaluation-contract.md` — 增加 compact verdict 样例和 anti-slop 规则 |
| Context Reset 模式 | `skills/pge-execute/runtime/persistent-runner.md` — round 间 context reset 策略 |
| pass@k 非确定性处理 | `skills/pge-execute/contracts/evaluation-contract.md` — verdict 一致性要求 |

### 为什么不复制整个项目

Anthropic Harness 是为 **长时间应用开发**（生成完整 web app）设计的。它的 Planner 做完整产品 spec 展开（200+ features），Generator 做多 sprint 代码实现，Evaluator 用 Playwright 做 UI 验证。PGE 的场景是 **有界证明运行**（一次一个 bounded round），Planner 只做 round shaping 不做产品规划，验证对象是合约和 artifact 而非 UI。复制整个 harness 会引入 PGE 不需要的产品规划层和 UI 验证层，同时丢失 PGE 的 bounded round 约束。

---

## 2. OpenSpec

### 学什么

1. **Delta Spec 机制** — change 中的 spec 不是完整重写，而是增量描述（ADDED/MODIFIED/REMOVED）。每种 delta 操作有明确的 archive 时合并语义。这对 PGE 的 contract 演进特别有价值：round contract 的修改可以用 delta 方式描述，而不是每次全量重写。

2. **Specs 与 Changes 的物理分离** — "当前真相"（specs/）和"提议修改"（changes/）是不同的目录。多个 change 可以并行存在而不冲突。PGE 可以将 contract baseline 和正在进行的 round amendment 类似分离。

3. **行为契约而非实现计划** — Spec 只描述可观察行为（GIVEN/WHEN/THEN），不包含实现细节。用 RFC 2119 关键词（SHALL/MUST/SHOULD/MAY）表达要求强度。每个 Requirement 必须有至少一个 Scenario。PGE 的 acceptance_criteria 可以借鉴这种结构化程度。

4. **Schema-driven 的 Artifact DAG** — Artifact 之间的依赖关系用 YAML schema 声明式定义（proposal → specs + design → tasks）。状态检测基于文件系统存在性。PGE 的 artifact 依赖关系可以声明式定义，而不是硬编码在 ORCHESTRATION.md 中。

5. **渐进式严格度（Progressive Rigor）** — 大多数 change 用 Lite spec（简短行为要求 + 验收检查），只有高风险 change 才用 Full spec。PGE 不是所有 proving run 都需要同等严格度的 contract。

6. **Archive 流程** — 归档时 delta specs 合并到主 specs，change 文件夹移到 archive/，所有 artifact 原样保留。PGE 的 round 完成后可以类似地将 round 产物归档并更新 baseline。

### 不学什么

1. **线性的 propose → apply → archive 流程** — OpenSpec 假设一个 change 从提议到实现到归档是相对线性的。PGE 的 proving run 有更复杂的状态转换（retry、partial success、escalation、return_to_planner），不能用线性流程建模。

2. **文本 diff 式的 delta merge** — OpenSpec 的 delta merge 基于 requirement 名称匹配和文本替换。PGE 的 contract 演进需要更结构化的 merge 语义（verdict 驱动的修改，不是文本替换）。

3. **面向人类的 slash command 交互模型** — OpenSpec 的核心场景是人类开发者通过 `/openspec` 命令与 AI 协作。PGE 的场景是 agent 自主执行 proving run，交互模型不同。

4. **无运行时状态** — OpenSpec 的状态完全基于文件系统存在性检测（BLOCKED → READY → DONE）。PGE 需要运行时状态（agent 执行状态、verdict 结果、round 进度），不能仅靠文件存在性。

5. **"Actions, not phases" 哲学** — OpenSpec 没有阶段门禁，可以随时回去修改任何 artifact。PGE 的 proving run 需要明确的阶段门禁（planner gate → preflight gate → generator gate → evaluator gate），因为 agent 的默认行为是跳过检查。

### 学到 PGE 哪个模块里

| 设计点 | 目标模块 |
|--------|---------|
| Delta Spec 机制 | `skills/pge-execute/contracts/round-contract.md` — contract amendment 格式 |
| Specs/Changes 分离 | `.pge-artifacts/` 目录结构 — baseline vs active round 分离 |
| 行为契约格式 (GIVEN/WHEN/THEN) | `skills/pge-execute/contracts/round-contract.md` — acceptance_criteria 结构 |
| Schema-driven Artifact DAG | `skills/pge-execute/runtime/artifacts-and-state.md` — artifact 依赖声明 |
| 渐进式严格度 | `skills/pge-execute/contracts/entry-contract.md` — 按任务风险选择 contract 严格度 |
| Archive 流程 | `skills/pge-execute/handoffs/route-summary-teardown.md` — round 归档和 baseline 更新 |

### 为什么不复制整个项目

OpenSpec 是为 **人类-AI 协作的 spec-driven 开发** 设计的。它的核心价值在于让人类和 AI 在写代码前对齐要构建什么，用 slash command 驱动交互。PGE 的场景是 **agent 自主执行有界证明运行**，交互模型完全不同。OpenSpec 的 "Actions, not phases" 哲学与 PGE 需要的严格阶段门禁直接冲突。复制整个项目会引入不适合 agent 自主执行的交互模型，同时丢失 PGE 需要的阶段门禁和运行时状态管理。

---

## 3. GSD (get-shit-done)

### 学什么

1. **文件即上下文的结构化体系** — 每个文件有明确角色（PROJECT.md=愿景、REQUIREMENTS.md=需求、ROADMAP.md=阶段、STATE.md=活状态、PLAN.md=任务、SUMMARY.md=结果）。上下文是链式传递的：每个阶段产出的 artifact 自动成为下一阶段的输入。PGE 的 artifact 体系可以借鉴这种明确的角色分工。

2. **Mandatory Initial Read** — 所有 agent 启动时，如果 prompt 包含 `<required_reading>` 块，必须先用 Read tool 加载列出的所有文件。这是硬性约束，不是建议。PGE 的 agent 启动时也应该强制加载关键上下文（round contract、state artifact）。

3. **双格式交接（JSON + Markdown）** — HANDOFF.json（机器可读的结构化状态）+ .continue-here.md（人类可读的上下文）。PGE 的 round 间交接可以借鉴这种双格式模式。

4. **Completion Markers** — 每个 agent 有明确的完成标记（`## PLANNING COMPLETE`、`## PLAN COMPLETE`）。Orchestrator 通过 regex 匹配检测完成状态。PGE 的 artifact gate 可以借鉴这种简单有效的完成检测机制。

5. **Blocking Constraints** — 通过失败发现的约束，恢复时必须理解。`.continue-here.md` 中有专门的 `BLOCKING CONSTRAINTS` section，严重性分级（blocking/advisory）。PGE 的 retry/return_to_planner 路由可以携带类似的 blocking constraints。

6. **Context Budget 分级** — 根据 context window 大小和使用率调整行为。PEAK(0-30%)=全功能、GOOD(30-50%)=正常、DEGRADING(50-70%)=节约、POOR(70%+)=紧急 checkpoint。PGE 的 multi-round 运行需要类似的 context 健康监控。

7. **Fresh Context Per Agent** — 每个 subagent 获得干净的 200K context window。Orchestrator 永远不做重活，只负责加载上下文、spawn agent、收集结果、路由下一步。PGE 的 Agent Team 模式天然支持这个模式。

### 不学什么

1. **完整的命令体系（86 skills）** — GSD 是一个完整的 workflow 工具，有从项目初始化到部署的全流程命令。PGE 不是 workflow 工具，不需要复制命令体系。

2. **Wave Execution / 并行 agents** — GSD 的 plans 按依赖关系分组为 waves，wave 内并行执行。PGE 的 multi-round 是顺序的 proving 过程，不需要并行编排。

3. **Git 集成（atomic commits, branching）** — GSD 深度集成 git 工作流（每个 task 一个 atomic commit）。PGE 是 proving/evaluation 系统，git 集成不是核心关注点。

4. **Model Profiles（quality/balanced/budget）** — GSD 根据任务复杂度选择不同的模型配置。PGE 有自己的 evaluator 模型选择逻辑，不需要复制 GSD 的 profile 体系。

5. **Security Hardening（prompt injection 防护）** — GSD 有专门的安全加固机制。不是 PGE 当前阶段的关注点。

6. **Plan 的 XML 结构** — GSD 用 XML 格式定义 plan 中的每个 task（`<task type="auto">`）。PGE 的 contract 用 Markdown 格式，不需要引入 XML。

### 学到 PGE 哪个模块里

| 设计点 | 目标模块 |
|--------|---------|
| 文件即上下文体系 | `skills/pge-execute/runtime/artifacts-and-state.md` — artifact 角色明确化 |
| Mandatory Initial Read | `agents/pge-planner.md`, `agents/pge-generator.md`, `agents/pge-evaluator.md` — 启动时强制读取 |
| 双格式交接 | `skills/pge-execute/handoffs/` — 增加 JSON 格式的结构化交接 |
| Completion Markers | `skills/pge-execute/handoffs/` — 标准化 agent 完成标记 |
| Blocking Constraints | `skills/pge-execute/contracts/routing-contract.md` — retry/return 路由携带约束 |
| Context Budget 分级 | `skills/pge-execute/runtime/persistent-runner.md` — context 健康监控 |
| Fresh Context Per Agent | `skills/pge-execute/SKILL.md` — orchestrator 保持 thin |

### 为什么不复制整个项目

GSD 是一个 **完整的 AI 辅助开发 workflow 工具**，覆盖从项目初始化到部署的全流程。它的核心价值在于 context engineering（给 Claude Code 足够的上下文）和 roadmap-before-code（先规划再编码）。PGE 的场景是 **有界证明运行**，不是完整的开发流程。GSD 的 86 个命令、wave 并行执行、git 深度集成都是 PGE 不需要的。但 GSD 的 context 管理策略（文件即上下文、链式传播、fresh context per agent、context budget 分级）是 PGE 可以直接借鉴的基础设施模式。

---

## 4. gstack

### 学什么

1. **结构化 Review 维度** — gstack 将 review 压力结构化为具体的、可检查的维度（Architecture Review → Code Quality → Test Review → Performance Review）。每个维度有明确的评估项和产出要求。PGE 的 Evaluator 可以借鉴这种结构化评估维度，替代当前的叙述性判断。

2. **Confidence Calibration（置信度校准）** — 每个发现必须包含置信度分数（1-10）。9-10=通过阅读具体代码验证；7-8=高置信度模式匹配；5-6=中等，可能误报；3-4=低置信度，从主报告中抑制；1-2=推测，仅 P0 时报告。PGE 的 Evaluator verdict 可以附带置信度分数。

3. **"不允许模糊"原则** — 不说"处理错误"，要命名具体异常类；不说"有测试"，要画出覆盖率图；不说"可能有问题"，要给置信度分数。PGE 的 Evaluator 应该同样要求：不说"质量不够"，要指出具体哪个 acceptance criterion 未满足。

4. **Fix-First 机制** — 发现问题不是终点，修复才是。AUTO-FIX（机械性修复直接应用）vs ASK（需要人类判断的问题）。不存在"发现问题但不处理"的状态。PGE 的 RETRY verdict 可以借鉴这种分类：哪些问题 Generator 可以自动修复，哪些需要 return_to_planner。

5. **Shipping Gate vs Advisory 区分** — 只有 Eng Review 是 shipping gate（必须通过才能 ship），CEO Review/Design Review/Adversarial Review 都是可选的。PGE 应该同样区分必须通过的评估（gate）和有价值但可选的评估（advisory）。

6. **Scope Challenge（Step 0）** — 在深入 review 之前先做范围挑战：映射每个子问题到已有代码、最小变更集识别、复杂度检查（>8 文件或 >2 新类 = 代码异味）。PGE 的 Planner 可以借鉴这种 scope 前置检测。

7. **Test Coverage 图（ASCII 覆盖率图）** — 不是问"有没有测试"，而是画出完整的执行图，然后逐个分支检查覆盖。缺口无处可藏。PGE 的 Evaluator 可以用类似的覆盖率图来可视化 acceptance criteria 的覆盖情况。

### 不学什么

1. **交互式问答流程** — gstack 的 review 是高度交互式的（每个 issue 一个 AskUserQuestion）。PGE 的 proving run 是自动化的，不适合这种交互模式。PGE 需要的是自动化的评估标准，不是交互式的问答。

2. **代码级别的检查清单** — gstack 的 checklist.md 是针对具体编程模式的（SQL 注入、N+1 查询、XSS）。PGE 的评估对象是合约和证明运行，不是代码。需要设计自己的检查清单。

3. **Cross-model Adversarial Review** — gstack 用 Claude + Codex 做跨模型对抗 review（200+ 行 diff 触发 4 轮全面审查）。PGE 当前是单模型，跨模型对抗不是当前阶段的关注点。

4. **Scope Expansion/Reduction 模式** — gstack 的 CEO review 有 4 种范围模式（EXPANSION/SELECTIVE/HOLD/REDUCTION）。PGE 的评估不涉及范围决策，评估标准应该是固定的。

5. **Design/UX 维度** — gstack 的设计审查维度（信息架构、响应式、无障碍）不适用于 PGE 的合约评估场景。

6. **Telemetry/Analytics 基础设施** — gstack 的遥测、分析、学习系统是为长期使用设计的。PGE 的评估器不需要这些。

### 学到 PGE 哪个模块里

| 设计点 | 目标模块 |
|--------|---------|
| 结构化 Review 维度 | `agents/pge-evaluator.md` — 增加结构化评估维度 |
| Confidence Calibration | `skills/pge-execute/contracts/evaluation-contract.md` — verdict 附带置信度 |
| "不允许模糊"原则 | `agents/pge-evaluator.md` — 评估输出必须引用具体 criterion |
| Fix-First 分类 | `skills/pge-execute/contracts/routing-contract.md` — RETRY 路由携带修复分类 |
| Gate vs Advisory 区分 | `skills/pge-execute/contracts/evaluation-contract.md` — 评估维度分级 |
| Scope Challenge | `agents/pge-planner.md` — 增加 scope 前置检测步骤 |
| Coverage 图 | `agents/pge-evaluator.md` — acceptance criteria 覆盖率可视化 |

### 为什么不复制整个项目

gstack 是一个 **面向人类开发者的交互式 review 工具**，由 Y Combinator CEO 设计，强调 CEO/founder 视角的产品审查。它的核心价值在于结构化的 review 压力和交互式问答。PGE 的场景是 **自动化的 agent 评估**，不需要交互式问答，也不需要 CEO/Design/Adversarial 多层 review。但 gstack 的结构化评估维度、置信度校准、"不允许模糊"原则是 PGE Evaluator 可以直接借鉴的评估方法论。

---

## 5. Superpowers

### 学什么

1. **HARD-GATE: 设计未批准不得实现** — 用 hard gate 强制 agent 在动手前停下来思考和澄清。这不是建议，是强制流程。PGE 的 preflight 阶段已经实现了类似的 gate，但 Superpowers 的 anti-pattern 防护表（封堵 agent 跳过流程的借口）值得借鉴。

2. **Anti-Pattern 防护表** — 明确列出 agent 常见的跳过设计的借口并逐一封堵："This is too simple to need a design"→每个项目都走流程；"I need more context first"→skill check 在澄清之前；"Let me explore first"→skill 告诉你怎么探索。PGE 的 agent 定义可以增加类似的 anti-pattern 防护。

3. **Spec 自审 4 项 Checklist** — 写完 spec 后 agent 自己做四项检查：Placeholder 扫描（TBD/TODO？）、内部一致性（各部分是否矛盾？）、Scope 检查（是否聚焦到可以用单个 plan 实现？）、歧义检查（需求是否可以有两种解读？）。PGE 的 Planner 产出 round contract 后可以做类似的自审。

4. **一次一个问题 + 优先选择题** — 降低用户认知负担，提高澄清效率。不用多问题轰炸用户。PGE 的 Planner 在处理 open_questions 时可以借鉴这种提问策略。

5. **Spec 是第一类公民** — 持久化到文件、commit 到 git，不是对话中的临时产物。有自审和用户审阅两道 gate。PGE 的 round contract 已经是文件级 artifact，但可以强化"两道 gate"模式（自审 + 外部审阅）。

6. **单向 Handoff 保证流程完整性** — brainstorming 只能转入 writing-plans，不能跳到任何实现 skill。这防止了"设计到一半就开始写代码"的问题。PGE 的阶段转换已经是单向的，但可以更明确地声明不允许的跳转。

### 不学什么

1. **Visual Companion（浏览器 mockup）** — PGE 是 proving/execution 框架，不涉及 UI mockup。

2. **Git Worktree 隔离** — PGE 当前是 docs/contracts skeleton，不需要 worktree 工作流。

3. **Subagent-Driven-Development** — PGE 有自己的 agent 调度模型（pge-execute），不需要复制 Superpowers 的 subagent 执行模式。

4. **TDD RED-GREEN-REFACTOR 强制** — PGE 当前阶段是设计/合约，不是代码实现。TDD 流程不适用。

5. **"Enthusiastic Junior Engineer" 假设** — Superpowers 假设执行者是"没有判断力的热情初级工程师"。PGE 的 Generator 是有 contract 约束的 proving agent，执行者模型不同。

6. **Skill 自动发现/安装机制** — PGE 不需要复制 plugin marketplace 体系。

7. **完整的 PR/Code Review 流程** — PGE 有自己的 evaluator/verdict 机制，不需要 Superpowers 的 PR review 流程。

### 学到 PGE 哪个模块里

| 设计点 | 目标模块 |
|--------|---------|
| HARD-GATE + Anti-Pattern 防护 | `agents/pge-generator.md` — 增加 anti-pattern 防护表 |
| Spec 自审 4 项 Checklist | `agents/pge-planner.md` — round contract 自审步骤 |
| 一次一个问题 + 选择题 | `agents/pge-planner.md` — open_questions 处理策略 |
| Spec 是第一类公民 | `skills/pge-execute/contracts/round-contract.md` — 已实现，强化两道 gate |
| 单向 Handoff | `skills/pge-execute/ORCHESTRATION.md` — 明确声明不允许的跳转 |
| Scope 前置检测 | `agents/pge-planner.md` — 在深入规划前先评估 scope |

### 为什么不复制整个项目

Superpowers 是一个 **"design before code" 的完整开发流程框架**，核心理念是强制 agent 在写代码前先退一步做设计。它的 brainstorming → spec → plan → execution 管线覆盖了从用户意图到代码实现的全流程。PGE 的场景是 **有界证明运行**，不需要完整的 brainstorming 流程（PGE 的输入已经是 bounded task，不是 raw intent）。Superpowers 的 TDD 强制、worktree 隔离、subagent 执行模式都是面向代码实现的，不适用于 PGE 的合约/证明场景。但 Superpowers 的 hard gate、anti-pattern 防护、spec 自审 checklist 是 PGE 可以直接借鉴的流程控制模式。

---

## 6. claude-code-best-practice DEVELOPMENT WORKFLOWS

### 学什么

1. **Vertical Phase 设计** — 每个 phase 端到端可验证，不做水平切片。Horizontal（先做所有 database → 所有 services → 所有 API）导致 1200 行代码后才发现不工作。Vertical（mock API → frontend → services → database → 集成）每个 checkpoint 可验证。PGE 的 multi-round 执行应该每轮端到端可验证。

2. **Instruction Budget 管理** — 前沿 LLM 只能可靠遵循 ~150-200 条指令。单个 prompt <40 条指令。用 control flow（多步骤）替代 prompt 内 control flow。PGE 的 skill/contract 指令总量需要控制。

3. **Static Artifact 作为 Context 锚点** — 所有重要信息写入 static markdown artifacts（design, structure, plan）。不依赖 built-in compaction。可以随时从 artifacts 恢复，不担心 autocompact 质量。PGE 的每轮产出写入文件，不依赖 context 内记忆。

4. **Rewind-First 纠错** — 纠正（"no, try B"）留下失败尝试污染 context。Rewind 回到失败前，用学到的知识重新 prompt。PGE 的 proving run 失败时应该回退到 checkpoint 重试，不在失败上下文中修补。

5. **Verification Skill 独立化** — Boris Cherny: "give Claude a way to verify its work — 2-3x quality"。Thariq 将 verification 提升为独立 skill 类型（signup-flow-driver, checkout-verifier）。PGE 的 Evaluator 已经是独立角色，但可以进一步将特定类型的验证抽象为可复用的 verification skill。

6. **Design → Structure → Plan 三层渐进** — Design discussion ~200 行（方向对齐）→ Structure outline ~2 页（"C header file" 级别）→ Plan（完整实现细节）。每层都是 review checkpoint。PGE 的 contract negotiation 可以借鉴这个渐进对齐模式。

7. **Context Rot 阈值** — 1M context model: ~300-400k tokens 开始 context rot。新手保持 <40%，到 60% 考虑收尾。老手激进保持 <30%。Autocompact 发生在模型最不智能的时刻 → 主动 /compact 带 hint 更好。PGE 的 multi-round 运行需要关注 context rot。

8. **五种 Turn 后选择** — Continue（同任务）、/rewind（走错路）、/compact（会话膨胀）、/clear + brief（新任务）、Subagent（大量中间输出只需结论）。PGE 的 round 间路由可以映射到这些选择。

### 不学什么

1. **Plugin/Marketplace 分发** — PGE 是单项目，不需要 skill 分发体系。

2. **MCP 集成（Slack, BigQuery, Sentry）** — PGE 不涉及外部服务集成。

3. **Agent Teams / tmux 并行** — PGE 当前是单线程 proving，不需要 tmux 并行编排。

4. **Ralph Wiggum Loop** — PGE 需要人类参与 gate，不适合全自主循环。

5. **Cross-Model Workflow（Claude + Codex 交叉验证）** — PGE 当前是单模型，跨模型验证不是当前阶段的关注点。

6. **PostToolUse hooks / auto-format** — 运行时工具链，不影响 PGE 合约设计。

7. **CRISPY 7 步完整流程** — PGE 不需要完整的 Questions → Research → Design → Structure → Plan → Work → Implement → PR 流程。但 "design discussion" 对齐步骤值得引入。

### 学到 PGE 哪个模块里

| 设计点 | 目标模块 |
|--------|---------|
| Vertical Phase 设计 | `skills/pge-execute/ORCHESTRATION.md` — 每轮端到端可验证 |
| Instruction Budget | `skills/pge-execute/SKILL.md` — 保持 ≤220 行限制；agent 定义控制指令数 |
| Static Artifact 锚点 | `skills/pge-execute/runtime/artifacts-and-state.md` — artifact 作为 context 恢复源 |
| Rewind-First 纠错 | `skills/pge-execute/contracts/routing-contract.md` — retry 路由回退到 checkpoint |
| Verification Skill 独立化 | `agents/pge-evaluator.md` — 已实现，可进一步模块化 |
| Design → Structure → Plan 渐进 | `skills/pge-execute/handoffs/preflight.md` — 渐进对齐模式 |
| Context Rot 阈值 | `skills/pge-execute/runtime/persistent-runner.md` — context 健康监控 |
| 五种 Turn 后选择 | `skills/pge-execute/contracts/routing-contract.md` — round 间路由映射 |

### 为什么不复制整个项目

claude-code-best-practice 是一个 **最佳实践汇编**，收集了 10+ 个主流 workflow 项目的经验和 Anthropic 工程师的实战建议。它不是一个可执行的框架，而是一组原则和模式。PGE 不需要复制它的全部内容（plugin 分发、MCP 集成、tmux 并行、cross-model workflow），但它提炼的核心原则（vertical phase、instruction budget、static artifact、rewind-first、verification 独立化）是 PGE 设计的重要参考。这些原则需要适配到 PGE 的 bounded proving run 场景中，而不是直接照搬。

---

## Cross-cutting Patterns

从 6 个参考项目中提取的共通模式：

### 1. 强制停顿（Forced Pause）

所有项目都有某种形式的"在动手前强制停下来"机制：
- **Anthropic**: Contract 协商（Generator 提案 → Evaluator 审查）
- **OpenSpec**: proposal → specs → design → tasks 的 DAG 依赖
- **GSD**: discuss-phase → plan-phase → execute-phase 的顺序约束
- **gstack**: Step 0 Scope Challenge（在 review 前先做范围挑战）
- **Superpowers**: HARD-GATE（设计未批准不得实现）+ anti-pattern 防护表
- **Best Practice**: Design → Structure → Plan 三层渐进

**PGE 映射**: preflight 阶段（`skills/pge-execute/handoffs/preflight.md`）已经实现了这个模式。可以强化 anti-pattern 防护和自审 checklist。

### 2. 文件即通信（File-based Communication）

所有项目都用文件系统作为 agent 间的通信介质，而不是依赖对话历史：
- **Anthropic**: "通信通过文件，一个 agent 写文件，另一个读取并回应"
- **OpenSpec**: specs/ 和 changes/ 目录结构
- **GSD**: PLAN.md → SUMMARY.md → VERIFICATION.md 链式传递
- **gstack**: Review Log + Readiness Dashboard 写入文件
- **Superpowers**: spec 文档持久化到文件、commit 到 git
- **Best Practice**: static markdown artifacts 作为 context 锚点

**PGE 映射**: `.pge-artifacts/` 目录和 handoff 文件已经实现了这个模式。这是 PGE 架构的核心原则之一。

### 3. 评估者独立性（Evaluator Independence）

多个项目强调评估者必须独立于执行者：
- **Anthropic**: "调优一个独立的 evaluator 使其持怀疑态度，比让 generator 对自己的工作保持批判性要容易得多"
- **gstack**: Outside Voice（完成所有 section 后调用另一个 AI 做独立 review）
- **Best Practice**: "separate context windows make results better" + "one agent can cause bugs and another can find them"
- **Superpowers**: Spec Reviewer 是独立的 subagent

**PGE 映射**: Evaluator 角色（`agents/pge-evaluator.md`）已经实现了独立性。关键是强化"不信任 Generator 叙述"的原则。

### 4. 明确验收面，而不是放大叙述（Make Acceptance Explicit）

多个项目都要求减少“凭感觉给 PASS”的空间，但做法不一定是大评分表：
- **Anthropic**: 强 Evaluator gate + few-shot 校准
- **gstack**: 明确置信与完整性信号
- **Best Practice**: 用 instruction budget 和 context 阈值防止评估面失控

**PGE 映射**: 当前 Evaluator 需要的不是默认重评分，而是更明确的 compact acceptance surface、anti-slop 规则和少量可复用示例。

### 5. Context 是有限资源（Context as Finite Resource）

所有项目都认识到 context window 的有限性并有应对策略：
- **Anthropic**: Context Reset > Compaction；递减边际收益
- **GSD**: Fresh Context Per Agent；Context Budget 分级（PEAK/GOOD/DEGRADING/POOR）
- **Best Practice**: Context Rot 阈值（300-400k tokens）；五种 Turn 后选择
- **Superpowers**: 每个 skill 有独立的完整生命周期

**PGE 映射**: `skills/pge-execute/runtime/persistent-runner.md` 需要增加 context 健康监控。Agent Team 模式天然提供 fresh context per agent。

### 6. 渐进式严格度（Progressive Rigor）

多个项目支持根据任务复杂度调整流程严格度：
- **OpenSpec**: Lite spec vs Full spec
- **gstack**: Eng Review（必须）vs CEO/Design/Adversarial Review（可选）
- **Anthropic**: Evaluator 的价值取决于任务是否在模型独立能力边界之外
- **Best Practice**: 简单任务 1 agent + 3-10 tool calls；复杂研究 10+ subagents

**PGE 映射**: `skills/pge-execute/contracts/entry-contract.md` 可以根据任务风险选择 contract 严格度。不是所有 proving run 都需要完整的 preflight + evaluator 流程。
