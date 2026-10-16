extends ReplayBase
## Ticket 09 — Adult Content gate (ADR-0005): the web export serves the
## all-ages experience only. Pins, through the Engine seam:
##   1. on this headless desktop target the flag defaults to true (adult
##      flavor lines play, so all 29 earlier replays stay pinned);
##   2. with the gate off, every flavor surface (base quiet evening here)
##      logs the trilingual all-ages line instead of the pack's adult text.
## The flag itself is platform state, not session state — it is asserted via
## checks() and the log, not the bit-for-bit state diff. The session under
## the gate is still pinned bit-for-bit.

var _default_flag := true
var _flavor_seen := ""

const ALL_AGES_EN := "the squad shares a quiet, wholesome evening"


func replay_name() -> String:
	return "adult_gate"


func actions() -> Array:
	return [
		# Desktop-side pin: the platform-derived default on this target.
		Callable(self, "capture_default_flag"),
		# Simulate the web platform deterministically (no env, no wall clock).
		Callable(self, "gate_off"),
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_END_PHASE},
		{"type": EngineCore.ACTION_BASE_PICK, "option": 0},
		# Restore the desktop default for the rest of the suite run (the
		# autoload is shared across replays).
		Callable(self, "gate_on"),
	]


func capture_default_flag() -> void:
	_default_flag = GameEngine.adult_allowed()


func gate_off() -> void:
	GameEngine.set_adult_allowed(false)


func gate_on() -> void:
	GameEngine.set_adult_allowed(true)


func checks() -> PackedStringArray:
	var problems := PackedStringArray()
	if not _default_flag:
		problems.append("adult_allowed: expected the desktop/headless default true, got false")
	if _flavor_seen.is_empty():
		_flavor_seen = _last_base_quiet_flavor()
	if not _flavor_seen.contains(ALL_AGES_EN):
		problems.append("base_quiet flavor: expected the all-ages line under the gate, got: %s" % [_flavor_seen])
	for line in GameEngine.get_builtin_pack()["text"]["en"]["flavor"]["base"]:
		if _flavor_seen.contains(line):
			problems.append("base_quiet flavor: adult pack line leaked under the gate: %s" % [line])
	return problems


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": null,
	"chest": null,
	"collection": {
		"archer": {
			"count": 1,
			"exp": 0
		},
		"healer": {
			"count": 1,
			"exp": 0
		},
		"hero": {
			"count": 1,
			"exp": 2
		},
		"mage": {
			"count": 1,
			"exp": 0
		},
		"striker": {
			"count": 1,
			"exp": 0
		},
		"tank": {
			"count": 1,
			"exp": 0
		}
	},
	"ended": "",
	"fatigue": 0,
	"gains_total": 0,
	"gains_turn": 0,
	"log": [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
		"Turn 1: quiet evening with Captain Maren Stormbite: the squad shares a quiet, wholesome evening (+2 EXP)"
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 2,
	"quest": null,
	"realm": 100,
	"tickets": 0,
	"turn": 1
}

func _last_base_quiet_flavor() -> String:
	for line in GameEngine.get_state()["log"]:
		if line.contains(ALL_AGES_EN):
			return line
	return ""
