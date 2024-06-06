extends Area2D
class_name BaseHurtbox

var entity_is_set = false

var entity
var history = PastBoxHistory.new()
@onready var collision_shape = get_child(0)

func _ready():
	# Base hurtboxes are not added to the hurtbox group. This is reserved for PastHurtboxes
	add_to_group("BaseHurtbox")
	# If the entity was not set by hand, set it to the parent
	set_entity(get_parent())

func set_entity(node) -> void:
	if not entity_is_set:
		entity = node
		entity_is_set = true
		process_priority = entity.process_priority + 1

func _physics_process(delta):
	# We can get off by one errors here. When enabling/disabling the hurtbox, we must take care to
	# properly enable/disable past hurtboxes so that it occurs on the same frame
	history.add_data(CommandFrame.frame, collision_shape)

func get_history_for_frame(frame : int):
	return history.retrieve_data(frame)

func get_hurtbox_shape():
	return get_child(0)
