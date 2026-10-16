extends ReplayBase

## Ticket 06: the full AI Entry round trip. A fake transport "emits" a v1
## Theme Pack (markdown-fenced, as models do); the gateway parses, validates
## it against the Engine contract, caches it, and registers it in the pack
## list; the pack then enters the game through the Engine seam (select_pack)
## and a battle step plays under it. Zero network activity.

const LOCAL_SETTINGS := {"kind": "local", "preset": "ollama", "base_url": "http://127.0.0.1:11434/v1", "model": "fake-model", "api_key": ""}
const TOPIC := "copper desert caravan"
const GENERATED_ID := "copper_desert"

var _problems: PackedStringArray = PackedStringArray()
var _fake: AIFakeTransport
var _result: Dictionary = {}
var _switch_errors: PackedStringArray = PackedStringArray()


func replay_name() -> String:
	return "ai_generated_pack_plays"


func pack() -> Dictionary:
	return {}


func actions() -> Array:
	return [
		Callable(self, "setup_gateway"),
		Callable(self, "generate"),
		Callable(self, "switch_to_generated"),
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "grunt"},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
	]


## Test-driver code (not an Engine action): reset the cache, inject the fake
## transport (zero network), configure a local provider, and queue the
## model's fenced-JSON reply.
func setup_gateway() -> void:
	AIGateway.clear_cache()
	_fake = AIFakeTransport.new()
	_fake.queue_response(AIFakeTransport.chat_response("```json\n" + _model_pack_json() + "\n```"))
	AIGateway.set_transport(_fake)
	var saved := AIGateway.set_settings(LOCAL_SETTINGS)
	if not saved["ok"]:
		_problems.append("local settings rejected: %s" % [saved["errors"]])


func generate() -> void:
	_result = await AIGateway.generate_pack(TOPIC)


## Test-driver code: the ONLY door from AI output into the game — the
## Engine's select_pack action.
func switch_to_generated() -> void:
	if not _result.get("ok", false):
		return
	var switched := GameEngine.step({"type": EngineCore.ACTION_SELECT_PACK, "pack": _result["pack"]})
	if not switched["ok"]:
		_switch_errors = switched["errors"]


func checks() -> PackedStringArray:
	if _result.is_empty():
		_problems.append("generate_pack() never returned (transport hung?)")
		return _problems
	if not _result["ok"]:
		_problems.append("generation failed: %s" % [_result["errors"]])
		return _problems
	if _result.get("cached", true):
		_problems.append("first generation claimed a cache hit")
	var pack: Dictionary = _result["pack"]
	if str(pack["id"]) != GENERATED_ID:
		_problems.append("expected generated pack id %s, got %s" % [GENERATED_ID, pack["id"]])
	if not GameEngine.validate_pack(pack).is_empty():
		_problems.append("generated pack fails v1 validation: %s" % [GameEngine.validate_pack(pack)])
	if _fake.calls != 1:
		_problems.append("expected exactly 1 network call, got %d" % [_fake.calls])
	var cache_files := DirAccess.get_files_at(AIGateway.CACHE_DIR)
	if cache_files.size() != 1:
		_problems.append("expected exactly 1 cache entry, got %d" % [cache_files.size()])
	var found := false
	for registered in AIGateway.get_generated_packs():
		if registered["id"] == GENERATED_ID:
			found = true
	if not found:
		_problems.append("generated pack not registered in the pack list")
	if not _switch_errors.is_empty():
		_problems.append("select_pack rejected the generated pack: %s" % [_switch_errors])
	return _problems


## A complete v1 pack "emitted by the model": the builtin pack re-themed, so
## the text is guaranteed contract-complete in all three locales. Only the
## identity/accent/name fields change; the battle text below (enemy, card,
## skill names) still comes from the builtin vocabulary.
func _model_pack_json() -> String:
	var pack := GameEngine.get_builtin_pack()
	pack["id"] = GENERATED_ID
	pack["accent"] = "#b87333"
	pack["text"]["en"]["name"] = "Copper Desert"
	pack["text"]["en"]["tagline"] = "caravans under a brass sun"
	pack["text"]["zh"]["name"] = "黄铜荒漠"
	pack["text"]["zh"]["tagline"] = "黄铜太阳下的商队"
	pack["text"]["ja"]["name"] = "銅の砂漠"
	pack["text"]["ja"]["tagline"] = "真鍮の太陽の下の隊商"
	return JSON.stringify(pack)


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": {
		"ap": 4,
		"ap_max": 6,
		"boss": false,
		"combo": 0,
		"enemy": "grunt",
		"enemy_at": 8,
		"enemy_hp": 26,
		"enemy_max_hp": 40,
		"guard": false,
		"hexed": false,
		"next_action": "e_slash",
		"over": "",
		"party_hp": [
			60,
			77,
			70,
			45,
			50,
			48
		],
		"regen": 2,
		"round": 2
	},
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
			"exp": 0
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
		"Turn 1: theme pack switched to Copper Desert.",
		"Turn 1: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 26)",
		"Round 1: Press-Gang Hand uses Hook Rake for 8 damage on Bram Ironkeel (HP 77)"
	],
	"medals": 0,
	"pack_id": "copper_desert",
	"phase": 0,
	"quest": null,
	"realm": 100,
	"tickets": 0,
	"turn": 1
}
