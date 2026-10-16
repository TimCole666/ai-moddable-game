extends ReplayBase

## Battle smoke walkthrough: turn advance (no battle), battle start with the
## turn-based enemy scale (turn 2 -> Grunt 40 HP * 1.15 = 46, at 8 * 1.15 = 9),
## one skill, one enemy phase — final state pinned bit-for-bit.
##
## Numbers: hero Strike (no combo) 14 -> Grunt 32; the announced Jab hits the
## Bulwark for roundi(9 * 1.0 * 1.05) = 9 -> HP 76.


func replay_name() -> String:
	return "smoke_battle"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "grunt"},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
	]


func expected_state() -> Dictionary:
	return {
		"pack_id": "builtin",
		"turn": 2,
		"battle": {
			"enemy": "grunt",
			"boss": false,
			"enemy_hp": 32,
			"enemy_max_hp": 46,
			"enemy_at": 9,
			"round": 2,
			"ap": 4,
			"ap_max": 6,
			"regen": 2,
			"combo": 0,
			"guard": false,
			"hexed": false,
			"over": "",
			"party_hp": [60, 76, 70, 45, 50, 48],
			"next_action": "e_slash",
		},
		"log": [
			"Turn 2: end turn",
			"Turn 2: battle vs Grunt",
			"Round 1: Vanguard uses Strike for 14 damage (enemy HP 32)",
			"Round 1: Grunt uses Jab for 9 damage on Bulwark (HP 76)",
		],
	}
