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
				"exp": 6,
			},
			"healer": {
				"count": 2,
				"exp": 10,
			},
			"hero": {
				"count": 2,
				"exp": 8,
			},
			"mage": {
				"count": 1,
				"exp": 6,
			},
			"striker": {
				"count": 1,
				"exp": 6,
			},
			"tank": {
				"count": 2,
				"exp": 6,
			},
		},
		"ended": "",
		"fatigue": 0,
		"gains_total": 3,
		"gains_turn": 0,
		"log": [
			"Turn 1: Preparation quest started: Ridge Patrol.",
			"Turn 1: battle vs Grunt",
			"Round 1: Vanguard uses Strike for 14 damage (enemy HP 26)",
			"Round 1: Grunt uses Jab for 8 damage on Bulwark (HP 77)",
			"Round 2: Vanguard uses Strike for 15 damage (enemy HP 11)",
			"Round 2: Grunt uses Jab for 7 damage on Medic (HP 63)",
			"Round 3: Vanguard uses Strike for 13 damage (enemy HP 0)",
			"Round 3: victory!",
			"Turn 1: battle over",
			"Turn 1: You escort supplies to the alliance camp.",
			"Turn 1: war supplies secured: gains +2 (turn total 3).",
			"Turn 1: quest complete: Ridge Patrol.",
			"Turn 1: Operation quest started: Storm the Fort.",
			"Turn 1: skirmish vs Brute: won handily (squad AT 69). Leaders +1 EXP.",
			"Turn 1: treasure chest! 3 cards — take one.",
			"Turn 1: card gained: Vanguard (copy x2).",
			"Turn 1: rest site: squad fully restored, fatigue cleared.",
			"Turn 1: treasure chest! 3 cards — take one.",
			"Turn 1: card gained: Medic (copy x2).",
			"Turn 1: quest complete: Storm the Fort.",
			"Turn 1: earned a meal ticket.",
			"Turn 1: meal ticket spent: Vanguard event, +2 EXP.",
			"Turn 1 war report: the enemy pushed the frontier — the alliance lost 3 ground. 97% of the realm remains.",
			"Turn 2: Preparation quest started: Supply Scout.",
			"Turn 2: treasure chest! 3 cards — take one.",
			"Turn 2: card gained: Bulwark (copy x2).",
			"Turn 2: A veteran shares an old lesson over dinner. (Medic +2 EXP)",
			"Turn 2: medal +1 (squad level 0).",
			"Turn 2: quest complete: Supply Scout.",
			"Turn 2: Operation quest started: Ambush at the Ford.",
			"Turn 2: skirmish vs Grunt: won handily (squad AT 69). Leaders +1 EXP.",
			"Turn 2: battle vs Shaman",
			"Round 1: Dancer uses Blast for 28 damage (enemy HP 12)",
			"Round 1: Shaman uses Bolt for 15 damage on Bulwark (HP 70)",
			"Round 2: Dancer uses Twin Strike for 16 damage (enemy HP 0)",
			"Round 2: victory!",
			"Turn 2: battle over",
			"Turn 2: rest site: squad fully restored, fatigue cleared.",
			"Turn 2: medal +1 (squad level 1).",
			"Turn 2: quest complete: Ambush at the Ford.",
			"Turn 2: earned a meal ticket.",
			"Turn 2: meal ticket spent: Medic event, +2 EXP.",
			"Turn 2 war report: the enemy pushed the frontier — the alliance lost 9 ground. 88% of the realm remains.",
		],
		"medals": 2,
		"pack_id": "builtin",
		"phase": 0,
		"quest": null,
		"realm": 88,
		"tickets": 0,
		"turn": 3,
	}
