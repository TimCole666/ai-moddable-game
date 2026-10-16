extends ReplayBase

## The Core Loop walkthrough: two full turns — prep quest (branch battles and
## events), operation quest (auto-battle, chests, rest site), base phase
## (quiet evening, then a spent meal ticket), war reports softening realm
## losses, medals accruing squad levels — final state pinned bit-for-bit.


func replay_name() -> String:
	return "turn_cycle_walkthrough"


func actions() -> Array:
	return [
		# --- Turn 1: prep quest A (fight left, then events and supplies) ---
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # battle: Grunt
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},              # win -> node done
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # event: +war gains
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # war supplies +2
		# --- Turn 1: operation quest A (skirmish, chests, rest site) ---
		{"type": EngineCore.ACTION_START_QUEST, "pool": "operation", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # skirmish: Brute
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # chest
		{"type": EngineCore.ACTION_CHEST_PICK, "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # rest site
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # chest
		{"type": EngineCore.ACTION_CHEST_PICK, "idx": 2},
		# --- Turn 1: base phase + war report ---
		{"type": EngineCore.ACTION_BASE_PICK, "option": 0},  # quiet evening
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_END_PHASE},               # war report -> turn 2
		# --- Turn 2: prep quest B (chest, event, medal) ---
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 1},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # chest
		{"type": EngineCore.ACTION_CHEST_PICK, "idx": 1},
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # event: +EXP
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # medal +1
		# --- Turn 2: operation quest B (skirmish, shaman battle, medal) ---
		{"type": EngineCore.ACTION_START_QUEST, "pool": "operation", "idx": 1},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # skirmish: Grunt
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # battle: Shaman
		{"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 1},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},              # win -> node done
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # rest site
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # medal +1
		# --- Turn 2: base phase (meal ticket earned and spent) + war report ---
		{"type": EngineCore.ACTION_BASE_PICK, "option": 2},  # meal ticket
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_END_PHASE},               # war report -> turn 3
	]


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": null,
	"chest": null,
	"collection": {
		"archer": {
			"count": 1,
			"exp": 6
		},
		"healer": {
			"count": 2,
			"exp": 12
		},
		"hero": {
			"count": 2,
			"exp": 10
		},
		"mage": {
			"count": 1,
			"exp": 6
		},
		"striker": {
			"count": 1,
			"exp": 6
		},
		"tank": {
			"count": 2,
			"exp": 6
		}
	},
	"ended": "",
	"fatigue": 1,
	"gains_total": 3,
	"gains_turn": 0,
	"log": [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
		"Turn 1: Preparation quest started: Provisions Ashore.",
		"Turn 1: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 26)",
		"Round 1: Press-Gang Hand uses Hook Rake for 8 damage on Bram Ironkeel (HP 77)",
		"Round 2: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 11)",
		"Round 2: Press-Gang Hand uses Hook Rake for 7 damage on Tidepriestess Nuala (HP 63)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 0)",
		"Round 3: victory!",
		"Turn 1: battle over",
		"Turn 1: War chests land on the beach at midnight; the crew hauls barrels through the surf while two officers warm the chart room.",
		"Turn 1: war supplies secured: gains +2 (turn total 3).",
		"Turn 1: quest complete: Provisions Ashore.",
		"Turn 1: Operation quest started: Storm Fort Siren.",
		"Turn 1: skirmish vs Sharkhide Brute: won handily (squad AT 69). Leaders +1 EXP.",
		"Turn 1: treasure chest! 3 cards — take one.",
		"Turn 1: card gained: Captain Maren Stormbite (copy x2).",
		"Turn 1: rest site: squad fully restored, fatigue cleared.",
		"Turn 1: treasure chest! 3 cards — take one.",
		"Turn 1: card gained: Tidepriestess Nuala (copy x2).",
		"Turn 1: quest complete: Storm Fort Siren.",
		"Turn 1: earned a meal ticket.",
		"Turn 1: meal ticket spent: Captain Maren Stormbite event, +4 EXP.",
		"Turn 1 dispatch from the tide: raiders tore 7 leagues from our waters — 93% of the sea still flies the crimson flag.",
		"Turn 2: Preparation quest started: The Rum Run.",
		"Turn 2: treasure chest! 3 cards — take one.",
		"Turn 2: card gained: Bram Ironkeel (copy x2).",
		"Turn 2: The ship's surgeon teaches herb-lore and anatomy in one breathless lesson; by the end you can name every place she likes to be touched. (Tidepriestess Nuala +2 EXP)",
		"Turn 2: medal +1 (squad level 0).",
		"Turn 2: quest complete: The Rum Run.",
		"Turn 2: Operation quest started: Ambush in the Screaming Strait.",
		"Turn 2: skirmish vs Press-Gang Hand: won handily (squad AT 69). Leaders +1 EXP.",
		"Turn 2: battle vs Reef Hexer",
		"Round 1: Twin-Cut Sable uses Powder Blast for 28 damage (enemy HP 12)",
		"Round 1: Reef Hexer uses Venom Bolt for 15 damage on Bram Ironkeel (HP 70)",
		"Round 2: Twin-Cut Sable uses Knife Flurry for 16 damage (enemy HP 0)",
		"Round 2: victory!",
		"Turn 2: battle over",
		"Turn 2: rest site: squad fully restored, fatigue cleared.",
		"Turn 2: medal +1 (squad level 1).",
		"Turn 2: quest complete: Ambush in the Screaming Strait.",
		"Turn 2: earned a meal ticket.",
		"Turn 2: meal ticket spent: Tidepriestess Nuala event, +4 EXP.",
		"Turn 2 dispatch from the tide: raiders tore 13 leagues from our waters — 80% of the sea still flies the crimson flag."
	],
	"medals": 2,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 80,
	"tickets": 0,
	"turn": 3
}
