# Learnings: 20260511-0017-smoke

## Patterns Discovered
- Agent Teams communication works as designed: SendMessage dispatches structured packs, agents respond with structured completions/verdicts
- Agents go idle after processing — idle_notification confirms message was consumed
- Generator created file and ran verification before reporting READY
- Evaluator independently verified (ran cat + wc -c) before issuing PASS

## Deviations from Plan
- None

## Repair Insights
- None

## Verification Gaps
- None

## Conventions Confirmed
- Structured dispatch/completion/verdict protocol works end-to-end
- TeamCreate → spawn → SendMessage → idle → TeamDelete lifecycle is stable
- shutdown_request requires brief wait before TeamDelete (agents need time to terminate)

## Feedback to Config
- None
