extends Node


func _ready() -> void:
	SystemController.register_pre_state_system(self)

func execute(frame : int) -> void:
	var timers = get_tree().get_nodes_in_group("Timer")
	for timer in timers:
		timer.advance(frame)

# Timers tend to be connected to other components, which makes them very difficult to be pure ECS
# Timer still have their timeout signal, start, stop, and reset functions which can be triggered outside of the system
