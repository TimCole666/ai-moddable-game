extends ReplayBase

## V1 schema: every top-level rule broken at once — id, version, accent,
## bodyClass palette enum, Fatigue params, locales — with the exact ordered
## reason list pinned. A rejected pack leaves the baseline session untouched.

func replay_name() -> String:
	return "pack_reject_reasons_top_level"


func pack() -> Dictionary:
	return {
		"id": "",
		"version": "one",
		"accent": "nope",
		"bodyClass": "theme-mock",
		"parts": {
			"fatigue": {
				"enabled": "yes",
				"params": {"threshold": 0, "apPenalty": -1},
			},
		},
		"text": {},
	}


func expected_new_game_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	errors.append("pack.id: required non-empty string")
	errors.append("pack.version: required integer")
	errors.append("pack.accent: must match #rrggbb")
	errors.append("pack.bodyClass: unknown palette theme-mock (known: seas, iron)")
	errors.append("pack.parts.fatigue.enabled: required bool")
	errors.append("pack.parts.fatigue.params.threshold: required integer > 0")
	errors.append("pack.parts.fatigue.params.apPenalty: required integer >= 0")
	errors.append("pack.text.en: required object")
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
			"exp": 0
		},
		"healer": {
			"count": 1,
			"exp": 0
		},
		"hero": {
			"count": 1,
			"exp": 0
		},
		"mage": {
			"count": 1,
			"exp": 0
		},
		"striker": {
			"count": 1,
			"exp": 0
		},
		"tank": {
			"count": 1,
			"exp": 0
		}
	},
	"ended": "",
	"fatigue": 0,
	"gains_total": 0,
	"gains_turn": 0,
	"log": [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue."
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 100,
	"tickets": 0,
	"turn": 1
}
