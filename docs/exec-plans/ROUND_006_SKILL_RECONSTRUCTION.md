# Round 006: Standard Skill Reconstruction

## 本轮目标

Rebuild PGE into a standard Claude Code skill shape and remove the bash-first orchestration mistake.

## What Changed

### Files Deleted
- `skills/pge-execute/skill.sh` (433 lines of bash orchestration brain)

### Files Modified
- `skills/pge-execute/SKILL.md` (converted from documentation-only to prompt-first orchestration entrypoint)

### Files Preserved
All semantic/source-of-truth files preserved at that stage:
- `agents/planner.md`
- `agents/generator.md`
- `agents/evaluator.md`
- `contracts/*.md` (5 files)
- `docs/` (all files)

Historical note: this round predated the later seam cleanup that removed `agents/main.md` and moved `main` orchestration semantics into `skills/pge-execute/ORCHESTRATION.md`.

## Old Architecture (Incorrect)

```
skills/pge-execute/
├── SKILL.md          # Documentation only, not used by runtime
└── skill.sh          # 433-line bash orchestration brain
                      # Hardcoded agent simulation with bash functions
                      # spawn_planner(), spawn_generator(), spawn_evaluator()
                      # State management in bash
                      # Routing logic in bash

agents/               # Semantic definitions, not used by runtime
contracts/            # Semantic definitions, not used by runtime
```

**Problem**: Bash-first orchestration. The skill was a bash script that simulated agents with hardcoded functions. The semantic agent files existed but weren't used by the runtime.

## New Architecture (Standard)

```
skills/pge-execute/
└── SKILL.md                        # Prompt-first orchestration entrypoint
                                    # Spawns agents from agents/ directory

agents/                             # Agent definitions (authoritative)
├── planner.md                      # Planner agent
├── generator.md                    # Generator agent
├── evaluator.md                    # Evaluator agent
└── main.md                         # Main routing agent

contracts/                          # Contract definitions (authoritative)
├── round-contract.md
├── evaluation-contract.md
├── routing-contract.md
├── runtime-state-contract.md
└── entry-contract.md
```

**Solution**: Prompt-first orchestration. SKILL.md is the real entrypoint that spawns agents from `agents/` directory using the Agent tool. No duplication, no separate runtime layer.

## Architecture

### Single Unified Layer
- `skills/pge-execute/SKILL.md`: Orchestration entrypoint
- `agents/`: Agent definitions (planner, generator, evaluator, main)
- `contracts/`: Contract definitions (round, evaluation, routing, etc.)
- `docs/`: Design and planning documents

**No separation needed**: The skill directly spawns agents from `agents/` directory. No runtime-facing duplicates. The agent files are both the semantic definitions AND the runtime implementations.

## How the New Skill Works

### 1. Skill Invocation
User runs: `/pge-execute "upstream plan text"`

### 2. SKILL.md Orchestrates
`skills/pge-execute/SKILL.md` contains the orchestration logic:
- Initialize runtime state
- Spawn planner agent from `agents/planner.md`
- Run preflight check
- Spawn generator agent from `agents/generator.md`
- Spawn evaluator agent from `agents/evaluator.md`
- Route based on verdict

### 3. Agents Execute
Each agent in `agents/` directory:
- Is spawned using the Agent tool with its .md file as instructions
- Receives input from the skill
- Executes its responsibility
- Produces structured output per contracts

### 4. Artifacts Produced
All artifacts written to `.pge-artifacts/`:
- `{run_id}-planner-output.md`
- `{run_id}-generator-output.md`
- `{run_id}-evaluator-verdict.md`
- `{run_id}-round-summary.md`

## Why skill.sh Was Removed

`skill.sh` was the orchestration brain (433 lines). It contained:
- Hardcoded bash functions simulating agents
- State management logic
- Routing logic
- Artifact generation logic

This violated the standard Claude Code skill model where:
- SKILL.md should be the orchestration entrypoint
- Subagents should be prompt-based, not bash functions
- Orchestration should be prompt-first, not bash-first

**Decision**: Remove `skill.sh` entirely. The orchestration logic now lives in SKILL.md as prompt instructions.

## How the Skill Uses Agent Files

### Direct Agent Spawning
The skill spawns agents directly from `agents/` directory:
- Planner: Load `agents/planner.md` as instructions, spawn with Agent tool
- Generator: Load `agents/generator.md` as instructions, spawn with Agent tool
- Evaluator: Load `agents/evaluator.md` as instructions, spawn with Agent tool

### No Duplication
- No separate "runtime-facing" agent files
- No `.claude/agents/` directory
- Agent files in `agents/` are both definitions AND implementations
- Contracts in `contracts/` define the handoff structures

### Single Source of Truth
- `agents/` files are authoritative for agent behavior
- `contracts/` files are authoritative for handoff structures
- `skills/pge-execute/SKILL.md` orchestrates by spawning agents
- No conflicts, no synchronization needed

## What Should Be Validated Next

### 1. Skill Invocation Test
Test that `/pge-execute` skill can be invoked:
```
/pge-execute "Create a simple test file at test.txt with content 'hello world'"
```

Expected:
- Skill loads SKILL.md
- Spawns pge-planner subagent
- Planner produces round contract
- Preflight passes
- Spawns pge-generator subagent
- Generator creates test.txt
- Spawns pge-evaluator subagent
- Evaluator validates test.txt exists
- Routes to converged

### 2. Subagent Loading Test
Verify that subagents actually load their .md files:
- Check that pge-planner reads its instructions
- Check that pge-generator reads its instructions
- Check that pge-evaluator reads its instructions

### 3. Artifact Production Test
Verify artifacts are produced:
- `.pge-artifacts/{run_id}-planner-output.md` exists
- `.pge-artifacts/{run_id}-generator-output.md` exists
- `.pge-artifacts/{run_id}-evaluator-verdict.md` exists
- Runtime state `.pge-runtime-state.json` exists

### 4. Semantic Alignment Test
Verify runtime agents follow semantic definitions:
- Generator produces actual deliverables (not placeholders)
- Evaluator independently validates (not rubber-stamps)
- Planner produces executable contracts (not ambiguous)

### 5. Routing Test
Verify routing logic works:
- PASS verdict routes to converged (single_round mode)
- RETRY verdict routes to retry
- BLOCK verdict routes appropriately
- ESCALATE verdict routes to return_to_planner

## Quality Bar Met

✓ PGE now has a standard Claude Code skill entrypoint
✓ Runtime-facing agents are in the standard location
✓ skill.sh is no longer the orchestration brain
✓ Repo's existing semantic files are preserved
✓ Resulting structure is standard, minimal, and ready for validation

## Next Action

Test via actual `/pge-execute` skill invocation to verify runtime properly loads and executes agent .md files (not embedded stubs).
