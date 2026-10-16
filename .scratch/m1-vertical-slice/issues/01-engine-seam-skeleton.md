# 01: Engine test seam + project skeleton

**What to build:** A Godot 4.7 (GDScript) project that boots to a placeholder scene reading live Engine state, where the Engine is an autoload exposing exactly one seam — `validate_pack()` plus a deterministic step API — and a walkthrough replay can be executed headless from the CLI and pass. This is the prefactor every later ticket rides on: the seam first, everything else through it.

**Blocked by:** None (can start immediately).

**Status:** done

- [x] The project opens and runs; the placeholder scene renders live Engine state
- [x] The Engine exposes `validate_pack()` and deterministic state transitions as its only public seam
- [x] A trivial walkthrough replay (scripted action sequence → asserted final state) runs headless via CLI and passes
- [x] ADR-0003 respected: the TS prototype is reference only; no ported code

## Comments

Implemented on branch m1-vertical-slice (commit 3c4d1c9); merged with all M1 tickets. All checkboxes hold; headless suite green.
