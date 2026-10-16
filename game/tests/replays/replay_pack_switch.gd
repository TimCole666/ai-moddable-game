extends ReplayBase

## Pack switching preserves rules and state: a session partway through a quest
## battle switches to the second placeholder pack (Iron Road) via the import
## action — turn, quest, battle resources and log carry over; only pack_id and
## the pack text change, so the very next skill logs with the new world's
## names.

const IRONROAD_PATH := "res://engine/packs/ironroad.json"


func replay_name() -> String:
	return "pack_switch_preserves_state"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_IMPORT_PACK, "path": IRONROAD_PATH},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
	]


func expected_state() -> Dictionary:
	return {
		"base_options": null,
		"battle": {
			"ap": 2,
			"ap_max": 6,
			"boss": false,
			"combo": 1,
			"enemy": "grunt",
			"enemy_at": 8,
			"enemy_hp": 11,
			"enemy_max_hp": 40,
			"guard": false,
			"hexed": false,
			"next_action": "e_slash",
			"over": "",
			"party_hp": [60, 77, 70, 45, 50, 48],
			"regen": 2,
			"round": 2,
		},
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
			"Turn 1: Preparation quest started: Ridge Patrol.",
			"Turn 1: battle vs Grunt",
			"Round 1: Vanguard uses Strike for 14 damage (enemy HP 26)",
			"Round 1: Grunt uses Jab for 8 damage on Bulwark (HP 77)",
			"Turn 1: theme pack switched to Iron Road.",
			"Round 2: Engine Driver uses Coupling Strike for 15 damage (enemy HP 11)",
		],
		"medals": 0,
		"pack_id": "ironroad",
		"phase": 0,
		"quest": {"idx": 0, "pool": "prep", "step": 0},
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
