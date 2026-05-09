# PGE 全管线设计（基于 claude-code-best-practice 11 框架提炼）

## Context

设计完整的 PGE 管线：`pge-research → pge-plan → pge-exec`

现有实现（`/code/b/pge/skills/`）：pge-setup、pge-plan、pge-exec 已存在。需要新增 pge-research，并微调现有 skill 对接。

exec 自带 review（lightweight gates + self-review + evidence-summary）。独立的 pge-review/pge-ship 是未来考虑的事，当前不设计。

设计来源：claude-code-best-practice 追踪的 11 个框架 + aiworks researcher 模式。

设计哲学：
- "不信任但积累" — 每个阶段独立验证上游，每次验证的结论沉淀为下次输入。
- **最小化 Human In-The-Loop** — 整个 harness 的核心目标。每个阶段自主运转，人只在关键决策点介入。harness 进化方向：每次运行积累的知识（docs/config/patterns）让下次需要问人的更少。

---

## pge-research 详细设计

### 定位

pge-research 承担探索和结构化，产出 evidence brief + 多方案评估供 pge-plan 消费。借鉴 aiworks evidence package 模式（但允许推荐）+ RPI 多 agent 调研模式。

## 设计来源

| 框架 | 模式 | 借鉴点 |
|------|------|--------|
| aiworks/researcher.md | 证据包 + 置信度 + 硬限制 | 不做决策、code is truth、HIGH/MED/LOW |
| aiworks/research.md | 拆解子方向 → 并行 agent → 结构化报告 | 并行探索、结论先行 |
| addyosmani/idea-refine | 发散→收敛→锐化 | 先扩展可能性再收窄 |
| CE brainstorm | Socratic + 复合积累 | 一次一问 |
| superpowers brainstorm | 复杂度评估 → 自适应深度 | 轻重自适应 |
| grill-with-docs | 挑战术语 + 交叉验证代码 | 代码验证声明 |
| 现有 pge-plan | Planning Self-Evaluation | 自检框架可复用 |

核心提炼：**多 agent 并行调研 → 多方案产出 → 评估收敛**

### 从 claude-code-best-practice 提炼的 Research 阶段模式

11 个框架的 research/brainstorm 步骤：

| 框架 | Research 步骤 | 模式 |
|------|-------------|------|
| Superpowers (175k★) | `brainstorming` | 发散式探索，强制暂停 |
| Spec Kit (92k★) | `/speckit.clarify` → `/speckit.specify` | 先澄清再规格化 |
| gstack (88k★) | `/office-hours` | 对话式探索 |
| GSD (59k★) | `/gsd-discuss-phase` | 讨论阶段 |
| Matt Pocock (51k★) | `/grill-with-docs` | 领域术语挑战 + 代码交叉验证 |
| oh-my-claudecode (32k★) | `/deep-interview` | 深度访谈 |
| CE (16k★) | `/ce-ideate` → `/ce-brainstorm` | 构思 → 头脑风暴（两步） |
| RPI (best-practice 自建) | `/rpi:research` | 6 specialist agents 多阶段 |
| agent-skills (27k★) | `/spec` (idea-refine) | 发散→收敛→锐化 |

**关键发现**：
1. 所有框架都有 research 阶段，但重量差异巨大（从 grill-with-docs 的单轮到 RPI 的 6 agent）
2. 高星框架倾向轻量（Superpowers 的 brainstorming 是单 skill）
3. 多 agent 模式出现在 RPI（6 agents 串行）和 development-workflows（2 agents 并行）
4. 提问模式分两类：Socratic 一次一问（grill/deep-interview）vs 结构化提取（RPI requirement-parser）
5. CE 的两步分离（ideate vs brainstorm）暗示"发散"和"收敛"应该是独立动作

### RPI Research 的核心模式（最重参考）

```
Phase 1: 需求解析（requirement-parser agent）
Phase 2: 产品分析（product-manager agent）
Phase 2.5: 代码探索（Explore agent）— "CRITICAL: ensures based on actual code reality"
Phase 3: 技术可行性（senior-engineer agent）
Phase 4: 战略评估（CTO-advisor agent）— GO/NO-GO
Phase 5: 报告生成（documentation-writer agent）
```

产出：GO | NO-GO | CONDITIONAL GO | DEFER + 置信度 + 理由

### 提问模式提炼

从 claude-code-best-practice 的 Tips 和框架中提取：
- "start with a minimal spec and ask Claude to interview you using AskUserQuestion" (Thariq/Anthropic)
- "challenge Claude — grill me on these changes" (Boris/Anthropic)
- "knowing everything you know now, scrap this and implement the elegant solution" (Boris)
- Spec Kit 的 `/speckit.clarify`：先澄清再做任何事
- oh-my-claudecode 的 `/deep-interview`：深度访谈直到理解透彻

## 设计决策

### 核心学习对象

1. **Spec Kit `/speckit.clarify`** — 结构化歧义扫描 + 限量提问 + 推荐答案 + 即时集成
2. **Superpowers `brainstorming`** — 先探索上下文 + 2-3 方案 + self-review + hard gate

### 提问哲学

不是"先问再做"，是"先调研再问"。

| 情况 | 行为 |
|------|------|
| 结论明显（代码/文档能确认） | 不问，直接用，标注来源 |
| 不确定（多种合理解读） | 先调研评估，带证据 + 多方案让用户选 |
| 语义不理解（不知道用户说的是什么） | 直接问"X 是什么意思" |
| 能从代码回答 | 不问，自己看代码 |

**问题不是裸问，是调研后的带方案提问。** 每个问题必须包含：
- 调研发现（为什么这个问题重要）
- 2-3 个选项（每个带 pros/cons 或证据）
- 推荐（如果有倾向）

唯一例外：语义澄清可以直接问，不需要调研。

### 最小化 Human In-The-Loop

human in-the-loop 是最高成本操作。research 应尽可能自主完成。

| 优先级 | 情况 | 行为 |
|--------|------|------|
| 1 | 代码/文档能确认 | 自决，标注来源 |
| 2 | 有合理默认值 | 用默认值，标注假设 |
| 3 | 不确定但不阻塞 plan | 记录为 open question，不问 |
| 4 | 不确定且阻塞 plan | 带方案问（最后手段） |

只有第 4 种触发 human in-the-loop。其余全部自主处理。

### 内部执行管线

pge-research 的核心 loop：

```
探索（代码/文档） → 评估发现 → 形成结论或方案 → 需要时才问（带证据）
```

每一轮都走这个循环。明显的直接过，不确定的带方案问，语义不懂的直接问。

### 执行流程（从 speckit.clarify + brainstorming 提炼）

```
1. 探索项目上下文（brainstorming step 1）
   - 代码、文档、recent commits
   - .pge/config/* 如果存在

2. 结构化歧义扫描（speckit.clarify 的 taxonomy）
   - 扫描意图中的模糊点
   - 分类：功能范围、影响范围、约束、现有模式、术语、验收条件
   - 用作探索指引，不需要显式输出状态标记

3. 自主解决能解决的
   - Clear → 直接记录为 finding
   - 能从代码确认的 Partial → 探索代码，升级为 Clear
   - 有合理默认值的 → 用默认值，标注假设

4. 形成方案（brainstorming step 4: propose 2-3 approaches）
   - 对于核心问题，提出 2-3 个方案 + tradeoff + 推荐
   - 简单任务可能只有一个方案 + "proceed"

5. 仅对阻塞项提问（最后手段）
   - 带调研结果 + 方案选项
   - 一次一问
   - 最多 3 个问题（硬限制）

6. Self-review（brainstorming 的 spec self-review）
   - placeholder scan
   - 内部一致性
   - 范围检查
   - 歧义检查

7. 写 brief → .pge/research/<research_id>.md

8. Handoff → 建议 next_skill: pge-plan
```

**关键区别于旧设计**：
- 没有预设的 LIGHT/MEDIUM/DEEP 三档（Codex 批评：过早优化）
- 探索深度由实际发现驱动，不是预判
- 不预设 agent 数量，按需派发
- Synthesis 由 skill 自己做（读 agent 输出，写 options），不是独立 agent
- Agent 使用时机：跨多模块并行探索时用 Agent；单模块直接探索时自己做

### 歧义扫描维度（从 speckit.clarify 简化）

speckit.clarify 有 11 个维度，pge-research 只需要技术相关的：

| 维度 | 扫描什么 |
|------|----------|
| 功能范围 | 做什么、不做什么、边界在哪 |
| 影响范围 | 涉及哪些模块/文件/接口 |
| 约束 | 技术限制、兼容性、性能要求 |
| 现有模式 | 代码中已有的相关实现和约定 |
| 术语 | 用户说的词在代码中对应什么 |
| 验收条件 | 怎么判断做对了 |

不需要：产品分析、市场适配、UX 流程（那是产品层面，不是工程 harness）

### 方案产出格式

```markdown
## Options

### Option A: <name>
- Approach: <怎么做>
- Evidence: <为什么可行，来源>
- Tradeoff: <放弃什么>
- Effort: S | M | L

### Option B: <name>
...

## Recommendation
- Pick: Option <X>
- Why: <一句话>
```

简单任务只有一个 option + "proceed"。不强制多方案。

### 与 pge-plan 的接口契约

**信任哲学：Trust as-is + gate check**（所有 best-practice 框架的共识：下游不重做上游的活）

来源：6 个框架（speckit / superpowers / RPI / aiworks / pge-plan / GSD）无一重新验证上游内容。最接近的模型：
- RPI：固定路径文件 + verdict gate（GO/NO-GO）
- aiworks：trust but bounce-back（证据不足时退回要求补充）

**Gate check（plan 启动时）**：
1. `.pge/research/<id>.md` 存在？→ 不存在则正常运行（降级模式，现有行为不变）
2. `research_route` == `READY_FOR_PLAN`？→ `NEEDS_INFO` 或 `BLOCKED` 则停，提示用户
3. 有 `blocks_plan: yes` 的 open questions？→ 触发 plan 的 `BLOCK_PLAN`

**消费规则**：
| Brief Section | Plan 如何消费 | 信任级别 |
|---------------|--------------|----------|
| `## Intent` | 直接填充 plan 的 Intent section | as-is |
| `## Findings` | 作为 Repo Context 证据来源，可引用 | as-is（不重新验证） |
| `## Affected Areas` | 填充 plan 的 Target Areas | as-is |
| `## Constraints` | 填充 Assumptions / Non-goals | as-is |
| `## Options + Recommendation` | 采用推荐方案作为强默认值，跳过 Bounded Brainstorm | 强默认（除非 plan 分析发现偏离理由） |
| `## Assumptions` | 继承到 plan 的 Assumptions section | as-is |
| `## Open Questions (blocks_plan: no)` | 记录到 plan 的 Risks / Open Questions | 透传 |

**降级模式**（research brief 不存在时）：
- plan 正常运行，自己做 Explore + Brainstorm（现有行为不变）
- 不要求 research 作为前置条件

**pge-plan 的最小改动**：
- 在 "Read Setup Config" 步骤后增加：读取最新的 `.pge/research/*.md`（如果存在）
- 当 research brief 存在且 route == READY_FOR_PLAN 时：跳过或简化 step 3 (Explore) 和 step 4 (Brainstorm)
- 不改变 pge-plan 的产出格式

### Handoff（从 matt-skills 学习）

research brief 本身就是 handoff 文档。它包含下一个阶段需要的所有上下文，不重复已有 artifact（引用路径即可）。

### 与 `.pge/config/*` 的关系

- 存在时：读取 `docs-policy.md` 和 `repo-profile.md` 指导探索顺序
- 不存在时：直接探索 README/CLAUDE.md/代码
- 不要求 setup 作为前置条件

## Skill 结构

```
/code/b/pge/skills/pge-research/
├── SKILL.md              # 核心流程（~150-200 行）
└── references/
    └── examples.md       # 示例 brief（按需加载）
```

Progressive Disclosure：SKILL.md 放核心流程和 brief 模板，examples 按需加载。

## SKILL.md 设计要点

### Frontmatter

```yaml
---
name: pge-research
description: >
  Explore project context, scan for ambiguity, form options with evidence,
  and produce a research brief for pge-plan. Minimizes human interaction:
  explores code first, uses reasonable defaults, only asks when blocking.
  Use when: intent needs clarification, multiple approaches exist, or task
  touches unfamiliar code. Not for trivial fixes with obvious solutions.
argument-hint: "<topic or intent>"
allowed-tools:
  - Read
  - Write
  - Edit
  - Bash
  - Glob
  - Grep
  - Agent
---
```

### 核心流程（SKILL.md body 的结构）

1. 探索上下文
2. 歧义扫描（6 维度）
3. 自主解决能解决的（代码确认 / 合理默认值）
4. 形成方案（1-3 个 options + recommendation）
5. 仅对阻塞项提问（最多 3 个，带方案）
6. Self-review
7. 写 brief
8. Handoff

### Guardrails

- 不产出 plan 或 numbered issues
- 不写业务代码
- 不问能自己回答的问题
- 最多 3 个问题（硬限制），按 plan-blocking impact 优先级排序
- 每个问题必须带调研结果 + 选项
- 不要求 pge-setup 作为前置
- 探索有上界：findings 稳定或收益递减时停止，不穷举整个 codebase
- 范围膨胀检测：如果探索发现任务实际范围远大于用户描述，在 Findings 中标注并在 Options 中建议收窄，不默默扩大调研范围
- 失败路径：3 个问题用完仍有阻塞歧义 → route = BLOCKED；发现任务不可行 → route = BLOCKED + 原因

### Research Brief Template

```markdown
# Research: <title>

## Metadata
- research_id: <YYYYMMDD-HHMM-slug>
- date: <ISO date>
- research_route: READY_FOR_PLAN | NEEDS_INFO | BLOCKED

## Intent
<一段话：用户想要什么，为什么>

## Findings
- <finding> — source: <file:line | docs | user>
- <finding> — source: ...

## Affected Areas
- <file or module> — reason: <为什么会被影响>
- <interface or API> — reason: ...

## Constraints
- <约束>

## Assumptions
- <假设> — reason: <为什么合理>

## Options

### Option A: <name>
- Approach: <怎么做>
- Evidence: <为什么可行>
- Tradeoff: <放弃什么>
- Effort: S | M | L

### Option B: <name>
...

## Recommendation
- Pick: Option <X>
- Why: <一句话>

## Open Questions
- <问题> — blocks_plan: yes | no

## Next
- next_skill: pge-plan
- brief_path: .pge/research/<research_id>.md
```

### Final Response

```md
## PGE Research Result
- research_id: <id>
- research_path: .pge/research/<id>.md
- research_route: READY_FOR_PLAN | NEEDS_INFO | BLOCKED
- options_count: <N>
- recommended: <Option name>
- questions_asked: <0-3>
- next_skill: pge-plan
```

## 与现有管线的集成

```
pge-setup → .pge/config/*     (一次性)
pge-research → .pge/research/* (可选，推荐)
pge-plan → .pge/plans/*       (消费 research + config)
pge-exec → .pge/runs/*        (消费 plan + config，含 self-review)
```

## 验证

1. `/pge-research "add dark mode toggle"` → 自主完成，0 问题，单方案 brief
2. `/pge-research "rethink the skill-split architecture"` → 可能问 1-2 个带方案的问题
3. 产出的 brief 格式正确，pge-plan 可直接消费
4. 代码探索发现带 file:line 引用
5. 假设被显式标注

## 实现步骤

1. 创建 `/code/b/pge/skills/pge-research/SKILL.md`
2. 更新 `/code/b/pge/docs/exec-plans/CURRENT_MAINLINE.md` 记录 research 扩展
3. 可选：微调 `pge-plan` 增加 research brief 读取（最小改动）
4. 手动测试 3 个不同复杂度的 case（trivial / ambiguous / complex）
5. 更新 `.claude-plugin/plugin.json` 注册新 skill（如果需要）

---

## 全管线设计（从 claude-code-best-practice 11 框架提炼）

### 各阶段在 11 框架中的实现

| 阶段 | 框架 | 步骤名 | 模式 |
|------|------|--------|------|
| **Research** | Superpowers | `brainstorming` | 发散探索 |
| | Spec Kit | `/speckit.clarify` | 澄清意图 |
| | oh-my-claudecode | `/deep-interview` | 深度访谈 |
| | CE | `/ce-ideate` → `/ce-brainstorm` | 构思→头脑风暴 |
| | RPI | `/rpi:research` (6 agents) | 多 agent 串行 |
| **Plan** | Superpowers | `writing-plans` | 强制暂停+方案对比 |
| | Spec Kit | `/speckit.plan` → `/speckit.tasks` | 规格→任务 |
| | gstack | 3 重审查（CEO/Eng/Design） | 多视角审查 |
| | BMAD | PRD → Architecture → Epics | 瀑布式分解 |
| | CE | `/ce-plan` | 轻量计划 |
| | GSD | `/gsd-plan-phase` | 阶段计划 |
| **Execute** | Superpowers | `subagent-driven-development` | 子 agent 驱动 |
| | GSD | `/gsd-execute-phase` + verify loop | 执行+验证循环 |
| | BMAD | sprint → story → dev-story | 敏捷循环 |
| | CE | `/ce-work` + debug/optimize loops | 工作+修复循环 |
| | oh-my-claudecode | team-exec → verify → fix | 团队执行循环 |
| **Review** | Superpowers | `requesting-code-review` | 代码审查 |
| | Everything CC | review → security → e2e | 多维审查 |
| | CE | `/ce-code-review` | 代码审查 |
| | oh-my-claudecode | `/ralph` | 自进化审查 |
| **Ship** | Superpowers | `finishing-a-development-branch` | 分支完成 |
| | gstack | `/ship` → `/land-and-deploy` | 发布+部署 |
| | GSD | `/gsd-ship` → `/gsd-complete-milestone` | 发布+里程碑 |

### pge-plan 设计方向

**从 best-practice 提炼的 Plan 模式**：

1. **多视角审查**（gstack 模式）：plan 不是一个人写完就行，需要从不同角度审查
   - 可以用多 agent：一个产出 plan，另一个从不同角度 challenge
   
2. **分层分解**（BMAD 模式）：PRD → Architecture → Epics/Stories
   - 但 PGE 应该更轻：Intent → Approach → Issues
   
3. **强制暂停**（Superpowers 模式）：plan 写完后必须停下来，不能直接冲进执行
   - 这是 pge-plan 已有的行为（不调用 pge-exec）

4. **方案对比**（Superpowers + CE 模式）：plan 中必须对比 2-3 个方案
   - 如果 research 已经做了方案对比，plan 可以直接采用推荐方案
   - 如果没有 research，plan 自己做方案对比

**pge-plan 的改进方向**：
- 现有 pge-plan 已经很好（Planning Self-Evaluation、numbered issues、route）
- 主要改进：增加 research brief 消费 + 当 research 已做方案对比时简化 brainstorm

### pge-exec 设计方向

**从 best-practice 提炼的 Execute 模式**：

1. **子 agent 驱动**（Superpowers 模式）：每个 task 派发给子 agent
   - 现有 pge-exec 已有 worker 模式
   
2. **验证循环**（GSD/BMAD/CE 模式）：execute → verify → fix，bounded loop
   - 现有 pge-exec 已有 repair policy（MAX_REPAIR_ATTEMPTS = 2）

3. **团队执行**（oh-my-claudecode 模式）：team-exec → team-verify → team-fix
   - 更重，但对复杂任务有价值

4. **TDD 作为子循环**（Superpowers/Everything CC 模式）：不是强制，是可选的执行模式
   - 现有 pge-exec 已明确"TDD is only one possible execution mode"

5. **exec 内置 review**：exec 是单向的，完成后不回退。review 是 exec 内部的 self-review + lightweight gates，不是独立阶段。exec 产出 `DONE_NEEDS_REVIEW` 意味着交给人看，不是打回重做。

**pge-exec 的改进方向**：
- 现有 pge-exec 设计已经很成熟
- 可能的改进：更好的并行 worker 调度、更智能的 issue 依赖分析

### 全管线 Artifact Layout

```
.pge/
├── config/           # pge-setup 产出（一次性）
├── research/         # pge-research 产出
│   └── <research_id>.md
├── plans/            # pge-plan 产出
│   └── <plan_id>.md
└── runs/             # pge-exec 产出（含 self-review）
    └── <run_id>/
```

### 全管线 Route Flow

```
pge-research → READY_FOR_PLAN → pge-plan
pge-plan → READY_FOR_EXECUTE → pge-exec
pge-exec → DONE_NEEDS_REVIEW → 人来看

回退路径（人触发）：
人 → pge-exec（再跑一轮新 issue）
人 → pge-plan（重新规划）
pge-exec → NEEDS_MAIN_DECISION → 人决策后继续
```

### 实现优先级

1. **pge-research**（当前）— 填补管线最大空白
2. **pge-plan 微调**（之后）— 消费 research brief
3. **pge-exec 微调**（持续）— 更好的并行调度

### CE 的 `/ce-compound` 启示

CE 有一个独特的 `/ce-compound` 步骤：每次完成一个循环后，沉淀学到的东西。这对应 PGE 的 "不信任但积累" 哲学：

- 每次 research 的发现沉淀为 docs
- 每次 exec 的 self-review 发现沉淀为未来的验证标准
- 经验沉淀为 CLAUDE.md 或 config 更新

这不需要单独的 skill，而是每个阶段的 "handoff to docs" 行为。
