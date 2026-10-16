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
	"base_options": null,
	"battle": {
		"ap": 6,
		"ap_max": 6,
		"boss": true,
		"combo": 0,
		"enemy": "boss",
		"enemy_at": 16,
		"enemy_hp": 120,
		"enemy_max_hp": 120,
		"guard": false,
		"hexed": true,
		"next_action": "e_slash",
		"over": "lose",
		"party_hp": [
			40,
			35,
			40,
			5,
			0,
			33
		],
		"regen": 2,
		"round": 11
	},
	"chest": null,
	"collection": {
		"archer": {
			"count": 1,
			"exp": 0
		},
		"healer": {
			"count": 1,
			"exp": 0
		},
		"hero": {
			"count": 1,
			"exp": 0
		},
		"mage": {
			"count": 1,
			"exp": 0
		},
		"striker": {
			"count": 1,
			"exp": 0
		},
		"tank": {
			"count": 1,
			"exp": 0
		}
	},
	"ended": "",
	"fatigue": 0,
	"gains_total": 0,
	"gains_turn": 0,
	"log": [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
		"Turn 1: battle vs Admiral Blackjaw",
		"Round 1: Gull-Eye Finn uses Drowned Curse: one enemy action this round will be cancelled",
		"Round 1: Admiral Blackjaw uses Cannon Slam for 27 damage on Bram Ironkeel (HP 58)",
		"Round 2: Admiral Blackjaw uses Hook Rake for 14 damage on Tidepriestess Nuala (HP 56)",
		"Round 3: Admiral Blackjaw uses Venom Bolt for 19 damage on Tempest Iris (HP 26)",
		"Round 4: Admiral Blackjaw uses Cannon Slam for 28 damage on Twin-Cut Sable (HP 22)",
		"Round 5: Admiral Blackjaw uses Hook Rake for 15 damage on Gull-Eye Finn (HP 33)",
		"Round 6: Admiral Blackjaw uses Venom Bolt for 20 damage on Captain Maren Stormbite (HP 40)",
		"Round 7: Admiral Blackjaw uses Cannon Slam for 23 damage on Bram Ironkeel (HP 35)",
		"Round 8: Admiral Blackjaw uses Hook Rake for 16 damage on Tidepriestess Nuala (HP 40)",
		"Round 9: Admiral Blackjaw uses Venom Bolt for 21 damage on Tempest Iris (HP 5)",
		"Round 10: Admiral Blackjaw uses Cannon Slam for 24 damage on Twin-Cut Sable (HP 0)",
		"Round 11: the squad withdraws (stalemate)"
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 100,
	"tickets": 0,
	"turn": 1
}
