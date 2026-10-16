extends Control

## Placeholder main scene: a thin view over the Engine. It reads
## GameEngine.get_state() and renders it; every gameplay action it offers goes
## through GameEngine.step(). No rules live here. Pack names come from the
## pack text; chrome localization arrives with the trilingual-chrome ticket.

const PHASE_NAMES := ["Preparation", "Operation", "Base", "War Report"]

## The shipped placeholder packs, switchable in-game through the Engine's
## import action (same rules, new world).
const PACK_PATHS := [
	"res://engine/builtin_pack.json",
	"res://engine/packs/ironroad.json",
]

@onready var _state_label: Label = %StateLabel


func _ready() -> void:
	_start_session()


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


func _start_session() -> void:
	var pack := GameEngine.get_builtin_pack()
	var result := GameEngine.new_game(pack)
	if not result["ok"]:
		push_error("builtin pack rejected: %s" % [result["errors"]])


func _render() -> void:
	var state := GameEngine.get_state()
	if state.is_empty():
		_state_label.text = "Engine: no session"
		return
	var lines: Array[String] = []
	lines.append("Theme Pack: %s" % [state["pack_id"]])
	lines.append("Turn: %d%s   Phase: %s" % [
		state["turn"], _result_suffix(state), PHASE_NAMES[state["phase"]],
	])
	lines.append("Realm: %d%%   Gains: %d this turn (%d total)" % [
		state["realm"], state["gains_turn"], state["gains_total"],
	])
	lines.append("Medals: %d (squad level %d)   Meal tickets: %d   Fatigue: %d" % [
		state["medals"], state["medals"] / 2, state["tickets"], state["fatigue"],
	])
	var quest: Variant = state["quest"]
	if quest is Dictionary:
		var q: Dictionary = quest
		lines.append("Quest: %s #%d — step %d" % [q["pool"], q["idx"], q["step"]])
	var chest: Variant = state["chest"]
	if chest is Array:
		lines.append("Chest open: %s" % [str(chest)])
	var options: Variant = state["base_options"]
	if options is Array:
		lines.append("Base options: %s" % [str(options)])
	var battle: Variant = state["battle"]
	if battle is Dictionary:
		var b: Dictionary = battle
		if b["over"] != "":
			lines.append("Battle vs %s — over: %s" % [b["enemy"], b["over"]])
		else:
			lines.append("Battle vs %s (round %d) — announced next: %s" % [
				b["enemy"], b["round"], b["next_action"],
			])
			lines.append("Enemy HP: %d/%d   AP: %d/%d (+%d/round)   Combo: %d" % [
				b["enemy_hp"], b["enemy_max_hp"], b["ap"], b["ap_max"], b["regen"], b["combo"],
			])
			lines.append("Guard: %s   Hexed: %s" % [b["guard"], b["hexed"]])
			lines.append("Party HP: %s" % [str(b["party_hp"])])
	lines.append("")
	lines.append("--- log ---")
	for line in state["log"]:
		lines.append(line)
	_state_label.text = "\n".join(lines)


func _result_suffix(state: Dictionary) -> String:
	var ended: String = state["ended"]
	if ended == "":
		return ""
	return " (%s)" % [ended]
