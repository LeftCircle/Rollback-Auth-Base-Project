extends Node

enum STATES{MOVE, DASH, DODGE, ATTACK_PRIMARY, ATTACK_SECONDARY, RANGE_WEAPON, HEALING_FLASK,
	KNOCKBACK, NULL}

var state_systems = []
var pre_state_systems = []
var post_state_systems = []

# Other systems that I didn't want to be singletons
var RemoteInputSystem : RemoteInputReceiver = RemoteInputReceiver.new()

@onready var n_bits_for_states = BaseCompression.n_bits_for_int(STATES.NULL)
@onready var state_to_system = {
	STATES.MOVE: MoveStateSystem,
	STATES.ATTACK_PRIMARY : AttackPrimaryStateSystem,
	STATES.ATTACK_SECONDARY : AttackSecondaryStateSystem,
	STATES.DODGE : DodgeStateSystem
}

func _ready():
	add_to_group("PhysicsProcessRequired")

func _physics_process(delta):
	var frame = CommandFrame.execute()
	FrameSmoother.execute()
	Server.server_api.poll()
	FrameInitSystem.execute()
	PlayerUpdateSystem.execute()
	RemoteInputSystem.execute()
	WorldState.execute()
	RollbackSystem.execute()
	execute()
	ComponentFreeSystem.execute()
	AudioQueue.execute()
	MisspredictSmoothingSystem.execute_normal_frame()

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

func execute(frame : int = CommandFrame.frame) -> void:
	Logging.log_line(" ---------------- START OF REGULAR FRAME UPDATES ----------------")
	var entities = get_tree().get_nodes_in_group("Entities")
	_collect_and_send_local_inputs(frame)
	entity_frame_updates(frame, entities)
	Logging.log_line("---------------- END OF REGULAR FRAME UPDATES ----------------")

func entity_frame_updates(frame : int, entities : Array) -> void:
	# This is where components will be predicted.
	_execute_pre_state_systems(frame)
	PlayerInputSystem.execute(frame)
	_collision_response(frame, entities)
	_execute_states(frame)
	_execute_post_state_systems(frame)
	LocalAnimationSystem.execute(frame)
	StateHistorySystem.execute(frame)

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

func _collect_and_send_local_inputs(frame) -> void:
	LocalInputPollerSystem.execute(frame)

func _execute_states(frame : int) -> void:
	for state_system in state_systems:
		state_system.execute(frame)

func has_entity(entity) -> bool:
	return entity.is_in_group("Entities")

func prep_systems_for_rollback(frame : int) -> void:
	for state_system in state_systems:
		state_system.prep_for_rollback(frame)

func end_rollback(frame : int) -> void:
	for state_system in state_systems:
		state_system.end_rollback(frame)

func get_system_for_state(state : int):
	return state_to_system[state]

func before_gut_test():
	set_physics_process(false)
	for system in state_systems:
		if system.has_method("before_gut_test"):
			system.before_gut_test()
