extends Area2D
class_name PastCombatBox

signal queueing_free_past_box_for_area(area)

var base_box
var entity
# This is the entity that this past box will be set to the frame of reference for
# ONLY THIS ENTITY CAN HIT THE PAST BOX
var entity_frame_of_reference
var active_frame_minus_one : int = 0
var is_for_mob : bool
var collision_shape

func _ready():
	set_deferred("monitoring", false)
	set_deferred("monitorable", true)
	tree_exiting.connect(_on_tree_exiting)
	add_to_group("PastCombatBox")

func init_past_box(entity_reference, box_to_dup) -> void:
	if is_instance_valid(box_to_dup) and is_instance_valid(box_to_dup.shape):
		collision_layer = box_to_dup.collision_layer
		collision_mask = box_to_dup.collision_mask
		duplicate_box_shape(box_to_dup)
		entity = box_to_dup.entity
		base_box = box_to_dup
		entity_frame_of_reference = entity_reference
		for box_type in CombatBoxTypes.get_box_types():
			if box_to_dup.is_in_group(box_type):
				add_to_group(box_type)
		process_priority = base_box.process_priority + 1
		_check_for_is_for_mob(box_to_dup)

func _check_for_is_for_mob(box_to_dup) -> void:
	if not box_to_dup.entity.is_in_group("Players"):
		is_for_mob = true
		# Because set deferred disabled, we have to actually check 1 before the active frame
		active_frame_minus_one = CommandFrame.get_previous_frame(CommandFrame.frame)
		disable_box()
	else:
		_player_physics_process()
		enable_box()

func _physics_process(delta):
	if not is_instance_valid(base_box):
		queue_free()
		return
	if is_for_mob:
		_mob_physics_process()
	else:
		_player_physics_process()

func _mob_physics_process():
	var client_frame = ClientWorldStateMap.get_world_state_frame(entity_frame_of_reference.player_id)
	if client_frame == active_frame_minus_one:
		enable_box()
	elif CommandFrame.command_frame_greater_than_previous(client_frame, active_frame_minus_one):
		Logging.log_line("Trying to get buffered history for frame " + str(client_frame))
		var past_data = base_box.get_history_for_frame(client_frame)
		if past_data != PastBoxHistory.NO_DATA_FOR_FRAME:
			global_position = past_data.global_position
			global_rotation = past_data.global_rotation
			global_scale = past_data.global_scale
		_check_for_box_queue_free(client_frame)

# Not sure if we should queue free on the disable frame or after
func _check_for_box_queue_free(client_frame : int):
	var next_frame = CommandFrame.get_next_frame(client_frame)
	var next_data = base_box.get_history_for_frame(next_frame)
	if next_data != PastBoxHistory.NO_DATA_FOR_FRAME:
		if next_data.disabled:
			queue_free()

func _player_physics_process():
	var client_frame = ClientWorldStateMap.get_world_state_frame(entity_frame_of_reference.player_id)
	_set_global_position(client_frame)
	_set_rotation_and_scale(CommandFrame.frame)
	Logging.log_line("Trying to get buffered history for frame " + str(client_frame))
	var past_data = base_box.get_history_for_frame(client_frame)
	var current_data = base_box.get_history_for_frame(CommandFrame.frame)
	if past_data != PastBoxHistory.NO_DATA_FOR_FRAME:
		Logging.log_line("Past data = ")
		Logging.log_object_vars(past_data)
	else:
		Logging.log_line("No past data for frame " + str(client_frame) + " vs cf " + str(CommandFrame.frame))
	if current_data != PastBoxHistory.NO_DATA_FOR_FRAME:
		pass
	else:
		Logging.log_line("No current data for frame cf " + str(CommandFrame.frame))
	if base_box.shape.disabled:
		Logging.log_line("Past box queued free on frame " + str(CommandFrame.frame))
		queue_free()
	#Logging.log_line(str(entity.player_id) + " past hitbox position = " + str(global_position) + str(" for frame of reference " + str(client_frame)))

func _set_global_position(frame : int) -> void:
	var data = base_box.get_history_for_frame(frame)
	if data != PastBoxHistory.NO_DATA_FOR_FRAME:
		global_position = data.global_position

func _set_rotation_and_scale(frame) -> void:
	var data = base_box.get_history_for_frame(frame)
	if data != PastBoxHistory.NO_DATA_FOR_FRAME:
		global_rotation = data.global_rotation
		global_scale = data.global_scale

func _set_global_transforms_on_start() -> void:
	var client_frame = ClientWorldStateMap.get_world_state_frame(entity_frame_of_reference.player_id)
	var past_pos = entity.position_history.retrieve(client_frame)
	position = past_pos
	var current_data = base_box.get_history_for_frame(CommandFrame.frame)
	collision_shape.position += current_data.global_position
	collision_shape.rotation = current_data.global_rotation
	collision_shape.scale = current_data.global_scale


# Client hitboxes are enabled/disabled immediately to respect the player getting the dodge off first
func set_if_disabled():
	if base_box.shape.is_disabled() == true:
		disable_box()
	else:
		enable_box()

func duplicate_box_shape(old_hurtbox) -> void:
	var shape = old_hurtbox.shape
	collision_shape = shape.duplicate(true)
	collision_shape.position = Vector2.ZERO
	collision_shape.scale = Vector2.ONE
	collision_shape.rotation = 0
	add_child(collision_shape)

func enable_box():
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", false)

func is_disabled() -> bool:
	return collision_shape.is_disabled()

func disable_box():
	if is_instance_valid(collision_shape):
		collision_shape.set_deferred("disabled", true)

func _on_tree_exiting():
	emit_signal("queueing_free_past_box_for_area", base_box)

#func _on_PastHurtbox_area_entered(area):
#	Logging.log_line("Past hurtbox area entered on frame " + str(CommandFrame.frame))
#	print("Past hurtbox area entered on frame " + str(CommandFrame.frame))
func _exit_tree():
	Logging.log_line("Hurtbox is exiting tree on frame " + str(CommandFrame.frame))

