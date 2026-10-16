extends Node

## Headless walkthrough-replay runner: the test harness every ticket rides on.
##
## Run:  godot --headless --path game res://tests/run_replays.tscn
##
## Discovers every script in res://tests/replays/ (ReplayBase subclasses),
## runs its scripted actions through the GameEngine autoload, and asserts the
## final state bit-for-bit. Exits 0 when all replays pass, 1 otherwise.

const REPLAYS_DIR := "res://tests/replays"


func _ready() -> void:
	var replays := _load_replays()
	if replays.is_empty():
		printerr("FAIL: no replays found in %s" % [REPLAYS_DIR])
		get_tree().quit(1)
		return
	var failures := 0
	for replay in replays:
		if not _run_replay(replay):
			failures += 1
	if failures == 0:
		print("ALL %d REPLAY(S) PASSED" % [replays.size()])
	else:
		printerr("%d OF %d REPLAY(S) FAILED" % [failures, replays.size()])
	get_tree().quit(1 if failures > 0 else 0)


func _load_replays() -> Array:
	var replays: Array = []
	var file_names: PackedStringArray = DirAccess.get_files_at(REPLAYS_DIR)
	file_names.sort()
	for file_name in file_names:
		if not file_name.ends_with(".gd"):
			continue
		var script: Variant = load(REPLAYS_DIR + "/" + file_name)
		if not (script is GDScript):
			continue
		var replay: Variant = (script as GDScript).new()
		if replay is ReplayBase:
			replays.append(replay)
	return replays


func _run_replay(replay: ReplayBase) -> bool:
	var replay_name := replay.replay_name()
	# Baseline session under the builtin pack: replays run in arbitrary file
	# order against the shared Engine, so every replay starts from this known
	# state. A rejected pack leaves exactly this baseline (zero state change);
	# a valid pack replaces it with its own session.
	var baseline := GameEngine.new_game(GameEngine.get_builtin_pack())
	if not baseline["ok"]:
		printerr("REPLAY %s: FAILED" % [replay_name])
		printerr("  builtin baseline session failed to start: %s" % [baseline["errors"]])
		return false
	var pack := replay.pack()
	if pack.is_empty():
		pack = GameEngine.get_builtin_pack()
	var boot := GameEngine.new_game(pack)
	var expected_errors := replay.expected_new_game_errors()
	if _errors_to_array(boot["errors"]) != _errors_to_array(expected_errors):
		printerr("REPLAY %s: FAILED" % [replay_name])
		printerr("  new_game errors expected: %s" % [expected_errors])
		printerr("  new_game errors actual:   %s" % [boot["errors"]])
		return false
	if boot["ok"]:
		for action in replay.actions():
			var result := GameEngine.step(action)
			if not result["ok"]:
				printerr("REPLAY %s: FAILED" % [replay_name])
				printerr("  step %s failed: %s" % [action, result["errors"]])
				return false
	var actual := GameEngine.get_state()
	var diffs := _diff(replay.expected_state(), actual, "state")
	if diffs.is_empty():
		print("REPLAY %s: passed" % [replay_name])
		return true
	printerr("REPLAY %s: FAILED" % [replay_name])
	for diff in diffs:
		printerr("  %s" % [diff])
	return false


## Exact structural comparison, bit-for-bit: int and float are different types,
## key sets and array lengths must match exactly.
func _diff(expected: Variant, actual: Variant, path: String) -> PackedStringArray:
	var diffs := PackedStringArray()
	if typeof(expected) != typeof(actual):
		diffs.append("%s: expected %s, got %s" % [path, type_string(typeof(expected)), type_string(typeof(actual))])
		return diffs
	if expected is Dictionary:
		for key in expected:
			if not (actual as Dictionary).has(key):
				diffs.append("%s.%s: expected key missing" % [path, key])
		for key in actual:
			if not (expected as Dictionary).has(key):
				diffs.append("%s.%s: unexpected key" % [path, key])
		for key in expected:
			if (actual as Dictionary).has(key):
				diffs.append_array(_diff(expected[key], actual[key], "%s.%s" % [path, key]))
	elif expected is Array:
		if (expected as Array).size() != (actual as Array).size():
			diffs.append("%s: expected length %d, got %d" % [path, (expected as Array).size(), (actual as Array).size()])
		for i in mini((expected as Array).size(), (actual as Array).size()):
			diffs.append_array(_diff(expected[i], actual[i], "%s[%d]" % [path, i]))
	elif expected != actual:
		diffs.append("%s: expected %s, got %s" % [path, expected, actual])
	return diffs


func _errors_to_array(errors: Variant) -> Array:
	return Array(errors as PackedStringArray)
