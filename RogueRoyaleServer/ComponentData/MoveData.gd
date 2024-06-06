extends RefCounted
class_name MoveData

var friction = 0
var acceleration = 0
var max_speed = 0
var velocity = Vector2.ZERO
var global_position : Vector2 = Vector2.ZERO

func set_data_with_obj(other_obj):
	friction = other_obj.friction
	acceleration = other_obj.acceleration
	max_speed = other_obj.max_speed
	velocity = other_obj.velocity
	global_position = other_obj.global_position

func set_obj_with_data(other_obj):
	other_obj.friction = friction
	other_obj.acceleration = acceleration
	other_obj.max_speed = max_speed
	other_obj.velocity = velocity
	other_obj.global_position = global_position

func matches(other_obj) -> bool:
	return (
	(ModularDataComparer.compare_values(friction, other_obj.friction) == true) and
	(ModularDataComparer.compare_values(acceleration, other_obj.acceleration) == true) and
	(ModularDataComparer.compare_values(max_speed, other_obj.max_speed) == true) and
	(ModularDataComparer.compare_values(velocity, other_obj.velocity) == true) and
	(ModularDataComparer.compare_values(global_position, other_obj.global_position) == true)
	)
