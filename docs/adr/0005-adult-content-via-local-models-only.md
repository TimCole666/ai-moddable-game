# Adult content is generated only locally or by own agents; the official entry is all-ages

**Status**: architecture amended by ADR-0006 — no bundled model downloader; players configure local endpoints themselves. The all-ages/hosted-adult split stands.

The game contains adult content (explicit text and AI-generated imagery). Hosted commercial LLM APIs prohibit it, and a free/open game has no revenue to fund adult-content hosting anyway. Decided: the official AI entry serves all-ages content only; all adult generation runs through on-device open models (text and image) or the player's own agents. Consequences: the desktop build ships an in-game model downloader, image generation is desktop-only, and the web export serves all-ages content only.
