#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

printf '==> pge-plan template contract smoke test\n'
python3 "$ROOT_DIR/bin/test-pge-plan-template-contract.py"

printf '\n==> pge-plan emitted artifact validator regressions\n'
python3 "$ROOT_DIR/bin/test-validate-pge-plan-artifacts.py"

printf '\n==> pge-plan current emitted fixture validation\n'
python3 "$ROOT_DIR/bin/validate-pge-plan-artifacts.py" \
  "$ROOT_DIR/bin/fixtures/pge-plan-artifacts/current-plan-v2/plan.md" \
  "$ROOT_DIR/bin/fixtures/pge-plan-artifacts/current-plan-v2/workflow-handoff.md"

printf '\nAll pge-plan validation suite checks passed.\n'
