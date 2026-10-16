# Build verification

Record of the reproducible build run for the M1 vertical slice (ticket 09's
`scripts/build.sh`), from a fresh temp output directory.

## Run details

- Date: 2026-10-17
- Godot: `4.7.2.stable.official.ed1daf0bf` (`godot --version`)
- Replay suite: `ALL 31 REPLAY(S) PASSED` (exit 0)
- `scripts/build.sh all` from a fresh `OUT_DIR`: exit 0
- Desktop smoke boot (`--headless --quit-after 5`): exit 0, printed
  `desktop smoke boot: OK`

## Artifact sizes (fresh output dir, `ls -l`)

```
desktop:
-rwxr-xr-x 1 tiancaijb tiancaijb 73744832 ai-moddable-game.x86_64

web:
-rw-r--r-- 1 tiancaijb tiancaijb    11944 index.apple-touch-icon.png
-rw-r--r-- 1 tiancaijb tiancaijb     2973 index.audio.position.worklet.js
-rw-r--r-- 1 tiancaijb tiancaijb     7298 index.audio.worklet.js
-rw-r--r-- 1 tiancaijb tiancaijb     5446 index.html
-rw-r--r-- 1 tiancaijb tiancaijb     5700 index.icon.png
-rw-r--r-- 1 tiancaijb tiancaijb   279815 index.js
-rw-r--r-- 1 tiancaijb tiancaijb   225408 index.pck
-rw-r--r-- 1 tiancaijb tiancaijb    21443 index.png
-rw-r--r-- 1 tiancaijb tiancaijb 39514754 index.wasm
```

## Reproduce

A reviewer reruns the verification with, from the repository root:

```
godot --headless --path game --import
godot --headless --path game res://tests/run_replays.tscn   # ALL 31 REPLAY(S) PASSED, exit 0
OUT_DIR=$(mktemp -d) ./scripts/build.sh all                 # exit 0
"$OUT_DIR/desktop/ai-moddable-game.x86_64" --headless --quit-after 5
```

Note: `OUT_DIR` is consumed by the build script via the environment, so the
smoke-boot line needs `OUT_DIR=<dir>` persisted (e.g. `OUT_DIR=$(mktemp -d)`
into a variable first) — build outputs are never committed.
