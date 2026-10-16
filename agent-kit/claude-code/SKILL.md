---
name: theme-pack-author
description: Author complete, valid Theme Pack JSON files (v1 contract) for the AI-moddable game. Use when the user asks to create, write, or fix a theme pack, or when authoring game content packs for this project.
---

# Theme Pack Author (v1 contract)

You author Theme Pack JSON files: pure-data reskins (names, icons, flavor, palette, part parameters) for the game. Packs are validated by the engine before they can play; this skill encodes the enforced v1 contract so the packs you write pass on the first try. Full field-by-field spec with worked examples: `agent-kit/pack-contract.md` (repo root) — read it if anything here is ambiguous.

## Hard rules

1. **Pure JSON object**, one file. No code, no comments, no trailing commas.
2. Top level: `id` (non-empty string), `version` (integer `1` — anything else is rejected), `accent` (`"#rrggbb"`), `bodyClass` (`"seas"` or `"iron"`), `parts`, `text`.
3. `parts.fatigue`: `{ "enabled": bool, "params": { "threshold": int > 0, "apPenalty": int >= 0 } }`. Required even when `enabled` is false.
4. `text` must contain **all three** locales `en`, `zh`, `ja` — genuine translations, never duplicates or placeholders. There is no fallback language.
5. Every locale object needs ALL of:
   - `name`, `tagline` (non-empty strings)
   - `factions`: exactly 3 × `{ "name", "icon" }`
   - `cards`: all six ids — `hero, tank, healer, mage, striker, archer` — each `{ "name", "icon" }`
   - `skillNames`: all seven — `slash, heavy, multi, blast, mend, guard, hex`
   - `enemies`: all four — `grunt, brute, shaman, boss` — each `{ "name", "icon" }`
   - `enemyActions`: all three — `e_slash, e_heavy, e_bolt`
   - `questTitles`: all four — `prepA, prepB, opA, opB`
   - `flavor`: `ev_exp`, `ev_gains`, `base` (each an array of 1+ non-empty strings) and `reportTpl` (a string containing `{turn}`, `{loss}`, `{left}`)
   - `parts.fatigue`: `{ "name", "icon" }`
6. `icon` values are short emoji/glyph strings, non-empty. No empty strings anywhere — any empty string is a validation failure.
7. Write integers as integers (`1`, not `1.0`); `enabled` must be a real JSON bool.

## Workflow

1. Ask for (or decide) a theme and pack id; confirm the target output path.
2. Write the pack as one JSON file. Easiest correct path: copy the structure of `game/engine/packs/ironroad.json` and replace every text value with your theme's trilingual text, keeping all required ids intact.
3. Validate through the engine (from the repo root):
   ```
   godot --headless --path game res://tests/run_pack.tscn -- <absolute path to pack.json>
   ```
   - Exit 0 + `PACK PLAYED: ...` = valid and playable (it also runs a battle to prove it).
   - Otherwise it prints the exact `pack.*` reasons (format `dotted.path: problem`) — fix precisely those, in order, and re-run.
4. Report the output path and the validation/play result. Never edit engine code to make a pack pass.

## Install

Copy this directory to either location, then the skill is invocable as `theme-pack-author`:

- User-global: `~/.claude/skills/theme-pack-author/` (copy `SKILL.md`, plus `pack-contract.md` if you want the full spec offline — otherwise keep the repo checkout nearby)
- Per-project: `<repo>/.claude/skills/theme-pack-author/`

```sh
mkdir -p ~/.claude/skills/theme-pack-author
cp agent-kit/claude-code/SKILL.md ~/.claude/skills/theme-pack-author/
cp agent-kit/pack-contract.md ~/.claude/skills/theme-pack-author/
```
