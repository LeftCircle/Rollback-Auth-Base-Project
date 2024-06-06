#################################################
######   SHARED BETWEEN CLIENT AND SERVER   #####
#################################################
extends Node

const FUNC_IS_VOID = null

var thread = Thread.new()
var mutex = Mutex.new()
var sem = Semaphore.new()

var exit_thread : bool = false
var bit_packer = OutputMemoryBitStream.new()
var processed_packets = []
var server_api : SceneMultiplayer

func _init():
#	mutex = Mutex.new()
#	sem = Semaphore.new()
#	thread = Thread.new()
	pass

func init(new_server_api : SceneMultiplayer):
	server_api = new_server_api
	server_api.peer_packet.connect(self._on_packet_received)
	thread.start(Callable(self,"thread_func").bind(0))

func _lock(_caller):
	#print("Locked by " + _caller)
	mutex.lock()

func _unlock(_caller):
	#print("unlocked by " + _caller)
	mutex.unlock()

func _post(_caller):
	sem.post()

func _wait(_caller):
	sem.wait()

func thread_func(_u):
#func _process(delta):
	while true:
		if _time_for_exit():
			#print("STOPPING THE THREAD!")
			break
		thread_process()

func _time_for_exit() -> bool:
	# Protect with Mutex.
	_lock("_time_for_exit")
	var should_exit = exit_thread
	_unlock("_time_for_exit")
	return should_exit

func thread_process():
	#_wait("thread_process")
	_lock("thread_process")
	if server_api.has_multiplayer_peer():
		server_api.poll()
	_unlock("thread_process")

func _on_packet_received(id : int, packet) -> void:
	packet = Array(packet)
	var return_frame = decompress_frame(packet)
	var frame_diff = CommandFrame.frame_difference(CommandFrame.frame, return_frame)
	var frame_ping = frame_diff * 16.6667
	var enet_ping = get_enet_ping(id)
	processed_packets.append([frame_diff, frame_ping])
	#print("Frame difference: %s. Frame ping: %s ms. Enet ping: %s ms." % [frame_diff, frame_ping, enet_ping])

func get_processed_polls() -> Array:
	mutex.lock()
	var packets = processed_packets.duplicate()
	processed_packets.clear()
	mutex.unlock()
	return packets

func send_data(data : Array) -> void:
	mutex.lock()
	data = PackedByteArray(data)
	server_api.send_bytes(data, 0)
	mutex.unlock()

func decompress_frame(bytes : Array):
	bit_packer.init_read(bytes)
	var frame = bit_packer.decompress_frame()
	return frame

func get_enet_ping(id : int) -> float:
	return -1
#	var peer : ENetPacketPeer = network.get_peer(id)
#	return peer.get_statistic(ENetPacketPeer.PEER_ROUND_TRIP_TIME)

# Thread must be disposed (or "joined"), for portability.
func _exit_tree():
	# Set exit condition to true.
	_lock("_exit_tree")
	exit_thread = true # Protect with Mutex.
	_post("_exit_tree")
	_unlock("_exit_tree")

	# Wait until it exits.
	thread.wait_to_finish()
