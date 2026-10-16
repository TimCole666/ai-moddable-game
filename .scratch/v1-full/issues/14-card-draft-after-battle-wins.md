# 14: Card draft after battle wins

**What to build:** After each battle win, the player sees three candidate cards and takes one. The draft is deterministic under the seed. Drafted cards exist only in the current run. A panel shows each card's name and effect in the player's language.

**Blocked by:** 03 (Seed as an explicit input), 13 (Run and chapter structure with a shared realm)

Status: ready-for-agent

- [ ] The same seed gives the same three offers
- [ ] A new run starts with no drafted cards
- [ ] Duplicate picks grant no permanent bonus
- [ ] Each card's name and effect appear in zh, en, and ja
- [ ] A replay asserts at least one draft pick
