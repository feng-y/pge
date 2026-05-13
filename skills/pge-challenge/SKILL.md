---
name: pge-challenge
description: >
  Manual prove-it gate for PGE before ship. Explains the diff, challenges
  current prompt requirements when present, proves implementation matches the
  plan in execution context, and adversarially verifies each meaningful change
  with evidence.
version: 0.2.0
argument-hint: "[task-slug | plan path | base ref]"
allowed-tools:
  - Read
  - Bash
  - Glob
  - Grep
---

# PGE Challenge

Manual prove-it gate before PR/ship.

`pge-review` asks whether the change looks acceptable. `pge-challenge` asks whether the change can prove itself.

This skill does not implement fixes, edit code, create PRs, merge, or deploy. If proof fails, route back to fix/review.

## Core Responsibility

`pge-challenge` must cover two proof chains plus the diff explanation:

1. **Change explanation** — explain what changed and why the diff exists.
2. **Prompt challenge proof** — when a current prompt or latest user constraints exist, prove they were honored, not ignored or overwritten by older artifacts.
3. **Execution self-proof** — prove the implemented change satisfies the active plan, development requirements, acceptance criteria, and required evidence.

Then it adversarially challenges every meaningful change with a failure scenario and evidence.

## Challenge Modes

Select exactly one mode before judging the change:

- `prompt_and_plan` — a current prompt / latest user constraints exist. Prove prompt constraints first, then prove plan fulfillment.
- `execution_self_proof` — no current prompt was supplied for the challenge, but this is an execution context with a plan, run artifact, review output, or other development requirement source. Prompt proof is `not_provided`; prove the implementation against the execution context instead.
- `diff_only` — no prompt and no plan/run/review context are available. This is only valid for an explicit non-PGE ad hoc challenge; it cannot prove PGE plan fulfillment.

Do not route `BLOCK_SHIP` only because no new prompt was supplied. In `execution_self_proof` mode, the plan/run/review/diff are the proof surface.

## Inputs

Accepted inputs:
- current diff
- explicit base ref
- task slug
- `.pge/tasks-<slug>/plan.md`
- `.pge/tasks-<slug>/runs/<run_id>/*`
- current prompt / latest user constraints
- review output from `pge-review`
- other user-provided development requirement sources

If a task slug or plan path is provided, read the plan. If run artifacts exist for the task, read the run manifest, evidence, and review notes needed to prove what was executed. If no plan/run/review context is available, plan fulfillment must be `not_available`; route `BLOCK_SHIP` for PGE-managed implementation work unless the user explicitly requested `diff_only`.

## Base Resolution

Default base:

```bash
git merge-base HEAD origin/main
```

If the user provides a base ref, use it. If base resolution fails, if the working tree is on `main` with no meaningful diff, or if the diff cannot be fairly identified, route `BLOCK_SHIP`.

Use `git diff <base>...HEAD` for committed branch changes and include working-tree diff when uncommitted changes exist.

## Meaningful Change Definition

A meaningful change includes:
- behavior code
- tests
- configs
- generated or runtime contracts
- skill text or agent instructions
- plugin metadata
- docs that change workflow semantics
- validation scripts
- any file that changes how future agents plan, execute, review, verify, or ship

Do not dismiss Markdown or template changes as "docs only" when they change contract behavior.

## Evidence Standard

Evidence can be:
- test command output
- validator output
- grep/trace proving a required contract exists
- diff trace tied to a plan item
- runtime/manual verification record
- screenshot or browser evidence for UI behavior

Pure reasoning is not enough for `PASS`. For docs/skill contract changes, grep + contract validator + line trace can be enough. For behavior changes, prefer tests or executable verification.

## Workflow

### 1. Explain The Diff

Identify:
- `base_ref`
- changed files
- meaningful changes
- change purpose
- whether changes are implementation, test, contract, docs, template, or metadata

### 2. Prompt Challenge Proof

If a current prompt or latest user constraints exist, extract requirements and hard constraints. Include explicit "must", "must not", "only", "do not", latest user corrections, and source-priority instructions.

For each requirement, prove one of:
- implemented
- intentionally not applicable
- contradicted by repo evidence
- not proven

Current prompt outranks older plan/research artifacts. If the diff follows an older artifact but violates the latest prompt, route `NEEDS_FIX`.

If no current prompt was supplied, record `prompt_ref: not_provided`, put one `N/A` row in the Prompt Challenge Matrix, and continue in `execution_self_proof` mode when execution context exists.

### 3. Execution Self-Proof

If a plan exists, map every plan issue and acceptance criterion to:
- diff evidence
- verification evidence
- required evidence status
- verdict

Every READY issue in the plan must be either fulfilled, explicitly out of current scope, or marked not proven. Silent drops route `NEEDS_FIX`.

If run or review artifacts exist, use them as supporting evidence, not as authority to waive the plan. A run note that says "done" is only useful when it points to diff, command, runtime, or manual verification evidence.

If there is no plan but another execution-context source defines development requirements, build the Plan Fulfillment Matrix from that source and label `plan_ref: not_available`.

### 4. Adversarial Challenge

For each meaningful change:
1. State the claim the change makes.
2. Construct one plausible failure scenario.
3. Identify the evidence required to disprove that failure.
4. Run or trace the verification.
5. Mark `PASS`, `FAIL`, or `UNPROVEN`.

### 5. Route

- `BLOCK_SHIP` — base/diff is unclear, challenge cannot fairly run, PGE-managed work lacks any plan/run/review/development requirement source needed to prove fulfillment, or the user requested PGE proof but only `diff_only` evidence exists.
- `NEEDS_FIX` — prompt requirement not honored, plan item unmet, acceptance criterion unproven, meaningful change fails its challenge, or evidence does not support the claim.
- `READY_TO_SHIP` — change explanation is complete, prompt challenge matrix passes or is `N/A` because no current prompt was supplied, execution self-proof passes against the available plan/development requirements, and every meaningful change has failure scenario plus passing evidence.

## Output Contract

```md
## PGE Challenge Result
- challenge_mode: prompt_and_plan | execution_self_proof | diff_only
- base_ref: <sha/ref>
- prompt_ref: <current prompt / latest user constraints / not_provided>
- plan_ref: <path or not_available>
- execution_context_ref: <run artifact / review artifact / development requirement source / not_available>
- changed_files: <count + list>
- route: BLOCK_SHIP | NEEDS_FIX | READY_TO_SHIP
- next: fix and rerun pge-review | rerun pge-challenge | ship

## Change Explanation
- summary:
- meaningful_changes:
  - change:
    type: implementation | test | contract | docs | template | metadata | validation
    files:
    why_it_exists:

## Prompt Challenge Matrix
| Prompt Requirement | Source | Diff Evidence | Verification Evidence | Verdict |
|---|---|---|---|---|
| <requirement or not_provided> | <current prompt / user correction / N/A> | <file:line / diff / N/A> | <command / trace / N/A> | PASS / FAIL / UNPROVEN / N/A |

## Plan Fulfillment Matrix
| Plan Item | Acceptance / Required Evidence | Diff Evidence | Verification Evidence | Verdict |
|---|---|---|---|---|
| <issue or criterion> | <expected> | <file:line / diff> | <command / trace> | PASS / FAIL / UNPROVEN / N/A |

## Review Self-Proof Matrix
| Meaningful Change | Claim | Failure Scenario | Evidence Required | Evidence Produced | Verdict |
|---|---|---|---|---|---|
| <change> | <claim> | <plausible failure> | <needed proof> | <actual proof> | PASS / FAIL / UNPROVEN |

## Gaps
- <only if BLOCK_SHIP or NEEDS_FIX>
```

## Guardrails

- Do not fix implementation.
- Do not create PRs, merge, deploy, or mark shipped.
- Do not treat "tests pass" as sufficient unless the tests cover the claim.
- Do not route `READY_TO_SHIP` with `UNPROVEN` meaningful changes.
- Do not skip prompt constraints just because a plan or research artifact says something else.
