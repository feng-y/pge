---
name: pge-challenge
description: >
  Challenge Claude to prove its changes work before PR.
  Diffs branch against main, constructs failure scenarios,
  and must pass its own test before proceeding.
---

Prove to me this works. Diff the current branch against main, then for each meaningful change:

1. Explain what it does and why it's correct.
2. Construct one scenario where it could fail.
3. Run or trace verification that it doesn't fail.

Don't make a PR until every change passes.
