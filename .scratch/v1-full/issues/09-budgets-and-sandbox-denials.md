# 09: Budgets and sandbox denials

**What to build:** Each expression evaluation has a node-count budget. Each hook invocation and each turn has a total budget. Import checks the budget bounds, and rejects unknown functions and unknown state paths. An over-budget or denied rule fails with a reason and leaves the state unchanged.

**Blocked by:** 08 (Hook dispatch and whitelisted engine functions)

Status: ready-for-agent

- [ ] An over-budget rule fails with a reason at each level (evaluation, hook, turn), and state does not change
- [ ] Unknown functions and unknown state paths are rejected at import with reasons
- [ ] Malformed or unbounded constructs are rejected by the format, shown by tests
