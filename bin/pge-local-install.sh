#!/usr/bin/env bash
set -euo pipefail

# Manifest-driven component installer for PGE.
# Reads .claude-plugin/plugin.json and installs skills and agents to Claude Code directories.
#
# Usage:
#   ./bin/pge-local-install.sh                          Install components to ~/.claude
#   ./bin/pge-local-install.sh --root /path/to/base     Install to /path/to/base/.claude
#   ./bin/pge-local-install.sh --uninstall              Remove installed components
#   ./bin/pge-local-install.sh --root /path --uninstall Remove installed components from /path/.claude
#   ./bin/pge-local-install.sh --help                   Show this help

repo_root="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
manifest="$repo_root/.claude-plugin/plugin.json"

usage() {
  cat <<'EOF'
Usage:
  ./bin/pge-local-install.sh
  ./bin/pge-local-install.sh --root /path/to/base
  ./bin/pge-local-install.sh --uninstall
  ./bin/pge-local-install.sh --root /path/to/base --uninstall
  ./bin/pge-local-install.sh --help

Default install targets:
  ~/.claude/skills/
  ~/.claude/agents/

With --root /path/to/base, installs to:
  /path/to/base/.claude/skills/
  /path/to/base/.claude/agents/
EOF
}

mode="install"
claude_home="$HOME/.claude"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    --uninstall)
      mode="uninstall"
      shift
      ;;
    --root)
      [[ $# -ge 2 ]] || { usage; exit 1; }
      claude_home="$2/.claude"
      shift 2
      ;;
    --root=*)
      claude_home="${1#--root=}/.claude"
      shift
      ;;
    *)
      usage
      exit 1
      ;;
  esac
done

python3 - "$repo_root" "$mode" "$claude_home" <<'PY'
import hashlib
import json
import re
import shutil
import sys
from pathlib import Path

repo_root = Path(sys.argv[1])
mode = sys.argv[2]
claude_home = Path(sys.argv[3]).expanduser()
manifest = json.loads((repo_root / ".claude-plugin" / "plugin.json").read_text())

# Parse manifest
agents = [repo_root / path.removeprefix("./") for path in manifest.get("agents", [])]
skills_root = repo_root / manifest["skills"].removeprefix("./")
allowed_skill_names = manifest.get("skill_directories")
if allowed_skill_names:
    allowed_skill_names = set(allowed_skill_names)
    skill_dirs = sorted(
        path for path in skills_root.iterdir()
        if path.is_dir() and path.name in allowed_skill_names and (path / "SKILL.md").exists()
    )
else:
    skill_dirs = sorted(
        path for path in skills_root.iterdir()
        if path.is_dir() and (path / "SKILL.md").exists()
    )
legacy_cleanup = manifest.get("legacy_cleanup", {})
legacy_skill_names = set(legacy_cleanup.get("skills", []))
legacy_agent_names = set(legacy_cleanup.get("agents", []))

# Target directories
skills_target = claude_home / "skills"
agents_target = claude_home / "agents"

# Marker for tracking installed components
MARKER_PREFIX = "[local dev v"


def has_marker(file_path: Path) -> bool:
    """Check if a file contains the local dev marker."""
    if not file_path.exists() or not file_path.is_file():
        return False
    try:
        text = file_path.read_text()
        return MARKER_PREFIX in text
    except Exception:
        return False


def remove_path(path: Path) -> list[str]:
    """Remove a path if it exists."""
    if not path.exists() and not path.is_symlink():
        return []
    if path.is_dir() and not path.is_symlink():
        shutil.rmtree(path)
    else:
        path.unlink()
    return [str(path)]


def compute_local_build() -> str:
    """Compute a hash of all installed files for version tracking."""
    digest = hashlib.sha256()
    files = [*agents]
    for skill_dir in skill_dirs:
        files.extend(sorted(skill_dir.rglob("*")))

    for path in sorted(files, key=lambda p: p.relative_to(repo_root).as_posix() if p.is_relative_to(repo_root) else str(p)):
        if not path.is_file():
            continue
        relative = path.relative_to(repo_root).as_posix() if path.is_relative_to(repo_root) else path.name
        digest.update(relative.encode())
        digest.update(b"\0")
        digest.update(path.read_bytes())
        digest.update(b"\0")
    return digest.hexdigest()[:12]


if mode == "uninstall":
    removed = []

    # Remove currently managed skills with marker
    for skill_dir in skill_dirs:
        skill_target = skills_target / skill_dir.name
        skill_md = skill_target / "SKILL.md"
        if skill_target.exists() and has_marker(skill_md):
            removed.extend(remove_path(skill_target))

    # Remove legacy skills with marker when requested by manifest cleanup policy
    for skill_name in legacy_skill_names:
        skill_target = skills_target / skill_name
        skill_md = skill_target / "SKILL.md"
        if skill_target.exists() and has_marker(skill_md):
            removed.extend(remove_path(skill_target))

    # Remove currently managed agents with marker
    for agent in agents:
        agent_target = agents_target / agent.name
        if agent_target.exists() and has_marker(agent_target):
            removed.extend(remove_path(agent_target))

    # Remove legacy agents with marker when requested by manifest cleanup policy
    for agent_name in legacy_agent_names:
        agent_target = agents_target / agent_name
        if agent_target.exists() and has_marker(agent_target):
            removed.extend(remove_path(agent_target))

    if removed:
        for path in removed:
            print(f"  - {path}")
    else:
        print("  - nothing to remove")
    print("\nDone.")
    raise SystemExit(0)

# Install mode
skills_target.mkdir(parents=True, exist_ok=True)
agents_target.mkdir(parents=True, exist_ok=True)

# Remove legacy installed surfaces before installing current managed components
for skill_name in legacy_skill_names:
    legacy_target = skills_target / skill_name
    legacy_skill_md = legacy_target / "SKILL.md"
    if legacy_target.exists() and has_marker(legacy_skill_md):
        remove_path(legacy_target)
        print(f"  - skills/{skill_name}/")

for agent_name in legacy_agent_names:
    legacy_target = agents_target / agent_name
    if legacy_target.exists() and has_marker(legacy_target):
        remove_path(legacy_target)
        print(f"  - agents/{agent_name}")

# Install skills
for skill_dir in skill_dirs:
    dest = skills_target / skill_dir.name
    if dest.exists():
        shutil.rmtree(dest)
    shutil.copytree(skill_dir, dest)
    print(f"  + skills/{skill_dir.name}/")

# Install agents
for agent in agents:
    if not agent.exists():
        raise SystemExit(f"missing manifest agent: {agent.relative_to(repo_root)}")
    dest = agents_target / agent.name
    shutil.copy2(agent, dest)
    print(f"  + agents/{agent.name}")

# Add marker to installed components
local_build = compute_local_build()
marker = f"[local dev v{manifest['version']}-{local_build}] "

for skill_dir in skill_dirs:
    installed_skill = skills_target / skill_dir.name / "SKILL.md"
    if installed_skill.exists():
        text = installed_skill.read_text()
        updated = re.sub(
            r"^(description:\s*)(.+)$",
            lambda match: match.group(1) + marker + match.group(2).removeprefix(marker),
            text,
            count=1,
            flags=re.MULTILINE,
        )
        installed_skill.write_text(updated)

for agent in agents:
    installed_agent = agents_target / agent.name
    if installed_agent.exists():
        text = installed_agent.read_text()
        # Add marker to agent frontmatter description if it exists
        updated = re.sub(
            r"^(description:\s*)(.+)$",
            lambda match: match.group(1) + marker + match.group(2).removeprefix(marker),
            text,
            count=1,
            flags=re.MULTILINE,
        )
        installed_agent.write_text(updated)

print(f"\nInstalled components:")
print(f"  name: {manifest['name']}")
print(f"  version: {manifest['version']}")
print(f"  description: {manifest['description']}")
print(f"  local build: {local_build}")
print(f"\nTargets:")
print(f"  skills: {skills_target}")
print(f"  agents: {agents_target}")
PY
