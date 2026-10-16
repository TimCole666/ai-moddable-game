# 06: Pure expression interpreter

**What to build:** A pure evaluation module with one entry point. It takes an expression, a read-only view of state, and a budget, and returns a value or a structured error. It supports literals, reads from the state view, arithmetic, comparison, boolean logic, and conditionals. It has no access to clock, files, network, or randomness. It is tested on its own, without the game running.

**Blocked by:** None (can start immediately)

Status: ready-for-agent

- [ ] Each supported node kind has at least one test
- [ ] Malformed input returns a structured error with a reason
- [ ] Exceeding the budget returns an error and no value
- [ ] Unknown functions and unknown state paths are denied
