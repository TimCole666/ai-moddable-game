# 08: Agent Kit

**What to build:** The Own-Agent Path made turnkey (ADR-0006): a pack-contract document that fully specifies the v1 schema, validation rules, and worked examples, plus one Claude Code skill that encodes the contract so a coding agent can author packs in its native workflow. Proven by an end-to-end round-trip: an external agent authors a pack, it validates, and it plays.

**Blocked by:** 04 (Theme Pack contract v1).

**Status:** ready-for-agent

- [ ] The contract document specifies the v1 schema, validation reasons, and at least one worked example per section
- [ ] A Claude Code skill encodes the contract (installable and invocable)
- [ ] An agent-authored pack passes `validate_pack()` and plays in-game
- [ ] The round-trip is demonstrated with a real agent run, not a hand-written simulation
