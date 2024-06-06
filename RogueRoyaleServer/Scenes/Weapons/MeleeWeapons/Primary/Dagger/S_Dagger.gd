extends BaseDagger
class_name ServerDagger

@export var parry_sfx: Resource

var debug_hit_entities = []

func execute(frame, input_actions : InputActions) -> int:
	super.execute_tree(frame, input_actions, weapon_data)
	Logging.log_line(str(entity.player_id) + " Dagger position = " + str(global_position))
	Logging.log_line("Dagger hitbox position = " + str(shape.global_position))
	netcode.set_state_data(weapon_data)
	netcode.send_to_clients()
	Logging.log_line("Animation frame = " + str(weapon_data.animation_frame) + " frame = " + str(frame))
	return weapon_data.attack_end

func _on_area_entered(area):
	super._on_area_entered(area)
	if "entity" in area:
		if area.entity != entity and not area.is_in_group("BaseHurtbox"):
			if area.is_in_group("Hurtbox"):
				if debug_hit_entities.has(area.entity):
					assert(false) #,"Double hit an entity!")
				else:
					debug_hit_entities.append(entity)

func end_execution(frame : int):
	debug_hit_entities.clear()
	super.end_execution(frame)
	show()
	netcode.set_state_data(weapon_data)
	netcode.send_to_clients()

func physics_process(frame : int, input_actions : InputActions) -> void:
#	super.physics_process(frame, input_actions)
#	netcode.set_state_data(weapon_data)
#	netcode.send_to_clients()
	pass

func on_parry(frame : int):
	super.on_parry(frame)
	get_node("%FXManager").add_fx(parry_sfx)
	netcode.set_state_data(weapon_data)
	netcode.send_to_clients()
