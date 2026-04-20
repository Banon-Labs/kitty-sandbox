# Agent Instructions

This repository uses **bd** (beads) for issue tracking.

## Scope

- This repository-root `AGENTS.md` is the canonical shared instruction file for this repo.
- Because this repo lives under `~/projects`, the workspace guardrails in `/home/choza/projects/AGENTS.md` remain binding unless the user explicitly overrides them.

## Issue Tracking

- Use **bd** for all task tracking.
- Do not create markdown TODO lists or duplicate tracking systems.
- Prefer machine-readable commands for agent work:
  - `bd ready --json`
  - `bd create ... --json`
  - `bd update ... --json`
  - `bd show ... --json`
  - `bd close ... --json`

## Workspace Guardrails

- Do **not** use `git push` from this workspace unless the user explicitly approves it.
- Preferred Beads sync sequence when needed:
  - `bd dolt commit -m "checkpoint" && bd dolt pull && bd dolt push`
- For Pi-level behavior changes or executable script changes, run the required Kitty smoke test before claiming completion.
