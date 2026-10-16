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
			"exp": 0
		},
		"healer": {
			"count": 1,
			"exp": 0
		},
		"hero": {
			"count": 1,
			"exp": 12
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
		"Turn 1: quiet evening with Captain Maren Stormbite: Rain drums the stern windows while warm hands map every scar you own; when the storm finally passes you have learned her name gasped, not spoken. (+2 EXP)",
		"Turn 1 dispatch from the tide: raiders tore 9 leagues from our waters — 91% of the sea still flies the crimson flag.",
		"Turn 2: quiet evening with Captain Maren Stormbite: She tastes of rum and storm-salt; the hammock keeps the tide's rhythm and the lantern burns to nothing before either of you is done. (+2 EXP)",
		"Turn 2 dispatch from the tide: raiders tore 9 leagues from our waters — 82% of the sea still flies the crimson flag.",
		"Turn 3: quiet evening with Captain Maren Stormbite: A rare quiet anchorage: oil, slow hands, whispered charts of each other's bodies — the tide turns twice before either of you surfaces. (+2 EXP)",
		"Turn 3 dispatch from the tide: raiders tore 9 leagues from our waters — 73% of the sea still flies the crimson flag.",
		"Turn 4: quiet evening with Captain Maren Stormbite: The crew sleeps ashore and the ship creaks around two voices; the dawn watch finds an empty rum bottle and the two of you still tangled in one sheet. (+2 EXP)",
		"Turn 4 dispatch from the tide: raiders tore 9 leagues from our waters — 64% of the sea still flies the crimson flag.",
		"Turn 5: quiet evening with Captain Maren Stormbite: Lamplight, a lock turning on the cabin door: she undresses you with a sailor's economy, lays you back on the charts, and makes the whole sea wait. (+2 EXP)",
		"Turn 5 dispatch from the tide: raiders tore 9 leagues from our waters — 55% of the sea still flies the crimson flag.",
		"Turn 6: quiet evening with Captain Maren Stormbite: Rain drums the stern windows while warm hands map every scar you own; when the storm finally passes you have learned her name gasped, not spoken. (+2 EXP)",
		"Turn 6 dispatch from the tide: raiders tore 9 leagues from our waters — 46% of the sea still flies the crimson flag.",
		"Turn 7: warning: the realm is below half (46% held)."
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 46,
	"tickets": 0,
	"turn": 7
}
