extends ReplayBase

## Combos scale damage: every landed hit adds +10% to later attacks that
## round. Hero Strike lands first (14), then the tank's Strike with combo 1
## deals roundi(9 * 1.0 * 0.9 * 1.1) = 9 — without the combo bonus it would
## be 8 and the Warlord would sit at 138 HP; the pinned 137 fails.


func replay_name() -> String:
	return "combo_scaling"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "boss"},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_SKILL, "leader": 1, "slot": 1},
		{"type": EngineCore.ACTION_END_TURN},
	]


func expected_state() -> Dictionary:
	return {
		"pack_id": "builtin",
		"turn": 1,
		"battle": {
			"enemy": "boss",
			"boss": true,
			"enemy_hp": 137,
			"enemy_max_hp": 160,
			"enemy_at": 16,
			"round": 2,
			"ap": 2,
			"ap_max": 6,
			"regen": 2,
			"combo": 0,
			"guard": false,
			"hexed": false,
			"over": "",
			"party_hp": [60, 58, 70, 45, 50, 48],
			"next_action": "e_slash",
		},
		"log": [
			"Turn 1: battle vs Warlord",
			"Round 1: Vanguard uses Strike for 14 damage (enemy HP 146)",
			"Round 1: Bulwark uses Strike for 9 damage (enemy HP 137)",
			"Round 1: Warlord uses Slam for 27 damage on Bulwark (HP 58)",
		],
	}
