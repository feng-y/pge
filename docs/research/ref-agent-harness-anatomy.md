---
title: The Anatomy of an Agent Harness
source: https://x.com/akshay_pachaar (Apr 6, 2026)
relevance: Validates PGE's architecture against industry harness patterns
---

# Reference: The Anatomy of an Agent Harness

## Summary

Agent harness = complete software infrastructure wrapping an LLM: orchestration loop, tools, memory, context management, state persistence, error handling, and guardrails. "If you're not the model, you're the harness."

Key evidence: LangChain changed only infrastructure (same model, same weights) and jumped from outside top 30 to rank 5 on TerminalBench 2.0.

## 12 Components of a Production Harness

1. **Orchestration Loop** — TAO cycle (Thought-Action-Observation). Often just a while loop.
2. **Tools** — Schema-defined capabilities. Registration, validation, sandboxed execution, result formatting.
3. **Memory** — Short-term (conversation) + long-term (cross-session). Three-tier: index → topic files → raw transcripts.
4. **Context Management** — Core problem: context rot (30%+ degradation in mid-window). Strategies: compaction, observation masking, just-in-time retrieval, sub-agent delegation.
5. **Prompt Construction** — Hierarchical: system prompt + tool defs + memory + history + current message.
6. **Output Parsing** — Native tool calling (structured tool_calls objects, not free-text parsing).
7. **State Management** — Checkpointing at boundaries. Git commits as checkpoints. Progress files as scratchpads.
8. **Error Handling** — 10-step process at 99% per-step = ~90.4% end-to-end. Four types: transient, LLM-recoverable, user-fixable, unexpected.
9. **Guardrails** — Input/output/tool guardrails. Tripwire mechanism. Permission enforcement separate from model reasoning.
10. **Verification Loops** — Rules-based (tests, linters), visual (screenshots), LLM-as-judge. "Giving the model a way to verify its work improves quality 2-3x."
11. **Subagent Orchestration** — Fork, Teammate, Worktree models. Minimize: maximize single agent first.

## Seven Architecture Decisions

1. Single-agent vs multi-agent (maximize single first, split only at ~10+ overlapping tools)
2. ReAct vs plan-and-execute (LLMCompiler: 3.6x speedup with plan-and-execute)
3. Context window strategy (ACON: 26-54% token reduction preserving 95%+ accuracy)
4. Verification loop design (guides = feedforward, sensors = feedback)
5. Permission architecture (permissive vs restrictive)
6. Tool scoping (Vercel removed 80% of tools, got better results)
7. Harness thickness (thin + model improvement vs explicit graph control)

## PGE Mapping

| Component | PGE Implementation |
|-----------|-------------------|
| Orchestration | pge-exec main loop: dispatch → completion → verdict → next |
| Tools | Claude Code native (Read/Write/Edit/Bash) |
| Memory | pge-handoff + learnings.md + .pge/config/ |
| Context Mgmt | Execution pack (per-issue context), Session Hygiene thresholds |
| Prompt Construction | Structured dispatch templates (generator.md, evaluator.md) |
| Output Parsing | Structured generator_completion / evaluator_verdict |
| State | state.json + resume support + git tags |
| Error Handling | Retry(max 3) → BLOCKED, rewind-style retry |
| Guardrails | Target Areas scope check, deviation classification |
| Verification | Independent Evaluator + Final Review Gate |
| Subagents | Agent Teams (generator/evaluator/reviewer), adaptive scaling |

## Key Insights for PGE

- "Changing only the harness moved agents by 20+ ranking positions" — harness optimization > model switching
- "Thin harness + model improvement" — PGE's markdown-protocol approach is future-proof
- "Context rot in mid-window" — execution pack's precise context trimming addresses this
- "Verification loops improve quality 2-3x" — independent Evaluator is PGE's core advantage
- "Co-evolution: model post-trained with specific harness" — PGE skills native to Claude Code's skill loading
- "Maximize single agent first" — PGE defaults to 1 generator, scales only when conditions met
