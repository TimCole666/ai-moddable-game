extends ReplayBase

## Ticket 10 onboarding: every fresh session opens with four turn-1 lines that
## walk a player to their first battle (current phase, branch choices, the
## spend-vs-brace hook, where the controls are). Pins the lines as the FIRST
## log entries under the builtin pack in en literally, and the zh/ja chrome
## templates as renderings with the same args (turn 1, phase name). Note the
## session always boots in en (new_game resets the chrome locale — ticket 05
## pinned behavior); the trilingual templates are what a language switch
## hands to later chrome lines.

func replay_name() -> String:
	return "onboarding_lines"


func actions() -> Array:
	# No steps: the harness booted the baseline session under the builtin
	# pack; its log opens with the four onboarding lines.
	return []


func checks() -> PackedStringArray:
	var problems := PackedStringArray()
	var log: Array = GameEngine.get_state()["log"]
	var en_lines := [log[0], log[1], log[2], log[3]]
	# en pinned literally — the wording itself is contract for the playtest.
	var en_expected := [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
	]
	if en_lines != en_expected:
		problems.append("en onboarding lines mismatch: %s" % [str(en_lines)])
	# zh/ja pinned through the chrome templates with the same arg order, and
	# distinct from the en wording (localized, not copies).
	var en_chrome := GameEngine.chrome("en")
	for lang in ["zh", "ja"]:
		var chrome := GameEngine.chrome(lang)
		var templates: Dictionary = chrome["log"]
		var phase: String = (chrome["phases"] as Array)[0]
		var rendered := [
			(templates["onboard_phase"] as String) % [1, phase],
			templates["onboard_branch"] % [1],
			templates["onboard_battle"] % [1],
			templates["onboard_buttons"] % [1],
		]
		var en_rendered := [
			(en_chrome["log"]["onboard_phase"] as String) % [1, (en_chrome["phases"] as Array)[0]],
			en_chrome["log"]["onboard_branch"] % [1],
			en_chrome["log"]["onboard_battle"] % [1],
			en_chrome["log"]["onboard_buttons"] % [1],
		]
		if rendered == en_rendered:
			problems.append("chrome.%s onboarding templates identical to en (not localized)" % [lang])
	return problems


func expected_state() -> Dictionary:
	# Final session: a fresh en boot (new_game resets the language), so the
	# state is exactly the opened baseline session with its onboarding log.
	return {
		"base_options": null,
		"battle": null,
		"chest": null,
		"collection": {
			"archer": {"count": 1, "exp": 0},
			"healer": {"count": 1, "exp": 0},
			"hero": {"count": 1, "exp": 0},
			"mage": {"count": 1, "exp": 0},
			"striker": {"count": 1, "exp": 0},
			"tank": {"count": 1, "exp": 0},
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
		],
		"medals": 0,
		"pack_id": "builtin",
		"phase": 0,
		"quest": null,
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
