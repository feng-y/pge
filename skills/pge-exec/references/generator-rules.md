# Generator Execution Rules

## Analysis Paralysis Guard

If Generator performs 5+ consecutive Read/Grep/Glob operations without an Edit/Write/Bash that modifies a file:
- STOP immediately
- Either write code OR report BLOCKED with what's preventing progress
- Open-ended investigation without action is Generator drift

## Deviation Classification

When encountering issues during execution:

| Category | Examples | Action |
|----------|----------|--------|
| **auto-fix-local** | Broken test, wrong import, typo, missing null check, format error | Fix silently, no permission needed |
| **auto-fix-critical** | Missing error handling, validation gap, auth check, missing index | Fix + record in deviations |
| **stop-for-architectural** | New service needed, schema change, library swap, scope expansion, public API change | Report BLOCKED immediately |

Priority: stop-for-architectural wins. If unsure → stop-for-architectural.

## No-Change Guard

Each repair attempt MUST change at least one file. If the same input would produce the same output:
- Do not retry
- Report BLOCKED with "same approach exhausted, need different strategy"
- Same failure signature + no code change = infinite loop

## Destructive Git Prohibition

NEVER run:
- `git reset --hard`
- `git clean -f` or `git clean -fd`
- `git push --force`
- `git checkout -- .` (blanket restore)
- `git update-ref` on protected branches (main/master/develop)

If clean state needed: create a new commit that reverts specific changes.

## Package Install Safety

If a package install fails (`npm install`, `pip install`, `cargo add`, `go get`, etc.):
- Do NOT auto-retry with a different package name
- Do NOT guess alternative package names
- Report BLOCKED with the exact error message
- Reason: typosquatting/slopsquat protection

## Scope Boundary

- Only modify files listed in the issue's Target Areas
- Only fix what the issue's Action specifies
- **Target Areas = which files you may touch. Action = what you do in those files. Both must be satisfied.** Modifying a Target Area file for a purpose not described in Action = scope drift.
- Unrelated bugs found → record in `deferred_items`, do not fix
- If the Action requires touching a file not in Target Areas: record as deviation, proceed only if clearly necessary for the Action
- **Plan references wrong path:** If plan references a file that doesn't exist but an obvious equivalent exists (renamed, moved), record as deviation with the correct path and proceed. Evaluator will check if the deviation is justified.

## Self-Review (before completion)

Before sending `generator_completion`:
1. Does the Deliverable exist at the expected path?
2. Does the evidence match what Required Evidence asks for?
3. Did I stay within Target Areas? Any scope drift?
4. Did I satisfy the Test Expectation?
5. Any deviations from the plan? Recorded?

Self-review is NOT self-approval. Evaluator makes the final call.
