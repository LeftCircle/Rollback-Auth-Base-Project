extends StaticBody2D

@onready var animation = $AnimationPlayer

func open():
	animation.play_backwards("Close")

func close():
	animation.play("Close")
