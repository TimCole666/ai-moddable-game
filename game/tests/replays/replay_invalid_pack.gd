extends ReplayBase

## Invalid-pack rejection: an invalid pack is rejected with specific reasons
## and zero state change. The runner boots a baseline builtin session before
## every replay, so "untouched" means exactly that baseline survives.


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
	errors.append("pack.version: required integer")
	errors.append("pack.accent: required #rrggbb string")
	errors.append("pack.bodyClass: required string")
	errors.append("pack.parts: required object")
	errors.append("pack.text.en.factions: required array of exactly 3 entries")
	errors.append("pack.text.en.cards: required object")
	errors.append("pack.text.en.skillNames: required object")
	errors.append("pack.text.en.enemies: required object")
	errors.append("pack.text.en.enemyActions: required object")
	errors.append("pack.text.en.questTitles: required object")
	errors.append("pack.text.en.flavor: required object")
	errors.append("pack.text.en.parts: required object")
	errors.append("pack.text.zh: required object")
	errors.append("pack.text.ja: required object")
	return errors


func expected_state() -> Dictionary:
	return {
		"base_options": null,
		"battle": null,
		"chest": null,
		"collection": {
			"archer": {
				"count": 1,
				"exp": 0,
			},
			"healer": {
				"count": 1,
				"exp": 0,
			},
			"hero": {
				"count": 1,
				"exp": 0,
			},
			"mage": {
				"count": 1,
				"exp": 0,
			},
			"striker": {
				"count": 1,
				"exp": 0,
			},
			"tank": {
				"count": 1,
				"exp": 0,
			},
		},
		"ended": "",
		"fatigue": 0,
		"gains_total": 0,
		"gains_turn": 0,
		"log": [],
		"medals": 0,
		"pack_id": "builtin",
		"phase": 0,
		"quest": null,
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
