# 05: Trilingual interface chrome

**What to build:** All Engine chrome (phases, scenes, state labels, logs, buttons) localized in Chinese, English, and Japanese, switchable mid-run — and switching preserves the run's state bit-for-bit. Pack text needs no fallback logic: the v1 contract requires all three languages (a deliberate tightening over the prototype, which fell back to English).

**Blocked by:** 04 (Theme Pack contract v1).

**Status:** ready-for-agent

- [ ] Every engine chrome string exists in zh, en, and ja
- [ ] The language switcher works mid-run with state preserved bit-for-bit (replay-asserted)
- [ ] Theme switching and language switching compose without state drift
