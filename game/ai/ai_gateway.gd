extends Node

## AIGateway — the AI Entry (ticket 06, ADR-0006): in-game Theme Pack
## generation through a provider the PLAYER configures (a cloud API key or a
## local endpoint, from recommended presets). The game hosts nothing.
##
## Architecture: the gateway lives entirely OUTSIDE the deterministic Engine.
## It talks to the provider through an injectable transport, parses and
## validates every candidate pack with the Engine's validate_pack(), and a
## generated pack enters the game ONLY through the Engine seam (the
## select_pack / import_pack actions). Generation results are persisted
## cache-first so an identical request (same provider + model + prompt)
## returns the stored pack without a second network call. Only successful
## generations are cached — a failed request can be retried after the player
## fixes their settings without clearing the cache by hand.
##
## Secrets: the API key lives only in user:// settings storage and in the
## outbound request headers. It is never hardcoded, never logged, and never
## written into the cache (it does not participate in the cache key).

const SETTINGS_PATH := "user://settings/ai_provider.json"
const CACHE_DIR := "user://ai_cache"
const GENERATED_DIR := "user://packs"

## Max characters of a provider error body echoed in an actionable error
## (truncated: never echo a full response into logs or the UI).
const RESPONSE_SNIPPET_MAX := 240

## Recommended provider presets (ADR-0006). Every preset speaks the
## OpenAI-compatible chat-completions dialect — cloud providers natively,
## local endpoints (Ollama, LM Studio) through their OpenAI-compatible
## servers — so one request builder serves both kinds.
const PRESETS := [
	{"id": "openai", "kind": "cloud", "base_url": "https://api.openai.com/v1", "model": "gpt-4o-mini"},
	{"id": "openrouter", "kind": "cloud", "base_url": "https://openrouter.ai/api/v1", "model": "openrouter/auto"},
	{"id": "ollama", "kind": "local", "base_url": "http://127.0.0.1:11434/v1", "model": "llama3.1"},
	{"id": "lmstudio", "kind": "local", "base_url": "http://127.0.0.1:1234/v1", "model": "local-model"},
]

var _settings: Dictionary = {}
var _transport: Object = null
var _default_transport: AIHttpTransport = null
var _generated: Array[Dictionary] = []


func _ready() -> void:
	_settings = _load_settings()
	_default_transport = AIHttpTransport.new()
	add_child(_default_transport)
	_scan_generated_packs()


# --- Provider settings ----------------------------------------------------------

## The recommended presets (id, kind, base_url, model per entry).
func get_presets() -> Array:
	return PRESETS.duplicate(true)


## The currently configured provider settings: {kind, preset, base_url, model,
## api_key}. The api_key is the player's own secret on their own machine —
## callers must never log or display it.
func get_settings() -> Dictionary:
	return _settings.duplicate(true)


## Validate and persist provider settings to user:// storage. Returns
## {ok: bool, errors: PackedStringArray}; on failure nothing is persisted and
## the previous settings stand.
func set_settings(settings: Dictionary) -> Dictionary:
	var errors := validate_settings(settings)
	if not errors.is_empty():
		return {"ok": false, "errors": errors}
	_settings = settings.duplicate(true)
	_persist_settings()
	return {"ok": true, "errors": PackedStringArray()}


## Contract for provider settings (dotted reasons, like the pack contract):
## kind is "cloud"|"local"; base_url is an http(s) URL; model is non-empty;
## api_key is required for cloud providers, optional for local ones.
func validate_settings(settings: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	var kind: Variant = settings.get("kind", null)
	if not (kind is String) or not ((kind as String) == "cloud" or (kind as String) == "local"):
		errors.append("settings.kind: must be \"cloud\" or \"local\"")
	var base_url: Variant = settings.get("base_url", null)
	if not (base_url is String) or not ((base_url as String).begins_with("http://") or (base_url as String).begins_with("https://")):
		errors.append("settings.base_url: required http(s) URL")
	var model: Variant = settings.get("model", null)
	if not (model is String) or (model as String).is_empty():
		errors.append("settings.model: required non-empty string")
	var api_key: Variant = settings.get("api_key", "")
	if not (api_key is String):
		errors.append("settings.api_key: required string")
	elif kind is String and (kind as String) == "cloud" and (api_key as String).is_empty():
		errors.append("settings.api_key: required for a cloud provider")
	return errors


# --- Transport injection ----------------------------------------------------------

## Replace the transport used to reach the provider. Any object with
## post(url: String, headers: PackedStringArray, body: String) -> Dictionary
## qualifies (returning {"status": int, "body": String} or {"error": String}).
## Tests inject a fake; pass null to fall back to the default HTTP transport.
func set_transport(transport: Object) -> void:
	_transport = transport


func get_default_transport() -> AIHttpTransport:
	return _default_transport


# --- Generation -------------------------------------------------------------------

## Generate a Theme Pack about `topic` through the configured provider.
## Coroutine: awaits the transport (the default HTTP transport suspends; a
## synchronous fake transport makes the whole call run to completion).
## Returns {ok: bool, errors: PackedStringArray, pack: Dictionary,
## cached: bool, prompt: String}. On failure state is untouched (the Engine
## is not involved at all); on success the pack has already passed
## GameEngine.validate_pack() and is registered in get_generated_packs().
func generate_pack(topic: String, extra_instructions: String = "") -> Dictionary:
	var prompt := AIPackPrompt.build_prompt(topic, extra_instructions)
	var failure := PackedStringArray()
	if not _settings.is_empty():
		failure = validate_settings(_settings)
	if not failure.is_empty():
		failure.insert(0, "gateway.settings: no valid provider configured — open AI settings and pick a preset")
		return {"ok": false, "errors": failure, "pack": {}, "cached": false, "prompt": prompt}
	var cache_key := _cache_key(prompt)
	var cached := _load_cache_entry(cache_key)
	if not cached.is_empty():
		return {"ok": true, "errors": PackedStringArray(), "pack": cached["pack"], "cached": true, "prompt": prompt}
	var response: Variant = await _active_transport().post(_request_url(), _request_headers(), _request_body(prompt))
	var result := _process_response(response)
	if not result["ok"]:
		return {"ok": false, "errors": result["errors"], "pack": {}, "cached": false, "prompt": prompt}
	var pack: Dictionary = result["pack"]
	_store_cache_entry(cache_key, pack, prompt)
	_write_generated_pack(pack)
	return {"ok": true, "errors": PackedStringArray(), "pack": pack, "cached": false, "prompt": prompt}


## Theme Packs generated this run or loaded from user:// on startup — the
## in-game pack list extension beyond the shipped packs. Packs enter the game
## only through the Engine seam (select_pack / import_pack).
func get_generated_packs() -> Array:
	var packs: Array = []
	for pack in _generated:
		packs.append(pack.duplicate(true))
	return packs


## Test/diagnostic seam: drop all persisted generation cache entries. Never
## touches the generated pack files or Engine state.
func clear_cache() -> void:
	if not DirAccess.dir_exists_absolute(CACHE_DIR):
		return
	for file_name in DirAccess.get_files_at(CACHE_DIR):
		DirAccess.remove_absolute(CACHE_DIR + "/" + file_name)


# --- Request building (OpenAI-compatible chat completions) ------------------------

func _active_transport() -> Object:
	if _transport != null:
		return _transport
	return _default_transport


func _request_url() -> String:
	return (_settings["base_url"] as String).trim_suffix("/") + "/chat/completions"


## The player's API key travels ONLY here — never log the headers.
func _request_headers() -> PackedStringArray:
	var headers := PackedStringArray(["Content-Type: application/json"])
	if _settings["kind"] == "cloud" and not (_settings.get("api_key", "") as String).is_empty():
		headers.append("Authorization: Bearer " + (_settings["api_key"] as String))
	return headers


func _request_body(prompt: String) -> String:
	var body := {
		"model": _settings["model"],
		"messages": [
			{"role": "system", "content": AIPackPrompt.SYSTEM_PROMPT},
			{"role": "user", "content": prompt},
		],
		"temperature": 0.8,
	}
	return JSON.stringify(body)


# --- Response handling --------------------------------------------------------------

## Turn a transport result into {ok, errors, pack}. Every failure is an
## actionable error; Engine validation reasons pass through verbatim (they
## are the pack contract). Full response bodies are never echoed.
func _process_response(response: Variant) -> Dictionary:
	var failure := PackedStringArray()
	if not (response is Dictionary):
		failure.append("gateway.transport: transport returned no result")
		return {"ok": false, "errors": failure, "pack": {}}
	var response_dict := response as Dictionary
	if response_dict.has("error"):
		failure.append("gateway.request: transport error: %s" % [str(response_dict["error"])])
		return {"ok": false, "errors": failure, "pack": {}}
	var status: int = int(response_dict.get("status", 0))
	var body := str(response_dict.get("body", ""))
	if status < 200 or status >= 300:
		failure.append("gateway.response: HTTP %d — provider said: %s" % [status, _snippet(body)])
		return {"ok": false, "errors": failure, "pack": {}}
	var parsed: Variant = JSON.parse_string(body)
	if not (parsed is Dictionary):
		failure.append("gateway.response: provider reply is not a JSON object")
		return {"ok": false, "errors": failure, "pack": {}}
	var content: Variant = (parsed as Dictionary).get("choices", null)
	if content is Array and (content as Array).size() > 0 and (content[0] as Dictionary).get("message", null) is Dictionary:
		content = ((content[0] as Dictionary)["message"] as Dictionary).get("content", null)
	else:
		content = null
	if not (content is String):
		failure.append("gateway.response: unexpected reply shape (expected choices[0].message.content)")
		return {"ok": false, "errors": failure, "pack": {}}
	var pack_variant: Variant = AIPackPrompt.extract_json_object(content as String)
	if pack_variant == null:
		failure.append("gateway.response: no JSON object found in the model output — reply with only a JSON Theme Pack")
		return {"ok": false, "errors": failure, "pack": {}}
	if not (pack_variant is Dictionary):
		failure.append("gateway.response: model output is not a JSON object")
		return {"ok": false, "errors": failure, "pack": {}}
	# The ONE seam: AI output becomes a pack only by passing the Engine's
	# validation. Reasons are the raw contract reasons, verbatim.
	var errors: PackedStringArray = GameEngine.validate_pack(pack_variant)
	if not errors.is_empty():
		return {"ok": false, "errors": errors, "pack": {}}
	return {"ok": true, "errors": PackedStringArray(), "pack": pack_variant}


func _snippet(text: String) -> String:
	var flat := text.replace("\n", " ").strip_edges()
	if flat.length() > RESPONSE_SNIPPET_MAX:
		flat = flat.substr(0, RESPONSE_SNIPPET_MAX) + "..."
	return flat


# --- Cache (cache-first persistence) ---------------------------------------------

## Cache key: a hash over provider kind + endpoint + model + the full prompt —
## exactly what "same provider + model + prompt" means. The API key never
## participates (rotating a key must not bust the cache).
func _cache_key(prompt: String) -> String:
	var material := "%s|%s|%s|%s" % [_settings["kind"], _settings["base_url"], _settings["model"], prompt]
	return material.sha256_text()


func _cache_path(key: String) -> String:
	return CACHE_DIR + "/" + key + ".json"


func _store_cache_entry(key: String, pack: Dictionary, prompt: String) -> void:
	DirAccess.make_dir_recursive_absolute(CACHE_DIR)
	var entry := {
		"key": key,
		"request": {"kind": _settings["kind"], "base_url": _settings["base_url"], "model": _settings["model"], "prompt": prompt},
		"pack": pack,
		"created_at": Time.get_unix_time_from_system(),
	}
	var file := FileAccess.open(_cache_path(key), FileAccess.WRITE)
	if file == null:
		push_warning("AIGateway: cannot write cache entry %s (%s)" % [key, error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(entry, "\t") + "\n")


func _load_cache_entry(key: String) -> Dictionary:
	var file := FileAccess.open(_cache_path(key), FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {}
	var entry := parsed as Dictionary
	if not (entry.get("pack", null) is Dictionary):
		return {}
	return entry


# --- Generated pack files ---------------------------------------------------------

## Persist a generated pack as pure JSON under user://packs so it can later be
## re-imported through the Engine's import_pack action, and register it in
## the in-memory generated list (the in-game pack list extension).
func _write_generated_pack(pack: Dictionary) -> void:
	DirAccess.make_dir_recursive_absolute(GENERATED_DIR)
	var path := GENERATED_DIR + "/" + _safe_file_name(str(pack["id"])) + ".json"
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file != null:
		file.store_string(JSON.stringify(pack, "\t") + "\n")
	else:
		push_warning("AIGateway: cannot write generated pack %s (%s)" % [path, error_string(FileAccess.get_open_error())])
	_register_generated(pack)


func _register_generated(pack: Dictionary) -> void:
	var id := str(pack["id"])
	for i in _generated.size():
		if str(_generated[i]["id"]) == id:
			_generated[i] = pack.duplicate(true)
			return
	_generated.append(pack.duplicate(true))


## Re-validate and register packs persisted by earlier runs. Invalid files are
## skipped (they can no longer enter the game — validation is the only door).
func _scan_generated_packs() -> void:
	if not DirAccess.dir_exists_absolute(GENERATED_DIR):
		return
	for file_name in DirAccess.get_files_at(GENERATED_DIR):
		if not file_name.ends_with(".json"):
			continue
		var loaded := GameEngine.load_pack_file(GENERATED_DIR + "/" + file_name)
		if loaded["ok"]:
			_register_generated(loaded["pack"])


func _safe_file_name(id: String) -> String:
	var name := ""
	for character in id.to_lower():
		if (character >= "a" and character <= "z") or (character >= "0" and character <= "9") or character == "_" or character == "-":
			name += character
		else:
			name += "_"
	if name.is_empty():
		name = "generated"
	return name


# --- Settings persistence ----------------------------------------------------------

func _persist_settings() -> void:
	DirAccess.make_dir_recursive_absolute(SETTINGS_PATH.get_base_dir())
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("AIGateway: cannot persist settings (%s)" % [error_string(FileAccess.get_open_error())])
		return
	file.store_string(JSON.stringify(_settings, "\t") + "\n")


func _load_settings() -> Dictionary:
	var file := FileAccess.open(SETTINGS_PATH, FileAccess.READ)
	if file == null:
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		return {}
	return parsed as Dictionary
