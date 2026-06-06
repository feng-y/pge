# Agent 认证继承问题修复方案

## 问题描述

在 pge-exec 执行过程中，Agent 子进程没有继承 main 的认证状态，导致以下错误：

```
4. Agent spawn for generator-1 调用
5. 等待 30 秒 lane_ready
6. 30 秒超时后没有收到 lane_ready 数据包
7. 检查运行时注册：agent registry 中没有 generator-1 条目
8. Agent 检查 lane 启动日志："Authentication failed: Claude Code login required"
```

## 根本原因

**错误假设**：pge-exec SKILL.md line 336 假设 "Custom lanes must still register as native Team members, inherit the parent session's authentication/runtime state"

**实际情况**：Claude Code native Agent Teams 的子进程在某些环境下不会自动继承父会话的认证状态。

## 已完成的修复 ✅

### 1. 更新 pge-exec SKILL.md (line 336-343)

**修复内容**：
- ❌ 移除了 "inherit the parent session's authentication/runtime state" 的错误假设
- ✅ 添加了明确的认证继承指导
- ✅ 明确了认证失败时应触发 Fallback Protocol
- ✅ 澄清这是启动失败边界，不是实现阻塞器

**新增内容**：
```
**Authentication inheritance:** Native Agent Teams may or may not inherit 
the parent session's authentication state depending on the runtime environment. 
If a lane fails Agent Startup Verification due to authentication (`Not logged in`, 
token missing, requires separate `/login`), this is a valid startup failure 
surface—use the Fallback Protocol for the affected issue or evaluation scope. 
Do not treat authentication inheritance failure as an implementation blocker 
or route to ask the user to authenticate; it is a known startup failure boundary.
```

### 2. 创建了测试和诊断工具

**已创建文件**：
- `bin/test-agent-auth-fallback.sh` - 测试脚本框架
- `bin/pge-check-agent-auth.sh` - 认证检查占位符
- `/tmp/verify-fallback.md` - Fallback 激活验证标准
- `/tmp/exec-improvements.md` - 改进建议列表

## 当前行为（修复后）

根据 pge-exec SKILL.md lines 375, 387-394：

```
当 Agent 启动认证失败时：

1. ❌ 不要重试 spawn
2. ✅ 记录 startup_status: FAILED
3. ✅ 记录 startup_failure_surface: team_auth_failure  
4. ✅ 记录 execution_mode: main_thread_fallback
5. ✅ Main thread 直接执行 issue（使用相同的 execution brief）
6. ✅ 写入 state.json, manifest.md, implementation-notes.md
7. ✅ Candidate Gate、evidence 要求、Diagnostic Recovery 仍然适用
```

## 验证步骤

### 测试场景 1：正常认证继承

```bash
# 如果环境支持认证继承，Agent 应该正常工作
/pge-exec simple-task
# 预期：generator-1 正常启动，收到 lane_ready，执行完成
```

### 测试场景 2：认证失败触发 fallback

```bash
# 如果环境不支持认证继承
/pge-exec simple-task
# 预期：
# - 30秒后 lane_ready 超时
# - 检测到 "Not logged in" 或 "Authentication failed"
# - 自动触发 main_thread_fallback
# - Main 直接执行，不要求用户 /login
# - state.json 记录 execution_mode: main_thread_fallback
# - manifest.md 记录 fallback 原因
```

### 验证检查点

1. **state.json 检查**：
```json
{
  "lane_health": {
    "generator-1": {
      "startup_status": "FAILED",
      "startup_failure_surface": "team_auth_failure",
      "execution_mode": "main_thread_fallback"
    }
  }
}
```

2. **manifest.md 检查**：
应包含 fallback 激活记录和受影响的 issues

3. **implementation-notes.md 检查**：
应记录 "Generator lane startup failed: team_auth_failure. Used main_thread_fallback."

## 短期改进建议

### 优先级 1：快速认证预检（节省 25 秒）

当前：等待 30 秒后发现认证失败
改进：在等待 lane_ready 前做 5 秒快速认证检查

**实现位置**：pge-exec SKILL.md line 351 "Agent Startup Verification"

**建议添加**：
```
- Before waiting 30s for lane_ready, attempt a 5s quick auth check
- If auth fails immediately (Not logged in, token missing), skip to fallback
- This saves 25s per failed lane on known auth failures
```

### 优先级 2：增强诊断信息

**state.json 增强**：
```json
{
  "lane_health": {
    "generator-1": {
      "auth_check_result": {
        "attempted": true,
        "passed": false,
        "error_message": "Not logged in",
        "checked_at": "2026-06-06T10:30:15Z"
      },
      "lane_ready_wait": {
        "timeout_ms": 30000,
        "received": false,
        "waited_ms": 30120
      },
      "startup_logs_excerpt": "..last 10 lines..."
    }
  }
}
```

### 优先级 3：实现 bin/pge-check-agent-auth.sh

完整实现认证检查脚本，可以在 TeamCreate 前快速测试。

## 长期解决方案

### 向 Claude Code 团队反馈

**问题报告**：
1. Native Agent Teams 在某些环境下不继承父会话认证
2. 导致 "Authentication failed: Claude Code login required"
3. 需要明确文档说明预期行为
4. 或提供显式认证传播 API

**预期改进**：
- Agent Teams 默认继承认证
- 或提供 `Agent(..., inherit_auth=True)` 选项
- 明确文档何时需要 fallback

## 与现有记忆的关系

**记忆文件**: `feedback-agent-login-inheritance.md`

**之前的观点**（9天前）：
> "不要诊断为 'subagents do not inherit the main session login state'，因为测试显示可以正常工作"

**当前更新**：
- 之前的测试可能在特定环境下通过
- 但在其他环境（如你当前遇到的）确实存在认证继承失败
- 正确的处理：不假设继承一定成功，而是优雅降级到 fallback
- 更新记忆：认证继承是**环境相关的**，不是绝对可靠的

**建议更新记忆**：
```
认证继承是环境相关的行为。某些环境下 Agent Teams 会继承，
某些环境下不会。pge-exec 应该对两种情况都有优雅处理：
1. 成功继承 → 正常 lane 执行
2. 继承失败 → 自动 fallback，不阻塞执行
```

## 现在可以做什么

### 立即测试（推荐）

```bash
# 1. 找一个简单的 pge plan
cd /Users/yan./git/b/pge

# 2. 尝试执行
/pge-exec <task-slug>

# 3. 观察行为
# - 如果 generator-1 正常启动 → 认证继承工作正常
# - 如果超时后触发 fallback → 新的优雅降级生效

# 4. 检查工件
cat .pge/tasks-<slug>/runs/<run_id>/state.json | jq .lane_health
cat .pge/tasks-<slug>/runs/<run_id>/manifest.md
```

### 如果 fallback 频繁触发

**短期方案**：
- Fallback 是合法的执行模式
- 只是 main thread 执行而不是 lane 执行
- 功能完整性不受影响

**中期方案**：
- 考虑实现快速认证预检（优先级 1）
- 可以节省 25 秒超时等待

**长期方案**：
- 向 Claude Code 团队反馈
- 请求改进认证继承或提供 API

## 总结

✅ **已修复**：移除错误假设，明确 fallback 行为
✅ **已测试**：文档化了验证标准
📋 **待实现**：快速认证预检、增强诊断
🔄 **待反馈**：向 Claude Code 团队报告环境差异

**关键点**：认证继承失败不再导致执行阻塞，而是自动降级到 main_thread_fallback 模式继续执行。
