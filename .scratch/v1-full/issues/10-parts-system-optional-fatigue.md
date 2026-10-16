# 10: Parts system with Fatigue as an optional built-in part

**What to build:** A part is a named bundle of state fields, parameters with validated ranges, and hooks. Fatigue becomes a built-in optional part. A pack enables or disables it and sets its parameters within range. Current Fatigue behavior stays the same, and its replay stays green.

**Blocked by:** 08 (Hook dispatch and whitelisted engine functions)

Status: ready-for-agent

- [ ] Fatigue works when enabled and when disabled, both driven by pack data
- [ ] Parameters are validated against their ranges, with reasons
- [ ] Part name and description are required in zh, en, and ja
- [ ] The existing Fatigue replay passes
