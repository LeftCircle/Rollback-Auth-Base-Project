extends Node
class_name MoveOnAttack

func _on_attack_ended(move_data : MoveOnAttackData) -> void:
	move_data.speed_mod = 1.0

func _on_attack_started(attack_direction : Vector2, move_data : MoveOnAttackData) -> void:
	move_data.attack_direction = attack_direction

func set_attack_direction(attack_direction : Vector2, move_data : MoveOnAttackData) -> void:
	move_data.attack_direction = attack_direction

static func move_entity(frame : int, move_component : Move, move_data) -> void:
	var vel = move_data.attack_direction * move_data.speed_mod * move_component.max_speed
	move_component.execute_fixed_velocity(frame, move_data.entity, vel)

func set_speed_mod(speed_mod : float, move_data : MoveOnAttackData) -> void:
	move_data.speed_mod = speed_mod
