extends Control

## The playable view over the Engine seam — no longer the placeholder dump.
## The Engine owns legality: the view renders exactly
## GameEngine.available_actions() as buttons (quest branches, battle skills,
## chest picks, base options, phase advances) plus a phase summary from
## GameEngine.context_line(), with pack names resolved engine-side. Every
## press is one GameEngine.step(); no rules live here. The session boots in
## the OS locale; chrome and future log lines follow the session language.

const SHIPPED_PACKS := [
	"res://engine/builtin_pack.json",
	"res://engine/packs/ironroad.json",
]
const LANG_CYCLE := ["en", "zh", "ja"]
const AI_PANEL_SCENE := "res://ui/ai_panel.tscn"

@onready var _header: Label = %Header
@onready var _context: Label = %ContextLabel
@onready var _actions_grid: GridContainer = %ActionsGrid
@onready var _log_label: Label = %LogLabel
@onready var _log_scroll: ScrollContainer = %LogScroll
@onready var _new_game_button: Button = %NewGameButton

var _rendered_log_size := -1


func _ready() -> void:
	%LanguageButton.pressed.connect(_on_language_pressed)
	%SwitchPackButton.pressed.connect(_on_switch_pack_pressed)
	%AIPanelButton.pressed.connect(_on_ai_panel_pressed)
	%NewGameButton.pressed.connect(_on_new_game_pressed)
	_start_session()
	_render()


func _start_session() -> void:
	# Humans boot in their OS locale; test harnesses pin "en" explicitly so
	# replays stay deterministic whatever machine runs them.
	var result := GameEngine.new_game(GameEngine.get_builtin_pack())
	if not result["ok"]:
		push_error("builtin pack rejected: %s" % [result["errors"]])
	_rendered_log_size = -1
	_render()


func _render() -> void:
	var state := GameEngine.get_state()
	var chrome := GameEngine.chrome()
	if state.is_empty() or chrome.is_empty():
		return
	var ui: Dictionary = chrome["ui"]
	var phases: Array = chrome["phases"]
	var results: Dictionary = chrome["results"]
	_header.text = "\n".join([
		(ui["pack"] as String) % [state["pack_id"]],
		(ui["turnPhase"] as String) % [state["turn"], _result_suffix(state, results), phases[state["phase"]]],
		(ui["realm"] as String) % [state["realm"], state["gains_turn"], state["gains_total"]],
		(ui["medals"] as String) % [state["medals"], state["medals"] / 2, state["tickets"], state["fatigue"]],
	])
	_context.text = GameEngine.context_line()
	_context.visible = not _context.text.is_empty()
	_new_game_button.visible = state["ended"] != ""
	_rebuild_actions()
	_render_log(state)


func _rebuild_actions() -> void:
	for child in _actions_grid.get_children():
		_actions_grid.remove_child(child)
		child.queue_free()
	for entry in GameEngine.available_actions():
		var action: Dictionary = entry["action"]
		var button := Button.new()
		button.text = entry["label"]
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.pressed.connect(func() -> void:
			GameEngine.step(action)
			_render()
		)
		_actions_grid.add_child(button)


func _render_log(state: Dictionary) -> void:
	var log: Array = state["log"]
	if log.size() == _rendered_log_size:
		return
	_rendered_log_size = log.size()
	var lines: Array[String] = []
	for line in log:
		lines.append(line)
	_log_label.text = "\n".join(lines)
	# Follow the newest line; the reader can scroll back between events.
	_log_scroll.set_deferred("scroll_vertical", 1_000_000)


func _result_suffix(state: Dictionary, results: Dictionary) -> String:
	var ended: String = state["ended"]
	if ended == "":
		return ""
	return " (%s)" % [results[ended]]


func _on_switch_pack_pressed() -> void:
	# Thin view: pick the shipped pack whose id differs from the current one
	# and let the Engine validate and switch. Rejections change nothing.
	# AI-generated packs (persisted under user://packs) join the cycle after
	# the shipped ones, through the same Engine seam.
	var current: String = GameEngine.get_state().get("pack_id", "")
	for path in SHIPPED_PACKS:
		var loaded := GameEngine.load_pack_file(path)
		if loaded["ok"] and loaded["pack"]["id"] != current:
			GameEngine.step({"type": EngineCore.ACTION_IMPORT_PACK, "path": path})
			_render()
			return
	for pack in AIGateway.get_generated_packs():
		if pack["id"] != current:
			GameEngine.step({"type": EngineCore.ACTION_SELECT_PACK, "pack": pack})
			_render()
			return


func _on_ai_panel_pressed() -> void:
	# ADR-0005: the web export is all-ages only — the Engine says whether the
	# AI Entry plays on this platform; the view just follows.
	if not GameEngine.adult_allowed():
		return
	if get_node_or_null("AIPanel") == null:
		var panel: Control = (load(AI_PANEL_SCENE) as PackedScene).instantiate()
		panel.name = "AIPanel"
		add_child(panel)


func _on_language_pressed() -> void:
	# Mid-run chrome switch through the Engine seam; state is preserved
	# bit-for-bit by the Engine (chrome-only change). Future log lines render
	# in the new language; historical lines stay as they were written.
	var next: String = LANG_CYCLE[(LANG_CYCLE.find(GameEngine.get_language()) + 1) % LANG_CYCLE.size()]
	GameEngine.step({"type": EngineCore.ACTION_SET_LANGUAGE, "lang": next})
	_render()


func _on_new_game_pressed() -> void:
	# Keep the language the player already chose; new_game's OS-locale default
	# is only for the very first boot.
	GameEngine.new_game(GameEngine.get_builtin_pack(), GameEngine.get_language())
	_rendered_log_size = -1
	_render()
