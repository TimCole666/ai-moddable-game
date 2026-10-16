extends ReplayBase

## Ticket 06: a bad generation fails with actionable errors and leaves
## everything untouched. Four failure modes, each pinned exactly:
## 1. unparseable model output (no JSON object at all),
## 2. provider-side HTTP error (status surfaced with a truncated body),
## 3. transport-level failure (no HTTP round trip at all),
## 4. parseable JSON that is not a valid v1 pack (raw Engine contract reasons).
## Failed generations are NOT cached (retrying after fixing settings must be
## possible without hand-clearing), so the cache stays empty; Engine state is
## untouched and no pack is registered.

const LOCAL_SETTINGS := {"kind": "local", "preset": "ollama", "base_url": "http://127.0.0.1:11434/v1", "model": "fake-model", "api_key": ""}
const TOPIC := "salted hollow"

var _problems: PackedStringArray = PackedStringArray()
var _errors: Array = []          # the PackedStringArray of each generate call
var _results: Array = []         # the raw result of each generate call
var _state_before := ""


func replay_name() -> String:
	return "ai_invalid_generation_actionable"


func actions() -> Array:
	return [
		Callable(self, "setup_gateway"),
		Callable(self, "generate_no_json"),
		Callable(self, "generate_http_error"),
		Callable(self, "generate_transport_error"),
		Callable(self, "generate_invalid_pack"),
	]


func setup_gateway() -> void:
	AIGateway.clear_cache()
	var fake := AIFakeTransport.new()
	fake.queue_response(AIFakeTransport.chat_response("I'm sorry, I can't help with that."))
	fake.queue_response({"status": 401, "body": "{\"error\":\"invalid api key\"}"})
	fake.queue_response({"error": "connection refused"})
	var broken := GameEngine.get_builtin_pack()
	(broken["text"] as Dictionary).erase("zh")  # not a valid v1 pack: two locales missing
	(broken["text"] as Dictionary).erase("ja")
	fake.queue_response(AIFakeTransport.chat_response(JSON.stringify(broken)))
	AIGateway.set_transport(fake)
	var saved := AIGateway.set_settings(LOCAL_SETTINGS)
	if not saved["ok"]:
		_problems.append("local settings rejected: %s" % [saved["errors"]])
	_state_before = var_to_str(GameEngine.get_state())


func _generate() -> void:
	var result: Dictionary = await AIGateway.generate_pack(TOPIC)
	_results.append(result)
	_errors.append(Array(result["errors"]))


func generate_no_json() -> void:
	_generate()


func generate_http_error() -> void:
	_generate()


func generate_transport_error() -> void:
	_generate()


func generate_invalid_pack() -> void:
	_generate()


func checks() -> PackedStringArray:
	if _errors.size() != 4:
		_problems.append("expected 4 generate attempts, got %d" % [_errors.size()])
		return _problems
	for result in _results:
		if result["ok"]:
			_problems.append("a broken generation unexpectedly succeeded")
	var expected := [
		["gateway.response: no JSON object found in the model output — reply with only a JSON Theme Pack"],
		["gateway.response: HTTP 401 — provider said: {\"error\":\"invalid api key\"}"],
		["gateway.request: transport error: connection refused"],
		["pack.text.zh: required object", "pack.text.ja: required object"],
	]
	for i in 4:
		if _errors[i] != expected[i]:
			_problems.append("attempt %d errors: expected %s, got %s" % [i + 1, expected[i], _errors[i]])
	if DirAccess.dir_exists_absolute(AIGateway.CACHE_DIR) and not DirAccess.get_files_at(AIGateway.CACHE_DIR).is_empty():
		_problems.append("failed generations must not be cached")
	for registered in AIGateway.get_generated_packs():
		if registered["id"] == "builtin":
			_problems.append("an invalid pack leaked into the generated list")
	if var_to_str(GameEngine.get_state()) != _state_before:
		_problems.append("Engine state changed during failed generations")
	return _problems


func expected_state() -> Dictionary:
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
