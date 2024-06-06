extends NetcodeNode2DComponent
class_name Move

@export var friction = 7500 # (int, 0, 10000)
@export var acceleration = 7500 # (int, 0, 10000)
@export var max_speed = 250 # (int, 0, 10000)

var velocity = Vector2.ZERO
var delta = CommandFrame.frame_length_sec

func _netcode_init():
	#data_container = MoveData.new()
	netcode.init(self, "MVE", MoveData.new(), MoveCompression.new())
	add_to_group("Move")

#func _ready():
#	data_container.set_data_with_obj(self)

func execute(_frame : int, entity, input_vector, speed_mod = 1.0, acc_mod = 1.0) -> void:
	if input_vector == Vector2.ZERO:
		set_velocity(velocity.move_toward(Vector2.ZERO, friction * delta))
	else:
		set_velocity(velocity.move_toward(input_vector * max_speed * speed_mod, acceleration * acc_mod * delta))
		if velocity.length_squared() > pow(max_speed * speed_mod, 2):
			set_velocity(velocity.normalized() * max_speed * speed_mod)
	_move_with_collisions(entity)

func execute_fixed_velocity(_frame : int, entity, fixed_velocity : Vector2) -> void:
	set_velocity(fixed_velocity)
	_move_with_collisions(entity)

func execute_with_fixed_decay(_frame : int, entity, fixed_decay : int) -> void:
	set_velocity(velocity.move_toward(Vector2.ZERO, fixed_decay * delta))
	_move_with_collisions(entity)

func set_velocity(new_velocity) -> void:
	velocity = new_velocity.snapped(Vector2.ONE)
	entity.set_velocity(velocity)

func _move_with_collisions(entity):
	var has_collisions = entity.move_and_slide()
	entity.global_position = entity.global_position.snapped(Vector2.ONE)
	entity.velocity = entity.velocity.snapped(Vector2.ONE)
	velocity = entity.velocity

func _on_collisions(entity):
	var combined_velocity = Vector2.ZERO
	for collision in entity.get_slide_collision_count():
		combined_velocity = get_normalized_velocity_of_collider_if_character(entity, collision, combined_velocity)
	move_from_combined_velocity(entity, combined_velocity)

func get_normalized_velocity_of_collider_if_character(entity, collision : int, combined_velocity : Vector2) -> Vector2:
	var collision_2D : KinematicCollision2D = entity.get_slide_collision(collision)
	var collider = collision_2D.get_collider()
	if collider.is_in_group("Entities"):
		combined_velocity = _on_character_collision(collision_2D.get_normal(), collider.velocity, combined_velocity)
	return combined_velocity

func _on_character_collision(normal : Vector2, char_velocity : Vector2, combined_velocity : Vector2) -> Vector2:
	var vel_along_normal = char_velocity.dot(normal) * normal
	combined_velocity += vel_along_normal
	return combined_velocity

func move_from_combined_velocity(entity, combined_velocity : Vector2) -> void:
	var old_velocity = velocity
	velocity += combined_velocity
	entity.move_and_collide(velocity * CommandFrame.frame_length_sec)
	velocity = old_velocity
