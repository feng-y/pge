---
name: pge-challenge
description: >
  Manual verify gate for PGE. Challenge Claude to prove its changes work before PR.
  Diffs branch against main, constructs failure scenarios,
  and must pass its own test before proceeding.
---

Manual verify / prove-it gate. Diff the current branch against main, then for each meaningful change:

1. Explain what it does and why it's correct.
2. Construct one scenario where it could fail.
3. Run or trace verification that it doesn't fail.

Don't make a PR until every change passes.

Use this as the current manual verify layer in the PGE workflow when you need evidence that implementation matches the plan and survives adversarial checks.
