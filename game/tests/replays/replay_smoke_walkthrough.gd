extends ReplayBase

## Trivial walkthrough: a scripted action sequence through the Engine seam,
## asserting the final state bit-for-bit (exact types, exact log wording).


func replay_name() -> String:
	return "smoke_walkthrough"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_PATROL},
		{"type": EngineCore.ACTION_PATROL},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_REST},
	]


func expected_state() -> Dictionary:
	return {
		"pack_id": "builtin",
		"turn": 2,
		"hp": 60,
		"ap": 6,
		"exp": 2,
		"log": [
			"Turn 1: patrol (+1 exp)",
			"Turn 1: patrol (+1 exp)",
			"Turn 2: end turn (AP +regen)",
			"Turn 2: rest (full heal)",
		],
	}
