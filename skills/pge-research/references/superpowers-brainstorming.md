# Superpowers Brainstorming Contract

`pge-research` should behave like an enhanced Superpowers brainstorming pass, not like a generic repo scan and not like a reduced checklist that skips the hard parts. The seedex `spark` skill exposes that brainstorming checklist; PGE keeps the full functional shape and upgrades the output into a research contract for planning.

This file is not background reading. When triggered by `SKILL.md`, it is a stable executable sub-contract for the current research run. Follow it in order, preserve its STOP boundary, and leave explicit evidence in `research.md` for every required move or justified skip.

Length is not the stability risk. This contract can be long as long as each section tells the agent what to do, when to stop, what evidence to write, and what boundary not to cross.

Superpowers brainstorming is strong because it prevents confident guessing:

- It expands before narrowing, so the first plausible interpretation does not silently become the spec.
- It protects the original goal from being replaced by the first plausible implementation path.
- It makes the user participate in goal, scope, and success-shape decisions when those require user authority.
- It asks one focused question at a time instead of dumping a questionnaire on the user.
- It turns soft wishes such as "better", "clearer", or "valuable" into observable success and failure criteria.
- It stops at the artifact boundary instead of sliding into implementation.
- It writes a reviewable artifact instead of leaving the important decisions only in chat.
- It self-reviews the artifact for completeness, coherence, and missing perspective.
- It protects user intent from being rewritten into the agent's convenient local change.

Core alignment mechanism: brainstorming starts from the desired outcome, then explores possible paths. It does not start by selling or comparing implementation paths. When an engineer has already jumped from original goal A to implementation hypothesis B, the brainstorming move is to recover A first, then judge whether B actually serves it.

PGE strengthens that behavior with repo evidence, authority labels, upstream preservation, and a planning handoff. These additions exist to make the brainstorming output safer for engineering execution, not to reduce the original brainstorming moves.

Use this line-by-line functional contract when checking whether `pge-research` preserved brainstorming rather than weakening it. Each item must leave evidence in the research brief or explain why it was skipped.

Stable execution rules:

1. Expand before narrowing.
2. Ask only when user authority is needed, but do ask when it is needed.
3. Keep questions one at a time.
4. Separate problem framing from implementation approach.
5. Write the artifact before claiming completion.
6. Self-review the artifact before routing.
7. Deliver the route and STOP.

1. **Explore project context**
   - Must do: before asking or synthesizing, read the local sources that can change intent, scope, affected areas, terminology, constraints, or verification risk.
   - Evidence to write: `evidence` entries with file/command/source citations; `planning_handoff.likely_affected_areas`; optional Zoom-Out Map when more than one module or flow matters.
   - Enhanced check: each important finding carries authority (`repo_evidence`, `upstream_authoritative`, `user_confirmed`, or `inferred`).
   - Fail route: if project context cannot be inspected enough to avoid guessing, route `BLOCKED` or `NEEDS_INFO`; do not write `READY_FOR_PLAN`.

2. **Offer visual companion**
   - Must do: decide whether the task has an experience surface where a visual, artifact, workflow, CLI, prompt, report, or documentation aid would change understanding.
   - Evidence to write: `experience_scope` plus either captured audience/artifact purpose/experience success shape/what would disappoint, or a concrete `skip_reason`.
   - Enhanced check: for visual or artifact-facing work, record what the companion would clarify for planning even if no companion is produced.
   - Boundary: research may suggest that a visual companion would help; it must not create mockups, choose layout, or decide final design.

3. **Ask clarifying questions**
   - Must do: after repo/upstream exploration, identify whether goal, scope, success shape, compatibility, safety, or user-facing tradeoff still requires user authority.
   - Must not do: open with implementation choices, code paths, or B variants before original goal A is explicit.
   - Must do first: when an implementation hypothesis B is already dominating the conversation, ask the question that recovers original goal A before asking the user to choose between B variants.
   - Evidence to write: `interactive_alignment` with question asked, choices offered, recommendation, answer incorporated; or no-question rationale with authority basis.
   - Enhanced check: if any plan-shaping field is still `inferred`, ask one focused question unless the route is `NEEDS_INFO` / `BLOCKED`.
   - Fail route: if the user answer is required and unavailable, route `NEEDS_INFO`; do not pass inferred intent as confirmed.

4. **Propose 2-3 approaches**
   - Must do: when the prompt is fuzzy, broad, value-laden, or could map to multiple code paths, compare 2-4 problem framings, scope interpretations, or success shapes before selecting one.
   - Evidence to write: `intent_framings` with original goal A, any implementation hypothesis B, assumed user intent, supporting/contradicting evidence, risk if wrong, and what would make it an invalid plan.
   - Enhanced check: reject framings using repo evidence or explicit user/upstream constraints, not taste.
   - Boundary: these are not implementation approaches. Research may recommend the correct problem framing only; `pge-plan` chooses implementation approach.

5. **Present design**
   - Must do: present the selected framing as confirmed intent when user confirmation is needed, or record why evidence is sufficient without another user turn.
   - Evidence to write: `confirmed_intent` with original goal A, problem, goal, scope, non-goals, success shape, and "plan would be wrong if..."; authority labels for key claims.
   - Enhanced check: user words, repo evidence, upstream constraints, and rejected framings must all still point to the selected framing.
   - Boundary: this is not solution design. Research confirms problem, goal, scope, non-goals, and success shape only.

6. **Write design doc**
   - Must do: write `.pge/tasks-<slug>/research.md` before claiming the stage is complete.
   - Evidence to write: all required `research.v2` semantic fields: `schema_version`, `intent_framings`, `confirmed_intent`, `scope_contract`, `success_shape`, `experience_scope`, conditional `design_surface_context`, `upstream_contract`, `evidence`, `ambiguities`, `interactive_alignment`, `planning_handoff`, and `route`.
   - Enhanced check: planning should be able to produce a plan from the brief without redoing research or rereading the original upstream source for missing intent.
   - Boundary: this artifact is a research brief for planning, not a design spec or executable plan.

7. **Spec self-review**
   - Must do: review the written brief before route selection using Upstream Preservation Review, Spec Coverage Gate, Grill Brief, and Final Readiness Review.
   - Evidence to write: Quality Gates result, or compressed gate result for simple tasks, including any repaired gap.
   - Enhanced check: `READY_FOR_PLAN` is forbidden when material upstream/user requirements disappeared without an explicit scope decision.
   - Fail route: fix the brief or route `NEEDS_INFO` / `BLOCKED`; do not hand a shaky artifact to planning.

8. **User reviews written spec**
   - Must do: decide whether the user must review/confirm the framing before planning can fairly proceed.
   - Evidence to write: `interactive_alignment` and `ambiguities` showing confirmed fields, remaining inferred fields, and whether user review is required.
   - Enhanced check: user review is targeted to authority gaps instead of required for every evidence-resolved research artifact.
   - Fail route: if user review is required and not available, route `NEEDS_INFO`.

9. **Deliver spec and STOP**
   - Must do: report the research artifact path and route, then stop.
   - Evidence to write: final `route` and next-stage recommendation.
   - Enhanced check: route is explicit: `READY_FOR_PLAN`, `NEEDS_INFO`, or `BLOCKED`.
   - Boundary: do not invoke `pge-plan`, write issues, or continue into implementation automatically.

Enhancements over plain brainstorming:

| PGE enhancement | Why it exists |
|---|---|
| Evidence-backed repo grounding | Prevents attractive brainstormed framings from ignoring actual code, docs, config, or recent changes. |
| Authority classification | Separates user-confirmed, upstream-authoritative, repo-evidence, and inferred claims so planning does not treat guesses as facts. |
| Upstream contract preservation | Keeps supplied specs, handoffs, plans, and decisions from being compressed into a narrower agent-preferred task. |
| Scope contract | Makes in-scope, out-of-scope, deferred, and "must not silently narrow" explicit before planning. |
| Planning handoff | Converts brainstorming output into constraints and risks `pge-plan` can execute against without re-researching. |
| Route gate | Ends with `READY_FOR_PLAN`, `NEEDS_INFO`, or `BLOCKED`, not a design approval claim. |

These enhancements are additive. They do not permit skipping brainstorming's context exploration, clarifying questions, option/framing comparison, user-facing validation when needed, artifact writing, self-review, or STOP behavior.
