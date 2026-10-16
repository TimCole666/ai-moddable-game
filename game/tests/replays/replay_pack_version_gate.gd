extends ReplayBase

## Version gate (ADR-0002): the contract carries a version from day one and
## the Engine rejects packs whose version it cannot interpret. The builtin
## pack mutated to version 2 is rejected with one specific reason and the
## baseline session is untouched.

func replay_name() -> String:
	return "pack_version_gate"


func pack() -> Dictionary:
	var pack := GameEngine.get_builtin_pack()
	pack["version"] = 2
	return pack


func expected_new_game_errors() -> PackedStringArray:
	var errors := PackedStringArray()
	errors.append("pack.version: unsupported version 2 (this engine interprets v1)")
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
