# RUNTIME_TEAM_IMPLEMENTATION_CHECKLIST

This checklist translates the reviewed runtime-team orchestration plan into a bounded implementation sequence.

Use it with:
- `docs/exec-plans/PGE_EXECUTION_LAYER_PLAN.md`
- `docs/exec-plans/CURRENT_MAINLINE.md`
- `docs/exec-plans/ROUND_011_RUNTIME_TEAM_ORCHESTRATION_PLAN.md`
- `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md`

## Execution rule

Do these in order.
Do not claim later items before earlier items are explicit in the repo.

---

## 1. Make one orchestration source of truth explicit

### Goal
Create one authoritative runtime-orchestration definition for:
- state transitions
- route policy
- unsupported-route behavior
- recovery entry points
- team lifecycle assumptions

### Done when
- `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md` is explicitly named as the runtime orchestration source of truth.
- `SKILL.md` no longer acts as the only de facto runtime spec.
- The source of truth includes explicit FSM states, not only prose.

### Evidence
- `docs/exec-plans/RUNTIME_ORCHESTRATION_AUTHORITY.md` is named in control-plane docs.
- `SKILL.md` references it rather than re-specifying the whole runtime.

---

## 2. Close `main` vs Planner ownership

### Goal
Make run-level vs slice-level authority non-overlapping.

### Required split
- `main`: run lifecycle, runtime state, route, stop, recovery, team lifecycle
- Planner: slice shaping, boundary, deliverable, verification path, slice-status advice

### Done when
- `main` and Planner responsibilities are written explicitly.
- Planner cannot be read as owning run-level route or recovery.
- Planner may emit slice-status advice only.

### Evidence
- Ownership table exists in runtime docs.
- No conflicting wording remains in `agents/main.md`, `agents/pge-planner.md`, or runtime docs.

---

## 3. Make unsupported routes fail fast

### Goal
Prevent the runtime from implying loop support that it does not yet implement.

### Required behavior for current stage
- `converged` on bounded single-round success is supported.
- `retry`, `continue`, `return_to_planner` must be explicit:
  - either truly implemented,
  - or fail fast with a clear unsupported-runtime reason.

### Done when
- Route truth table exists for current-stage supported vs deferred behavior.
- Unsupported routes are documented as explicit runtime outcomes, not vague future behavior.

### Evidence
- Route truth table exists in runtime docs.
- Runtime docs no longer imply more loop support than actually exists.

---

## 4. Add artifact-chain validation before final routing

### Goal
Ensure routing only happens from structurally usable artifacts.

### Minimum gates
- planner artifact structurally usable
- generator artifact names resolvable deliverable + evidence
- evaluator artifact is structurally complete and route-usable
- append-only evidence / trace record exists for the step

### Done when
- Artifact gate requirements are documented before final routing.
- The gate applies to planner/generator/evaluator outputs, not only planner preflight.

### Evidence
- Runtime docs explicitly require artifact-chain validation.
- Required sections / resolvability checks are named.

---

## 5. Add checkpoint-driven recovery expectations

### Goal
Make recovery depend on durable records instead of transcript reconstruction.

### Recovery inputs
- latest runtime state
- latest accepted artifact refs
- latest route reason
- latest verifier outcome

### Done when
- Recovery is documented as checkpoint-driven.
- Transcript-only continuity is explicitly rejected as sufficient recovery semantics.

### Evidence
- Runtime docs name the checkpoint inputs.
- Recovery wording is aligned across mainline and runtime docs.

---

## 6. Keep delegation scoped

### Goal
Prevent persistent teams from turning into unconstrained context-sharing.

### Minimum scoped inputs
- Planner gets upstream plan + bounded runtime context
- Generator gets approved slice + minimal execution context
- Evaluator gets approved slice + deliverable + evidence bundle

### Done when
- Role input boundaries are explicit.
- Runtime docs do not imply unrestricted shared context across P/G/E.

### Evidence
- Role input constraints are written in runtime/team docs.

---

## 7. Add contract drift control

### Goal
Stop silent divergence between canonical and runtime-facing contract copies.

### Done when
- The repo names an explicit sync rule, validation rule, or parity check.
- Control-plane docs acknowledge that drift is a live risk and show how it is controlled.

### Evidence
- Drift-control rule is written in runtime/control-plane docs.

---

## 8. Keep `SKILL.md` thin

### Goal
Reduce `skills/pge-execute/SKILL.md` to entry + dispatch + artifact + route/recovery bridge.

### Done when
- `SKILL.md` no longer carries the full thick runtime theory.
- It clearly acts as a thin dispatcher into the orchestration source of truth.

### Evidence
- Runtime orchestration detail has moved to the named authoritative runtime doc(s).
- `SKILL.md` keeps only the minimal operational surface.

---

## 9. Re-validate the bounded runtime

### Goal
Ensure hardening work did not break the currently working bounded path.

### Validation path
- `./bin/pge-local-install.sh`
- `claude -p "/pge-execute test"`

### Done when
- The bounded path still produces explicit artifacts.
- Final route and route reason are still inspectable.
- The repo does not overclaim persistent runtime-team capability after validation.

### Evidence
- One bounded validation run with explicit artifact refs and route outcome.

---

## 10. Only then widen runtime-team claims

Do not claim any of the following until checklist items 1-9 are satisfied and validated:
- persistent runtime-team lifecycle fully implemented
- true multi-round runtime continuation
- full retry loop support
- generalized long-running recovery
- production-grade autonomous runtime organization

This checklist exists to stop the repo from jumping from "team is the target architecture" to "team runtime is already real" without closing the orchestration core first.