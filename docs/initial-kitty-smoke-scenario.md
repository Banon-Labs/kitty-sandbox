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

## Follow-up work

Once this contract is accepted, the next implementation-oriented task should:

- run the documented command from this repo
- capture one successful evidence set
- record the artifact paths in Beads
