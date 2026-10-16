# 01: Owner decisions for saves and the native rules entry point

**What to build:** The owner answers four questions that block the save and title screen tickets. (1) Save slots: one per run, or several. (2) Autosave: none, at phase boundaries, or at every step. (3) Pack change: when a pack has changed since a save was made, reject the save, or resume with the old pack. (4) Native Rance-10 option: where the player-visible comparison option lives (title screen, settings, or other), and whether developers also get a separate entry point.

**Blocked by:** None (can start immediately)

Status: done

- [x] Each of the four questions has a recorded answer
- [x] Answers are written into the v1 spec, and the matching "still open" items are removed
- [x] Tickets 18 and 19 can be picked up without further questions

## Answers

1. Save slots: one save per run.
2. Autosave: at phase boundaries.
3. Pack change: resume with a copy of the old pack stored in the save.
4. Native Rance-10 option: on the title screen only. No separate developer entry point (the developer CLI flag was not selected).
