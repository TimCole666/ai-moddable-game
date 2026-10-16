# 15: Quest branch trees

**What to build:** Quests are branch trees. Each choice leads to a different next node. The number of options varies by step, from 2 to 3. Each tree is 4 to 5 steps deep. The seven node types stay: battle, auto, chest, heal, gains, medal, and event. Choice cards show each option's label in the player's language.

**Blocked by:** 07 (First pack rule end to end), 13 (Run and chapter structure with a shared realm)

Status: ready-for-agent

- [ ] A tree with variable forks reaches different endings for different choices, shown by two replays
- [ ] Every node type can be reached in some replay
- [ ] No raw node id appears on screen
- [ ] The native rule set's fixed quests still work
- [ ] Shared constant tables are read by the balance tooling, so change them in an expand-then-contract sequence
