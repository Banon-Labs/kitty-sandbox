# Initial Kitty smoke scenario contract

This is the first concrete workload for `kitty-sandbox`.

## Goal

Run one bounded Kitty/Pi smoke session using the shared workspace helper, capture the resulting terminal artifacts, and verify one clear success string from the saved output.

## Scope

This contract is intentionally documentation-first.

- Use the existing shared helper from the workspace:
  - `/home/choza/projects/scripts/pi-kitty-smoke.sh`
- Do **not** add repo-local wrapper scripts yet.
- Keep the scenario limited to one launch, one injected prompt, and one pass/fail check.

## Working directory assumptions

- Repository root: `/home/choza/projects/kitty-sandbox`
- Run the smoke command from this repository root.
- The scenario may call shared scripts from `/home/choza/projects/scripts/`.

## Command entrypoint

Representative command shape:

```bash
/home/choza/projects/scripts/pi-kitty-smoke.sh \
  --cwd /home/choza/projects/kitty-sandbox \
  --title kitty-sandbox-smoke \
  --out-dir /tmp/kitty-sandbox-smoke \
  --quit-after
```

## Sandbox title

Use a title containing the literal word `sandbox` for traceability.

Preferred initial title:

- `kitty-sandbox-smoke`

## Expected artifacts

The run is expected to leave an output directory with at least these artifacts:

- `summary.txt`
- `prompt-before.txt`
- `prompt-after.txt`

Additional helper-generated artifacts are acceptable, but these three are the minimum contract.

## Pass/fail condition

A run passes when all of the following are true:

1. the smoke command exits successfully
2. `summary.txt` exists
3. `prompt-after.txt` exists
4. `prompt-after.txt` contains the expected smoke acknowledgement string

Initial expected string:

- `KLAATU BERADA NIKTO acknowledged by smoke sandbox`

## Why this is the first task

This gives the repository one stable, bounded target that matches its name and the surrounding Kitty/Pi work, without prematurely introducing new helper code into the repo itself.

## Existing-window variant

A second supported variant avoids popup launch entirely by reusing the current Kitty OS window and creating a fresh sandbox tab inside it.

Validated flow:

```bash
# 1) create a fresh sandbox tab in the current Kitty window
window_id=$(/home/choza/projects/scripts/kitty-orchestrate.sh launch-tab \
  --cwd /home/choza/projects/kitty-sandbox \
  --title existing-window-sandbox-manual)

# 2) start Pi in that tab
pi_cmd='pi --provider smoke-sandbox --model deterministic --thinking minimal --tools read,grep,find,ls --session-dir /tmp/kitty-sandbox-existing-window-manual2/sessions --verbose --no-extensions --extension /home/choza/projects/pi-smoke-sandbox/index.ts'
/home/choza/projects/scripts/kitty-orchestrate.sh send-with-captures \
  --window "$window_id" \
  --text "$pi_cmd" \
  --enter \
  --before /tmp/kitty-sandbox-existing-window-manual2/pi-command-before.txt \
  --after /tmp/kitty-sandbox-existing-window-manual2/pi-command-after.txt

# 3) verify readiness and then run the smoke phrase
/home/choza/projects/scripts/kitty-orchestrate.sh send-with-captures \
  --window "$window_id" \
  --text '__PI_SMOKE_SANDBOX_READY_PROBE__' \
  --enter \
  --before /tmp/kitty-sandbox-existing-window-manual2/probe-before.txt \
  --after /tmp/kitty-sandbox-existing-window-manual2/probe-after.txt

/home/choza/projects/scripts/kitty-orchestrate.sh send-with-captures \
  --window "$window_id" \
  --text 'KLAATU BERADA NIKTO' \
  --enter \
  --before /tmp/kitty-sandbox-existing-window-manual2/prompt-before.txt \
  --after /tmp/kitty-sandbox-existing-window-manual2/prompt-after.txt

# 4) close the sandbox tab
/home/choza/projects/scripts/kitty-orchestrate.sh close-window --window "$window_id"
```

Validated evidence set:

- `/tmp/kitty-sandbox-existing-window-manual2/probe-after.txt`
- `/tmp/kitty-sandbox-existing-window-manual2/prompt-after.txt`

Validated success strings:

- `smoke sandbox ready`
- `KLAATU BERADA NIKTO acknowledged by smoke sandbox`

Known limitation:

- the repo-local shortcut `scripts/run-initial-smoke.sh --window <kitty-window-id> --quit-after` timed out during reuse-mode validation; that follow-up is tracked separately.

## Follow-up work

Once this contract is accepted, the next implementation-oriented task should:

- run one of the documented command paths from this repo
- capture one successful evidence set
- record the artifact paths in Beads
