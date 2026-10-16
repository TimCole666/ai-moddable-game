extends ReplayBase

## A hexed enemy action is cancelled: the archer's Hex (2 AP) cancels the
## announced Jab — no damage, the hex is consumed (hexed back to false), and
## the round still advances (AP regen, next announcement). Boss immunity is
## pinned separately in battle_defeat_withdraw.


func replay_name() -> String:
	return "hex_cancellation"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "grunt"},
		{"type": EngineCore.ACTION_SKILL, "leader": 5, "slot": 1},
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
			"ap": 4,
			"ap_max": 6,
			"regen": 2,
			"combo": 0,
			"guard": false,
			"hexed": false,
			"over": "",
			"party_hp": [60, 85, 70, 45, 50, 48],
			"next_action": "e_slash",
		},
		"log": [
			"Turn 1: battle vs Grunt",
			"Round 1: Ranger uses Hex: one enemy action this round will be cancelled",
			"Round 1: the hex cancels Grunt's Jab!",
		],
	}
