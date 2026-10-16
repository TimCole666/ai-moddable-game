# Spec: v1 — Full Game

Status: ready-for-agent

## Problem Statement

M1 proved two things: the pack-import loop works, and the Rance-10-style rules run in Godot. It is still a demo. A run lasts 8 turns, with 4 enemies, 6 characters, and 7 skills. Nothing carries over between runs. There is no audio. The game has one main screen, with no title or end screen.

Pack authors can reskin names, text, colors, and part parameters, but they cannot add new mechanics. The project promises that players extend content and mechanics through AI. M1 delivers only the content half.

The owner has decided that the Rance-10-style rules do not yet feel like a game worth playing. They will be replaced with a strategy-leaning rule set. Packs will also be able to add new parts and new rules.

## Solution

Build the full v1 game in Godot 4.7 (GDScript):

- A run of about 15 chapters, 10 hours or more, with 4 to 5 turns per chapter.
- A new strategy-leaning core rule set. The four turn phases (preparation, operation, base, war report) stay.
- One shared realm value for the whole run. The run is lost when the realm reaches zero. It is won after the last chapter with the realm above zero.
- Card drafting within a run. After a battle win, the player picks one of three cards.
- Quests as branch trees, where the number of forks varies by step.
- Adult text inside chapter events, gated as before.
- A title screen, an end screen, a background for each chapter, and sound effects and music from free assets.
- Theme packs stay pure JSON. Rules inside a pack are expression trees, evaluated by a self-written, deterministic interpreter under budgets. Packs can add new parts and new rules. Hooks can attach to any engine state change.
- The current Rance-10-style rules stay as native code, for replay coverage and for comparison.

## User Stories

1. As a player, I want to start a new run from the title screen, so that I can begin a full game without setup.
2. As a player, I want a run of about 15 chapters, so that the game lasts ten hours or more.
3. As a player, I want each chapter to have 4 to 5 turns, so that every chapter has a clear shape.
4. As a player, I want each turn to move through preparation, operation, base, and war report in order, so that every turn has the same rhythm.
5. As a player, I want quests to be branch trees with a variable number of forks, so that my route choices change what I face later.
6. As a player, I want node types to include battle, auto, chest, heal, gains, medal, and event, so that routes feel varied.
7. As a player, I want AP card battles where enemy actions are announced one round in advance, so that spending AP now or bracing is a real choice.
8. As a player, I want battle rules to stay as they were in M1, so that what I learned still applies.
9. As a player, I want to pick one of three cards after a battle win, so that each run builds a different deck.
10. As a player, I want drafted cards to last only for the current run, so that every run starts fresh.
11. As a player, I want the realm value to carry across all chapters of a run, so that early choices matter late.
12. As a player, I want the run to end in a loss when the realm reaches zero, so that the war has real stakes.
13. As a player, I want to win after the last chapter when the realm is above zero, so that finishing the run means something.
14. As a player, I want the war report each turn to show how the realm changed, so that I can see the cost of my choices.
15. As a player, I want a base phase with meal tickets and rest options, so that I can recover and prepare between operations.
16. As a player, I want Fatigue to be an optional part that a pack can switch on or off, so that a pack can change resource pressure.
17. As a player, I want an end screen that shows whether I won or lost, with a short run summary, so that each run has a clear ending.
18. As a player, I want each chapter to have its own background image, so that the world changes as I advance.
19. As a player, I want sound effects for cards, hits, and chests, so that my actions feel responsive.
20. As a player, I want background music on the title screen, in battle, and at base, so that the game has atmosphere.
21. As a player, I want the whole interface in Chinese, English, and Japanese, and I want to switch languages mid-run without losing state, so that I can play in my own language.
22. As a player, I want adult text in chapter events, so that the game matches its rating.
23. As a player using the web build, I want adult text replaced by the all-ages line, so that the web version stays all-ages.
24. As a player, I want the game to be fully playable offline with the built-in pack, so that I never need an AI setup just to play.
25. As a player, I want every card, enemy, and quest name shown in my language, so that no raw id ever appears on screen.
26. As a player, I want to reach the first battle without guidance, so that onboarding works without a wall of text.
27. As a player, I want to choose a pack from the title screen, so that I can reskin the game before a run.
28. As a player, I want a single settings screen that holds the AI provider panel, so that generation settings live in one place.
29. As a player, I want the chapter start to show the chapter title and its background, so that each chapter feels like a stage.
30. As a player, I want the card draft to show each card's name and effect in my language, so that I can choose with confidence.
31. As a player, I want the current realm shown at all times, so that I always know how close I am to losing.
32. As a player, I want a pack to be able to swap names, icons, and palette without changing rules, so that a pack can reskin the game cleanly.
33. As a pack author, I want to write rules as JSON expression trees, so that I do not need to know GDScript.
34. As a pack author, I want to add new parts with validated parameter ranges, so that I can introduce mechanics the engine does not ship with.
35. As a pack author, I want to add new rules that hook into engine state changes, so that my mechanics can react to any event.
36. As a pack author, I want validation to list every error with a specific reason, so that I can fix a pack without guessing.
37. As a pack author, I want an invalid pack to leave the game state unchanged, so that importing is always safe.
38. As a pack author, I want every text field to exist in all three languages, so that my pack plays in every language.
39. As a pack author, I want to export the current pack as JSON, so that I have a working example of the format.
40. As a pack author, I want a pack-contract document that fully specifies the expression format, the validation reasons, and worked examples, so that I can write a pack from scratch.
41. As a pack author, I want a rule that exceeds its computation budget to fail with a clear reason and no state change, so that one bad rule cannot freeze the game.
42. As a pack author, I want rules to reach only engine-provided functions, so that a pack cannot touch files, the network, or the clock.
43. As a pack author, I want validation to reject unknown functions and unknown state paths at import time, so that errors show up before a run starts.
44. As a pack author, I want the same pack, seed, and player actions to produce the same run, so that I can reproduce any bug.
45. As a player, I want to set up a generation provider with a cloud key or a local endpoint, so that I can create packs with a service I already use.
46. As a player, I want AI-generated packs validated like any other pack, so that a bad generation cannot break the game.
47. As a player, I want every generation cached, so that identical requests never cost money twice.
48. As an agent author using Claude Code or Codex, I want an Agent Kit that documents the expression format, so that my agent writes valid rules on the first try.
49. As an agent author, I want a worked round trip showing an external agent writing a pack that validates and plays, so that I can trust the kit.
50. As the owner, I want the 15 chapters written in English first and then translated into Chinese and Japanese, so that the English reads as the source text.
51. As the owner, I want chapters drafted and reviewed in batches, so that I can catch problems before the whole run is written.
52. As the owner, I want every image generation batch to show a cost estimate before it runs, so that I approve spending first.
53. As the owner, I want each audio asset's license recorded and checked against CC0 or CC-BY, so that the release stays legal.
54. As the owner, I want the native Rance-10 replays to stay green, so that any regression in the old rules shows up.
55. As the owner, I want replays that cover every engine state-change kind at least once, so that the hook system is tested across its whole surface.
56. As the owner, I want a seeded replay to produce identical state on repeated runs, so that determinism is proven.
57. As the owner, I want one full replay that wins the game and one that loses it, so that both ends of the run are tested.
58. As the owner, I want the playtest notes template ready when all chapters are done, so that feedback is recorded the same way every time.
59. As the owner, I want decisions about the rule replacement and the code-pack format recorded as ADRs, so that future readers know why.
60. As the owner, I want the glossary to match the new design, so that the project uses one set of terms.
61. As a maintainer, I want all rule logic to run behind the existing engine seam, so that UI code cannot bypass the rules.
62. As a maintainer, I want the expression interpreter to be a pure module with one entry point, so that I can test it alone.
63. As a maintainer, I want hooks unable to change state directly, only through whitelisted engine functions, so that every change can be replayed.
64. As a maintainer, I want hook order to be deterministic, so that the same packs always behave the same way.
65. As a maintainer, I want the M1 spec archived and this spec to be the single source of scope, so that the team does not follow two specs.
66. As a player, I want the battle view, base view, and war report to be clearly separate panels within the main screen, so that each phase is easy to read.

## Implementation Decisions

Run structure
- A run has a fixed sequence of about 15 chapters. Each chapter contains one preparation group and one operation group of quests, on branch trees, lasting 4 to 5 turns. Turn counts and quest trees are data in the built-in pack, so packs can change them.
- Each turn runs preparation, operation, base, and war report in that order.
- Realm is one value per run. It starts at M1's default of 100. Each war report reduces it by 13 minus 2 per gain, with a floor of 3 (M1 defaults, pack-tunable). The run ends in a loss when the realm is zero or below. It ends in a win after the final chapter when the realm is above zero.
- Quests are branch trees. The number of forks varies by step, as defined in the data.
- The node types from M1 are kept: battle, auto, chest, heal, gains, medal, and event.
- Card draft: after each battle win, the player sees three candidate cards and takes one. Drafted cards exist only in the current run.
- No cross-run progression. Duplicate cards grant no permanent bonus.
- The base phase is an independent phase with M1's base options (meal tickets and rest).
- Battle rules stay as in M1: pre-announced enemy actions, combos, weaknesses, guards, and hexed actions. v1 adds no new battle mechanics. The replacement is in the turn-level strategy rules, not in battle.
- The party roster (six characters) and the skill set (seven skills) carry over from M1 into the built-in pack. Packs may add more through parts and rules.

Rules and the engine
- The new strategy rule set is the core rule set for v1. The built-in pack carries it as expression trees, so the interpreter runs the official content.
- The native Rance-10-style rules stay in the code, not in a pack, for replay coverage and for comparison.

Pack format
- Packs stay JSON. Rules are expression trees. The format version rises to 2. Validation gates features by version, as ADR-0002 requires.
- Expression trees use a closed set of node kinds: literals, reads from a read-only view of state, arithmetic, comparison, boolean logic, conditionals, list selection, and calls to whitelisted engine functions. v1 has no unbounded loops. Iteration happens only through whitelisted engine functions.
- Budgets: every evaluation has a node-count budget. Every hook invocation and every turn has a total budget. Exceeding a budget is an error with a reason, and the step applies no change.
- Determinism: no clock, no file access, no network, and no unseeded randomness. Randomness comes only from the engine's seeded generator, passed in as an explicit input. The same pack, seed, and actions produce the same state.
- Static validation at import checks node kinds, engine function names, state paths, type mismatches that can be detected statically, and budget bounds. Every error carries a reason.

Parts
- A part is a named bundle of state fields, parameters with validated ranges, and hooks. Packs can add parts.
- Fatigue becomes a built-in optional part. A pack enables or disables it, and sets its parameters within range.
- Part names and descriptions are trilingual, as the contract requires.

Hooks
- Any state change the engine emits can trigger hooks. Hooks are registered by enabled parts and rules.
- Hook order is deterministic: pack load order, then declared priority, then id.
- A hook cannot change state directly. It can only call whitelisted engine functions. Those calls go through the engine's normal step path, and their state changes can trigger further hooks. Hook recursion depth is bounded (default 3, to be tuned).

Validation and safety
- validate_pack returns the full list of reasons. A failed import leaves state unchanged, as M1 requires.
- Every new text field, for parts and rules alike, is required in zh, en, and ja.

Interfaces
- The GameEngine public API stays the single seam for the UI and for tests: validate_pack, new_game, step, get_state, available_actions, context_line, and the chrome and art accessors.
- The UI still never invents actions. Legal actions come only from available_actions.
- New interpreter entry point: a pure function. Given an expression, a read-only view of state, and a budget, it returns a value or a structured error. This is the only new seam.

Schema changes
- Pack version 2 adds: rule expression trees, optional part definitions, chapter structure (chapter count, turns per chapter, branch trees), realm parameters, the card draft pool, and references to backgrounds and audio. Exact field names live in the pack-contract document, not in this spec.

Content and presentation
- Adult content is text only, placed in chapter events, and may appear in any chapter. On the web export, the all-ages line replaces it, using the ADR-0005 mechanism. Adult images are out of scope.
- Chapter backgrounds, the title screen, and the end screen are image assets, produced by image generation after the owner approves the estimated cost.
- Audio: sound effects for cards, hits, chests, and UI. Music loops for the title screen, battle, and base. Assets come from free libraries, must be CC0 or CC-BY compatible, and each one gets a license record. No audio generation.
- All interface and pack text exists in zh, en, and ja. Chapter content is written in English first, then translated.

AI Entry and Agent Kit
- AI Entry generates version-2 packs, including expression trees. Generated packs go through the same validation as any other pack, and results are cached first, as in M1.
- The Agent Kit documents the version-2 expression format, the validation reasons, and worked examples. It replaces the GDScript DSL plan in ADR-0007.

Testing Decisions

What makes a good test here: it exercises external behavior through the engine seam and asserts visible state, log lines, and validation reasons. It does not assert internal structure.

- Replays drive new_game, step, and get_state. Actions are chosen from available_actions, as the UI does.
- The interpreter is tested through its entry point: each node kind, each budget breach, malformed inputs, and sandbox denials (unknown function, unknown state path).
- Determinism: the same pack, seed, and actions produce identical state snapshots on two separate runs.
- Hook coverage: across the replay suite, every engine state-change kind triggers at least one hook.
- Chapter flow: one replay wins the full run, and one replay loses it through the realm.
- Card draft: picks are deterministic under a seed, and drafted cards do not carry into a new run.
- Native rules: the existing M1 replays stay green on the native Rance-10 rules.
- Import safety: invalid packs return reasons and leave state unchanged. Over-budget rules fail cleanly.
- Language switch mid-run keeps state (M1 test, retained).
- Adult gate: the web-style gate shows the all-ages line (M1 test, retained).
- Pack round trip: export, then import, yields a pack that validates and plays identically.
- Not automated: art quality, audio feel, and UI feel. These are covered by the playtest, using the notes template.
- Prior art: the replay suite, the view smoke test, and the pack and balance checks already in the project.

## Out of Scope

- Cross-run progression of any kind: unlocks, collection carry-over, or saved power.
- Adult image generation.
- Any hosted AI service.
- Code packs with access to files, the network, the clock, or unseeded randomness.
- A mod-sharing UI, a pack browser, or an in-game code editor.
- Languages beyond zh, en, and ja.
- Music composition or audio generation.
- Adult content in the web build.
- itch.io publishing and the project name.
- Moving the tracker to GitHub Issues.
- Multiplayer.

## Further Notes

Defaults to confirm (set in this spec, not yet decided by the owner):
- Realm numbers reuse M1's defaults.
- Fatigue is on by default in the built-in pack.
- Hook recursion depth and per-turn budgets are placeholders to tune.
- The party roster and skill set carry over from M1.

Open questions to settle before implementation:
- Version 1 compatibility: do existing version-1 packs still import, or are they rejected with a version reason?
- In-run saving: none, or save and resume within a run? A 10-hour run without any save is a real risk.
- How the native Rance-10 rules are reached: developer-only, or a player-visible comparison option?
- Turn counts and quest-tree sizes for each of the 15 chapters.

Documents to update when this spec is accepted:
- A new ADR replacing ADR-0007, covering the code-pack format: JSON expression trees with a self-written interpreter.
- A new ADR recording the core rule replacement: the Rance-10-style rules are replaced by the strategy rules, and the native Rance-10 rules are kept.
- Amend ADR-0002: its line about later sandboxed code now applies to version 2.
- Update CONTEXT.md: the Core Loop, Theme Pack, mod, Part, and Engine definitions.
- Archive the M1 spec.

Risks:
- The scope is large for one person working full time. No schedule has been set.
- The first full playtest comes after all 15 chapters are written. If the rules are wrong, the owner learns it late. Testing after chapter one was considered and not chosen.
- Any-time hooks widen the test surface. The replay plan above is the mitigation.
- Image cost: each batch needs an estimate and the owner's approval first.
- Each audio license must be checked by hand.
- The new rules are written as expression trees inside the built-in pack. This means the interpreter must be correct before the built-in content works.

Source: decisions from the grilling session on 2026-10-17.
