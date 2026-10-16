extends ReplayBase

## The second placeholder pack plays a full session start under the v1
## contract: it must validate (complete trilingual text) and drive the same
## rules with its own names and flavor.

const IRONROAD_PATH := "res://engine/packs/ironroad.json"


func replay_name() -> String:
	return "ironroad_pack_smoke"


func pack() -> Dictionary:
	var loaded := GameEngine.load_pack_file(IRONROAD_PATH)
	if loaded["ok"]:
		return loaded["pack"]
	# A missing or invalid pack file must fail the replay loudly, not
	# silently fall back to the builtin pack.
	return {"id": "ironroad-load-failed"}


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
	]


func expected_state() -> Dictionary:
	return {
		"base_options": null,
		"battle": {
			"ap": 4,
			"ap_max": 6,
			"boss": false,
			"combo": 0,
			"enemy": "grunt",
			"enemy_at": 8,
			"enemy_hp": 26,
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
			"Turn 1: Preparation quest started: Track Inspection.",
			"Turn 1: battle vs Raider",
			"Round 1: Engine Driver uses Coupling Strike for 14 damage (enemy HP 26)",
			"Round 1: Raider uses Lash for 8 damage on Brakeman (HP 77)",
		],
		"medals": 0,
		"pack_id": "ironroad",
		"phase": 0,
		"quest": {"idx": 0, "pool": "prep", "step": 0},
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
