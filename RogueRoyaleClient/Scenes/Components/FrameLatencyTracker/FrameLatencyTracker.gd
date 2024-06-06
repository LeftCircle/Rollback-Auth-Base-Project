extends Node
class_name FrameLatencyTracker

const AVERAGE_AFTER : float = 10.0
const SIZE = int(AVERAGE_AFTER)

var netcode = FrameLatencyTrackerNetcode.new()
var data_container = FrameLatencyTrackerData.new()

var remote_latencies = {}
var local_frame_latency = ValueAverager.new()
var is_entity = false

func _init():
	netcode.init(self, "FLT", data_container, FrameLatencyTrackerCompresser.new())
	set_physics_process(false)
	set_process(false)

func add_local_frame_latency(frame_latency : float) -> void:
	local_frame_latency.add_value(frame_latency)

func add_remote_frame_latency(player_id : int, frame_latency : float) -> void:
	if not remote_latencies.has(player_id):
		remote_latencies[player_id] = ValueAverager.new()
	remote_latencies[player_id].add_value(frame_latency)

func get_remote_latency(player_id : int) -> float:
	if not remote_latencies.has(player_id):
		return 0.0
	return remote_latencies[player_id].average
