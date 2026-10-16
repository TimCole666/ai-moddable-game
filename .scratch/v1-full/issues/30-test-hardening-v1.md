# 30: Test hardening for v1

**What to build:** Tests that protect the v1 core. Same pack, seed, and actions give identical snapshots on two separate runs. Every state-change kind triggers a hook somewhere in the suite. Each expression node kind has its own tests. Export and then import plays identically.

**Blocked by:** 11 (Packs add parts and rules), 17 (Full 15-chapter structure with placeholder text)

Status: ready-for-agent

- [ ] The determinism test runs the same inputs twice in one process and compares snapshots
- [ ] Hook coverage is checked across the suite
- [ ] Each expression node kind has at least one test
- [ ] The export-import round trip plays identically
- [ ] Failing any one of these tests fails the suite
