extends ReplayBase

## Medals, squad level, and meal tickets accumulate and are spendable: a prep
## medal and an operation medal raise the squad level (floor(medals / 2)),
## completing an operation quest earns a meal ticket (capped at 2), and the
## base phase spends it on a companion event (+2 EXP). The rest site clears
## fatigue on the way.


func replay_name() -> String:
	return "medal_meal_spending"


func actions() -> Array:
	return [
		# --- Turn 1: prep quest B — chest, rest site, medal ---
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 1},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # chest
		{"type": EngineCore.ACTION_CHEST_PICK, "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # rest site
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # medal +1 (squad level 0)
		# --- Turn 1: operation quest B — skirmish, shaman battle, medal ---
		{"type": EngineCore.ACTION_START_QUEST, "pool": "operation", "idx": 1},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # skirmish: Grunt
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # battle: Shaman
		{"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 1},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},              # win -> node done
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # rest site
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # medal +1 (squad level 1)
		# Operation quest complete -> meal ticket earned; base phase spends it.
		{"type": EngineCore.ACTION_BASE_PICK, "option": 2},  # meal ticket: +2 EXP
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_END_PHASE},               # war report -> turn 2
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
				"count": 1,
				"exp": 5,
			},
			"hero": {
				"count": 1,
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
				"count": 2,
				"exp": 3,
			},
		},
		"ended": "",
		"fatigue": 0,
		"gains_total": 0,
		"gains_turn": 0,
		"log": [
			"Turn 1: Preparation quest started: Supply Scout.",
			"Turn 1: treasure chest! 3 cards — take one.",
			"Turn 1: card gained: Bulwark (copy x2).",
			"Turn 1: rest site: squad fully restored, fatigue cleared.",
			"Turn 1: medal +1 (squad level 0).",
			"Turn 1: quest complete: Supply Scout.",
			"Turn 1: Operation quest started: Ambush at the Ford.",
			"Turn 1: skirmish vs Grunt: won handily (squad AT 69). Leaders +1 EXP.",
			"Turn 1: battle vs Shaman",
			"Round 1: Dancer uses Blast for 28 damage (enemy HP 7)",
			"Round 1: Shaman uses Bolt for 13 damage on Bulwark (HP 72)",
			"Round 2: Dancer uses Twin Strike for 16 damage (enemy HP 0)",
			"Round 2: victory!",
			"Turn 1: battle over",
			"Turn 1: rest site: squad fully restored, fatigue cleared.",
			"Turn 1: medal +1 (squad level 1).",
			"Turn 1: quest complete: Ambush at the Ford.",
			"Turn 1: earned a meal ticket.",
			"Turn 1: meal ticket spent: Medic event, +2 EXP.",
			"Turn 1 war report: the enemy pushed the frontier — the alliance lost 9 ground. 91% of the realm remains.",
		],
		"medals": 2,
		"pack_id": "builtin",
		"phase": 0,
		"quest": null,
		"realm": 91,
		"tickets": 0,
		"turn": 2,
	}
