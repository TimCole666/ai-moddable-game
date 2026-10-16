# 02: Battle core

**What to build:** One full AP card battle playable end to end through the Engine seam: the player spends AP on leader skills, enemy actions are announced one round in advance (spend AP now vs brace and punish), combos scale damage, weaknesses multiply, and the battle resolves to victory or defeat. A walkthrough replay asserts a scripted battle's final state bit-for-bit.

**Blocked by:** 01 (Engine test seam + project skeleton).

**Status:** done

- [x] A battle is playable end to end: AP spend, skills, damage, heals, guards
- [x] Enemy actions are pre-announced; bracing reduces incoming damage; a hexed action is cancelled
- [x] Combos and the weakness multiplier resolve correctly (the prototype's dead-multiplier bug stays dead — see replay)
- [x] Victory and defeat both terminate the battle with a result state
- [x] A walkthrough replay asserts the scripted battle's final state bit-for-bit

## Comments

Implemented on branch m1-vertical-slice (commit 24f76a8); merged with all M1 tickets. All checkboxes hold; weakness multiplier pinned live, hex/brace/combo covered by replays.
