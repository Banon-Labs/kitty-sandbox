#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
shared_helper="/home/choza/projects/scripts/pi-kitty-smoke.sh"
kitty_helper="/home/choza/projects/scripts/kitty-orchestrate.sh"
out_dir="${KITTY_SANDBOX_SMOKE_OUT_DIR:-/tmp/kitty-sandbox-smoke}"
title="${KITTY_SANDBOX_SMOKE_TITLE:-kitty-sandbox-smoke}"
use_existing_window=0
requested_window_id=""
pass_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --window)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --window" >&2
        exit 2
      fi
      use_existing_window=1
      requested_window_id="$2"
      shift 2
      ;;
    --window=*)
      use_existing_window=1
      requested_window_id="${1#*=}"
      shift
      ;;
    *)
      pass_args+=("$1")
      shift
      ;;
  esac
done

if [[ ! -x "$shared_helper" ]]; then
  echo "Shared helper not found or not executable: $shared_helper" >&2
  exit 1
fi

if [[ ! -x "$kitty_helper" ]]; then
  echo "Kitty helper not found or not executable: $kitty_helper" >&2
  exit 1
fi

if [[ "$use_existing_window" -eq 0 ]]; then
  exec "$shared_helper" \
    --cwd "$repo_root" \
    --title "$title" \
    --out-dir "$out_dir" \
    "${pass_args[@]}"
fi

if [[ -z "${KITTY_WINDOW_ID:-}" || -z "${KITTY_LISTEN_ON:-}" ]]; then
  echo "Existing-window mode requires running inside Kitty with KITTY_WINDOW_ID and KITTY_LISTEN_ON set." >&2
  exit 1
fi

if [[ -n "$requested_window_id" && "$requested_window_id" != "$KITTY_WINDOW_ID" ]]; then
  echo "Existing-window mode must target the current Kitty tab/window ID ($KITTY_WINDOW_ID), got: $requested_window_id" >&2
  exit 2
fi

mkdir -p "$out_dir" "$out_dir/sessions"
window_id="$($kitty_helper launch-tab --cwd "$repo_root" --title "${title}-existing-window-sandbox")"
printf '%s\n' "$window_id" > "$out_dir/window_id.txt"

pi_cmd="pi --provider smoke-sandbox --model deterministic --thinking minimal --tools read,grep,find,ls --session-dir $out_dir/sessions --verbose --no-extensions --extension /home/choza/projects/pi-smoke-sandbox/index.ts"

cleanup_window() {
  "$kitty_helper" close-window --window "$window_id" >/dev/null 2>&1 || true
}
trap cleanup_window EXIT

"$kitty_helper" send-with-captures \
  --window "$window_id" \
  --text "$pi_cmd" \
  --enter \
  --before "$out_dir/pi-command-before.txt" \
  --after "$out_dir/pi-command-after.txt" \
  --timeout 120

"$kitty_helper" wait-screen-stable \
  --window "$window_id" \
  --out "$out_dir/pi-ready.txt" \
  --timeout 120

"$kitty_helper" send-with-captures \
  --window "$window_id" \
  --text '__PI_SMOKE_SANDBOX_READY_PROBE__' \
  --enter \
  --before "$out_dir/probe-before.txt" \
  --after "$out_dir/probe-after.txt" \
  --timeout 120

"$kitty_helper" send-with-captures \
  --window "$window_id" \
  --text 'KLAATU BERADA NIKTO' \
  --enter \
  --before "$out_dir/prompt-before.txt" \
  --after "$out_dir/prompt-after.txt" \
  --timeout 120

cat >"$out_dir/summary.txt" <<EOF
mode=existing-window-tab
cwd=$repo_root
title=${title}-existing-window-sandbox
window_id=$window_id
pi_command=$pi_cmd
session_dir=$out_dir/sessions
pi_ready=$out_dir/pi-ready.txt
probe_after=$out_dir/probe-after.txt
prompt_after=$out_dir/prompt-after.txt
cleanup_window_command=$kitty_helper close-window --window $window_id
EOF

cleanup_window
trap - EXIT
