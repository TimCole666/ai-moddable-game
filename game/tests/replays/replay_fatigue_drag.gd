extends ReplayBase

## The Fatigue part drags battle AP once its threshold is crossed. The pack
## enables Fatigue (threshold 2, apPenalty 1); every war report ticks fatigue
## up by 1. Two report cycles without a rest site push fatigue to 2, and the
## next battle starts with AP max 5 and regen 1 instead of 6 and 2 — with the
## drag announced in the log.


func replay_name() -> String:
	return "fatigue_drag"


func pack() -> Dictionary:
	var pack := GameEngine.get_builtin_pack()
	(pack["parts"]["fatigue"] as Dictionary)["enabled"] = true
	return pack


func actions() -> Array:
	return [
		# Turn 1: skip the quest, resolve the base phase and war report.
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_BASE_PICK, "option": 0},
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_END_PHASE},             # report: fatigue 1
		# Turn 2: same quick cycle.
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_BASE_PICK, "option": 0},
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_END_PHASE},             # report: fatigue 2
		# Turn 3: the next battle starts dragged.
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # battle: Grunt
	]


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": {
		"ap": 4,
		"ap_max": 5,
		"boss": false,
		"combo": 0,
		"enemy": "grunt",
		"enemy_at": 10,
		"enemy_hp": 52,
		"enemy_max_hp": 52,
		"guard": false,
		"hexed": false,
		"next_action": "e_slash",
		"over": "",
		"party_hp": [
			60,
			85,
			70,
			45,
			50,
			48
		],
		"regen": 1,
		"round": 1
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
			"exp": 4
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
	"fatigue": 2,
	"gains_total": 0,
	"gains_turn": 0,
	"log": [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
		"Turn 1: quiet evening with Captain Maren Stormbite: Rain drums the stern windows while her mouth traces every scar you own, then moves lower, until you are shaking and begging her name; when the storm passes you are spent and gasping against the glass. (+2 EXP)",
		"Turn 1 dispatch from the tide: raiders tore 13 leagues from our waters — 87% of the sea still flies the crimson flag.",
		"Turn 2: quiet evening with Captain Maren Stormbite: She tastes of rum and salt; in the swaying hammock she takes you inside her and sets the tide's rhythm with her hips, and the lantern burns out before either of you stops. (+2 EXP)",
		"Turn 2 dispatch from the tide: raiders tore 13 leagues from our waters — 74% of the sea still flies the crimson flag.",
		"Turn 3: Preparation quest started: Provisions Ashore.",
		"Turn 3: Sea Weariness drags the squad: AP regen -1.",
		"Turn 3: battle vs Press-Gang Hand"
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": {
		"idx": 0,
		"pool": "prep",
		"step": 0
	},
	"realm": 74,
	"tickets": 0,
	"turn": 3
}
