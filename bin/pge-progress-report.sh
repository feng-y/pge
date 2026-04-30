#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <progress.jsonl>" >&2
  exit 1
fi

progress_file="$1"

if [[ -d "$progress_file" ]]; then
  progress_file="${progress_file%/}/progress.jsonl"
fi

if [[ ! -f "$progress_file" ]]; then
  echo "missing file: $progress_file" >&2
  exit 1
fi

python - "$progress_file" <<'PY'
import json
import sys
from datetime import datetime
from pathlib import Path

path = Path(sys.argv[1])
rows = []
bad = 0

for idx, line in enumerate(path.read_text().splitlines(), 1):
    if not line.strip():
        continue
    try:
        row = json.loads(line)
        row["_line"] = idx
        rows.append(row)
    except Exception:
        bad += 1

required = ["ts", "run_id", "actor", "phase", "event", "status", "artifact", "detail", "blocker"]
missing = []
for row in rows:
    miss = [k for k in required if k not in row]
    if miss:
        missing.append((row["_line"], miss))

fmt = "%Y-%m-%dT%H:%M:%SZ"

def parse_ts(value):
    return datetime.strptime(value, fmt)

durations = []
for a, b in zip(rows, rows[1:]):
    try:
        delta = (parse_ts(b["ts"]) - parse_ts(a["ts"])).total_seconds()
    except Exception:
        continue
    durations.append((a, b, delta))

print(f"file: {path}")
print(f"rows: {len(rows)}")
print(f"invalid_json_rows: {bad}")
print(f"rows_missing_required_fields: {len(missing)}")
for line, miss in missing[:10]:
    print(f"  line {line}: missing {', '.join(miss)}")

if rows:
    try:
        total = (parse_ts(rows[-1]["ts"]) - parse_ts(rows[0]["ts"])).total_seconds()
        print(f"total_seconds: {total:.1f}")
    except Exception:
        pass

print("--- slow gaps (>= 5s) ---")
slow = [(a, b, d) for a, b, d in durations if d >= 5]
if not slow:
    print("none")
else:
    for a, b, d in slow:
        print(
            f"{d:7.1f}s | "
            f"{a.get('actor')}:{a.get('event')} -> {b.get('actor')}:{b.get('event')}"
        )

print("--- top 5 gaps ---")
for a, b, d in sorted(durations, key=lambda x: x[2], reverse=True)[:5]:
    print(
        f"{d:7.1f}s | "
        f"{a.get('actor')}:{a.get('phase')}:{a.get('event')} -> "
        f"{b.get('actor')}:{b.get('phase')}:{b.get('event')}"
    )
PY
