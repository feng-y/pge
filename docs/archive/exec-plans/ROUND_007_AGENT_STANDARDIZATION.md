# Round 007: Agent Expression Standardization

## 本轮目标

Standardize the expression structure of the three source-repo agent files (planner, generator, evaluator) to make them cleaner, more consistent, and easier to project into runtime-facing agents.

## Files Changed

- `agents/planner.md` - Standardized expression structure
- `agents/generator.md` - Standardized expression structure
- `agents/evaluator.md` - Standardized expression structure

## Standardized Section Template

All three agent files now follow this consistent structure:

### 1. Frontmatter (YAML)
```yaml
---
name: {agent-name}
description: {one-line description of role and responsibility}
tools: {comma-separated list of tools}
---
```

### 2. `<role>` Section
- What this agent is
- Position in the PGE flow (before/during/after)
- Primary job statement

### 3. `## Responsibility`
- "You own:" list (what this agent is responsible for)
- "You do NOT own:" list (what this agent must not do) [for Generator and Evaluator]

### 4. `## Input`
- What this agent receives
- Clear parameter names and descriptions

### 5. `## Output`
- What this agent must produce
- Structured output specification with required fields

### 6. `## Core Behavior`
- Numbered steps describing the main working process
- Clear, actionable guidance

### 7. `## Forbidden Behavior`
- Clear "must NOT" statements
- Organized by category (for Generator and Evaluator)

### 8. Additional Sections (as needed)
- `## Handling Ambiguity` (Generator, Evaluator)
- `## Handling Blocked Execution` (Generator)
- `## Retry Behavior` (Generator)
- `## Providing Actionable Feedback` (Evaluator)
- `## Interface Role` (Planner)

### 9. `## Quality Bar`
- "A good {agent} output:" with examples
- "A bad {agent} output:" with examples

## What Was Preserved

### Planner semantics preserved:
- Single bounded round heuristic
- Pass-through or cut decision
- Executable PGE spec structure (goal, in_scope, out_of_scope, actual_deliverable, etc.)
- Open questions recording instead of guessing
- Interface role for Generator and Evaluator

### Generator semantics preserved:
- Actual deliverable requirement (not placeholders)
- Local verification (but not final approval)
- Evidence provision
- Known limits declaration
- Deviation reporting
- Boundary adherence
- All forbidden behaviors (scope expansion, self-approval, placeholder artifacts)

### Evaluator semantics preserved:
- Independent validation requirement
- Four verdict types (PASS, RETRY, BLOCK, ESCALATE)
- Deliverable-first validation approach
- Contract compliance checking
- Evidence sufficiency validation
- Task-applicable invariants (not full-suite for trivial work)
- Deviation evaluation
- Actionable feedback requirement
- All forbidden behaviors (no modification, no self-review, no placeholder acceptance)

## What Was Improved in Expression Structure

### Before (inconsistent structure):
- Planner: Simple bullet lists under `## responsibility`, `## input`, `## output`, `## forbidden behavior`
- Generator: Long prose document with embedded examples, inconsistent section hierarchy
- Evaluator: Long prose document with embedded examples, inconsistent section hierarchy
- No frontmatter
- No `<role>` context
- Inconsistent section naming and ordering

### After (standardized structure):
- **Frontmatter**: All three have YAML frontmatter with name, description, tools
- **`<role>` section**: All three clearly state position in PGE flow
- **Consistent sections**: All three follow the same section template
- **Clear boundaries**: "You own" vs "You do NOT own" explicit in Generator and Evaluator
- **Structured outputs**: All three specify required output fields clearly
- **Numbered core behavior**: All three use numbered steps for main process
- **Organized forbidden behavior**: All three have clear "must NOT" statements
- **Quality bar**: All three have good vs bad examples
- **Projectable**: Structure is now ready for later projection into runtime-facing agents

### Specific improvements:

**Planner:**
- Added frontmatter with tools specification
- Added `<role>` section with flow position
- Expanded `## Responsibility` with clear ownership list
- Added `## Interface Role` section to clarify output purpose
- Structured `## Output` with required fields clearly marked
- Added `## Core Behavior` with 7 numbered steps
- Expanded `## Forbidden Behavior` with more examples
- Added `## Quality Bar` with good vs bad examples

**Generator:**
- Added frontmatter with tools specification
- Added `<role>` section with flow position
- Split `## Responsibility` into "You own" and "You do NOT own"
- Structured `## Output` with required fields clearly marked
- Organized `## Core Behavior` into 6 numbered steps
- Organized `## Forbidden Behavior` into 4 clear subsections
- Added `## Handling Ambiguity`, `## Handling Blocked Execution`, `## Retry Behavior` sections
- Improved `## Quality Bar` with clearer good vs bad examples

**Evaluator:**
- Added frontmatter with tools specification
- Added `<role>` section with flow position
- Split `## Responsibility` into "You own" and "You do NOT own"
- Structured `## Output` with required fields and verdict meanings
- Organized `## Core Behavior` into 6 numbered steps
- Organized `## Forbidden Behavior` into 4 clear subsections
- Added `## Handling Ambiguity`, `## Handling Deviations`, `## Providing Actionable Feedback` sections
- Improved `## Quality Bar` with clearer good vs bad examples

## What Was Intentionally Deferred

### Not done in this round:
- **Deep Planner semantic redesign**: Planner semantics were preserved as-is. Only expression structure was standardized. Planner redesign will happen in a separate focused round.
- **Repo-specific knowledge injection**: No domain-specific knowledge was added to agent bodies.
- **Runtime installation layout**: Files remain source-repo definitions, not installed runtime files. No `.claude/` path assumptions were added.
- **Contract structure changes**: The contract structures referenced by agents (round-contract.md, evaluation-contract.md, etc.) were not modified.
- **Semantic expansion**: No new responsibilities or behaviors were added beyond what existed.

### Deferred to later rounds:
- Planner semantic redesign (separate focused round)
- Runtime projection/installation (when needed)
- Repo-specific disclosure docs (separate round)
- Contract structure refinement (if needed)

## Quality Bar Met

✓ All three agents have consistent expression structure
✓ They are easier to read, review, and evolve
✓ They remain source-repo agent definitions (not installed runtime files)
✓ They are closer to standard agent expression style (GSD-like frontmatter and sections)
✓ No unnecessary semantic expansion happened
✓ Role boundaries remain distinct and non-overlapping
✓ Structure is projectable to runtime-facing agents when needed

## Next Steps

1. Test the standardized agents via actual `/pge-execute` invocation
2. Verify runtime correctly loads and uses the agent definitions
3. Consider Planner semantic redesign in a separate focused round (if needed)
4. Consider runtime projection when installation layout is needed
