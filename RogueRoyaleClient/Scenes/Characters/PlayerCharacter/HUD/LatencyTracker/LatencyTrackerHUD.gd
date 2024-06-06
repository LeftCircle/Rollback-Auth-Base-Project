extends Control
class_name LatencyTrackerHUD

var remote_latency_labels = {}

@onready var frames_ahead_of_server_label = $VBoxContainer/FramesAheadOfServer
@onready var container = $VBoxContainer
@onready var ping_timer = $PingTimer
@onready var ping_label = $VBoxContainer/PingLabel

func _ready():
	FrameLatencyTrackerSingleton.connect("local_latency_update",Callable(self,"_on_frames_ahead_of_server_update"))
	FrameLatencyTrackerSingleton.connect("remote_latency_update",Callable(self,"_on_remote_frames_ahead_update"))
	

func _on_frames_ahead_of_server_update(frames : float) -> void:
	frames_ahead_of_server_label.text = "Server = " + str(frames)

func _on_remote_frames_ahead_update(player_id : int, frames : float) -> void:
	if not remote_latency_labels.has(player_id):
		_build_new_label(player_id)
	remote_latency_labels[player_id].text = str(player_id) + " = " + str(frames)

func _build_new_label(player_id) -> void:
	var new_label = Label.new()
	new_label.name = str(player_id) + "FrameLatency"
	container.add_child(new_label, true)
	remote_latency_labels[player_id] = new_label


func _on_ping_timer_timeout():
	var ping = FrameLatencyTrackerSingleton.get_rtt()
	ping_label.text = "Ping: %s ms" % [ping]
	
	
