extends Move
class_name C_Move

func _init_history():
	history = MoveHistory.new()

func execute(frame : int, entity, new_input_vector, new_speed_mod = 1.0, acc_mod = 1.0) -> void:
	super.execute(frame, entity, new_input_vector, new_speed_mod, acc_mod)
	Logging.log_line("ID: %s | Standard: Velocity for frame %s = %s. Pos = %s" % [entity.player_id, frame, velocity, global_position])
	netcode.on_client_update(frame)
	#animate(entity)

func execute_fixed_velocity(frame : int, entity, fixed_velocity : Vector2) -> void:
	super.execute_fixed_velocity(frame, entity, fixed_velocity)
	Logging.log_line("ID: %s | fixed vel: Velocity for frame %s = %s. Pos = %s" % [entity.player_id, frame, velocity, global_position])
	netcode.on_client_update(frame)
	#animate(entity)

func execute_with_fixed_decay(frame : int, entity, fixed_decay : int) -> void:
	super.execute_with_fixed_decay(frame, entity, fixed_decay)
	netcode.on_client_update(frame)
	Logging.log_line("ID: %s | fixed decay: Velocity for frame %s = %s. Pos = %s" % [entity.player_id, frame, velocity, global_position])
	#animate(entity)

func reset_to_frame(frame : int) -> void:
	super.reset_to_frame(frame)
	if is_instance_valid(entity):
		entity.global_position = global_position
		position = Vector2.ZERO
		Logging.log_line("ID: %s | RESET: Velocity for frame %s = %s. Pos = %s" % [entity.player_id, frame, velocity, global_position])

func save_history(frame : int) -> void:
	global_position = entity.global_position
	if is_instance_valid(data_container):
		history.add_data(frame, data_container)
	else:
		history.add_data(frame, self)
		Logging.log_line("Saving move data:")
		log_component(frame)

func animate(entity) -> void:
	if velocity.length_squared() > 0:
		entity.local_animation_tree.start_playing_node("Run", velocity.normalized())
	else:
		entity.local_animation_tree.start_playing_node("Idle", velocity.normalized())

func log_component(frame : int) -> void:
	var id = -2
	if is_instance_valid(entity):
		id = entity.player_id
	Logging.log_line("Move data for frame %s | Player: %s, Velocity = %s, Position = %s" % [frame, id, velocity, global_position])
