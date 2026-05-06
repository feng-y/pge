# Research Note: AI Agent Team as First Hires

> Source: "How to Build a Team of AI Agents That Replace Your First 3 Hires (Full Course)"
> Date captured: 2026-05-06
> Status: design-learning note, not a runtime contract

## 1. Transferable thesis

The useful design pattern is not the marketing claim that AI agents replace employees.
The reusable architecture is:

```text
Agent = role + tools + knowledge base + workflow + quality gates + shared memory
```

An agent team becomes useful only when each agent has a clear operating loop and the agents share facts across workflows.
A prompt persona alone is insufficient.

## 2. Three-agent pattern in the source

The source describes three business agents:

| Agent | Role | Workflow | Quality control |
| --- | --- | --- | --- |
| Research Agent | market intelligence analyst | periodic sweep of competitors, industry news, social signals | weekly brief with sources and recommended actions |
| Content Agent | content production lead | ideation, drafting, editing, repurposing, scheduling | scoring gates for voice match, hook strength, value density, originality |
| Operations Agent | chief-of-staff assistant | email triage, meeting prep, weekly reports | human review for flagged items and drafted responses |

The agents are coordinated by a shared knowledge base.
Research findings can become content inputs or operational follow-up.

## 3. PGE mapping

PGE should use the pattern structurally, not copy the business roles.

| Source pattern | PGE equivalent |
| --- | --- |
| Research Agent | Planner as resident research / architecture / contract owner |
| Content Agent | Generator as resident coder / integrator / reviewer / evidence packager |
| Operations Agent | Evaluator as resident QA / audit / verdict owner |
| Shared knowledge base | run-scoped shared memory under `.pge-artifacts/<run_id>/` |
| Quality gates | Planner gate, Generator gate, Evaluator gate, validator |

## 4. Design lessons for PGE

### 4.1 Agents must be workflow actors

Each PGE role should be more than a static prompt role.
Each agent needs:

- a resident lifecycle
- an internal workflow
- bounded helper/subagent rules
- durable artifacts
- teammate-to-main canonical event delivery
- quality gates that make compliance observable

### 4.2 Helper usage needs triggers, not permission

Writing "may use subagents" is too weak.
Agents may ignore the option and silently run serially.

PGE helper usage should therefore require visible decisions:

- Planner: research helper decision when repo understanding is the bottleneck
- Generator: `helper_decision` for coder workers and reviewer helpers
- Evaluator: `verification_helper_decision` for independent verification helpers

If trigger conditions are met but helpers are not used, the agent must record why.
This turns helper usage from prompt aspiration into reviewable evidence.

### 4.3 Quality gates prevent first-draft output

The source's content-agent lesson is directly transferable:
AI output degrades when first drafts are accepted.

PGE equivalents:

- Planner must not treat a thin plan as a frozen contract without evidence and self-check.
- Generator must not treat local implementation as final acceptance.
- Evaluator must not treat artifact existence or Generator claims as sufficient evidence.

### 4.4 Shared memory is evidence, not progression

The source emphasizes shared knowledge base.
For PGE, the shared memory should be run-scoped artifacts:

```text
.pge-artifacts/<run_id>/
  input.md
  planner.md
  generator.md
  evaluator.md
  progress.jsonl
  manifest.json
  helper reports when used
```

But shared memory must not replace runtime events.

```text
canonical SendMessage event = progression trigger
artifact / shared memory = evidence and context
```

This keeps Agent Teams coordination live while preserving durable inspectability.

## 5. Implications for current PGE design

Current PGE direction should keep:

- resident Planner / Generator / Evaluator teammates
- Planner parallel research helpers
- Generator coder workers and reviewer helpers
- Evaluator read-only verification helpers
- visible helper decisions in artifacts
- canonical teammate-to-main `SendMessage` events
- artifacts as gates, not triggers

Next useful design work:

1. Define a small run board / shared memory convention.
2. Define helper report artifact naming and minimum fields.
3. Ensure `main` gates helper-decision sections in durable artifacts.
4. Run a real repo validation to verify helpers are actually triggered when conditions apply.

## 6. Non-goals

Do not import the source's business-agent framing literally.
Do not claim agents replace human hires.
Do not let shared memory become file-polling progression.
Do not add permanent roles beyond Planner / Generator / Evaluator for the current PGE stage.
