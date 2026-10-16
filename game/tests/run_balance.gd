extends Node

## Ticket 10: deterministic balance simulation at the Engine seam. Plays
## scripted strategies (no RNG, no wall clock) through the full campaign arc
## and prints per-strategy outcomes so tuning decisions have evidence.
##
## Run:  godot --headless --path game res://tests/run_balance.tscn
##
## Every strategy drives the same public step() vocabulary; battle play reads
## only get_state() (AP, enemy HP, party HP) and quest choices read only the
## EngineCore skeleton constants. Nothing here touches Engine internals — the
## same evidence a player could gather from the UI.

## Node kinds a branch choice can rank: "battle" and "auto" (skirmish),
## "chest", "heal", "gains" (war supplies), "medal", "ev_exp", "ev_gains".
const KIND_BATTLE := "battle"
const KIND_AUTO := "auto"
const KIND_CHEST := "chest"
const KIND_HEAL := "heal"
const KIND_GAINS := "gains"
const KIND_MEDAL := "medal"
const KIND_EV_EXP := "ev_exp"
const KIND_EV_GAINS := "ev_gains"


func _ready() -> void:
	print("=== BALANCE SIM (builtin pack unless noted) ===")
	var strategies := [
		{
			"name": "supply_disciplined",
			"desc": "quests every turn, war-supplies-first picks, efficient battles",
			"questing": true, "prep_idx": 0, "op_idx": 0,
			"prefs": [KIND_GAINS, KIND_EV_GAINS, KIND_AUTO, KIND_BATTLE, KIND_HEAL, KIND_CHEST, KIND_EV_EXP, KIND_MEDAL],
			"battle": "efficient", "base": "logistics",
		},
		{
			"name": "supply_no_fatigue",
			"desc": "same play, but the Fatigue part is disabled in the pack copy",
			"questing": true, "prep_idx": 0, "op_idx": 0,
			"prefs": [KIND_GAINS, KIND_EV_GAINS, KIND_AUTO, KIND_BATTLE, KIND_HEAL, KIND_CHEST, KIND_EV_EXP, KIND_MEDAL],
			"battle": "efficient", "base": "logistics", "pack": _no_fatigue_pack(),
		},
		{
			"name": "blitz_looter",
			"desc": "quests every turn but chests/battles first, zero war supplies",
			"questing": true, "prep_idx": 0, "op_idx": 0,
			"prefs": [KIND_CHEST, KIND_BATTLE, KIND_AUTO, KIND_EV_EXP, KIND_HEAL, KIND_MEDAL, KIND_EV_GAINS, KIND_GAINS],
			"battle": "efficient", "base": "rest",
		},
		{
			"name": "branch_b_disciplined",
			"desc": "quests every turn on the B branches, supplies where B offers them",
			"questing": true, "prep_idx": 1, "op_idx": 1,
			"prefs": [KIND_GAINS, KIND_EV_GAINS, KIND_MEDAL, KIND_AUTO, KIND_HEAL, KIND_CHEST, KIND_BATTLE, KIND_EV_EXP],
			"battle": "efficient", "base": "logistics",
		},
		{
			"name": "passive",
			"desc": "never starts a quest; phases only, quiet evenings",
			"questing": false, "prep_idx": 0, "op_idx": 0,
			"prefs": [],
			"battle": "efficient", "base": "rest",
		},
		{
			"name": "ap_hoarder",
			"desc": "quests like a supply player but hoards battle AP (brace only)",
			"questing": true, "prep_idx": 0, "op_idx": 0,
			"prefs": [KIND_GAINS, KIND_EV_GAINS, KIND_AUTO, KIND_BATTLE, KIND_HEAL, KIND_CHEST, KIND_EV_EXP, KIND_MEDAL],
			"battle": "hoard", "base": "logistics",
		},
	]
	for s in strategies:
		var pack: Dictionary = s.get("pack", {})
		if pack.is_empty():
			pack = GameEngine.get_builtin_pack()
		_report(s, _play(s, pack))
	_boss_probe()
	get_tree().quit(0)


## A copy of the builtin pack with the Fatigue part flipped off, so the sim
## can price what the pack's fatigue (threshold 2, apPenalty 1) costs.
func _no_fatigue_pack() -> Dictionary:
	var pack := GameEngine.get_builtin_pack()
	pack["parts"]["fatigue"]["enabled"] = false
	return pack


func _report(s: Dictionary, out: Dictionary) -> void:
	print("")
	print("STRATEGY %s — %s" % [s["name"], s["desc"]])
	print("  ended=%s turn=%d realm_traj=%s" % [
		out["ended"], out["turns"], str(out["realm_traj"]),
	])
	print("  realm_final=%d medals=%d squad_level=%d tickets_left=%d fatigue=%d collection_exp=%d" % [
		out["realm"], out["medals"], out["medals"] / 2, out["tickets"], out["fatigue"], out["collection_exp"],
	])
	print("  battles: %d won, %d lost, %d withdrawn" % [out["won"], out["lost"], out["withdrawn"]])


# --- One strategy playthrough ---------------------------------------------------

## Play a full campaign with the given strategy under the given pack. Returns
## a summary Dictionary of observable outcomes.
func _play(s: Dictionary, pack: Dictionary) -> Dictionary:
	var boot := GameEngine.new_game(pack, "en")
	if not boot["ok"]:
		push_error("sim: pack rejected: %s" % [boot["errors"]])
		get_tree().quit(1)
	var run: Dictionary = s.duplicate(true)
	run["prep_done"] = false
	run["op_done"] = false
	var traj: Array = []
	var guard := 0
	var cur_turn := 0
	while GameEngine.get_state()["ended"] == "" and guard < 5000:
		guard += 1
		var st := GameEngine.get_state()
		if int(st["turn"]) != cur_turn:
			# Quests restart every turn: reset the per-turn start flags.
			cur_turn = int(st["turn"])
			run["prep_done"] = false
			run["op_done"] = false
		match int(st["phase"]):
			EngineCore.PHASE_PREPARE, EngineCore.PHASE_OPERATION:
				_advance_phase(run)
			EngineCore.PHASE_BASE:
				if st["base_options"] != null:
					_do({"type": EngineCore.ACTION_BASE_PICK, "option": 0 if run["base"] == "rest" else 1})
				else:
					_do({"type": EngineCore.ACTION_END_PHASE})
			EngineCore.PHASE_WAR_REPORT:
				_do({"type": EngineCore.ACTION_END_PHASE})
				st = GameEngine.get_state()
				if st["ended"] == "":
					traj.append(st["realm"])
	var final := GameEngine.get_state()
	var log: Array = final["log"]
	return {
		"ended": final["ended"],
		"turns": final["turn"],
		"realm_traj": traj,
		"realm": final["realm"],
		"medals": final["medals"],
		"tickets": final["tickets"],
		"fatigue": final["fatigue"],
		"collection_exp": _total_exp(final["collection"]),
		"won": _count_round_line(log, "victory!"),
		"lost": _count_round_line(log, "defeat!"),
		"withdrawn": _count_round_line(log, "withdraws (stalemate)"),
	}


func _advance_phase(s: Dictionary) -> void:
	var st := GameEngine.get_state()
	if st["battle"] != null:
		_battle_round(s)
		return
	if st["chest"] != null:
		_do({"type": EngineCore.ACTION_CHEST_PICK, "idx": 0})
		return
	if st["quest"] != null:
		var quest: Dictionary = st["quest"]
		var option := _pick_option(s, quest["pool"], quest["idx"], quest["step"])
		_do({"type": EngineCore.ACTION_CHOOSE, "option": option})
		return
	if s["questing"]:
		if st["phase"] == EngineCore.PHASE_PREPARE and not s["prep_done"]:
			s["prep_done"] = true
			_do({"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": s["prep_idx"]})
			return
		if st["phase"] == EngineCore.PHASE_OPERATION and not s["op_done"]:
			s["op_done"] = true
			_do({"type": EngineCore.ACTION_START_QUEST, "pool": "operation", "idx": s["op_idx"]})
			return
	_do({"type": EngineCore.ACTION_END_PHASE})


## Rank the two branch options by the strategy's node-kind preference order.
func _pick_option(s: Dictionary, pool: String, idx: int, step: int) -> int:
	var nodes: Array = EngineCore.QUESTS[pool][idx]["steps"][step]
	var li: int = (s["prefs"] as Array).find(_kind_of(nodes[0]))
	var ri: int = (s["prefs"] as Array).find(_kind_of(nodes[1]))
	if ri < li:
		return 1
	return 0


func _kind_of(node_id: String) -> String:
	var node: Dictionary = EngineCore.QUEST_NODES[node_id]
	if node["t"] == "event":
		return "ev_" + str(node["effect"])
	return str(node["t"])


# --- Battle play ----------------------------------------------------------------

## Play one decision of the active battle (called when state.battle != null).
## "efficient": best damage per AP from standing leaders, pass when nothing
## affordable. "hoard": brace when a guard is affordable, never attack. Either
## way, a battle that is already over is closed with end_turn.
func _battle_round(s: Dictionary) -> void:
	var b: Dictionary = GameEngine.get_state()["battle"]
	if b["over"] != "":
		_do({"type": EngineCore.ACTION_END_TURN})
		return
	if s["battle"] == "hoard":
		var brace := _find_support(b)
		if brace.is_empty():
			_do({"type": EngineCore.ACTION_END_TURN})
		else:
			_do({"type": EngineCore.ACTION_SKILL, "leader": brace["leader"], "slot": brace["slot"]})
		return
	# Efficient: maximize expected damage per AP from the announced plan.
	var weakness: String = EngineCore.ENEMIES[b["enemy"]].get("weakness", "")
	var best := {}
	var best_score := -1.0
	for leader in EngineCore.LEADERS.size():
		if b["party_hp"][leader] <= 0:
			continue
		var bindings: Array = EngineCore.LEADERS[leader]["skills"]
		for slot in bindings.size():
			var bind: Dictionary = bindings[slot]
			var sk: Dictionary = EngineCore.SKILLS[bind["id"]]
			var kind: String = sk["kind"]
			if int(sk["ap"]) > int(b["ap"]) or (kind != "attack" and kind != "magic"):
				continue
			var mult := float(sk["mult"]) * float(int(sk.get("hits", 1)))
			if weakness != "" and str(bind.get("attr", "")) == weakness:
				mult *= EngineCore.WEAKNESS_MULT
			var score := float(EngineCore.LEADERS[leader]["at"]) * mult / float(sk["ap"])
			if score > best_score:
				best_score = score
				best = {"leader": leader, "slot": slot}
	if best.is_empty():
		_do({"type": EngineCore.ACTION_END_TURN})
	else:
		_do({"type": EngineCore.ACTION_SKILL, "leader": best["leader"], "slot": best["slot"]})


## Find the first affordable support (brace) skill, standing leaders only.
func _find_support(b: Dictionary) -> Dictionary:
	for leader in EngineCore.LEADERS.size():
		if b["party_hp"][leader] <= 0:
			continue
		var bindings: Array = EngineCore.LEADERS[leader]["skills"]
		for slot in bindings.size():
			var bind: Dictionary = bindings[slot]
			if int(EngineCore.SKILLS[bind["id"]]["ap"]) > int(b["ap"]):
				continue
			if EngineCore.SKILLS[bind["id"]]["kind"] == "support":
				return {"leader": leader, "slot": slot}
	return {}


# --- Boss probe -------------------------------------------------------------------

## When is the boss (opA's optional b_boss node) actually beatable? For each
## session turn: pass passively to reach that turn, then rush prepA + opA and
## take the boss branch with efficient play. Prints one line per turn.
func _boss_probe() -> void:
	print("")
	print("=== BOSS PROBE (opA b_boss branch, efficient play) ===")
	for target in range(1, 7):
		var boot := GameEngine.new_game(GameEngine.get_builtin_pack(), "en")
		if not boot["ok"]:
			push_error("sim: pack rejected: %s" % [boot["errors"]])
			get_tree().quit(1)
		while GameEngine.get_state()["turn"] < target and GameEngine.get_state()["ended"] == "":
			_passive_turn()
		if GameEngine.get_state()["ended"] != "":
			print("  turn %d: unreachable (game ended earlier)" % [target])
			continue
		# Rush: prepA (fight, event, supplies) then opA to the boss branch.
		_do({"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0})
		_do({"type": EngineCore.ACTION_CHOOSE, "option": 0})
		_fight_to_completion("efficient")
		_do({"type": EngineCore.ACTION_CHOOSE, "option": 0})
		_do({"type": EngineCore.ACTION_CHOOSE, "option": 0})
		if GameEngine.get_state()["ended"] != "" or GameEngine.get_state()["phase"] != EngineCore.PHASE_OPERATION:
			print("  turn %d: did not reach the operation phase" % [target])
			continue
		_do({"type": EngineCore.ACTION_START_QUEST, "pool": "operation", "idx": 0})
		# opA steps: [b_g|a_b], [chest|ev_gains], [heal|b_s], [b_boss|chest]
		_do({"type": EngineCore.ACTION_CHOOSE, "option": 0})
		_fight_to_completion("efficient")
		_do({"type": EngineCore.ACTION_CHOOSE, "option": 1})
		_do({"type": EngineCore.ACTION_CHOOSE, "option": 0})
		_do({"type": EngineCore.ACTION_CHOOSE, "option": 0})
		var boss: Variant = GameEngine.get_state()["battle"]
		if boss == null:
			print("  turn %d: no boss battle started" % [target])
			continue
		var outcome := _fight_to_completion("efficient")
		print("  turn %d: boss hp=%d at=%d -> %s" % [target, boss["enemy_max_hp"], boss["enemy_at"], outcome])


## One bare turn: phases only, quiet evening, war report.
func _passive_turn() -> void:
	while GameEngine.get_state()["phase"] != EngineCore.PHASE_BASE and GameEngine.get_state()["ended"] == "":
		_do({"type": EngineCore.ACTION_END_PHASE})
	if GameEngine.get_state()["ended"] != "":
		return
	if GameEngine.get_state()["base_options"] != null:
		_do({"type": EngineCore.ACTION_BASE_PICK, "option": 0})
	_do({"type": EngineCore.ACTION_END_PHASE})   # base -> report
	_do({"type": EngineCore.ACTION_END_PHASE})   # resolve report


## Drive the active battle to its close (win, defeat, or withdrawal). Returns
## the observed result ("win"/"lose") — captured before the closing end_turn
## clears the battle.
func _fight_to_completion(policy: String) -> String:
	var guard := 0
	var outcome := "?"
	while GameEngine.get_state()["battle"] != null and guard < 100:
		guard += 1
		var b: Dictionary = GameEngine.get_state()["battle"]
		if b["over"] != "":
			outcome = str(b["over"])
		_battle_round({"battle": policy})
	return outcome


# --- Helpers -------------------------------------------------------------------

func _do(action: Dictionary) -> void:
	var result := GameEngine.step(action)
	if not result["ok"]:
		printerr("sim: step failed: %s -> %s" % [action, result["errors"]])
		get_tree().quit(1)


func _total_exp(collection: Dictionary) -> int:
	var total := 0
	for id in collection:
		total += int(collection[id]["exp"])
	return total


## Count battle-resolution lines only: they are the ones the Engine prefixes
## "Round N: " (keeps the campaign-win line out of the victory count).
func _count_round_line(log: Array, suffix: String) -> int:
	var count := 0
	for line in log:
		var text := str(line)
		if text.begins_with("Round ") and text.ends_with(suffix):
			count += 1
	return count
