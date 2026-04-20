#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
shared_helper="/home/choza/projects/scripts/pi-kitty-smoke.sh"
out_dir="${KITTY_SANDBOX_SMOKE_OUT_DIR:-/tmp/kitty-sandbox-smoke}"
title="${KITTY_SANDBOX_SMOKE_TITLE:-kitty-sandbox-smoke}"

if [[ ! -x "$shared_helper" ]]; then
  echo "Shared helper not found or not executable: $shared_helper" >&2
  exit 1
fi

exec "$shared_helper" \
  --cwd "$repo_root" \
  --title "$title" \
  --out-dir "$out_dir" \
  "$@"
