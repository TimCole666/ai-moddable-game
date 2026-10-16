# Dual-path AI access: official entry plus own-agent authoring

**Status**: superseded by ADR-0006 — the hosted official entry was dropped; generation is player-configured. The own-agent path (with Agent Kits) survives.

The game ships with a hosted official AI entry as the default (players never need an API key; costs are absorbed by cache-first persistence of every generation) and additionally lets advanced players author theme packs with their own AI agents or tools (validated on import). We chose this over BYOK-only — an API-key wall kills mainstream onboarding — and over hosted-only, which ignores the agent-creator ecosystem. Amends the survey's recommendation 5 (research/ai-extensible-games-survey.md).
