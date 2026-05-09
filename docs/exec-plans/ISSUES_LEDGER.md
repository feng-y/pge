# ISSUES_LEDGER

Keep this file lightweight. Record only items that help the current mainline move.

## P0 / Blocker

- **Top-level execution docs still contain legacy Team-runtime truth**
  - Impact: High (they can pull future work back toward `pge-execute` + Planner / Generator / Evaluator orchestration even though the active split is `pge-setup -> pge-plan -> pge-exec`)
  - Next: update remaining top-level execution-plan docs so active truth matches the split workflow and legacy runtime material is explicitly marked as reference/migration-only

- **Anti-regression validation for legacy orchestration terms is still incomplete**
  - Impact: High (without repo checks, `TeamCreate` / `SendMessage` / resident-team wording can drift back into active setup/plan/exec surfaces)
  - Next: extend validation/grep checks to cover active docs and split skills against forbidden Team-runtime vocabulary

## P1 / Follow-up

- **Marketplace install path still unverified end-to-end**
  - Impact: Medium (manifest and local install are aligned, but the real Claude Code marketplace flow still needs a proving pass)
  - Next: test `/plugin marketplace add feng-y/pge`, `/plugin install pge@pge`, and refresh/update flow against the split surfaces

- **Secondary historical docs still need cleanup or stronger labeling**
  - Impact: Medium (older round docs can still mislead if read as active runtime authority)
  - Next: review older execution-plan/reference docs and either downgrade them explicitly or leave them outside active truth paths

- **Validator coverage should prove install/output expectations, not just wording**
  - Impact: Medium (wording checks help, but install projection and split artifact expectations should also stay enforced)
  - Next: keep `./bin/pge-local-install.sh --root <tmp>` and contract validation in the proof path for future rounds

## P2 / Park

- Full SDK-runner design and implementation.
- Broad autonomous multi-round execution beyond the current bounded workflow.
- Additional workflow surfaces beyond `pge-setup`, `pge-plan`, and `pge-exec`.

## Resolved

- **Split skill surfaces landed**
  - Result: `pge-setup`, `pge-plan`, and `pge-exec` now exist as the intended active skill surfaces

- **README and CLAUDE top-level identity were realigned**
  - Result: top-level repo docs now describe the split workflow and downgrade the legacy runtime path

- **Local install alignment landed**
  - Result: `.claude-plugin/plugin.json` and `bin/pge-local-install.sh` now project only the split skills and clean up manifest-declared legacy local-dev surfaces
