# PGE Exec Stability Plan

## Why this exists

`pge-exec` 现在不稳定，不主要是因为文档长，而是因为职责密度过高。一个 skill 里同时承担了：

- canonical plan intake
- external plan normalization
- team lifecycle
- generator/evaluator dispatch
- retry / pipeline control
- final review gate
- compound learnings
- route / teardown

这会让模型在执行时优先抓住“把任务做完”，然后渐进式漏掉协议 gate。

这个文档只解决一件事：**把 `pge-exec` 收窄成稳定的执行控制面。**

## Target boundary

`pge-exec` 只负责：

1. 读取 canonical `.pge/tasks-<slug>/plan.md`
2. 验证它是否 `READY_FOR_EXECUTE | READY_FOR_EXECUTE_WITH_ASSUMPTIONS`
3. 吸收计划之后新增、且只会收窄或阻断执行的用户约束
4. 创建并预检 generator / evaluator lanes
5. 按 issue contract 派发 generator / evaluator
6. 维护 per-issue state / retry / route
7. 做 teardown 并写运行 artifacts

`pge-exec` 不再负责：
- external plan adoption / normalization
- broad planning judgment
- default compound / durable knowledge promotion
- full review workflow orchestration beyond a thin high-risk final gate

## Hard rules

### 1. Canonical-only execution
- `pge-exec` 只接受 canonical `.pge/tasks-<slug>/plan.md`
- 合法执行 route 只有：`READY_FOR_EXECUTE | READY_FOR_EXECUTE_WITH_ASSUMPTIONS`
- 非 canonical plan 一律退回 `pge-plan-normalize`
- exec 内旧 normalize path 删除，不保留长期兼容
- canonical-only 不等于 context-blind。计划后的用户纠偏仍要吸收，但只允许收窄、暂停、阻断，不允许静默扩 scope

### 2. No implicit planning
- goal / scope / acceptance / target areas 不清时，exec 不能补齐
- `READY_FOR_EXECUTE_WITH_ASSUMPTIONS` 里的 assumptions 必须已经显式写进 canonical plan
- exec 可以按这些显式 assumptions 执行，但不能在运行时再发明新的 assumptions
- 这类问题统一退回 `pge-plan` 或 `pge-plan-normalize`

### 3. Team-first protocol
- 任何 issue work 前必须：
  - `TeamCreate`
  - spawn `generator` + `evaluator`
  - 双方 `lane_ready`
- 任一 lane 无法 preflight，retry once，再失败 `BLOCKED`

### 4. No main-thread fallback
- 主线程不得模拟 generator / evaluator
- “能做完”不等于“协议正确”

### 5. Unique runtime signals
- startup: `lane_ready`
- candidate-ready: `generator_completion`
- acceptance verdict: `evaluator_verdict`
- teardown complete: runtime shutdown approval / teammate termination

### 6. Runtime truth beats text truth
- 文本 `shutdown_response` 只是 lane-level ack
- 真正 teardown 完成以 runtime-level shutdown approval / teammate termination 为准

### 7. Facts, not compound
- `pge-exec` 只写：
  - manifest
  - state
  - evidence
  - deliverables
  - review report（若 gate 触发）
- durable learnings 交给 `pge-knowledge`

## Generator / evaluator boundary

### Generator lane
负责：
- 实现 issue
- 运行本地 verification
- 产出 deliverable + evidence
- 自检 candidate 是否有资格交给 evaluator

不负责：
- PASS issue
- whole-diff judgement
- planning / scope reinterpretation

### Evaluator lane
负责：
- 独立验证 deliverable
- 检查 acceptance / evidence / drift
- 给出 `PASS | RETRY | BLOCK`

不负责：
- 重新 planning
- broad architectural critique
- durable knowledge extraction

### Final review gate
保留，但变薄。只在高风险时触发：
- cross-issue composition
- shared/public interface risk
- ship-level whole-diff risk

Minimum trigger checklist:
- multiple issues changed shared behavior or must compose correctly
- public API, CLI, skill contract, handoff schema, or artifact layout changed
- stateful behavior, migration, persistence, or recovery semantics changed
- auth, safety, destructive action, or sensitive-data handling changed
- generator/evaluator needed retries, disagreed materially, or left residual risk
- changed files cross ownership boundaries enough that issue-level acceptance may miss whole-diff risk

这里的“变薄”是 ownership thinning，不是质量 bar 变弱：
- issue-level acceptance 仍由 evaluator 独占
- final review 仍覆盖 whole-diff / cross-issue / shared-interface 风险
- 合起来的验证强度不得低于当前 exec + final review 的组合要求
- 不重新做 issue acceptance，不替代 evaluator。

## Migration phases

### Phase 1: Freeze the boundary
修改 `skills/pge-exec/SKILL.md`：
- 顶部增加短的 Critical Path
- 明确 canonical-only execution
- 删除 exec 内 normalize 语义
- 明确 compound 不在 exec 主路径

### Phase 2: Redirect normalize upstream
修改 `skills/pge-exec/SKILL.md`：
- 所有非 canonical source route 到 `pge-plan-normalize`
- canonical 合法执行 route 明确为 `READY_FOR_EXECUTE | READY_FOR_EXECUTE_WITH_ASSUMPTIONS`
- 对 assumptions 的消费规则写清：只执行显式 assumptions，不新增隐式 assumptions
- conversation-context fallback 不再用于“补 exec plan”
- 但计划后的用户纠偏仍可 narrow / pause / block 当前执行

### Phase 3: Thin final review
收窄 final review gate 说明：
- 明确它只负责 whole-diff / cross-issue 风险
- issue-level acceptance 由 evaluator 独占

### Phase 4: Remove compound from exec
修改 `skills/pge-exec/SKILL.md`：
- 删除默认 compound / learnings 提炼责任
- 仅保留运行事实 artifacts
- 把后续 durable knowledge promotion 指向 `pge-knowledge`

## Files expected to change

Primary:
- `skills/pge-exec/SKILL.md`
- `skills/pge-exec/handoffs/generator.md`
- `skills/pge-exec/handoffs/evaluator.md`
- `bin/pge-validate-contracts.sh`

Downstream follow-up references:
- `skills/pge-knowledge/SKILL.md`
- `skills/pge-plan-normalize/SKILL.md` (new)

## Migration risks

1. **Hidden normalize dependencies**
   - old callers may still pass non-canonical plans to exec
2. **Review responsibility regression**
   - if final review is thinned without clarifying evaluator boundary, issue acceptance may drift
3. **Knowledge gap after removing compound**
   - if `pge-knowledge` is not ready, learnings may silently stop being extracted
4. **Protocol drift during cutover**
   - docs, handoffs, and validator can diverge if changed in separate commits

## Verification

Minimum required verification after migration:

1. canonical `.pge/tasks-<slug>/plan.md` still executes end-to-end
2. non-canonical input is rejected by exec and clearly routed to normalize upstream
3. generator/evaluator loop still works with:
   - `lane_ready`
   - `generator_completion`
   - `evaluator_verdict`
   - runtime teardown approval / teammate termination
4. exec artifacts still land under `.pge/tasks-<slug>/runs/<run_id>/`
5. no implicit planning fallback remains in exec
6. a high-quality non-canonical plan still works end-to-end through the new split:
   - source plan → `pge-plan-normalize` → canonical plan → `pge-exec`
7. post-plan user constraints can narrow / pause / block execution without being mistaken for permission to replan or expand scope

## Not in scope

- implementing runtime orchestrator code outside Claude Code skill surfaces
- redesigning Team APIs
- redefining `pge-plan` or `pge-knowledge` in full
- deploy / ship workflow changes
