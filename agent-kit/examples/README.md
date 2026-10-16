# Examples

Proof artifacts of the ticket-08 agent round-trip were to live here:

- `agent_pack.json` — a Theme Pack authored by an external coding agent
- the agent's raw run transcript and the engine validation/play transcript

**Status: round-trip not yet demonstrated.** Both local CLIs were unavailable
when ticket 08 was implemented:

- `claude -p ...` — "You've hit your weekly limit · resets 8am (Asia/Taipei)"
- `codex exec ...` — not logged in (401 Unauthorized against api.openai.com)

Per the ticket, no hand-written pack is presented as an agent output. To
complete the round-trip once either CLI has credentials:

1. Install the skill: `cp agent-kit/claude-code/SKILL.md agent-kit/pack-contract.md ~/.claude/skills/theme-pack-author/`
2. From the repo root, run e.g.:
   `claude -p "Use the theme-pack-author skill ... author a NEW theme pack at agent-kit/examples/agent_pack.json, validate it with godot --headless --path game res://tests/run_pack.tscn -- <abs path> until exit 0" --dangerously-skip-permissions > agent-kit/examples/agent_run.log`
3. Keep the raw log here; the runner already prints `VALID`/`PACK PLAYED` (or
   the exact `pack.*` reasons) and its exit code is the validation verdict.

The runner itself is verified: it accepts `game/engine/packs/ironroad.json`
(plays a battle, exit 0) and rejects a broken pack with the exact contract
reason strings.
