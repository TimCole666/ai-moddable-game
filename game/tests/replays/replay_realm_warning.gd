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
	"fatigue": 6,
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
		"Turn 3: quiet evening with Captain Maren Stormbite: A rare quiet anchorage: warm oil, slow hands, her fingers opening you one knuckle at a time while she whispers charts of your body; the tide turns twice before either of you comes apart. (+2 EXP)",
		"Turn 3 dispatch from the tide: raiders tore 13 leagues from our waters — 61% of the sea still flies the crimson flag.",
		"Turn 4: quiet evening with Captain Maren Stormbite: The crew sleeps ashore and the ship creaks around two bodies: you wake with her astride you, and the dawn watch finds an empty rum bottle and the two of you still tangled, sweat-slick, in one sheet. (+2 EXP)",
		"Turn 4 dispatch from the tide: raiders tore 13 leagues from our waters — 48% of the sea still flies the crimson flag.",
		"Turn 5: warning: the realm is below half (48% held).",
		"Turn 5: quiet evening with Captain Maren Stormbite: Lamplight and a barred cabin door: she strips you with a sailor's impatience, lays you back across the charts, and rides you slow until you both forget the sea is waiting. (+2 EXP)",
		"Turn 5 dispatch from the tide: raiders tore 13 leagues from our waters — 35% of the sea still flies the crimson flag.",
		"Turn 6: warning: the realm is below half (35% held).",
		"Turn 6: quiet evening with Captain Maren Stormbite: Rain drums the stern windows while her mouth traces every scar you own, then moves lower, until you are shaking and begging her name; when the storm passes you are spent and gasping against the glass. (+2 EXP)",
		"Turn 6 dispatch from the tide: raiders tore 13 leagues from our waters — 22% of the sea still flies the crimson flag.",
		"Turn 7: warning: the realm is below half (22% held)."
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 22,
	"tickets": 0,
	"turn": 7
}
