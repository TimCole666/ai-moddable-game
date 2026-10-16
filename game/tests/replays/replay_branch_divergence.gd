extends ReplayBase

## Branch divergence: the same quests walked on opposite branches produce
## different chests, events, and fights. Turn 1 takes every right branch
## (chest, +gains events, skirmish, rest site), turn 2 takes the left battle
## and event branches of the same prep quest — route decisions change what
## you face, and the war report reflects the banked gains.


func replay_name() -> String:
	return "branch_divergence"


func actions() -> Array:
	return [
		# --- Turn 1: prep quest A, all right ---
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # chest
		{"type": EngineCore.ACTION_CHEST_PICK, "idx": 1},
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # event: +war gains
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # rest site
		# --- Turn 1: operation quest A, all right ---
		{"type": EngineCore.ACTION_START_QUEST, "pool": "operation", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # skirmish: Brute
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # event: +war gains
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # rest site
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # chest
		{"type": EngineCore.ACTION_CHEST_PICK, "idx": 2},
		# --- Turn 1: base phase (logistics) + war report ---
		{"type": EngineCore.ACTION_BASE_PICK, "option": 1},  # logistics: +1 gains
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_END_PHASE},               # war report -> turn 2
		# --- Turn 2: prep quest A, all left (the divergent route) ---
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # battle: Grunt (turn-2 scale)
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},              # win -> node done
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # event: +EXP
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # war supplies +2
	]


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": null,
	"chest": null,
	"collection": {
		"archer": {
			"count": 1,
			"exp": 3
		},
		"healer": {
			"count": 2,
			"exp": 5
		},
		"hero": {
			"count": 2,
			"exp": 3
		},
		"mage": {
			"count": 1,
			"exp": 3
		},
		"striker": {
			"count": 1,
			"exp": 3
		},
		"tank": {
			"count": 1,
			"exp": 7
		}
	},
	"ended": "",
	"fatigue": 1,
	"gains_total": 4,
	"gains_turn": 2,
	"log": [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
		"Turn 1: Preparation quest started: Provisions Ashore.",
		"Turn 1: treasure chest! 3 cards — take one.",
		"Turn 1: card gained: Captain Maren Stormbite (copy x2).",
		"Turn 1: War chests land on the beach at midnight; the crew hauls barrels through the surf while two officers, half undressed, finish each other against the chart table.",
		"Turn 1: rest site: squad fully restored, fatigue cleared.",
		"Turn 1: quest complete: Provisions Ashore.",
		"Turn 1: Operation quest started: Storm Fort Siren.",
		"Turn 1: skirmish vs Sharkhide Brute: won handily (squad AT 69). Leaders +1 EXP.",
		"Turn 1: War chests land on the beach at midnight; the crew hauls barrels through the surf while two officers, half undressed, finish each other against the chart table.",
		"Turn 1: rest site: squad fully restored, fatigue cleared.",
		"Turn 1: treasure chest! 3 cards — take one.",
		"Turn 1: card gained: Tidepriestess Nuala (copy x2).",
		"Turn 1: quest complete: Storm Fort Siren.",
		"Turn 1: earned a meal ticket.",
		"Turn 1: meal ticket spent: Bram Ironkeel event, +4 EXP.",
		"Turn 1 dispatch from the tide: raiders tore 9 leagues from our waters — 91% of the sea still flies the crimson flag.",
		"Turn 2: Preparation quest started: Provisions Ashore.",
		"Turn 2: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 32)",
		"Round 1: Press-Gang Hand uses Hook Rake for 9 damage on Bram Ironkeel (HP 76)",
		"Round 2: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 17)",
		"Round 2: Press-Gang Hand uses Hook Rake for 8 damage on Tidepriestess Nuala (HP 62)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 4)",
		"Round 3: Press-Gang Hand uses Hook Rake for 9 damage on Tempest Iris (HP 36)",
		"Round 4: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 0)",
		"Round 4: victory!",
		"Turn 2: battle over",
		"Turn 2: The ship's surgeon teaches anatomy in one breathless lesson: she names each place she likes to be touched, then shows you with her mouth and fingers until you can name them back through a moan. (Tidepriestess Nuala +2 EXP)",
		"Turn 2: war supplies secured: gains +2 (turn total 2).",
		"Turn 2: quest complete: Provisions Ashore."
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 1,
	"quest": null,
	"realm": 91,
	"tickets": 0,
	"turn": 2
}
