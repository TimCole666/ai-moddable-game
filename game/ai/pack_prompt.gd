class_name AIPackPrompt
extends RefCounted

## Prompt building and response extraction for the AI Entry (ticket 06).
## The prompt embeds the v1 Theme Pack contract essentials so a model can
## emit a valid pack without reading the game's source; the required id
## vocabulary is pulled from the Engine's constants so the prompt stays in
## sync with the contract the Engine enforces. Packs are pure JSON (ADR-0002).

## The chat-completions system message: forces a bare JSON reply.
const SYSTEM_PROMPT := "You are a Theme Pack author for a deterministic game engine. Reply with ONLY one JSON object - no markdown fences, no commentary, nothing before or after the JSON."


## Build the user prompt for generating a Theme Pack about `topic`. Reads the
## id vocabulary from the Engine constants (autoload GameEngine) so adding a
## leader, skill, enemy, or quest automatically teaches the prompt its new id.
static func build_prompt(topic: String, extra_instructions: String = "") -> String:
	var leader_ids: Array = []
	for leader in GameEngine.LEADERS:
		leader_ids.append(leader["id"])
	var skill_ids: Array = GameEngine.SKILLS.keys()
	var enemy_ids: Array = GameEngine.ENEMIES.keys()
	var enemy_action_ids: Array = GameEngine.ENEMY_SKILLS.keys()
	var quest_keys: Array = []
	for pool in GameEngine.QUESTS.values():
		for quest in pool:
			quest_keys.append(quest["key"])
	var lines: Array[String] = [
		"Generate a Theme Pack about: %s." % [topic],
		"",
		"Reply with ONLY one JSON object matching this Theme Pack contract (version 1). No markdown, no code fences, no commentary.",
		"",
		"Required top-level fields:",
		'- "id": unique snake_case id for the pack',
		'- "version": 1',
		'- "accent": "#rrggbb" hex color string',
		'- "bodyClass": one of %s' % [JSON.stringify(GameEngine.PACK_PALETTES)],
		'- "parts": {"fatigue": {"enabled": true|false, "params": {"threshold": integer > 0, "apPenalty": integer >= 0}}}',
		'- "text": {"en": {...}, "zh": {...}, "ja": {...}} - ALL THREE locales required, same shape each.',
		"",
		"Each locale text object requires exactly these fields:",
		'- "name": string, "tagline": string',
		'- "factions": exactly 3 entries, each {"name": string, "icon": string (emoji)}',
		'- "cards": one entry per id %s, each {"name": string, "icon": string (emoji)}' % [JSON.stringify(leader_ids)],
		'- "skillNames": one entry per id %s, each a non-empty string' % [JSON.stringify(skill_ids)],
		'- "enemies": one entry per id %s, each {"name": string, "icon": string (emoji)}' % [JSON.stringify(enemy_ids)],
		'- "enemyActions": one entry per id %s, each a non-empty string' % [JSON.stringify(enemy_action_ids)],
		'- "questTitles": one entry per id %s, each a non-empty string' % [JSON.stringify(quest_keys)],
		'- "flavor": {"ev_exp": [1+ strings], "ev_gains": [1+ strings], "base": [1+ strings], "reportTpl": string containing {turn}, {loss} and {left}}',
		'- "parts": {"fatigue": {"name": string, "icon": string (emoji)}}',
		"",
		"Write idiomatic, evocative text per language (Simplified Chinese for zh, Japanese for ja - not placeholders).",
	]
	if not extra_instructions.is_empty():
		lines.append("")
		lines.append("Additional instructions: %s" % [extra_instructions])
	return "\n".join(lines)


## Extract the JSON object from a model reply: models wrap JSON in prose or
## markdown fences despite instructions. Returns the parsed Dictionary, or
## null when no JSON object can be found or the text is not a JSON object.
static func extract_json_object(model_output: String) -> Variant:
	var start := model_output.find("{")
	var end := model_output.rfind("}")
	if start < 0 or end <= start:
		return null
	var parsed: Variant = JSON.parse_string(model_output.substr(start, end - start + 1))
	return parsed
