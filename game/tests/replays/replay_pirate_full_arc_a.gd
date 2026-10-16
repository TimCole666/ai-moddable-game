extends ReplayBase

## Ticket 07: full-arc pirate-pack playthrough, branch A — every one of the
## 8 turns runs preparation quest A (Provisions Ashore); turns 1-2 also run
## operation quest A (Storm Fort Siren) and spend the earned meal ticket,
## turns 3-8 skip the operation quest so the base phase offers the quiet
## evening (the pack's adult rest-scene pool, rotating by turn). Press-Gang
## Hand fights scale with the turn (win round table below). Final state
## pinned bit-for-bit; checks() pins that pirate names ride every log line
## and no skeleton placeholder leaks.


func replay_name() -> String:
	return "pirate_full_arc_a"


## Hero cutlass fight vs the turn-scaled Press-Gang Hand: round 1 is two
## slashes (14 + roundi(14 * 1.1 combo) = 15), later rounds one slash each
## (13/15 by jitter) — the win round per session turn, computed from the
## enemy's roundi(40 * (1 + 0.15 * (t - 1))) HP. From turn 4 the pack's
## Fatigue part drags regen to 1 (fatigue crossed its threshold 2 at the
## turn-3 report), so the hero can only slash every other round — even-round
## passes fill the gap (win rounds 7/7/7/9/9 for turns 4-8).
const GRUNT_WIN_ROUND := {1: 2, 2: 3, 3: 3, 4: 7, 5: 7, 6: 7, 7: 9, 8: 9}
const FATIGUE_DRAG_FROM_TURN := 4


func _grunt_fight(turn: int) -> Array:
	var acts := []
	var win_round := int(GRUNT_WIN_ROUND[turn])
	acts.append({"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0})
	acts.append({"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0})
	acts.append({"type": EngineCore.ACTION_END_TURN})
	for round_no in range(2, win_round + 1):
		var slashed := not (turn >= FATIGUE_DRAG_FROM_TURN and round_no % 2 == 0)
		if slashed:
			acts.append({"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0})
		acts.append({"type": EngineCore.ACTION_END_TURN})
	return acts


func actions() -> Array:
	var acts := []
	for turn in range(1, 9):
		# --- Preparation quest A: fight, event, war supplies ---
		acts.append({"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0})
		acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 0})    # battle: Press-Gang Hand
		acts.append_array(_grunt_fight(turn))
		acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 1 if turn % 2 == 0 else 0})  # ev_gains / ev_exp
		acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 0})    # war supplies +2
		if turn <= 2:
			# --- Operation quest A: fight, chest, rest site, chest ---
			acts.append({"type": EngineCore.ACTION_START_QUEST, "pool": "operation", "idx": 0})
			acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 0})  # battle: Press-Gang Hand
			acts.append_array(_grunt_fight(turn))
			acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 0})  # chest
			acts.append({"type": EngineCore.ACTION_CHEST_PICK, "idx": 0})
			acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 0})  # rest site
			acts.append({"type": EngineCore.ACTION_CHOOSE, "option": 1})  # chest
			acts.append({"type": EngineCore.ACTION_CHEST_PICK, "idx": 2})
			# Meal ticket earned by the operation quest; the base phase spends it.
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
	for required in ["Captain Maren Stormbite", "Press-Gang Hand",
			"Provisions Ashore", "Storm Fort Siren", "Cutlass Slash"]:
		if not joined.contains(required):
			problems.append("log missing pirate pack text %s" % [required])
	# Six quiet evenings (turns 3-8) must show five distinct lines from the
	# pack's rotating adult rest-scene pool (turn prefix and card name
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
	for text in evenings:
		distinct[text] = true
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
			"count": 1,
			"exp": 22
		},
		"healer": {
			"count": 2,
			"exp": 20
		},
		"hero": {
			"count": 2,
			"exp": 40
		},
		"mage": {
			"count": 2,
			"exp": 22
		},
		"striker": {
			"count": 1,
			"exp": 20
		},
		"tank": {
			"count": 2,
			"exp": 24
		}
	},
	"ended": "win",
	"fatigue": 7,
	"gains_total": 20,
	"gains_turn": 0,
	"log": [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
		"Turn 1: Preparation quest started: Provisions Ashore.",
		"Turn 1: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 26)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 11)",
		"Round 1: Press-Gang Hand uses Hook Rake for 8 damage on Bram Ironkeel (HP 77)",
		"Round 2: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 0)",
		"Round 2: victory!",
		"Turn 1: battle over",
		"Turn 1: The sailing master corrects your charts by lamplight, then your posture: she bends you over the table, her teeth at your throat and her hand between your thighs, until you can no longer hold a pen. (Bram Ironkeel +2 EXP)",
		"Turn 1: war supplies secured: gains +2 (turn total 2).",
		"Turn 1: quest complete: Provisions Ashore.",
		"Turn 1: Operation quest started: Storm Fort Siren.",
		"Turn 1: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 26)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 11)",
		"Round 1: Press-Gang Hand uses Hook Rake for 8 damage on Bram Ironkeel (HP 77)",
		"Round 2: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 0)",
		"Round 2: victory!",
		"Turn 1: battle over",
		"Turn 1: treasure chest! 3 cards — take one.",
		"Turn 1: card gained: Captain Maren Stormbite (copy x2).",
		"Turn 1: rest site: squad fully restored, fatigue cleared.",
		"Turn 1: treasure chest! 3 cards — take one.",
		"Turn 1: card gained: Tidepriestess Nuala (copy x2).",
		"Turn 1: quest complete: Storm Fort Siren.",
		"Turn 1: earned a meal ticket.",
		"Turn 1: meal ticket spent: Captain Maren Stormbite event, +4 EXP.",
		"Turn 1 dispatch from the tide: raiders tore 9 leagues from our waters — 91% of the sea still flies the crimson flag.",
		"Turn 2: Preparation quest started: Provisions Ashore.",
		"Turn 2: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 32)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 17)",
		"Round 1: Press-Gang Hand uses Hook Rake for 9 damage on Bram Ironkeel (HP 76)",
		"Round 2: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 2)",
		"Round 2: Press-Gang Hand uses Hook Rake for 8 damage on Tidepriestess Nuala (HP 62)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 0)",
		"Round 3: victory!",
		"Turn 2: battle over",
		"Turn 2: A prize of brandy and silk: by dawn the silk is knotted around your wrists, the brandy is spilled across her stomach, and both gun crews have heard every word.",
		"Turn 2: war supplies secured: gains +2 (turn total 3).",
		"Turn 2: quest complete: Provisions Ashore.",
		"Turn 2: Operation quest started: Storm Fort Siren.",
		"Turn 2: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 32)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 17)",
		"Round 1: Press-Gang Hand uses Hook Rake for 9 damage on Bram Ironkeel (HP 76)",
		"Round 2: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 2)",
		"Round 2: Press-Gang Hand uses Hook Rake for 8 damage on Tidepriestess Nuala (HP 62)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 0)",
		"Round 3: victory!",
		"Turn 2: battle over",
		"Turn 2: treasure chest! 3 cards — take one.",
		"Turn 2: card gained: Bram Ironkeel (copy x2).",
		"Turn 2: rest site: squad fully restored, fatigue cleared.",
		"Turn 2: treasure chest! 3 cards — take one.",
		"Turn 2: card gained: Tempest Iris (copy x2).",
		"Turn 2: quest complete: Storm Fort Siren.",
		"Turn 2: earned a meal ticket.",
		"Turn 2: meal ticket spent: Captain Maren Stormbite event, +4 EXP.",
		"Turn 2 dispatch from the tide: raiders tore 7 leagues from our waters — 84% of the sea still flies the crimson flag.",
		"Turn 3: Preparation quest started: Provisions Ashore.",
		"Turn 3: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 38)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 23)",
		"Round 1: Press-Gang Hand uses Hook Rake for 11 damage on Bram Ironkeel (HP 74)",
		"Round 2: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 8)",
		"Round 2: Press-Gang Hand uses Hook Rake for 9 damage on Tidepriestess Nuala (HP 61)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 0)",
		"Round 3: victory!",
		"Turn 3: battle over",
		"Turn 3: The gunner's mate shows you how to hold a long barrel steady, then takes you apart with the same unhurried precision: she guides you inside her, and you learn to aim by the sound of her gasps. (Tempest Iris +2 EXP)",
		"Turn 3: war supplies secured: gains +2 (turn total 2).",
		"Turn 3: quest complete: Provisions Ashore.",
		"Turn 3: quiet evening with Captain Maren Stormbite: A rare quiet anchorage: warm oil, slow hands, her fingers opening you one knuckle at a time while she whispers charts of your body; the tide turns twice before either of you comes apart. (+2 EXP)",
		"Turn 3 dispatch from the tide: raiders tore 9 leagues from our waters — 75% of the sea still flies the crimson flag.",
		"Turn 4: Preparation quest started: Provisions Ashore.",
		"Turn 4: Sea Weariness drags the squad: AP regen -1.",
		"Turn 4: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 44)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 29)",
		"Round 1: Press-Gang Hand uses Hook Rake for 13 damage on Bram Ironkeel (HP 72)",
		"Round 2: Press-Gang Hand uses Hook Rake for 11 damage on Tidepriestess Nuala (HP 59)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 16)",
		"Round 3: Press-Gang Hand uses Hook Rake for 12 damage on Tempest Iris (HP 33)",
		"Round 4: Press-Gang Hand uses Hook Rake for 13 damage on Twin-Cut Sable (HP 37)",
		"Round 5: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 3)",
		"Round 5: Press-Gang Hand uses Hook Rake for 11 damage on Gull-Eye Finn (HP 37)",
		"Round 6: Press-Gang Hand uses Hook Rake for 13 damage on Captain Maren Stormbite (HP 47)",
		"Round 7: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 0)",
		"Round 7: victory!",
		"Turn 4: battle over",
		"Turn 4: The supply lugger's captain settles her escort bill with supper, brandy, and the whole night: she rides you until you cry out her name, and you pay the rest in full.",
		"Turn 4: war supplies secured: gains +2 (turn total 3).",
		"Turn 4: quest complete: Provisions Ashore.",
		"Turn 4: quiet evening with Captain Maren Stormbite: The crew sleeps ashore and the ship creaks around two bodies: you wake with her astride you, and the dawn watch finds an empty rum bottle and the two of you still tangled, sweat-slick, in one sheet. (+2 EXP)",
		"Turn 4 dispatch from the tide: raiders tore 7 leagues from our waters — 68% of the sea still flies the crimson flag.",
		"Turn 5: Preparation quest started: Provisions Ashore.",
		"Turn 5: Sea Weariness drags the squad: AP regen -1.",
		"Turn 5: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 50)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 35)",
		"Round 1: Press-Gang Hand uses Hook Rake for 14 damage on Bram Ironkeel (HP 71)",
		"Round 2: Press-Gang Hand uses Hook Rake for 12 damage on Tidepriestess Nuala (HP 58)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 22)",
		"Round 3: Press-Gang Hand uses Hook Rake for 13 damage on Tempest Iris (HP 32)",
		"Round 4: Press-Gang Hand uses Hook Rake for 14 damage on Twin-Cut Sable (HP 36)",
		"Round 5: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 9)",
		"Round 5: Press-Gang Hand uses Hook Rake for 12 damage on Gull-Eye Finn (HP 36)",
		"Round 6: Press-Gang Hand uses Hook Rake for 14 damage on Captain Maren Stormbite (HP 46)",
		"Round 7: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 0)",
		"Round 7: victory!",
		"Turn 5: battle over",
		"Turn 5: A veteran corsair drills you in cutlass-work below decks until the lesson dissolves into sweat and bare skin; her hands guide yours, slow, then faster, until you both shudder. (Gull-Eye Finn +2 EXP)",
		"Turn 5: war supplies secured: gains +2 (turn total 2).",
		"Turn 5: quest complete: Provisions Ashore.",
		"Turn 5: quiet evening with Captain Maren Stormbite: Lamplight and a barred cabin door: she strips you with a sailor's impatience, lays you back across the charts, and rides you slow until you both forget the sea is waiting. (+2 EXP)",
		"Turn 5 dispatch from the tide: raiders tore 9 leagues from our waters — 59% of the sea still flies the crimson flag.",
		"Turn 6: Preparation quest started: Provisions Ashore.",
		"Turn 6: Sea Weariness drags the squad: AP regen -1.",
		"Turn 6: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 56)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 41)",
		"Round 1: Press-Gang Hand uses Hook Rake for 15 damage on Bram Ironkeel (HP 70)",
		"Round 2: Press-Gang Hand uses Hook Rake for 13 damage on Tidepriestess Nuala (HP 57)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 28)",
		"Round 3: Press-Gang Hand uses Hook Rake for 14 damage on Tempest Iris (HP 31)",
		"Round 4: Press-Gang Hand uses Hook Rake for 15 damage on Twin-Cut Sable (HP 35)",
		"Round 5: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 15)",
		"Round 5: Press-Gang Hand uses Hook Rake for 13 damage on Gull-Eye Finn (HP 35)",
		"Round 6: Press-Gang Hand uses Hook Rake for 15 damage on Captain Maren Stormbite (HP 45)",
		"Round 7: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 0)",
		"Round 7: victory!",
		"Turn 6: battle over",
		"Turn 6: War chests land on the beach at midnight; the crew hauls barrels through the surf while two officers, half undressed, finish each other against the chart table.",
		"Turn 6: war supplies secured: gains +2 (turn total 3).",
		"Turn 6: quest complete: Provisions Ashore.",
		"Turn 6: quiet evening with Captain Maren Stormbite: Rain drums the stern windows while her mouth traces every scar you own, then moves lower, until you are shaking and begging her name; when the storm passes you are spent and gasping against the glass. (+2 EXP)",
		"Turn 6 dispatch from the tide: raiders tore 7 leagues from our waters — 52% of the sea still flies the crimson flag.",
		"Turn 7: Preparation quest started: Provisions Ashore.",
		"Turn 7: Sea Weariness drags the squad: AP regen -1.",
		"Turn 7: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 62)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 47)",
		"Round 1: Press-Gang Hand uses Hook Rake for 16 damage on Bram Ironkeel (HP 69)",
		"Round 2: Press-Gang Hand uses Hook Rake for 14 damage on Tidepriestess Nuala (HP 56)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 34)",
		"Round 3: Press-Gang Hand uses Hook Rake for 15 damage on Tempest Iris (HP 30)",
		"Round 4: Press-Gang Hand uses Hook Rake for 17 damage on Twin-Cut Sable (HP 33)",
		"Round 5: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 21)",
		"Round 5: Press-Gang Hand uses Hook Rake for 14 damage on Gull-Eye Finn (HP 34)",
		"Round 6: Press-Gang Hand uses Hook Rake for 16 damage on Captain Maren Stormbite (HP 44)",
		"Round 7: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 6)",
		"Round 7: Press-Gang Hand uses Hook Rake for 14 damage on Bram Ironkeel (HP 55)",
		"Round 8: Press-Gang Hand uses Hook Rake for 15 damage on Tidepriestess Nuala (HP 41)",
		"Round 9: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 0)",
		"Round 9: victory!",
		"Turn 7: battle over",
		"Turn 7: The ship's surgeon teaches anatomy in one breathless lesson: she names each place she likes to be touched, then shows you with her mouth and fingers until you can name them back through a moan. (Bram Ironkeel +2 EXP)",
		"Turn 7: war supplies secured: gains +2 (turn total 2).",
		"Turn 7: quest complete: Provisions Ashore.",
		"Turn 7: quiet evening with Captain Maren Stormbite: She tastes of rum and salt; in the swaying hammock she takes you inside her and sets the tide's rhythm with her hips, and the lantern burns out before either of you stops. (+2 EXP)",
		"Turn 7 dispatch from the tide: raiders tore 9 leagues from our waters — 43% of the sea still flies the crimson flag.",
		"Turn 8: warning: the realm is below half (43% held).",
		"Turn 8: Preparation quest started: Provisions Ashore.",
		"Turn 8: Sea Weariness drags the squad: AP regen -1.",
		"Turn 8: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 68)",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 53)",
		"Round 1: Press-Gang Hand uses Hook Rake for 17 damage on Bram Ironkeel (HP 68)",
		"Round 2: Press-Gang Hand uses Hook Rake for 14 damage on Tidepriestess Nuala (HP 56)",
		"Round 3: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 40)",
		"Round 3: Press-Gang Hand uses Hook Rake for 16 damage on Tempest Iris (HP 29)",
		"Round 4: Press-Gang Hand uses Hook Rake for 18 damage on Twin-Cut Sable (HP 32)",
		"Round 5: Captain Maren Stormbite uses Cutlass Slash for 13 damage (enemy HP 27)",
		"Round 5: Press-Gang Hand uses Hook Rake for 15 damage on Gull-Eye Finn (HP 33)",
		"Round 6: Press-Gang Hand uses Hook Rake for 17 damage on Captain Maren Stormbite (HP 43)",
		"Round 7: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 12)",
		"Round 7: Press-Gang Hand uses Hook Rake for 14 damage on Bram Ironkeel (HP 54)",
		"Round 8: Press-Gang Hand uses Hook Rake for 16 damage on Tidepriestess Nuala (HP 40)",
		"Round 9: Captain Maren Stormbite uses Cutlass Slash for 15 damage (enemy HP 0)",
		"Round 9: victory!",
		"Turn 8: battle over",
		"Turn 8: Bribed harbor pilots trade their charts for pearls and spend the night being thanked in person, thoroughly: one at a time, then all at once, until the pearls are scattered across the sheets.",
		"Turn 8: war supplies secured: gains +2 (turn total 3).",
		"Turn 8: quest complete: Provisions Ashore.",
		"Turn 8: quiet evening with Captain Maren Stormbite: A rare quiet anchorage: warm oil, slow hands, her fingers opening you one knuckle at a time while she whispers charts of your body; the tide turns twice before either of you comes apart. (+2 EXP)",
		"Turn 8 dispatch from the tide: raiders tore 7 leagues from our waters — 36% of the sea still flies the crimson flag.",
		"Turn 9: the campaign holds — victory!"
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 36,
	"tickets": 0,
	"turn": 9
}
