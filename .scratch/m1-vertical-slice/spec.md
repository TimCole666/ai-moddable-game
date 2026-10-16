# Spec: M1 — Godot Vertical Slice

Status: ready-for-human

## Problem Statement

The game exists only as a throwaway TypeScript web prototype. It proved the pack-import loop and the Rance-10-style rules, but it cannot answer the real questions: is the Core Loop fun across a 2-3 hour arc, does the Theme Pack contract survive a port into the real engine, and does the "self-produced" content pipeline (AI-drafted, hand-polished) work end to end. There is also no pack-format spec precise enough for an external coding agent to author valid packs without reading the game's source.

## Solution

Build the vertical slice in Godot 4.7 (GDScript): a complete 2-3 hour arc of the Core Loop (turn phases, branch-choice quests, AP card battles with pre-announced enemy actions, collection) with the pirate theme, trilingual text (Chinese, English, Japanese), and text-based Adult Content. Ship the Theme Pack system as a versioned pure-JSON contract, the AI Entry as player-configured generation (a cloud key or a local endpoint — the game hosts nothing), and the first Agent Kit (pack-contract document plus a Claude Code skill) so external agents can author packs in their native workflow. The desktop build is primary; a web export carries the all-ages experience.

## User Stories

1. As a player, I want a complete 2-3 hour quest flow across preparation, operation, base, and war-report phases, so that I can judge whether the loop is genuinely fun.
2. As a player, I want AP card battles where enemy actions are announced one round in advance, so that spending AP now versus bracing is a real tactical choice.
3. As a player, I want branch-choice quests with distinct paths, so that my route decisions change what I face.
4. As a player, I want a card collection where duplicates grant permanent stat bonuses, so that battles and chests feed long-term power.
5. As a player, I want the Fatigue part to drag AP regen based on a visible state, so that long operations demand resource management.
6. As a player, I want the game fully playable offline with built-in packs, so that I never need an AI setup just to play.
7. As a player, I want the UI fully localized in Chinese, English, and Japanese, so that I can play in my own language.
8. As a player, I want theme packs to swap names, icons, flavor text, palette, and part parameters without touching rules, so that a new world needs no re-learning.
9. As a player, I want to import a Theme Pack from a file, so that I can play packs made by friends or by my agent.
10. As a player, I want invalid packs rejected with specific reasons and zero state change, so that importing is always safe.
11. As a player, I want to configure a generation provider in settings — a cloud API key or a local endpoint with recommended presets — so that I can create content through a service I already have.
12. As a player, I want every generation persisted cache-first into pack or save storage, so that identical requests never cost again.
13. As an adult-content player, I want explicit text content in the built-in packs, so that the game matches its rating.
14. As an adult-content player, I want to point generation at my own local endpoint, so that adult generation works within provider limits without any hosted service.
15. As a creator, I want to export the current Theme Pack as JSON, so that I have a by-example specification of the format.
16. As a creator, I want a written pack-contract document, so that I can author packs from scratch without reading the source.
17. As a creator, I want all three languages required by the contract, so that every player gets complete text in their language.
18. As a Claude Code user, I want an official skill that encodes the pack contract, so that my agent authors valid packs in its native workflow.
19. As an external coding agent (Claude Code, Codex), I want a pure-JSON pack format with a fixed, versioned contract, so that I can author packs offline with no game-engine access.
20. As the developer, I want walkthrough replays as deterministic tests at the Engine API boundary, so that refactors cannot silently break the loop.
21. As the developer, I want a versioned pack contract, so that old packs keep loading as the format grows.
22. As the developer, I want the slice's content drafted through the same pipeline players will use and then hand-polished, so that the AI Entry is dogfooded before public launch.
23. As a web-export player, I want an all-ages browser build, so that I can try the game with zero install (Adult Content stays desktop-only).
24. As the developer, I want MIT-licensed code and CC-BY text/art, so that the ecosystem can spread freely.
25. As the developer, I want a 30-minute playtest build at the end, so that the Core Loop decision can be revisited on evidence.

## Implementation Decisions

- **Godot 4.7.2 + GDScript** (ADR-0003; the installed editor version was verified on this machine). Desktop is the primary target; a web export ships the all-ages experience only.
- **The Engine is a deterministic rules layer**; AI output reaches the game only through it. No AI runs inside the Engine loop (CONTEXT.md: Engine; ADR-0002).
- **Theme Pack contract v1: pure JSON, versioned from day one** (ADR-0002). All three languages required (the prototype required English only — a v1 tightening). Parts catalog holds Fatigue only for the slice; packs pick parts and set parameters within validated ranges; packs never carry code in v1. The prototype encoded the contract precisely (branch `prototype/theme-mod-loop`, `validatePack`), trimmed to its decision-rich shape:

  ```
  pack := {
    id: string,
    accent: #rrggbb,
    bodyClass: one of the known palette ids,
    parts: { fatigue: { enabled: boolean,
                        params: { threshold: number > 0, apPenalty: number >= 0 },
                        name: string, icon: string } },
    text: { zh: localeText, en: localeText, ja: localeText }   // all three required in v1
  }
  localeText := {
    name, tagline,
    factions: exactly 3 × {name, icon},
    cards: every roster id → {name, icon},
    skillNames: every skill id → name,
    enemies: every enemy id → {name, icon},
    enemyActions: the 3 enemy-action ids → name,
    questTitles: the 4 quest ids → title,
    flavor: { ev_exp: string[1+], ev_gains: string[1+], base: string[1+],
              reportTpl: contains {turn} {loss} {left} },
    parts: { fatigue: {name, icon} }
  }
  ```

- **Validation failure returns an explicit reason list and leaves state untouched.** Export→import is a round-trip: an exported pack is itself a valid pack.
- **AI Entry: zero hosting** (ADR-0006). In-game generation talks to a provider the player configures (cloud API key or local endpoint) with recommended presets; every generation persists cache-first so identical requests never re-bill.
- **Agent Kit, in-slice**: a pack-contract document plus one Claude Code skill that encodes the contract (owner decision).
- **Adult Content is text-only in the slice**; the imagery pipeline is a later milestone (ADR-0005).
- **License**: MIT for code, CC-BY for text/art (ADR-0004).
- **Distribution and repo creation are deferred** until the slice is done (owner decision); this spec is published as local markdown under `.scratch/` and becomes the first GitHub issue then.
- **The TS prototype is the reference, not the codebase**: mechanics, walkthrough replays, and the pack contract carry over; its code does not (ADR-0003).

## Testing Decisions

- **One seam (owner-confirmed): the Engine API boundary** — `validate_pack()` plus deterministic state transitions driven by scripted action sequences. The UI layer is untested.
- Tests are **walkthrough replays**: load a pack, run a scripted action sequence, assert final state bit-for-bit. Prior art: the prototype's 4 walkthrough replays and ~28 smoke assertions (branch `prototype/theme-mod-loop`), ported to the Engine's API.
- Also covered at the same seam: invalid-pack rejection with specific reasons and untouched state; export→mutate→import round-trip; language switching preserves state.
- Good tests assert external behavior only — Engine responses and resulting state — never internal node structure or scene layout.
- Runner: Godot headless CLI, suitable for CI later.

## Out of Scope

- Adult image generation (pipeline deferred; slice is text-only adult)
- Code-carrying packs and the restricted GDScript DSL (ADR-0002, ADR-0007 — a later format version)
- Any hosted AI service (ADR-0006 rules this out by design)
- GitHub repo creation, itch.io publishing, and any mod-sharing platform UI
- Parts catalog beyond Fatigue
- Core Loop redesign (contingent on the 30-minute playtest; see CONTEXT.md)

## Further Notes

- The 30-minute playtest on this slice is the gate that revisits the Core Loop decision.
- Naming is deferred until after the slice; the repo keeps the codename `ai-moddable-game`.
- When the GitHub repo is created (after the slice, per owner decision), publish this spec as the first issue labeled `ready-for-agent`.
- Full decision trail: `CONTEXT.md`, `docs/adr/0001`–`0007`, and the survey in `research/`.

## Comments

All ten tickets implemented on branch m1-vertical-slice (31 walkthrough replays green; desktop + web artifacts reproducible via scripts/build.sh; code review fixes merged). The spec's own gate — the 30-minute playtest that revisits the Core Loop decision — awaits a human session; notes template: docs/playtest/notes-template.md.
