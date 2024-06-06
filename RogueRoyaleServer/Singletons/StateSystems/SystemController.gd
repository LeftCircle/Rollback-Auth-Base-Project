extends Node

enum STATES{MOVE, DASH, DODGE, ATTACK_PRIMARY, ATTACK_SECONDARY, RANGE_WEAPON, HEALING_FLASK,
	KNOCKBACK, NULL}

var state_systems = []
var pre_state_systems = []
var post_state_systems = []

var netcode_free_system : NetcodeFreeSystem = NetcodeFreeSystem.new()

@onready var n_bits_for_states = BaseCompression.n_bits_for_int(STATES.NULL)
@onready var state_to_system = {
	STATES.MOVE: MoveStateSystem,
	STATES.ATTACK_PRIMARY : AttackPrimaryStateSystem,
	STATES.ATTACK_SECONDARY : AttackSecondaryStateSystem,
	STATES.DODGE : DodgeStateSystem
}

func _physics_process(_delta):
	CommandFrame.execute()
	Server.server_api.poll()
	execute(CommandFrame.frame)

func register_state_system(state_system) -> void:
	if not state_system in state_systems:
		state_systems.append(state_system)

func register_pre_state_system(pre_state_system) -> void:
	if not pre_state_system in pre_state_systems:
		pre_state_systems.append(pre_state_system)

func register_post_state_system(post_state_system) -> void:
	if not post_state_system in post_state_systems:
		post_state_systems.append(post_state_system)

func has_state_system(state_system) -> bool:
	return state_system in state_systems

func execute(frame : int) -> void:
	var entities = get_tree().get_nodes_in_group("Entities")
	entity_frame_updates(frame, entities)
	netcode_free_system.execute(frame)

func entity_frame_updates(frame : int, entities : Array) -> void:
	_execute_pre_state_systems(frame)
	PlayerInputSystem.execute(frame)
	_collision_response(frame, entities)
	_execute_states(frame)
	_execute_post_state_systems(frame)

func _execute_pre_state_systems(frame : int) -> void:
	for pre_state_system in pre_state_systems:
		pre_state_system.execute(frame)

func _execute_post_state_systems(frame : int) -> void:
	for post_state_system in post_state_systems:
		post_state_system.execute(frame)

func _collision_response(frame : int, entities : Array) -> void:
	# TO DO -> turn this into a system! Each entity has the combat event queue as a component, and the system will update it
	# and add entities to relevant StateSystems
	for entity in entities:
		entity.combat_events.update(frame)

func _execute_states(frame : int) -> void:
	for state_system in state_systems:
		state_system.execute(frame)

func has_entity(entity) -> bool:
	return entity.is_in_group("Entities")

func get_system_for_state(state : int):
	return state_to_system[state]

func before_gut_test():
	set_physics_process(false)
	for system in state_systems:
		if system.has_method("before_gut_test"):
			system.before_gut_test()
