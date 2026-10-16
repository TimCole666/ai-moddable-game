extends Node

## Headless Agent Kit runner (ticket 08): validate a Theme Pack file through
## the Engine and prove it plays by driving a short battle with it.
##
## Run:  godot --headless --path game res://tests/run_pack.tscn -- <pack.json>
##
## Exit 0: pack is valid and playable (prints VALID + a play transcript).
## Exit 1: file/parse/validation failure (prints the exact pack.* reasons)
##         or a gameplay step failed.


func _ready() -> void:
	var args := OS.get_cmdline_user_args()
	if args.is_empty():
		printerr("usage: godot --headless --path game res://tests/run_pack.tscn -- <pack.json>")
		get_tree().quit(1)
		return
	var path := args[0]
	var loaded := GameEngine.load_pack_file(path)
	if not loaded["ok"]:
		printerr("VALIDATION FAILED: %s" % [path])
		for reason in loaded["errors"]:
			printerr("  %s" % [reason])
		get_tree().quit(1)
		return
	print("VALID: %s" % [path])
	var pack: Dictionary = loaded["pack"]
	var boot := GameEngine.new_game(pack)
	if not boot["ok"]:
		printerr("PLAY FAILED: new_game errors: %s" % [boot["errors"]])
		get_tree().quit(1)
		return
	var actions: Array = [
		{"type": "start_battle", "enemy": "brute"},
		{"type": "skill", "leader": 0, "slot": 0},
		{"type": "end_turn"},
		{"type": "end_turn"},
	]
	for action in actions:
		var result := GameEngine.step(action)
		print("STEP %s -> ok=%s %s" % [JSON.stringify(action), result["ok"], result["errors"]])
		if not result["ok"]:
			printerr("PLAY FAILED: step error above")
			get_tree().quit(1)
			return
	var state := GameEngine.get_state()
	print("LOG:")
	for line in state["log"]:
		print("  %s" % [line])
	print("STATE: pack_id=%s turn=%s battle_over=%s" % [state["pack_id"], state["turn"], state["battle"]["over"] if state["battle"] != null else "-"])
	print("PACK PLAYED: %s" % [path])
	get_tree().quit(0)
