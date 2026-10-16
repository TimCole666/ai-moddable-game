extends ReplayBase

## V1 schema: locale completeness — every roster/skill/enemy/enemy-action/
## quest id covered, flavor arrays 1+ entries, report placeholders — pinned
## with per-id dotted-path reasons against a surgically broken builtin copy.
## A rejected pack leaves the baseline session untouched.

func replay_name() -> String:
	return "pack_reject_locale_fields"


func pack() -> Dictionary:
	var pack := GameEngine.get_builtin_pack()
	var en: Dictionary = pack["text"]["en"]
	var zh: Dictionary = pack["text"]["zh"]
	var ja: Dictionary = pack["text"]["ja"]
	(en["factions"] as Array)[1] = {"name": "Lantern Order"}  # icon missing
	(en["cards"] as Dictionary).erase("mage")
	(en["parts"]["fatigue"] as Dictionary).erase("icon")
	(zh["skillNames"] as Dictionary).erase("hex")
	(zh["questTitles"] as Dictionary).erase("opB")
	zh["flavor"]["reportTpl"] = "no placeholders here"
	(ja["enemies"]["boss"] as Dictionary).erase("icon")
	ja["flavor"]["ev_exp"] = []
	return pack


func expected_new_game_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	errors.append("pack.text.en.factions[1]: required object with name and icon strings")
	errors.append("pack.text.en.cards.mage: required object with name and icon strings")
	errors.append("pack.text.en.parts.fatigue: required object with name and icon strings")
	errors.append("pack.text.zh.skillNames.hex: required non-empty string")
	errors.append("pack.text.zh.questTitles.opB: required non-empty string")
	errors.append("pack.text.zh.flavor.reportTpl: required string containing {turn} {loss} {left}")
	errors.append("pack.text.ja.enemies.boss: required object with name and icon strings")
	errors.append("pack.text.ja.flavor.ev_exp: required array of at least 1 non-empty string")
	return errors


func expected_state() -> Dictionary:
	return {
		"base_options": null,
		"battle": null,
		"chest": null,
		"collection": {
			"archer": {"count": 1, "exp": 0},
			"healer": {"count": 1, "exp": 0},
			"hero": {"count": 1, "exp": 0},
			"mage": {"count": 1, "exp": 0},
			"striker": {"count": 1, "exp": 0},
			"tank": {"count": 1, "exp": 0},
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
