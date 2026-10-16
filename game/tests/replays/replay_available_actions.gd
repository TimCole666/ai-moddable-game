extends ReplayBase

## available_actions(): the Engine owns legality, the view renders this list
## as buttons. Pinned at the seam in four situations — fresh boot (every
## quest of both pools + end_phase), an active quest (two branch choices +
## retire, NO phase advance), an open battle (affordable skills + end_turn,
## nothing else), and after retiring mid-battle (operation-phase start
## quests). The scripted run retires out of the battle so the final state
## stays hand-computable; the mid-run snapshots are the point.

var _fresh: Array = []
var _in_quest: Array = []
var _in_battle: Array = []
var _after_retire: Array = []


func replay_name() -> String:
	return "available_actions"


func actions() -> Array:
	return [
		Callable(self, "_snap_fresh"),
		{"type": "start_quest", "pool": "prep", "idx": 0},
		Callable(self, "_snap_in_quest"),
		{"type": "choose", "option": 0},
		Callable(self, "_snap_in_battle"),
		{"type": "retire"},
		Callable(self, "_snap_after_retire"),
	]


func _snap_fresh() -> void:
	_fresh = GameEngine.available_actions()


func _snap_in_quest() -> void:
	_in_quest = GameEngine.available_actions()


func _snap_in_battle() -> void:
	_in_battle = GameEngine.available_actions()


func _snap_after_retire() -> void:
	_after_retire = GameEngine.available_actions()


func _types(actions: Array) -> Array:
	var types: Array = []
	for entry in actions:
		types.append((entry["action"] as Dictionary)["type"])
	return types


func _labels_present(actions: Array) -> bool:
	for entry in actions:
		if (entry["label"] as String).strip_edges().is_empty():
			return false
	return true


func checks() -> PackedStringArray:
	var problems := PackedStringArray()
	# Fresh boot (preparation phase): every quest of both pools + end_phase.
	if _types(_fresh) != ["start_quest", "start_quest", "start_quest", "start_quest", "end_phase"]:
		problems.append("fresh actions mismatch: %s" % [str(_types(_fresh))])
	# Active quest: exactly two branch choices + retire; no phase advance.
	if _types(_in_quest) != ["choose", "choose", "retire"]:
		problems.append("in-quest actions mismatch: %s" % [str(_types(_in_quest))])
	# Open battle: 12 affordable skill bindings at starting AP 4 (heavy costs
	# exactly 4, every other skill less) + end_turn; no quest/phase actions.
	var battle_types := _types(_in_battle)
	if battle_types.size() != 13:
		problems.append("battle actions: expected 13 (12 skills + end_turn), got %d: %s" % [battle_types.size(), str(battle_types)])
	if not ("end_turn" in battle_types):
		problems.append("battle actions: end_turn missing")
	for kind in ["start_quest", "end_phase", "choose"]:
		if kind in battle_types:
			problems.append("battle actions: %s must not be offered mid-battle" % [kind])
	for entry in _in_battle:
		var action: Dictionary = entry["action"]
		if action["type"] == "skill" and not (action["leader"] is int and action["slot"] is int):
			problems.append("battle skill action malformed: %s" % [str(action)])
	# After retiring mid-battle: the operation phase's start quests + end_phase.
	if _types(_after_retire) != ["start_quest", "start_quest", "start_quest", "start_quest", "end_phase"]:
		problems.append("after-retire actions mismatch: %s" % [str(_types(_after_retire))])
	# Every label everywhere is a non-empty chrome string.
	for snap in [_fresh, _in_quest, _in_battle, _after_retire]:
		if not _labels_present(snap):
			problems.append("empty action label in %s" % [str(_types(snap))])
	return problems


func expected_state() -> Dictionary:
	# Hand-computable: the run retires out of the battle before any end_turn,
	# so the log is exactly onboarding + quest_started + battle_start +
	# quest_retired, and the retire advanced the phase to operation (1).
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
		"log": [
			"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
			"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
			"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
			"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
			"Turn 1: Preparation quest started: Provisions Ashore.",
			"Turn 1: battle vs Press-Gang Hand",
			"Turn 1: quest retired (no rewards).",
		],
		"medals": 0,
		"pack_id": "builtin",
		"phase": 1,
		"quest": null,
		"realm": 100,
		"tickets": 0,
		"turn": 1,
	}
