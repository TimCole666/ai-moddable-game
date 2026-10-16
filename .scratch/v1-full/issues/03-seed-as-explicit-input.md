# 03: Seed as an explicit input to new games

**What to build:** A new game takes an explicit seed, and the seed is stored in the run state. Given the same pack, seed, and actions, the game produces the same state. This is the foundation for the card draft and for saves. Existing native replays keep their expected results. If the stored seed changes a baseline snapshot, update the baselines in one mechanical pass.

**Blocked by:** None (can start immediately)

Status: ready-for-agent

- [ ] A new game accepts a seed, and the seed appears in the run state
- [ ] Two runs with the same pack, seed, and actions produce identical snapshots
- [ ] No randomness exists outside the seed
- [ ] All existing native replays pass
