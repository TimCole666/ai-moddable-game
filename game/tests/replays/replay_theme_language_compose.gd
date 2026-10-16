extends ReplayBase

## Theme switching and language switching compose: mid-battle, switch to the
## Iron Road pack (state preserved), then switch the language to Japanese
## (state preserved bit-for-bit), then keep playing — the battle resolves and
## every chrome line logs in Japanese while carrying Iron Road's ja pack names.
## The final state is pinned bit-for-bit.

const IRONROAD_PATH := "res://engine/packs/ironroad.json"

## Debug aid during pinning: dumps the final state to stdout.
const DEBUG_DUMP := false


func replay_name() -> String:
	return "theme_language_compose"


func pack() -> Dictionary:
	return {}


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		# Theme switch mid-battle (ticket 04 vocabulary)…
		{"type": EngineCore.ACTION_IMPORT_PACK, "path": IRONROAD_PATH},
		# …then a language switch mid-battle: chrome-only, state untouched.
		{"type": EngineCore.ACTION_SET_LANGUAGE, "lang": "ja"},
		{"type": EngineCore.ACTION_SKILL, "leader": 2, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
	]


func checks() -> PackedStringArray:
	var problems := PackedStringArray()
	if GameEngine.get_language() != "ja":
		problems.append("get_language(): expected ja, got %s" % [GameEngine.get_language()])
	var chrome := GameEngine.chrome()
	if (chrome["phases"] as Array)[0] != "準備":
		problems.append("chrome().phases[0]: expected 準備, got %s" % [(chrome["phases"] as Array)[0]])
	if DEBUG_DUMP:
		print(JSON.stringify(GameEngine.get_state(), "\t"))
	return problems


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": {
		"ap": 2,
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
		"Turn 1: Preparation quest started: Provisions Ashore.",
		"Turn 1: battle vs Press-Gang Hand",
		"Round 1: Captain Maren Stormbite uses Cutlass Slash for 14 damage (enemy HP 26)",
		"Turn 1: theme pack switched to Iron Road.",
		"ラウンド 1：駅務衛生兵 が 応急修理 を使用：生存する隊員全員の HP +9",
		"ラウンド 1：襲撃者 が 鞭打ち を使用、8 ダメージ（制動手 の HP 77）"
	],
	"medals": 0,
	"pack_id": "ironroad",
	"phase": 0,
	"quest": {
		"idx": 0,
		"pool": "prep",
		"step": 0
	},
	"realm": 100,
	"tickets": 0,
	"turn": 1
}
