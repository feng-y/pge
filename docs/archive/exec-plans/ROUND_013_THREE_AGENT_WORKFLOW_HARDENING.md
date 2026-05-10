# ROUND_013_THREE_AGENT_WORKFLOW_HARDENING

## 本轮目标

Harden all three PGE agents as resident workflows: Planner as researcher + architect, Generator as local-first implementer with bounded Planner escalation, and Evaluator as independent verifier with bounded clarification behavior.

## Warmup

- 当前主线：Stage 0.5 resident Planner/Generator/Evaluator responsibility split.
- 当前唯一 active step：turn the three runtime agent surfaces into stable resident workflow actors with observable decisions and non-progression coordination messages.
- 本轮为什么现在做：Generator cannot carry broad research/architecture work during implementation, but asking Planner for everything would make the run slow and brittle.
- 需要先读的最小文件集：
  - `agents/pge-planner.md`
  - `agents/pge-generator.md`
  - `agents/pge-evaluator.md`
  - `skills/pge-execute/ORCHESTRATION.md`
  - `skills/pge-execute/contracts/runtime-event-contract.md`
  - `skills/pge-execute/handoffs/*.md`

## Done-when

- Planner has a resident researcher/architect post-plan support role.
- Generator has explicit local-first / Planner-on-trigger rules.
- Evaluator remains a resident independent verifier and cannot use clarification as approval.
- Support messages are defined as non-progression coordination messages.
- Durable artifacts expose helper/support decisions where they affect execution.
- Contract validator covers the above rules.

## Evidence to collect

- `./bin/pge-validate-contracts.sh`
- `git diff --check`

## Non-scope

- No automatic multi-round redispatch.
- No checkpoint/resume implementation.
- No new permanent PGE runtime agents beyond Planner / Generator / Evaluator.
- No runtime smoke claim until Claude CLI authentication is fixed.

## Progress

- 已完成：Planner resident research / architecture role added.
- 已完成：Generator local-first / Planner-on-trigger boundary added.
- 已完成：`planner_support_request` / `planner_support_response` non-progression messages added.
- 进行中：Evaluator resident clarification boundary and validator coverage.
- 下一步：run static checks and stop.

## Blockers

- P0：none for static hardening.
- P1：runtime smoke blocked by invalid Claude CLI token.
- P2：full checkpoint/resume and multi-round support.

## Decisions

- Support messages are coordination evidence, not phase progression events.
- Generator asks Planner only when local implementation context is insufficient.
- Planner support can advise `replan_needed`, but `main` owns route/stop decisions.
- Evaluator may ask/answer bounded clarification, but final verdict must remain based on independent deliverable/evidence checks.

## Review cell

- 主规划者：current Codex session.
- 并行评审轮次：not used; this is a bounded P0 hardening pass.
- Superpower 专家意见：agent value comes from workflow + gates, not persona labels.
- Gstack 专家意见：keep message-first progression and explicit non-progression support messages.
- GSD 专家意见：one bounded round, no expansion into multi-round runtime.
- Consolidation（采纳 / 拒绝 / 延后）：adopt resident workflow and support protocol; defer checkpoint/resume.

## Action

Update runtime-facing agent, handoff, orchestration, and validator surfaces for the three-agent workflow hardening pass.

## Completion criteria

Stop after static validation passes or a concrete blocker is recorded.

## Stop condition

- 达成预期产物后停止
- 移除当前 blocker 后停止
- 或把失败稳定化并写清 blocker 后停止

## Process improvement note

- 本轮暴露的问题：single support protocol work can look like a one-agent optimization unless the three-agent workflow frame is explicit.
- 下轮改进动作：after authentication is fixed, run a runtime smoke and then a small Planner-support validation task.
