extends ReplayBase

## Ticket 07: the pirate pack's trilingual text surfaces through the engine.
## Two turns are played — turn 1 in Chinese, turn 2 in Japanese — exercising
## the pack's quest titles, the rotating event flavor pools, the adult
## quiet-evening pool, and the localized war-report template. checks() also
## validates the builtin pack (all three locales) and pins pool size and
## line uniqueness. Final state pinned bit-for-bit.


func replay_name() -> String:
	return "pirate_text_trilingual"


func actions() -> Array:
	return [
		# --- Turn 1, Chinese: prep quest A (fight, event, supplies, evening) ---
		{"type": EngineCore.ACTION_SET_LANGUAGE, "lang": "zh"},
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # battle: 强征水手
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},
		{"type": EngineCore.ACTION_SKILL, "leader": 0, "slot": 0},
		{"type": EngineCore.ACTION_END_TURN},              # win -> node done
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # event: +EXP (zh pool)
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # war supplies +2
		{"type": EngineCore.ACTION_END_PHASE},             # -> base phase
		{"type": EngineCore.ACTION_BASE_PICK, "option": 0},  # quiet evening (zh adult pool)
		{"type": EngineCore.ACTION_END_PHASE},             # -> war report
		{"type": EngineCore.ACTION_END_PHASE},             # zh report -> turn 2
		# --- Turn 2, Japanese: prep quest B (chest, event, rest site) ---
		{"type": EngineCore.ACTION_SET_LANGUAGE, "lang": "ja"},
		{"type": EngineCore.ACTION_START_QUEST, "pool": "prep", "idx": 1},
		{"type": EngineCore.ACTION_CHOOSE, "option": 0},   # chest
		{"type": EngineCore.ACTION_CHEST_PICK, "idx": 0},
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # event: +EXP (ja pool)
		{"type": EngineCore.ACTION_CHOOSE, "option": 1},   # rest site
		{"type": EngineCore.ACTION_END_PHASE},             # -> base phase
		{"type": EngineCore.ACTION_BASE_PICK, "option": 0},  # quiet evening (ja adult pool)
		{"type": EngineCore.ACTION_END_PHASE},             # -> war report
		{"type": EngineCore.ACTION_END_PHASE},             # ja report -> turn 3
	]


func checks() -> PackedStringArray:
	var problems := PackedStringArray()
	# The builtin pirate pack must validate cleanly — every locale complete.
	var errors := GameEngine.validate_pack(GameEngine.get_builtin_pack())
	if not errors.is_empty():
		problems.append("builtin pack failed validation: %s" % [", ".join(errors)])
	var pack := GameEngine.get_builtin_pack()
	var expected_names := {"en": "Crimson Corsairs", "zh": "绯红私掠者", "ja": "紅の海賊団"}
	for lang in ["en", "zh", "ja"]:
		var locale: Dictionary = pack["text"][lang]
		if locale["name"] != expected_names[lang]:
			problems.append("text.%s.name: expected %s" % [lang, expected_names[lang]])
		for pool in ["ev_exp", "ev_gains", "base"]:
			var lines: Array = locale["flavor"][pool]
			if lines.size() < 4:
				problems.append("text.%s.flavor.%s: expected a pool of 4+ lines, got %d" % [lang, pool, lines.size()])
			var unique := {}
			for line in lines:
				unique[line] = true
			if unique.size() != lines.size():
				problems.append("text.%s.flavor.%s: duplicate lines in the pool" % [lang, pool])
	# The session ended speaking Japanese.
	if GameEngine.get_language() != "ja":
		problems.append("expected language ja, got %s" % [GameEngine.get_language()])
	var log: Array = GameEngine.get_state()["log"]
	var joined := "\n".join(log)
	for banned in ["Vanguard", "Bulwark", "Medic", "Sage", "Dancer", "Ranger",
			"Grunt", "Brute", "Shaman", "Warlord", "Jab", "Ridge Patrol",
			"Provisions Ashore", "Placeholder", "placeholder", "skeleton",
			"TODO", "TBD", "{turn}", "{loss}", "{left}"]:
		if joined.contains(banned):
			problems.append("log leaks skeleton placeholder %s" % [banned])
	# Contract v1 (ticket 04) makes every flavor pool mandatory, so the
	# skeleton fallback in _flavor_line() is unreachable for a validated
	# pack. Pin that: none of the fallback chrome strings may ever appear
	# in a validated-pack session's log. If validation ever loosens, this
	# fails loudly instead of leaking skeleton text silently. (The
	# all-ages web gate's substitution is a separate, legitimate path —
	# this session runs with adult content on.)
	for fallback in ["an event (+EXP)", "an event (+war gains)"]:
		if joined.contains(fallback):
			problems.append("log leaked _flavor_line skeleton fallback %s" % [fallback])
	for required in ["岸上筹粮", "强征水手", "ラム酒の輸送", "嵐牙の船長マレン"]:
		if not joined.contains(required):
			problems.append("log missing localized pirate pack text %s" % [required])
	return problems


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": null,
	"chest": null,
	"collection": {
		"archer": {
			"count": 1,
			"exp": 2
		},
		"healer": {
			"count": 2,
			"exp": 4
		},
		"hero": {
			"count": 1,
			"exp": 6
		},
		"mage": {
			"count": 1,
			"exp": 2
		},
		"striker": {
			"count": 1,
			"exp": 2
		},
		"tank": {
			"count": 1,
			"exp": 4
		}
	},
	"ended": "",
	"fatigue": 2,
	"gains_total": 4,
	"gains_turn": 0,
	"log": [
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue.",
		"第 1 回合：准备任务开始：岸上筹粮。",
		"第 1 回合：对战 强征水手",
		"第 1 轮：玛伦·风暴之牙船长 使用 弯刀斩，造成 14 伤害（敌方 HP 26）",
		"第 1 轮：强征水手 使用 铁钩横扫，造成 8 伤害（布拉姆·铁龙骨，HP 77）",
		"第 2 轮：玛伦·风暴之牙船长 使用 弯刀斩，造成 15 伤害（敌方 HP 11）",
		"第 2 轮：强征水手 使用 铁钩横扫，造成 7 伤害（潮汐祭司娜乌拉，HP 63）",
		"第 3 轮：玛伦·风暴之牙船长 使用 弯刀斩，造成 13 伤害（敌方 HP 0）",
		"第 3 轮：胜利！",
		"第 1 回合：战斗结束",
		"第 1 回合：航海长在灯下替你修订海图，顺便修正你的姿势：她把你按在桌边，齿尖抵着你的喉咙，手探进你的腿间，直到你再也握不住笔。（布拉姆·铁龙骨 +2 经验）",
		"第 1 回合：军需到位：战功 +2（本回合合计 2）。",
		"第 1 回合：任务完成：岸上筹粮。",
		"第 1 回合：与玛伦·风暴之牙船长的宁静夜晚：雨点敲打艉窗，她的唇沿着你每一道旧疤向下游走，直到你颤抖着喊出她的名字；暴雨停歇时，你已瘫在玻璃上喘息。（经验 +2）",
		"第 1 回合潮讯：掠袭者撕走了 9 里格海域——绯红的旗帜仍飘扬在 91% 的海面上。",
		"ターン 2：準備クエスト開始：ラム酒の輸送。",
		"ターン 2：宝箱！カード 3 枚——1 枚選べ。",
		"ターン 2：カード獲得：潮の巫女ヌアラ（複製 x2）。",
		"ターン 2：船医は解剖学を息も継げない一つの稽古にしてしまう。触れられると好い場所を一つずつ名指しし、唇と指で実地に示してくる。お前は呻きながら、それを全部言い返せるようになった。（潮の巫女ヌアラ 経験値 +2）",
		"ターン 2：軍需品を確保：戦果 +2（ターン合計 2）。",
		"ターン 2：クエスト完了：ラム酒の輸送。",
		"ターン 2：嵐牙の船長マレン との静かな夜：彼女はラム酒と塩の味がする。揺れるハンモックの中でお前を迎え入れ、腰で潮の拍子を刻む。ランプの芯が燃え尽きるまで、どちらも止まらなかった。（経験値 +2）",
		"ターン 2 の潮告：略奪者たちが 9 リーグの海を切り取った——紅の旗はまだ海の 82% に翻っている。"
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 82,
	"tickets": 0,
	"turn": 3
}
