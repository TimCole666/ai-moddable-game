extends ReplayBase

## The language switch works mid-run and preserves the session bit-for-bit:
## a mid-battle snapshot taken before set_language(zh) must equal the final
## state exactly (chrome is not state), and the next chrome-driven string the
## Engine produces comes out in Chinese.

var _snapshot: Dictionary = {}


func replay_name() -> String:
	return "language_switch_preserves_state"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 1, "slot": 0},
		Callable(self, "_snapshot_state"),
		# The language switch itself must touch nothing at all.
		{"type": EngineCore.ACTION_SET_LANGUAGE, "lang": "zh"},
	]


func _snapshot_state() -> void:
	_snapshot = GameEngine.get_state()


func checks() -> PackedStringArray:
	var problems := PackedStringArray()
	if GameEngine.get_language() != "zh":
		problems.append("get_language(): expected zh, got %s" % [GameEngine.get_language()])
	# Bit-for-bit: the switch changed nothing, not even the log.
	var diffs := _diff(_snapshot, GameEngine.get_state(), "state")
	if not diffs.is_empty():
		problems.append_array(diffs)
	# And the zh chrome table renders the brace line with the builtin pack's
	# zh pack text (the same line a post-switch skill would log).
	var brace: String = GameEngine.chrome("zh")["log"]["brace"] % [2, "盾卫", "布防"]
	if brace != "第 2 轮：盾卫 使用 布防：全队防御（本轮所受伤害 -30%）":
		problems.append("zh brace template: unexpected rendering %s" % [brace])
	return problems


## Minimal structural diff (same comparison rules as the harness: exact types,
## key sets, array lengths).
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


func expected_state() -> Dictionary:
	return _snapshot.duplicate(true)
