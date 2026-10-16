extends ReplayBase

## Battle smoke walkthrough: battle start through the quest-free seam with
## turn-based enemy scale (turn 1 -> Grunt 40 HP, at 8), one skill, one enemy
## phase — final state pinned bit-for-bit.
##
## Numbers: hero Strike (no combo, jitter 1.0) 14 -> Grunt 40 -> 26; the
## announced Jab hits the Bulwark for roundi(8 * 1.0 * 1.05) = 8 -> HP 77.
## (The session turn now only advances through the war report; end_turn is
## battle-scoped since the turn cycle arrived.)


func replay_name() -> String:
	return "smoke_battle"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "grunt"},
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
		"party_hp": [
			60,
			77,
			70,
			45,
			50,
			48
		],
		"regen": 2,
		"round": 2
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
		"Turn 1: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 26)",
		"Round 1: Press-Gang Hand uses Hook Rake for 8 damage on Bram Ironkeel (HP 77)"
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 100,
	"tickets": 0,
	"turn": 1
}
