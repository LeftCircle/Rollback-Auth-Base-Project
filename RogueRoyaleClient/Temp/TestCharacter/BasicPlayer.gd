extends CharacterBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var ACCELERATION = 5000
@export var MAX_SPEED = 5000
@export var ROLL_SPEED = 120
@export var FRICTION = 5000000

enum {
	MOVE
}

var state = MOVE
var velocity = Vector2.ZERO
var roll_vector = Vector2.DOWN


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _physics_process(delta):
	match state:
		MOVE:
			move_state(delta)

func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	move()

func move():
	set_velocity(velocity)
	move_and_slide()
	velocity = velocity
