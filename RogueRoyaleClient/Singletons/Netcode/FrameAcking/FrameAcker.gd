extends Node

var acked_frames = []
var mutex = Mutex.new()

func ack_server_frame(server_frame):
	mutex.lock()
	acked_frames.append(server_frame)
	mutex.unlock()

func get_acked_frames():
	mutex.lock()
	var received_server_frames = acked_frames.duplicate()
	if received_server_frames.size() > 100:
		print("Too many acked frames. Just dropping them all")
		received_server_frames = []
	acked_frames = []
	mutex.unlock()
	return received_server_frames
