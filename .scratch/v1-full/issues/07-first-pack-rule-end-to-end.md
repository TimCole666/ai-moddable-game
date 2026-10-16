# 07: First pack rule end to end

**What to build:** A version 2 pack can declare one expression rule that runs at the war report and changes the realm. The rule is validated at import, with reasons for any error. The engine evaluates it through the interpreter. A replay shows the realm change. An invalid rule leaves the state unchanged.

**Blocked by:** 05 (Pack contract v2 gate), 06 (Pure expression interpreter)

Status: ready-for-agent

- [ ] A pack with a valid rule changes the realm at the war report, shown by a replay
- [ ] An invalid rule is rejected at import with a reason, and state does not change
- [ ] The replay is deterministic
