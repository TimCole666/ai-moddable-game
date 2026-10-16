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
	"base_options": null,
	"battle": {
		"ap": 0,
		"ap_max": 6,
		"boss": false,
		"combo": 1,
		"enemy": "brute",
		"enemy_at": 12,
		"enemy_hp": 0,
		"enemy_max_hp": 70,
		"guard": false,
		"hexed": false,
		"next_action": "e_slash",
		"over": "win",
		"party_hp": [
			60,
			74,
			68,
			26,
			37,
			35
		],
		"regen": 2,
		"round": 6
	},
	"chest": null,
	"collection": {
		"archer": {
			"count": 1,
			"exp": 2
		},
		"healer": {
			"count": 1,
			"exp": 2
		},
		"hero": {
			"count": 1,
			"exp": 2
		},
		"mage": {
			"count": 1,
			"exp": 2
		},
		"striker": {
			"count": 1,
			"exp": 2
		},
		"tank": {
			"count": 1,
			"exp": 2
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
		"Turn 1: battle vs Sharkhide Brute",
		"Round 1: Tempest Iris uses Powder Blast for 22 damage (enemy HP 48)",
		"Round 1: Sharkhide Brute uses Cannon Slam for 20 damage on Bram Ironkeel (HP 65)",
		"Round 2: Twin-Cut Sable uses Knife Flurry for 16 damage (enemy HP 32)",
		"Round 2: Sharkhide Brute uses Hook Rake for 11 damage on Tidepriestess Nuala (HP 59)",
		"Round 3: Tidepriestess Nuala uses Sea Salve: all standing leaders +9 HP",
		"Round 3: Sharkhide Brute uses Cannon Slam for 19 damage on Tempest Iris (HP 26)",
		"Round 4: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 17)",
		"Round 4: Sharkhide Brute uses Hook Rake for 13 damage on Twin-Cut Sable (HP 37)",
		"Round 5: Bram Ironkeel uses Brace the Deck: party braces (-30% incoming this round)",
		"Round 5: Sharkhide Brute uses Cannon Slam for 13 damage on Gull-Eye Finn (HP 35)",
		"Round 6: Tempest Iris uses Powder Blast for 22 damage (enemy HP 0)",
		"Round 6: victory!"
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 100,
	"tickets": 0,
	"turn": 1
}
