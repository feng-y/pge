---
name: pge-challenge
description: >
  Manual prove-it gate for PGE before ship. Explains the diff, challenges
  current prompt requirements when present, proves implementation matches the
  plan in execution context, and adversarially verifies each meaningful change
  with evidence.
when_to_use: >
  Use when the user asks for prove-it or 自证.
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

Do not fix implementation, create PRs, merge, deploy, or mark shipped. If proof fails, route back to fix/review.

## Challenge Models

Select exactly one model before judging the change:

- `prove_expected` — prove an implementation satisfies expected behavior from the current prompt plus the plan/development contract.
- `challenge_claim` — challenge a prompt claim, judgment, or change claim before accepting it as true.

No prompt and no execution context means `BLOCK_SHIP`.

## Inputs

Use only the inputs that exist:

- current diff and optional base ref
- task slug, `.pge/tasks-<slug>/plan.md`, and `.pge/tasks-<slug>/runs/<run_id>/*`
- current prompt / latest user constraints
- `pge-review` output or other explicit development requirement source

Current prompt outranks older plan/research artifacts. If a prompt is present, treat it as the highest-priority requirement source. If no prompt is present, do not block solely for that; use the strongest available execution context.

## Base Resolution

```bash
git merge-base HEAD origin/main
```

If the user provides a base ref, use it. If base resolution fails, if the working tree is on `main` with no meaningful diff, or if the diff cannot be fairly identified, route `BLOCK_SHIP`.

Use `git diff <base>...HEAD` for committed branch changes and include working-tree diff when uncommitted changes exist.

## Workflow

### 1. Explain The Diff

Identify:
- `base_ref`
- changed files
- meaningful changes
- change purpose
- change type: implementation | test | contract | docs | template | metadata | validation

Markdown/templates count as meaningful when they change agent workflow semantics.

### 2. Prompt Challenge Proof

If prompt constraints exist, extract hard requirements: "must", "must not", "only", "do not", latest corrections, and source-priority instructions.

For each requirement, prove one of:
- `PASS` — honored with diff and verification evidence
- `FAIL` — contradicted or ignored
- `UNPROVEN` — cannot prove
- `N/A` — intentionally not applicable with reason

If no prompt was supplied, record `prompt_ref: not_provided`, put one `N/A` row in the Prompt Challenge Matrix, and continue from the execution context.

### 3. Execution Self-Proof

Build the Plan Fulfillment Matrix from the strongest available development contract:

1. `.pge/tasks-<slug>/plan.md`
2. explicit plan/spec path from the user
3. `pge-review` output with concrete required evidence
4. current prompt, when it is the only development requirement source

Map every issue, acceptance criterion, required evidence item, and explicit development requirement to diff evidence and verification evidence. Silent drops route `NEEDS_FIX`.

Run/review artifacts can support proof but cannot waive the plan. A note that says "done" only counts when it points to concrete evidence.

### 4. Adversarial Challenge

For each meaningful change, state the claim, one plausible failure scenario, the evidence required, the evidence produced, and the verdict.

In `challenge_claim` mode, restate the claim first, identify what evidence would disprove it, and test the strongest no-change or simpler-change alternative when the claim concerns a change's necessity, correctness, or boundary.

For waits, retries, sleeps, polling, queue timing, or post-completion delay, challenge necessity explicitly: what race or state transition requires it, why a simpler event/condition check is insufficient, what bound prevents hanging or latency creep, and what evidence proves both the wait-needed and no-extra-wait cases.

Pure reasoning is not enough for `PASS`. Use tests, validator output, grep/trace, runtime/manual evidence, screenshots, or file/line proof appropriate to the change.

### 5. Route

- `BLOCK_SHIP` — base/diff is unclear, challenge cannot fairly run, or no prompt/plan/run/review/development requirement source exists.
- `NEEDS_FIX` — prompt requirement failed, plan/development item is unmet or unproven, meaningful change fails its challenge, or evidence does not support the claim.
- `READY_TO_SHIP` — change explanation is complete, prompt challenge matrix passes or is `N/A` because no current prompt was supplied, execution self-proof passes against the available plan/development requirements, and every meaningful change has failure scenario plus passing evidence.

## Output Contract

```md
## PGE Challenge Result
- challenge_model: prove_expected | challenge_claim
- base_ref: <sha/ref>
- prompt_ref: <current prompt / latest user constraints / not_provided>
- claim_source: prompt | change | plan | review | not_applicable
- challenged_claim: <claim / judgment being challenged / not_applicable>
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
