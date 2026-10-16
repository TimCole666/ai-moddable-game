# AI-Moddable Game (working title TBD)

A single-player, open-source, adult game in which players extend content and mechanics through AI. Built with Godot 4.7 (GDScript); informed by a throwaway TS prototype (branch `prototype/theme-mod-loop`).

## Language

**Core Loop**: The v1 rule set for a run. Each turn moves through four phases in order: preparation, operation, base, and war report. Battles are AP card battles with pre-announced enemy actions, quests are branch trees, and each battle win offers a Card Draft. Replaces the Rance-10 Rules as the v1 rules; subject to revision after the first full playtest.

**Run**: One full game, from start to a win or a loss. A run has about 15 chapters.

**Chapter**: One stage of a run, with a preparation group and an operation group of quests, lasting 4 to 5 turns.

**Realm**: The single value shared across a run. Each war report lowers it. At zero the run is lost; after the last chapter, with the Realm above zero, the run is won. Avoid: territory.

**Card Draft**: After each battle win, the player picks one of three candidate cards. Drafted cards last only for the current run.

**Rance-10 Rules**: The M1 rule set, with short runs and no carry-over between runs. Kept in the code as a native implementation for replay coverage and comparison; not a Theme Pack, and not part of the v1 Core Loop.

**Engine**: The deterministic rules layer. It validates Theme Packs and runs both the native rules and the rules written in packs. AI output reaches the game only through the engine.

**Theme Pack**: A validated JSON file that reskins the game and can extend its rules. It sets names, text, icons, art, palette, part parameters, and chapter structure, and it may add new parts and rules. Its text ships in Chinese, English, and Japanese; all three are required by the v1 contract. Authored by the AI Entry, an Agent Kit, or by hand. Avoid: mod, skin.

**Part**: A named mechanic component with state fields, parameters within validated ranges, and hooks. The engine provides built-in parts, such as Fatigue (optional); a Theme Pack may enable and parameterize them, or add new parts.

**AI Entry**: In-game generation through a provider the player configures — a cloud API key or a local endpoint. The game ships no hosted AI. Avoid: Official AI Entry, hosted entry, Local Path.

**Agent Kit**: Ready-made skill/plugin integrations that let coding agents (Claude Code, Codex) author theme packs in their native workflow.

**Own-Agent Path**: Authoring packs offline with any external AI agent or tool and importing them; the engine validates before running. Avoid: BYOK (that framing was rejected for the default path).

**Adult Content**: Explicit sexual text or imagery, produced only through the player's configured provider or the Own-Agent Path — never through any hosted service.
