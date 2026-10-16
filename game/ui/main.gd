extends Control

## The art-driven game view over the Engine seam. All visuals are pack data:
## the backdrop, portraits, and enemy illustrations come from the pack's
## optional art section (ADR-0008) via GameEngine.pack_art(); the accent and
## palette come via pack_accent()/pack_palette(). All gameplay legality stays
## engine-side: the view renders GameEngine.available_actions() (quest
## branches, battle skills, chests, base options, phase advances) and one
## structured battle_view() for the cards and bars. Every press is exactly
## one GameEngine.step(); no rules live here. Packs without art degrade to
## emoji chips on the accent theme — never broken.

const SHIPPED_PACKS := [
	"res://engine/builtin_pack.json",
	"res://engine/packs/ironroad.json",
]
const LANG_CYCLE := ["en", "zh", "ja"]
const AI_PANEL_SCENE := "res://ui/ai_panel.tscn"
const ACCENT_FALLBACK := Color(0.25, 0.75, 0.62)
const PANEL_BG := Color(0.05, 0.09, 0.11, 0.92)
const HP_DANGER := 0.35

@onready var _backdrop: TextureRect = %Backdrop
@onready var _dim: ColorRect = %Dim
@onready var _title: Label = %Title
@onready var _phase_strip: HBoxContainer = %PhaseStrip
@onready var _resources: Label = %Resources
@onready var _realm_bar: ProgressBar = %RealmBar
@onready var _center: VBoxContainer = %Center
@onready var _log_label: Label = %LogLabel
@onready var _log_scroll: ScrollContainer = %LogScroll
@onready var _new_btn: Button = %NewBtn

var _rendered_log_size := -1
var _prev_hp := {}


func _ready() -> void:
	%LangBtn.pressed.connect(_on_language_pressed)
	%PackBtn.pressed.connect(_on_switch_pack_pressed)
	%AIBtn.pressed.connect(_on_ai_panel_pressed)
	%NewBtn.pressed.connect(_on_new_game_pressed)
	_start_session()


func _start_session() -> void:
	# Humans boot in their OS locale; test harnesses pin "en" explicitly so
	# replays stay deterministic whatever machine runs them.
	var result := GameEngine.new_game(GameEngine.get_builtin_pack())
	if not result["ok"]:
		push_error("builtin pack rejected: %s" % [result["errors"]])
	_rendered_log_size = -1
	_prev_hp.clear()
	_render()


# --- render -------------------------------------------------------------------

func _render() -> void:
	var state := GameEngine.get_state()
	var chrome := GameEngine.chrome()
	if state.is_empty() or chrome.is_empty():
		return
	_render_backdrop(state)
	_render_top(state, chrome)
	_render_center(state, chrome)
	_render_log(state)


func _render_backdrop(state: Dictionary) -> void:
	var bg_key := "sea"
	if state["battle"] is Dictionary:
		bg_key = "deck"
	elif state["base_options"] is Array or state["phase"] == 3:
		bg_key = "tavern"
	var texture := GameEngine.pack_art("backgrounds", bg_key)
	_backdrop.texture = texture
	_dim.color = Color(0.03, 0.07, 0.09, 0.55) if texture != null else Color(0.05, 0.09, 0.11)


func _render_top(state: Dictionary, chrome: Dictionary) -> void:
	var ui: Dictionary = chrome["ui"]
	var phases: Array = chrome["phases"]
	_title.text = GameEngine.pack_name()
	_new_btn.visible = state["ended"] != ""
	%LangBtn.text = (chrome["buttons"]["language"] as String) % [GameEngine.get_language()]
	%PackBtn.text = chrome["buttons"]["switchPack"]
	%AIBtn.text = "AI"
	%NewBtn.text = chrome["buttons"]["newGame"]
	# Phase strip: four chips, the current one lit.
	for child in _phase_strip.get_children():
		child.queue_free()
	var phase_idx: int = state["phase"]
	for idx in phases.size():
		var chip := PanelContainer.new()
		var sb := _chip_style(GameEngine.pack_accent(), idx == phase_idx and state["ended"] == "")
		chip.add_theme_stylebox_override("panel", sb)
		var chip_label := Label.new()
		chip_label.text = phases[idx]
		chip_label.add_theme_font_size_override("font_size", 13)
		chip.add_child(chip_label)
		_phase_strip.add_child(chip)
	# Resources line + realm bar.
	_resources.text = "%s\n%s" % [
		(ui["realm"] as String) % [state["realm"], state["gains_turn"], state["gains_total"]],
		(ui["medals"] as String) % [state["medals"], state["medals"] / 2, state["tickets"], state["fatigue"]],
	]
	var realm: int = state["realm"]
	_realm_bar.max_value = 100
	_realm_bar.value = realm
	var realm_color := Color(0.85, 0.3, 0.3) if realm < 50 else GameEngine.pack_accent()
	_style_bar(_realm_bar, realm_color)


func _render_center(state: Dictionary, chrome: Dictionary) -> void:
	_clear(_center)
	var accent := GameEngine.pack_accent()
	var ui: Dictionary = chrome["ui"]
	var ended: String = state["ended"]
	if ended != "":
		var banner := _section_label(results_line(state, chrome), accent, 26)
		_center.add_child(banner)
		var again := _big_button(chrome["buttons"]["newGame"], accent)
		again.pressed.connect(_start_session)
		_center.add_child(again)
		return
	if state["battle"] is Dictionary:
		_render_battle(state, chrome, accent)
		return
	var actions := GameEngine.available_actions()
	if state["chest"] is Array:
		_center.add_child(_section_label(ui["nodeChest"], accent))
		_center.add_child(_cards_row(actions, accent))
		return
	if state["base_options"] is Array:
		_center.add_child(_section_label(ui["baseTitle"], accent))
		_center.add_child(_cards_row(actions, accent))
		return
	var quest: Variant = state["quest"]
	if quest is Dictionary:
		var q := quest as Dictionary
		_center.add_child(_section_label((ui["chooseStep"] as String) % [q["step"] + 1], accent))
		_center.add_child(_cards_row(_of_type(actions, "choose"), accent, true))
		var retire_row := HBoxContainer.new()
		retire_row.alignment = BoxContainer.ALIGNMENT_CENTER
		for entry in _of_type(actions, "retire"):
			retire_row.add_child(_small_button(entry["label"], accent, entry["action"]))
		_center.add_child(retire_row)
		return
	if state["phase"] == 3:
		_center.add_child(_section_label(phases_line(state, chrome), accent, 22))
		_center.add_child(_cards_row(actions, accent))
		return
	_center.add_child(_section_label(ui["noQuest"], accent))
	_center.add_child(_cards_row(actions, accent))


func _render_battle(state: Dictionary, chrome: Dictionary, accent: Color) -> void:
	var ui: Dictionary = chrome["ui"]
	var bv := GameEngine.battle_view()
	if bv.is_empty():
		return
	var row := HBoxContainer.new()
	row.size_flags_vertical = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("separation", 14)
	# Enemy panel: portrait, name, HP bar, the announced next action.
	var enemy_panel := PanelContainer.new()
	enemy_panel.add_theme_stylebox_override("panel", _panel_style(accent, true))
	var enemy_box := VBoxContainer.new()
	enemy_box.add_child(_portrait(GameEngine.pack_art("enemies", bv["enemy_id"]), Vector2(230, 300)))
	var enemy_name := Label.new()
	enemy_name.text = bv["enemy_name"]
	enemy_name.add_theme_font_size_override("font_size", 18)
	enemy_box.add_child(enemy_name)
	enemy_box.add_child(_hp_bar(bv["enemy_hp"], bv["enemy_max_hp"], "enemy", accent))
	var announce := Label.new()
	announce.text = (ui["announcedBanner"] as String) % [bv["announced"]]
	announce.add_theme_color_override("font_color", Color(1.0, 0.75, 0.35))
	enemy_box.add_child(announce)
	enemy_panel.add_child(enemy_box)
	row.add_child(enemy_panel)
	# Party: six leader cards with portraits, HP bars, and their skill buttons.
	var party_grid := GridContainer.new()
	party_grid.columns = 3
	party_grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	party_grid.add_theme_constant_override("h_separation", 10)
	party_grid.add_theme_constant_override("v_separation", 10)
	var skill_actions := _of_type(GameEngine.available_actions(), "skill")
	for idx in bv["party"].size():
		var member: Dictionary = bv["party"][idx]
		party_grid.add_child(_leader_card(member, idx, skill_actions, accent))
	row.add_child(party_grid)
	_center.add_child(row)
	# Battle bar: AP, combo, guard/hexed chips, end turn.
	var bar := HBoxContainer.new()
	bar.add_theme_constant_override("separation", 12)
	var ap_line := Label.new()
	ap_line.text = (ui["apLine"] as String) % [bv["ap"], bv["ap_max"], bv["regen"]]
	ap_line.add_theme_font_size_override("font_size", 17)
	bar.add_child(ap_line)
	if bv["combo"] > 0:
		bar.add_child(_chip("×%d" % bv["combo"], accent))
	if bv["guard"]:
		bar.add_child(_chip("⛨", accent))
	if bv["hexed"]:
		bar.add_child(_chip("✦", accent))
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	bar.add_child(spacer)
	for entry in _of_type(GameEngine.available_actions(), "end_turn"):
		var label: String = chrome["buttons"]["continue"] if bv["over"] != "" else chrome["buttons"]["endTurn"]
		var end_btn := _big_button(label, accent)
		var action: Dictionary = entry["action"]
		end_btn.pressed.connect(func() -> void:
			GameEngine.step(action)
			_render()
		)
		bar.add_child(end_btn)
	_center.add_child(bar)


# --- widget factories ---------------------------------------------------------

func _leader_card(member: Dictionary, idx: int, skill_actions: Array, accent: Color) -> Control:
	var card := PanelContainer.new()
	card.add_theme_stylebox_override("panel", _panel_style(accent))
	var box := VBoxContainer.new()
	box.add_theme_constant_override("separation", 4)
	var portrait := _portrait(GameEngine.pack_art("portraits", member["id"]), Vector2(0, 88))
	box.add_child(portrait)
	var name_label := Label.new()
	name_label.text = member["name"]
	box.add_child(name_label)
	box.add_child(_hp_bar(member["hp"], member["max_hp"], member["id"], accent))
	for entry in skill_actions:
		var action: Dictionary = entry["action"]
		if action["leader"] != idx:
			continue
		var skill_btn := _small_button(entry["label"], accent, action)
		box.add_child(skill_btn)
	card.add_child(box)
	return card


func _portrait(texture: Texture2D, min_size: Vector2) -> Control:
	var rect := TextureRect.new()
	rect.custom_minimum_size = min_size
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	rect.texture = texture
	if texture == null:
		var fallback := Label.new()
		fallback.text = "⚓"
		fallback.custom_minimum_size = min_size
		fallback.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		fallback.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		return fallback
	return rect


func _cards_row(actions: Array, accent: Color, wide := false) -> Control:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 12)
	for entry in actions:
		var card := _big_button(entry["label"], accent)
		if wide:
			card.custom_minimum_size = Vector2(300, 96)
		else:
			card.custom_minimum_size = Vector2(260, 72)
		var action: Dictionary = entry["action"]
		card.pressed.connect(func() -> void:
			GameEngine.step(action)
			_render()
		)
		row.add_child(card)
	return row


func _big_button(label: String, accent: Color) -> Button:
	var button := Button.new()
	button.text = label
	button.custom_minimum_size = Vector2(220, 56)
	button.add_theme_font_size_override("font_size", 16)
	_style_button(button, accent)
	return button


func _small_button(label: String, accent: Color, action: Dictionary) -> Button:
	var button := Button.new()
	button.text = label
	button.add_theme_font_size_override("font_size", 12)
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_style_button(button, accent)
	button.pressed.connect(func() -> void:
		GameEngine.step(action)
		_render()
	)
	return button


func _section_label(text: String, accent: Color, font_size := 18) -> Label:
	var label := Label.new()
	label.text = text
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", accent)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	return label


func _chip(text: String, accent: Color) -> Control:
	var chip := PanelContainer.new()
	chip.add_theme_stylebox_override("panel", _chip_style(accent, true))
	var label := Label.new()
	label.text = text
	chip.add_child(label)
	return chip


func _panel_style(accent: Color, border := false) -> StyleBoxFlat:
	var sb := StyleBoxFlat.new()
	sb.bg_color = PANEL_BG
	sb.corner_radius_top_left = 10
	sb.corner_radius_top_right = 10
	sb.corner_radius_bottom_left = 10
	sb.corner_radius_bottom_right = 10
	sb.content_margin_left = 12
	sb.content_margin_right = 12
	sb.content_margin_top = 10
	sb.content_margin_bottom = 10
	if border:
		sb.border_width_left = 2
		sb.border_width_right = 2
		sb.border_width_top = 2
		sb.border_width_bottom = 2
		sb.border_color = accent
	return sb


func _chip_style(accent: Color, filled: bool) -> StyleBoxFlat:
	var sb := _panel_style(accent)
	sb.content_margin_left = 8
	sb.content_margin_right = 8
	sb.content_margin_top = 2
	sb.content_margin_bottom = 2
	sb.bg_color = accent if filled else Color(accent.r, accent.g, accent.b, 0.2)
	return sb


func _style_button(button: Button, accent: Color) -> void:
	var normal := _chip_style(accent, false)
	normal.bg_color = Color(0.07, 0.12, 0.14, 0.95)
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.border_color = accent
	var hover := _chip_style(accent, false)
	hover.bg_color = Color(accent.r, accent.g, accent.b, 0.25)
	hover.border_color = accent
	var pressed := _chip_style(accent, true)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("hover", hover)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("focus", StyleBoxEmpty.new())


func _hp_bar(value: float, max_value: float, key: String, accent: Color) -> ProgressBar:
	var bar := ProgressBar.new()
	bar.custom_minimum_size = Vector2(0, 10)
	bar.show_percentage = false
	bar.max_value = max_value
	var ratio := value / max_value if max_value > 0 else 0.0
	var color := Color(0.85, 0.3, 0.3) if ratio < HP_DANGER else accent
	_style_bar(bar, color)
	# Animate from the previously rendered value so hits read as motion.
	var prev: Variant = _prev_hp.get(key, value)
	bar.value = prev
	if absf(float(prev) - value) > 0.01:
		var tween := create_tween()
		tween.tween_property(bar, "value", value, 0.35)
	_prev_hp[key] = value
	return bar


func _style_bar(bar: ProgressBar, color: Color) -> void:
	var bg := StyleBoxFlat.new()
	bg.bg_color = Color(0, 0, 0, 0.55)
	var fill := StyleBoxFlat.new()
	fill.bg_color = color
	bar.add_theme_stylebox_override("background", bg)
	bar.add_theme_stylebox_override("fill", fill)


# --- shared plumbing ----------------------------------------------------------

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


func _clear(node: Node) -> void:
	for child in node.get_children():
		node.remove_child(child)
		child.queue_free()


func _of_type(actions: Array, type: String) -> Array:
	var matches: Array = []
	for entry in actions:
		if (entry["action"] as Dictionary)["type"] == type:
			matches.append(entry)
	return matches


func results_line(state: Dictionary, chrome: Dictionary) -> String:
	var ui: Dictionary = chrome["ui"]
	var ended: String = state["ended"]
	if ended == "":
		return ""
	var line := (ui["battleOver"] as String) % [GameEngine.pack_name(), chrome["results"][ended]]
	return line


func phases_line(state: Dictionary, chrome: Dictionary) -> String:
	var phases: Array = chrome["phases"]
	return phases[state["phase"]] if state["phase"] < phases.size() else ""


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
	_prev_hp.clear()
	_render()
