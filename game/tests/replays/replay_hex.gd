extends ReplayBase

## A hexed enemy action is cancelled: the archer's Hex (2 AP) cancels the
## announced Jab — no damage, the hex is consumed (hexed back to false), and
## the round still advances (AP regen, next announcement). Boss immunity is
## pinned separately in battle_defeat_withdraw.


func replay_name() -> String:
	return "hex_cancellation"


func actions() -> Array:
	return [
		{"type": EngineCore.ACTION_START_BATTLE, "enemy": "grunt"},
		{"type": EngineCore.ACTION_SKILL, "leader": 5, "slot": 1},
		{"type": EngineCore.ACTION_END_TURN},
	]


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
		"enemy_hp": 40,
		"enemy_max_hp": 40,
		"guard": false,
		"hexed": false,
		"next_action": "e_slash",
		"over": "",
		"party_hp": [
			60,
			85,
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
		"Turn 1: battle vs Press-Gang Hand",
		"Round 1: Gull-Eye Finn uses Drowned Curse: one enemy action this round will be cancelled",
		"Round 1: the hex cancels Press-Gang Hand's Hook Rake!"
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 100,
	"tickets": 0,
	"turn": 1
}
