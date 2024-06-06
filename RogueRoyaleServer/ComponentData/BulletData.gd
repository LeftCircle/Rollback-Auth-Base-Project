extends RefCounted
class_name BulletData

var global_position : Vector2
var velocity : Vector2
var to_despawn : bool = false

func set_data_with_obj(other_obj):
	global_position = other_obj.global_position
	velocity = other_obj.velocity
	to_despawn = other_obj.to_despawn

func set_obj_with_data(other_obj):
	other_obj.global_position = global_position
	other_obj.velocity = velocity
	other_obj.to_despawn = to_despawn

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(global_position, other_obj.global_position) == true) and
	(ModularDataComparer.compare_values(velocity, other_obj.velocity) == true) and
	(ModularDataComparer.compare_values(to_despawn, other_obj.to_despawn) == true)
	)
