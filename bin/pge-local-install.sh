#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: ./bin/pge-local-install.sh [--clean] [--help]

Install the local PGE skill into ~/.claude/skills using the same install shape gstack uses:
- ~/.claude/skills/pge as the runtime root
- ~/.claude/skills/pge-execute/SKILL.md as the top-level discovered skill entry

Options:
  --clean   Remove the local PGE install from ~/.claude/skills and exit.
  --help    Show this help text.
EOF
}

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
skills_dir="${HOME}/.claude/skills"
install_dir="${skills_dir}/pge"
entry_dir="${skills_dir}/pge-execute"
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

mkdir -p "$skills_dir"

if [[ "$clean_only" -eq 1 ]]; then
  rm -rf "$install_dir" "$entry_dir"
  printf 'Removed local PGE install from: %s\n' "$skills_dir"
  exit 0
fi

tmp_dir="$(mktemp -d "${skills_dir}/.pge-local-install.XXXXXX")"
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

mkdir -p \
  "$tmp_dir/.claude-plugin" \
  "$tmp_dir/agents" \
  "$tmp_dir/skills/pge-execute/contracts"

cp "$repo_root/.claude-plugin/plugin.json" "$tmp_dir/.claude-plugin/plugin.json"
cp "$repo_root/SKILL.md" "$tmp_dir/SKILL.md"
cp "$repo_root/skills/pge-execute/SKILL.md" "$tmp_dir/skills/pge-execute/SKILL.md"
cp "$repo_root/agents/planner.md" "$tmp_dir/agents/planner.md"
cp "$repo_root/agents/generator.md" "$tmp_dir/agents/generator.md"
cp "$repo_root/agents/evaluator.md" "$tmp_dir/agents/evaluator.md"
cp "$repo_root/skills/pge-execute/contracts/"*.md "$tmp_dir/skills/pge-execute/contracts/"

python - <<'PY' "$tmp_dir"
import hashlib
import json
import sys
from pathlib import Path

install_root = Path(sys.argv[1])
manifest = json.loads((install_root / '.claude-plugin' / 'plugin.json').read_text())
tracked = [
    install_root / '.claude-plugin' / 'plugin.json',
    install_root / 'SKILL.md',
    install_root / 'skills' / 'pge-execute' / 'SKILL.md',
    *sorted((install_root / 'agents').glob('*.md')),
    *sorted((install_root / 'skills' / 'pge-execute' / 'contracts').glob('*.md')),
]
h = hashlib.sha256()
for path in tracked:
    h.update(path.relative_to(install_root).as_posix().encode())
    h.update(b'\0')
    h.update(path.read_bytes())
    h.update(b'\0')
local_build = h.hexdigest()[:8]
marker = f"[local dev v{manifest['version']}-{local_build}] "

for rel in ['SKILL.md', 'skills/pge-execute/SKILL.md']:
    path = install_root / rel
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
mv "$tmp_dir" "$install_dir"
trap - EXIT

mkdir -p "$entry_dir"
ln -snf "$install_dir/skills/pge-execute/SKILL.md" "$entry_dir/SKILL.md"

manifest_summary="$(python - <<'PY'
import json
from pathlib import Path
install_root = Path.home().joinpath('.claude/skills/pge')
manifest = json.loads((install_root / '.claude-plugin' / 'plugin.json').read_text())
local_build = (install_root / '.local-build').read_text().strip()
print(f"Plugin: {manifest['name']} | Manifest version: {manifest['version']} | Local build: {local_build}")
PY
)"

installed_plugin_warning="$(python - <<'PY'
import json
from pathlib import Path
registry = Path.home() / '.claude' / 'plugins' / 'installed_plugins.json'
if registry.exists():
    data = json.loads(registry.read_text())
    if data.get('plugins', {}).get('pge@pge'):
        print('Warning: marketplace-installed plugin pge@pge is still present in Claude plugin registry.\n         You may see duplicate /pge or /pge-execute entries until that plugin is uninstalled.')
PY
)"

cat <<EOF
Installed local PGE skill to:
  $install_dir
Exposed top-level skill at:
  $entry_dir/SKILL.md
$manifest_summary
${installed_plugin_warning:+$installed_plugin_warning
}
Next steps:
  1. Run the skill directly in Claude Code:
     /pge-execute test
  2. Or smoke-test it from the CLI:
     claude -p "/pge-execute test"
  3. If Claude Code is already running, restart the current session if /pge-execute is not discovered immediately.

Troubleshooting:
  - To remove the local install entirely:
    ./bin/pge-local-install.sh --clean
EOF
