extends CharacterBody2D
class_name KinematicEntity

signal queued_for_free(entity)
signal components_removed(entity)

var state : int = SystemController.STATES.MOVE
var next_state : int = SystemController.STATES.MOVE
var input_actions = InputActions.new()

var input_vector = Vector2.ZERO
var looking_vector = Vector2.ZERO
var class_stats = ClassStats.new()
var damage_calculator = DamageCalculator.new()
var combat_events = CombatEventQueue.new()
# is_entity_flag is here as well as the group, because we need to check if it is an entity before
# it enters the scene tree on the client
var is_entity = true
#var frame : int = 0

# Server only
var position_history = PositionHistory.new()

@onready var components = $Components

func _on_ready():
	_component_ready()
	_gameplay_ready()
	position_history.init(self)

func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("Entities")
	connect("tree_exiting",Callable(self,"_on_tree_exiting"))
	_on_ready()
	MoveStateSystem.queue_entity(CommandFrame.frame, self)

func _gameplay_ready():
	damage_calculator.player_class_stats = class_stats
	combat_events.init(self)

# Just for the server (Client entities are built dynamically)
func _component_ready():
	for component in components.get_children():
		component.add_owner(self)
		components.add_component(CommandFrame.frame, component)

func has_component_group(group : String) -> bool:
	return components.has_group(group)

func get_component(group : String):
	return components.get_component_in_group(group)

func get_primary_weapon():
	return components.get_primary_weapon()

func get_secondary_weapon():
	return components.get_secondary_weapon()

func add_component(frame : int, component) -> void:
	components.add_component(frame, component)

func remove_component(frame : int, component, free_component = true) -> void:
	var has_component_to_remove = components.remove_component(frame, component, free_component)
	if has_component_to_remove:
		emit_signal("components_removed", self)

func on_attack_hit_entity(frame : int, event : CombatEvent, was_blocked = false) -> void:
	var damage = damage_calculator.get_damage(event.weapon_data)
	event.entity_received_event.on_hurtbox_hit_by(frame, event, damage)
	event.object_did_event.on_successful_hit(event.entity_received_event)

func on_range_attack_hit_entity(frame, event : CombatEvent) -> void:
	print("Range Attack hit hurtbox not yet implemented for " + self.to_string())
	assert(false) #,"Range Attack hit hurtbox not yet implemented for " + self.to_string())

func on_hurtbox_hit_by(frame : int, event : CombatEvent, damage : int):
	# To be overriden by child classes
	print("Hurtbox hit not yet implemented for " + self.to_string())
	assert(false)

func on_melee_hitbox_hit(event: CombatEvent):
	assert(false) #," on_parry not yet implemented for " + self.to_string())

func _on_tree_exiting():
	emit_signal("queued_for_free", self)

