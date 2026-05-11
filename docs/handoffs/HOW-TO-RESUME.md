---
name: pge-research-session
description: >
  How to resume a PGE research + design improvement session.
  Reads the latest handoff, loads research docs, and continues
  where the last session left off.
---
## How to Resume

New session 开头说：

```
读 docs/handoffs/ 下最新的文件，恢复上下文，继续 PGE 调研和完善工作。
```

## What This Session Does

1. 读外部文章/框架，提取对 PGE 有价值的模式
2. 对照 PGE 现状判断 gap（已覆盖 / 小 gap / 不需要）
3. 有价值的保存到 `docs/research/ref-*.md`
4. 可操作的直接改进 skill 文件
5. 结束时更新 `docs/handoffs/` 供下次恢复

## Key Paths

- Skills: `skills/pge-{setup,research,plan,exec,handoff,html}/`
- Research notes: `docs/research/ref-*.md`（14 个框架调研）
- Handoffs: `docs/handoffs/`（session 状态快照）
- Plugin manifest: `.claude-plugin/plugin.json`
- Project rules: `CLAUDE.md`

## Research Sources Already Covered

- Superpowers (168k★) — brainstorming, writing-skills RED/GREEN/REFACTOR
- gstack (88k★) — plan-eng-review 多维度压力测试
- matt-skill (45k★) — grill-with-docs, CONTEXT.md, TDD, diagnose
- GSD (59k★) — discuss→plan→execute→verify, wave execution
- CE (16k★) — compound learning, adversarial reviewer
- RPI/CRISPY — 7 步替代 3 步, cross-model verification
- HeavySkill — parallel reasoning + deliberation
- OpenSpec — delta specs, artifact DAG
- Garry Tan GBrain — thin harness + fat skills + skillify
- Thariq HTML — HTML as agent output format
- Unified Skills 6 层模型 — CANON/Command/Agent/Skill/Artifact/Hook
- Karpathy guidelines — 4 rules (think/simplify/surgical/goal-driven)
- 12-rule CLAUDE.md — Karpathy 4 + 8 additional rules
- Boris/Thariq/Dex prompting patterns

## Current Design State

PGE 管线：pge-research → pge-plan → pge-exec → pge-handoff + pge-html (utility)

核心架构决策（已固定）：
- Generator + Evaluator 分离（不是 3 agent）
- Plan 是 frozen contract（exec 期间不修改）
- Continuous task-dir layout（.pge/tasks-<slug>/）
- Progressive disclosure（SKILL.md < 270 行，details in references/）
- 最小化 HITL
- Outside Voice for MEDIUM + DEEP
- Bounded repair (max 3 per issue)
