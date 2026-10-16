# 04: Theme Pack contract v1

**What to build:** The Theme Pack as a versioned pure-JSON contract (see the spec's inlined schema from the prototype): trilingual text all required, the Fatigue part enableable with parameters in validated ranges, flavor arrays and the war-report template with its placeholders. The Engine loads packs from files, validates with explicit reason lists, rejects malformed packs with zero state change, and exports the current pack as JSON. Two hand-written placeholder packs are switchable in-game — same rules, new world.

**Blocked by:** 03 (Turn cycle + quests).

**Status:** ready-for-agent

- [ ] The v1 schema validates: id, palette enum, Fatigue params (threshold > 0, apPenalty >= 0), all three locales complete, report template placeholders present
- [ ] The contract carries a version field from day one (ADR-0002)
- [ ] Invalid packs are rejected with specific reasons and state untouched (replay-asserted)
- [ ] Export → mutate → import round-trips into a playable pack
- [ ] Two placeholder packs switch in-game without touching rules
