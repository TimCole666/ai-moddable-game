extends ReplayBase

## Ticket 06: provider settings. The recommended presets exist (cloud +
## local), settings validation rejects bad configurations with actionable
## dotted reasons, and a valid configuration persists to user:// storage and
## round-trips through get_settings(). No transport is involved; Engine state
## must be untouched (pinned by the final state diff: plain baseline).

const DUMMY_KEY := "sk-test-dummy-not-a-secret"

var _problems: PackedStringArray = PackedStringArray()


func replay_name() -> String:
	return "ai_provider_settings"


func actions() -> Array:
	return [Callable(self, "run_settings_checks")]


func run_settings_checks() -> void:
	AIGateway.clear_cache()
	_check_presets()
	_check_validation()
	_check_persistence()


func _check_presets() -> void:
	var presets := AIGateway.get_presets()
	if presets.size() < 2:
		_problems.append("expected at least 2 presets (cloud + local), got %d" % [presets.size()])
		return
	var cloud := 0
	var local := 0
	var ids := {}
	for preset in presets:
		if preset["kind"] == "cloud":
			cloud += 1
			if not (preset["base_url"] as String).begins_with("https://"):
				_problems.append("cloud preset %s: base_url must be https" % [preset["id"]])
		elif preset["kind"] == "local":
			local += 1
			if not (preset["base_url"] as String).begins_with("http://"):
				_problems.append("local preset %s: base_url must be http" % [preset["id"]])
		else:
			_problems.append("preset %s: unknown kind %s" % [preset["id"], preset["kind"]])
		if (preset["model"] as String).is_empty():
			_problems.append("preset %s: empty model" % [preset["id"]])
		if ids.has(preset["id"]):
			_problems.append("duplicate preset id %s" % [preset["id"]])
		ids[preset["id"]] = true
	if cloud == 0 or local == 0:
		_problems.append("expected both cloud and local presets, got %d cloud / %d local" % [cloud, local])


func _check_validation() -> void:
	var expect := func(errors: Variant, expected: Array, label: String) -> void:
		if Array(errors) != expected:
			_problems.append("%s: expected %s, got %s" % [label, expected, errors])
	expect.call(AIGateway.validate_settings({}),
		["settings.kind: must be \"cloud\" or \"local\"", "settings.base_url: required http(s) URL", "settings.model: required non-empty string"],
		"empty settings errors")
	expect.call(AIGateway.validate_settings({"kind": "cloud", "base_url": "https://api.example.com/v1", "model": "m", "api_key": ""}),
		["settings.api_key: required for a cloud provider"],
		"cloud key missing")
	expect.call(AIGateway.validate_settings({"kind": "cloud", "base_url": "ftp://nope", "model": "m", "api_key": "k"}),
		["settings.base_url: required http(s) URL"],
		"bad scheme")
	expect.call(AIGateway.validate_settings({"kind": "hosted", "base_url": "http://x", "model": "m"}),
		["settings.kind: must be \"cloud\" or \"local\""],
		"bad kind")
	if not AIGateway.validate_settings({"kind": "local", "base_url": "http://127.0.0.1:11434/v1", "model": "m"}).is_empty():
		_problems.append("local settings without a key must validate")


func _check_persistence() -> void:
	var settings := {"kind": "cloud", "preset": "openai", "base_url": "https://api.example.com/v1", "model": "fake-model", "api_key": DUMMY_KEY}
	var saved := AIGateway.set_settings(settings)
	if not saved["ok"]:
		_problems.append("valid settings rejected: %s" % [saved["errors"]])
		return
	if AIGateway.get_settings() != settings:
		_problems.append("get_settings() did not round-trip the saved settings")
	var file := FileAccess.open(AIGateway.SETTINGS_PATH, FileAccess.READ)
	if file == null:
		_problems.append("settings not persisted at %s" % [AIGateway.SETTINGS_PATH])
		return
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		_problems.append("persisted settings are not a JSON object")
		return
	if parsed != settings:
		_problems.append("persisted settings differ from the saved settings")


func checks() -> PackedStringArray:
	return _problems


func expected_state() -> Dictionary:
	return _baseline_state()


static func _baseline_state() -> Dictionary:
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
		"log": [],
		"medals": 0,
		"pack_id": "builtin",
		"phase": 0,
		"quest": null,
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
