Review 要求：

必须做三层 review，不要只做 Claude Code 自评。

Round 1：Repo-grounded self review
- 基于当前 repo 文件检查方案是否贴合真实结构
- 明确 current confirmed state / inferred gap / proposed change
- 不允许把未来目标写成当前已实现

Round 2：Anthropic Critical Gates review
- 用 5 个 Critical Gates 逐条检查：
  1. Planner raw-prompt ownership
  2. Preflight multi-turn negotiation
  3. Generator sprint / feature granularity
  4. Evaluator hard-threshold grading
  5. Runtime long-running execution and recovery
- 每个 gate 必须给：
  - 当前状态
  - 缺口
  - 改建动作
  - 需要新增/修改的 artifact
  - 验收方式

Round 3：Codex independent review
- 将 docs/design/ 下产出的改建方案交给 Codex 做独立 review
- Codex review 不负责重写方案，只负责挑问题
- Codex review 必须优先找：
  - 方案和当前 repo 不一致的地方
  - 过度设计
  - 缺失的 runtime artifact
  - 不可执行的验收标准
  - P/G/E 职责边界不清
  - 没有落到文件/contract/runtime-state 的空泛描述
  - 没有覆盖 Anthropic Critical Gates 的缺口
  - 会导致 agent 膨胀或 per-task agent inflation 的设计
  - 可能让 Evaluator 变成存在性检查的薄弱点
  - recovery/resume 只写概念、没有可验证 artifact 的问题

Codex review 输出保存为：
  docs/design/pge-codex-review.md

Codex review 格式：
  # Findings

  ## P0 Blocking Issues
  - issue
  - evidence
  - affected document
  - affected Critical Gate
  - required fix

  ## P1 Major Issues
  - issue
  - evidence
  - affected document
  - affected Critical Gate
  - required fix

  ## P2 Improvements
  - issue
  - suggestion

  # Missing Acceptance Checks

  # Questions / Assumptions

然后 Claude Code 必须根据 Codex review 再做一轮修订：

Round 4：Post-Codex revision
- 修复 Codex review 中的 P0/P1 问题
- 对每个 Codex finding 标记：
  - accepted
  - rejected
  - partially accepted
- rejected 必须写理由
- 最终汇总保存到：
  docs/design/pge-rebuild-review-report.md
