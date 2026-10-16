# Theme Pack art: optional embedded section with graceful fallback

**Status**: amended 2026-10-17. Version 1 packs are no longer accepted once version 2 ships, so the "v1 packs run unchanged" clause below no longer applies. The art rules themselves are unchanged.

Theme packs may carry an optional `art` section — base64-encoded JPEG/PNG images (leader portraits, enemy illustrations, backgrounds) embedded directly in the pack's single JSON file, so "a pack is a file" stays true for sharing. Validation accepts absent art (v1 packs run unchanged, degrading to emoji + accent styling) and rejects corrupt or oversized entries with dotted-path reasons (≤2 MB of base64 per image). Decided over a folder/zip pack format because single-file sharing is the Own-Agent Path's core story, and over engine-side art because "switching a Theme Pack swaps the whole skin" only holds if art travels with the pack. Style anchor for shipped content: flat anime, clean lineart (the owner's pick), produced through the image-gen pipeline.

**Consequences**: full-art packs weigh a few MB; the Agent Kit and the AI Entry prompt document the optional section; agents may ship text-only packs — visuals degrade gracefully, never break.
