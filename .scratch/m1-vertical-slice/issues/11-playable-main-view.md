# 11: Playable main view

**What to build:** The playtest surfaced that M1 shipped a programmer's view: a raw state dump with six hardcoded buttons — the Engine knew the legal actions, but the view never asked. The Engine now exposes `available_actions()` (legality + chrome labels, same guards `step()` enforces) and `context_line()` (pack names resolved — no bare "grunt"/"e_slash" ids) at the same single seam; the main view renders them as phase-driven buttons with a scrollable, language-following log, and boots in the OS locale instead of hardcoded en.

**Blocked by:** None (replaces the placeholder view in place on this branch).

**Status:** done

- [x] `available_actions()` lists exactly the legal actions with chrome labels, pinned in four situations by the new replay
- [x] The main view renders the Engine's action list dynamically; every press is one `step()`
- [x] `context_line()` shows pack names, announced enemy actions, and quest titles — no raw ids
- [x] The session boots in the OS locale; test harnesses pin `en` so replays stay deterministic
- [x] Scrollable log with new-line follow; buttons in a wrapped grid; nothing clips
- [x] All 32 replays green headless (31 prior + 1 new); desktop build smoke boots OK

## Comments

User verdict on the shipped M1 build: "这根本不可玩" — the view was a debug dump. This ticket is the fix; the review lesson is recorded for the next milestone: "playable" acceptance needs a human-eyes check, not only seam replays.
