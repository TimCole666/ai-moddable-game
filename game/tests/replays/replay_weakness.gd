extends ReplayBase

## The weakness multiplier is alive: the striker's fire Blast vs the fire-weak
## Shaman deals roundi(12 * 1.4 * 1.1 * 1.5) = 28, not the unboosted 18.
## The prototype once read the weakness off the battle instance instead of the
## enemy definition, which killed the multiplier ("dead-multiplier bug"); this
## replay keeps it dead. Without the x1.5 the Shaman survives the Twin Strike
## at 1 HP and the battle would NOT be over — the pinned victory + cleared
## battle would fail.
##
## Also pins the win flow: the victory result state (over "win") is visible
## after the winning skill, and the next end turn clears the battle.

func replay_name() -> String:
	return "weakness_multiplier_live"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "shaman"},
		{"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 1},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
	]


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": null,
	"chest": null,
	"collection": {
		"archer": {
			"count": 1,
			"exp": 2
		},
		"healer": {
			"count": 1,
			"exp": 2
		},
		"hero": {
			"count": 1,
			"exp": 2
		},
		"mage": {
			"count": 1,
			"exp": 2
		},
		"striker": {
			"count": 1,
			"exp": 2
		},
		"tank": {
			"count": 1,
			"exp": 2
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
		"Turn 1: battle vs Reef Hexer",
		"Round 1: Twin-Cut Sable uses Powder Blast for 28 damage (enemy HP 7)",
		"Round 1: Reef Hexer uses Venom Bolt for 13 damage on Bram Ironkeel (HP 72)",
		"Round 2: Twin-Cut Sable uses Knife Flurry for 16 damage (enemy HP 0)",
		"Round 2: victory!",
		"Turn 1: battle over"
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 100,
	"tickets": 0,
	"turn": 1
}
