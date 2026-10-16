# 22: Main screen panels and always-visible realm

**What to build:** The battle view, base view, and war report appear as separate panels on the main screen. The realm stays visible in every phase. Switching language during a run keeps all state. Before the panels change, replace the hard-coded phase number in the main view with the named phase constant.

**Blocked by:** 17 (Full 15-chapter structure with placeholder text)

Status: ready-for-agent

- [ ] Each phase shows its own panel, and the panels do not overlap
- [ ] The realm is visible in every phase
- [ ] Switching language mid-run keeps the run state (the M1 test still passes)
- [ ] No raw phase number appears in the main view code path
