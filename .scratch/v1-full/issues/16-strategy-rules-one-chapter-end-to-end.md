# 16: Strategy rules in the built-in pack, one chapter end to end

**What to build:** Implement the strategy turn rules from the design note as expressions in the built-in pack. Play one full chapter from new game to the chapter's end, with quest trees, card draft, realm, the base phase, and the Fatigue part all on. Each turn runs the four phases in order.

**Blocked by:** 02 (Design the strategy turn rules), 08 (Hook dispatch and whitelisted engine functions), 10 (Parts system with optional Fatigue), 14 (Card draft after battle wins), 15 (Quest branch trees)

Status: ready-for-agent

- [ ] One chapter replay plays all four phases in order every turn
- [ ] The base phase stays independent, with the M1 base options
- [ ] Battle replays from M1 still pass, because battle rules are unchanged
- [ ] Strategy values match the design note
