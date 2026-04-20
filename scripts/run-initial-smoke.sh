#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
shared_helper="/home/choza/projects/scripts/pi-kitty-smoke.sh"
kitty_helper="/home/choza/projects/scripts/kitty-orchestrate.sh"
out_dir="${KITTY_SANDBOX_SMOKE_OUT_DIR:-/tmp/kitty-sandbox-smoke}"
title="${KITTY_SANDBOX_SMOKE_TITLE:-kitty-sandbox-smoke}"
session_dir=""
provider="smoke-sandbox"
model="deterministic"
thinking="minimal"
tools="read,grep,find,ls"
phrase="KLAATU BERADA NIKTO"
smoke_sandbox_extension="/home/choza/projects/pi-smoke-sandbox/index.ts"
use_smoke_sandbox=1
allow_discovered_extensions=0
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
    --out-dir)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --out-dir" >&2
        exit 2
      fi
      out_dir="$2"
      pass_args+=("$1" "$2")
      shift 2
      ;;
    --out-dir=*)
      out_dir="${1#*=}"
      pass_args+=("$1")
      shift
      ;;
    --title)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --title" >&2
        exit 2
      fi
      title="$2"
      pass_args+=("$1" "$2")
      shift 2
      ;;
    --title=*)
      title="${1#*=}"
      pass_args+=("$1")
      shift
      ;;
    --session-dir)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --session-dir" >&2
        exit 2
      fi
      session_dir="$2"
      pass_args+=("$1" "$2")
      shift 2
      ;;
    --session-dir=*)
      session_dir="${1#*=}"
      pass_args+=("$1")
      shift
      ;;
    --provider)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --provider" >&2
        exit 2
      fi
      provider="$2"
      pass_args+=("$1" "$2")
      shift 2
      ;;
    --provider=*)
      provider="${1#*=}"
      pass_args+=("$1")
      shift
      ;;
    --model)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --model" >&2
        exit 2
      fi
      model="$2"
      pass_args+=("$1" "$2")
      shift 2
      ;;
    --model=*)
      model="${1#*=}"
      pass_args+=("$1")
      shift
      ;;
    --thinking)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --thinking" >&2
        exit 2
      fi
      thinking="$2"
      pass_args+=("$1" "$2")
      shift 2
      ;;
    --thinking=*)
      thinking="${1#*=}"
      pass_args+=("$1")
      shift
      ;;
    --tools)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --tools" >&2
        exit 2
      fi
      tools="$2"
      pass_args+=("$1" "$2")
      shift 2
      ;;
    --tools=*)
      tools="${1#*=}"
      pass_args+=("$1")
      shift
      ;;
    --phrase)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --phrase" >&2
        exit 2
      fi
      phrase="$2"
      pass_args+=("$1" "$2")
      shift 2
      ;;
    --phrase=*)
      phrase="${1#*=}"
      pass_args+=("$1")
      shift
      ;;
    --smoke-sandbox-extension)
      if [[ $# -lt 2 ]]; then
        echo "Missing value for --smoke-sandbox-extension" >&2
        exit 2
      fi
      smoke_sandbox_extension="$2"
      pass_args+=("$1" "$2")
      shift 2
      ;;
    --smoke-sandbox-extension=*)
      smoke_sandbox_extension="${1#*=}"
      pass_args+=("$1")
      shift
      ;;
    --allow-discovered-extensions)
      allow_discovered_extensions=1
      pass_args+=("$1")
      shift
      ;;
    --no-smoke-sandbox)
      use_smoke_sandbox=0
      pass_args+=("$1")
      shift
      ;;
    *)
      pass_args+=("$1")
      shift
      ;;
  esac
done

if [[ -z "$session_dir" ]]; then
  session_dir="$out_dir/sessions"
fi

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

mkdir -p "$out_dir" "$session_dir"
window_id="$($kitty_helper launch-tab --cwd "$repo_root" --title "${title}-existing-window-sandbox")"
printf '%s\n' "$window_id" > "$out_dir/window_id.txt"

pi_args=(
  --provider "$provider"
  --model "$model"
  --thinking "$thinking"
  --tools "$tools"
  --session-dir "$session_dir"
  --verbose
)

if [[ "$allow_discovered_extensions" -eq 0 ]]; then
  pi_args+=(--no-extensions)
fi

if [[ "$use_smoke_sandbox" -eq 1 ]]; then
  pi_args+=(--extension "$smoke_sandbox_extension")
fi

printf -v pi_cmd '%q ' pi "${pi_args[@]}"
pi_cmd="${pi_cmd% }"

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
  --text "$phrase" \
  --enter \
  --before "$out_dir/prompt-before.txt" \
  --after "$out_dir/prompt-after.txt" \
  --timeout 120

cat >"$out_dir/summary.txt" <<EOF
mode=existing-window-tab
cwd=$repo_root
title=${title}-existing-window-sandbox
window_id=$window_id
provider=$provider
model=$model
thinking=$thinking
tools=$tools
phrase=$phrase
pi_command=$pi_cmd
session_dir=$session_dir
pi_ready=$out_dir/pi-ready.txt
probe_after=$out_dir/probe-after.txt
prompt_after=$out_dir/prompt-after.txt
cleanup_window_command=$kitty_helper close-window --window $window_id
EOF

cleanup_window
trap - EXIT
