# 06: AI Entry

**What to build:** In-game generation with zero hosting (ADR-0006): a settings surface where the player configures a provider — a cloud API key or a local endpoint — from recommended presets, and a generation flow whose prompt output is parsed, validated against the v1 contract, and persisted cache-first so identical requests never re-bill. A generated pack lands in the in-game pack list and plays immediately.

**Blocked by:** 04 (Theme Pack contract v1).

**Status:** ready-for-agent

- [ ] Provider settings accept a cloud key or a local endpoint, with recommended presets
- [ ] Generation produces packs that pass v1 validation or fail with actionable errors
- [ ] Cache-first persistence: an identical generation request returns the stored result without a second call
- [ ] A generated pack appears in the pack list and plays (full round-trip demo)
