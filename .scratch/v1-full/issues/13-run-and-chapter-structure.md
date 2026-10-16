# 13: Run and chapter structure with a shared realm

**What to build:** A run has a set number of chapters, and each chapter has a set number of turns. One realm value is shared across the whole run. The realm starts at its default and drops at each war report. The run is lost when the realm reaches zero or below. It is won after the last chapter, with the realm above zero. Chapter and turn counts come from pack data. The native rule set keeps its own limits.

**Blocked by:** 04 (Rule-set seam with the native Rance-10 rules selectable by name), 05 (Pack contract v2 gate)

Status: ready-for-agent

- [ ] A two-chapter test run can be won by one replay and lost by another, through the realm
- [ ] The start of each chapter is logged
- [ ] Chapter and turn counts are read from pack data
- [ ] Existing native replays pass unchanged
