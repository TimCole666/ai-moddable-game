#!/usr/bin/env sh
# Build the M1 vertical slice artifacts (ticket 09).
#
#   scripts/build.sh                 # both targets into game/build/
#   scripts/build.sh desktop         # Linux/Desktop only
#   scripts/build.sh web             # Web (all-ages) only
#   OUT_DIR=/tmp/fresh-out scripts/build.sh   # reproducibility check: any dir
#
# Requirements: godot 4.7.x on PATH with matching export templates installed.
# Artifacts:
#   game/build/desktop/ai-moddable-game.x86_64   (full slice, Adult Content in)
#   game/build/web/index.html (+ .js/.wasm/.pck) (all-ages only, ADR-0005)
set -eu

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)/game"
OUT_ROOT="${OUT_DIR:-$PROJECT_DIR/build}"

export_desktop() {
	mkdir -p "$OUT_ROOT/desktop"
	godot --headless --path "$PROJECT_DIR" \
		--export-release "Linux/Desktop" "$OUT_ROOT/desktop/ai-moddable-game.x86_64"
}

export_web() {
	mkdir -p "$OUT_ROOT/web"
	godot --headless --path "$PROJECT_DIR" \
		--export-release "Web" "$OUT_ROOT/web/index.html"
}

smoke_desktop() {
	# The exported Linux binary boots headless (pck embedded). NOTE: exported
	# binaries are compiled without --path support — never pass --path to one.
	"$OUT_ROOT/desktop/ai-moddable-game.x86_64" --headless --quit-after 5
	echo "desktop smoke boot: OK"
}

case "${1:-all}" in
desktop)
	export_desktop
	smoke_desktop
	;;
web)
	export_web
	;;
all)
	export_desktop
	smoke_desktop
	export_web
	;;
*)
	echo "usage: scripts/build.sh [desktop|web|all]" >&2
	exit 2
	;;
esac

echo "artifacts in $OUT_ROOT"
