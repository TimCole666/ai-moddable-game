extends Node

## View smoke: instantiate the real main scene headless and drive a bot
## through every view branch — quest start cards, branch cards, battle cards
## (portraits, HP bars, skill grids, the announced banner), chest, base,
## war report, the next turn, and a pack switch to the art-less fallback pack
## and back. Exits 0 when no step fails, every render survives, and the bot
## reaches turn 2.

const MAIN_SCENE := "res://ui/main.tscn"
const TURN_2 := 2


func _ready() -> void:
	var main: Control = (load(MAIN_SCENE) as PackedScene).instantiate()
	add_child(main)
	await get_tree().process_frame
	var failures := _drive(main)
	if failures == 0:
		print("VIEW SMOKE OK — every branch rendered, turn %d reached" % [TURN_2])
	get_tree().quit(failures)


func _drive(main: Control) -> int:
	# prepA: [b_g|chest], [ev_exp|ev_gains], [gains|heal] — left branch each.
	# opA:   [b_g|a_b], [chest|ev_gains], [heal|b_s], [b_boss|chest] — take
	# the battle, then the chest, dodging the boss. Chest nodes need a
	# choose to open, then a chest_pick to resolve.
	var ok := true
	ok = _step(main, {"type": "start_quest", "pool": "prep", "idx": 0}) and ok
	ok = _step(main, {"type": "choose", "option": 0}) and ok
	ok = _fight(main) == 0 and ok
	ok = _step(main, {"type": "choose", "option": 0}) and ok
	ok = _step(main, {"type": "choose", "option": 0}) and ok
	ok = _step(main, {"type": "start_quest", "pool": "operation", "idx": 0}) and ok
	ok = _step(main, {"type": "choose", "option": 0}) and ok
	ok = _fight(main) == 0 and ok
	ok = _step(main, {"type": "choose", "option": 0}) and ok
	ok = _step(main, _pick("chest_pick")) and ok
	ok = _step(main, {"type": "choose", "option": 0}) and ok
	ok = _step(main, {"type": "choose", "option": 1}) and ok
	ok = _step(main, _pick("chest_pick")) and ok
	ok = _step(main, _pick("base_pick")) and ok
	ok = _step(main, {"type": "end_phase"}) and ok
	ok = _step(main, {"type": "end_phase"}) and ok
	# The art-less fallback pack must render (emoji + accent), then switch back.
	ok = _step(main, {"type": "import_pack", "path": "res://engine/packs/ironroad.json"}) and ok
	ok = _step(main, {"type": "import_pack", "path": "res://engine/builtin_pack.json"}) and ok
	var state := GameEngine.get_state()
	if state["turn"] != TURN_2 or state["phase"] != 0:
		printerr("view smoke: expected turn %d phase 0, got turn %d phase %d" % [TURN_2, state["turn"], state["phase"]])
		ok = false
	return 0 if ok else 1


func _step(main: Control, action: Dictionary) -> bool:
	if action.is_empty():
		printerr("view smoke: no action available for the next step")
		return false
	var result := GameEngine.step(action)
	if not result["ok"]:
		printerr("view smoke: step failed: %s → %s" % [str(action), str(result["errors"])])
		return false
	main._render()
	return true


func _pick(type: String) -> Dictionary:
	for entry in GameEngine.available_actions():
		if (entry["action"] as Dictionary)["type"] == type:
			return entry["action"]
	return {}


## Fight the active battle with a greedy bot: any skill while AP lasts, then
## end the turn; a closed battle (won — the node is finished) ends the fight.
## Bounded so a rules bug cannot hang CI.
func _fight(main: Control) -> int:
	for round_guard in 40:
		var state := GameEngine.get_state()
		var battle: Variant = state["battle"]
		if not (battle is Dictionary):
			return 0
		if battle["over"] != "":
			if not _step(main, {"type": "end_turn"}):
				return 1
			continue
		var action := _pick("skill")
		if action.is_empty():
			action = _pick("end_turn")
		if not _step(main, action):
			return 1
	printerr("view smoke: battle did not end within the guard")
	return 1
