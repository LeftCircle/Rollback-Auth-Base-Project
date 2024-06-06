extends BaseHitbox
class_name PlayerHitbox

@onready var collision_shape = $CollisionShape2D


func rotate_hitbox(looking_vector : Vector2) -> void:
	var angle = looking_vector.angle()
	self.rotation = angle
