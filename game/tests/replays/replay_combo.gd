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
		"base_options": null,
		"battle": {
			"ap": 2,
			"ap_max": 6,
			"boss": true,
			"combo": 0,
			"enemy": "boss",
			"enemy_at": 16,
			"enemy_hp": 137,
			"enemy_max_hp": 160,
			"guard": false,
			"hexed": false,
			"next_action": "e_slash",
			"over": "",
			"party_hp": [60, 58, 70, 45, 50, 48],
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
			"Turn 1: battle vs Warlord",
			"Round 1: Vanguard uses Strike for 14 damage (enemy HP 146)",
			"Round 1: Bulwark uses Strike for 9 damage (enemy HP 137)",
			"Round 1: Warlord uses Slam for 27 damage on Bulwark (HP 58)",
		],
		"medals": 0,
		"pack_id": "builtin",
		"phase": 0,
		"quest": null,
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
