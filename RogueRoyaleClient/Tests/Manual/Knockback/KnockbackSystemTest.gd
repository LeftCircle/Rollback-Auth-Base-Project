extends Node
class_name KnockbackSystemTest

var knockback_components = []

func _physics_process(delta : float) -> void:
	update(delta)

func register_entity(entity : CharacterBody2D, knockback_data : KnockbackData) -> void:
	knockback_components.append([entity, knockback_data])

func execute_knockback(delta : float) -> void:
	for i in knockback_components.size():
		var entity = knockback_components[i][0]
		var knockback_data : KnockbackData = knockback_components[i][1]
		var velocity = knockback_data.knockback_direction * knockback_data.knockback_speed
		entity.velocity = velocity
		entity.move_and_slide()
		velocity = velocity.move_toward(Vector2.ZERO, knockback_data.knockback_decay * delta)
		knockback_data.knockback_speed = velocity.length()

func remove_finished_knockbacks() -> void:
	for i in range(knockback_components.size() - 1, -1, -1):
		var knockback_data : KnockbackData = knockback_components[i][1]
		if knockback_data.knockback_speed <= 0.0:
			knockback_components.erase(i)

func update(delta : float) -> void:
	execute_knockback(delta)
	remove_finished_knockbacks()

