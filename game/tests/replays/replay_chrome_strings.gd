extends ReplayBase

## Every chrome string exists in all three languages: the chrome() accessor
## returns, for en/zh/ja, the same key set everywhere (phases x4, results,
## quest pools, buttons, ui labels, and the full log-template table), with
## non-empty strings and distinct zh/ja text. Also pins the set_language
## rejection reason for an unknown language (deliberately failed step).

var _bad_lang_errors: PackedStringArray = PackedStringArray()


func replay_name() -> String:
	return "chrome_strings_trilingual"


func actions() -> Array:
	return [
		# Deliberately invalid: must be rejected with a pinned reason and
		# leave state (and the language) untouched.
		Callable(self, "_try_bad_language"),
	]


func _try_bad_language() -> void:
	var result := GameEngine.step({"type": EngineCore.ACTION_SET_LANGUAGE, "lang": "ko"})
	_bad_lang_errors = result["errors"]


func checks() -> PackedStringArray:
	var problems := PackedStringArray()
	if _bad_lang_errors.size() != 1 or _bad_lang_errors[0] != "set_language.lang: invalid language ko (known: en, zh, ja)":
		problems.append("set_language(ko) errors expected [set_language.lang: invalid language ko (known: en, zh, ja)], got %s" % [_bad_lang_errors])
	if GameEngine.get_language() != "en":
		problems.append("language after rejected set_language: expected en, got %s" % [GameEngine.get_language()])
	var en := GameEngine.chrome("en")
	var reference := _chrome_problems(en, "en")
	if not reference.is_empty():
		problems.append_array(reference)
	for lang in ["zh", "ja"]:
		var problems_lang := _chrome_problems(GameEngine.chrome(lang), lang)
		if not problems_lang.is_empty():
			problems.append_array(problems_lang)
		var locale := GameEngine.chrome(lang)
		if (locale["log"] as Dictionary).hash() == (en["log"] as Dictionary).hash():
			problems.append("chrome.%s.log: identical to en (not localized)" % [lang])
		if (locale["phases"] as Array).hash() == (en["phases"] as Array).hash():
			problems.append("chrome.%s.phases: identical to en (not localized)" % [lang])
	# Unknown language yields an empty chrome dict; chrome() with no argument
	# follows the session language.
	if not GameEngine.chrome("ko").is_empty():
		problems.append("chrome(ko): expected {} for an unknown language")
	if GameEngine.chrome().hash() != en.hash():
		problems.append("chrome(): expected the current-language chrome (en)")
	return problems


## Structural completeness check for one locale's chrome dict.
func _chrome_problems(chrome: Dictionary, lang: String) -> PackedStringArray:
	var problems := PackedStringArray()
	if chrome.is_empty():
		problems.append("chrome.%s: empty" % [lang])
		return problems
	for section in ["results", "questPools", "buttons", "ui", "log"]:
		if not (chrome.get(section, null) is Dictionary):
			problems.append("chrome.%s.%s: expected dictionary" % [lang, section])
	if not (chrome.get("phases", null) is Array) or (chrome["phases"] as Array).size() != 4:
		problems.append("chrome.%s.phases: expected exactly 4 phase names" % [lang])
		return problems
	var en := GameEngine.chrome("en")
	for key in (en["results"] as Dictionary):
		if not _nonempty((chrome["results"] as Dictionary).get(key, null)):
			problems.append("chrome.%s.results.%s: missing" % [lang, key])
	for key in (en["questPools"] as Dictionary):
		if not _nonempty((chrome["questPools"] as Dictionary).get(key, null)):
			problems.append("chrome.%s.questPools.%s: missing" % [lang, key])
	for key in (en["buttons"] as Dictionary):
		if not _nonempty((chrome["buttons"] as Dictionary).get(key, null)):
			problems.append("chrome.%s.buttons.%s: missing" % [lang, key])
	for key in (en["ui"] as Dictionary):
		if not _nonempty((chrome["ui"] as Dictionary).get(key, null)):
			problems.append("chrome.%s.ui.%s: missing" % [lang, key])
	for key in (en["log"] as Dictionary):
		if not _nonempty((chrome["log"] as Dictionary).get(key, null)):
			problems.append("chrome.%s.log.%s: missing" % [lang, key])
	for key in (chrome["log"] as Dictionary):
		if not (en["log"] as Dictionary).has(key):
			problems.append("chrome.%s.log.%s: not in the en key set" % [lang, key])
	return problems


func _nonempty(value: Variant) -> bool:
	return value is String and not (value as String).is_empty()


func expected_state() -> Dictionary:
	return {
	"base_options": null,
	"battle": null,
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
		"Turn 1: you are in the Preparation phase — start a preparation quest, work through its steps, then End Phase.",
		"Turn 1: every quest step offers two branches: fights, chests, rest sites, and war supplies. Choose a side.",
		"Turn 1: in battle the enemy's next move is announced — spend AP to strike now, or brace to soften the blow.",
		"Turn 1: the buttons below (End Turn, End Phase, ...) drive the session; the header tracks realm, medals, meal tickets, and fatigue."
	],
	"medals": 0,
	"pack_id": "builtin",
	"phase": 0,
	"quest": null,
	"realm": 100,
	"tickets": 0,
	"turn": 1
}
