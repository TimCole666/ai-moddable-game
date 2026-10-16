# 06: AI Entry

**What to build:** In-game generation with zero hosting (ADR-0006): a settings surface where the player configures a provider — a cloud API key or a local endpoint — from recommended presets, and a generation flow whose prompt output is parsed, validated against the v1 contract, and persisted cache-first so identical requests never re-bill. A generated pack lands in the in-game pack list and plays immediately.

**Blocked by:** 04 (Theme Pack contract v1).

Status: done

- [x] Provider settings accept a cloud key or a local endpoint, with recommended presets
- [x] Generation produces packs that pass v1 validation or fail with actionable errors
- [x] Cache-first persistence: an identical generation request returns the stored result without a second call
- [x] A generated pack appears in the pack list and plays (full round-trip demo)

## Comments

Implemented on branch m1-vertical-slice (commit c5da3ec); merged with all M1 tickets. All checkboxes hold; cache-first persistence proven with exactly-one-network-call replay.
