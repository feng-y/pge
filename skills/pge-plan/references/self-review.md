# Self-Review Loop Reference

Loaded by pge-plan Phase 4. This is the primary quality gate for stable execution.

## Flow

```dot
digraph self_review {
  "Run 6 checks" [shape=box];
  "All pass?" [shape=diamond];
  "Fix failing checks" [shape=box];
  "Re-run failed checks only" [shape=box];
  "Still failing?" [shape=diamond];
  "attempt < 2?" [shape=diamond];
  "Downgrade to NEEDS_INFO" [shape=box];
  "Confidence gate" [shape=diamond];
  "Re-enter Phase 2 Explore\n(1 gap only, max 1 re-entry)" [shape=box];
  "DONE" [shape=doublecircle];

  "Run 6 checks" -> "All pass?";
  "All pass?" -> "Confidence gate" [label="yes"];
  "All pass?" -> "Fix failing checks" [label="no"];
  "Fix failing checks" -> "Re-run failed checks only";
  "Re-run failed checks only" -> "Still failing?";
  "Still failing?" -> "Confidence gate" [label="no"];
  "Still failing?" -> "attempt < 2?" [label="yes"];
  "attempt < 2?" -> "Fix failing checks" [label="yes"];
  "attempt < 2?" -> "Downgrade to NEEDS_INFO" [label="no"];
  "Downgrade to NEEDS_INFO" -> "Confidence gate";
  "Confidence gate" -> "Re-enter Phase 2 Explore\n(1 gap only, max 1 re-entry)" [label="LOW affects correctness"];
  "Confidence gate" -> "DONE" [label="all HIGH/MEDIUM"];
  "Re-enter Phase 2 Explore\n(1 gap only, max 1 re-entry)" -> "Run 6 checks";
}
```

## 6 Review Checks

Run all 6, record pass/fail per check:

1. **Goal-backward verification** — state the goal, work backward: what must be true when done? What artifacts must exist? What wiring connects them? Do the issues produce all of these?
2. **Upstream coverage** — does the plan address everything the upstream input asked for?
3. **Traceability** — for each requirement/finding in upstream, which issue covers it? No silent drops.
4. **Placeholder scan** — search for No Placeholders patterns + Scope Reduction Prohibition phrases. After fixing, verify the replacement is concrete and actionable — not a synonym of the prohibited phrase (e.g., replacing "basic version" with "initial version" is not a fix).
5. **Consistency check** — target areas, acceptance criteria, and issue scopes must align.
6. **Confidence check** — any LOW-confidence assumption affecting correctness? Verify or flag.

## Retry Protocol

- Run all 6 checks. Record pass/fail.
- If all pass: proceed to confidence gate.
- If any fail: fix inline. Re-run ONLY the failed checks.
- If still failing: attempt again (max 2 attempts per failing check).
- After 2 failed attempts: structural issue. Downgrade affected issues to NEEDS_INFO.
- Never loop more than 2 times total.

## Confidence Gate

If check 6 finds LOW-confidence assumption affecting correctness of a READY_FOR_EXECUTE issue:
- Re-enter Phase 2 Explore for that specific gap only.
- Maximum 1 re-entry.
- If still LOW after re-entry: downgrade issue to NEEDS_INFO.

## No Placeholders Rule

These are plan failures — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation"
- "Similar to Issue N" without repeating the relevant context
- Acceptance criteria that cannot be verified ("works correctly", "handles edge cases")
- Vague scope ("update relevant files")
