extends Area2D
class_name ParryBox

var entity

func _ready():
	add_to_group("ParryBox")
	add_to_group("Rollback")

#func _physics_process(delta):
#	var parry_box = get_child(0) as CollisionShape2D
#	if parry_box.disabled == false:
#		print("Parry box is active")
