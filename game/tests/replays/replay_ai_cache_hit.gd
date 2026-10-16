extends ReplayBase

## Ticket 06: cache-first persistence. An identical generation request (same
## provider + model + prompt) returns the stored result with exactly ONE
## network call; a different prompt goes back to the transport. Also pins the
## request dialect (OpenAI-compatible chat completions, no Authorization
## header for a local provider) and that generation never touches Engine
## state.

const LOCAL_SETTINGS := {"kind": "local", "preset": "ollama", "base_url": "http://127.0.0.1:11434/v1", "model": "fake-model", "api_key": ""}
const TOPIC_A := "tidal moon vault"
const TOPIC_B := "ember steppe"

var _problems: PackedStringArray = PackedStringArray()
var _fake: AIFakeTransport
var _result_a1: Dictionary = {}
var _result_a2: Dictionary = {}
var _result_b: Dictionary = {}
var _state_before := ""


func replay_name() -> String:
	return "ai_cache_hit_single_call"


func actions() -> Array:
	return [
		Callable(self, "setup_gateway"),
		Callable(self, "generate_a_first"),
		Callable(self, "generate_a_second"),
		Callable(self, "generate_b"),
	]


## Test-driver code (not an Engine action): reset the cache, inject the fake
## transport (zero network), configure a local provider.
func setup_gateway() -> void:
	AIGateway.clear_cache()
	_fake = AIFakeTransport.new()
	_fake.queue_response(AIFakeTransport.chat_response(_model_pack_json("tidal_moon", TOPIC_A)))
	_fake.queue_response(AIFakeTransport.chat_response(_model_pack_json("ember_steppe", TOPIC_B)))
	AIGateway.set_transport(_fake)
	var saved := AIGateway.set_settings(LOCAL_SETTINGS)
	if not saved["ok"]:
		_problems.append("local settings rejected: %s" % [saved["errors"]])
	_state_before = var_to_str(GameEngine.get_state())


func generate_a_first() -> void:
	_result_a1 = await AIGateway.generate_pack(TOPIC_A)


func generate_a_second() -> void:
	_result_a2 = await AIGateway.generate_pack(TOPIC_A)


func generate_b() -> void:
	_result_b = await AIGateway.generate_pack(TOPIC_B)


func checks() -> PackedStringArray:
	if _result_a1.is_empty() or _result_a2.is_empty() or _result_b.is_empty():
		_problems.append("a generate_pack() call never returned (transport hung?)")
		return _problems
	if not _result_a1["ok"]:
		_problems.append("first generation failed: %s" % [_result_a1["errors"]])
	if not _result_b["ok"]:
		_problems.append("topic-B generation failed: %s" % [_result_b["errors"]])
	if not _result_a2["ok"]:
		_problems.append("cached generation failed: %s" % [_result_a2["errors"]])
	if not _result_a2.get("cached", false):
		_problems.append("second identical request was not served from cache")
	if _result_a1.get("cached", true):
		_problems.append("first request claimed a cache hit")
	if _fake.calls != 2:
		_problems.append("expected exactly 2 network calls (1 fresh + 1 different topic), got %d" % [_fake.calls])
	if var_to_str(_result_a1["pack"]) != var_to_str(_result_a2["pack"]):
		_problems.append("cached result differs from the first result")
	if var_to_str(GameEngine.get_state()) != _state_before:
		_problems.append("Engine state changed during generation")
	_check_request_dialect()
	_check_persistence(_result_a1["pack"])
	return _problems


func _check_request_dialect() -> void:
	if not _fake.last_url.ends_with("/chat/completions"):
		_problems.append("request URL is not chat-completions: %s" % [_fake.last_url])
	var body: Variant = JSON.parse_string(_fake.last_body)
	if not (body is Dictionary):
		_problems.append("request body is not a JSON object")
		return
	if str(body.get("model", "")) != "fake-model":
		_problems.append("request model field mismatch: %s" % [body.get("model", "")])
	var messages: Array = body.get("messages", [])
	if messages.size() != 2 or str(messages[0].get("role", "")) != "system" or str(messages[1].get("role", "")) != "user":
		_problems.append("request messages shape unexpected")
		return
	var user_prompt := str(messages[1]["content"])
	if not user_prompt.contains(TOPIC_B):
		_problems.append("user prompt does not carry the topic")
	if not user_prompt.contains("\"version\": 1"):
		_problems.append("user prompt does not embed the v1 contract")
	for header in _fake.last_headers:
		if header.begins_with("Authorization"):
			_problems.append("local provider must not send an Authorization header")


func _check_persistence(pack: Dictionary) -> void:
	var cache_files := DirAccess.get_files_at(AIGateway.CACHE_DIR)
	if cache_files.size() != 2:
		_problems.append("expected 2 cache entries after 2 distinct requests, got %d" % [cache_files.size()])
	var pack_path := AIGateway.GENERATED_DIR + "/" + str(pack["id"]) + ".json"
	if not FileAccess.file_exists(pack_path):
		_problems.append("generated pack not persisted at %s" % [pack_path])
	var found := false
	for registered in AIGateway.get_generated_packs():
		if registered["id"] == pack["id"]:
			found = true
	if not found:
		_problems.append("generated pack %s not registered in the pack list" % [pack["id"]])


## A complete v1 pack "emitted by the model": the builtin pack re-themed, so
## the text is guaranteed contract-complete in all three locales.
func _model_pack_json(pack_id: String, pack_name: String) -> String:
	var pack := GameEngine.get_builtin_pack()
	pack["id"] = pack_id
	pack["accent"] = "#4a6fa5"
	pack["text"]["en"]["name"] = pack_name
	pack["text"]["en"]["tagline"] = "generated by the fake model"
	pack["text"]["zh"]["name"] = pack_name
	pack["text"]["zh"]["tagline"] = "假模型生成"
	pack["text"]["ja"]["name"] = pack_name
	pack["text"]["ja"]["tagline"] = "フェイクモデル生成"
	return JSON.stringify(pack)


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
