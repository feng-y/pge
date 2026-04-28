#!/usr/bin/env bash
set -euo pipefail

# Install the plugin payload to a local Claude Code dev-plugin override.
# The install payload is derived from .claude-plugin/plugin.json.
#
# Usage:
#   ./bin/pge-local-install.sh [plugin-root]
#   ./bin/pge-local-install.sh --uninstall [plugin-root]

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$repo_root/.claude-plugin/plugin.json"

usage() {
  cat <<'EOF'
Usage:
  ./bin/pge-local-install.sh [plugin-root]              Install dev-plugin override
  ./bin/pge-local-install.sh --uninstall [plugin-root]  Remove dev-plugin override
  ./bin/pge-local-install.sh --help                     Show this help

Default plugin-root: ~/.claude/dev-plugins/pge
EOF
}

mode="install"
target_arg=""

case "${1:-}" in
  --help|-h)
    usage
    exit 0
    ;;
  --uninstall)
    mode="uninstall"
    target_arg="${2:-}"
    [[ $# -le 2 ]] || { usage; exit 1; }
    ;;
  "")
    ;;
  *)
    target_arg="$1"
    [[ $# -eq 1 ]] || { usage; exit 1; }
    ;;
esac

python3 - "$repo_root" "$target_arg" "$mode" <<'PY'
import hashlib
import json
import re
import shutil
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
target_arg = sys.argv[2]
mode = sys.argv[3]
manifest = json.loads((repo_root / ".claude-plugin" / "plugin.json").read_text())
plugin_name = manifest["name"]
default_target = Path.home() / ".claude" / "dev-plugins" / plugin_name
target = Path(target_arg).expanduser() if target_arg else default_target

agents = [repo_root / path.removeprefix("./") for path in manifest.get("agents", [])]
skills_root = repo_root / manifest["skills"].removeprefix("./")
skill_dirs = sorted(
    path for path in skills_root.iterdir()
    if path.is_dir() and (path / "SKILL.md").exists()
)

legacy_paths = [
    Path.home() / ".claude" / "skills" / plugin_name,
    Path.home() / ".claude" / "skills" / "pge-execute",
    *(Path.home() / ".claude" / "agents" / agent.name for agent in agents),
]


def remove_path(path: Path) -> list[str]:
    if not path.exists() and not path.is_symlink():
        return []
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    else:
        path.unlink()
    return [str(path)]


def iter_payload_files() -> list[Path]:
    files = [repo_root / ".claude-plugin" / "plugin.json", *agents]
    for skill_dir in skill_dirs:
        files.extend(path for path in sorted(skill_dir.rglob("*")) if path.is_file())
    return files


def compute_local_build() -> str:
    digest = hashlib.sha256()
    for path in sorted(iter_payload_files(), key=lambda item: item.relative_to(repo_root).as_posix()):
        relative = path.relative_to(repo_root).as_posix()
        digest.update(relative.encode())
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()[:12]


if mode == "uninstall":
    removed = []
    removed.extend(remove_path(target))
    for legacy_path in legacy_paths:
        removed.extend(remove_path(legacy_path))

    if removed:
        for path in removed:
            print(f"  - {path}")
    else:
        print("  - nothing to remove")
    print("\nDone.")
    raise SystemExit(0)

plugin_manifest_dir = target / ".claude-plugin"
plugin_manifest_dir.mkdir(parents=True, exist_ok=True)
if target.exists():
    shutil.rmtree(target)
target.mkdir(parents=True, exist_ok=True)
plugin_manifest_dir = target / ".claude-plugin"
plugin_manifest_dir.mkdir(parents=True, exist_ok=True)
shutil.copy2(repo_root / ".claude-plugin" / "plugin.json", plugin_manifest_dir / "plugin.json")

skills_dest = target / "skills"
for skill_dir in skill_dirs:
    dest = skills_dest / skill_dir.name
    dest.parent.mkdir(parents=True, exist_ok=True)
    shutil.copytree(skill_dir, dest)
    print(f"  + skills/{skill_dir.name}/")

agents_dest = target / "agents"
agents_dest.mkdir(parents=True, exist_ok=True)
for agent in agents:
    if not agent.exists():
        raise SystemExit(f"missing manifest agent: {agent.relative_to(repo_root)}")
    shutil.copy2(agent, agents_dest / agent.name)
    print(f"  + agents/{agent.name}")

local_build = compute_local_build()
marker = f"[local dev v{manifest['version']}-{local_build}] "
for skill_dir in skill_dirs:
    installed_skill = skills_dest / skill_dir.name / "SKILL.md"
    text = installed_skill.read_text()
    updated = re.sub(
        r"^(description:\s*)(.+)$",
        lambda match: match.group(1) + marker + match.group(2).removeprefix(marker),
        text,
        count=1,
        flags=re.MULTILINE,
    )
    installed_skill.write_text(updated)

removed_legacy = []
for legacy_path in legacy_paths:
    removed_legacy.extend(remove_path(legacy_path))
for path in removed_legacy:
    print(f"  - {path}")

print(f"\nInstalled to {target}")
print(f"  name: {manifest['name']}")
print(f"  version: {manifest['version']}")
print(f"  description: {manifest['description']}")
print(f"  local build: {local_build}")
PY
