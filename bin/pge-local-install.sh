#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./bin/pge-local-install.sh [--clean] [--help]

Install the local PGE plugin as a dev-plugin override at ~/.claude/dev-plugins/pge.
This replaces the active local PGE override surface without creating parallel
~/.claude/skills/pge-execute or ~/.claude/agents/pge-* entries.

Options:
  --clean   Remove the local PGE dev-plugin override and legacy helper outputs, then exit.
  --help    Show this help text.
EOF
}

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
dev_plugins_dir="${HOME}/.claude/dev-plugins"
legacy_skills_dir="${HOME}/.claude/skills"
legacy_agents_dir="${HOME}/.claude/agents"
install_dir="${dev_plugins_dir}/pge"
legacy_runtime_root="${legacy_skills_dir}/pge"
legacy_entry_dir="${legacy_skills_dir}/pge-execute"
clean_only=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --clean)
      clean_only=1
      shift
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown argument: %s\n\n' "$1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

mkdir -p "$dev_plugins_dir"

cleanup_legacy_helper_outputs() {
  rm -rf "$legacy_runtime_root" "$legacy_entry_dir"
  rm -f \
    "$legacy_agents_dir/pge-planner.md" \
    "$legacy_agents_dir/pge-generator.md" \
    "$legacy_agents_dir/pge-evaluator.md"
}

if [[ "$clean_only" -eq 1 ]]; then
  rm -rf "$install_dir"
  cleanup_legacy_helper_outputs
  printf 'Removed local PGE dev-plugin override from: %s\n' "$install_dir"
  printf 'Removed legacy helper outputs from: %s and %s\n' "$legacy_skills_dir" "$legacy_agents_dir"
  exit 0
fi

tmp_dir="$(mktemp -d "${dev_plugins_dir}/.pge-local-install.XXXXXX")"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

mkdir -p "$tmp_dir/.claude-plugin"
cp "$repo_root/.claude-plugin/plugin.json" "$tmp_dir/.claude-plugin/plugin.json"

python - <<'PY' "$repo_root" "$tmp_dir"
import hashlib
import json
import shutil
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
install_root = Path(sys.argv[2])
manifest = json.loads((repo_root / '.claude-plugin' / 'plugin.json').read_text())

def copy_declared_path(relative_path: str) -> None:
    normalized = relative_path.removeprefix('./')
    source = repo_root / normalized
    target = install_root / normalized
    if not source.exists():
        raise SystemExit(f"Manifest path does not exist: {relative_path}")
    target.parent.mkdir(parents=True, exist_ok=True)
    if source.is_dir():
        shutil.copytree(source, target, dirs_exist_ok=True)
    else:
        shutil.copy2(source, target)

copy_declared_path('.claude-plugin/plugin.json')
copy_declared_path(manifest['skills'])
for agent_path in manifest.get('agents', []):
    copy_declared_path(agent_path)

tracked = sorted(path for path in install_root.rglob('*') if path.is_file())
h = hashlib.sha256()
for path in tracked:
    h.update(path.relative_to(install_root).as_posix().encode())
    h.update(b'\0')
    h.update(path.read_bytes())
    h.update(b'\0')
local_build = h.hexdigest()[:8]
marker = f"[local dev v{manifest['version']}-{local_build}] "

for path in sorted(install_root.glob('skills/**/SKILL.md')):
    lines = path.read_text().splitlines()
    for i, line in enumerate(lines):
        if line.startswith('description: '):
            original = line[len('description: '):]
            if original.startswith('[local dev '):
                end = original.find('] ')
                if end != -1:
                    original = original[end + 2:]
            lines[i] = f'description: {marker}{original}'
            break
    path.write_text('\n'.join(lines) + '\n')

(install_root / '.local-build').write_text(local_build + '\n')
PY

rm -rf "$install_dir"
cleanup_legacy_helper_outputs
mv "$tmp_dir" "$install_dir"
trap - EXIT

manifest_summary="$(python - <<'PY'
import json
from pathlib import Path
install_root = Path.home().joinpath('.claude/dev-plugins/pge')
manifest = json.loads((install_root / '.claude-plugin' / 'plugin.json').read_text())
local_build = (install_root / '.local-build').read_text().strip()
print(f"Plugin: {manifest['name']} | Manifest version: {manifest['version']} | Local build: {local_build}")
PY
)"

cat <<EOF
Installed local PGE dev-plugin override to:
  $install_dir
Removed legacy helper-created skill and agent surfaces from:
  $legacy_skills_dir
  $legacy_agents_dir
$manifest_summary
Next steps:
  1. Reload plugins in Claude Code:
     /reload-plugins
  2. Run the skill directly in Claude Code:
     /pge-execute test
  3. Or smoke-test it from the CLI:
     claude -p "/pge-execute test"

Troubleshooting:
  - To remove the local override and return to marketplace visibility:
    ./bin/pge-local-install.sh --clean
EOF
