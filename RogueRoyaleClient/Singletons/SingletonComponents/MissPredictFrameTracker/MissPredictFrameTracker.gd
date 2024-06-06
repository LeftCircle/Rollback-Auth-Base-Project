extends Node


const NO_FRAME = INF

var frame_to_reset_to = NO_FRAME
var last_server_verified_frame = NO_FRAME

func _ready():
	add_to_group("FrameInit")

func frame_init(frame : int) -> void:
	frame_to_reset_to = NO_FRAME

func add_reset_frame(frame : int) -> void:
	if frame_to_reset_to == NO_FRAME:
		_set_reset_frame(frame)
	else:
		if CommandFrame.command_frame_greater_than_previous(frame_to_reset_to, frame):
			_set_reset_frame(frame)

func _set_reset_frame(frame : int) -> void:
	if CommandFrame.frame_greater_than_or_equal_to(frame, last_server_verified_frame):
		frame_to_reset_to = frame

func receive_server_player_state_frame(frame : int) -> void:
	if last_server_verified_frame == NO_FRAME:
		last_server_verified_frame = frame
	else:
		if CommandFrame.command_frame_greater_than_previous(frame, last_server_verified_frame):
			last_server_verified_frame = frame

func before_gut_test():
	frame_init(0)
	last_server_verified_frame = NO_FRAME
