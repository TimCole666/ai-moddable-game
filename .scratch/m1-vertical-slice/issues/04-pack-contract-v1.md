# 04: Theme Pack contract v1

**What to build:** The Theme Pack as a versioned pure-JSON contract (see the spec's inlined schema from the prototype): trilingual text all required, the Fatigue part enableable with parameters in validated ranges, flavor arrays and the war-report template with its placeholders. The Engine loads packs from files, validates with explicit reason lists, rejects malformed packs with zero state change, and exports the current pack as JSON. Two hand-written placeholder packs are switchable in-game — same rules, new world.

**Blocked by:** 03 (Turn cycle + quests).

**Status:** done

- [x] The v1 schema validates: id, palette enum, Fatigue params (threshold > 0, apPenalty >= 0), all three locales complete, report template placeholders present
- [x] The contract carries a version field from day one (ADR-0002)
- [x] Invalid packs are rejected with specific reasons and state untouched (replay-asserted)
- [x] Export → mutate → import round-trips into a playable pack
- [x] Two placeholder packs switch in-game without touching rules

## Comments

Implemented on branch m1-vertical-slice (commit fb03aae); merged with all M1 tickets. v1 schema enforced with version gate; round-trip and pack switching replay-asserted. Two placeholder slots: the second was later superseded by the finished pirate pack (ticket 07) — end state exceeds the ticket.
