extends ReplayBase

## Invalid-pack rejection: an invalid pack is rejected with specific reasons
## and the state stays untouched (no session starts, so state remains empty).


func replay_name() -> String:
	return "invalid_pack_rejected_state_untouched"


func pack() -> Dictionary:
	return {
		"id": "broken",
		"text": {
			"en": {"name": "Broken", "tagline": "missing accent, parts, zh, ja"},
		},
	}


func expected_new_game_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	errors.append("pack.accent: required #rrggbb string")
	errors.append("pack.parts: required object")
	errors.append("pack.text.zh: required object")
	errors.append("pack.text.ja: required object")
	return errors


func expected_state() -> Dictionary:
	return {}
