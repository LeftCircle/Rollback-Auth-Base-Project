extends Area2D
class_name BaseHurtboxRollback

var entity_is_set = false

var entity
@onready var collision_shape = get_child(0)

func _ready():
	add_to_group("Hurtbox")
	add_to_group("Rollback")
	# If the entity was not set by hand, set it to the parent
	set_entity(get_parent())

func set_entity(node) -> void:
	if not entity_is_set:
		entity = node
		entity_is_set = true
		process_priority = entity.process_priority + 1

func get_hurtbox_shape():
	return get_child(0)
