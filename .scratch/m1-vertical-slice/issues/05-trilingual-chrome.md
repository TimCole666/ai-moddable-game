# 05: Trilingual interface chrome

**What to build:** All Engine chrome (phases, scenes, state labels, logs, buttons) localized in Chinese, English, and Japanese, switchable mid-run — and switching preserves the run's state bit-for-bit. Pack text needs no fallback logic: the v1 contract requires all three languages (a deliberate tightening over the prototype, which fell back to English).

**Blocked by:** 04 (Theme Pack contract v1).

Status: done

- [x] Every engine chrome string exists in zh, en, and ja
- [x] The language switcher works mid-run with state preserved bit-for-bit (replay-asserted)
- [x] Theme switching and language switching compose without state drift

## Comments

Implemented on branch m1-vertical-slice (commit f73b8cc); merged with all M1 tickets. All checkboxes hold; mid-run language switch bit-for-bit, composes with theme switching.
