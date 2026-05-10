# Multi-Round Evaluation Principles

Shared reference for pge-research (grill step) and pge-plan (self-review). Extracted from superpowers writing-skills RED/GREEN/REFACTOR methodology, adapted for document quality rather than skill compliance.

## Core Idea

Evaluation is not "read it and check if it looks right." It is actively constructing failure scenarios and verifying the artifact survives them. One round of adversarial pressure, then fix and move on.

## Baseline Awareness

Know what artifacts look like WITHOUT review, so you can catch the patterns:

| Common failure mode | What it looks like | Why it survives without review |
|---|---|---|
| Terminology drift | Brief says "auth service", code calls it "identity-provider" | Sounds plausible, never cross-checked |
| Phantom coverage | Plan has 5 issues, but requirement #3 has no issue covering it | Each issue looks complete in isolation |
| Degenerate acceptance | "File exists" as acceptance criterion for a complex feature | Technically verifiable, practically useless |
| Scope creep disguised as thoroughness | 8 issues when 3 would suffice, extra ones are "nice to have" | More issues feels more complete |
| Assumption cascade | One unverified assumption feeds into 3 downstream decisions | Each step looks logical given its inputs |

## Pressure Scenario Thinking

Don't ask "is this correct?" Ask "under what conditions does this fail?"

For research briefs:
- What if the code was refactored last week and your findings are stale?
- What if the terminology you used means something different in another module?
- What if your recommended option has a hidden dependency you didn't explore?

For plans:
- What if Generator interprets the Action differently than you intended?
- What if the acceptance criterion passes but the feature doesn't actually work?
- What if two issues modify the same file and create a merge conflict?

## Rationalization Table

Agents avoid specificity through soft language. Catch these patterns:

| Rationalization | Translation | Counter |
|---|---|---|
| "This is straightforward" | I didn't verify it | Verify or mark as assumption |
| "Standard approach" | I'm guessing based on training data | Check if this repo actually does it that way |
| "Well-known pattern" | I haven't confirmed it applies here | Find the specific file where this pattern exists |
| "Should be simple" | I haven't traced the actual complexity | Read the code path end-to-end |
| "As discussed" / "As noted" | I'm referencing something vague | Cite the specific finding with source |

## Fix-First, Not Report-Only

The review step is not a findings document. It is a repair pass.

- Found a vague term? Replace it with the specific one from the code.
- Found a coverage gap? Add the missing test expectation to the issue.
- Found an assumption? Either verify it (read one more file) or mark it explicitly.
- Found a contradiction? Resolve it — don't flag both sides as "noted."

The only output of review is a better artifact, not a list of concerns.

## Bounded: One Round

One round of adversarial pressure is enough. Don't loop:
- Run the checks / grill points
- Fix everything fixable
- Mark unfixable items as explicit gaps or assumptions
- Move on

Infinite review loops are a form of analysis paralysis. The goal is "good enough to execute safely," not "perfect."
