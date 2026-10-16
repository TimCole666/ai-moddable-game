extends ReplayBase

## Defeat terminates the battle with a result state: vs the Boss the squad
## cannot win by stalling — ten rounds of absorbed hits, then the round cap
## (10) withdraws the squad -> over "lose".
##
## Also pins boss hex immunity: the round-1 Hex is NOT consumed and the Boss's
## Slam is NOT cancelled — the hex stays armed (hexed: true) through the whole
## battle and the Boss still hits every round. Damage per round:
##   R1 Slam 27 -> Bulwark 58      R6 Bolt 20 -> Vanguard 40
##   R2 Jab 14 -> Medic 56         R7 Slam 23 -> Bulwark 35
##   R3 Bolt 19 -> Sage 26         R8 Jab 16 -> Medic 40
##   R4 Slam 28 -> Dancer 22       R9 Bolt 21 -> Sage 5
##   R5 Jab 15 -> Ranger 33        R10 Slam 24 -> Dancer 0


func replay_name() -> String:
	return "battle_defeat_withdraw"


func actions() -> Array:
	var actions: Array = [
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "boss"},
		{"type": EngineCore.ACTION_SKILL, "leader": 5, "slot": 1},
	]
	for i in 11:
		actions.append({"type": EngineCore.ACTION_END_TURN})
	return actions


func expected_state() -> Dictionary:
	return {
		"pack_id": "builtin",
		"turn": 1,
		"battle": {
			"enemy": "boss",
			"boss": true,
			"enemy_hp": 160,
			"enemy_max_hp": 160,
			"enemy_at": 16,
			"round": 11,
			"ap": 6,
			"ap_max": 6,
			"regen": 2,
			"combo": 0,
			"guard": false,
			"hexed": true,
			"over": "lose",
			"party_hp": [40, 35, 40, 5, 0, 33],
			"next_action": "e_slash",
		},
		"log": [
			"Turn 1: battle vs Warlord",
			"Round 1: Ranger uses Hex: one enemy action this round will be cancelled",
			"Round 1: Warlord uses Slam for 27 damage on Bulwark (HP 58)",
			"Round 2: Warlord uses Jab for 14 damage on Medic (HP 56)",
			"Round 3: Warlord uses Bolt for 19 damage on Sage (HP 26)",
			"Round 4: Warlord uses Slam for 28 damage on Dancer (HP 22)",
			"Round 5: Warlord uses Jab for 15 damage on Ranger (HP 33)",
			"Round 6: Warlord uses Bolt for 20 damage on Vanguard (HP 40)",
			"Round 7: Warlord uses Slam for 23 damage on Bulwark (HP 35)",
			"Round 8: Warlord uses Jab for 16 damage on Medic (HP 40)",
			"Round 9: Warlord uses Bolt for 21 damage on Sage (HP 5)",
			"Round 10: Warlord uses Slam for 24 damage on Dancer (HP 0)",
			"Round 11: the squad withdraws (stalemate)",
		],
	}
