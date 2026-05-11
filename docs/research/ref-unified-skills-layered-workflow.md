# 调研：Unified Skills 分层 Workflow 模型 vs PGE

来源：关木 @ZeroZ_JQ "从 Skills 到分层 Workflow：AI Agent 工程化的下一层抽象" (2026-05-09)
日期：2026-05-10

---

## 文章核心论点

Skills library 解决的是"怎么做"，workflow 解决的是"什么时候做、由谁做、做到什么程度算通过、失败时退回哪里、过程证据留在哪里"。

提出 6 层模型：CANON → Command → Agent → Skill → Artifact → Hook/Validate

## 6 层模型 vs PGE 对照

| 层级 | 职责 | PGE 对应 | 覆盖度 |
|------|------|---------|--------|
| CANON | 全局不可放松的纪律（所有 skill 继承） | CLAUDE.md + 各 skill anti-patterns（分散） | 分散，无统一宪法 |
| Command | 阶段状态机（入口/出口/门控） | 每个 skill 的 dot flow + gate check + route | ✓ 完整 |
| Agent | 责任分离（提出/执行/判断不同视角） | Generator ≠ Evaluator ≠ Outside Voice | ✓ 核心设计 |
| Skill | 可复用方法论单元 | 5 个 skill + references/ progressive disclosure | ✓ 完整 |
| Artifact | 过程证据链（可审计） | .pge/tasks-<slug>/{research, plan, runs/} | ✓ 完整 |
| Hook/Validate | 运行时护栏，检测合同漂移 | Evaluator thresholds + self-review（仅 prompt 级） | 无运行时 hook |

## 文章四类"工程失稳" vs PGE 对策

| 失稳类型 | 描述 | PGE 机制 |
|---------|------|---------|
| 时序失稳（跳步骤） | Agent 从模糊想法直接进入实现 | gate check：plan 必须有 upstream input，exec 必须有 READY_FOR_EXECUTE |
| 责任失稳（自证通过） | 同一 Agent 提出/执行/判断 | Generator ≠ Evaluator，Outside Voice 独立挑战 |
| 证据失稳（不可追踪） | 过程散失在对话中 | artifact chain + learnings.md + manifest.md |
| 治理失稳（skills 无组织） | 运行时临场决定调用顺序 | 固定阶段流 research → plan → exec + dot flow |

## PGE 的真实 Gap

### Gap 1: 无统一 CANON

当前状态：每个 skill 各自定义 anti-patterns 和 guardrails。跨 skill 的共享原则散落各处：
- "不信任但积累" — 在 exec compound 描述中
- "最小化 HITL" — 在 research 的 anti-pattern 中
- "fix-first not report-only" — 在 multi-round-eval.md 中
- "code is truth" — 在 research key principles 中

风险：原则在不同 skill 间漂移，新增 skill 时可能遗漏继承。

可能方案：`.pge/config/` 下或 `skills/shared/` 下放一个 principles 文件，所有 skill 引用。

### Gap 2: 无运行时 validate

当前状态：所有验证都是 prompt 级（self-review、evaluator thresholds、placeholder scan）。

无法检测：
- artifact-layout.md 定义的路径 vs SKILL.md 实际引用的路径是否一致
- plan 引用的 Target Areas 文件是否真的存在
- config 和 SKILL.md 之间是否有矛盾
- 多个 skill 的 Final Response 格式是否对齐

实例：刚修的 artifact layout 不一致就是这类"合同漂移"的典型。

可能方案：一个轻量 validate 脚本（rg 检查路径一致性），或 pge-handoff extract 模式的一部分。

## 文章的两阶段 Review

文章主张 review 分两关：
1. Spec Compliance — 做没做对（功能覆盖）
2. Code Quality — 做得好不好（质量维度）

PGE 现状：Evaluator 对 DEEP 任务做两 pass（spec compliance → code quality），LIGHT 任务单 pass。
文章观点：所有任务都应该分两关。

## 文章验证了 PGE 的设计方向

文章用不同词汇描述了同一套架构。PGE 的 research → plan → exec 就是文章说的 Command 层状态机；G+E 分离就是 Agent 层责任分离；artifact layout 就是证据链。

核心差异：文章更强调"宪法"层（CANON）和"运行时护栏"层（Hook/Validate），PGE 在这两层相对薄。

## 六条原则（文章提出）

1. 具体能力可以增加纪律，但不能放松纪律
2. Workflow 需要阶段状态机，而不是能力快捷方式
3. Agent 的核心价值是责任分离，不是人格化
4. Skill 是执行方法论，不是工作流总控
5. 没有 artifact，workflow 就缺少可审计证据
6. 高层纪律必须有低层护栏，否则只是建议

PGE 对 1-5 已有实现。第 6 条（低层护栏）是当前最大 gap。
