extends Control

## Placeholder main scene: a thin view over the Engine. It reads
## GameEngine.get_state() and renders it; every gameplay action it offers goes
## through GameEngine.step(). No rules live here. Pack names come from the
## pack text; chrome (labels, phases, buttons, log language) comes from the
## Engine's chrome() accessor and switches mid-run via the set_language action.

## The shipped placeholder packs, switchable in-game through the Engine's
## import action (same rules, new world).
const PACK_PATHS := [
	"res://engine/builtin_pack.json",
	"res://engine/packs/ironroad.json",
]

## Language cycle for the chrome switcher (same order as EngineCore's).
const LANG_CYCLE := ["en", "zh", "ja"]

const AI_PANEL_SCENE := "res://ui/ai_panel.tscn"

@onready var _state_label: Label = %StateLabel
@onready var _buttons: HBoxContainer = %Buttons
@onready var _language_button: Button = %LanguageButton


func _ready() -> void:
	_start_session()
	_apply_chrome_buttons()


func _process(_delta: float) -> void:
	_render()


func _on_start_battle_pressed() -> void:
	GameEngine.step({"type": EngineCore.ACTION_START_BATTLE, "enemy": "grunt"})


func _on_end_turn_pressed() -> void:
	GameEngine.step({"type": EngineCore.ACTION_END_TURN})


func _on_end_phase_pressed() -> void:
	GameEngine.step({"type": EngineCore.ACTION_END_PHASE})


func _on_switch_pack_pressed() -> void:
	# Thin view: pick the shipped pack whose id differs from the current one
	# and let the Engine validate and switch. Rejections change nothing.
	var current: String = GameEngine.get_state().get("pack_id", "")
	for path in PACK_PATHS:
		var loaded := GameEngine.load_pack_file(path)
		if loaded["ok"] and loaded["pack"]["id"] != current:
			GameEngine.step({"type": EngineCore.ACTION_IMPORT_PACK, "path": path})
			return
	# Ticket 06 (additive): AI-generated packs (persisted under user://packs)
	# join the cycle after the shipped packs, through the same Engine seam.
	for pack in AIGateway.get_generated_packs():
		if pack["id"] != current:
			GameEngine.step({"type": EngineCore.ACTION_SELECT_PACK, "pack": pack})
			return


func _on_ai_panel_pressed() -> void:
	# ADR-0005: the web export is all-ages only — the Engine says whether the
	# AI Entry plays on this platform; the view just follows.
	if not GameEngine.adult_allowed():
		return
	# Ticket 06 (additive): open the AI Entry panel (provider settings +
	# generation). All panel behavior lives in ai_panel.gd.
	if get_node_or_null("AIPanel") == null:
		var panel: Control = (load(AI_PANEL_SCENE) as PackedScene).instantiate()
		panel.name = "AIPanel"
		add_child(panel)


func _on_language_pressed() -> void:
	# Mid-run chrome switch through the Engine seam; state is preserved
	# bit-for-bit by the Engine (chrome-only change).
	var next: String = LANG_CYCLE[(LANG_CYCLE.find(GameEngine.get_language()) + 1) % LANG_CYCLE.size()]
	GameEngine.step({"type": EngineCore.ACTION_SET_LANGUAGE, "lang": next})
	_apply_chrome_buttons()


func _start_session() -> void:
	var pack := GameEngine.get_builtin_pack()
	var result := GameEngine.new_game(pack)
	if not result["ok"]:
		push_error("builtin pack rejected: %s" % [result["errors"]])


## Button labels are engine chrome, so they follow the session language.
func _apply_chrome_buttons() -> void:
	var chrome := GameEngine.chrome()
	if chrome.is_empty():
		return
	var buttons: Dictionary = chrome["buttons"]
	for i in _buttons.get_child_count():
		var child := _buttons.get_child(i) as Button
		if child == null:
			continue
		match child.name:
			"StartBattleButton":
				child.text = buttons["startBattle"]
			"EndTurnButton":
				child.text = buttons["endTurn"]
			"EndPhaseButton":
				child.text = buttons["endPhase"]
			"SwitchPackButton":
				child.text = buttons["switchPack"]
			"LanguageButton":
				child.text = buttons["language"] % [GameEngine.get_language()]


func _render() -> void:
	var state := GameEngine.get_state()
	var chrome := GameEngine.chrome()
	if state.is_empty():
		_state_label.text = chrome.get("ui", {}).get("noSession", "Engine: no session")
		return
	var ui: Dictionary = chrome["ui"]
	var phases: Array = chrome["phases"]
	var pools: Dictionary = chrome["questPools"]
	var results: Dictionary = chrome["results"]
	var lines: Array[String] = []
	lines.append(ui["pack"] % [state["pack_id"]])
	lines.append(ui["turnPhase"] % [state["turn"], _result_suffix(state, results), phases[state["phase"]]])
	lines.append(ui["realm"] % [state["realm"], state["gains_turn"], state["gains_total"]])
	lines.append(ui["medals"] % [state["medals"], state["medals"] / 2, state["tickets"], state["fatigue"]])
	var quest: Variant = state["quest"]
	if quest is Dictionary:
		var q: Dictionary = quest
		lines.append(ui["quest"] % [pools[q["pool"]], q["idx"], q["step"]])
	var chest: Variant = state["chest"]
	if chest is Array:
		lines.append(ui["chest"] % [str(chest)])
	var options: Variant = state["base_options"]
	if options is Array:
		lines.append(ui["baseOptions"] % [str(options)])
	var battle: Variant = state["battle"]
	if battle is Dictionary:
		var b: Dictionary = battle
		if b["over"] != "":
			lines.append(ui["battleOver"] % [b["enemy"], results[b["over"]]])
		else:
			lines.append(ui["battleRound"] % [
				b["enemy"], b["round"], b["next_action"],
			])
			lines.append(ui["enemyStats"] % [
				b["enemy_hp"], b["enemy_max_hp"], b["ap"], b["ap_max"], b["regen"], b["combo"],
			])
			lines.append(ui["guardHexed"] % [b["guard"], b["hexed"]])
			lines.append(ui["partyHp"] % [str(b["party_hp"])])
	lines.append("")
	lines.append(ui["logHeader"])
	for line in state["log"]:
		lines.append(line)
	_state_label.text = "\n".join(lines)


func _result_suffix(state: Dictionary, results: Dictionary) -> String:
	var ended: String = state["ended"]
	if ended == "":
		return ""
	return " (%s)" % [results[ended]]
