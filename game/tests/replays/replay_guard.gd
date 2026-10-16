extends ReplayBase

## Bracing reduces incoming damage: the tank Braces (1 AP) and the announced
## Jab lands for roundi(8 * 1.0 * 1.05 * 0.7) = 6 instead of 8 (Bulwark 79,
## not 77). The guard is round-scoped: it resets when the round advances.


func replay_name() -> String:
	return "guard_brace"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "grunt"},
		{"type": EngineCore.ACTION_SKILL, "leader": 1, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
	]


func expected_state() -> Dictionary:
	return {
		"pack_id": "builtin",
		"turn": 1,
		"battle": {
			"enemy": "grunt",
			"boss": false,
			"enemy_hp": 40,
			"enemy_max_hp": 40,
			"enemy_at": 8,
			"round": 2,
			"ap": 5,
			"ap_max": 6,
			"regen": 2,
			"combo": 0,
			"guard": false,
			"hexed": false,
			"over": "",
			"party_hp": [60, 79, 70, 45, 50, 48],
			"next_action": "e_slash",
		},
		"log": [
			"Turn 1: battle vs Grunt",
			"Round 1: Bulwark uses Brace: party braces (-30% incoming this round)",
			"Round 1: Grunt uses Jab for 6 damage on Bulwark (HP 79)",
		],
	}
