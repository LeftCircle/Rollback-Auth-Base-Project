extends Node
class_name FrameLatencyTracker

const FRAMES_BETWEEN_SENDS = 10

var netcode = FrameLatencyTrackerNetcode.new()
var data_container = FrameLatencyTrackerData.new()
var delayed_sender = DelayedDataSender.new()
var value_averager = SlidingValueAverager.new()

var network_id : int

func _init():
	netcode.init(self, "FLT", data_container, FrameLatencyTrackerCompresser.new())
	#set_physics_process(false)
	set_process(false)
	delayed_sender.send_after_x_frames = FRAMES_BETWEEN_SENDS

func _physics_process(delta):
	_get_enet_latency()
	delayed_sender.send_data(netcode, [network_id])

func _get_enet_latency():
	var enetPacketPeer : ENetPacketPeer = Server.network.get_peer(network_id)
	if is_instance_valid(enetPacketPeer):
		var ping = enetPacketPeer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)
		data_container.eNet_rtt = ping

func add_frame_latency(frame_latency : float) -> void:
	value_averager.add_value(frame_latency)
	#data_container.server_frame_latency = value_averager.average
	# We aren't sending data at the moment, but this would be how it is done
	#_set_data()
	#delayed_sender.send_data(netcode, [network_id])

func get_average_after():
	return value_averager.AVERAGE_AFTER

func get_frame_latency() -> float:
	return value_averager.average

func _set_data():
	data_container.server_frame_latency = value_averager.average

