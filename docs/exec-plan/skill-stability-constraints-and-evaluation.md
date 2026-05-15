# Skill Stability Constraints & Evaluation

## Context

这份文档定义 PGE skill 如何稳定运行的设计约束，以及如何评估一个 skill 是否稳定。它服务两个目的：

1. 作为后续重构 `pge-exec`、新增 `pge-plan-normalize`、迁移 compound 到 `pge-knowledge` 的约束来源。
2. 作为评估任何 PGE skill 是否“稳定可执行”的统一 rubric，而不是靠事后凭感觉判断。

这里的核心判断是：

> skill 不稳定，往往不是因为行数多，而是因为职责密度过高、关键协议不够前置、以及运行时控制面和其他认知任务混在一起。

`pge-exec` 是当前最典型的例子。

## What we learned from gstack

gstack 有很多重型 skill，但它们的“重”通常不是 `pge-exec` 这种重法。对 PGE 最有价值的经验有五条：

### 1. 重 skill 可以稳定，但前提是目标单一

gstack 的重 skill 往往聚焦一个 workflow，例如：
- plan review
- QA
- ship
- office-hours

它们可能很长，但主任务比较单一。PGE 里最危险的情况不是“文档长”，而是一个 skill 同时承担：
- planning
- normalization
- execution
- review
- knowledge extraction

### 2. 关键步骤必须前置成 checklist，而不是埋在 prose 里

gstack 会把：
- preamble
- prerequisite checks
- question protocol
- completion protocol

前置成结构化规则。PGE 的执行型 skill 也必须这样做。对于 runtime-sensitive 的 skill，说明文字不能代替关键 gate。

### 3. 人类检查点越少，执行约束就要越硬

gstack 很多重 skill 是 interactive 的，靠：
- AskUserQuestion
- 分 section 推进
- 中间确认

来降低漂移。

`pge-exec` 则更接近自动控制面，所以必须用更硬的协议约束来替代人类 checkpoint。

### 4. 外部 artifacts 比内存中的“理解”更可靠

gstack 大量依赖：
- 外部文档
- review logs
- dashboard
- 固定格式输出

这意味着“状态”更多写在外面，而不是只存在模型脑子里。PGE 的执行路径也应该优先依赖 artifacts 和唯一信号，不依赖 prose 理解。

### 5. 可选复杂度应外置，不应挤占主路径

gstack 的很多复杂度分散在：
- preamble
- shared helpers
- 其他 skill
- 外部脚本

而不是塞进一个 runtime loop。PGE 的执行主路径也应该保持窄，把 normalization、knowledge extraction 等移到 sibling skill。

## Design constraints for stable skills

### 1. Role purity

一个 skill 只应承担一种主认知任务。

允许：
- planning
- normalization
- execution
- review
- knowledge extraction

但不应把多个主任务长时间混在同一个 skill 里。

**Constraint:**
- 一个 skill 的主输出只服务一种结果。
- planning 负责做判断。
- normalization 负责无损转换。
- execution 负责按 contract 运行。
- review 负责质疑与放行。
- knowledge 负责提炼 durable learnings。

### 2. Critical path first

所有执行型 skill 必须把执行关键路径放在最前面。

**Constraint:**
- skill 顶部必须存在一个简短、唯一的 Critical Path。
- 这条路径必须能在不读完整份文档的情况下被执行。
- 关键 gate 不能只散落在后文 prose 里。

**Failure mode when violated:**
- 模型会先抓住“把任务做完”，再渐进式漏掉前置协议，例如 source routing、preflight、teardown truth。

**Expected enforcement surface:**
- skill contract 顶部 checklist
- review / challenge rubric

### 3. Unique protocol signals

每个关键状态转换必须有唯一、可检查的信号。

**Constraint:**
- startup signal 唯一
- candidate-ready signal 唯一
- verdict signal 唯一
- teardown-complete signal 唯一

示例：
- `lane_ready`
- `generator_completion`
- `evaluator_verdict`
- runtime shutdown approval / teammate termination

### 4. Runtime truth beats text truth

文本自述不能替代运行时真相。

**Constraint:**
- prose acknowledgement 只能算提示，不能算完成。
- teardown、completion、recovery 以 runtime-visible state 为准。
- 如果文本和 runtime 状态冲突，信 runtime。

### 5. State must be explicit and recoverable

执行路径必须能中断、恢复、重放。

**Constraint:**
- 状态变化外显
- 状态写盘
- in-flight 状态有明确 resume 规则
- 不允许“先做完再补状态”

### 6. No hidden planning inside exec

execution skill 不应承担隐式规划权。

**Constraint:**
- goal / scope / acceptance 不清时，退回 planning upstream。
- execution 只处理 canonical contract，或处理明确定义的 normalization 输入。
- execution 不从 conversation context 临时发明 scope。
- 计划后的当前用户约束可以收窄、暂停、阻断执行，但不能被当作 silent replan 或 scope expansion 的授权。

### 7. Optional complexity moves out

可选复杂度必须移出主路径。

**Constraint:**
- references 承担展开说明
- sibling skills 承担相邻主任务
- 主 skill 只保留执行关键路径所需最小决策
- 如果相邻职责被外移到 sibling skill，必须明确它的触发方式与输入/输出边界，避免责任真空或偷偷回流进主路径

## Evaluation rubric

用下面 6 个维度评估 skill 稳定性。

### 1. Role purity
- **0-2**: skill 同时承担多个主任务，边界模糊
- **3-5**: 主任务清楚，但仍混入明显不属于它的职责
- **6-8**: 大部分职责边界清晰，只有少量尾部混杂
- **9-10**: 单一主任务，边界清楚，邻接任务有独立承接者

### 2. Critical-path clarity
- **0-2**: 关键执行路径埋在长 prose 中
- **3-5**: 有主路径，但分散在多个 section
- **6-8**: 主路径可提取，但还不够前置
- **9-10**: 顶部有短硬 checklist，主路径极清楚

### 3. Protocol explicitness
- **0-2**: 关键状态依赖模型理解，没有唯一信号
- **3-5**: 部分状态有信号，部分仍靠 prose
- **6-8**: 主要状态信号存在，但有少数模糊地带
- **9-10**: 所有关键 gate 都有唯一、可检查的信号

### 4. State recoverability
- **0-2**: 中断后几乎无法恢复
- **3-5**: 有部分状态记录，但恢复靠猜测
- **6-8**: 大部分状态可恢复，仍有边缘不明确
- **9-10**: 恢复规则明确，状态外显，失败路径可重放

### 5. Human checkpoint discipline
- **0-2**: 该问人的地方不问，不该问的地方乱问
- **3-5**: checkpoint 存在但不稳定
- **6-8**: 大致分清 AI 决策和用户决策边界
- **9-10**: 用户决策边界清楚且一致

### 6. Operational verifiability
- **0-2**: 只有理论说明，没有可操作验证
- **3-5**: 有文档级验证，没有 live proof
- **6-8**: 既有 contract 验证，也有最小 runtime 验证
- **9-10**: contract、runtime、failure-path 都能验证

## Complexity budget

职责密度要可操作，不能只靠感觉。

**Recommended budget:**
- 一个 skill 的 Critical Path 中，同时必须记住的核心控制权不应长期超过 **5-7 个**。
- 超过预算时，优先外移到 sibling skills 或 fixed artifacts。

对执行型 skill，典型核心控制权包括：
- source routing
- canonical validation
- lane preflight
- candidate verdict
- teardown truth

超过这个预算，不代表一定错误，但代表该 skill 进入脆弱区，必须额外证明为什么这些控制权不能拆开。

## Applying the rubric

这份文档只定义通用评估与设计约束，不承载某一个具体 skill 的实施方案。

使用方式：
- 用本 rubric 评估某个 skill 是否稳定
- 把具体拆分、cutover、source-of-truth、migration verification 写入该 skill 自己的 design plan
- 如果某个 skill 的问题是“职责密度过高”，应在对应 design doc 中明确拆分后的边界与验证方式

## Verification standard for this document

这份文档是否合格，用下面四条判断：

1. 能清楚解释为什么 skill 不稳定常常是职责密度问题，不是行数问题。
2. 能给出一套可复用的稳定性约束，而不是只针对单个 skill 的经验总结。
3. 能给出一套可复用的评估 rubric，而不是一次性的重构理由。
4. 读者能把这份文档作为上位约束，再去写具体 skill 的 design plan。