class_name EngineCore
extends Node

## The Engine: the game's deterministic rules layer and its single public seam
## (CONTEXT.md: "Engine"). Everything gameplay — UI, packs, AI output — goes
## through this API and nothing else:
##
##   validate_pack(pack: Dictionary) -> PackedStringArray
##   new_game(pack: Dictionary) -> Dictionary      # validate + start a session
##   step(action: Dictionary) -> Dictionary        # apply one scripted action
##   get_state() -> Dictionary                     # full snapshot (deep copy)
##
## Results are plain Dictionaries so replays can assert them bit-for-bit and
## so later format versions extend without breaking the seam.
##
## Determinism contract: no wall-clock time, no unseeded randomness, pure
## integer arithmetic over fixed skeleton constants. State changes only via
## new_game() and step(); a failed call leaves state untouched.

# --- Fixed skeleton constants (mechanics, not content) -----------------------
# Content strings live in theme packs, never here. These constants exist only
# to give ticket 01 a live, steppable state; tickets 02-03 replace them with
# the real battle core and turn cycle behind the same API.

const START_TURN := 1
const START_HP := 60
const START_AP := 5
const AP_MAX := 10
const AP_REGEN := 3
const PATROL_AP_COST := 1
const PATROL_EXP := 1

const ACTION_PATROL := "patrol"
const ACTION_REST := "rest"
const ACTION_END_TURN := "end_turn"

const BUILTIN_PACK_PATH := "res://engine/builtin_pack.json"

var _state: Dictionary = {}


func _ready() -> void:
	_state = {}


# --- The seam ----------------------------------------------------------------

## Validate a Theme Pack against the v1 contract. Returns the list of reasons
## the pack is invalid; an empty list means valid. Pure: reads nothing but the
## argument, mutates nothing. Ticket 04 completes the full localeText contract;
## the reason format ("dotted.path: problem") is stable from now on.
func validate_pack(pack: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	if pack.is_empty():
		errors.append("pack: required")
		return errors
	if not pack.has("id") or not (pack["id"] is String) or (pack["id"] as String).is_empty():
		errors.append("pack.id: required non-empty string")
	_validate_accent(pack, errors)
	_validate_parts(pack, errors)
	_validate_text(pack, errors)
	return errors


## Validate the pack and, if valid, start a fresh deterministic session under
## it. Returns {ok: bool, errors: PackedStringArray, state: Dictionary}; state
## is the new snapshot on success and an empty Dictionary on failure. An
## invalid pack never changes existing state.
func new_game(pack: Dictionary) -> Dictionary:
	var errors := validate_pack(pack)
	if not errors.is_empty():
		return {"ok": false, "errors": errors, "state": {}}
	_state = {
		"pack_id": pack["id"],
		"turn": START_TURN,
		"hp": START_HP,
		"ap": START_AP,
		"exp": 0,
		"log": [],
	}
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


## Apply one scripted action to the session. Returns
## {ok: bool, errors: PackedStringArray, state: Dictionary} where state is the
## post-step snapshot on success and the untouched snapshot on failure. The
## action vocabulary grows in later tickets without changing this signature.
func step(action: Dictionary) -> Dictionary:
	if _state.is_empty():
		return _step_error("engine: no session; call new_game() first")
	var type: Variant = action.get("type", null)
	match type:
		ACTION_PATROL:
			return _apply_patrol()
		ACTION_REST:
			return _apply_rest()
		ACTION_END_TURN:
			return _apply_end_turn()
		_:
			return _step_error("action.type: unknown action type %s" % [type])


## Full state snapshot as a deep copy: the view layer renders this, replays
## assert against it bit-for-bit, and nothing outside the Engine holds a
## mutable reference to internal state.
func get_state() -> Dictionary:
	return _state.duplicate(true)


## Load the built-in Theme Pack shipped with the game (pure JSON, v1 shape).
func get_builtin_pack() -> Dictionary:
	var file := FileAccess.open(BUILTIN_PACK_PATH, FileAccess.READ)
	if file == null:
		push_error("Engine: cannot read builtin pack at %s" % [BUILTIN_PACK_PATH])
		return {}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		push_error("Engine: builtin pack is not a JSON object")
		return {}
	return parsed


# --- Validation helpers -------------------------------------------------------

func _validate_accent(pack: Dictionary, errors: PackedStringArray) -> void:
	var accent: Variant = pack.get("accent", null)
	if not (accent is String):
		errors.append("pack.accent: required #rrggbb string")
		return
	var regex := RegEx.new()
	regex.compile("^#[0-9a-fA-F]{6}$")
	if regex.search(accent as String) == null:
		errors.append("pack.accent: must match #rrggbb")


func _validate_parts(pack: Dictionary, errors: PackedStringArray) -> void:
	var parts: Variant = pack.get("parts", null)
	if not (parts is Dictionary):
		errors.append("pack.parts: required object")
		return
	_validate_fatigue(parts as Dictionary, errors)


func _validate_fatigue(parts: Dictionary, errors: PackedStringArray) -> void:
	var fatigue: Variant = parts.get("fatigue", null)
	if not (fatigue is Dictionary):
		errors.append("pack.parts.fatigue: required object")
		return
	var fat := fatigue as Dictionary
	if not (fat.get("enabled", null) is bool):
		errors.append("pack.parts.fatigue.enabled: required bool")
	var params: Variant = fat.get("params", null)
	if not (params is Dictionary):
		errors.append("pack.parts.fatigue.params: required object")
		return
	# JSON numbers parse as float, so integer fields accept any integral number.
	var threshold: Variant = (params as Dictionary).get("threshold", null)
	if not _is_integral(threshold) or (threshold as int) <= 0:
		errors.append("pack.parts.fatigue.params.threshold: required integer > 0")
	var ap_penalty: Variant = (params as Dictionary).get("apPenalty", null)
	if not _is_integral(ap_penalty) or (ap_penalty as int) < 0:
		errors.append("pack.parts.fatigue.params.apPenalty: required integer >= 0")


## True for ints and for floats that hold an exact integer value (JSON numbers).
func _is_integral(value: Variant) -> bool:
	if value is int:
		return true
	if value is float:
		return is_finite(value as float) and value == floorf(value as float)
	return false


func _validate_text(pack: Dictionary, errors: PackedStringArray) -> void:
	var text: Variant = pack.get("text", null)
	if not (text is Dictionary):
		errors.append("pack.text: required object")
		return
	# Contract v1 tightening: all three languages are required, no fallback.
	for lang in ["en", "zh", "ja"]:
		var locale: Variant = (text as Dictionary).get(lang, null)
		if not (locale is Dictionary):
			errors.append("pack.text.%s: required object" % [lang])
			continue
		for field in ["name", "tagline"]:
			var value: Variant = (locale as Dictionary).get(field, null)
			if not (value is String) or (value as String).is_empty():
				errors.append("pack.text.%s.%s: required non-empty string" % [lang, field])


# --- Action implementations ----------------------------------------------------
# Each returns a result; on failure state is untouched. Log lines are part of
# state so replays pin exact wording.

func _step_error(message: String) -> Dictionary:
	var errors := PackedStringArray()
	errors.append(message)
	var state := get_state()
	return {"ok": false, "errors": errors, "state": state}


func _apply_patrol() -> Dictionary:
	if _state["ap"] < PATROL_AP_COST:
		return _step_error("patrol: not enough AP (%d < %d)" % [_state["ap"], PATROL_AP_COST])
	_state["ap"] = _state["ap"] - PATROL_AP_COST
	_state["exp"] = _state["exp"] + PATROL_EXP
	_log("Turn %d: patrol (+%d exp)" % [_state["turn"], PATROL_EXP])
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _apply_rest() -> Dictionary:
	_state["hp"] = START_HP
	_log("Turn %d: rest (full heal)" % [_state["turn"]])
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _apply_end_turn() -> Dictionary:
	_state["turn"] = _state["turn"] + 1
	_state["ap"] = mini(AP_MAX, _state["ap"] + AP_REGEN)
	_log("Turn %d: end turn (AP +regen)" % [_state["turn"]])
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _log(line: String) -> void:
	var log: Array = _state["log"]
	log.append(line)
