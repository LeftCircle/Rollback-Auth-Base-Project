extends CharacterBody2D
class_name KinematicEntity

signal queued_for_free(entity)
signal components_removed(entity)
signal remove_from_all_systems_without_exit(frame, entity)

var input_actions = InputActions.new()

var input_vector = Vector2.ZERO
var looking_vector = Vector2.ZERO
var class_stats = ClassStats.new()
var damage_calculator = DamageCalculator.new()
var combat_events = CombatEventQueue.new()
# is_entity_flag is here as well as the group, because we need to check if it is an entity before
# it enters the scene tree
var is_entity = true
var frame : int = 0

@onready var components = get_node("%Components")

func _on_ready():
	_netcode_ready()
	_gameplay_ready()

func _ready():
	motion_mode = CharacterBody2D.MOTION_MODE_FLOATING
	add_to_group("Entities")
	connect("tree_exiting",Callable(self,"_on_tree_exiting"))
	_on_ready()
	#_add_to_frame_smoothing()
	#MoveStateSystem.queue_entity(CommandFrame.frame, self)

func _add_to_frame_smoothing():
	var frame_smoothing = SmoothingRegisterer.new()
	frame_smoothing.add_node_to_smooth(self)
	add_child(frame_smoothing)

func _gameplay_ready():
	damage_calculator.player_class_stats = class_stats
	combat_events.init(self)

func _netcode_ready():
	CommandFrame.node_uses_command_frames(self)

func has_component_group(group : String) -> bool:
	return components.has_group(group)

func has_component(component) -> bool:
	return components.has_component(component)

func get_component(group : String):
	return components.get_component_in_group(group)

func get_primary_weapon():
	return components.get_primary_weapon()

func get_secondary_weapon():
	return components.get_secondary_weapon()

func add_component(frame : int, component) -> void:
	components.add_component(frame, component)
	# Client only
	if is_in_group("Players") and not component.netcode.class_id == "HLT":
		component.is_lag_comp = false

func remove_component(component) -> bool:
	var has_component_to_remove = components.remove_component(component)
	if has_component_to_remove:
		emit_signal("components_removed", self)
	return has_component_to_remove

func remove_and_immediately_delete_component(component) -> bool:
	var has_component_to_remove = components.remove_and_immediately_delete(component)
	if has_component_to_remove:
		emit_signal("components_removed", self)
	return has_component_to_remove

func get_components() -> Array:
	return components.get_components()

func on_attack_hit_entity(frame : int, event : CombatEvent, was_blocked = false) -> void:
	var damage = damage_calculator.get_damage(event.weapon_data)
	event.entity_received_event.on_hurtbox_hit_by(frame, event, damage)
	event.object_did_event.on_successful_hit(event.entity_received_event)

func on_range_attack_hit_entity(frame : int, event : CombatEvent) -> void:
	print("Range Attack hit hurtbox not yet implemented for " + self.to_string())
	#assert(false) #,"Range Attack hit hurtbox not yet implemented for " + self.to_string())

func on_hurtbox_hit_by(frame : int, event : CombatEvent, damage : int):
	# To be overriden by child classes
	print("Hurtbox hit not yet implemented for " + self.to_string())
	#assert(false)

func on_melee_hitbox_hit(event: CombatEvent):
	print("Melle hitbox hit not yet implemented for " + self.to_string())

func _on_tree_exiting():
	emit_signal("queued_for_free", self)
