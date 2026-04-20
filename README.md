# kitty-sandbox

A lightweight sandbox repository for Kitty/Pi experiments and other small isolated work that should not live in the larger workspace repo.

## Current bootstrap state

This repository is initialized with:

- a standalone Git repository
- a standalone Beads database under `.beads/`
- a public GitHub remote: `git@github.com:Banon-Labs/kitty-sandbox.git`
- a public Beads/Dolt remote: `https://doltremoteapi.dolthub.com/chozandrias/kitty-sandbox`

## Working conventions

- Task tracking lives in **Beads**. Do not create markdown TODO lists.
- Start from `bd ready --json`.
- Create work with `bd create ... --json` before making changes.
- The repository instructions live in `AGENTS.md`.
- Because this repo is under `~/projects`, workspace guardrails from `/home/choza/projects/AGENTS.md` still apply.

## Common commands

```bash
# inspect work
bd ready --json
bd list --json
bd show <issue-id> --json

# create and claim work
bd create "Title" --description "Context" --type task --priority 2 --json
bd update <issue-id> --status in_progress --json

# finish work
bd close <issue-id> --reason "Done" --json

# sync Beads
bd dolt commit -m "checkpoint" && bd dolt pull && bd dolt push
```

## Repository contents

- `AGENTS.md` — repo-local agent instructions
- `.beads/` — Beads metadata and local Dolt state
- `.pi/`, `.pi-lens/` — local Pi runtime artifacts (ignored by Git)

## Initial scenario contract

The first concrete workload for this repo is documented here:

- `docs/initial-kitty-smoke-scenario.md`

## Repo-local launcher

A convenience launcher is available at:

- `scripts/run-initial-smoke.sh`

Example:

```bash
./scripts/run-initial-smoke.sh --allow-popup-launch --quit-after
```

## Next step

Use the repo-local launcher to capture repeatable evidence, then decide whether this repo needs more scenario variants or lightweight automation around artifact review.
