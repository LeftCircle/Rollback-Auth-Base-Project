extends CharacterBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
@export var ACCELERATION = 5000000
@export var MAX_SPEED = 1000
@export var ROLL_SPEED = 120
@export var FRICTION = 5000000

enum {
	MOVE
}

var state = MOVE
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
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector = input_vector.normalized()

	velocity = input_vector * MAX_SPEED
	move()

func move():
	set_velocity(velocity)
	move_and_slide()
	#velocity = velocity
