extends Control

## Placeholder main scene: a thin view over the Engine. It reads
## GameEngine.get_state() and renders it; every gameplay action it offers goes
## through GameEngine.step(). No rules live here. Pack names for battle text
## arrive with the pack contract ticket; until then the view shows skeleton
## ids.

@onready var _state_label: Label = %StateLabel


func _ready() -> void:
	_start_session()


func _process(_delta: float) -> void:
	_render()


func _on_start_battle_pressed() -> void:
	GameEngine.step({"type": EngineCore.ACTION_START_BATTLE, "enemy": "grunt"})


func _on_end_turn_pressed() -> void:
	GameEngine.step({"type": EngineCore.ACTION_END_TURN})


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
	lines.append("Turn: %d" % [state["turn"]])
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
