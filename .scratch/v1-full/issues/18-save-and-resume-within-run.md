# 18: Save and resume within a run

**What to build:** The player saves a run in progress and resumes it later. The save holds the full run state and its seed. The slot and autosave rules follow the owner's decision in ticket 01. A save whose pack has changed follows the rule decided in ticket 01.

**Blocked by:** 01 (Owner decisions for saves and the native rules entry point), 03 (Seed as an explicit input), 13 (Run and chapter structure with a shared realm)

Status: ready-for-agent

- [ ] Save, quit, and load give an identical state
- [ ] Play continued from a save matches an uninterrupted run with the same actions (replay)
- [ ] A save whose pack changed follows the decided rule
- [ ] A corrupt save is rejected with a reason, and state does not change
