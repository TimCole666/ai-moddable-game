# 08: Hook dispatch and whitelisted engine functions

**What to build:** Rules can attach to any state change the engine emits. Hooks run in a fixed order: pack load order, then declared priority, then id. A hook changes state only by calling whitelisted engine functions through the normal step path. Those calls can trigger further hooks, up to a recursion depth of 3.

**Blocked by:** 07 (First pack rule end to end)

Status: ready-for-agent

- [ ] Every engine state-change kind is listed in one place
- [ ] Hook order is deterministic: a test registers hooks in different orders and gets the same result
- [ ] Recursion stops at depth 3 with a reason
- [ ] A hook that calls an unlisted function is rejected at import
- [ ] Replays together trigger every state-change kind at least once
