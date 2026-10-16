# Code packs use JSON expression trees run by a self-written interpreter

**Status**: accepted; supersedes ADR-0007.

Packs that carry rules (the sandboxed-code format ADR-0002 foresees as version 2) express them as JSON expression trees, so packs stay pure JSON. The engine evaluates them in a self-written interpreter with a closed set of node kinds, bounded budgets, no clock, file, or network access, and randomness only from the engine's seeded generator. We chose this over a GDScript DSL because GDScript has no sandbox of its own: the interpreter's closed node set is the security boundary, not an allowlist of GDScript calls. Consequences: we build and maintain the interpreter ourselves, and packs may add new parts and rules with hooks at any engine state change, which widens the replay test surface.
