extends ReplayBase

## The full AP card battle walkthrough vs the Brute, played end to end:
## weakness blast, multi-hit combo, heal, brace, and victory — final state
## pinned bit-for-bit. Round-by-round:
##   R1 mage Blast [ice, weakness x1.5]: 22 -> Brute 48; enemy Slam 20 -> Bulwark 65
##   R2 striker Twin Strike (2 hits, combo 0): 8+8 = 16 -> Brute 32; enemy Jab 11 -> Medic 59
##   R3 medic Mend: all standing +9 (Bulwark 74, Medic 68); enemy Slam 19 -> Sage 26
##   R4 hero Strike: 15 -> Brute 17; enemy Jab 13 -> Dancer 37
##   R5 tank Brace (1 AP): the Slam lands for roundi(18.24 * 0.7) = 13 -> Ranger 35
##   R6 mage Blast [ice, weakness x1.5]: 22 -> Brute 0 — VICTORY


func replay_name() -> String:
	return "battle_walkthrough"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "brute"},
		{"type": EngineCore.ACTION_SKILL, "leader": 3, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 2, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 1, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 3, "slot": 0},
	]


func expected_state() -> Dictionary:
	return {
		"pack_id": "builtin",
		"turn": 1,
		"battle": {
			"enemy": "brute",
			"boss": false,
			"enemy_hp": 0,
			"enemy_max_hp": 70,
			"enemy_at": 12,
			"round": 6,
			"ap": 0,
			"ap_max": 6,
			"regen": 2,
			"combo": 1,
			"guard": false,
			"hexed": false,
			"over": "win",
			"party_hp": [60, 74, 68, 26, 37, 35],
			"next_action": "e_slash",
		},
		"log": [
			"Turn 1: battle vs Brute",
			"Round 1: Sage uses Blast for 22 damage (enemy HP 48)",
			"Round 1: Brute uses Slam for 20 damage on Bulwark (HP 65)",
			"Round 2: Dancer uses Twin Strike for 16 damage (enemy HP 32)",
			"Round 2: Brute uses Jab for 11 damage on Medic (HP 59)",
			"Round 3: Medic uses Mend: all standing leaders +9 HP",
			"Round 3: Brute uses Slam for 19 damage on Sage (HP 26)",
			"Round 4: Vanguard uses Strike for 15 damage (enemy HP 17)",
			"Round 4: Brute uses Jab for 13 damage on Dancer (HP 37)",
			"Round 5: Bulwark uses Brace: party braces (-30% incoming this round)",
			"Round 5: Brute uses Slam for 13 damage on Ranger (HP 35)",
			"Round 6: Sage uses Blast for 22 damage (enemy HP 0)",
			"Round 6: victory!",
		],
	}
