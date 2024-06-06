extends Node

signal rollback_started(frame : int)
signal rollback_frame(frame : int)

func execute(end_frame : int = CommandFrame.frame) -> void:
	var entities = get_tree().get_nodes_in_group("Entities")
	#if not entities.is_empty():
		#var oldest_frame = _get_oldest_frame(entities)
	var reset_frame = MissPredictFrameTracker.frame_to_reset_to
	if reset_frame != MissPredictFrameTracker.NO_FRAME and not ProjectSettings.get_setting("global/ClientOnlyTest"):
		_stop_physics_processes()
		Logging.log_line("----------------  START OF ROLLBACK SYSTEM ----------------")
		Logging.log_line("Resetting back to frame %s. Command frame: %s. End frame: %s" % [reset_frame, CommandFrame.frame, end_frame])
		CommandFrame.execution_frame = reset_frame
		SystemController.prep_systems_for_rollback(reset_frame)
		DeferredDeleteComponent.on_rollback(reset_frame)
		# Spawn server components before the rollback frame
		ServerComponentContainer.on_rollback_frame(reset_frame)
		emit_signal("rollback_started", reset_frame)
		_reset_entities_to_frame(reset_frame, entities)
		emit_signal("rollback_frame", reset_frame)
		_repredict_entities_from_oldest_frame(reset_frame, entities, end_frame)
		SystemController.end_rollback(CommandFrame.frame)
		Logging.log_line("----------------  END OF ROLLBACK SYSTEM ----------------")
		_resume_physics_processes()

func _stop_physics_processes():
	var nodes_using_physics = get_tree().get_nodes_in_group("PhysicsProcessRequired")
	for node in nodes_using_physics:
		node.set_physics_process(false)

func _resume_physics_processes():
	var nodes_using_physics = get_tree().get_nodes_in_group("PhysicsProcessRequired")
	for node in nodes_using_physics:
		node.set_physics_process(true)

# If an entity is part of the State System, the state system component will register it to the appropriate system
func _reset_entities_to_frame(frame : int, entities : Array) -> void:
	Logging.log_line("Resetting entities to frame " + str(frame))
	for entity in entities:
		entity.components.reset_components_to_frame(frame)
	#MisspredictSmoothingSystem.execute_corrected_frame()

func _repredict_entities_from_oldest_frame(frame : int, entities : Array, end_frame : int) -> void:
	var next_frame = CommandFrame.get_next_frame(frame)
	CommandFrame.execution_frame = next_frame
	#PhysicsServer2D.sync_physics_before_simulation()
	PhysicsServer2D.advance_physics_post_simulation()
	#while next_frame < end_frame:
	while CommandFrame.command_frame_greater_than_previous(end_frame, next_frame):
		#print("Repredicting frame %s" % [next_frame])
		Logging.log_line("Repridicting frame --- " + str(next_frame) + " ---")
		# Not sure if this should be before or after sync_physics_simulation
		Logging.log_line("-- Emitting rollback frame signal -- ")
		emit_signal("rollback_frame", next_frame)
		Logging.log_line("-- Post rollback frame signal -- ")
		PhysicsServer2D.sync_physics_before_simulation()
		
		ServerComponentContainer.on_rollback_frame(next_frame)
		SystemController.entity_frame_updates(next_frame, entities)

		PhysicsServer2D.advance_physics_post_simulation()
		next_frame = CommandFrame.get_next_frame(next_frame)
		CommandFrame.execution_frame = next_frame
	#assert(CommandFrame.execution_frame == CommandFrame.frame, "Debug to ensure frames match")
	PhysicsServer2D.sync_physics_before_simulation()
