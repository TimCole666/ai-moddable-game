# Ticket 12 — Art-driven main view (pack art reskin)

Status: ready-for-human

Labels: feature, ui

## Why

The playable view (ticket 11) was functionally clickable but visually a text
form. The user set the presentation bar at B: full illustrated art (portraits,
card faces, backdrops). Decision recorded in ADR-0008 — art ships inside the
pack as base64, generated with the user's own image pipeline, anime flat-color
style.

## Done

- [x] ADR-0008: optional `art` section — base64 PNG/JPEG in the single pack
      file, per-image 2M char cap, emoji + accent fallback when absent.
- [x] `scripts/embed_art.py`: injects the 13 illustrations (6 crew portraits,
      4 enemies, 3 phase backdrops) into `builtin_pack.json`.
- [x] Engine: `_validate_art` (magic-byte check, cap), `pack_art()` accessor
      with decode cache cleared on pack switch.
- [x] UI rewrite: phase backdrops (sea/deck/tavern), enemy panel with portrait
      + HP bar + telegraph banner, six crew cards with skill grids, tweened
      HP bars, accent theming, emoji fallback for art-less packs.
- [x] Trilingual chrome keys for the new view elements.
- [x] Tests: `replay_pack_art` (good decode / bad reject / oversize reject /
      art-less fallback), `run_view_smoke` (bot walks every view branch to
      turn 2). 33/33 replays green.
- [x] Agent kit: contract section 7 documents art; AI prompt forbids
      model-generated art.
- [x] Desktop + Web rebuilt; desktop boot smoke clean.

## Verification

- `run_replays.tscn` → ALL 33 REPLAY(S) PASSED
- `run_view_smoke.tscn` → VIEW SMOKE OK — every branch rendered, turn 2 reached
- `scripts/build.sh` → desktop 96M, web 64M

## Acceptance

The user plays the rebuilt desktop build and confirms the presentation bar is
met. Regeneration with style reference (`--ref`) available if any illustration
misses the anime flat-color anchor.
