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
		"base_options": null,
		"battle": {
			"ap": 5,
			"ap_max": 6,
			"boss": false,
			"combo": 0,
			"enemy": "grunt",
			"enemy_at": 8,
			"enemy_hp": 40,
			"enemy_max_hp": 40,
			"guard": false,
			"hexed": false,
			"next_action": "e_slash",
			"over": "",
			"party_hp": [60, 79, 70, 45, 50, 48],
			"regen": 2,
			"round": 2,
		},
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
		"log": [
			"Turn 1: battle vs Grunt",
			"Round 1: Bulwark uses Brace: party braces (-30% incoming this round)",
			"Round 1: Grunt uses Jab for 6 damage on Bulwark (HP 79)",
		],
		"medals": 0,
		"pack_id": "builtin",
		"phase": 0,
		"quest": null,
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
