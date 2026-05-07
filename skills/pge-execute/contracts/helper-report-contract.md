# Helper Report Contract

## purpose

Phase-local helpers may improve speed or evidence quality, but they do not own PGE runtime authority.

This contract defines the minimal durable report shape for helper output in the current lane.

## authority

Helper reports are advisory evidence only.

Helpers must not:
- send PGE runtime events to `main`
- freeze Planner contracts
- approve Generator deliverables
- choose Evaluator verdicts or routes
- mutate another phase owner's artifact
- delegate recursively

The owning phase teammate must synthesize helper output into its own durable artifact and canonical runtime event.

## location

When helper output is durable, use:

```text
.pge-artifacts/<run_id>/helpers/<phase>/<helper_id>.md
```

Allowed `<phase>` values:
- `planner`
- `generator`
- `evaluator`

Recommended helper ids:
- `planner-research-01`
- `planner-challenge-01`
- `generator-worker-01`
- `generator-reviewer-01`
- `evaluator-verifier-01`

## minimum sections

Each durable helper report should include:
- `## helper_scope`
- `## sources_checked`
- `## findings`
- `## confidence`
- `## uncertainty`
- `## authority_boundary`

Coding worker reports should also include:
- `## edit_scope`
- `## changed_files`
- `## local_checks`

## reference rule

Phase-owner artifacts must reference helper reports when helpers were used:
- Planner: `planner_note.multi_agent_research_decision.research_report_refs`
- Generator: `helper_decision` and, when relevant, `self_review`
- Evaluator: `independent_verification.verification_helper_decision`

Use `None` only when no helper ran or when the helper output was intentionally not made durable; record the reason.

## quality rule

Helper reports should be short evidence packets:
- source path or command
- fact observed
- confidence
- relevance to the phase owner's decision
- uncertainty or missing evidence

Do not ask helpers for full plans, final approval, route decisions, or broad essays.
