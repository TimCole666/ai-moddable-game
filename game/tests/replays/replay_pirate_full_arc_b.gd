extends ReplayBase

## Ticket 07: full-arc pirate-pack playthrough, branch B — every one of the
## 8 turns runs preparation quest B (The Rum Run); turns 1 and 3 also run
## operation quest B (Ambush in the Screaming Strait) with the Reef Hexer and
## Sharkhide Brute fights, earning and spending meal tickets; the other turns
## skip it so the base phase offers the quiet evening (the pack's adult
## rest-scene pool, rotating by turn). Final state pinned bit-for-bit;
## checks() pins that pirate names ride every log line and no skeleton
## placeholder leaks.


func replay_name() -> String:
	return "pirate_full_arc_b"


## Twin-Cut Sable's Powder Blast (fire, weakness x1.5) vs the Reef Hexer:
## 28 on round 1, then Knife Flurry (16) — the hexer dies in round 2 on
## turns 1 and 3; on turn 3 a brace bridges round 3 and a last blast lands
## the win on round 4.
func _shaman_fight(turn: int) -> Array:
	var acts := []
	acts.append({"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 1})
	acts.append({"type": EngineCore.ACTION_END_TURN})
	acts.append({"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 0})
	acts.append({"type": EngineCore.ACTION_END_TURN})
	if turn >= 3:
		acts.append({"type": EngineCore.ACTION_SKILL, "leader": 1, "slot": 0})
		acts.append({"type": EngineCore.ACTION_END_TURN})
		acts.append({"type": EngineCore.ACTION_SKILL, "leader": 4, "slot": 1})
		acts.append({"type": EngineCore.ACTION_END_TURN})
	return acts


## Tempest Iris's Powder Blast (ice, weakness x1.5) vs the Sharkhide Brute:
## 22/24/23/22 on rounds 1/2/4/6 with braced rounds between — the brute
## (70 HP at turn 1, 91 at turn 3) dies exactly on round 6.
func _brute_fight() -> Array:
	return [
		{"type": EngineCore.ACTION_SKILL, "leader": 3, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 3, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 1, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 3, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 1, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 3, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
	]


func actions() -> Array:
	var acts := []
	for turn in range(1, 9):
		# --- Preparation quest B: chest, event or rest site, war supplies ---
		acts.append({"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 1})
		acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 0})    # chest
		acts.append({"type": EngineCore.ACTION_CHEST_PICK, "idx": 0})
		acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 1 if turn % 2 == 1 else 0})  # ev_exp / rest site
		acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 1})    # war supplies +2
		if turn == 1 or turn == 3:
			# --- Operation quest B: skirmish, hexer fight, brute fight, medal ---
			acts.append({"type": EngineCore.ACTION_START_QUEST, "pool": "operation", "idx": 1})
			acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 0})  # skirmish: Press-Gang Hand
			acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 1})  # battle: Reef Hexer
			acts.append_array(_shaman_fight(turn))
			acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 0})  # battle: Sharkhide Brute
			acts.append_array(_brute_fight())
			acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 1})  # medal -> quest complete
			# Meal ticket earned; the base phase spends it.
			acts.append({"type": EngineCore.ACTION_BASE_PICK, "option": 0})
		else:
			# No operation quest -> no ticket -> the quiet evening (adult pool).
			acts.append({"type": EngineCore.ACTION_END_PHASE})
			acts.append({"type": EngineCore.ACTION_BASE_PICK, "option": 0})
		acts.append({"type": EngineCore.ACTION_END_PHASE})
		acts.append({"type": EngineCore.ACTION_END_PHASE})   # war report -> next turn
	return acts


func checks() -> PackedStringArray:
	var problems := PackedStringArray()
	var log: Array = GameEngine.get_state()["log"]
	var joined := "\n".join(log)
	for banned in ["Vanguard", "Bulwark", "Medic", "Sage", "Dancer", "Ranger",
			"Grunt", "Warlord", "Jab", "Ridge Patrol",
			"Supply Scout", "Storm the Fort", "Ambush at the Ford",
			"Placeholder", "placeholder", "skeleton", "TODO", "TBD", "alliance",
			"{turn}", "{loss}", "{left}"]:
		if joined.contains(banned):
			problems.append("log leaks skeleton placeholder %s" % [banned])
	for required in ["Captain Maren Stormbite", "Press-Gang Hand", "Sharkhide Brute",
			"Reef Hexer", "The Rum Run", "Ambush in the Screaming Strait", "Powder Blast"]:
		if not joined.contains(required):
			problems.append("log missing pirate pack text %s" % [required])
	# Six quiet evenings (turns 2, 4-8) must show five distinct lines from
	# the pack's rotating adult rest-scene pool (turn prefix and card name
	# stripped before comparing).
	var evenings := []
	for line in log:
		var text: String = line
		if text.contains("quiet evening"):
			text = text.substr(text.find(": ") + 2)      # drop "Turn N: "
			text = text.substr(text.find(": ") + 2)      # drop "quiet evening with <card>: "
			text = text.trim_suffix(" (+%d EXP)" % [EngineCore.EVENT_EXP])
			evenings.append(text)
	if evenings.size() != 6:
		problems.append("expected 6 quiet evenings, got %d" % [evenings.size()])
	var distinct := {}
	for line in evenings:
		distinct[line] = true
	if distinct.size() != 5:
		problems.append("expected 5 distinct base flavor lines, got %d" % [distinct.size()])
	return problems


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": null,
	"chest": null,
	"collection": {
		"archer": {
			"count": 2,
			"exp": 12
		},
		"healer": {
			"count": 3,
			"exp": 10
		},
		"hero": {
			"count": 2,
			"exp": 30
		},
		"mage": {
			"count": 2,
			"exp": 12
		},
		"striker": {
			"count": 2,
			"exp": 10
		},
		"tank": {
			"count": 3,
			"exp": 14
		}
	},
	"ended": "win",
	"fatigue": 1,
	"gains_total": 16,
	"gains_turn": 0,
	"log": [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
		"Turn 1: Preparation quest started: The Rum Run.",
		"Turn 1: treasure chest! 3 cards — take one.",
		"Turn 1: card gained: Bram Ironkeel (copy x2).",
		"Turn 1: The sailing master corrects your charts by lamplight, then your posture: she bends you over the table, her teeth at your throat and her hand between your thighs, until you can no longer hold a pen. (Bram Ironkeel +2 EXP)",
		"Turn 1: war supplies secured: gains +2 (turn total 2).",
		"Turn 1: quest complete: The Rum Run.",
		"Turn 1: Operation quest started: Ambush in the Screaming Strait.",
		"Turn 1: skirmish vs Press-Gang Hand: won handily (squad AT 69). Leaders +1 EXP.",
		"Turn 1: battle vs Reef Hexer",
		"Round 1: Twin-Cut Sable uses Powder Blast for 28 damage (enemy HP 7)",
		"Round 1: Reef Hexer uses Venom Bolt for 13 damage on Bram Ironkeel (HP 72)",
		"Round 2: Twin-Cut Sable uses Knife Flurry for 16 damage (enemy HP 0)",
		"Round 2: victory!",
		"Turn 1: battle over",
		"Turn 1: battle vs Sharkhide Brute",
		"Round 1: Tempest Iris uses Powder Blast for 22 damage (enemy HP 48)",
		"Round 1: Sharkhide Brute uses Cannon Slam for 20 damage on Bram Ironkeel (HP 65)",
		"Round 2: Tempest Iris uses Powder Blast for 24 damage (enemy HP 24)",
		"Round 2: Sharkhide Brute uses Hook Rake for 11 damage on Tidepriestess Nuala (HP 59)",
		"Round 3: Bram Ironkeel uses Brace the Deck: party braces (-30% incoming this round)",
		"Round 3: Sharkhide Brute uses Cannon Slam for 13 damage on Tempest Iris (HP 32)",
		"Round 4: Tempest Iris uses Powder Blast for 23 damage (enemy HP 1)",
		"Round 4: Sharkhide Brute uses Hook Rake for 13 damage on Twin-Cut Sable (HP 37)",
		"Round 5: Bram Ironkeel uses Brace the Deck: party braces (-30% incoming this round)",
		"Round 5: Sharkhide Brute uses Cannon Slam for 13 damage on Gull-Eye Finn (HP 35)",
		"Round 6: Tempest Iris uses Powder Blast for 22 damage (enemy HP 0)",
		"Round 6: victory!",
		"Turn 1: battle over",
		"Turn 1: medal +1 (squad level 0).",
		"Turn 1: quest complete: Ambush in the Screaming Strait.",
		"Turn 1: earned a meal ticket.",
		"Turn 1: meal ticket spent: Captain Maren Stormbite event, +4 EXP.",
		"Turn 1 dispatch from the tide: raiders tore 9 leagues from our waters — 91% of the sea still flies the crimson flag.",
		"Turn 2: Preparation quest started: The Rum Run.",
		"Turn 2: treasure chest! 3 cards — take one.",
		"Turn 2: card gained: Tidepriestess Nuala (copy x2).",
		"Turn 2: rest site: squad fully restored, fatigue cleared.",
		"Turn 2: war supplies secured: gains +2 (turn total 2).",
		"Turn 2: quest complete: The Rum Run.",
		"Turn 2: quiet evening with Captain Maren Stormbite: She tastes of rum and salt; in the swaying hammock she takes you inside her and sets the tide's rhythm with her hips, and the lantern burns out before either of you stops. (+2 EXP)",
		"Turn 2 dispatch from the tide: raiders tore 9 leagues from our waters — 82% of the sea still flies the crimson flag.",
		"Turn 3: Preparation quest started: The Rum Run.",
		"Turn 3: treasure chest! 3 cards — take one.",
		"Turn 3: card gained: Tempest Iris (copy x2).",
		"Turn 3: The gunner's mate shows you how to hold a long barrel steady, then takes you apart with the same unhurried precision: she guides you inside her, and you learn to aim by the sound of her gasps. (Tempest Iris +2 EXP)",
		"Turn 3: war supplies secured: gains +2 (turn total 2).",
		"Turn 3: quest complete: The Rum Run.",
		"Turn 3: Operation quest started: Ambush in the Screaming Strait.",
		"Turn 3: skirmish vs Press-Gang Hand: won handily (squad AT 69). Leaders +1 EXP.",
		"Turn 3: battle vs Reef Hexer",
		"Round 1: Twin-Cut Sable uses Powder Blast for 28 damage (enemy HP 18)",
		"Round 1: Reef Hexer uses Venom Bolt for 16 damage on Bram Ironkeel (HP 69)",
		"Round 2: Twin-Cut Sable uses Knife Flurry for 16 damage (enemy HP 2)",
		"Round 2: Reef Hexer uses Hook Rake for 12 damage on Tidepriestess Nuala (HP 58)",
		"Round 3: Bram Ironkeel uses Brace the Deck: party braces (-30% incoming this round)",
		"Round 3: Reef Hexer uses Venom Bolt for 11 damage on Tempest Iris (HP 34)",
		"Round 4: Twin-Cut Sable uses Powder Blast for 23 damage (enemy HP 0)",
		"Round 4: victory!",
		"Turn 3: battle over",
		"Turn 3: battle vs Sharkhide Brute",
		"Round 1: Tempest Iris uses Powder Blast for 22 damage (enemy HP 69)",
		"Round 1: Sharkhide Brute uses Cannon Slam for 27 damage on Bram Ironkeel (HP 58)",
		"Round 2: Tempest Iris uses Powder Blast for 24 damage (enemy HP 45)",
		"Round 2: Sharkhide Brute uses Hook Rake for 14 damage on Tidepriestess Nuala (HP 56)",
		"Round 3: Bram Ironkeel uses Brace the Deck: party braces (-30% incoming this round)",
		"Round 3: Sharkhide Brute uses Cannon Slam for 18 damage on Tempest Iris (HP 27)",
		"Round 4: Tempest Iris uses Powder Blast for 23 damage (enemy HP 22)",
		"Round 4: Sharkhide Brute uses Hook Rake for 18 damage on Twin-Cut Sable (HP 32)",
		"Round 5: Bram Ironkeel uses Brace the Deck: party braces (-30% incoming this round)",
		"Round 5: Sharkhide Brute uses Cannon Slam for 17 damage on Gull-Eye Finn (HP 31)",
		"Round 6: Tempest Iris uses Powder Blast for 22 damage (enemy HP 0)",
		"Round 6: victory!",
		"Turn 3: battle over",
		"Turn 3: medal +1 (squad level 1).",
		"Turn 3: quest complete: Ambush in the Screaming Strait.",
		"Turn 3: earned a meal ticket.",
		"Turn 3: meal ticket spent: Captain Maren Stormbite event, +4 EXP.",
		"Turn 3 dispatch from the tide: raiders tore 9 leagues from our waters — 73% of the sea still flies the crimson flag.",
		"Turn 4: Preparation quest started: The Rum Run.",
		"Turn 4: treasure chest! 3 cards — take one.",
		"Turn 4: card gained: Twin-Cut Sable (copy x2).",
		"Turn 4: rest site: squad fully restored, fatigue cleared.",
		"Turn 4: war supplies secured: gains +2 (turn total 2).",
		"Turn 4: quest complete: The Rum Run.",
		"Turn 4: quiet evening with Captain Maren Stormbite: The crew sleeps ashore and the ship creaks around two bodies: you wake with her astride you, and the dawn watch finds an empty rum bottle and the two of you still tangled, sweat-slick, in one sheet. (+2 EXP)",
		"Turn 4 dispatch from the tide: raiders tore 9 leagues from our waters — 64% of the sea still flies the crimson flag.",
		"Turn 5: Preparation quest started: The Rum Run.",
		"Turn 5: treasure chest! 3 cards — take one.",
		"Turn 5: card gained: Gull-Eye Finn (copy x2).",
		"Turn 5: A veteran corsair drills you in cutlass-work below decks until the lesson dissolves into sweat and bare skin; her hands guide yours, slow, then faster, until you both shudder. (Gull-Eye Finn +2 EXP)",
		"Turn 5: war supplies secured: gains +2 (turn total 2).",
		"Turn 5: quest complete: The Rum Run.",
		"Turn 5: quiet evening with Captain Maren Stormbite: Lamplight and a barred cabin door: she strips you with a sailor's impatience, lays you back across the charts, and rides you slow until you both forget the sea is waiting. (+2 EXP)",
		"Turn 5 dispatch from the tide: raiders tore 9 leagues from our waters — 55% of the sea still flies the crimson flag.",
		"Turn 6: Preparation quest started: The Rum Run.",
		"Turn 6: treasure chest! 3 cards — take one.",
		"Turn 6: card gained: Captain Maren Stormbite (copy x2).",
		"Turn 6: rest site: squad fully restored, fatigue cleared.",
		"Turn 6: war supplies secured: gains +2 (turn total 2).",
		"Turn 6: quest complete: The Rum Run.",
		"Turn 6: quiet evening with Captain Maren Stormbite: Rain drums the stern windows while her mouth traces every scar you own, then moves lower, until you are shaking and begging her name; when the storm passes you are spent and gasping against the glass. (+2 EXP)",
		"Turn 6 dispatch from the tide: raiders tore 9 leagues from our waters — 46% of the sea still flies the crimson flag.",
		"Turn 7: warning: the realm is below half (46% held).",
		"Turn 7: Preparation quest started: The Rum Run.",
		"Turn 7: treasure chest! 3 cards — take one.",
		"Turn 7: card gained: Bram Ironkeel (copy x3).",
		"Turn 7: The ship's surgeon teaches anatomy in one breathless lesson: she names each place she likes to be touched, then shows you with her mouth and fingers until you can name them back through a moan. (Bram Ironkeel +2 EXP)",
		"Turn 7: war supplies secured: gains +2 (turn total 2).",
		"Turn 7: quest complete: The Rum Run.",
		"Turn 7: quiet evening with Captain Maren Stormbite: She tastes of rum and salt; in the swaying hammock she takes you inside her and sets the tide's rhythm with her hips, and the lantern burns out before either of you stops. (+2 EXP)",
		"Turn 7 dispatch from the tide: raiders tore 9 leagues from our waters — 37% of the sea still flies the crimson flag.",
		"Turn 8: warning: the realm is below half (37% held).",
		"Turn 8: Preparation quest started: The Rum Run.",
		"Turn 8: treasure chest! 3 cards — take one.",
		"Turn 8: card gained: Tidepriestess Nuala (copy x3).",
		"Turn 8: rest site: squad fully restored, fatigue cleared.",
		"Turn 8: war supplies secured: gains +2 (turn total 2).",
		"Turn 8: quest complete: The Rum Run.",
		"Turn 8: quiet evening with Captain Maren Stormbite: A rare quiet anchorage: warm oil, slow hands, her fingers opening you one knuckle at a time while she whispers charts of your body; the tide turns twice before either of you comes apart. (+2 EXP)",
		"Turn 8 dispatch from the tide: raiders tore 9 leagues from our waters — 28% of the sea still flies the crimson flag.",
		"Turn 9: the campaign holds — victory!"
	],
	"medals": 2,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 28,
	"tickets": 0,
	"turn": 9
}
