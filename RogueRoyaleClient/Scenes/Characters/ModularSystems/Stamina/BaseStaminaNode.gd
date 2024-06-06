extends Node2D
class_name BaseStaminaNode

enum {FULL, USED}

var state = FULL
var is_empty = false

func use_stamina():
	state = USED
	is_empty = true
	#animations.play("Use")

func refill():
	state = FULL
	is_empty = false
	#animations.play("Fill")

