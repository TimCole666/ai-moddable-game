extends ReplayBase

## Export → mutate → import round-trip: the current pack is exported as pure
## JSON, mutated on disk (retitled, one card renamed, id changed), and
## imported back — it must validate and switch into a playable pack. A second,
## corrupted copy (version erased) must be rejected with a specific reason and
## zero state change (asserted in checks(); the untouched state is pinned by
## the final state diff, since the failed import is the last call).

const EXPORT_DIR := "user://t04/roundtrip"
const EXPORT_PATH := "user://t04/roundtrip/exported.json"
const BROKEN_PATH := "user://t04/roundtrip/broken.json"

var _problems: PackedStringArray = PackedStringArray()
var _failed_import_errors: PackedStringArray = PackedStringArray()


func replay_name() -> String:
	return "pack_roundtrip_export_mutate_import"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_EXPORT_PACK, "path": EXPORT_PATH},
		Callable(self, "mutate_exported_files"),
		{"type": EngineCore.ACTION_IMPORT_PACK, "path": EXPORT_PATH},
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "grunt"},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		Callable(self, "assert_broken_import_rejected"),
	]


## Test-driver code (not an Engine action): rewrites the exported pack on
## disk — a valid mutation and a corrupted copy — and captures the errors of
## the deliberately rejected import.
func mutate_exported_files() -> void:
	DirAccess.make_dir_recursive_absolute(EXPORT_DIR)
	var pack := _read_json(EXPORT_PATH)
	pack["id"] = "mutated"
	pack["text"]["en"]["name"] = "Mutated Seas"
	pack["text"]["en"]["cards"]["hero"]["name"] = "Mutineer"
	_write_json(EXPORT_PATH, pack)
	var broken := _read_json(EXPORT_PATH)
	broken["id"] = "broken"
	broken.erase("version")
	_write_json(BROKEN_PATH, broken)


## Test-driver code: import the corrupted copy through the Engine and record
## the outcome for checks(). The state must not change.
func assert_broken_import_rejected() -> void:
	var before := var_to_str(GameEngine.get_state())
	var result := GameEngine.step({"type": EngineCore.ACTION_IMPORT_PACK, "path": BROKEN_PATH})
	if result["ok"]:
		_problems.append("broken.json import unexpectedly succeeded")
		return
	_failed_import_errors = result["errors"]
	if var_to_str(GameEngine.get_state()) != before:
		_problems.append("state changed after the failed broken.json import")


func checks() -> PackedStringArray:
	var problems := _problems
	if Array(_failed_import_errors) != ["pack.version: required integer"]:
		problems.append("broken.json import errors: expected [pack.version: required integer], got %s" % [_failed_import_errors])
	return problems


func _read_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		_problems.append("cannot read %s" % [path])
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_problems.append("%s is not a JSON object" % [path])
		return {}
	return parsed


func _write_json(path: String, pack: Dictionary) -> void:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		_problems.append("cannot write %s" % [path])
		return
	file.store_string(JSON.stringify(pack, "\t") + "\n")


func expected_state() -> Dictionary:
	return {
		"base_options": null,
		"battle": {
			"ap": 2,
			"ap_max": 6,
			"boss": false,
			"combo": 1,
			"enemy": "grunt",
			"enemy_at": 8,
			"enemy_hp": 26,
			"enemy_max_hp": 40,
			"guard": false,
			"hexed": false,
			"next_action": "e_slash",
			"over": "",
			"party_hp": [60, 85, 70, 45, 50, 48],
			"regen": 2,
			"round": 1,
		},
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
			"Turn 1: theme pack exported to user://t04/roundtrip/exported.json",
			"Turn 1: theme pack switched to Mutated Seas.",
			"Turn 1: battle vs Grunt",
			"Round 1: Mutineer uses Strike for 14 damage (enemy HP 26)",
		],
		"medals": 0,
		"pack_id": "mutated",
		"phase": 0,
		"quest": null,
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
