# 28: AI Entry generates version 2 packs

**What to build:** The in-game AI Entry generates version 2 packs, including expression rules. Generated packs go through the same validation as any other pack. Results are cached, as in M1.

**Blocked by:** 12 (Pack contract v2 document)

Status: ready-for-agent

- [ ] A generated pack with a rule validates and plays
- [ ] An invalid generation is rejected with reasons, and state does not change
- [ ] A repeated identical request is served from the cache, shown with the test provider
