extends RefCounted
class_name StableBufferFinder

const STABLE_BUFFER_SIZE = 2.5 #2.75
const MAX_AHEAD_OF_STABLE = 1.5

# {player_id : int, stable_buffer_frames : int}
# The stable buffer is found by accounting for the ping difference
# between each player and the max ping player
var stable_buffers = {}

func track_player(player_id : int) -> void:
	if not stable_buffers.has(player_id):
		stable_buffers[player_id] = STABLE_BUFFER_SIZE

func stop_tracking(player_id : int) -> void:
	if stable_buffers.has(player_id):
		stable_buffers.erase(player_id)

func has_player(player_id : int) -> bool:
	return stable_buffers.has(player_id)

func get_stable_buffer(player_id : int) -> float:
	if stable_buffers.has(player_id):
		_find_stable_buffer(player_id)
		return stable_buffers[player_id]
	else:
		track_player(player_id)
		return STABLE_BUFFER_SIZE

func _find_stable_buffer(player_id : int) -> void:
	var frame_latency = LatencyTracker.get_frame_latency(player_id)
	var frame_difference = max(LatencyTracker.max_average_frame_latency - frame_latency, 0)
	stable_buffers[player_id] = STABLE_BUFFER_SIZE + frame_difference
