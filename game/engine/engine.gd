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
##   load_pack_file(path: String) -> Dictionary    # {ok, errors, pack}; pure
##   export_pack(path: String) -> Dictionary       # write current pack as JSON
##
## Results are plain Dictionaries so replays can assert them bit-for-bit and
## so later format versions extend without breaking the seam.
##
## Determinism contract: no wall-clock time, no randomness — combat variance
## comes from a fixed integer jitter formula, never from a RNG. State changes
## only via new_game() and step(); a failed call leaves state untouched.

# --- Fixed skeleton constants (mechanics, not content) -----------------------
# Content strings live in theme packs, never here. Skill effects, leader and
# enemy stats, quest node graphs, and plans are rules; every name/icon/title
# for them is pack text (text.<lang>.cards / .skillNames / .enemies /
# .enemyActions / .questTitles / .flavor).

## Leader skills. "attr" lives on the leader's binding (not the skill) and is
## what the weakness multiplier checks against the enemy's weakness.
const SKILLS := {
	"slash": {"kind": "attack", "ap": 2, "mult": 1.0},
	"heavy": {"kind": "attack", "ap": 4, "mult": 2.2},
	"multi": {"kind": "attack", "ap": 3, "mult": 0.7, "hits": 2},
	"blast": {"kind": "magic", "ap": 3, "mult": 1.4},
	"mend": {"kind": "heal", "ap": 2, "mult": 0.9},
	"guard": {"kind": "support", "ap": 1},
	"hex": {"kind": "interference", "ap": 2},
}

## The battle party: the six skeleton character cards with base stats and
## their two skill bindings each. The party is fixed; the card collection
## (chests) accumulates counts and EXP on these same six ids.
const LEADERS := [
	{"id": "hero", "faction": 0, "at": 14, "max_hp": 60, "skills": [{"id": "slash"}, {"id": "heavy"}]},
	{"id": "tank", "faction": 0, "at": 9, "max_hp": 85, "skills": [{"id": "guard"}, {"id": "slash"}]},
	{"id": "healer", "faction": 1, "at": 10, "max_hp": 70, "skills": [{"id": "mend"}, {"id": "slash"}]},
	{"id": "mage", "faction": 1, "at": 11, "max_hp": 45, "skills": [{"id": "blast", "attr": "ice"}, {"id": "mend"}]},
	{"id": "striker", "faction": 2, "at": 12, "max_hp": 50, "skills": [{"id": "multi"}, {"id": "blast", "attr": "fire"}]},
	{"id": "archer", "faction": 2, "at": 13, "max_hp": 48, "skills": [{"id": "slash"}, {"id": "hex"}]},
]

## Enemies: stats, the pre-announced action plan (cycling), and the elemental
## weakness the multiplier checks against the binding's "attr". Bosses are
## immune to hexes.
const ENEMIES := {
	"grunt": {"hp": 40, "at": 8, "plan": ["e_slash"], "weakness": ""},
	"brute": {"hp": 70, "at": 12, "plan": ["e_heavy", "e_slash"], "weakness": "ice"},
	"shaman": {"hp": 35, "at": 10, "plan": ["e_bolt", "e_slash"], "weakness": "fire"},
	"boss": {"hp": 160, "at": 16, "plan": ["e_heavy", "e_slash", "e_bolt"], "weakness": "fire", "boss": true},
}

const ENEMY_SKILLS := {
	"e_slash": {"kind": "attack", "mult": 1.0},
	"e_heavy": {"kind": "attack", "mult": 1.6},
	"e_bolt": {"kind": "magic", "mult": 1.2},
}

# --- Turn cycle: quest skeletons ---------------------------------------------
# Steps of paired node ids (left / right branch), identical for every theme —
# the pack's questTitles name the quests, the pack's text names the nodes.
# Node shapes: battle/auto carry an enemy id; event carries its effect.

const QUEST_NODES := {
	"b_g": {"t": "battle", "e": "grunt"},
	"b_b": {"t": "battle", "e": "brute"},
	"b_s": {"t": "battle", "e": "shaman"},
	"b_boss": {"t": "battle", "e": "boss"},
	"a_g": {"t": "auto", "e": "grunt"},
	"a_b": {"t": "auto", "e": "brute"},
	"chest": {"t": "chest"},
	"heal": {"t": "heal"},
	"gains": {"t": "gains"},
	"medal": {"t": "medal"},
	"ev_exp": {"t": "event", "effect": "exp"},
	"ev_gains": {"t": "event", "effect": "gains"},
}

const QUESTS := {
	"prep": [
		{"key": "prepA", "steps": [["b_g", "chest"], ["ev_exp", "ev_gains"], ["gains", "heal"]]},
		{"key": "prepB", "steps": [["chest", "a_g"], ["heal", "ev_exp"], ["medal", "gains"]]},
	],
	"operation": [
		{"key": "opA", "steps": [["b_g", "a_b"], ["chest", "ev_gains"], ["heal", "b_s"], ["b_boss", "chest"]]},
		{"key": "opB", "steps": [["a_g", "chest"], ["ev_exp", "b_s"], ["b_b", "heal"], ["chest", "medal"]]},
	],
}

# --- Turn cycle: tuning -------------------------------------------------------

const PHASE_PREPARE := 0
const PHASE_OPERATION := 1
const PHASE_BASE := 2
const PHASE_WAR_REPORT := 3

const START_REALM := 100
const REALM_WARN_BELOW := 50
const TURN_LIMIT := 8
const WAR_LOSS_BASE := 9
const WAR_LOSS_REDUCTION := 2
const WAR_LOSS_MIN := 3
const MAX_TICKETS := 2
const GAINS_NODE_AMOUNT := 2
const EVENT_EXP := 2
const MEAL_EXP := 2
const LOGISTICS_GAINS := 1
const CHEST_CHOICES := 3
const AUTO_EXP := 1
const AUTO_AT_BONUS_PER_LEVEL := 0.05
const AUTO_WIN_RATIO := 1.6
const BATTLE_WIN_EXP := 2

# --- Battle tuning -------------------------------------------------------------

const BATTLE_START_AP := 4
const BATTLE_AP_MAX := 6
const BATTLE_AP_REGEN := 2
const BATTLE_ROUND_CAP := 10
const COMBO_BONUS := 0.1
const WEAKNESS_MULT := 1.5
const GUARD_REDUCTION := 0.7
const ENEMY_SCALE_PER_TURN := 0.15

const START_TURN := 1

# --- Pack contract v1 (ADR-0002: versioned from day one) ----------------------
# The Engine interprets exactly this format version; packs declaring any other
# version are rejected so old packs keep loading as the format grows.

const PACK_FORMAT_VERSION := 1
## Palette ids a v1 pack may declare in bodyClass (the UI maps them to styles;
## the Engine only checks the enum).
const PACK_PALETTES := ["seas", "iron"]

# --- Action vocabulary -----------------------------------------------------------

const ACTION_START_BATTLE := "start_battle"
const ACTION_SKILL := "skill"
const ACTION_END_TURN := "end_turn"
const ACTION_START_QUEST := "start_quest"
const ACTION_CHOOSE := "choose"
const ACTION_CHEST_PICK := "chest_pick"
const ACTION_RETIRE := "retire"
const ACTION_BASE_PICK := "base_pick"
const ACTION_END_PHASE := "end_phase"
const ACTION_SELECT_PACK := "select_pack"
const ACTION_IMPORT_PACK := "import_pack"
const ACTION_EXPORT_PACK := "export_pack"
const ACTION_SET_LANGUAGE := "set_language"

const BUILTIN_PACK_PATH := "res://engine/builtin_pack.json"

var _state: Dictionary = {}
var _pack: Dictionary = {}
## UI language for chrome text (log templates, labels). Not part of session
## state: switching it preserves the run bit-for-bit. Pack text uses the same
## locale (pack.text.<lang>, complete in all three by contract — no fallback).
var _lang: String = ChromeText.LANGUAGES[0]


func _ready() -> void:
	_state = {}
	_pack = {}


# --- The seam ----------------------------------------------------------------

## Validate a Theme Pack against the v1 contract. Returns the list of reasons
## the pack is invalid; an empty list means valid. Pure: reads nothing but the
## argument, mutates nothing. Reason format: "dotted.path: problem", ordered
## top-to-bottom through the schema (id, version, accent, bodyClass, parts,
## then per-locale text in en, zh, ja).
func validate_pack(pack: Dictionary) -> PackedStringArray:
	var errors := PackedStringArray()
	if pack.is_empty():
		errors.append("pack: required")
		return errors
	if not pack.has("id") or not (pack["id"] is String) or (pack["id"] as String).is_empty():
		errors.append("pack.id: required non-empty string")
	# ADR-0002: the contract carries a version from day one and validation
	# gates features by version — this Engine only interprets v1 packs.
	var version: Variant = pack.get("version", null)
	if not _is_integral(version):
		errors.append("pack.version: required integer")
	elif int(version) != PACK_FORMAT_VERSION:
		errors.append("pack.version: unsupported version %d (this engine interprets v%d)" % [int(version), PACK_FORMAT_VERSION])
	_validate_accent(pack, errors)
	_validate_body_class(pack, errors)
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
	_pack = pack.duplicate(true)
	_lang = ChromeText.LANGUAGES[0]
	var collection := {}
	for leader in LEADERS:
		collection[leader["id"]] = {"count": 1, "exp": 0}
	_state = {
		"pack_id": pack["id"],
		"turn": START_TURN,
		"phase": PHASE_PREPARE,
		"realm": START_REALM,
		"gains_turn": 0,
		"gains_total": 0,
		"medals": 0,
		"tickets": 0,
		"fatigue": 0,
		"collection": collection,
		"quest": null,
		"chest": null,
		"base_options": null,
		"ended": "",
		"battle": null,
		"log": [],
	}
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


## Apply one scripted action to the session. Returns
## {ok: bool, errors: PackedStringArray, state: Dictionary} where state is the
## post-step snapshot on success and the untouched snapshot on failure. The
## action vocabulary grows in later tickets without changing this signature.
##
## Turn-cycle vocabulary (ticket 03):
##   {"type": "start_quest", "pool": "prep"|"operation", "idx": <0|1>}
##   {"type": "choose", "option": <0|1>}     # quest branch choice
##   {"type": "chest_pick", "idx": <0..2>}   # resolve an opened chest
##   {"type": "retire"}                      # abandon the quest, no rewards
##   {"type": "base_pick", "option": <int>}  # base phase action
##   {"type": "end_phase"}                   # advance the phase; at the war
##                                           # report, resolve it -> next turn
## Battle vocabulary (ticket 02):
##   {"type": "start_battle", "enemy": <skeleton enemy id>}
##   {"type": "skill", "leader": <leader index>, "slot": <skill slot index>}
##   {"type": "end_turn"}                    # battle only: resolve the enemy
##                                           # phase announced in battle.next_action;
##                                           # once over, close the battle (and
##                                           # finish or abandon the quest node)
## Pack vocabulary (ticket 04): switch the running session's Theme Pack —
## same rules, new world. State is preserved; only pack_id and the pack text
## change. A failed switch leaves state untouched.
##   {"type": "select_pack", "pack": <pack Dictionary>}   # in-memory pack
##   {"type": "import_pack", "path": <String>}            # pack from a file
##   {"type": "export_pack", "path": <String>}            # write current pack
## Chrome vocabulary (ticket 05): switch the UI language mid-run. Chrome-only:
## the session state is preserved bit-for-bit (the switch touches nothing but
## the chrome locale used for log templates, labels, and pack-text lookups).
##   {"type": "set_language", "lang": <"en"|"zh"|"ja">}
func step(action: Dictionary) -> Dictionary:
	if _state.is_empty():
		return _step_error("engine: no session; call new_game() first")
	var type: Variant = action.get("type", null)
	match type:
		ACTION_START_BATTLE:
			return _apply_start_battle(action)
		ACTION_SKILL:
			return _apply_skill(action)
		ACTION_END_TURN:
			return _apply_end_turn()
		ACTION_START_QUEST:
			return _apply_start_quest(action)
		ACTION_CHOOSE:
			return _apply_choose(action)
		ACTION_CHEST_PICK:
			return _apply_chest_pick(action)
		ACTION_RETIRE:
			return _apply_retire()
		ACTION_BASE_PICK:
			return _apply_base_pick(action)
		ACTION_END_PHASE:
			return _apply_end_phase()
		ACTION_SELECT_PACK:
			return _apply_select_pack(action)
		ACTION_IMPORT_PACK:
			return _apply_import_pack(action)
		ACTION_EXPORT_PACK:
			return _apply_export_pack(action)
		ACTION_SET_LANGUAGE:
			return _apply_set_language(action)
		_:
			return _step_error("action.type: unknown action type %s" % [type])


## Full state snapshot as a deep copy: the view layer renders this, replays
## assert against it bit-for-bit, and nothing outside the Engine holds a
## mutable reference to internal state.
func get_state() -> Dictionary:
	return _state.duplicate(true)


## Chrome strings (phases, results, quest pools, buttons, UI labels, log
## templates) for the given language — or the current one when omitted.
## Returns {} for an unknown language. Deep copy: read-only for callers.
func chrome(lang := "") -> Dictionary:
	var key := _lang if lang.is_empty() or not (lang is String) else lang
	if not ChromeText.LANGUAGES.has(key):
		return {}
	return (ChromeText.CHROME[key] as Dictionary).duplicate(true)


## The session's UI language ("en" | "zh" | "ja"); switched only by the
## set_language action.
func get_language() -> String:
	return _lang


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


## Load a Theme Pack from a file (user-imported or shipped) and validate it.
## Pure: reads the file, never touches session state. Returns
## {ok: bool, errors: PackedStringArray, pack: Dictionary} where pack is set
## only on success.
func load_pack_file(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		var errors := PackedStringArray()
		errors.append("pack file: cannot open %s (%s)" % [path, error_string(FileAccess.get_open_error())])
		return {"ok": false, "errors": errors, "pack": {}}
	var parsed: Variant = JSON.parse_string(file.get_as_text())
	if not (parsed is Dictionary):
		var errors := PackedStringArray()
		errors.append("pack file: not a JSON object: %s" % [path])
		return {"ok": false, "errors": errors, "pack": {}}
	var pack := parsed as Dictionary
	var validation := validate_pack(pack)
	if not validation.is_empty():
		return {"ok": false, "errors": validation, "pack": {}}
	return {"ok": true, "errors": PackedStringArray(), "pack": pack}


## Write the current session's Theme Pack to a file as pure JSON (v1 shape —
## an exported pack is itself a valid pack). Returns {ok, errors, path};
## requires a session. State is untouched.
func export_pack(path: String) -> Dictionary:
	var errors := PackedStringArray()
	if _state.is_empty():
		errors.append("engine: no session; call new_game() first")
		return {"ok": false, "errors": errors, "path": path}
	if path.is_empty():
		errors.append("export_pack.path: required string")
		return {"ok": false, "errors": errors, "path": path}
	var dir := path.get_base_dir()
	if dir != "" and not DirAccess.dir_exists_absolute(dir):
		DirAccess.make_dir_recursive_absolute(dir)
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		errors.append("export_pack: cannot write %s (%s)" % [path, error_string(FileAccess.get_open_error())])
		return {"ok": false, "errors": errors, "path": path}
	file.store_string(JSON.stringify(_pack, "\t") + "\n")
	return {"ok": true, "errors": PackedStringArray(), "path": path}


# --- Turn cycle ------------------------------------------------------------------

func _apply_start_quest(action: Dictionary) -> Dictionary:
	if _state["ended"] != "":
		return _step_error("start_quest: the game is over")
	if _state["quest"] != null:
		return _step_error("start_quest: quest already active")
	if _state["battle"] != null:
		return _step_error("start_quest: battle still active")
	if _state["chest"] != null:
		return _step_error("start_quest: chest still open")
	var phase: int = _state["phase"]
	if phase != PHASE_PREPARE and phase != PHASE_OPERATION:
		return _step_error("start_quest: quests only run in preparation and operation phases")
	var pool: Variant = action.get("pool", null)
	if not (pool is String) or not QUESTS.has(pool):
		return _step_error("start_quest.pool: invalid pool %s" % [pool])
	var pool_quests: Array = QUESTS[pool]
	var idx_v: Variant = action.get("idx", null)
	if not _is_integral(idx_v):
		return _step_error("start_quest.idx: invalid quest index %s" % [idx_v])
	var idx := int(idx_v)
	if idx < 0 or idx >= pool_quests.size():
		return _step_error("start_quest.idx: invalid quest index %s" % [idx_v])
	_state["quest"] = {"pool": pool, "idx": idx, "step": 0}
	var kind: String = ChromeText.CHROME[_lang]["questPools"][pool]
	_log_chrome("quest_started", [_state["turn"], kind, _quest_title(pool_quests[idx]["key"])])
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _apply_choose(action: Dictionary) -> Dictionary:
	if _state["quest"] == null:
		return _step_error("choose: no active quest")
	if _state["battle"] != null:
		return _step_error("choose: battle still active")
	if _state["chest"] != null:
		return _step_error("choose: chest still open")
	if _state["ended"] != "":
		return _step_error("choose: the game is over")
	var option_v: Variant = action.get("option", null)
	if not _is_integral(option_v) or int(option_v) < 0 or int(option_v) > 1:
		return _step_error("choose.option: invalid branch %s" % [option_v])
	var option := int(option_v)
	var quest: Dictionary = _state["quest"]
	var steps: Array = QUESTS[quest["pool"]][quest["idx"]]["steps"]
	var step_nodes: Array = steps[quest["step"]]
	_apply_node(step_nodes[option], option)
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


## Resolve one quest node. Battle and chest nodes hand control to their own
## action loop (the step advances when the battle is won or the chest picked);
## every other node resolves immediately and advances the quest step.
func _apply_node(node_id: String, option: int) -> void:
	var node: Dictionary = QUEST_NODES[node_id]
	match node["t"]:
		"battle":
			_start_battle(node["e"])
			return
		"chest":
			_open_chest()
			return
		"auto":
			_apply_auto_node(node["e"])
		"heal":
			_state["fatigue"] = 0
			_log_chrome("rest_site", [_state["turn"]])
		"event":
			_apply_event_node(node["effect"])
		"gains":
			_state["gains_turn"] = _state["gains_turn"] + GAINS_NODE_AMOUNT
			_state["gains_total"] = _state["gains_total"] + GAINS_NODE_AMOUNT
			_log_chrome("gains_node", [
				_state["turn"], GAINS_NODE_AMOUNT, _state["gains_turn"],
			])
		"medal":
			_state["medals"] = _state["medals"] + 1
			_log_chrome("medal", [_state["turn"], _squad_level()])
	_finish_node()


## Deterministic auto-battle (the Rance-10 squad-total-AT comparison): total
## AT boosted 5% per squad level (two medals each) vs 1.6x the enemy's base
## AT. Winning or not, every leader banks +1 EXP.
func _apply_auto_node(enemy_id: String) -> void:
	var def: Dictionary = ENEMIES[enemy_id]
	var total_at := _squad_total_at()
	for id in _state["collection"]:
		var entry: Dictionary = _state["collection"][id]
		entry["exp"] = entry["exp"] + AUTO_EXP
	if total_at >= roundi(def["at"] * AUTO_WIN_RATIO):
		_log_chrome("skirmish_easy", [
			_state["turn"], _enemy_name(enemy_id), total_at, AUTO_EXP,
		])
	else:
		_log_chrome("skirmish_costly", [
			_state["turn"], _enemy_name(enemy_id), total_at, AUTO_EXP,
		])


## Event nodes resolve by the node's own effect: +EXP to the squad member
## rotating with the turn, or +1 war gains. Flavor lines come from the pack.
func _apply_event_node(effect: String) -> void:
	if effect == "exp":
		var chars := _owned_char_ids()
		var char_id: String = chars[_state["turn"] % chars.size()]
		var entry: Dictionary = _state["collection"][char_id]
		entry["exp"] = entry["exp"] + EVENT_EXP
		_log_chrome("event_exp", [_state["turn"], _flavor_line("ev_exp"), _card_name(char_id), EVENT_EXP])
	else:
		_state["gains_turn"] = _state["gains_turn"] + 1
		_state["gains_total"] = _state["gains_total"] + 1
		_log_chrome("event_gains", [_state["turn"], _flavor_line("ev_gains")])


func _open_chest() -> void:
	# Deterministic 3-card offer: a pure function of turn and quest step.
	var quest: Dictionary = _state["quest"]
	var opts: Array = []
	var k := 0
	while opts.size() < CHEST_CHOICES and k < LEADERS.size():
		var id: String = LEADERS[(_state["turn"] * 7 + quest["step"] * 5 + k * 5) % LEADERS.size()]["id"]
		if not opts.has(id):
			opts.append(id)
		k += 1
	_state["chest"] = opts
	_log_chrome("chest_open", [_state["turn"], opts.size()])


func _apply_chest_pick(action: Dictionary) -> Dictionary:
	if _state["chest"] == null:
		return _step_error("chest_pick: no chest open")
	if _state["battle"] != null:
		return _step_error("chest_pick: battle still active")
	var chest: Array = _state["chest"]
	var idx_v: Variant = action.get("idx", null)
	if not _is_integral(idx_v) or int(idx_v) < 0 or int(idx_v) >= chest.size():
		return _step_error("chest_pick.idx: invalid card index %s" % [idx_v])
	var card_id: String = chest[int(idx_v)]
	var entry: Dictionary = _state["collection"][card_id]
	entry["count"] = entry["count"] + 1
	if entry["count"] > 1:
		_log_chrome("card_gained_copy", [_state["turn"], _card_name(card_id), entry["count"]])
	else:
		_log_chrome("card_gained", [_state["turn"], _card_name(card_id)])
	_state["chest"] = null
	_finish_node()
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _finish_node() -> void:
	var quest: Dictionary = _state["quest"]
	quest["step"] = quest["step"] + 1
	var steps: Array = QUESTS[quest["pool"]][quest["idx"]]["steps"]
	if quest["step"] >= steps.size():
		_complete_quest()


func _complete_quest() -> void:
	var quest: Dictionary = _state["quest"]
	var title := _quest_title(QUESTS[quest["pool"]][quest["idx"]]["key"])
	_state["quest"] = null
	_log_chrome("quest_complete", [_state["turn"], title])
	if quest["pool"] == "operation" and _state["tickets"] < MAX_TICKETS:
		_state["tickets"] = _state["tickets"] + 1
		_log_chrome("meal_ticket_earned", [_state["turn"]])
	_state["phase"] = _state["phase"] + 1
	if _state["phase"] == PHASE_BASE:
		_set_base_options()


func _apply_retire() -> Dictionary:
	if _state["quest"] == null:
		return _step_error("retire: no active quest")
	_state["quest"] = null
	_state["battle"] = null
	_state["chest"] = null
	_state["phase"] = _state["phase"] + 1
	if _state["phase"] == PHASE_BASE:
		_set_base_options()
	_log_chrome("quest_retired", [_state["turn"]])
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _set_base_options() -> void:
	if _state["tickets"] > 0:
		_state["base_options"] = ["meal", "meal", "meal"]
	else:
		_state["base_options"] = ["exp", "gains"]


func _apply_base_pick(action: Dictionary) -> Dictionary:
	if _state["phase"] != PHASE_BASE:
		return _step_error("base_pick: not in the base phase")
	var options: Variant = _state["base_options"]
	if not (options is Array):
		return _step_error("base_pick: base phase already resolved")
	var option_v: Variant = action.get("option", null)
	if not _is_integral(option_v) or int(option_v) < 0 or int(option_v) >= (options as Array).size():
		return _step_error("base_pick.option: invalid option %s" % [option_v])
	var option := int(option_v)
	var chars := _owned_char_ids()
	var char_id: String = chars[option % chars.size()]
	var entry: Dictionary = _state["collection"][char_id]
	if _state["tickets"] > 0:
		_state["tickets"] = _state["tickets"] - 1
		entry["exp"] = entry["exp"] + MEAL_EXP
		_log_chrome("base_meal", [_state["turn"], _card_name(char_id), MEAL_EXP])
	elif option == 0:
		entry["exp"] = entry["exp"] + EVENT_EXP
		_log_chrome("base_quiet", [_state["turn"], _card_name(char_id), EVENT_EXP])
	else:
		_state["gains_turn"] = _state["gains_turn"] + LOGISTICS_GAINS
		_state["gains_total"] = _state["gains_total"] + LOGISTICS_GAINS
		_log_chrome("base_logistics", [_state["turn"], LOGISTICS_GAINS])
	_state["base_options"] = null
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _apply_end_phase() -> Dictionary:
	if _state["ended"] != "":
		return _step_error("end_phase: the game is over")
	if _state["quest"] != null:
		return _step_error("end_phase: quest still active")
	if _state["battle"] != null:
		return _step_error("end_phase: battle still active")
	if _state["chest"] != null:
		return _step_error("end_phase: chest still open")
	if _state["phase"] == PHASE_BASE and _state["base_options"] != null:
		return _step_error("end_phase: base phase options pending")
	if _state["phase"] == PHASE_WAR_REPORT:
		_resolve_war_report()
	else:
		_state["phase"] = _state["phase"] + 1
		if _state["phase"] == PHASE_BASE:
			_set_base_options()
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


## The war report converts this turn's war gains into softened realm losses.
## Fatigue ticks up once per report (when the pack's Fatigue part is enabled),
## realm at zero ends the game in defeat, and past the turn limit the
## campaign is won.
func _resolve_war_report() -> void:
	var loss := maxi(WAR_LOSS_MIN, WAR_LOSS_BASE - WAR_LOSS_REDUCTION * _state["gains_turn"])
	_state["realm"] = _state["realm"] - loss
	var left := maxi(0, _state["realm"])
	_log(_report_tpl().replace("{turn}", str(_state["turn"])).replace("{loss}", str(loss)).replace("{left}", "%d%%" % [left]))
	_state["gains_turn"] = 0
	var part := _fatigue_part()
	if not part.is_empty():
		_state["fatigue"] = _state["fatigue"] + 1
	if _state["realm"] <= 0:
		_state["ended"] = "lose"
		_log_chrome("realm_falls", [_state["turn"]])
		return
	_state["turn"] = _state["turn"] + 1
	_state["phase"] = PHASE_PREPARE
	if _state["turn"] > TURN_LIMIT:
		_state["ended"] = "win"
		_log_chrome("campaign_victory", [_state["turn"]])
	elif _state["realm"] < REALM_WARN_BELOW:
		_log_chrome("realm_warning", [_state["turn"], _state["realm"]])


func _squad_level() -> int:
	return _state["medals"] / 2


func _squad_total_at() -> int:
	var total := 0
	for leader in LEADERS:
		total = total + leader["at"]
	return roundi(total * (1.0 + AUTO_AT_BONUS_PER_LEVEL * _squad_level()))


func _owned_char_ids() -> Array:
	return _state["collection"].keys()


# --- Battle core ---------------------------------------------------------------

## Start a battle against a skeleton enemy. Returns "" on success or the error
## message; used both by the direct start_battle action and by battle quest
## nodes. Enemies scale with the session turn so later fights bite harder.
## When the pack's Fatigue part is enabled and its threshold is crossed, the
## part's apPenalty drags the battle's AP pool and regen (announced in the log).
func _start_battle(enemy_id: String) -> String:
	var def: Dictionary = ENEMIES[enemy_id]
	var scale: float = 1.0 + ENEMY_SCALE_PER_TURN * (_state["turn"] - 1)
	var hp := roundi(def["hp"] * scale)
	var at := roundi(def["at"] * scale)
	var party_hp: Array = []
	for leader in LEADERS:
		party_hp.append(leader["max_hp"])
	var battle := {
		"enemy": enemy_id,
		"boss": bool(def.get("boss", false)),
		"enemy_hp": hp,
		"enemy_max_hp": hp,
		"enemy_at": at,
		"round": 1,
		"ap": BATTLE_START_AP,
		"ap_max": BATTLE_AP_MAX,
		"regen": BATTLE_AP_REGEN,
		"combo": 0,
		"guard": false,
		"hexed": false,
		"over": "",
		"party_hp": party_hp,
		# Pre-announcement: the action the enemy will take when this round ends.
		"next_action": def["plan"][0],
	}
	var part := _fatigue_part()
	if not part.is_empty() and _state["fatigue"] >= part["params"]["threshold"]:
		var penalty: int = part["params"]["apPenalty"]
		battle["ap_max"] = maxi(1, BATTLE_AP_MAX - penalty)
		battle["regen"] = maxi(0, BATTLE_AP_REGEN - penalty)
		_log_chrome("fatigue_drag", [_state["turn"], _fatigue_part_name(), penalty])
	_state["battle"] = battle
	_log_chrome("battle_start", [_state["turn"], _enemy_name(enemy_id)])
	return ""


func _apply_start_battle(action: Dictionary) -> Dictionary:
	if _state["battle"] != null:
		return _step_error("start_battle: battle already active")
	var enemy_id: Variant = action.get("enemy", null)
	if not (enemy_id is String) or not ENEMIES.has(enemy_id):
		return _step_error("start_battle: unknown enemy %s" % [enemy_id])
	var error := _start_battle(enemy_id)
	if error != "":
		return _step_error(error)
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _apply_skill(action: Dictionary) -> Dictionary:
	var battle: Variant = _state["battle"]
	if not (battle is Dictionary):
		return _step_error("skill: no active battle")
	var b := battle as Dictionary
	if b["over"] != "":
		return _step_error("skill: battle is over")
	var leader_idx_v: Variant = action.get("leader", null)
	if not _is_integral(leader_idx_v):
		return _step_error("skill.leader: invalid leader index")
	var leader_idx := int(leader_idx_v)
	if leader_idx < 0 or leader_idx >= LEADERS.size():
		return _step_error("skill.leader: invalid leader index")
	if b["party_hp"][leader_idx] <= 0:
		return _step_error("skill.leader: leader is down")
	var slot_v: Variant = action.get("slot", null)
	if not _is_integral(slot_v):
		return _step_error("skill.slot: invalid slot index")
	var slot := int(slot_v)
	var bindings: Array = LEADERS[leader_idx]["skills"]
	if slot < 0 or slot >= bindings.size():
		return _step_error("skill.slot: invalid slot index")
	var bind: Dictionary = bindings[slot]
	var sk: Dictionary = SKILLS[bind["id"]]
	var cost: int = sk["ap"]
	if b["ap"] < cost:
		return _step_error("skill: not enough AP (%d < %d)" % [b["ap"], cost])
	b["ap"] = b["ap"] - cost
	var leader_def: Dictionary = LEADERS[leader_idx]
	var leader_label := _card_name(leader_def["id"])
	var skill_label := _skill_name(bind["id"])
	match sk["kind"]:
		"attack", "magic":
			_apply_attack(b, leader_def, bind, sk, leader_idx, slot, leader_label, skill_label)
		"heal":
			_apply_heal(b, leader_def, sk, leader_idx, slot, leader_label, skill_label)
		"support":
			b["guard"] = true
			_log_chrome("brace", [b["round"], leader_label, skill_label])
		"interference":
			b["hexed"] = true
			_log_chrome("hex_set", [b["round"], leader_label, skill_label])
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


## Attacks and magic share the damage path: per hit
## at * mult * jitter * combo, with the weakness multiplier applied before
## rounding. Each landed hit grows the combo (+10% per hit for later attacks
## this round); the combo resets when the round advances.
func _apply_attack(b: Dictionary, leader_def: Dictionary, bind: Dictionary, sk: Dictionary, leader_idx: int, slot: int, leader_label: String, skill_label: String) -> void:
	var weakness: String = ENEMIES[b["enemy"]].get("weakness", "")
	var hits: int = int(sk.get("hits", 1))
	var total := 0
	for h in hits:
		var dmg: float = leader_def["at"] * sk["mult"] * _jitter(b["round"], leader_idx, slot, h) * (1.0 + COMBO_BONUS * b["combo"])
		if weakness != "" and bind.get("attr", "") == weakness:
			dmg *= WEAKNESS_MULT
		total += roundi(dmg)
	b["enemy_hp"] = maxi(0, b["enemy_hp"] - total)
	b["combo"] = b["combo"] + hits
	_log_chrome("attack", [b["round"], leader_label, skill_label, total, b["enemy_hp"]])
	if b["enemy_hp"] <= 0:
		b["over"] = "win"
		for id in _state["collection"]:
			var entry: Dictionary = _state["collection"][id]
			entry["exp"] = entry["exp"] + BATTLE_WIN_EXP
		_log_chrome("victory", [b["round"]])


## Heals top up every standing leader, capped at each one's max HP.
func _apply_heal(b: Dictionary, leader_def: Dictionary, sk: Dictionary, leader_idx: int, slot: int, leader_label: String, skill_label: String) -> void:
	var heal := roundi(leader_def["at"] * sk["mult"] * _jitter(b["round"], leader_idx, slot, 0))
	var party_hp: Array = b["party_hp"]
	for i in party_hp.size():
		if party_hp[i] > 0:
			party_hp[i] = mini(LEADERS[i]["max_hp"], party_hp[i] + heal)
	_log_chrome("heal", [b["round"], leader_label, skill_label, heal])


## Resolve the enemy phase: execute the pre-announced action (unless a hex
## cancels it and the enemy is no boss), then advance the round, regen AP, and
## reset the round-scoped state (combo, guard). The next announcement lands in
## battle.next_action. A stalemate past the round cap withdraws the squad
## (a defeat) so every battle terminates.
func _apply_battle_end_turn(b: Dictionary) -> void:
	var def: Dictionary = ENEMIES[b["enemy"]]
	var plan: Array = def["plan"]
	if b["round"] > BATTLE_ROUND_CAP:
		b["over"] = "lose"
		_log_chrome("withdraw", [b["round"]])
		return
	var action_id: String = plan[(b["round"] - 1) % plan.size()]
	if b["hexed"] and not b["boss"]:
		b["hexed"] = false
		_log_chrome("hex_cancel", [b["round"], _enemy_name(b["enemy"]), _enemy_action_name(action_id)])
	else:
		var alive: Array = []
		for i in b["party_hp"].size():
			if b["party_hp"][i] > 0:
				alive.append(i)
		if alive.is_empty():
			b["over"] = "lose"
			_log_chrome("defeat", [b["round"]])
			return
		var sk: Dictionary = ENEMY_SKILLS[action_id]
		var guard_mult: float = GUARD_REDUCTION if b["guard"] else 1.0
		var dmg := roundi(b["enemy_at"] * sk["mult"] * _jitter(b["round"], 0, 0, 1) * guard_mult)
		var target: int = alive[b["round"] % alive.size()]
		b["party_hp"][target] = maxi(0, b["party_hp"][target] - dmg)
		_log_chrome("enemy_hit", [
			b["round"], _enemy_name(b["enemy"]), _enemy_action_name(action_id),
			dmg, _card_name(LEADERS[target]["id"]), b["party_hp"][target],
		])
		var any_alive := false
		for hp in b["party_hp"]:
			if hp > 0:
				any_alive = true
		if not any_alive:
			b["over"] = "lose"
			_log_chrome("defeat", [b["round"]])
			return
	b["round"] = b["round"] + 1
	b["ap"] = mini(b["ap_max"], b["ap"] + b["regen"])
	b["combo"] = 0
	b["guard"] = false
	b["next_action"] = plan[(b["round"] - 1) % plan.size()]


## Deterministic combat variance (0.9..1.1), the prototype's jitter formula:
## a pure function of round and attacker/slot/hit indices — no RNG anywhere.
func _jitter(round_no: int, a: int, b: int, c: int) -> float:
	return 1.0 + float((round_no * 7 + a * 3 + b * 5 + c) % 5 - 2) * 0.05


# --- Pack text lookups ---------------------------------------------------------
# Log lines carry pack names. Ticket 04 enforces these fields in the
# contract; until then a missing name falls back to the skeleton id.

func _locale() -> Dictionary:
	var text: Variant = _pack.get("text", {})
	if text is Dictionary:
		var locale: Variant = (text as Dictionary).get(_lang, {})
		if locale is Dictionary:
			return locale
	return {}


func _text_name(section: String, id: String) -> String:
	var entries: Variant = _locale().get(section, {})
	if entries is Dictionary and (entries as Dictionary).has(id):
		var entry: Variant = (entries as Dictionary)[id]
		if entry is Dictionary:
			return str((entry as Dictionary).get("name", id))
		if entry is String:
			return entry
	return id


func _card_name(id: String) -> String:
	return _text_name("cards", id)


func _skill_name(id: String) -> String:
	return _text_name("skillNames", id)


func _enemy_name(id: String) -> String:
	return _text_name("enemies", id)


func _enemy_action_name(id: String) -> String:
	return _text_name("enemyActions", id)


func _quest_title(key: String) -> String:
	var titles: Variant = _locale().get("questTitles", {})
	if titles is Dictionary and (titles as Dictionary).has(key):
		var title: Variant = (titles as Dictionary)[key]
		if title is String and not (title as String).is_empty():
			return title
	return key


## First flavor line for an event node; falls back to a bare chrome line when
## the pack carries no flavor yet (ticket 04 enforces it).
func _flavor_line(key: String) -> String:
	var flavor: Variant = _locale().get("flavor", {})
	if flavor is Dictionary:
		var lines: Variant = (flavor as Dictionary).get(key, null)
		if lines is Array and not (lines as Array).is_empty() and (lines as Array)[0] is String:
			return (lines as Array)[0]
	if key == "ev_exp":
		return "an event (+EXP)"
	return "an event (+war gains)"


## The war-report template with its {turn} {loss} {left} placeholders; falls
## back to a bare chrome template when the pack carries none (ticket 04).
func _report_tpl() -> String:
	var flavor: Variant = _locale().get("flavor", {})
	if flavor is Dictionary:
		var tpl: Variant = (flavor as Dictionary).get("reportTpl", null)
		if tpl is String and not (tpl as String).is_empty():
			return tpl
	return "Turn {turn} war report: the realm lost {loss} ground. {left} remains."


## The pack's Fatigue part as declared ({enabled, params} + text name), or {}
## when the pack disables it or carries no part text.
func _fatigue_part() -> Dictionary:
	var parts: Variant = _pack.get("parts", {})
	if not (parts is Dictionary):
		return {}
	var fatigue: Variant = (parts as Dictionary).get("fatigue", null)
	if not (fatigue is Dictionary):
		return {}
	var fat := fatigue as Dictionary
	if (fat.get("enabled", false) is bool) and fat["enabled"]:
		return fat
	return {}


func _fatigue_part_name() -> String:
	return _text_name("parts", "fatigue")


# --- Pack switching -------------------------------------------------------------
# Switch the running session's Theme Pack: same rules, new world. The state
# (turn, quest, battle, ...) carries over untouched; pack_id and every pack-
# text lookup switch to the new pack. Failed switches leave state untouched.

func _apply_select_pack(action: Dictionary) -> Dictionary:
	var pack: Variant = action.get("pack", null)
	if not (pack is Dictionary):
		return _step_error("select_pack.pack: required object")
	var errors := validate_pack(pack as Dictionary)
	if not errors.is_empty():
		return {"ok": false, "errors": errors, "state": get_state()}
	_switch_pack(pack as Dictionary)
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _apply_import_pack(action: Dictionary) -> Dictionary:
	var path: Variant = action.get("path", null)
	if not (path is String) or (path as String).is_empty():
		return _step_error("import_pack.path: required string")
	var loaded := load_pack_file(path as String)
	if not loaded["ok"]:
		var errors: PackedStringArray = loaded["errors"]
		return {"ok": false, "errors": errors, "state": get_state()}
	_switch_pack(loaded["pack"])
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _apply_export_pack(action: Dictionary) -> Dictionary:
	var path: Variant = action.get("path", null)
	if not (path is String) or (path as String).is_empty():
		return _step_error("export_pack.path: required string")
	var result := export_pack(path as String)
	if not result["ok"]:
		var errors: PackedStringArray = result["errors"]
		return {"ok": false, "errors": errors, "state": get_state()}
	_log_chrome("pack_exported", [_state["turn"], path])
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _switch_pack(pack: Dictionary) -> void:
	_pack = pack.duplicate(true)
	_state["pack_id"] = pack["id"]
	var name: Variant = _locale().get("name", pack["id"])
	_log_chrome("pack_switched", [_state["turn"], str(name)])


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


## bodyClass picks one of the known palettes (an enum, not a free string).
func _validate_body_class(pack: Dictionary, errors: PackedStringArray) -> void:
	var body_class: Variant = pack.get("bodyClass", null)
	if not (body_class is String) or (body_class as String).is_empty():
		errors.append("pack.bodyClass: required string")
		return
	if not PACK_PALETTES.has(body_class):
		errors.append("pack.bodyClass: unknown palette %s (known: %s)" % [body_class, ", ".join(PACK_PALETTES)])


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


## Contract v1 tightening: all three languages are required — no fallback —
## and every locale must cover the full skeleton: name/tagline, 3 factions,
## every roster/skill/enemy/enemy-action/quest id, flavor arrays and the war
## report template with its placeholders, and the part text.
func _validate_text(pack: Dictionary, errors: PackedStringArray) -> void:
	var text: Variant = pack.get("text", null)
	if not (text is Dictionary):
		errors.append("pack.text: required object")
		return
	for lang in ["en", "zh", "ja"]:
		var locale: Variant = (text as Dictionary).get(lang, null)
		if not (locale is Dictionary):
			errors.append("pack.text.%s: required object" % [lang])
			continue
		var loc := locale as Dictionary
		for field in ["name", "tagline"]:
			var value: Variant = loc.get(field, null)
			if not (value is String) or (value as String).is_empty():
				errors.append("pack.text.%s.%s: required non-empty string" % [lang, field])
		# factions: exactly 3 entries, each with name + icon.
		var factions: Variant = loc.get("factions", null)
		if not (factions is Array) or (factions as Array).size() != 3:
			errors.append("pack.text.%s.factions: required array of exactly 3 entries" % [lang])
		else:
			for i in (factions as Array).size():
				if not _has_name_and_icon(factions[i]):
					errors.append("pack.text.%s.factions[%d]: required object with name and icon strings" % [lang, i])
		# cards: every roster id needs name + icon.
		var cards: Variant = loc.get("cards", null)
		if not (cards is Dictionary):
			errors.append("pack.text.%s.cards: required object" % [lang])
		else:
			for id in _roster_ids():
				if not _has_name_and_icon((cards as Dictionary).get(id, null)):
					errors.append("pack.text.%s.cards.%s: required object with name and icon strings" % [lang, id])
		# skillNames: every skill id needs a non-empty name.
		var skill_names: Variant = loc.get("skillNames", null)
		if not (skill_names is Dictionary):
			errors.append("pack.text.%s.skillNames: required object" % [lang])
		else:
			for id in SKILLS:
				if not _nonempty_string((skill_names as Dictionary).get(id, null)):
					errors.append("pack.text.%s.skillNames.%s: required non-empty string" % [lang, id])
		# enemies: every enemy id needs name + icon.
		var enemies: Variant = loc.get("enemies", null)
		if not (enemies is Dictionary):
			errors.append("pack.text.%s.enemies: required object" % [lang])
		else:
			for id in ENEMIES:
				if not _has_name_and_icon((enemies as Dictionary).get(id, null)):
					errors.append("pack.text.%s.enemies.%s: required object with name and icon strings" % [lang, id])
		# enemyActions: all three ids need a non-empty name.
		var enemy_actions: Variant = loc.get("enemyActions", null)
		if not (enemy_actions is Dictionary):
			errors.append("pack.text.%s.enemyActions: required object" % [lang])
		else:
			for id in ENEMY_SKILLS:
				if not _nonempty_string((enemy_actions as Dictionary).get(id, null)):
					errors.append("pack.text.%s.enemyActions.%s: required non-empty string" % [lang, id])
		# questTitles: every quest key needs a non-empty title.
		var quest_titles: Variant = loc.get("questTitles", null)
		if not (quest_titles is Dictionary):
			errors.append("pack.text.%s.questTitles: required object" % [lang])
		else:
			for key in _quest_keys():
				if not _nonempty_string((quest_titles as Dictionary).get(key, null)):
					errors.append("pack.text.%s.questTitles.%s: required non-empty string" % [lang, key])
		# flavor: 1+ non-empty string lines per array, and the war report
		# template must carry all three placeholders.
		var flavor: Variant = loc.get("flavor", null)
		if not (flavor is Dictionary):
			errors.append("pack.text.%s.flavor: required object" % [lang])
		else:
			var flav := flavor as Dictionary
			for key in ["ev_exp", "ev_gains", "base"]:
				if not _nonempty_string_array(flav.get(key, null)):
					errors.append("pack.text.%s.flavor.%s: required array of at least 1 non-empty string" % [lang, key])
			var tpl: Variant = flav.get("reportTpl", null)
			if not (tpl is String) or not _has_report_placeholders(tpl as String):
				errors.append("pack.text.%s.flavor.reportTpl: required string containing {turn} {loss} {left}" % [lang])
		# parts: text for every part the pack can enable.
		var parts: Variant = loc.get("parts", null)
		if not (parts is Dictionary):
			errors.append("pack.text.%s.parts: required object" % [lang])
		else:
			var fatigue: Variant = (parts as Dictionary).get("fatigue", null)
			if not _has_name_and_icon(fatigue):
				errors.append("pack.text.%s.parts.fatigue: required object with name and icon strings" % [lang])


## Roster ids in fixed party order (deterministic reason ordering).
func _roster_ids() -> Array:
	var ids: Array = []
	for leader in LEADERS:
		ids.append(leader["id"])
	return ids


## Quest keys from the skeleton data (deterministic reason ordering).
func _quest_keys() -> Array:
	var keys: Array = []
	for pool in QUESTS.values():
		for quest in pool:
			keys.append(quest["key"])
	return keys


func _nonempty_string(value: Variant) -> bool:
	return value is String and not (value as String).is_empty()


func _has_name_and_icon(value: Variant) -> bool:
	return value is Dictionary \
		and _nonempty_string((value as Dictionary).get("name", null)) \
		and _nonempty_string((value as Dictionary).get("icon", null))


func _nonempty_string_array(value: Variant) -> bool:
	if not (value is Array) or (value as Array).is_empty():
		return false
	for entry in value:
		if not _nonempty_string(entry):
			return false
	return true


func _has_report_placeholders(tpl: String) -> bool:
	return tpl.contains("{turn}") and tpl.contains("{loss}") and tpl.contains("{left}")


# --- Action implementations ----------------------------------------------------
# Each returns a result; on failure state is untouched. Log lines are part of
# state so replays pin exact wording.

func _step_error(message: String) -> Dictionary:
	var errors := PackedStringArray()
	errors.append(message)
	var state := get_state()
	return {"ok": false, "errors": errors, "state": state}


## End the battle round: resolve the announced enemy action, or — once the
## battle is over — close the battle. A won battle finishes the quest node
## (the step advances, possibly completing the quest); a lost one abandons
## the quest and moves the phase along.
func _apply_end_turn() -> Dictionary:
	var battle: Variant = _state["battle"]
	if not (battle is Dictionary):
		return _step_error("end_turn: no active battle")
	var b := battle as Dictionary
	if b["over"] != "":
		# The result state (over: "win"/"lose") stays observable until the
		# next end turn closes the battle.
		var result: String = b["over"]
		_state["battle"] = null
		_log_chrome("battle_over", [_state["turn"]])
		if _state["quest"] != null:
			if result == "win":
				_finish_node()
			else:
				_state["quest"] = null
				_state["chest"] = null
				_state["phase"] = _state["phase"] + 1
				if _state["phase"] == PHASE_BASE:
					_set_base_options()
				_log_chrome("quest_abandoned", [_state["turn"]])
	else:
		_apply_battle_end_turn(b)
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _log(line: String) -> void:
	var log: Array = _state["log"]
	log.append(line)


## Log through the chrome template for the current language: `_log_chrome(key)`
## for template-free lines, `_log_chrome(key, args)` to format. Template args
## are positional; a line with no placeholders takes no args.
func _log_chrome(key: String, args: Array = []) -> void:
	var tpl: String = ChromeText.CHROME[_lang]["log"][key]
	if args.is_empty():
		_log(tpl)
	else:
		_log(tpl % args)


## Chrome vocabulary (ticket 05): switch the UI language mid-run. Touches only
## the chrome locale — session state is preserved bit-for-bit, and every later
## chrome log line and pack-text lookup renders in the new language.
func _apply_set_language(action: Dictionary) -> Dictionary:
	var lang: Variant = action.get("lang", null)
	if not (lang is String) or not ChromeText.LANGUAGES.has(lang):
		return _step_error("set_language.lang: invalid language %s (known: %s)" % [lang, ", ".join(ChromeText.LANGUAGES)])
	_lang = lang
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}
