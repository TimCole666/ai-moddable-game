# Zero AI hosting: player-configured generation plus agent authoring kits

The game runs no AI infrastructure of any kind. This supersedes ADR-0001's hosted "official AI entry": built-in packs ship pre-generated and complete, so the game is fully playable offline, and new generation happens through a provider the player configures in settings — a cloud API key or a local endpoint (Ollama and friends), with recommended presets. The own-agent path gains official Agent Kits: ready-made skill/plugin integrations so coding agents like Claude Code and Codex can author packs in their native workflow. Amends ADR-0005: there is no bundled model downloader — players self-explore and wire up local models for adult content.

**Consequences**: zero inference cost for the developer; the promise changes from "generates with zero setup" to "plays with zero setup, generates with your own key or local model".
