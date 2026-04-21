# Round 009: P/G/E Interface Alignment

## 本轮目标

Lock one shared current-task / bounded-round vocabulary across Planner, Generator, Evaluator, and skill handoff wording.

## Progress

- 已完成：对齐 `agents/planner.md`、`agents/generator.md`、`agents/evaluator.md` 的当前任务语义与边界分工。
- 已完成：最小修正 `skills/pge-execute/SKILL.md`，使 skill 与 P/G/E 使用同一组 handoff 字段。
- 下一步：通过实际 `/pge` 运行验证这些对齐后的接口词汇在真实流转中可驱动。

## Blockers

- P0：None.
- P1：实际 skill/runtime 仍需证明会按最新 agent/skill 契约消费这些字段。
- P2：更广泛的合同/流程文档统一暂不展开。

## Decisions

- 执行单元明确为 **one current task / bounded round**。
- Planner 输出的是 **current-task plan / bounded round contract**，不是另一份高层 spec。
- Generator 负责 **local verification**，但不拥有 final approval。
- Evaluator 评估 **当前任务整体**，并产出 route-ready verdict。
- skill 只做最小词汇对齐，不做编排重设计。

## Non-scope

- 不做 runtime redesign。
- 不做 multi-round support 扩展。
- 不做外部任务支持。
- 不做大规模 prompt 重写。
- 不做 broader harness theory 扩展。

## Action

本轮只做一个最小动作：把 P/G/E 与 skill 的 handoff vocabulary 锁成同一种 current-task contract 语言。

## Completion criteria

- Planner / Generator / Evaluator 对执行单元使用同一语义。
- Generator local verification 与 Evaluator final approval 边界清晰。
- skill/main 能消费同一组字段而不需要再翻译旧词汇。
- 无额外范围扩张。

## Process improvement note

- 本轮暴露的问题：agents/ 与 skill 在同一回合里漂移成两套近似但不相同的接口语言。
- 下轮改进动作：在做 proving run 前，先对 handoff 字段做一次 cross-file grep 检查，避免旧 schema 残留。
