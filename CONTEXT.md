# AI-Moddable Game (working title TBD)

A single-player, open-source, adult game in which players extend content and mechanics through AI. Built with Godot 4.7 (GDScript); informed by a throwaway TS prototype (branch `prototype/theme-mod-loop`).

## Language

**Core Loop**: The Rance-10-style rules set — turn phases, branch-choice quests, AP card battles with pre-announced enemy actions, and collection. Adopted as the product's v1 rules; revisited only after the 30-minute playtest.

**Engine**: The deterministic rules layer that validates packs and interprets them into gameplay. AI output reaches the game only through the engine.

**Theme Pack**: A validated data file that reskins the game — names, icons, flavor text, palette, and part parameters — authored by the AI Entry, an Agent Kit, or by hand. Its text ships in Chinese, English, and Japanese; all three are required by the v1 contract. Avoid: mod (reserved for the future code-carrying packs), skin.

**Part**: A fixed mechanic component the engine provides (e.g., Fatigue) that a pack may enable and parameterize within validated ranges.

**AI Entry**: In-game generation through a provider the player configures — a cloud API key or a local endpoint. The game ships no hosted AI. Avoid: Official AI Entry, hosted entry, Local Path.

**Agent Kit**: Ready-made skill/plugin integrations that let coding agents (Claude Code, Codex) author theme packs in their native workflow.

**Own-Agent Path**: Authoring packs offline with any external AI agent or tool and importing them; the engine validates before running. Avoid: BYOK (that framing was rejected for the default path).

**Adult Content**: Explicit sexual text or imagery, produced only through the player's configured provider or the Own-Agent Path — never through any hosted service.
