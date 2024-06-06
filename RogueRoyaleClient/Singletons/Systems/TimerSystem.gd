extends Node


func _ready() -> void:
	SystemController.register_pre_state_system(self)

func execute(frame : int) -> void:
	var timers = get_tree().get_nodes_in_group("Timer")
	for timer in timers:
		timer.advance(frame)
