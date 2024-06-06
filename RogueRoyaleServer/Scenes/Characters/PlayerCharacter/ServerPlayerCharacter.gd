extends BaseCharacter
class_name ServerPlayerCharacter

var netcode = CharacterNetcodeBase.new()#NetcodeBase.new()

#onready var lag_comp_hurtbox_spawner = $LagCompHurtboxSpawner

func _init():
	_netcode_init()

func _netcode_init():
	netcode.init(self, "CHR", PlayerState.new(), PlayerStateCompresser.new())

func _ready():
	super._ready()
	_player_component_ready()
	netcode.send_to_clients()

func _on_ready():
	netcode.assign_class_instance_id()
	super._on_ready()
	if is_instance_valid(Map.region_from_grammar):
		var spawn_position = Map.region_from_grammar.get_player_spawn_point(player_id)
		spawn_position += Vector2(randi_range(-20, 20), randf_range(-20, 20))
		position = spawn_position

func _player_component_ready():
	for component in components.get_children():
		component.add_owner(self)
		if component.is_in_group("Weapon"):
			add_weapon(CommandFrame.frame, component)
		elif component.is_in_group("Health"):
			component.health_reached_zero.connect(_on_death)
			damaged.connect(component.damage)

#func _kinematic_entity_physics_process(delta):
#	Logging.log_line(" ---- " + str(player_id) + " physics process start ----")
#	_standard_character_functions()
#	Logging.log_line("Player state = ")
#	Logging.log_object_vars(netcode.state_data)
#	Logging.log_line(" ---- Physics process end ----")
#
#func _standard_character_functions():
#	var frame = CommandFrame.frame
#	inputs = InputProcessing.get_action_or_duplicate_for_frame(player_id, frame)
#	input_actions.receive_action(inputs)
#	Logging.log_line("executing input action:")
#	input_actions.log_input_actions()
#	states.physics_process(frame, input_actions)
#	stamina.physics_process(frame)
#	health.physics_process(frame)
#	_weapon_physics_process(frame)
#	_update_player_state(frame)

func add_weapon(frame : int, new_weapon, add_to_components = true):
	super.add_weapon(frame, new_weapon, add_to_components)
	var equip_type = new_weapon.weapon_data.equip_type

func _on_death():
	var spawn_position = HackedPlayerDeath.spawn_location
	global_position = spawn_position
	var state_system : S_StateSystemState = get_component("StateSystem")
	state_system.set_state(CommandFrame.frame, SystemController.STATES.MOVE)
	health.full_heal(CommandFrame.frame)
	primary_weapon.end_execution(CommandFrame.frame)
	secondary_weapon.end_execution(CommandFrame.frame)
	ranged_weapon.holster()

func _set_state_from_physical_hit_effect(frame : int, weapon_data : WeaponData, dir_to_entity : Vector2) -> void:
	if weapon_data.physical_hit_effect == WeaponData.PHYSICAL_HIT_EFFECTS.STUN:
		print("Stun state not yet implemented for " + self.to_string())
	elif weapon_data.physical_hit_effect == WeaponData.PHYSICAL_HIT_EFFECTS.KNOCKBACK:
		var new_knockback = Knockback.new()
		new_knockback.set_data(-dir_to_entity, weapon_data.knockback_speed, weapon_data.knockback_decay)
		print("Knockback added on frame %s" % [frame])
		add_component(frame, new_knockback)

################################################################################
### KinematicEntity functions
###############################################################################

func on_attack_hit_entity(frame : int, event : CombatEvent, was_blocked = false) -> void:
	assert(event.entity_did_event == self) #,"debug")
	emit_signal("landed_melee_attack", CommandFrame.frame)
	#ammo.refill_ammo(CommandFrame.frame)
	super.on_attack_hit_entity(frame, event, was_blocked)
	#var damage = damage_calculator.get_damage(event.weapon_data)
	#event.entity_received_event.on_hurtbox_hit_by(frame, event, damage)
	#event.object_did_event.on_successful_hit(event.entity_received_event)

func on_range_attack_hit_entity(frame : int, event : CombatEvent) -> void:
	assert(event.entity_did_event == self) #,"debug")
	var damage = damage_calculator.get_damage(event.weapon_data)
	event.entity_received_event.on_hurtbox_hit_by(event, damage)

func on_hurtbox_hit_by(frame : int, event : CombatEvent, damage : int) -> void:
	assert(event.entity_did_event != self) #,"debug")
	var dir_to_entity = global_position.direction_to(event.entity_did_event.global_position)
	dir_to_entity.x = round(dir_to_entity.x * 10) / 10
	dir_to_entity.y = round(dir_to_entity.y * 10) / 10
	emit_signal("damaged", CommandFrame.frame, damage)
	_set_state_from_physical_hit_effect(frame, event.weapon_data, dir_to_entity)

func on_melee_hitbox_hit(event : CombatEvent):
	event.object_did_event.on_parry(CommandFrame.frame)

func on_projectile_hit_by_melee(event : CombatEvent) -> void:
	ammo.refill_ammo(CommandFrame.frame)
