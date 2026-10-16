# ai-moddable-game

An AI-moddable game built with Godot 4. Theme Packs are pure-JSON content
contracts validated by the engine's `validate_pack()` seam; an in-game AI
Entry can generate them through any OpenAI-compatible endpoint.

## Layout

- `game/` — the Godot project (engine, UI, tests)
- `agent-kit/` — pack contract docs, authoring skill, examples
- `scripts/build.sh` — reproducible build script
- `docs/adr/` — architecture decision records

## License

Code is licensed under the MIT License — see [LICENSE](LICENSE).
Game text, art, and Theme Pack content are licensed under
CC BY 4.0 — see [LICENSE-ASSETS](LICENSE-ASSETS). (Decision recorded in
`docs/adr/0004-open-source-free-distribution.md`: the game is open source
and free; builds ship on itch.io, source on GitHub.)
