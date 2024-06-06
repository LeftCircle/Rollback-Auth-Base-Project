extends Dodge
class_name C_Dodge

func _init_history():
	history = DodgeHistory.new()

func execute(frame : int, entity, input_actions : InputActions) -> bool:
	var can_execute = super.execute(frame, entity, input_actions)
	netcode.on_client_update(frame)
	return can_execute

func reset_to_frame(frame : int) -> void:
	super.reset_to_frame(frame)
	if is_executing:
		animations.reset_to("Roll", animation_frame)
	#animations.rollback_to_end_of_frame(frame)
