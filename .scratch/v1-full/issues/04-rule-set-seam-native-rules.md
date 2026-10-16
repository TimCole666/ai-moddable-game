# 04: Rule-set seam with the native Rance-10 rules selectable by name

**What to build:** The game selects a rule set by name. The native Rance-10 rules are one choice, and their behavior does not change. This seam lets the strategy rules sit beside the native rules instead of replacing them in place.

**Blocked by:** None (can start immediately)

Status: ready-for-agent

- [ ] The native rule set is the default, and all existing replays pass unchanged
- [ ] The chosen rule set name is part of the run state
- [ ] An unknown rule set name is rejected with a reason and no state change
