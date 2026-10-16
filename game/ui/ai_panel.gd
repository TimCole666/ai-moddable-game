extends PanelContainer

## AI Entry panel (ticket 06): provider settings from recommended presets plus
## the generation flow. Settings persist through AIGateway into user://
## storage; a generated pack enters the game ONLY through the Engine seam
## (select_pack). The panel's own text is trilingual zh/en/ja, local to this
## file; following the session language is the trilingual-chrome ticket's job
## (set `language` on this panel from there).

const STRINGS := {
	"en": {
		"title": "AI Entry",
		"preset": "Preset",
		"base_url": "Endpoint URL",
		"model": "Model",
		"api_key": "API key (cloud only)",
		"topic": "Pack theme",
		"generate": "Generate Pack",
		"status_ready": "Configure a provider above, then generate.",
		"status_generating": "Generating...",
		"status_generated": "Generated and playing: %s",
		"status_cached": "Returned from cache, playing: %s",
		"err_settings": "Settings rejected: %s",
		"err_generation": "Generation failed: %s",
		"err_switch": "Engine rejected the pack: %s",
	},
	"zh": {
		"title": "AI 生成入口",
		"preset": "预设",
		"base_url": "接口地址",
		"model": "模型",
		"api_key": "API 密钥（仅云端）",
		"topic": "主题包题材",
		"generate": "生成主题包",
		"status_ready": "先在上方配置服务商，再进行生成。",
		"status_generating": "生成中……",
		"status_generated": "已生成并开始游玩:%s",
		"status_cached": "命中缓存，开始游玩:%s",
		"err_settings": "设置被拒绝:%s",
		"err_generation": "生成失败:%s",
		"err_switch": "引擎拒绝该主题包:%s",
	},
	"ja": {
		"title": "AIエントリー",
		"preset": "プリセット",
		"base_url": "エンドポイントURL",
		"model": "モデル",
		"api_key": "APIキー(クラウドのみ)",
		"topic": "テーマパックの題材",
		"generate": "テーマパックを生成",
		"status_ready": "まず上でプロバイダを設定してから生成してください。",
		"status_generating": "生成中……",
		"status_generated": "生成してプレイ中:%s",
		"status_cached": "キャッシュから返却してプレイ中:%s",
		"err_settings": "設定を拒否されました:%s",
		"err_generation": "生成に失敗:%s",
		"err_switch": "エンジンがテーマパックを拒否:%s",
	},
}

## Session language ("en"|"zh"|"ja"). The trilingual-chrome ticket drives this.
var language := "en"

var _preset_ids: Array = []

@onready var _title_label: Label = %TitleLabel
@onready var _preset_label: Label = %PresetLabel
@onready var _preset_option: OptionButton = %PresetOption
@onready var _base_url_label: Label = %BaseUrlLabel
@onready var _base_url_edit: LineEdit = %BaseUrlEdit
@onready var _model_label: Label = %ModelLabel
@onready var _model_edit: LineEdit = %ModelEdit
@onready var _api_key_label: Label = %ApiKeyLabel
@onready var _api_key_edit: LineEdit = %ApiKeyEdit
@onready var _topic_label: Label = %TopicLabel
@onready var _topic_edit: LineEdit = %TopicEdit
@onready var _generate_button: Button = %GenerateButton
@onready var _status_label: Label = %StatusLabel


func _ready() -> void:
	_preset_ids.clear()
	_preset_option.clear()
	for preset in AIGateway.get_presets():
		_preset_ids.append(preset["id"])
		_preset_option.add_item("%s (%s)" % [preset["id"], preset["kind"]])
	_apply_language()
	var settings := AIGateway.get_settings()
	if not settings.is_empty() and _preset_ids.has(settings.get("preset", "")):
		_preset_option.select(_preset_ids.find(settings["preset"]))
	_base_url_edit.text = str(settings.get("base_url", ""))
	_model_edit.text = str(settings.get("model", ""))
	_api_key_edit.text = str(settings.get("api_key", ""))
	_status_label.text = _t("status_ready")


func _t(key: String) -> String:
	var locale: Dictionary = STRINGS.get(language, STRINGS["en"])
	return str(locale.get(key, STRINGS["en"].get(key, key)))


func _apply_language() -> void:
	_title_label.text = _t("title")
	_preset_label.text = _t("preset")
	_base_url_label.text = _t("base_url")
	_model_label.text = _t("model")
	_api_key_label.text = _t("api_key")
	_topic_label.text = _t("topic")
	_generate_button.text = _t("generate")


func _on_preset_option_item_selected(index: int) -> void:
	# A preset fills in the endpoint and model; the player can still edit them
	# (e.g. point a cloud preset at a compatible relay). The key never comes
	# from a preset.
	for preset in AIGateway.get_presets():
		if preset["id"] == _preset_ids[index]:
			_base_url_edit.text = str(preset["base_url"])
			_model_edit.text = str(preset["model"])
			return


func _on_generate_button_pressed() -> void:
	var preset: Dictionary = AIGateway.get_presets()[_preset_option.selected]
	var settings := {
		"kind": preset["kind"],
		"preset": preset["id"],
		"base_url": _base_url_edit.text.strip_edges(),
		"model": _model_edit.text.strip_edges(),
		"api_key": _api_key_edit.text,
	}
	var saved := AIGateway.set_settings(settings)
	if not saved["ok"]:
		_status_label.text = _t("err_settings") % [", ".join(saved["errors"])]
		return
	_status_label.text = _t("status_generating")
	var result: Dictionary = await AIGateway.generate_pack(_topic_edit.text.strip_edges())
	if not result["ok"]:
		_status_label.text = _t("err_generation") % [", ".join(result["errors"])]
		return
	# The Engine seam is the only door: switch the running session to the
	# generated pack (validation already passed inside the gateway).
	var switched := GameEngine.step({"type": EngineCore.ACTION_SELECT_PACK, "pack": result["pack"]})
	if not switched["ok"]:
		_status_label.text = _t("err_switch") % [", ".join(switched["errors"])]
		return
	var pack: Dictionary = result["pack"]
	var pack_name := str(pack["text"]["en"]["name"])
	if result["cached"]:
		_status_label.text = _t("status_cached") % [pack_name]
	else:
		_status_label.text = _t("status_generated") % [pack_name]
