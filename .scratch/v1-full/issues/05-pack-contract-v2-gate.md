# 05: Pack contract v2 gate

**What to build:** Packs that declare format version 2 are accepted. Version 1 packs are rejected with a version reason. The built-in pack and the placeholder packs move to version 2 with no change to their rules. Export writes version 2. Owner decision: v1 packs are not supported (see the v1 spec).

**Blocked by:** None (can start immediately)

Status: ready-for-agent

- [ ] A version 1 pack is rejected with a version reason, and state does not change
- [ ] The built-in pack and placeholder packs load at version 2 and pass the native replays
- [ ] Export writes version 2, and the export imports again
