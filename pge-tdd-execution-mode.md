# PGE Exec TDD Development Mode 设计计划

## 背景

当前 PGE 的 `research -> plan -> exec` 链路已经覆盖 intent alignment、plan contract、evidence alignment 和 evaluator review。`pge-exec` 也要求 Generator 写测试、运行 verification，并由 Evaluator 独立验证。

但当前执行协议不是严格 TDD。它能证明“实现后有测试和验证”，不能证明“测试先于实现且测试确实承载行为约束”。如果直接引入 red-green-refactor 证据，容易诱导低价值测试：测试只是复述实现结构，目的是制造 RGR 证据，而不是捕获真实行为回归。

## 目标

为 PGE 增加可选的 issue-level TDD 执行模式，用于 bug fix、新行为和复杂规则类任务，同时避免把所有任务都强制纳入 TDD ceremony。

## 非目标

- 不把所有 `pge-exec` issue 全局改为强制 TDD。
- 不要求文档、配置、机械迁移、重命名、纯删除等任务使用 TDD。
- 不允许为了满足 RGR 形式而加入只复述实现的低价值测试。
- 不改变 `pge-research` 的职责边界；research 仍不选择实现方案或定义最终 acceptance。
- 不引入或依赖独立 TDD skill；TDD 是 `pge-exec` 的内建执行能力。

## 核心决策

### 1. 增加 issue-level Development Mode

在 PGE plan issue 中增加字段：

```text
Development Mode: STANDARD | TDD
```

默认值为 `STANDARD`。`TDD` 只用于行为可被测试明确约束的 issue。

`Development Mode` 和现有 `Execution Type` 是两个正交维度：

- `Development Mode` 决定 Generator 的开发协议：普通实现或 red-green-refactor。
- `Execution Type` 决定执行形态：AFK 或 HITL。

TDD 的执行权威属于 `pge-exec`。plan 只声明 issue 是否需要 TDD，以及 TDD 所需的行为测试合同；Generator 和 Evaluator 负责按该合同执行和裁决。

### 2. TDD 适用范围

推荐使用 `TDD`：

- bug fix，尤其需要先复现回归的修复
- 新行为
- 复杂业务规则
- parser / validator
- 状态迁移或状态机
- public API / CLI 行为变化
- 可以通过 public interface 验证的 caller-visible 行为

保持 `STANDARD`：

- 文档
- 配置
- 机械迁移
- 重命名
- build / include / compile 修复
- 纯删除
- 探索性遗留代码整理
- 无法稳定先写行为测试的底层接线工作

### 3. TDD issue 必须声明 TDD Expectation

当 `Development Mode: TDD` 时，issue 必须包含：

```text
TDD Expectation:
- Behavior Under Test:
- Public Interface:
- Red Test:
- Expected Red Failure:
- Green Target:
- Refactor Boundary:
- Evidence Required:
```

字段含义：

- `Behavior Under Test`：测试要约束的可观察行为。
- `Public Interface`：测试进入系统的接口；优先 public API、CLI、request/response、可见模块接口。
- `Red Test`：第一条行为测试，不应一次性列出所有测试。
- `Expected Red Failure`：预期失败原因，必须是行为缺失或 bug 存在，而不是测试脚手架错误。
- `Green Target`：让该测试通过所需的最小实现目标。
- `Refactor Boundary`：允许清理的范围；不得借 refactor 扩大 scope。
- `Evidence Required`：red output、green output、final verification，以及测试为何是 behavior-bearing 的说明。

## 测试质量规则

### 禁止实现复述型测试

加入 TDD 规则：

```text
Do not add tests which simply restate the implementation. These provide zero confidence.
```

无效测试信号：

- 测试镜像实现里的分支、常量、helper 调用或内部数据结构。
- 测试 private method 或 internal collaborator，而不是可观察行为。
- 内部实现重构但行为不变时，测试会失败。
- 用户可见行为错误时，测试仍可能通过。
- 测试存在的主要目的只是制造 red-green evidence。

有效 RED 测试必须：

- 验证 observable behavior。
- 尽量通过 public interface 进入。
- 能捕获真实 regression。
- 在内部重构后仍应成立。
- 失败原因是目标行为缺失，而不是测试形状与实现形状不匹配。

## pge-plan 修改点

1. 在 issue schema / template 中加入 `Development Mode`。
2. 当 mode 为 `TDD` 时，要求填写 `TDD Expectation`。
3. Engineering Review Gate 增加检查：
   - TDD 是否适用于该 issue。
   - `Red Test` 是否验证行为，而不是实现结构。
   - `Expected Red Failure` 是否明确且可验证。
   - `Green Target` 是否足够小，不提前实现未来行为。
4. Test Coverage Review 对 TDD issue 不只检查覆盖面，还检查测试是否 behavior-bearing。
5. Final Plan Gate 必须拒绝缺少 TDD 合同的 `Development Mode: TDD` issue，避免把不完整计划交给 exec。

## pge-exec Generator 修改点

当 issue 为 `Development Mode: TDD` 时，Generator 必须执行：

```text
1. Write one behavior test.
2. Run it and capture RED.
3. Confirm RED fails for the expected behavior reason.
4. Implement the minimum code needed for GREEN.
5. Run it and capture GREEN.
6. Repeat only for additional behaviors explicitly required by the issue.
7. Refactor only while tests stay green and only inside Refactor Boundary.
8. Run final Verification Hint.
```

Generator completion 必须增加：

```text
tdd_evidence:
  mode: TDD
  behavior_under_test: <behavior>
  red_command: <command>
  red_result: <summary/output path>
  red_failure_reason: <why this is the expected failure>
  green_command: <command>
  green_result: <summary/output path>
  final_verification: <command/output>
  behavior_bearing_rationale: <why this test is not implementation-restating>
```

如果 Generator 无法产生有效 RED，必须报告 `BLOCKED` 或请求 route upstream，不能伪造 RGR。

Generator handoff 必须把 `Development Mode` 和 `TDD Expectation` 作为结构化输入传入，不能只靠自然语言提示。

## pge-exec Evaluator 修改点

Evaluator 不对每个 TDD issue 做串行 gate。Generator completion 先经过 Main 的 Candidate Gate；缺少 red/green evidence、scope drift、self-review 不完整、或 `tdd_evidence` 格式错误，都是 Generator contract failure，直接 repair / classify blocker，不派 Evaluator 兜底。

最终 run-level Evaluator verification 对所有 `Development Mode: TDD` candidates 增加 `Behavior Test Gate`：

```text
Behavior Test Gate:
- Does the RED test verify observable behavior through a public interface?
- Would the test survive internal refactor if behavior stayed the same?
- Would the test fail for a real user/caller-visible regression?
- Did RED fail for the expected reason?
- Did GREEN pass with the minimal implementation?
- Does final verification still pass?
```

自动 RETRY 条件：

- 缺少 red evidence。
- RED 是测试脚手架错误，而非行为缺失。
- 测试只是复述实现。
- 测试检查 private/internal structure。
- GREEN 没有对应 verification output。
- 实现明显超出 `Green Target` 或 `Refactor Boundary`。

Evaluator handoff 必须在 final_run verification 中接收每个 TDD candidate 的 `Development Mode`、`TDD Expectation` 和 `tdd_evidence`，并在 verdict 中输出：

```text
behavior_test_gate: PASS | RETRY | BLOCK
```

## 接受标准

- `pge-exec` 内建 TDD 执行路径，不依赖独立 TDD skill。
- PGE plan issue 可以标记 `Development Mode: STANDARD | TDD`。
- TDD issue 必须包含 `TDD Expectation`。
- TDD issue 的 Generator completion 必须包含 red/green/final verification evidence。
- Main Candidate Gate 能拒绝缺失或格式错误的 TDD evidence；final Evaluator 能拒绝低价值 RGR 证据。
- `STANDARD` issue 不需要承担 TDD ceremony。

## 风险

1. **过度 TDD 化**：如果默认强制 TDD，会拖慢配置、文档、机械修改等任务。
2. **RGR 表演化**：如果只检查 red/green 输出，会诱导实现复述型测试。
3. **测试接口选错**：如果 public interface 不清楚，plan 阶段必须先定义测试入口，否则 exec 容易测内部结构。
4. **并发执行耦合**：TDD issue 可能和其他 issue 共享 verification surface，需要继续依赖 `Verification Coupling` 控制并发安全。

## 推荐落地顺序

1. 更新 `pge-plan` template，加入 `Development Mode` 和 `TDD Expectation`。
2. 更新 Final Plan Gate，拒绝缺少 TDD 合同的 TDD issue。
3. 更新 plan engineering review，增加 TDD suitability / behavior-bearing test 检查。
4. 更新 Generator handoff，增加 TDD execution path 和 `tdd_evidence`。
5. 更新 Evaluator final_run handoff，增加 run-level `Behavior Test Gate`。
6. 用 1 个 bug fix 和 1 个新行为 issue 做试运行，再决定是否扩大默认使用范围。
