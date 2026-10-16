# 02: Battle core

**What to build:** One full AP card battle playable end to end through the Engine seam: the player spends AP on leader skills, enemy actions are announced one round in advance (spend AP now vs brace and punish), combos scale damage, weaknesses multiply, and the battle resolves to victory or defeat. A walkthrough replay asserts a scripted battle's final state bit-for-bit.

**Blocked by:** 01 (Engine test seam + project skeleton).

**Status:** ready-for-agent

- [ ] A battle is playable end to end: AP spend, skills, damage, heals, guards
- [ ] Enemy actions are pre-announced; bracing reduces incoming damage; a hexed action is cancelled
- [ ] Combos and the weakness multiplier resolve correctly (the prototype's dead-multiplier bug stays dead — see replay)
- [ ] Victory and defeat both terminate the battle with a result state
- [ ] A walkthrough replay asserts the scripted battle's final state bit-for-bit
