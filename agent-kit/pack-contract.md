# Theme Pack Contract v1

Status: enforced contract (engine version 1). This document fully specifies the Theme Pack v1 format: every field, every validation reason with its exact trigger, and a worked example per section. An external coding agent can author valid packs from this document alone — no game source reading required.

Audience: coding agents (Claude Code, Codex) and hand authors on the Own-Agent Path (ADR-0006). A Theme Pack is a **pure JSON data file** that reskins the game — names, icons, flavor text, palette, and part parameters. It never carries code.

By-example references shipped with the engine:

- `game/engine/builtin_pack.json` — the default pirate-theme pack (`bodyClass: "seas"`)
- `game/engine/packs/ironroad.json` — a frontier-railroad pack (`bodyClass: "iron"`)

---

## 1. Top level

A pack is a single JSON object with exactly these fields (extra fields are ignored; missing fields are rejected):

```
pack := {
  id:        string   — non-empty; unique pack identifier (lowercase-slug recommended)
  version:   integer  — must be exactly 1
  accent:    string   — UI accent color, "#rrggbb" (7 chars: # + 6 hex)
  bodyClass: string   — palette id: "seas" or "iron"
  parts:     object   — part configuration (section 2)
  text:      object   — trilingual text, keys en, zh, ja (section 3)
}
```

Validation reasons (checked in this order; first failures at each level are all reported, reason format `dotted.path: problem`):

| Trigger | Exact reason |
|---|---|
| `id` missing or not a non-empty string | `pack.id: required non-empty string` |
| `version` missing or not an integer (booleans are NOT integers) | `pack.version: required integer` |
| `version` an integer other than 1 (0, negative, 2, future) | `pack.version: unsupported version N (this engine interprets v1)` |
| `accent` missing or not a string | `pack.accent: required #rrggbb string` |
| `accent` not matching `#rrggbb` (case: use lowercase hex; must start with `#`, exactly 6 hex digits after) | `pack.accent: must match #rrggbb` |
| `bodyClass` missing or not a string | `pack.bodyClass: required string` |
| `bodyClass` not a known palette | `pack.bodyClass: unknown palette X (known: seas, iron)` |
| `parts` missing or not an object | `pack.parts: required object` |
| `text` missing or not an object | `pack.text: required object` |
| one of `en`, `zh`, `ja` missing or not an object | `pack.text.<lang>: required object` |

**Version gate:** the engine declares `PACK_FORMAT_VERSION := 1`. Missing/non-integer version fails with "required integer"; any integer ≠ 1 fails with "unsupported version". There is no fallback and no leniency — a v2 pack will not load under a v1 engine.

### Worked example (top level)

```json
{
  "id": "starfall",
  "version": 1,
  "accent": "#7a4bd6",
  "bodyClass": "seas",
  "parts": { "...": "see section 2" },
  "text":  { "...": "see section 3" }
}
```

---

## 2. `parts` — part configuration

v1 ships exactly one Part: **Fatigue**. Every pack must include the full `parts.fatigue` object (enable it or disable it, but the object must be present and complete).

```
parts.fatigue := {
  enabled: bool      — whether the Fatigue part is active
  params: {
    threshold:  integer > 0   — fatigue level at which the penalty kicks in
    apPenalty:  integer >= 0  — AP regen lost once threshold is reached
  }
}
```

Validation reasons:

| Trigger | Exact reason |
|---|---|
| `parts` missing or not an object | `pack.parts: required object` |
| `parts.fatigue` missing or not an object | `pack.parts.fatigue: required object` |
| `parts.fatigue.params` missing or not an object | `pack.parts.fatigue.params: required object` |
| `enabled` missing or not a bool | `pack.parts.fatigue.enabled: required bool` |
| `threshold` missing, not an integer, or <= 0 | `pack.parts.fatigue.params.threshold: required integer > 0` |
| `apPenalty` missing, not an integer, or < 0 | `pack.parts.fatigue.params.apPenalty: required integer >= 0` |

Behavior when enabled: once session `fatigue >= threshold`, battles start with reduced AP (`ap_max = 6 − apPenalty`, `regen = 2 − apPenalty`, clamped to at least 1 / 0). Choose modest values: `threshold` 2–4 and `apPenalty` 0–2 are sane.

### Worked example (parts)

```json
"parts": {
  "fatigue": {
    "enabled": true,
    "params": { "threshold": 3, "apPenalty": 1 }
  }
}
```

Disabling it is equally valid: `"enabled": false` — the `params` are still required and validated.

---

## 3. `text` — trilingual text (en, zh, ja)

All three locales are **required in v1** — there is no fallback to another language. Each locale is a `localeText` object with identical structure; strings must be written natively in that language (not machine-empty placeholders).

```
localeText := {
  name:         non-empty string            — pack display name
  tagline:      non-empty string            — one-line pitch
  factions:     array of EXACTLY 3 entries, each { name: non-empty string, icon: non-empty string }
  cards:        object; every roster id (hero, tank, healer, mage, striker, archer)
                → { name: non-empty string, icon: non-empty string }
  skillNames:   object; every skill id (slash, heavy, multi, blast, mend, guard, hex)
                → non-empty string
  enemies:      object; every enemy id (grunt, brute, shaman, boss)
                → { name: non-empty string, icon: non-empty string }
  enemyActions: object; every enemy-action id (e_slash, e_heavy, e_bolt)
                → non-empty string
  questTitles:  object; every quest id (prepA, prepB, opA, opB)
                → non-empty string
  flavor: {
    ev_exp:     array of 1+ non-empty strings   — training event lines
    ev_gains:   array of 1+ non-empty strings   — logistics event lines
    base:       array of 1+ non-empty strings   — base-phase rest lines
    reportTpl:  string containing {turn} {loss} {left}   — war-report template
  }
  parts: {
    fatigue: { name: non-empty string, icon: non-empty string }
  }
}
```

Fixed id vocabulary (extra keys are allowed and ignored; these keys are **required** in every locale):

- **cards** (the fixed six-leader party, in party order): `hero`, `tank`, `healer`, `mage`, `striker`, `archer`
- **skillNames**: `slash`, `heavy`, `multi`, `blast`, `mend`, `guard`, `hex`
- **enemies**: `grunt`, `brute`, `shaman`, `boss`
- **enemyActions**: `e_slash`, `e_heavy`, `e_bolt`
- **questTitles**: `prepA`, `prepB`, `opA`, `opB`

`reportTpl` placeholders: `{turn}` = current turn number, `{loss}` = realm points lost, `{left}` = remaining realm as a percent (rendered like `91%`). Write the template so all three fit naturally, e.g. `"Turn {turn} dispatch: raiders cut {loss} miles of line. {left} of the road still runs."`

`icon` strings are short emoji/glyphs (1–2 code points recommended); they must be non-empty.

### Validation reasons (per locale `<lang>` ∈ en, zh, ja; checked in order: name/tagline → factions → cards → skillNames → enemies → enemyActions → questTitles → flavor → parts)

| Trigger | Exact reason |
|---|---|
| `text.<lang>` missing or not an object | `pack.text.<lang>: required object` |
| `name` missing or empty | `pack.text.<lang>.name: required non-empty string` |
| `tagline` missing or empty | `pack.text.<lang>.tagline: required non-empty string` |
| `factions` missing or not an array of exactly 3 | `pack.text.<lang>.factions: required array of exactly 3 entries` |
| a faction entry is not an object with non-empty `name` and `icon` strings | `pack.text.<lang>.factions[<i>]: required object with name and icon strings` |
| `cards` missing or not an object | `pack.text.<lang>.cards: required object` |
| a card entry missing or lacking non-empty `name`/`icon` | `pack.text.<lang>.cards.<id>: required object with name and icon strings` |
| `skillNames` missing or not an object | `pack.text.<lang>.skillNames: required object` |
| a skill name missing, empty, or not a string | `pack.text.<lang>.skillNames.<id>: required non-empty string` |
| `enemies` missing or not an object | `pack.text.<lang>.enemies: required object` |
| an enemy entry missing or lacking non-empty `name`/`icon` | `pack.text.<lang>.enemies.<id>: required object with name and icon strings` |
| `enemyActions` missing or not an object | `pack.text.<lang>.enemyActions: required object` |
| an enemy action name missing, empty, or not a string | `pack.text.<lang>.enemyActions.<id>: required non-empty string` |
| `questTitles` missing or not an object | `pack.text.<lang>.questTitles: required object` |
| a quest title missing, empty, or not a string | `pack.text.<lang>.questTitles.<key>: required non-empty string` |
| `flavor` missing or not an object | `pack.text.<lang>.flavor: required object` |
| a flavor array (`ev_exp`, `ev_gains`, `base`) missing, empty, or containing a non-string/empty entry | `pack.text.<lang>.flavor.<key>: required array of at least 1 non-empty string` |
| `reportTpl` missing, not a string, or not containing `{turn}`, `{loss}`, and `{left}` | `pack.text.<lang>.flavor.reportTpl: required string containing {turn} {loss} {left}` |
| `parts` missing or not an object | `pack.text.<lang>.parts: required object` |
| `parts.fatigue` missing or lacking non-empty `name`/`icon` | `pack.text.<lang>.parts.fatigue: required object with name and icon strings` |

### Worked example (one full locale — en; zh and ja mirror it with native text)

```json
"en": {
  "name": "Starfall Vanguard",
  "tagline": "a celestial war in three languages",
  "factions": [
    { "name": "Comet Court", "icon": "☄️" },
    { "name": "Void Choir", "icon": "🌌" },
    { "name": "Lens Guild", "icon": "🔭" }
  ],
  "cards": {
    "hero":    { "name": "Star Champion", "icon": "⭐" },
    "tank":    { "name": "Meteor Shield", "icon": "🛡️" },
    "healer":  { "name": "Dawn Cleric",   "icon": "🌟" },
    "mage":    { "name": "Nebula Weaver", "icon": "🌠" },
    "striker": { "name": "Comet Blade",   "icon": "💫" },
    "archer":  { "name": "Orion Sentinel","icon": "🏹" }
  },
  "skillNames": {
    "slash": "Star Slash", "heavy": "Meteor Drop", "multi": "Shower of Blades",
    "blast": "Supernova", "mend": "Moonlight", "guard": "Aegis", "hex": "Eclipse"
  },
  "enemies": {
    "grunt":  { "name": "Void Spark",  "icon": "✨" },
    "brute":  { "name": "Gravity Ox",  "icon": "🐂" },
    "shaman": { "name": "Singularity","icon": "🕳️" },
    "boss":   { "name": "The Devourer","icon": "🐉" }
  },
  "enemyActions": { "e_slash": "Tail Lash", "e_heavy": "Body Slam", "e_bolt": "Gamma Flash" },
  "questTitles": {
    "prepA": "Chart the Sky", "prepB": "Fuel the Lenses",
    "opA": "Hold the Observatory", "opB": "Descent into the Void"
  },
  "flavor": {
    "ev_exp":   ["An astronomer teaches you to read the comet's tail."],
    "ev_gains": ["The crew hauls starmetal up the mountain."],
    "base":     ["Tea cools under alien constellations."],
    "reportTpl": "Turn {turn} report: the void took {loss} leagues. {left} of the sky remains ours."
  },
  "parts": { "fatigue": { "name": "Starweariness", "icon": "😵‍💫" } }
}
```

---

## 4. Structural summary — the minimal valid pack skeleton

Copy this skeleton and fill in every marked slot in all three locales. Do not leave any placeholder non-empty check to chance: empty strings fail.

```json
{
  "id": "<your-pack-id>",
  "version": 1,
  "accent": "#rrggbb",
  "bodyClass": "seas",
  "parts": {
    "fatigue": { "enabled": false, "params": { "threshold": 2, "apPenalty": 1 } }
  },
  "text": {
    "en": { "<localeText — section 3>" },
    "zh": { "<localeText — section 3, in Chinese>" },
    "ja": { "<localeText — section 3, in Japanese>" }
  }
}
```

---

## 5. Numbers in JSON

JSON has no int/float distinction, and the engine's JSON parser reads all numbers as floats. The validator accepts integral floats, so `"version": 1.0` in a file is valid — but **write integers as integers** (`1`, not `1.0`) for readability. Bools must be JSON `true`/`false` (a `1` is not a bool and fails `enabled: required bool`).

## 6. Authoring checklist

1. `id` non-empty; `version` exactly `1`; `accent` matches `#rrggbb`; `bodyClass` is `seas` or `iron`.
2. `parts.fatigue` complete: `enabled` bool, `threshold` integer > 0, `apPenalty` integer >= 0.
3. `text` has all of `en`, `zh`, `ja` — each with every field of section 3, every fixed id present, no empty strings, `reportTpl` containing `{turn}`, `{loss}`, `{left}`.
4. Text is genuinely trilingual — translate, do not duplicate.
5. Validate with the engine before shipping:
   `godot --headless --path game res://tests/run_pack.tscn -- /abs/path/to/pack.json`
   It prints `VALID` + a played battle transcript on success, or the exact `pack.*` reasons on failure. Exit code 0 = valid and playable.

## 7. How packs get into the game

- `load_pack_file(path)` — read + parse + validate; returns `{ok, errors, pack}` with the exact reasons above.
- In-session: the `select_pack` / `import_pack` actions switch packs (mid-session switching is allowed and preserves state; a rejected switch changes nothing).
- `export_pack(path)` writes the current pack back as JSON (tab-indented) — export → import is a lossless round-trip.
