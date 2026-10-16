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
## Determinism contract: no wall-clock time, no randomness — combat variance
## comes from a fixed integer jitter formula, never from a RNG. State changes
## only via new_game() and step(); a failed call leaves state untouched.

# --- Fixed skeleton constants (mechanics, not content) -----------------------
# Content strings live in theme packs, never here. Skill effects, leader and
# enemy stats, and plans are rules; every name/icon for them is pack text
# (text.<lang>.skillNames / .cards / .enemies / .enemyActions).

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
## their two skill bindings each. Squad formation from the card collection
## (auto-formation, duplicates, level-ups) arrives with the turn cycle; until
## then the battle core runs this fixed party.
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

const BATTLE_START_AP := 4
const BATTLE_AP_MAX := 6
const BATTLE_AP_REGEN := 2
const BATTLE_ROUND_CAP := 10
const COMBO_BONUS := 0.1
const WEAKNESS_MULT := 1.5
const GUARD_REDUCTION := 0.7
const ENEMY_SCALE_PER_TURN := 0.15

const START_TURN := 1

const ACTION_START_BATTLE := "start_battle"
const ACTION_SKILL := "skill"
const ACTION_END_TURN := "end_turn"

const BUILTIN_PACK_PATH := "res://engine/builtin_pack.json"

var _state: Dictionary = {}
var _pack: Dictionary = {}


func _ready() -> void:
	_state = {}
	_pack = {}


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
	_pack = pack.duplicate(true)
	_state = {
		"pack_id": pack["id"],
		"turn": START_TURN,
		"log": [],
		"battle": null,
	}
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


## Apply one scripted action to the session. Returns
## {ok: bool, errors: PackedStringArray, state: Dictionary} where state is the
## post-step snapshot on success and the untouched snapshot on failure. The
## action vocabulary grows in later tickets without changing this signature.
##
## Battle vocabulary (ticket 02):
##   {"type": "start_battle", "enemy": <skeleton enemy id>}
##   {"type": "skill", "leader": <leader index>, "slot": <skill slot index>}
##   {"type": "end_turn"}
## end_turn outside a battle advances the session turn; during a battle it
## resolves the enemy phase (announced in state.battle.next_action); once the
## battle is over ("win"/"lose" in state.battle.over) it clears the battle.
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


# --- Battle core ---------------------------------------------------------------

func _apply_start_battle(action: Dictionary) -> Dictionary:
	if _state["battle"] != null:
		return _step_error("start_battle: battle already active")
	var enemy_id: Variant = action.get("enemy", null)
	if not (enemy_id is String) or not ENEMIES.has(enemy_id):
		return _step_error("start_battle: unknown enemy %s" % [enemy_id])
	var def: Dictionary = ENEMIES[enemy_id]
	# Enemies scale with the session turn so later fights bite harder.
	var scale: float = 1.0 + ENEMY_SCALE_PER_TURN * (_state["turn"] - 1)
	var hp := roundi(def["hp"] * scale)
	var at := roundi(def["at"] * scale)
	var party_hp: Array = []
	for leader in LEADERS:
		party_hp.append(leader["max_hp"])
	_state["battle"] = {
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
	_log("Turn %d: battle vs %s" % [_state["turn"], _enemy_name(enemy_id)])
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
			_log("Round %d: %s uses %s: party braces (-30%% incoming this round)" % [b["round"], leader_label, skill_label])
		"interference":
			b["hexed"] = true
			_log("Round %d: %s uses %s: one enemy action this round will be cancelled" % [b["round"], leader_label, skill_label])
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
	_log("Round %d: %s uses %s for %d damage (enemy HP %d)" % [b["round"], leader_label, skill_label, total, b["enemy_hp"]])
	if b["enemy_hp"] <= 0:
		b["over"] = "win"
		_log("Round %d: victory!" % [b["round"]])


## Heals top up every standing leader, capped at each one's max HP.
func _apply_heal(b: Dictionary, leader_def: Dictionary, sk: Dictionary, leader_idx: int, slot: int, leader_label: String, skill_label: String) -> void:
	var heal := roundi(leader_def["at"] * sk["mult"] * _jitter(b["round"], leader_idx, slot, 0))
	var party_hp: Array = b["party_hp"]
	for i in party_hp.size():
		if party_hp[i] > 0:
			party_hp[i] = mini(LEADERS[i]["max_hp"], party_hp[i] + heal)
	_log("Round %d: %s uses %s: all standing leaders +%d HP" % [b["round"], leader_label, skill_label, heal])


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
		_log("Round %d: the squad withdraws (stalemate)" % [b["round"]])
		return
	var action_id: String = plan[(b["round"] - 1) % plan.size()]
	if b["hexed"] and not b["boss"]:
		b["hexed"] = false
		_log("Round %d: the hex cancels %s's %s!" % [b["round"], _enemy_name(b["enemy"]), _enemy_action_name(action_id)])
	else:
		var alive: Array = []
		for i in b["party_hp"].size():
			if b["party_hp"][i] > 0:
				alive.append(i)
		if alive.is_empty():
			b["over"] = "lose"
			_log("Round %d: defeat!" % [b["round"]])
			return
		var sk: Dictionary = ENEMY_SKILLS[action_id]
		var guard_mult: float = GUARD_REDUCTION if b["guard"] else 1.0
		var dmg := roundi(b["enemy_at"] * sk["mult"] * _jitter(b["round"], 0, 0, 1) * guard_mult)
		var target: int = alive[b["round"] % alive.size()]
		b["party_hp"][target] = maxi(0, b["party_hp"][target] - dmg)
		_log("Round %d: %s uses %s for %d damage on %s (HP %d)" % [
			b["round"], _enemy_name(b["enemy"]), _enemy_action_name(action_id),
			dmg, _card_name(LEADERS[target]["id"]), b["party_hp"][target],
		])
		var any_alive := false
		for hp in b["party_hp"]:
			if hp > 0:
				any_alive = true
		if not any_alive:
			b["over"] = "lose"
			_log("Round %d: defeat!" % [b["round"]])
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
# Battle log lines carry pack names. Ticket 04 enforces these fields in the
# contract; until then a missing name falls back to the skeleton id.

func _locale() -> Dictionary:
	var text: Variant = _pack.get("text", {})
	if text is Dictionary:
		var en: Variant = (text as Dictionary).get("en", {})
		if en is Dictionary:
			return en
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


func _apply_end_turn() -> Dictionary:
	var battle: Variant = _state["battle"]
	if battle is Dictionary:
		var b := battle as Dictionary
		if b["over"] != "":
			# The result state (over: "win"/"lose") stays observable until the
			# next end turn clears the battle.
			_state["battle"] = null
			_log("Turn %d: battle over" % [_state["turn"]])
		else:
			_apply_battle_end_turn(b)
	else:
		_state["turn"] = _state["turn"] + 1
		_log("Turn %d: end turn" % [_state["turn"]])
	return {"ok": true, "errors": PackedStringArray(), "state": get_state()}


func _log(line: String) -> void:
	var log: Array = _state["log"]
	log.append(line)
