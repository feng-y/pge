# PGE Resident Agent Workflow Refactor Plan

> Date: 2026-05-06
> Status: design plan
> Scope: Planner / Generator / Evaluator runtime-facing behavior
> Source learning: `docs/design/research/ref-ai-agent-team-first-hires.md`

## 1. Problem statement

PGE cannot rely on role descriptions alone.
Writing that an agent "may use helpers" or "should notify main" does not guarantee runtime behavior.
The live Agent Teams failure showed the core issue:

```text
agent writes artifact
agent marks task completed / exits / goes idle
main never receives canonical event or loses live coordination
```

PGE needs Planner / Generator / Evaluator to behave as resident workflow actors with observable decisions, durable evidence, quality gates, and canonical teammate-to-main messaging.

## 2. Target model

Each PGE agent should follow this shape:

```text
resident agent
+ internal workflow
+ tools
+ run-scoped shared memory
+ helper/subagent trigger rules
+ durable artifact
+ quality gate
+ canonical SendMessage event
+ post-phase responsiveness until shutdown
```

Canonical progression remains:

```text
SendMessage event = progression trigger
artifact / run memory = evidence gate
```

Artifacts must never become the only progression trigger.

## 3. Design principles

1. **Resident by default**
   - Agents do not self-complete after writing an artifact.
   - Agents stay responsive until `main` sends `shutdown_request`.

2. **Workflow, not persona**
   - Each agent has explicit phases, not just a role label.

3. **Helper usage must be observable**
   - Permission to use helpers is insufficient.
   - Each agent must record helper decisions and non-use reasons.

4. **Main owns orchestration, not agent judgment**
   - Agents produce events and artifacts.
   - `main` gates and routes.

5. **No hidden authority delegation**
   - Helpers can collect evidence, code bounded units, or review.
   - Helpers cannot own final plan, integration, verdict, route, or runtime event.

6. **Quality gates prevent first drafts**
   - Planner self-checks contract quality.
   - Generator self-reviews and optionally uses reviewer helpers.
   - Evaluator independently verifies.

## 4. Role target designs

### 4.1 Planner target

Planner is the resident research / architecture / contract owner.

Initial workflow:

```text
input intake
-> ambiguity gate
-> repo understanding / evidence gathering
-> optional parallel research helpers
-> synthesis
-> architecture judgment
-> engineering-review pressure
-> write planner.md
-> SendMessage planner_contract_ready
-> remain resident for clarification/guidance
```

Planner helper model:

```text
research helpers:
  purpose: repo understanding, source discovery, challenge against cut
  mode: read-only
  default: 0-2
  normal max: 3
  hard max: 4
  cannot: write files, freeze contract, define final acceptance, send PGE events
```

Planner post-plan role:

```text
allowed:
  clarify scope / intent / acceptance / architecture constraints
  answer bounded repo / architecture research questions for Generator
  classify issue as execution_issue | contract_issue | replan_needed

forbidden:
  implement code
  override Generator
  override Evaluator
  silently mutate planner.md
```

Required artifact observability:

```text
planner.md:
  evidence_basis
  design_constraints
  planner_note
  planner_escalation
  helper usage or non-use rationale when relevant
```

Post-plan support messages:

```text
planner_support_request:
  producer: Generator or main
  purpose: bounded research / architecture / contract-scope support
  progression: never advances main

planner_support_response:
  producer: Planner
  purpose: evidence-backed answer and replan_needed signal
  progression: advisory evidence only
```

Generator remains local-first. It asks Planner only for broad repo archaeology, architecture interpretation, contract-scope ambiguity, or multi-file pattern discovery that would otherwise overload implementation.

### 4.2 Generator target

Generator is the resident implementation lead.

Initial workflow:

```text
read frozen planner contract
-> executability review
-> implementation shaping
-> helper_decision
-> optional parallel coder workers
-> integrate worker outputs
-> local verification
-> optional reviewer helpers
-> self-review
-> write generator.md
-> SendMessage generator_completion
-> remain resident for implementation clarification/repair questions
```

Generator helper model:

```text
coder workers:
  purpose: bounded implementation units
  trigger: >=2 independent low-conflict work units
  default: 0
  normal max: 2-3
  hard max: 4
  can: edit authorized file scope, run unit verification
  cannot: own integration, decide final deliverable, send PGE events

reviewer helpers:
  purpose: independent read-only review before handoff
  trigger: non-trivial code changes when helper available
  default: 0-1
  hard max: 2
  can: inspect changed files, evidence, scope, verification output
  cannot: edit, approve, replace Evaluator, send PGE events
```

Required artifact observability:

```text
generator.md:
  execution_mode
  work_units
  helper_decision
  planner_support_decision
  changed_files
  local_verification
  evidence
  self_review
  known_limits
  deviations_from_spec
```

`helper_decision` must include:

```yaml
coder_workers: 0 | 1 | 2 | 3 | 4
reviewer_helpers: 0 | 1 | 2
reason: ...
parallel_units: ... | None
not_using_helpers_reason: ... | None
helper_reports: ... | None
```

### 4.3 Evaluator target

Evaluator is the resident independent validation / verdict owner.

Initial workflow:

```text
read planner contract
-> read generator artifact / completion message
-> inspect actual deliverable directly
-> verification_helper_decision
-> optional parallel verification helpers
-> map evidence to acceptance criteria
-> run independent checks
-> choose verdict and next_route
-> write evaluator.md
-> SendMessage final_verdict
-> remain resident for verdict clarification
```

Evaluator helper model:

```text
verification helpers:
  purpose: independent read-only evidence/deliverable checks
  trigger: >=2 independent verification checks, or Generator used coder workers
  default: 0-1
  hard max: 2
  can: inspect deliverable, evidence, verification output, invariants
  cannot: edit files, approve deliverable, choose verdict/route, send PGE events
```

Required artifact observability:

```text
evaluator.md:
  verdict
  evidence
  violated_invariants_or_risks
  required_fixes
  next_route
  route_reason
  independent_verification
```

`independent_verification` must include:

```yaml
verification_helper_decision:
  verification_helpers: 0 | 1 | 2
  reason: ...
  parallel_checks: ... | None
  not_using_helpers_reason: ... | None
  helper_reports: ... | None
```

## 5. Main orchestration changes

`main` should remain a shell, not a fourth agent.

Required behavior:

1. Dispatch bounded prompts to Planner / Generator / Evaluator.
2. Wait for canonical teammate-to-main `SendMessage` event.
3. If event missing but artifact exists, perform at most one protocol repair.
4. Gate referenced artifact after event.
5. Record degraded recovery only when artifact gate passes and current run ownership is unambiguous.
6. Send `shutdown_request` to resident agents during teardown.

Main must not:

- infer success from artifact existence alone
- treat `TaskUpdate(status: completed)` as phase completion
- treat idle notification or recap as canonical event
- poll files as the normal progression mechanism

## 6. Shared run memory design

PGE should introduce a small run board convention without turning files into progression triggers.

Candidate layout:

```text
.pge-artifacts/<run_id>/
  input.md
  planner.md
  generator.md
  evaluator.md
  progress.jsonl
  manifest.json
  helper-reports/
    planner-*.md
    generator-coder-*.md
    generator-reviewer-*.md
    evaluator-verifier-*.md
```

Minimum helper report fields:

```text
helper_type
assigned_question_or_unit
files_read_or_modified
facts_or_changes
verification_or_review_result
risks
confidence
owner_note
```

Rules:

- helper reports are evidence/context only
- helper reports never trigger phase progression
- parent agent must summarize material helper findings in its durable phase artifact

## 7. Implementation phases

### Phase 1: Contract hardening

Files:

```text
agents/pge-planner.md
agents/pge-generator.md
agents/pge-evaluator.md
skills/pge-execute/handoffs/planner.md
skills/pge-execute/handoffs/generator.md
skills/pge-execute/handoffs/evaluator.md
skills/pge-execute/ORCHESTRATION.md
bin/pge-validate-contracts.sh
```

Tasks:

- Make resident lifecycle explicit for all three agents.
- Add helper/subagent trigger rules.
- Add helper decision artifact requirements.
- Forbid `TaskUpdate(status: completed)` as phase completion.
- Require post-phase responsiveness until shutdown.

Acceptance:

```text
bash -n bin/pge-validate-contracts.sh
bash bin/pge-validate-contracts.sh
git diff --check
```

### Phase 2: Helper report convention

Files:

```text
skills/pge-execute/runtime/artifacts-and-state.md
skills/pge-execute/contracts/round-contract.md
skills/pge-execute/handoffs/*.md
bin/pge-validate-contracts.sh
```

Tasks:

- Define `helper-reports/` path convention.
- Define minimum helper report fields.
- Require parent agents to cite helper reports in `planner.md`, `generator.md`, or `evaluator.md` when used.
- Keep helper reports non-authoritative.

Acceptance:

```text
validator checks helper report path convention
validator checks helper reports are evidence only, not progression triggers
```

### Phase 3: Main gates for decisions

Files:

```text
skills/pge-execute/SKILL.md
skills/pge-execute/ORCHESTRATION.md
skills/pge-execute/handoffs/generator.md
skills/pge-execute/handoffs/evaluator.md
bin/pge-validate-contracts.sh
```

Tasks:

- Gate `## helper_decision` in durable Generator artifact.
- Gate `verification_helper_decision` inside Evaluator `## independent_verification`.
- Ensure non-use explanations are inspectable.
- Avoid adding retry loops or new runtime stages.

Acceptance:

```text
normal non-test generator artifact without helper_decision fails gate
normal evaluator artifact without verification_helper_decision fails gate
smoke/test remains lightweight but explicit about omitted helper decisions when applicable
```

### Phase 4: Real run validation

Use a real repo task where helper triggers should apply.

Evidence to collect:

```text
run_id
planner artifact
planner helper use or non-use rationale
generator artifact
generator helper_decision
generator helper reports when used
evaluator artifact
evaluator verification_helper_decision
canonical SendMessage event trace
validator output
final verdict / route
```

Pass criteria:

```text
- Planner does not exit after planner_contract_ready
- Generator uses or explicitly justifies not using coder/reviewer helpers
- Evaluator uses or explicitly justifies not using verification helpers
- main advances by canonical events plus gates
- artifacts prove helper decisions, not just role descriptions
```

## 8. Risks and mitigations

| Risk | Impact | Mitigation |
| --- | --- | --- |
| Agent Teams teammate cannot spawn helper agents reliably | Helper workflow becomes aspirational | Keep serial fallback but require non-use reason and runtime spike |
| Too much prompt bloat | Lower instruction compliance | Keep SKILL.md thin; put details in handoffs/agent files/contracts |
| Helper reports become file-based progression | Regresses to polling | State helper reports are evidence only; event remains progression trigger |
| Agents overuse helpers on trivial tasks | Latency/cost blowup | Trigger rules include overhead/trivial/smoke exceptions |
| Parent agents delegate authority to helpers | Loss of P/G/E boundaries | Validator checks parent-only ownership language |

## 9. Verification checklist

Before considering this refactor complete:

```text
1. bash -n bin/pge-validate-contracts.sh
2. bash bin/pge-validate-contracts.sh
3. git diff --check
4. live /pge-execute run on a real repo task
5. inspect artifacts for helper decisions and event delivery
6. confirm teardown sends shutdown_request
```

## 10. Non-goals

- Do not add permanent roles beyond Planner / Generator / Evaluator.
- Do not convert PGE into a file-polling runtime.
- Do not implement multi-round retry in this refactor.
- Do not let Generator self-approve.
- Do not let Evaluator modify deliverables.
- Do not make `main` a reasoning agent.
