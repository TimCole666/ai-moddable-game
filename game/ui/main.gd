extends Control

## Placeholder main scene: a thin view over the Engine. It reads
## GameEngine.get_state() and renders it; every gameplay action it offers goes
## through GameEngine.step(). No rules live here.

@onready var _state_label: Label = %StateLabel


func _ready() -> void:
	_start_session()


func _process(_delta: float) -> void:
	_render()


func _on_end_turn_pressed() -> void:
	GameEngine.step({"type": GameEngine.ACTION_END_TURN})


func _on_patrol_pressed() -> void:
	GameEngine.step({"type": GameEngine.ACTION_PATROL})


func _on_rest_pressed() -> void:
	GameEngine.step({"type": GameEngine.ACTION_REST})


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
	lines.append("Turn: %d   HP: %d/%d   AP: %d/%d   EXP: %d" % [
		state["turn"], state["hp"], EngineCore.START_HP,
		state["ap"], EngineCore.AP_MAX, state["exp"],
	])
	lines.append("")
	lines.append("--- log ---")
	for line in state["log"]:
		lines.append(line)
	_state_label.text = "\n".join(lines)
