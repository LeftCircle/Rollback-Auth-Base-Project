extends Move
class_name S_Move

func execute(frame : int, entity, new_input_vector, speed_mod = 1.0, acc_mod = 1.0) -> void:
	super.execute(frame, entity, new_input_vector, speed_mod, acc_mod)
	#netcode.set_state_data(self)
	Logging.log_line("ID: %s | Standard: Velocity for frame %s = %s. Pos = %s" % [entity.player_id, frame, velocity, global_position])
	netcode.send_to_clients()

func execute_fixed_velocity(frame, entity, fixed_velocity : Vector2) -> void:
	super.execute_fixed_velocity(frame, entity, fixed_velocity)
	#netcode.set_state_data(self)
	netcode.send_to_clients()
	Logging.log_line("ID: %s | fixed vel: Velocity for frame %s = %s. Pos = %s" % [entity.player_id, frame, velocity, global_position])

func execute_with_fixed_decay(frame, entity, fixed_decay : int) -> void:
	super.execute_with_fixed_decay(frame, entity, fixed_decay)
	#netcode.set_state_data(self)
	netcode.send_to_clients()
	Logging.log_line("ID: %s | fixed decay: Velocity for frame %s = %s. Pos = %s" % [entity.player_id, frame, velocity, global_position])
