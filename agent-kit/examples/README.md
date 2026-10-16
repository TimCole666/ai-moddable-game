# Examples

Proof artifacts of the ticket-08 agent round-trip.

## Round-trip demonstrated — Droid, contract-only (2026-10-17)

`droid-roundtrip/` records a real agent authoring round-trip performed by
**Droid** (Factory's coding agent), standing in for Claude Code/Codex, which
were both unavailable on this machine that day (claude weekly limit, codex not
logged in):

- `droid-roundtrip/agent_pack.json` — the "Coral Court" pack the agent authored
- `droid-roundtrip/transcript.md` — the agent's own run record

The authoring agent was given **only** the two shipped kit files
(`agent-kit/pack-contract.md`, `agent-kit/claude-code/SKILL.md`) — no game
source, no builtin packs, no engine access. It passed the headless runner on
its first attempt: `VALID` → battle played with pack text → `PACK PLAYED`,
exit 0. The in-repo copy re-verifies identically. This demonstrates the ticket's
intent: the contract document alone is sufficient for an external coding agent
to author a valid, playable pack with no game-engine access.

Remaining follow-up (optional, strengthens the evidence): repeat the run with
the Claude Code skill invoked through the `claude` CLI once it has credentials
(steps below, kept for that purpose).

## Completing the Claude Code variant

1. Install the skill: `cp agent-kit/claude-code/SKILL.md agent-kit/pack-contract.md ~/.claude/skills/theme-pack-author/`
2. From the repo root, run e.g.:
   `claude -p "Use the theme-pack-author skill ... author a NEW theme pack at agent-kit/examples/agent_pack.json, validate it with godot --headless --path game res://tests/run_pack.tscn -- <abs path> until exit 0" --dangerously-skip-permissions > agent-kit/examples/agent_run.log`
3. Keep the raw log here; the runner already prints `VALID`/`PACK PLAYED` (or
   the exact `pack.*` reasons) and its exit code is the validation verdict.

The runner itself is verified: it accepts `game/engine/packs/ironroad.json`
(plays a battle, exit 0) and rejects a broken pack with the exact contract
reason strings.
