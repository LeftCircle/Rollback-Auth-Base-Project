extends CharacterBody2D

enum K_TYPE{REPLACE, SIMPLE_ADD, SYSTEM}

@export_range(100, 1000) var knockback_impulse : int = 1000
@export_range(100, 1000) var decay : int = 100
@export_range(100, 1000) var force_variation : int = 500
@export var knockback_type : K_TYPE = K_TYPE.REPLACE
@export var knockback_system : Node 

var knockback_data = KnockbackData.new()

func _ready():
	set_physics_process(false)
	randomize()

func _input(event):
	if Input.is_action_just_pressed("attack_primary"):
		knockback_towards_mouse()

func knockback_towards_mouse():
	if not is_physics_processing():
		_start_knockback()
	else:
		_update_knockback()

func _start_knockback() -> void:
	if knockback_type == K_TYPE.REPLACE:
		_start_knockback_replace()
	elif knockback_type == K_TYPE.SIMPLE_ADD:
		_start_knockback_simple_add()
	elif knockback_type == K_TYPE.SYSTEM:
		_start_knockback_system()

func _start_knockback_replace() -> void:
	var mouse_pos = get_global_mouse_position()
	knockback_data.knockback_direction = (mouse_pos - global_position).normalized()
	knockback_data.knockback_speed = knockback_impulse + randi_range(-force_variation, force_variation)
	set_physics_process(true)

func _start_knockback_system() -> void:
	var new_knockback_data = KnockbackData.new()
	new_knockback_data.knockback_direction = (get_global_mouse_position() - global_position).normalized()
	new_knockback_data.knockback_speed = knockback_impulse + randi_range(-force_variation, force_variation)
	new_knockback_data.knockback_decay = decay
	knockback_system.register_entity(self, new_knockback_data)

func _start_knockback_simple_add() -> void:
	_start_knockback_replace()

func _update_knockback() -> void:
	if knockback_type == K_TYPE.REPLACE:
		velocity = Vector2.ZERO
		_start_knockback()
	elif knockback_type == K_TYPE.SIMPLE_ADD:
		_update_knockback_simple_add()
	elif knockback_type == K_TYPE.SYSTEM:
		pass

func _update_knockback_simple_add() -> void:
	var dir_to_mouse = (get_global_mouse_position() - global_position).normalized()
	var original_velocity = knockback_data.knockback_direction * knockback_data.knockback_speed
	var new_velocity = dir_to_mouse * (knockback_impulse + randi_range(-force_variation, force_variation))
	var final_velocity = original_velocity + new_velocity
	knockback_data.knockback_direction = final_velocity.normalized()
	knockback_data.knockback_speed = final_velocity.length()

func _physics_process(delta):
	knockback(delta)

func knockback(delta : float):
	var new_velocity = knockback_data.knockback_direction * knockback_data.knockback_speed
	velocity = new_velocity
	move_and_slide()
	knockback_data.knockback_speed = new_velocity.move_toward(Vector2.ZERO, decay * delta).length()
	if knockback_data.knockback_speed <= 0:
		set_physics_process(false)
 


