extends RefCounted
class_name ClientBufferRanges

const INPUT_BUFFER_CLOSE = 4
const INPUT_BUFFER_FAR = 8
const INPUT_BUFFER_TOO_FAR = 10

const MIN_AHEAD = 1

var too_close : float = 0
var too_far : float = 0
var way_too_far : float = 0

func set_buffer_ranges(half_rtt : float) -> void:
	# We want a bit of a buffer
	too_close = max(1, int(half_rtt + 1) + 2)
	too_far = too_close + 2
	way_too_far = too_far + 2
