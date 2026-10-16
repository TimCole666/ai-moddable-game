# 09: Build artifacts

**What to build:** Shippable binaries of the finished slice: a desktop build as the primary target and a web export carrying the all-ages experience only — Adult Content gated off on the web (ADR-0005/0006 consequences). The headless test suite runs green against the desktop target.

**Blocked by:** 05 (Trilingual interface chrome), 06 (AI Entry), 07 (Pirate content pack).

Status: done

- [x] A desktop build runs on Linux with the full slice (Adult Content included)
- [ ] A web export runs in a browser with Adult Content gated off (export + gate verified headless; an actual browser run is still pending)
- [x] The headless walkthrough replay suite is green on the desktop target
- [x] Both artifacts are reproducible from a clean checkout via CLI

## Comments

Implemented on branch m1-vertical-slice (commit d1a47b4); merged with all M1 tickets. Desktop + web artifacts reproducible via scripts/build.sh from a clean checkout (docs/build-verification.md). Pending verification: running the web export in an actual browser (infeasible headless here).
