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
				"exp": 3,
			},
			"healer": {
				"count": 2,
				"exp": 5,
			},
			"hero": {
				"count": 2,
				"exp": 3,
			},
			"mage": {
				"count": 1,
				"exp": 3,
			},
			"striker": {
				"count": 1,
				"exp": 3,
			},
			"tank": {
				"count": 1,
				"exp": 5,
			},
		},
		"ended": "",
		"fatigue": 0,
		"gains_total": 4,
		"gains_turn": 2,
		"log": [
			"Turn 1: Preparation quest started: Ridge Patrol.",
			"Turn 1: treasure chest! 3 cards — take one.",
			"Turn 1: card gained: Vanguard (copy x2).",
			"Turn 1: You escort supplies to the alliance camp.",
			"Turn 1: rest site: squad fully restored, fatigue cleared.",
			"Turn 1: quest complete: Ridge Patrol.",
			"Turn 1: Operation quest started: Storm the Fort.",
			"Turn 1: skirmish vs Brute: won handily (squad AT 69). Leaders +1 EXP.",
			"Turn 1: You escort supplies to the alliance camp.",
			"Turn 1: rest site: squad fully restored, fatigue cleared.",
			"Turn 1: treasure chest! 3 cards — take one.",
			"Turn 1: card gained: Medic (copy x2).",
			"Turn 1: quest complete: Storm the Fort.",
			"Turn 1: earned a meal ticket.",
			"Turn 1: meal ticket spent: Bulwark event, +2 EXP.",
			"Turn 1 war report: the enemy pushed the frontier — the alliance lost 5 ground. 95% of the realm remains.",
			"Turn 2: Preparation quest started: Ridge Patrol.",
			"Turn 2: battle vs Grunt",
			"Round 1: Vanguard uses Strike for 14 damage (enemy HP 32)",
			"Round 1: Grunt uses Jab for 9 damage on Bulwark (HP 76)",
			"Round 2: Vanguard uses Strike for 15 damage (enemy HP 17)",
			"Round 2: Grunt uses Jab for 8 damage on Medic (HP 62)",
			"Round 3: Vanguard uses Strike for 13 damage (enemy HP 4)",
			"Round 3: Grunt uses Jab for 9 damage on Sage (HP 36)",
			"Round 4: Vanguard uses Strike for 15 damage (enemy HP 0)",
			"Round 4: victory!",
			"Turn 2: battle over",
			"Turn 2: A veteran shares an old lesson over dinner. (Medic +2 EXP)",
			"Turn 2: war supplies secured: gains +2 (turn total 2).",
			"Turn 2: quest complete: Ridge Patrol.",
		],
		"medals": 0,
		"pack_id": "builtin",
		"phase": 1,
		"quest": null,
		"realm": 95,
		"tickets": 0,
		"turn": 2,
	}
