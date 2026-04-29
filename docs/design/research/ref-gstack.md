# gstack 调研报告：plan-eng-review 压力机制

来源：本地安装的 gstack 技能文件（`~/.claude/skills/gstack/`），版本 1.0.0
作者：Garry Tan（Y Combinator CEO）
许可：MIT

---

## 1. plan-eng-review 的具体流程

### 整体定位

gstack 将工程 review 定位为 **shipping gate**（发布门禁）。在所有 review 类型中，只有 Eng Review 是默认必须通过才能 ship 的。CEO Review、Design Review、Adversarial Review 都是可选的。

### 流程步骤

```
Design Doc Check → Scope Challenge (Step 0) → Architecture Review (Section 1)
→ Code Quality Review (Section 2) → Test Review (Section 3) → Performance Review (Section 4)
→ Outside Voice (optional) → Required Outputs → Review Log → Readiness Dashboard
```

**Step 0: Scope Challenge（范围挑战）**
- 映射每个子问题到已有代码
- 最小变更集识别
- 复杂度检查：>8 文件或 >2 新类/服务 = 代码异味
- 搜索检查：框架是否有内置方案？当前最佳实践？已知陷阱？
- TODOS 交叉引用
- 完整性检查：AI 辅助下完整方案只多花几分钟，为什么选捷径？
- 分发检查：新产物是否包含 CI/CD 管道？

**Section 1-4: 四个 review 维度（详见下节）**

**Outside Voice（外部声音）**
- 完成所有 section 后，可选调用 Codex CLI 或 Claude subagent 做独立 review
- 跨模型分歧标记为 CROSS-MODEL TENSION
- 用户主权原则：外部建议必须经用户明确批准才能采纳

**Required Outputs（必须产出）**
- "NOT in scope" 清单
- "What already exists" 清单
- TODOS.md 更新
- ASCII 图表
- 失败模式注册表
- 工作树并行化策略
- 完成摘要

---

## 2. 各个 review 维度的评审标准

### 2.1 Architecture Review（架构审查）

评估项：
- 系统设计和组件边界
- 依赖图和耦合关注点
- 数据流模式和潜在瓶颈
- 扩展特性和单点故障
- 安全架构（认证、数据访问、API 边界）
- 关键流程是否需要 ASCII 图
- 每个新代码路径/集成点：描述一个现实的生产故障场景
- 分发架构：新产物如何构建、发布、更新？

**压力机制**：要求为每个新集成点描述具体的生产故障场景，不是"可能出问题"而是"具体怎么出问题"。

### 2.2 Code Quality Review（代码质量审查）

评估项：
- 代码组织和模块结构
- DRY 违规（"be aggressive"）
- 错误处理模式和缺失的边界情况
- 技术债务热点
- 过度工程 vs 不足工程
- 已有 ASCII 图是否仍然准确

**压力机制**：DRY 检查要求"激进"。明确要求同时检查过度工程和不足工程。

### 2.3 Test Review（测试审查）— 最重的维度

这是 gstack 工程 review 中最详细的部分。目标：100% 覆盖率。

**五步流程**：

1. **追踪每个代码路径**：不是列出函数，而是跟踪执行流
   - 输入从哪来？
   - 什么转换它？
   - 去哪里？
   - 每一步什么会出错？

2. **映射用户流、交互和错误状态**：
   - 用户流：完整旅程映射
   - 交互边界情况：双击、中途导航离开、过期数据提交、慢连接、并发操作
   - 用户可见的错误状态
   - 空/零/边界状态

3. **检查每个分支对应的测试**：
   - 质量评分：★★★（行为+边界+错误路径）、★★（快乐路径）、★（烟雾测试）
   - E2E 测试决策矩阵
   - EVAL 测试（LLM 相关）

4. **输出 ASCII 覆盖率图**：
   ```
   CODE PATH COVERAGE
   ===========================
   [+] src/services/billing.ts
       ├── processPayment()
       │   ├── [★★★ TESTED] Happy path + card declined
       │   ├── [GAP]         Network timeout — NO TEST
       │   └── [GAP]         Invalid currency — NO TEST
   ```

5. **为缺口生成测试**

**REGRESSION RULE（铁律）**：回归测试不需要询问用户，直接写。

**压力机制**：不是问"有没有测试"，而是画出完整的执行图，然后逐个分支检查覆盖。缺口无处可藏。

### 2.4 Performance Review（性能审查）

评估项：
- N+1 查询和数据库访问模式
- 内存使用关注点
- 缓存机会
- 慢路径和高复杂度代码路径

### 2.5 Confidence Calibration（置信度校准）

每个发现必须包含置信度分数（1-10）：

| 分数 | 含义 | 显示规则 |
|------|------|----------|
| 9-10 | 通过阅读具体代码验证 | 正常显示 |
| 7-8 | 高置信度模式匹配 | 正常显示 |
| 5-6 | 中等，可能误报 | 带警告显示 |
| 3-4 | 低置信度 | 从主报告中抑制 |
| 1-2 | 推测 | 仅 P0 严重度时报告 |

---

## 3. plan-ceo-review 的额外压力维度（对比参考）

CEO review 在 eng review 的基础上增加了更多维度：

### 额外的 review sections（共 11 个）

| Section | 内容 | 压力来源 |
|---------|------|----------|
| Error & Rescue Map | 每个可失败方法的异常类、是否被捕获、用户看到什么 | 不允许 catch-all，必须命名具体异常 |
| Security & Threat Model | 攻击面扩展、输入验证、授权、注入向量 | 每个发现要评估 likelihood × impact |
| Data Flow & Interaction Edge Cases | 四条路径（happy/nil/empty/error）+ 交互边界 | ASCII 图强制要求 |
| Observability & Debuggability | 日志、指标、追踪、告警、仪表板、运维手册 | "3 周后出 bug 能从日志重建吗？" |
| Deployment & Rollout | 迁移安全、功能标志、回滚计划、部署时风险窗口 | "旧代码和新代码同时运行时什么会坏？" |
| Long-Term Trajectory | 技术债务、路径依赖、可逆性评分 1-5 | "12 个月后新工程师读这个代码，明显吗？" |
| Design & UX | 信息架构、交互状态覆盖、AI slop 风险 | 用户流 ASCII 图强制要求 |

### Prime Directives（首要指令）

1. **零静默失败**：每个失败模式必须可见
2. **每个错误有名字**：不说"处理错误"，要命名具体异常类
3. **数据流有影子路径**：每个数据流有 4 条路径（happy/nil/empty/error）
4. **交互有边界情况**：双击、中途导航、慢连接、过期状态、后退按钮
5. **可观测性是范围，不是事后想法**
6. **图表是强制的**：非平凡流程必须有 ASCII 图
7. **延迟的事项必须写下来**：模糊意图是谎言
8. **为 6 个月后优化，不只是今天**
9. **你有权说"推翻重来"**

---

## 4. Review 如何产生实质压力

### 4.1 结构化强制（不是建议，是必须）

gstack 的 review 不是"看看有没有问题"，而是一套结构化的检查清单，每个维度都有具体的产出要求：

- **ASCII 图是强制的**：不画图就不算完成 review
- **每个 section 后必须停下来**：`STOP. AskUserQuestion once per issue.`
- **失败模式注册表是必须产出**：每个代码路径的失败模式、是否有测试、是否有错误处理、用户是否看到
- **CRITICAL GAP 标记**：RESCUED=N + TEST=N + USER SEES=Silent = 关键缺口

### 4.2 对抗性设计

- **Outside Voice**：完成所有 section 后，调用另一个 AI 模型做独立 review
- **Adversarial Review**（在 /review 中）：根据 diff 大小自动升级
  - <50 行：跳过
  - 50-199 行：跨模型对抗挑战
  - 200+ 行：4 轮全面审查（Claude 结构化 + Codex 结构化 + Claude 对抗 + Codex 对抗）
- **Cross-model tension**：两个模型不一致时明确标记，呈现给用户决定

### 4.3 完整性原则（Boil the Lake）

核心理念：AI 让完整性的边际成本接近零。当完整方案只比捷径多花几分钟时，永远选完整方案。

每个选项都要标注 `Completeness: X/10`：
- 10 = 所有边界情况、完整覆盖
- 7 = 覆盖快乐路径但跳过一些边界
- 3 = 延迟大量工作的捷径

### 4.4 Fix-First 机制

发现问题不是终点，修复才是：
- **AUTO-FIX**：机械性修复直接应用（死代码、N+1 查询、过期注释）
- **ASK**：需要人类判断的问题（安全、竞态条件、设计决策）
- 不存在"发现问题但不处理"的状态

### 4.5 Review Readiness Dashboard

```
+====================================================================+
|                    REVIEW READINESS DASHBOARD                       |
+====================================================================+
| Review          | Runs | Last Run            | Status    | Required |
|-----------------|------|---------------------|-----------|----------|
| Eng Review      |  1   | 2026-03-16 15:00    | CLEAR     | YES      |
| CEO Review      |  0   | —                   | —         | no       |
| Design Review   |  0   | —                   | —         | no       |
| Adversarial     |  0   | —                   | —         | no       |
| Outside Voice   |  0   | —                   | —         | no       |
+--------------------------------------------------------------------+
| VERDICT: CLEARED — Eng Review passed                                |
+====================================================================+
```

- 7 天过期机制
- commit hash 追踪陈旧性
- 只有 Eng Review 是 shipping gate

---

## 5. 对 PGE Evaluator 设计有价值的具体点

### 5.1 压力维度的结构化

gstack 证明了 review 压力可以被结构化为具体的、可检查的维度。PGE 的 Evaluator 可以借鉴：

| gstack 维度 | PGE 可借鉴的评估维度 |
|-------------|---------------------|
| Error & Rescue Map | 合约的错误路径是否完整定义 |
| Data Flow 四条路径 | 状态转换的 nil/empty/error 路径 |
| Test Coverage 图 | 证明运行的覆盖率图 |
| Failure Modes Registry | 证明运行的失败模式注册表 |
| Confidence Calibration | 评估结果的置信度分数 |

### 5.2 "不允许模糊"原则

gstack 的核心压力来源是不允许模糊：
- 不说"处理错误"，要命名具体异常类
- 不说"有测试"，要画出覆盖率图
- 不说"可能有问题"，要给置信度分数

PGE 的 Evaluator 应该同样要求：
- 不说"质量不够"，要指出具体哪个合约条款未满足
- 不说"需要改进"，要给出具体的 verdict 和 evidence

### 5.3 多模型对抗

gstack 的 Outside Voice 和 Adversarial Review 证明了跨模型 review 的价值。PGE 可以考虑：
- Evaluator 和 Executor 使用不同的模型
- 或者 Evaluator 内部使用对抗性子代理

### 5.4 Fix-First 而非 Report-Only

gstack 的 review 不只是报告问题，而是直接修复能修复的。PGE 的 Evaluator 可以借鉴：
- 评估结果不只是 pass/fail，而是包含具体的修复建议
- 机械性问题自动修复，判断性问题升级

### 5.5 Completeness Score

每个选项的 `Completeness: X/10` 评分是一个简洁有效的压力工具。PGE 可以用类似机制评估证明运行的完整性。

### 5.6 Shipping Gate 机制

只有一个 review 是 gate（Eng Review），其他都是可选的。这避免了过度流程化。PGE 应该同样区分：
- 必须通过的评估（gate）
- 有价值但可选的评估（advisory）

---

## 6. 不适用于 PGE 的部分

### 6.1 交互式问答流程

gstack 的 review 是高度交互式的（每个 issue 一个 AskUserQuestion）。PGE 的证明运行是自动化的，不适合这种交互模式。PGE 需要的是自动化的评估标准，不是交互式的问答。

### 6.2 代码级别的检查清单

gstack 的 checklist.md 是针对具体编程模式的（SQL 注入、N+1 查询、XSS）。PGE 的评估对象是合约和证明运行，不是代码。需要设计自己的检查清单。

### 6.3 Scope Expansion/Reduction 模式

gstack 的 CEO review 有 4 种范围模式（EXPANSION/SELECTIVE/HOLD/REDUCTION）。PGE 的评估不涉及范围决策，评估标准应该是固定的。

### 6.4 Design/UX 维度

gstack 的设计审查维度（信息架构、响应式、无障碍）不适用于 PGE 的合约评估场景。

### 6.5 Telemetry/Analytics 基础设施

gstack 的遥测、分析、学习系统是为长期使用设计的。PGE 的评估器不需要这些。

---

## 7. 关键引用

- 来源文件：`~/.claude/skills/gstack/plan-eng-review/SKILL.md`
- 来源文件：`~/.claude/skills/gstack/plan-ceo-review/SKILL.md`
- 来源文件：`~/.claude/skills/gstack/review/SKILL.md`（pre-landing review）
- 来源文件：`~/.claude/skills/gstack/review/checklist.md`
- 来源文件：`~/.claude/skills/gstack/autoplan/SKILL.md`
- 来源文件：`~/.claude/skills/gstack/README.md`
- 来源文件：`~/.claude/skills/gstack/ETHOS.md`
- GitHub 仓库：`github.com/garrytan/gstack`（MIT 许可）
