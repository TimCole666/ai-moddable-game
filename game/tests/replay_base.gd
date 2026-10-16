class_name ReplayBase
extends RefCounted

## Base class for walkthrough replays: a scripted action sequence run through
## the Engine seam, with the final state asserted bit-for-bit. To add a new
## replay, create a script in res://tests/replays/ extending this class and
## override what you need; the runner discovers it automatically.

## Display name used in the pass/fail report.
func replay_name() -> String:
	return "unnamed"


## The Theme Pack to start the session with. Return an empty Dictionary to use
## the builtin pack.
func pack() -> Dictionary:
	return {}


## Scripted action sequence, applied with GameEngine.step() in order. All
## steps must succeed for the replay to pass. An entry that is a Callable is
## run verbatim between steps instead (test-driver code, e.g. file edits);
## its return value is ignored.
func actions() -> Array:
	return []


## Errors expected from new_game() for this replay's pack. Empty means the
## pack must validate and a session must start. Use a non-empty list to pin
## invalid-pack rejection with specific reasons.
func expected_new_game_errors() -> PackedStringArray:
	return PackedStringArray()


## Optional extra assertions, run after the action sequence and before the
## final state diff. Return a list of problems (empty = pass). Use it for
## things the state diff cannot see, e.g. errors captured from a deliberately
## failed step.
func checks() -> PackedStringArray:
	return PackedStringArray()


## Final Engine state asserted bit-for-bit (exact types: int is not float).
func expected_state() -> Dictionary:
	return {}
