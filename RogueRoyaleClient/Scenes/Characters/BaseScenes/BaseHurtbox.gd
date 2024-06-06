extends Area2D
class_name BaseHurtbox

signal hurtbox_hit(body, damage)

@onready var entity = get_parent()

func _ready():
	add_to_group("Hurtbox")

func get_hurtbox_shape():
	return get_child(0)
