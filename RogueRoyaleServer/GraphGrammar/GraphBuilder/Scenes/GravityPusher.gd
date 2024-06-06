extends Area2D

const push_mod = 10000

var collision_obj = CollisionShape2D.new()
var collision_shape = RectangleShape2D.new()

func _ready():
	collision_obj.shape = collision_shape
	collision_shape.size = Vector2(48, 48)
	add_child(collision_obj)

func set_size(new_size : Vector2) -> void:
	collision_shape.size = new_size / 2

func _on_Area2D_body_entered(body):
	var dist = body.global_position.distance_to(global_position)
	var center_to_body = body.global_position.direction_to(global_position)
	var force = center_to_body * 1 / dist * push_mod
	#body.apply_central_force(-force)

func queue__gravity_pusher_free():
	queue_free()
