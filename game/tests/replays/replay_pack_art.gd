extends ReplayBase

## Pack art (ADR-0008): the builtin pack ships embedded art and it decodes at
## the pack_art seam; a pack with corrupt or oversized art is rejected with
## specific reasons and zero state change; a pack without art stays valid
## (graceful fallback). Runner boots a baseline builtin session first, so
## "untouched" means exactly that baseline survives.

var _corrupt_errors := PackedStringArray()
var _oversize_errors := PackedStringArray()


func replay_name() -> String:
	return "pack_art_validation"


func actions() -> Array:
	return [
		Callable(self, "_try_corrupt_art"),
		Callable(self, "_try_oversize_art"),
	]


func _try_corrupt_art() -> void:
	var pack := GameEngine.get_builtin_pack()
	pack["id"] = "corrupt-art"
	(pack["art"] as Dictionary)["portraits"]["hero"] = "!!! definitely not base64 !!!"
	var result := GameEngine.step({"type": EngineCore.ACTION_SELECT_PACK, "pack": pack})
	_corrupt_errors = result["errors"]


func _try_oversize_art() -> void:
	var pack := GameEngine.get_builtin_pack()
	pack["id"] = "oversize-art"
	(pack["art"] as Dictionary)["portraits"]["tank"] = "QUJD".repeat(700000)
	var result := GameEngine.step({"type": EngineCore.ACTION_SELECT_PACK, "pack": pack})
	_oversize_errors = result["errors"]


func checks() -> PackedStringArray:
	var problems := PackedStringArray()
	# The builtin pack's embedded art decodes to textures at the seam.
	if GameEngine.pack_art("portraits", "hero") == null:
		problems.append("pack_art: builtin hero portrait did not decode")
	if GameEngine.pack_art("enemies", "boss") == null:
		problems.append("pack_art: builtin boss illustration did not decode")
	if GameEngine.pack_art("backgrounds", "tavern") == null:
		problems.append("pack_art: builtin tavern background did not decode")
	if GameEngine.pack_art("portraits", "nonexistent") != null:
		problems.append("pack_art: unknown id must be null, view degrades to emoji")
	# Corrupt art rejected with the dotted-path reason, state untouched.
	if _corrupt_errors.size() != 1 or not (_corrupt_errors[0] as String).begins_with("art.portraits.hero:"):
		problems.append("corrupt art: expected [art.portraits.hero: ...], got %s" % [str(_corrupt_errors)])
	# Oversize art rejected by the cap.
	if _oversize_errors.size() != 1 or not (_oversize_errors[0] as String).begins_with("art.portraits.tank: exceeds"):
		problems.append("oversize art: expected the cap reason, got %s" % [str(_oversize_errors)])
	return problems


func expected_state() -> Dictionary:
	# Baseline builtin session untouched: both pack switches were rejected.
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
		"log": [
			"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
			"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
			"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
			"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
		],
		"medals": 0,
		"pack_id": "builtin",
		"phase": 0,
		"quest": null,
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
