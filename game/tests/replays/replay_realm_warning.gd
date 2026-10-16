extends ReplayBase

## Realm integrity tracks across turns and warns below half. With no war
## gains banked, every war report costs the realm 9 points; after six barren
## turns the realm sits at 46% and the engine warns on the next turn. The
## report template with its {turn} {loss} {left} placeholders comes from the
## pack text.


func replay_name() -> String:
	return "realm_integrity_warning"


func actions() -> Array:
	var actions: Array = []
	for i in 6:
		actions.append({"type": EngineCore.ACTION_END_PHASE})                # prep -> operation
		actions.append({"type": EngineCore.ACTION_END_PHASE})                # operation -> base
		actions.append({"type": EngineCore.ACTION_BASE_PICK, "option": 0})   # quiet evening
		actions.append({"type": EngineCore.ACTION_END_PHASE})                # base -> war report
		actions.append({"type": EngineCore.ACTION_END_PHASE})                # report -> next turn
	return actions


func expected_state() -> Dictionary:
	return {
		"base_options": null,
		"battle": null,
		"chest": null,
		"collection": {
			"archer": {
				"count": 1,
				"exp": 0,
			},
			"healer": {
				"count": 1,
				"exp": 0,
			},
			"hero": {
				"count": 1,
				"exp": 12,
			},
			"mage": {
				"count": 1,
				"exp": 0,
			},
			"striker": {
				"count": 1,
				"exp": 0,
			},
			"tank": {
				"count": 1,
				"exp": 0,
			},
		},
		"ended": "",
		"fatigue": 0,
		"gains_total": 0,
		"gains_turn": 0,
		"log": [
			"Turn 1: quiet evening: Vanguard +2 EXP.",
			"Turn 1 war report: the enemy pushed the frontier — the alliance lost 9 ground. 91% of the realm remains.",
			"Turn 2: quiet evening: Vanguard +2 EXP.",
			"Turn 2 war report: the enemy pushed the frontier — the alliance lost 9 ground. 82% of the realm remains.",
			"Turn 3: quiet evening: Vanguard +2 EXP.",
			"Turn 3 war report: the enemy pushed the frontier — the alliance lost 9 ground. 73% of the realm remains.",
			"Turn 4: quiet evening: Vanguard +2 EXP.",
			"Turn 4 war report: the enemy pushed the frontier — the alliance lost 9 ground. 64% of the realm remains.",
			"Turn 5: quiet evening: Vanguard +2 EXP.",
			"Turn 5 war report: the enemy pushed the frontier — the alliance lost 9 ground. 55% of the realm remains.",
			"Turn 6: quiet evening: Vanguard +2 EXP.",
			"Turn 6 war report: the enemy pushed the frontier — the alliance lost 9 ground. 46% of the realm remains.",
			"Turn 7: warning: the realm is below half (46% held).",
		],
		"medals": 0,
		"pack_id": "builtin",
		"phase": 0,
		"quest": null,
		"realm": 46,
		"tickets": 0,
		"turn": 7,
	}
