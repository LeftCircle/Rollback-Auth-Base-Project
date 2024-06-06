extends Node
# KnockbackSystem

func _ready():
	SystemController.register_post_state_system(self)

func execute(frame : int) -> void:
	var knockback_entities = get_tree().get_nodes_in_group("KnockbackEntity")
	for entity in knockback_entities:
		_entity_knockback(frame, entity)

func _entity_knockback(frame : int, entity) -> void:
	var move : Move = entity.get_component("Move")
	var knockback : Knockback = entity.get_component("Knockback")
	_execute_knockback(frame, entity, knockback, move)

func _execute_knockback(frame : int, entity, knockback : Knockback, move : Move) -> void:
	var knockback_data : KnockbackData = knockback.data_container
	if knockback_data.knockback_speed <= 0:
		_on_knockback_ends(frame, entity, knockback)
	else:
		_on_knockback(frame, entity, knockback, move)
		_send_component_data(knockback, move)

func _on_knockback(frame, entity, knockback : Knockback, move : Move) -> void:
	var knockback_data : KnockbackData = knockback.data_container
	Logging.log_line("Executing knockback on ID: %s, speed: %s, decay: %s" % [entity.player_id, knockback_data.knockback_speed, knockback_data.knockback_decay])
	var knockback_velocity = knockback_data.knockback_direction * knockback_data.knockback_speed
	move.execute_fixed_velocity(frame, entity, knockback_velocity)
	knockback_data.knockback_speed = int(move_toward(knockback_data.knockback_speed, 0, knockback_data.knockback_decay * CommandFrame.frame_length_sec))
	Logging.log_line("Post knockback: Speed = %s, Decay = %s" % [knockback_data.knockback_speed, knockback_data.knockback_decay])

func _on_knockback_ends(frame : int, entity, knockback : Knockback) -> void:
	entity.remove_component(frame, knockback, true)
	# TO DO -> there is a cleaner way to add/remove entities from groups than by hand
	entity.remove_from_group("KnockbackEntity")

func _send_component_data(knockback : Knockback, move : Move) -> void:
	knockback.netcode.send_to_clients()
	move.netcode.send_to_clients()
