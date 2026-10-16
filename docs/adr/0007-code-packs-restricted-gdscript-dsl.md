# Code packs run a restricted GDScript DSL — no embedded runtime

**Status**: superseded by ADR-0009 — the GDScript DSL was dropped for JSON expression trees run by a self-written interpreter.

Future code-carrying packs (ADR-0002) will execute sandboxed GDScript under a restricted, allowlisted DSL rather than an embedded JavaScript or WASM runtime. Rejected QuickJS-via-GDExtension and WASM targets: an extra runtime dependency outweighs JS's edge in AI-codegen quality, and the DSL's small API surface is itself the security boundary.

**Consequences**: Agent Kits must carry rich GDScript examples to offset weaker model familiarity with GDScript.
